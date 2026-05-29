import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/db/drift_database.dart';
import 'local_sync_status.dart';

class LocalCacheRecord {
  final String localId;
  final String? remoteId;
  final LocalSyncStatus syncStatus;
  final DateTime createdAtLocal;
  final DateTime updatedAtLocal;
  final String? lastSyncError;
  final Map<String, dynamic> payload;

  const LocalCacheRecord({
    required this.localId,
    required this.remoteId,
    required this.syncStatus,
    required this.createdAtLocal,
    required this.updatedAtLocal,
    required this.lastSyncError,
    required this.payload,
  });
}

class FirestoreLocalCacheStore {
  FirestoreLocalCacheStore(this._db);

  final AppDatabase _db;

  static const List<String> managedTables = <String>[
    'associations',
    'association_contacts',
    'sponsorship_files',
    'sponsorship_candidates',
    'sponsorships',
    'sponsorship_payments',
    'beneficiary_visits',
    'beneficiary_followups',
  ];

  Future<void> ensureSchema() async {
    for (final logicalTable in managedTables) {
      final table = _physicalTable(logicalTable);
      await _db.customStatement('''
        CREATE TABLE IF NOT EXISTS $table (
          local_id TEXT PRIMARY KEY,
          remote_id TEXT,
          payload_json TEXT NOT NULL,
          sync_status TEXT NOT NULL,
          created_at_local TEXT NOT NULL,
          updated_at_local TEXT NOT NULL,
          last_sync_error TEXT,
          is_deleted INTEGER NOT NULL DEFAULT 0
        );
      ''');
      await _db.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_${table}_sync_status ON $table(sync_status, updated_at_local);',
      );
    }
  }

  Future<void> upsert({
    required String table,
    required String localId,
    String? remoteId,
    required Map<String, dynamic> payload,
    LocalSyncStatus syncStatus = LocalSyncStatus.pendingUpload,
    String? lastSyncError,
  }) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    final now = DateTime.now().toIso8601String();
    final existing = await _db.customSelect(
      'SELECT created_at_local FROM $physicalTable WHERE local_id = ? LIMIT 1',
      variables: <Variable<Object>>[Variable.withString(localId)],
    ).getSingleOrNull();

    final createdAtLocal = existing?.read<String>('created_at_local') ?? now;

    await _db.customStatement(
      '''
      INSERT INTO $physicalTable (
        local_id,
        remote_id,
        payload_json,
        sync_status,
        created_at_local,
        updated_at_local,
        last_sync_error,
        is_deleted
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 0)
      ON CONFLICT(local_id) DO UPDATE SET
        remote_id = excluded.remote_id,
        payload_json = excluded.payload_json,
        sync_status = excluded.sync_status,
        updated_at_local = excluded.updated_at_local,
        last_sync_error = excluded.last_sync_error,
        is_deleted = 0
      ''',
      <Object?>[
        localId,
        remoteId,
        jsonEncode(payload),
        syncStatus.value,
        createdAtLocal,
        now,
        lastSyncError,
      ],
    );
  }

  Future<List<LocalCacheRecord>> getPendingUploads(String table) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    final rows = await _db.customSelect(
      '''
      SELECT local_id, remote_id, payload_json, sync_status, created_at_local, updated_at_local, last_sync_error
      FROM $physicalTable
      WHERE is_deleted = 0
        AND sync_status IN (?, ?, ?)
      ORDER BY updated_at_local ASC
      ''',
      variables: <Variable<Object>>[
        Variable.withString(LocalSyncStatus.pendingUpload.value),
        Variable.withString(LocalSyncStatus.failedUpload.value),
        Variable.withString(LocalSyncStatus.pendingDelete.value),
      ],
    ).get();

    return rows.map(_rowToRecord).toList(growable: false);
  }

  Future<List<LocalCacheRecord>> getAll(String table) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);
    final rows = await _db.customSelect(
      '''
      SELECT local_id, remote_id, payload_json, sync_status, created_at_local, updated_at_local, last_sync_error
      FROM $physicalTable
      WHERE is_deleted = 0
      ORDER BY updated_at_local DESC
      ''',
    ).get();

    return rows.map(_rowToRecord).toList(growable: false);
  }

  Future<void> markSynced({
    required String table,
    required String localId,
    String? remoteId,
  }) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    await _db.customStatement(
      '''
      UPDATE $physicalTable
      SET sync_status = ?,
          remote_id = COALESCE(?, remote_id),
          updated_at_local = ?,
          last_sync_error = NULL
      WHERE local_id = ?
      ''',
      <Object?>[
        LocalSyncStatus.synced.value,
        remoteId,
        DateTime.now().toIso8601String(),
        localId,
      ],
    );
  }

  Future<void> markFailed({
    required String table,
    required String localId,
    required String error,
  }) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    await _db.customStatement(
      '''
      UPDATE $physicalTable
      SET sync_status = ?,
          updated_at_local = ?,
          last_sync_error = ?
      WHERE local_id = ?
      ''',
      <Object?>[
        LocalSyncStatus.failedUpload.value,
        DateTime.now().toIso8601String(),
        error,
        localId,
      ],
    );
  }

  Future<void> markPendingDelete({
    required String table,
    required String localId,
  }) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    await _db.customStatement(
      '''
      UPDATE $physicalTable
      SET sync_status = ?,
          is_deleted = 1,
          updated_at_local = ?
      WHERE local_id = ?
      ''',
      <Object?>[
        LocalSyncStatus.pendingDelete.value,
        DateTime.now().toIso8601String(),
        localId,
      ],
    );
  }

  Future<void> mergeRemoteRecord({
    required String table,
    required String remoteId,
    required Map<String, dynamic> payload,
  }) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);

    final existing = await _db.customSelect(
      'SELECT local_id, created_at_local FROM $physicalTable WHERE remote_id = ? LIMIT 1',
      variables: <Variable<Object>>[Variable.withString(remoteId)],
    ).getSingleOrNull();

    final localId = existing?.read<String>('local_id') ?? remoteId;
    final createdAt = existing?.read<String>('created_at_local') ?? DateTime.now().toIso8601String();

    await _db.customStatement(
      '''
      INSERT INTO $physicalTable (
        local_id,
        remote_id,
        payload_json,
        sync_status,
        created_at_local,
        updated_at_local,
        last_sync_error,
        is_deleted
      ) VALUES (?, ?, ?, ?, ?, ?, NULL, 0)
      ON CONFLICT(local_id) DO UPDATE SET
        remote_id = excluded.remote_id,
        payload_json = excluded.payload_json,
        sync_status = excluded.sync_status,
        updated_at_local = excluded.updated_at_local,
        last_sync_error = NULL,
        is_deleted = 0
      ''',
      <Object?>[
        localId,
        remoteId,
        jsonEncode(payload),
        LocalSyncStatus.synced.value,
        createdAt,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<int> countAll(String table) async {
    await _assertManagedTable(table);
    final physicalTable = _physicalTable(table);
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $physicalTable WHERE is_deleted = 0',
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<int> countByStatuses(String table, List<String> statuses) async {
    await _assertManagedTable(table);
    if (statuses.isEmpty) return 0;
    final physicalTable = _physicalTable(table);
    final placeholders = List.filled(statuses.length, '?').join(', ');
    final variables = statuses.map(Variable.withString).toList(growable: false);
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM $physicalTable WHERE is_deleted = 0 AND sync_status IN ($placeholders)',
          variables: variables,
        )
        .getSingle();
    return row.read<int>('c');
  }

  LocalCacheRecord _rowToRecord(QueryRow row) {
    final payloadRaw = row.read<String>('payload_json');
    final decoded = jsonDecode(payloadRaw);
    final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    return LocalCacheRecord(
      localId: row.read<String>('local_id'),
      remoteId: row.readNullable<String>('remote_id'),
      syncStatus: LocalSyncStatus.fromValue(row.read<String>('sync_status')),
      createdAtLocal: DateTime.tryParse(row.read<String>('created_at_local')) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAtLocal: DateTime.tryParse(row.read<String>('updated_at_local')) ?? DateTime.fromMillisecondsSinceEpoch(0),
      lastSyncError: row.readNullable<String>('last_sync_error'),
      payload: payload,
    );
  }

  Future<void> _assertManagedTable(String table) async {
    if (!managedTables.contains(table)) {
      throw ArgumentError('Table $table is not managed by FirestoreLocalCacheStore');
    }
    await ensureSchema();
  }

  String _physicalTable(String logicalTable) => 'firecache_$logicalTable';
}
