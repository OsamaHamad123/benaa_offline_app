import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/family_deceased_table.dart';

part 'family_deceased_dao.g.dart';

@DriftAccessor(tables: [FamilyDeceasedTable])
class FamilyDeceasedDao extends DatabaseAccessor<AppDatabase>
    with _$FamilyDeceasedDaoMixin {
  FamilyDeceasedDao(super.db);

  /// 📋 الحصول على جميع الأموات (الأب/الأم) لمستفيد معين
  Future<List<FamilyDeceased>> getDeceasedByBeneficiary(int beneficiaryId) {
    return (select(familyDeceasedTable)
          ..where((t) => t.beneficiaryId.equals(beneficiaryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.deceasedType), // father first
          ]))
        .get();
  }

  /// 👨 الحصول على الأب المتوفى
  Future<FamilyDeceased?> getFather(int beneficiaryId) {
    return (select(familyDeceasedTable)
          ..where(
            (t) =>
                t.beneficiaryId.equals(beneficiaryId) &
                t.deceasedType.equals(1), // 1=father
          ))
        .getSingleOrNull();
  }

  /// 👩 الحصول على الأم المتوفية
  Future<FamilyDeceased?> getMother(int beneficiaryId) {
    return (select(familyDeceasedTable)
          ..where(
            (t) =>
                t.beneficiaryId.equals(beneficiaryId) &
                t.deceasedType.equals(2), // 2=mother
          ))
        .getSingleOrNull();
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

  /// 📊 إحصائيات حسب سبب الوفاة
  Future<Map<int, int>> getDeceasedByDeathCause(int beneficiaryId) async {
    final query = selectOnly(familyDeceasedTable)
      ..where(familyDeceasedTable.beneficiaryId.equals(beneficiaryId))
      ..addColumns([
        familyDeceasedTable.deathCause,
        familyDeceasedTable.id.count(),
      ])
      ..groupBy([familyDeceasedTable.deathCause]);

    final results = await query.get();
    final Map<int, int> stats = {};

    for (final row in results) {
      final cause = row.read(familyDeceasedTable.deathCause);
      final count = row.read(familyDeceasedTable.id.count());
      if (cause != null && count != null) {
        stats[cause] = count;
      }
    }

    return stats;
  }

  /// 🔍 البحث في الأموات
  Future<List<FamilyDeceased>> searchDeceased(int beneficiaryId, String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    final nationalIdInt = int.tryParse(query);
    return (select(familyDeceasedTable)
          ..where(
            (t) =>
                t.beneficiaryId.equals(beneficiaryId) &
                (t.firstName.lower().like(searchTerm) |
                    t.familyName.lower().like(searchTerm) |
                    (nationalIdInt != null
                        ? t.nationalId.equals(nationalIdInt)
                        : const Constant(false))),
          ))
        .get();
  }

  /// 🔄 الحصول على السجلات غير المزامنة
  Future<List<FamilyDeceased>> getUnsyncedDeceased() {
    return (select(
      familyDeceasedTable,
    )..where((t) => t.syncState.equals('pending')))
        .get();
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
