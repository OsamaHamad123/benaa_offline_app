import 'package:drift/drift.dart';
import 'dart:convert' show jsonEncode;
import '../drift_database.dart';
import '../tables/family_members_table.dart';

part 'family_members_dao.g.dart';

@DriftAccessor(tables: [FamilyMembersTable])
class FamilyMembersDao extends DatabaseAccessor<AppDatabase> with _$FamilyMembersDaoMixin {
  FamilyMembersDao(super.db);

  /// 📋 الحصول على جميع أفراد العائلة (الأيتام) لمستفيد معين
  Future<List<FamilyMember>> getMembersByBeneficiary(int beneficiaryId) {
    return (select(familyMembersTable)
          ..where((t) => t.beneficiaryId.equals(beneficiaryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.age, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// 🔢 عدد أفراد العائلة
  Future<int> getMembersCount(int beneficiaryId) {
    return (selectOnly(familyMembersTable)
          ..where(familyMembersTable.beneficiaryId.equals(beneficiaryId))
          ..addColumns([familyMembersTable.id.count()]))
        .getSingle()
        .then((row) => row.read(familyMembersTable.id.count()) ?? 0);
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
  Future<int> deleteMember(int id, {bool trackSyncDelete = true}) async {
    if (trackSyncDelete) {
      final existing = await (select(familyMembersTable)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null) {
        final entityId = existing.serverId?.toString() ?? existing.id.toString();
        await db.syncDao.addTombstone(
          entityType: 're-people',
          entityId: entityId,
          payload: jsonEncode({
            'local_id': existing.id,
            'server_id': existing.serverId,
            'beneficiary_id': existing.beneficiaryId,
          }),
        );
      }
    }

    return (delete(familyMembersTable)..where((t) => t.id.equals(id))).go();
  }

  /// 📊 إحصائيات مفصلة
  Future<FamilyStatistics> getStatistics(int beneficiaryId) async {
    final members = await getMembersByBeneficiary(beneficiaryId);

    int malesCount = 0;
    int femalesCount = 0;
    int childrenCount = 0; // أقل من 18
    int healthySafe = 0; // سليم
    int sick = 0; // مريض
    int chronicSick = 0; // مريض مزمن
    int disabled = 0; // معاق

    for (final member in members) {
      if (member.gender == 1) malesCount++; // 1=male
      if (member.gender == 2) femalesCount++; // 2=female
      if (member.age != null && member.age! < 18) childrenCount++;

      // إحصائيات الحالة الصحية
      switch (member.healthStatus) {
        case 1: // سليم
          healthySafe++;
          break;
        case 2: // مريض
          sick++;
          break;
        case 3: // مريض مزمن
          chronicSick++;
          break;
        case 4: // معاق
          disabled++;
          break;
      }
    }

    return FamilyStatistics(
      totalMembers: members.length,
      malesCount: malesCount,
      femalesCount: femalesCount,
      childrenCount: childrenCount,
      healthySafe: healthySafe,
      sick: sick,
      chronicSick: chronicSick,
      disabled: disabled,
    );
  }

  /// 🏥 أفراد العائلة حسب الحالة الصحية
  Future<List<FamilyMember>> getMembersByHealthStatus(
    int beneficiaryId,
    int healthStatus, // 1=سليم, 2=مريض, 3=مزمن, 4=معاق, 5=غير معروف
  ) {
    return (select(familyMembersTable)
          ..where(
            (t) => t.beneficiaryId.equals(beneficiaryId) & t.healthStatus.equals(healthStatus),
          ))
        .get();
  }

  /// 🔍 البحث في أفراد العائلة
  Future<List<FamilyMember>> searchMembers(int beneficiaryId, String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    final nationalIdInt = int.tryParse(query);
    return (select(familyMembersTable)
          ..where(
            (t) =>
                t.beneficiaryId.equals(beneficiaryId) &
                (t.firstName.lower().like(searchTerm) |
                    t.familyName.lower().like(searchTerm) |
                    (nationalIdInt != null ? t.orphanNationalId.equals(nationalIdInt) : const Constant(false))),
          ))
        .get();
  }

  /// 🔄 الحصول على السجلات غير المزامنة
  Future<List<FamilyMember>> getUnsyncedMembers() {
    return (select(
      familyMembersTable,
    )..where((t) => t.syncState.equals('pending')))
        .get();
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
  final int healthySafe; // سليم
  final int sick; // مريض
  final int chronicSick; // مريض مزمن
  final int disabled; // معاق

  FamilyStatistics({
    required this.totalMembers,
    required this.malesCount,
    required this.femalesCount,
    required this.childrenCount,
    required this.healthySafe,
    required this.sick,
    required this.chronicSick,
    required this.disabled,
  });
}
