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

    for (final id in ids) {
      await customStatement(
        '''
        INSERT OR IGNORE INTO local_codes (code, is_used, synced, record_type)
        VALUES (?, 0, 0, 'data')
        ''',
        [_formatCode(id)],
      );
    }
  }

  /// 🆔 Get next available File ID
  Future<int?> getNextAvailableId() async {
    final localRows = await customSelect(
      '''
      SELECT code
      FROM local_codes
      WHERE is_used = 0
      ORDER BY code ASC
      LIMIT 1
      ''',
    ).get();

    if (localRows.isNotEmpty) {
      final code = localRows.first.read<String>('code');
      final parsed = _parseCodeToInt(code);
      if (parsed != null) return parsed;
    }

    final query = select(fileIdReservationTable)
      ..where((t) => t.status.equals('available'))
      ..orderBy([(t) => OrderingTerm.asc(t.fileId)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.fileId;
  }

  /// ✅ Mark an ID as used
  Future<void> markAsUsed(
    int fileId,
    int beneficiaryId, {
    String recordType = 'data',
    int? recordId,
  }) async {
    final now = DateTime.now().toIso8601String();

    await customStatement(
      '''
      INSERT OR IGNORE INTO local_codes (code, is_used, synced, record_type, record_id)
      VALUES (?, 0, 0, ?, ?)
      ''',
      [_formatCode(fileId), recordType, recordId ?? beneficiaryId],
    );

    await customStatement(
      '''
      UPDATE local_codes
      SET is_used = 1,
          synced = 0,
          used_at = ?,
          record_type = ?,
          record_id = ?
      WHERE code = ?
      ''',
      [
        now,
        recordType,
        recordId ?? beneficiaryId,
        _formatCode(fileId),
      ],
    );

    await customStatement(
      '''
      UPDATE file_id_reservations
      SET status = ?,
          beneficiary_id = ?,
          used_at = ?,
          record_type = ?,
          record_id = ?
      WHERE file_id = ?
      ''',
      [
        'used',
        beneficiaryId,
        now,
        recordType,
        recordId ?? beneficiaryId,
        fileId,
      ],
    );
  }

  /// 🔄 Get all used but not synced IDs
  Future<List<FileIdReservation>> getUsedUnsyncedIds() async {
    final rows = await customSelect(
      '''
      SELECT code, used_at, created_at, record_id
      FROM local_codes
      WHERE is_used = 1 AND synced = 0
      ORDER BY code ASC
      ''',
    ).get();

    return rows.map((row) {
      final code = row.read<String>('code');
      final fileId = _parseCodeToInt(code) ?? 0;
      final usedAtRaw = row.read<String?>('used_at');
      final createdAtRaw = row.read<String?>('created_at');

      return FileIdReservation(
        id: fileId,
        fileId: fileId,
        status: 'used',
        beneficiaryId: row.read<int?>('record_id'),
        reservedAt: DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now(),
        usedAt: DateTime.tryParse(usedAtRaw ?? ''),
        syncedAt: null,
      );
    }).toList(growable: false);
  }

  /// ✅ Mark IDs as synced
  Future<void> markAsSynced(List<int> fileIds) async {
    if (fileIds.isEmpty) return;

    final localCodes = fileIds.map(_formatCode).toList(growable: false);

    await customStatement(
      'UPDATE local_codes SET synced = 1 WHERE code IN (${localCodes.map((_) => '?').join(',')})',
      localCodes,
    );

    await (update(fileIdReservationTable)..where((t) => t.fileId.isIn(fileIds))).write(FileIdReservationTableCompanion(
      status: const Value('synced'),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> markAsConflict(List<int> fileIds) async {
    if (fileIds.isEmpty) return;

    final localCodes = fileIds.map(_formatCode).toList(growable: false);
    await customStatement(
      'UPDATE local_codes SET is_used = 1, synced = 0 WHERE code IN (${localCodes.map((_) => '?').join(',')})',
      localCodes,
    );

    await (update(fileIdReservationTable)..where((t) => t.fileId.isIn(fileIds))).write(
      FileIdReservationTableCompanion(
        status: const Value('conflict'),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteCodes(List<int> fileIds) async {
    if (fileIds.isEmpty) return;
    final localCodes = fileIds.map(_formatCode).toList(growable: false);
    await customStatement(
      'DELETE FROM local_codes WHERE code IN (${localCodes.map((_) => '?').join(',')})',
      localCodes,
    );
    await (delete(fileIdReservationTable)..where((t) => t.fileId.isIn(fileIds))).go();
  }

  Future<List<Map<String, dynamic>>> getAllCodesForLoginSyncPayload() async {
    var rows = await customSelect(
      '''
      SELECT
        CAST(code AS INTEGER) as file_id,
        CASE WHEN is_used = 1 AND synced = 1 THEN 'synced'
             WHEN is_used = 1 AND synced = 0 THEN 'used'
             ELSE 'available'
        END as status,
        used_at,
        NULL as synced_at,
        record_id,
        record_id as beneficiary_id,
        record_type
      FROM local_codes
      ''',
    ).get();

    if (rows.isEmpty) {
      rows = await customSelect(
        '''
      SELECT
        file_id,
        status,
        used_at,
        synced_at,
        record_id,
        beneficiary_id,
        record_type
      FROM file_id_reservations
      ''',
      ).get();
    }

    return rows.map((row) {
      final fileId = row.read<int>('file_id');
      final status = row.read<String>('status');
      final usedAt = row.read<String?>('used_at');
      final syncedAt = row.read<String?>('synced_at');
      final recordId = row.read<int?>('record_id') ?? row.read<int?>('beneficiary_id');

      return {
        'code': fileId.toString().padLeft(6, '0'),
        'used': status == 'used' || status == 'synced' || status == 'conflict',
        'used_at': usedAt ?? syncedAt,
        'record_id': recordId?.toString(),
      };
    }).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsedCodesPayload() async {
    var rows = await customSelect(
      '''
      SELECT
        CAST(code AS INTEGER) as file_id,
        used_at,
        record_type,
        record_id,
        record_id as beneficiary_id
      FROM local_codes
      WHERE is_used = 1 AND synced = 0
      ORDER BY file_id ASC
      ''',
    ).get();

    if (rows.isEmpty) {
      rows = await customSelect(
        '''
      SELECT
        file_id,
        used_at,
        record_type,
        record_id,
        beneficiary_id
      FROM file_id_reservations
      WHERE status = 'used'
      ORDER BY file_id ASC
      ''',
      ).get();
    }

    return rows.map((row) {
      final fileId = row.read<int>('file_id');
      final recordType = row.read<String?>('record_type') ?? 'data';
      final recordId = row.read<int?>('record_id') ?? row.read<int?>('beneficiary_id');

      return {
        'code': fileId.toString().padLeft(6, '0'),
        'used_at': row.read<String?>('used_at'),
        'record_type': recordType,
        'record_id': recordId,
      };
    }).toList(growable: false);
  }

  /// 📊 Count available IDs
  Future<int> countAvailable() async {
    final rows = await customSelect(
      'SELECT COUNT(*) AS count FROM local_codes WHERE is_used = 0',
    ).getSingle();

    final count = rows.read<int>('count');
    if (count > 0) return count;

    final legacyCountExp = fileIdReservationTable.id.count();
    final legacyQuery = selectOnly(fileIdReservationTable)
      ..addColumns([legacyCountExp])
      ..where(fileIdReservationTable.status.equals('available'));

    final legacyResult = await legacyQuery.getSingle();
    return legacyResult.read(legacyCountExp) ?? 0;
  }

  Future<int> countUsedUnsynced() async {
    final rows = await customSelect(
      'SELECT COUNT(*) AS count FROM local_codes WHERE is_used = 1 AND synced = 0',
    ).getSingle();

    final count = rows.read<int>('count');
    if (count > 0) return count;

    final legacyCountExp = fileIdReservationTable.id.count();
    final legacyQuery = selectOnly(fileIdReservationTable)
      ..addColumns([legacyCountExp])
      ..where(fileIdReservationTable.status.equals('used'));

    final legacyResult = await legacyQuery.getSingle();
    return legacyResult.read(legacyCountExp) ?? 0;
  }

  Future<DateTime?> getLastReservedAt() async {
    final row = await customSelect(
      'SELECT created_at FROM local_codes ORDER BY created_at DESC LIMIT 1',
    ).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.read<String>('created_at'));
  }

  Future<DateTime?> getLastSyncedAt() async {
    final row = await customSelect(
      'SELECT used_at FROM local_codes WHERE synced = 1 ORDER BY used_at DESC LIMIT 1',
    ).getSingleOrNull();
    if (row == null) return null;
    return DateTime.tryParse(row.read<String>('used_at'));
  }

  String _formatCode(int id) => id.toString().padLeft(6, '0');

  int? _parseCodeToInt(String code) => int.tryParse(code);

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

  Future<int?> getActiveReservationUsedCount() async {
    final rows = await customSelect(
      '''
      SELECT used_count
      FROM file_id_reservation_batches
      WHERE status = 'active'
      ORDER BY updated_at DESC, reservation_id DESC
      LIMIT 1
      ''',
    ).get();

    if (rows.isEmpty) return null;
    return rows.first.read<int?>('used_count');
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
