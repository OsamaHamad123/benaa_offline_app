import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/family_members_table.dart';

part 'family_members_dao.g.dart';

@DriftAccessor(tables: [FamilyMembersTable])
class FamilyMembersDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyMembersDaoMixin {
  FamilyMembersDao(AppDatabase db) : super(db);

  /// 📋 الحصول على جميع أفراد العائلة لمستفيد معين
  Future<List<FamilyMember>> getMembersByBeneficiary(int beneficiaryId) {
    return (select(familyMembersTable)
          ..where((t) => t.beneficiaryId.equals(beneficiaryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.relationship),
            (t) => OrderingTerm(expression: t.age, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// 👨‍👩‍👧‍👦 الحصول على أفراد العائلة حسب صلة القرابة
  Future<List<FamilyMember>> getMembersByRelationship(
    int beneficiaryId,
    String relationship,
  ) {
    return (select(familyMembersTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              t.relationship.equals(relationship),
        ))
        .get();
  }

  /// 🏠 الأفراد الذين يعيشون مع المستفيد
  Future<List<FamilyMember>> getMembersLivingTogether(int beneficiaryId) {
    return (select(familyMembersTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              t.livesWithBeneficiary.equals(true),
        ))
        .get();
  }

  /// ➕ إضافة فرد جديد
  Future<int> addMember(FamilyMembersTableCompanion member) {
    return into(familyMembersTable).insert(member);
  }

  /// ✏️ تحديث بيانات فرد
  Future<bool> updateMember(FamilyMember member) {
    return update(familyMembersTable).replace(member);
  }

  /// 🗑️ حذف فرد
  Future<int> deleteMember(int id) {
    return (delete(familyMembersTable)..where((t) => t.id.equals(id))).go();
  }

  /// 🔢 عدد أفراد العائلة
  Future<int> getMembersCount(int beneficiaryId) {
    return (selectOnly(familyMembersTable)
          ..where(familyMembersTable.beneficiaryId.equals(beneficiaryId))
          ..addColumns([familyMembersTable.id.count()]))
        .getSingle()
        .then((row) => row.read(familyMembersTable.id.count()) ?? 0);
  }

  /// 📊 إحصائيات مفصلة
  Future<FamilyStatistics> getStatistics(int beneficiaryId) async {
    final members = await getMembersByBeneficiary(beneficiaryId);

    int malesCount = 0;
    int femalesCount = 0;
    int childrenCount = 0; // أقل من 18
    int withDisability = 0;
    int withChronicDisease = 0;
    int livingTogether = 0;

    for (final member in members) {
      if (member.gender == 'male') malesCount++;
      if (member.gender == 'female') femalesCount++;
      if (member.age != null && member.age! < 18) childrenCount++;
      if (member.hasDisability) withDisability++;
      if (member.hasChronicDisease) withChronicDisease++;
      if (member.livesWithBeneficiary) livingTogether++;
    }

    return FamilyStatistics(
      totalMembers: members.length,
      malesCount: malesCount,
      femalesCount: femalesCount,
      childrenCount: childrenCount,
      withDisability: withDisability,
      withChronicDisease: withChronicDisease,
      livingTogether: livingTogether,
    );
  }

  /// 📊 إحصائيات حسب صلة القرابة
  Future<Map<String, int>> getMembersByRelationshipStats(
    int beneficiaryId,
  ) async {
    final query = selectOnly(familyMembersTable)
      ..where(familyMembersTable.beneficiaryId.equals(beneficiaryId))
      ..addColumns([
        familyMembersTable.relationship,
        familyMembersTable.id.count(),
      ])
      ..groupBy([familyMembersTable.relationship]);

    final results = await query.get();
    final Map<String, int> stats = {};

    for (final row in results) {
      final relationship = row.read(familyMembersTable.relationship);
      final count = row.read(familyMembersTable.id.count());
      if (relationship != null && count != null) {
        stats[relationship] = count;
      }
    }

    return stats;
  }

  /// 🏥 أفراد العائلة ذوو الاحتياجات الخاصة
  Future<List<FamilyMember>> getMembersWithDisability(int beneficiaryId) {
    return (select(familyMembersTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              t.hasDisability.equals(true),
        ))
        .get();
  }

  /// 💊 أفراد العائلة ذوو الأمراض المزمنة
  Future<List<FamilyMember>> getMembersWithChronicDisease(int beneficiaryId) {
    return (select(familyMembersTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              t.hasChronicDisease.equals(true),
        ))
        .get();
  }

  /// 🔍 البحث في أفراد العائلة
  Future<List<FamilyMember>> searchMembers(int beneficiaryId, String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(familyMembersTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              (t.fullName.lower().like(searchTerm) |
                  t.relationship.lower().like(searchTerm) |
                  t.nationalId.lower().like(searchTerm)),
        ))
        .get();
  }

  /// 🔄 الحصول على السجلات غير المزامنة
  Future<List<FamilyMember>> getUnsyncedMembers() {
    return (select(
      familyMembersTable,
    )..where((t) => t.syncState.equals('pending'))).get();
  }

  /// ✅ تحديث حالة المزامنة
  Future<void> markAsSynced(int id, int serverId) {
    return (update(familyMembersTable)..where((t) => t.id.equals(id))).write(
      FamilyMembersTableCompanion(
        syncState: const Value('synced'),
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// إحصائيات العائلة
class FamilyStatistics {
  final int totalMembers;
  final int malesCount;
  final int femalesCount;
  final int childrenCount;
  final int withDisability;
  final int withChronicDisease;
  final int livingTogether;

  FamilyStatistics({
    required this.totalMembers,
    required this.malesCount,
    required this.femalesCount,
    required this.childrenCount,
    required this.withDisability,
    required this.withChronicDisease,
    required this.livingTogether,
  });
}
