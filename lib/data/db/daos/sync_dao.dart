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
}
