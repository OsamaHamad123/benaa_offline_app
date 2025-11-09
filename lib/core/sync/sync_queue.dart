import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/db/drift_database.dart';

class SyncQueueService {
  final AppDatabase db;
  final _uuid = const Uuid();

  SyncQueueService(this.db);

  Future<void> enqueue({
    required String entity,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            entity: entity,
            entityId: entityId,
            operation: operation,
            payload: jsonEncode(payload),
            attempts: const Value(0),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<SyncQueueData>> getPending({int limit = 200}) async {
    return (db.select(db.syncQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markSuccess(String id) async {
    await (db.delete(db.syncQueue)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markFailed(String id, String error) async {
    final item = await (db.select(
      db.syncQueue,
    )..where((t) => t.id.equals(id))).getSingle();

    await db
        .update(db.syncQueue)
        .replace(
          item.copyWith(attempts: item.attempts + 1, lastError: Value(error)),
        );
  }

  Future<int> getQueueCount() async {
    final query = db.selectOnly(db.syncQueue)
      ..addColumns([db.syncQueue.id.count()]);
    final count = await query.getSingle();
    return count.read(db.syncQueue.id.count()) ?? 0;
  }

  Future<void> clearQueue() async {
    await db.delete(db.syncQueue).go();
  }
}
