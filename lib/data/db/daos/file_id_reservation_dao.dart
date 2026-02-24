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

  Future<int> countUsedUnsynced() async {
    final countExp = fileIdReservationTable.id.count();
    final query = selectOnly(fileIdReservationTable)
      ..addColumns([countExp])
      ..where(fileIdReservationTable.status.equals('used'));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<DateTime?> getLastReservedAt() async {
    final row = await (select(fileIdReservationTable)
          ..orderBy([(t) => OrderingTerm.desc(t.reservedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.reservedAt;
  }

  Future<DateTime?> getLastSyncedAt() async {
    final row = await (select(fileIdReservationTable)
          ..where((t) => t.syncedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.syncedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.syncedAt;
  }

  Future<void> upsertActiveReservationBatch({
    required int reservationId,
    required String deviceId,
    required int startId,
    required int endId,
    required int batchSize,
    required int usedCount,
    required int remainingCount,
    required int nextAvailableId,
    required String status,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) async {
    final now = DateTime.now().toIso8601String();
    final createdIso = (createdAt ?? DateTime.now()).toIso8601String();
    final expiresIso = expiresAt?.toIso8601String();

    await customStatement(
      '''
      INSERT INTO file_id_reservation_batches (
        reservation_id,
        device_id,
        start_id,
        end_id,
        batch_size,
        used_count,
        remaining_count,
        next_available_id,
        status,
        expires_at,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(reservation_id) DO UPDATE SET
        device_id = excluded.device_id,
        start_id = excluded.start_id,
        end_id = excluded.end_id,
        batch_size = excluded.batch_size,
        used_count = excluded.used_count,
        remaining_count = excluded.remaining_count,
        next_available_id = excluded.next_available_id,
        status = excluded.status,
        expires_at = excluded.expires_at,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at
      ''',
      [
        reservationId,
        deviceId,
        startId,
        endId,
        batchSize,
        usedCount,
        remainingCount,
        nextAvailableId,
        status,
        expiresIso,
        createdIso,
        now,
      ],
    );
  }

  Future<Map<String, dynamic>?> getActiveReservationBatch() async {
    final rows = await customSelect(
      '''
      SELECT *
      FROM file_id_reservation_batches
      WHERE status = 'active' AND remaining_count > 0
      ORDER BY updated_at DESC, reservation_id DESC
      LIMIT 1
      ''',
    ).get();

    if (rows.isEmpty) return null;
    return rows.first.data;
  }

  Future<int?> allocateNextAvailableFromBatch() async {
    return await transaction(() async {
      final currentRows = await customSelect(
        '''
        SELECT reservation_id, next_available_id, end_id, used_count, remaining_count
        FROM file_id_reservation_batches
        WHERE status = 'active' AND remaining_count > 0
        ORDER BY updated_at DESC, reservation_id DESC
        LIMIT 1
        ''',
      ).get();

      if (currentRows.isEmpty) return null;

      final row = currentRows.first.data;
      final reservationId = (row['reservation_id'] as int?) ?? 0;
      final nextAvailableId = (row['next_available_id'] as int?) ?? 0;
      final endId = (row['end_id'] as int?) ?? 0;
      final usedCount = (row['used_count'] as int?) ?? 0;
      final remainingCount = (row['remaining_count'] as int?) ?? 0;

      if (nextAvailableId <= 0 || nextAvailableId > endId || remainingCount <= 0) {
        return null;
      }

      final now = DateTime.now().toIso8601String();
      final updatedRemaining = (remainingCount - 1).clamp(0, 1 << 30);
      final updatedUsed = usedCount + 1;
      final updatedNext = nextAvailableId + 1;

      await customStatement(
        '''
        UPDATE file_id_reservation_batches
        SET next_available_id = ?,
            used_count = ?,
            remaining_count = ?,
            updated_at = ?
        WHERE reservation_id = ?
        ''',
        [
          updatedNext,
          updatedUsed,
          updatedRemaining,
          now,
          reservationId,
        ],
      );

      return nextAvailableId;
    });
  }

  Future<int> getUnsyncedUsedCountFromBatch() async {
    final rows = await customSelect(
      '''
      SELECT SUM(CASE
        WHEN used_count > last_synced_used_count THEN used_count - last_synced_used_count
        ELSE 0
      END) AS pending_used
      FROM file_id_reservation_batches
      WHERE status = 'active'
      ''',
    ).get();

    if (rows.isEmpty) return 0;
    final pending = rows.first.read<int?>('pending_used') ?? 0;
    return pending < 0 ? 0 : pending;
  }

  Future<int?> getActiveReservationBatchId() async {
    final rows = await customSelect(
      '''
      SELECT reservation_id
      FROM file_id_reservation_batches
      WHERE status = 'active'
      ORDER BY updated_at DESC, reservation_id DESC
      LIMIT 1
      ''',
    ).get();

    if (rows.isEmpty) return null;
    return rows.first.read<int>('reservation_id');
  }

  Future<void> markBatchUsedCountSynced(int reservationId) async {
    final now = DateTime.now().toIso8601String();
    await customStatement(
      '''
      UPDATE file_id_reservation_batches
      SET last_synced_used_count = used_count,
          synced_at = ?,
          updated_at = ?
      WHERE reservation_id = ?
      ''',
      [
        now,
        now,
        reservationId,
      ],
    );
  }
}
