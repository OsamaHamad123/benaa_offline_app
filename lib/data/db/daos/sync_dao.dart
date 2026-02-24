import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/sync_queue_table.dart';
import '../tables/taxonomies_table.dart';

part 'sync_dao.g.dart';

/// Sync and Taxonomies Data Access Object
/// يحتوي على عمليات المزامنة والتصنيفات
@DriftAccessor(tables: [SyncQueue, Taxonomies])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  // ============================================================================
  // SYNC QUEUE OPERATIONS
  // ============================================================================

  /// Get sync queue items (ordered by priority)
  Future<List<SyncQueueItem>> getSyncQueue({int limit = 100}) async {
    return await (select(syncQueue)
          ..orderBy([
            (s) => OrderingTerm.desc(s.priority),
            (s) => OrderingTerm.asc(s.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Add item to sync queue
  Future<void> addToSyncQueue(SyncQueueCompanion item) async {
    await into(syncQueue).insert(item);
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(String id) async {
    await (delete(syncQueue)..where((s) => s.id.equals(id))).go();
  }

  /// Update sync queue error
  Future<void> updateSyncQueueError(
    String id,
    String error,
    int attempts,
  ) async {
    await (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(lastError: Value(error), attempts: Value(attempts)),
    );
  }

  // ============================================================================
  // TAXONOMIES OPERATIONS
  // ============================================================================

  /// Get taxonomies by group
  Future<List<Taxonomy>> getTaxonomiesByGroup(String group) async {
    return await (select(taxonomies)
          ..where((t) => t.group.equals(group) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Add or update taxonomy
  Future<void> upsertTaxonomy(TaxonomiesCompanion taxonomy) async {
    await into(taxonomies).insertOnConflictUpdate(taxonomy);
  }

  // ============================================================================
  // DELETE SYNC TOMBSTONES
  // ============================================================================

  Future<void> addTombstone({
    required String entityType,
    required String entityId,
    String? payload,
    DateTime? deletedAt,
  }) async {
    await customStatement(
      '''
      INSERT INTO sync_tombstones (
        entity_type,
        entity_id,
        payload,
        deleted_at,
        sync_state,
        attempts,
        last_error,
        last_synced_at
      ) VALUES (?, ?, ?, ?, 'pending', 0, NULL, NULL)
      ''',
      [
        entityType,
        entityId,
        payload,
        (deletedAt ?? DateTime.now()).toIso8601String(),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTombstones({
    String? entityType,
    int limit = 200,
  }) async {
    final hasEntity = entityType != null && entityType.trim().isNotEmpty;

    final rows = await customSelect(
      hasEntity
          ? '''
      SELECT *
      FROM sync_tombstones
      WHERE sync_state = 'pending' AND entity_type = ?
      ORDER BY deleted_at ASC
      LIMIT ?
      '''
          : '''
      SELECT *
      FROM sync_tombstones
      WHERE sync_state = 'pending'
      ORDER BY deleted_at ASC
      LIMIT ?
      ''',
      variables: hasEntity
          ? [
              Variable.withString(entityType.trim()),
              Variable.withInt(limit),
            ]
          : [Variable.withInt(limit)],
    ).get();

    return rows.map((row) => row.data).toList(growable: false);
  }

  Future<void> markTombstoneSynced(int tombstoneId) async {
    final now = DateTime.now().toIso8601String();
    await customStatement(
      '''
      UPDATE sync_tombstones
      SET sync_state = 'synced',
          last_synced_at = ?,
          last_error = NULL
      WHERE id = ?
      ''',
      [now, tombstoneId],
    );
  }

  Future<void> markTombstoneFailed(int tombstoneId, String error) async {
    await customStatement(
      '''
      UPDATE sync_tombstones
      SET attempts = attempts + 1,
          last_error = ?
      WHERE id = ?
      ''',
      [error, tombstoneId],
    );
  }
}
