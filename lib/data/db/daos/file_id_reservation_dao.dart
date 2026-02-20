import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/file_id_reservation_table.dart';

part 'file_id_reservation_dao.g.dart';

@DriftAccessor(tables: [FileIdReservationTable])
class FileIdReservationDao extends DatabaseAccessor<AppDatabase> with _$FileIdReservationDaoMixin {
  FileIdReservationDao(super.db);

  /// 📥 Insert multiple reserved IDs
  Future<void> insertReservedIds(List<int> ids) async {
    await batch((batch) {
      for (final id in ids) {
        batch.insert(
          fileIdReservationTable,
          FileIdReservationTableCompanion.insert(
            fileId: id,
            status: const Value('available'),
            reservedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// 🆔 Get next available File ID
  Future<int?> getNextAvailableId() async {
    final query = select(fileIdReservationTable)
      ..where((t) => t.status.equals('available'))
      ..orderBy([(t) => OrderingTerm.asc(t.fileId)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.fileId;
  }

  /// ✅ Mark an ID as used
  Future<void> markAsUsed(int fileId, int beneficiaryId) async {
    await (update(fileIdReservationTable)..where((t) => t.fileId.equals(fileId))).write(FileIdReservationTableCompanion(
      status: const Value('used'),
      beneficiaryId: Value(beneficiaryId),
      usedAt: Value(DateTime.now()),
    ));
  }

  /// 🔄 Get all used but not synced IDs
  Future<List<FileIdReservation>> getUsedUnsyncedIds() async {
    return (select(fileIdReservationTable)..where((t) => t.status.equals('used'))).get();
  }

  /// ✅ Mark IDs as synced
  Future<void> markAsSynced(List<int> fileIds) async {
    await (update(fileIdReservationTable)..where((t) => t.fileId.isIn(fileIds))).write(FileIdReservationTableCompanion(
      status: const Value('synced'),
      syncedAt: Value(DateTime.now()),
    ));
  }

  /// 📊 Count available IDs
  Future<int> countAvailable() async {
    final countExp = fileIdReservationTable.id.count();
    final query = selectOnly(fileIdReservationTable)
      ..addColumns([countExp])
      ..where(fileIdReservationTable.status.equals('available'));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }
}
