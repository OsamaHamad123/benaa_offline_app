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

  /// أقصى عدد محاولات قبل اعتبار العنصر "سامّاً" وإيقاف إعادة محاولته تلقائياً.
  static const int maxAttempts = 5;

  /// Get sync queue items (ordered by priority)
  ///
  /// يحترم:
  ///  - scheduledAt: لا يُرجع عنصراً حُدِّد له موعد إعادة محاولة مستقبلي (backoff).
  ///  - maxAttempts: يستبعد العناصر التي تجاوزت الحد (رسائل سامة) حتى لا تُعاد للأبد.
  Future<List<SyncQueueItem>> getSyncQueue({int limit = 100}) async {
    final now = DateTime.now();
    return await (select(syncQueue)
          ..where((s) =>
              s.attempts.isSmallerThanValue(maxAttempts) &
              (s.scheduledAt.isNull() |
                  s.scheduledAt.isSmallerOrEqualValue(now)))
          ..orderBy([
            (s) => OrderingTerm.desc(s.priority),
            (s) => OrderingTerm.asc(s.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  /// عناصر تجاوزت حد المحاولات (لعرضها للمستخدم كـ "فشل مزامنة يحتاج تدخّلاً").
  Future<List<SyncQueueItem>> getFailedItems() async {
    return await (select(syncQueue)
          ..where((s) => s.attempts.isBiggerOrEqualValue(maxAttempts)))
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
