import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/family_deceased_table.dart';

part 'family_deceased_dao.g.dart';

@DriftAccessor(tables: [FamilyDeceasedTable])
class FamilyDeceasedDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyDeceasedDaoMixin {
  FamilyDeceasedDao(AppDatabase db) : super(db);

  /// 📋 الحصول على جميع الأموات لمستفيد معين
  Future<List<FamilyDeceased>> getDeceasedByBeneficiary(int beneficiaryId) {
    return (select(familyDeceasedTable)
          ..where((t) => t.beneficiaryId.equals(beneficiaryId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.deathDate, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// ➕ إضافة متوفى جديد
  Future<int> addDeceased(FamilyDeceasedTableCompanion deceased) {
    return into(familyDeceasedTable).insert(deceased);
  }

  /// ✏️ تحديث بيانات متوفى
  Future<bool> updateDeceased(FamilyDeceased deceased) {
    return update(familyDeceasedTable).replace(deceased);
  }

  /// 🗑️ حذف متوفى
  Future<int> deleteDeceased(int id) {
    return (delete(familyDeceasedTable)..where((t) => t.id.equals(id))).go();
  }

  /// 🔢 عدد الأموات لمستفيد
  Future<int> getDeceasedCount(int beneficiaryId) {
    return (selectOnly(familyDeceasedTable)
          ..where(familyDeceasedTable.beneficiaryId.equals(beneficiaryId))
          ..addColumns([familyDeceasedTable.id.count()]))
        .getSingle()
        .then((row) => row.read(familyDeceasedTable.id.count()) ?? 0);
  }

  /// 📊 إحصائيات حسب صلة القرابة
  Future<Map<String, int>> getDeceasedByRelationship(int beneficiaryId) async {
    final query = selectOnly(familyDeceasedTable)
      ..where(familyDeceasedTable.beneficiaryId.equals(beneficiaryId))
      ..addColumns([
        familyDeceasedTable.relationship,
        familyDeceasedTable.id.count(),
      ])
      ..groupBy([familyDeceasedTable.relationship]);

    final results = await query.get();
    final Map<String, int> stats = {};

    for (final row in results) {
      final relationship = row.read(familyDeceasedTable.relationship);
      final count = row.read(familyDeceasedTable.id.count());
      if (relationship != null && count != null) {
        stats[relationship] = count;
      }
    }

    return stats;
  }

  /// 🔍 البحث في الأموات
  Future<List<FamilyDeceased>> searchDeceased(int beneficiaryId, String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(familyDeceasedTable)..where(
          (t) =>
              t.beneficiaryId.equals(beneficiaryId) &
              (t.fullName.lower().like(searchTerm) |
                  t.relationship.lower().like(searchTerm)),
        ))
        .get();
  }

  /// 🔄 الحصول على السجلات غير المزامنة
  Future<List<FamilyDeceased>> getUnsyncedDeceased() {
    return (select(
      familyDeceasedTable,
    )..where((t) => t.syncState.equals('pending'))).get();
  }

  /// ✅ تحديث حالة المزامنة
  Future<void> markAsSynced(int id, int serverId) {
    return (update(familyDeceasedTable)..where((t) => t.id.equals(id))).write(
      FamilyDeceasedTableCompanion(
        syncState: const Value('synced'),
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }
}
