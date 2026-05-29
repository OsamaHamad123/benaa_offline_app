import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/offline/firestore_local_cache_store.dart';
import '../../../../core/offline/local_sync_status.dart';
import '../../../../core/sync/module_sync_stats.dart';
import '../../../../data/db/drift_database.dart';
import '../models/association_firestore_model.dart';

class AssociationFirestoreService {
  AssociationFirestoreService({
    required AppDatabase database,
    required FirestoreLocalCacheStore localStore,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = database,
        _localStore = localStore,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final AppDatabase _db;
  final FirestoreLocalCacheStore _localStore;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> upsertAssociationLocal(AssociationFirestoreModel model) async {
    await _localStore.upsert(
      table: 'associations',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<void> upsertAssociationContactLocal(AssociationContactModel model) async {
    await _localStore.upsert(
      table: 'association_contacts',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<ModuleSyncStats> uploadPendingAssociations() async {
    await _mirrorPendingAssociationsFromDrift();
    final pending = await _localStore.getPendingUploads('associations');
    developer.log('[AssociationUpload] started pending=${pending.length}', name: 'AssociationUpload');
    var uploaded = 0;
    var failed = 0;

    for (final row in pending) {
      try {
        if (row.syncStatus == LocalSyncStatus.pendingDelete) {
          await _firestore.collection('associations').doc(row.remoteId ?? row.localId).delete();
          await _localStore.markSynced(table: 'associations', localId: row.localId, remoteId: row.remoteId);
          uploaded++;
          continue;
        }

        final payload = Map<String, dynamic>.from(row.payload)
          ..putIfAbsent('id', () => row.remoteId ?? row.localId)
          ..putIfAbsent('createdBy', _resolveUid)
          ..['updatedAt'] = FieldValue.serverTimestamp();

        payload.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

        await _firestore
            .collection('associations')
            .doc(row.remoteId ?? row.localId)
            .set(payload, SetOptions(merge: true));
        await _localStore.markSynced(
          table: 'associations',
          localId: row.localId,
          remoteId: row.remoteId ?? row.localId,
        );

        await (_db.update(_db.associations)..where((a) => a.id.equals(row.localId))).write(
          AssociationsCompanion(
            syncState: const drift.Value('synced'),
            lastSyncedAt: drift.Value(DateTime.now()),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

        uploaded++;
      } catch (e) {
        failed++;
        await _localStore.markFailed(table: 'associations', localId: row.localId, error: e.toString());
      }
    }

    developer.log('[AssociationUpload] completed uploaded=$uploaded failed=$failed', name: 'AssociationUpload');

    return ModuleSyncStats(total: pending.length, uploaded: uploaded, failed: failed);
  }

  Future<ModuleSyncStats> uploadPendingContacts() async {
    final pending = await _localStore.getPendingUploads('association_contacts');
    var uploaded = 0;
    var failed = 0;

    for (final row in pending) {
      try {
        if (row.syncStatus == LocalSyncStatus.pendingDelete) {
          await _firestore.collection('association_contacts').doc(row.remoteId ?? row.localId).delete();
          await _localStore.markSynced(table: 'association_contacts', localId: row.localId, remoteId: row.remoteId);
          uploaded++;
          continue;
        }

        final payload = Map<String, dynamic>.from(row.payload)
          ..putIfAbsent('id', () => row.remoteId ?? row.localId)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        payload.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

        await _firestore
            .collection('association_contacts')
            .doc(row.remoteId ?? row.localId)
            .set(payload, SetOptions(merge: true));

        await _localStore.markSynced(
          table: 'association_contacts',
          localId: row.localId,
          remoteId: row.remoteId ?? row.localId,
        );
        uploaded++;
      } catch (e) {
        failed++;
        await _localStore.markFailed(table: 'association_contacts', localId: row.localId, error: e.toString());
      }
    }

    return ModuleSyncStats(total: pending.length, uploaded: uploaded, failed: failed);
  }

  Future<ModuleSyncStats> downloadAssociations() async {
    var downloaded = 0;
    var failed = 0;

    try {
      final snapshot = await _firestore.collection('associations').get();
      for (final doc in snapshot.docs) {
        await _localStore.mergeRemoteRecord(
          table: 'associations',
          remoteId: doc.id,
          payload: doc.data(),
        );
        downloaded++;
      }
    } catch (_) {
      failed++;
    }

    return ModuleSyncStats(total: downloaded + failed, downloaded: downloaded, failed: failed);
  }

  Future<ModuleSyncStats> downloadAssociationContacts() async {
    var downloaded = 0;
    var failed = 0;

    try {
      final snapshot = await _firestore.collection('association_contacts').get();
      for (final doc in snapshot.docs) {
        await _localStore.mergeRemoteRecord(
          table: 'association_contacts',
          remoteId: doc.id,
          payload: doc.data(),
        );
        downloaded++;
      }
    } catch (_) {
      failed++;
    }

    return ModuleSyncStats(total: downloaded + failed, downloaded: downloaded, failed: failed);
  }

  Future<List<AssociationFirestoreModel>> getLocalAssociations() async {
    final rows = await _localStore.getAll('associations');
    return rows.map((e) => AssociationFirestoreModel.fromJson(_toPlainJson(e.payload))).toList(growable: false);
  }

  Future<void> _mirrorPendingAssociationsFromDrift() async {
    final pending = await (_db.select(_db.associations)
          ..where(
            (a) => a.syncState.equals('pending') | a.syncState.equals('modified') | a.syncState.equals('failed'),
          ))
        .get();

    for (final a in pending) {
      await _localStore.upsert(
        table: 'associations',
        localId: a.id,
        remoteId: a.serverId?.toString() ?? a.id,
        payload: <String, dynamic>{
          'id': a.id,
          'nameAr': a.name,
          'nameEn': a.shortName,
          'type': 'other',
          'contactPersonPhone': a.phone,
          'email': a.email,
          'isActive': a.isActive,
          'updatedAt': a.updatedAt.toIso8601String(),
        },
        syncStatus: a.syncState == 'failed' ? LocalSyncStatus.failedUpload : LocalSyncStatus.pendingUpload,
      );
    }
  }

  String _resolveUid() => _auth.currentUser?.uid ?? 'system';

  Map<String, dynamic> _toPlainJson(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
