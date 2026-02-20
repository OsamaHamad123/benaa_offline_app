import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/sync_metadata_table.dart';

part 'sync_metadata_dao.g.dart';

@DriftAccessor(tables: [SyncMetadataTable])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase> with _$SyncMetadataDaoMixin {
  SyncMetadataDao(super.db);

  /// Get last sync time for entity
  Future<DateTime?> getLastSyncTime(String entity) async {
    final metadata = await (select(
      db.syncMetadataTable,
    )..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();

    return metadata?.lastSyncTime;
  }

  /// Update sync metadata after successful sync
  Future<void> updateSyncSuccess(
    String entity, {
    required int totalSynced,
    DateTime? syncTime,
  }) async {
    await into(db.syncMetadataTable).insertOnConflictUpdate(
      SyncMetadataTableCompanion.insert(
        entity: entity,
        lastSyncTime: syncTime ?? DateTime.now(),
        totalSynced: Value(totalSynced),
        failedSyncs: const Value(0),
        lastError: const Value(null),
        lastErrorTime: const Value(null),
      ),
    );
  }

  /// Update sync metadata after failed sync
  Future<void> updateSyncFailure(String entity, {required String error}) async {
    final current = await (select(
      db.syncMetadataTable,
    )..where((t) => t.entity.equals(entity)))
        .getSingleOrNull();

    await into(db.syncMetadataTable).insertOnConflictUpdate(
      SyncMetadataTableCompanion.insert(
        entity: entity,
        lastSyncTime: current?.lastSyncTime ?? DateTime.now(),
        totalSynced: Value(current?.totalSynced ?? 0),
        failedSyncs: Value((current?.failedSyncs ?? 0) + 1),
        lastError: Value(error),
        lastErrorTime: Value(DateTime.now()),
      ),
    );
  }

  /// Get all sync metadata
  Future<List<SyncMetadata>> getAllSyncMetadata() {
    return select(db.syncMetadataTable).get();
  }

  /// Clear all sync metadata (for testing)
  Future<void> clearAll() {
    return delete(db.syncMetadataTable).go();
  }
}
