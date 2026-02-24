import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import 'beneficiary_dependencies.dart';

/// 👥 Family Members Providers
///
/// استخدام Riverpod بدلاً من FutureBuilder للحصول على:
/// - Caching تلقائي
/// - Invalidation ذكي
/// - أداء أفضل

/// Provider لجلب أفراد العائلة الأحياء
final familyMembersProvider = FutureProvider.family<List<FamilyMember>, int>((
  ref,
  beneficiaryId,
) async {
  final database = ref.watch(databaseProvider);
  return await database.familyMembersDao.getMembersByBeneficiary(beneficiaryId);
});

/// Provider لجلب أفراد العائلة المتوفين
final familyDeceasedProvider = FutureProvider.family<List<FamilyDeceased>, int>(
  (ref, beneficiaryId) async {
    final database = ref.watch(databaseProvider);
    return await database.familyDeceasedDao.getDeceasedByBeneficiary(
      beneficiaryId,
    );
  },
);

/// Provider لإحصائيات العائلة
final familyStatisticsProvider = FutureProvider.family<FamilyStatistics, int>((
  ref,
  beneficiaryId,
) async {
  final database = ref.watch(databaseProvider);

  // جلب البيانات بالتوازي
  final results = await Future.wait([
    database.familyMembersDao.getMembersByBeneficiary(beneficiaryId),
    database.familyDeceasedDao.getDeceasedByBeneficiary(beneficiaryId),
  ]);

  final livingMembers = results[0] as List<FamilyMember>;
  final deceasedMembers = results[1] as List<FamilyDeceased>;

  final healthStats = await database.familyMembersDao.getStatistics(beneficiaryId);

  // حساب الإحصائيات
  final totalMembers = livingMembers.length + deceasedMembers.length;
  final deceasedFathers = deceasedMembers.where((d) => d.deceasedType == 1).length;
  final deceasedMothers = deceasedMembers.where((d) => d.deceasedType == 2).length;
  final maleCount = livingMembers.where((m) => m.gender == 1).length + deceasedFathers;
  final femaleCount = livingMembers.where((m) => m.gender == 2).length + deceasedMothers;

  // الأطفال (أقل من 18 سنة)
  final now = DateTime.now();
  final childrenCount = livingMembers.where((m) {
    final age = m.age ?? (now.difference(m.birthDate).inDays ~/ 365);
    return age < 18;
  }).length;

  return FamilyStatistics(
    totalMembers: totalMembers,
    livingMembers: livingMembers.length,
    deceasedMembers: deceasedMembers.length,
    maleCount: maleCount,
    femaleCount: femaleCount,
    childrenCount: childrenCount,
    healthySafe: healthStats.healthySafe,
    sick: healthStats.sick,
    chronicSick: healthStats.chronicSick,
    disabled: healthStats.disabled,
  );
});

/// Provider لعدد الأيتام فقط
final orphansCountProvider = FutureProvider.family<int, int>((
  ref,
  beneficiaryId,
) async {
  final database = ref.watch(databaseProvider);
  final members = await database.familyMembersDao.getMembersByBeneficiary(
    beneficiaryId,
  );
  return members.length;
});

/// Model للإحصائيات
class FamilyStatistics {
  final int totalMembers;
  final int livingMembers;
  final int deceasedMembers;
  final int maleCount;
  final int femaleCount;
  final int childrenCount;
  final int healthySafe;
  final int sick;
  final int chronicSick;
  final int disabled;

  // Aliases للتوافق مع الكود القديم
  int get malesCount => maleCount;
  int get femalesCount => femaleCount;

  const FamilyStatistics({
    required this.totalMembers,
    required this.livingMembers,
    required this.deceasedMembers,
    required this.maleCount,
    required this.femaleCount,
    required this.childrenCount,
    required this.healthySafe,
    required this.sick,
    required this.chronicSick,
    required this.disabled,
  });
}
