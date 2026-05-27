import '../../../../data/db/drift_database.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/file_number_entities.dart';
import '../../services/file_number_formatter.dart';

class LocalFileNumberPoolRepository {
  LocalFileNumberPoolRepository(this._db);

  final AppDatabase _db;

  Future<int> getAvailableCount() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS cnt FROM local_file_numbers WHERE status = 'available'",
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<LocalFileNumber?> getNextAvailableNumber() async {
    final rows = await _db
        .customSelect(
          "SELECT * FROM local_file_numbers WHERE status = 'available' ORDER BY number ASC LIMIT 1",
        )
        .get();
    if (rows.isEmpty) return null;
    return _map(rows.first.data);
  }

  Future<void> markTentative(String fileNumber, String formSessionId) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'tentative', form_session_id = ?, tentative_at = ?, updated_at = ? WHERE file_number = ? AND status = 'available'",
      [
        formSessionId,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );
  }

  Future<void> releaseTentative(String formSessionId) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'available', form_session_id = NULL, tentative_at = NULL, updated_at = ? WHERE form_session_id = ? AND status = 'tentative'",
      [
        DateTime.now().toIso8601String(),
        formSessionId,
      ],
    );
  }

  Future<void> assignToBeneficiary(String fileNumber, String beneficiaryLocalId) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'assigned_local', beneficiary_local_id = ?, assigned_at = ?, form_session_id = NULL, tentative_at = NULL, updated_at = ? WHERE file_number = ? AND status IN ('available','tentative')",
      [
        beneficiaryLocalId,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );

    await _db.customStatement(
      "UPDATE local_file_number_blocks SET used_count = used_count + 1, status = CASE WHEN used_count + 1 >= total_count THEN 'consumed' ELSE 'partially_used' END, updated_at = ? WHERE block_id = (SELECT block_id FROM local_file_numbers WHERE file_number = ? LIMIT 1)",
      [
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );
  }

  Future<void> markSynced(String fileNumber) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'synced', synced_at = ?, updated_at = ? WHERE file_number = ?",
      [
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );
  }

  Future<void> markConflict(String fileNumber) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'conflict', updated_at = ? WHERE file_number = ?",
      [
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );
  }

  Future<void> releaseAssigned(String fileNumber) async {
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'available', beneficiary_local_id = NULL, assigned_at = NULL, updated_at = ? WHERE file_number = ? AND status = 'assigned_local'",
      [
        DateTime.now().toIso8601String(),
        fileNumber,
      ],
    );
  }

  Future<int> getAssignedLocalCount() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS cnt FROM local_file_numbers WHERE status = 'assigned_local'",
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<int> getSyncedCount() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS cnt FROM local_file_numbers WHERE status = 'synced'",
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<int> getConflictCount() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS cnt FROM local_file_numbers WHERE status = 'conflict'",
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<({String start, String end})?> getCurrentReservedRange() async {
    final rows = await _db
        .customSelect(
          "SELECT prefix, year, start_number, end_number FROM local_file_number_blocks WHERE status IN ('reserved','partially_used','consumed') ORDER BY reserved_at DESC LIMIT 1",
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    final data = rows.first.data;
    final prefix = data['prefix']?.toString() ?? 'GZ';
    final year = (data['year'] as int?) ?? DateTime.now().year;
    final startNumber = (data['start_number'] as int?) ?? 1;
    final endNumber = (data['end_number'] as int?) ?? 1;

    return (
      start: FileNumberFormatter.format(prefix: prefix, year: year, number: startNumber),
      end: FileNumberFormatter.format(prefix: prefix, year: year, number: endNumber),
    );
  }

  Future<void> importReservedBlock(FileNumberBlock block) async {
    await _db.transaction(() async {
      await _db.customStatement(
        "INSERT OR REPLACE INTO local_file_number_blocks (block_id, device_id, user_id, prefix, year, start_number, end_number, total_count, status, reserved_at, expires_at, used_count, released_count, app_version, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          block.blockId,
          block.deviceId,
          block.userId,
          block.prefix,
          block.year,
          block.start,
          block.end,
          block.size,
          block.status,
          (block.reservedAt ?? DateTime.now().toUtc()).toIso8601String(),
          block.expiresAt?.toIso8601String(),
          block.usedCount,
          block.releasedCount,
          block.appVersion,
          DateTime.now().toIso8601String(),
        ],
      );

      for (var number = block.start; number <= block.end; number++) {
        final fileNumber = FileNumberFormatter.format(
          prefix: block.prefix,
          year: block.year,
          number: number,
        );

        await _db.customStatement(
          "INSERT OR IGNORE INTO local_file_numbers (file_number, number, year, prefix, block_id, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 'available', ?, ?)",
          [
            fileNumber,
            number,
            block.year,
            block.prefix,
            block.blockId,
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
          ],
        );
      }
    });
  }

  Future<List<FileNumberAllocation>> getPendingAssignedNumbers({
    required String deviceId,
    required String userId,
  }) async {
    final rows = await _db
        .customSelect(
          "SELECT * FROM local_file_numbers WHERE status = 'assigned_local' ORDER BY assigned_at ASC",
        )
        .get();

    return rows.map((row) {
      final data = row.data;
      final fileNumber = data['file_number']?.toString() ?? '';
      return FileNumberAllocation(
        fileNumber: fileNumber,
        number: (data['number'] as int?) ?? (FileNumberFormatter.extractSequence(fileNumber) ?? 0),
        year: (data['year'] as int?) ?? DateTime.now().year,
        prefix: data['prefix']?.toString() ?? 'GZ',
        status: 'assigned',
        beneficiaryLocalId: data['beneficiary_local_id']?.toString() ?? '',
        beneficiaryRemoteId: null,
        deviceId: deviceId,
        userId: userId,
        blockId: data['block_id']?.toString() ?? '',
        assignedAtLocal: DateTime.tryParse(data['assigned_at']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList(growable: false);
  }

  Future<void> cleanupExpiredTentatives({Duration maxAge = const Duration(hours: 2)}) async {
    final cutoff = DateTime.now().subtract(maxAge).toIso8601String();
    await _db.customStatement(
      "UPDATE local_file_numbers SET status = 'available', form_session_id = NULL, tentative_at = NULL, updated_at = ? WHERE status = 'tentative' AND tentative_at IS NOT NULL AND tentative_at < ?",
      [
        DateTime.now().toIso8601String(),
        cutoff,
      ],
    );
  }

  Future<void> mergeRemoteAllocationStatuses(List<FileNumberAllocation> remoteAllocations) async {
    if (remoteAllocations.isEmpty) return;

    for (final allocation in remoteAllocations) {
      final local = await getByFileNumber(allocation.fileNumber);
      if (local == null) {
        continue;
      }

      if (local.status == 'conflict') {
        continue;
      }

      if (local.status == 'assigned_local' && allocation.status == 'synced') {
        await markSynced(allocation.fileNumber);
        continue;
      }

      if (allocation.status == 'conflict') {
        await markConflict(allocation.fileNumber);
      }
    }
  }

  Future<void> releaseUnusedBlockNumbers(String blockId) async {
    await _db.transaction(() async {
      await _db.customStatement(
        "UPDATE local_file_numbers SET status = 'released', updated_at = ? WHERE block_id = ? AND status IN ('available','tentative')",
        [
          DateTime.now().toIso8601String(),
          blockId,
        ],
      );

      final releasedRow = await _db.customSelect(
        "SELECT COUNT(*) AS cnt FROM local_file_numbers WHERE block_id = ? AND status = 'released'",
        variables: [Variable.withString(blockId)],
      ).getSingle();

      await _db.customStatement(
        "UPDATE local_file_number_blocks SET status = 'released', released_count = ?, updated_at = ? WHERE block_id = ?",
        [
          releasedRow.read<int>('cnt'),
          DateTime.now().toIso8601String(),
          blockId,
        ],
      );
    });
  }

  Future<List<FileNumberBlock>> getDeviceBlocks({
    required String deviceId,
    required String userId,
  }) async {
    final rows = await _db.customSelect(
      "SELECT * FROM local_file_number_blocks WHERE device_id = ? AND user_id = ? ORDER BY reserved_at DESC",
      variables: [Variable.withString(deviceId), Variable.withString(userId)],
    ).get();

    return rows.map((row) {
      final data = row.data;
      return FileNumberBlock(
        blockId: data['block_id']?.toString() ?? '',
        deviceId: data['device_id']?.toString() ?? '',
        userId: data['user_id']?.toString() ?? '',
        prefix: data['prefix']?.toString() ?? 'GZ',
        year: (data['year'] as int?) ?? DateTime.now().year,
        start: (data['start_number'] as int?) ?? 0,
        end: (data['end_number'] as int?) ?? 0,
        status: data['status']?.toString() ?? 'reserved',
        reservedAt: DateTime.tryParse(data['reserved_at']?.toString() ?? ''),
        expiresAt: DateTime.tryParse(data['expires_at']?.toString() ?? ''),
        usedCount: (data['used_count'] as int?) ?? 0,
        releasedCount: (data['released_count'] as int?) ?? 0,
        appVersion: data['app_version']?.toString() ?? 'unknown',
      );
    }).toList(growable: false);
  }

  Future<LocalFileNumber?> getByFileNumber(String fileNumber) async {
    final rows = await _db.customSelect(
      "SELECT * FROM local_file_numbers WHERE file_number = ? LIMIT 1",
      variables: [Variable.withString(fileNumber)],
    ).get();

    if (rows.isEmpty) return null;
    return _map(rows.first.data);
  }

  LocalFileNumber _map(Map<String, dynamic> data) {
    return LocalFileNumber(
      fileNumber: data['file_number']?.toString() ?? '',
      number: (data['number'] as int?) ?? 0,
      year: (data['year'] as int?) ?? DateTime.now().year,
      prefix: data['prefix']?.toString() ?? 'GZ',
      blockId: data['block_id']?.toString() ?? '',
      status: data['status']?.toString() ?? 'available',
      beneficiaryLocalId: data['beneficiary_local_id']?.toString(),
      formSessionId: data['form_session_id']?.toString(),
      tentativeAt: DateTime.tryParse(data['tentative_at']?.toString() ?? ''),
      assignedAt: DateTime.tryParse(data['assigned_at']?.toString() ?? ''),
      syncedAt: DateTime.tryParse(data['synced_at']?.toString() ?? ''),
    );
  }
}
