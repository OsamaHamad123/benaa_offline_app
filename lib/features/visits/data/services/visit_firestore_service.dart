import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/offline/firestore_local_cache_store.dart';
import '../../../../core/offline/local_sync_status.dart';
import '../../../../core/sync/module_sync_stats.dart';
import '../../../../data/db/drift_database.dart';
import '../models/beneficiary_visit_followup_models.dart';

class VisitFirestoreService {
  VisitFirestoreService({
    required AppDatabase database,
    required FirestoreLocalCacheStore localStore,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _database = database,
        _localStore = localStore,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final AppDatabase _database;
  final FirestoreLocalCacheStore _localStore;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> upsertVisitLocal(BeneficiaryVisitFirestoreModel model) async {
    await _localStore.upsert(
      table: 'beneficiary_visits',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );

    if (model.status == 'completed' && model.nextVisitAt != null && model.nextVisitAt!.trim().isNotEmpty) {
      final followup = BeneficiaryFollowupModel(
        id: 'fu_${DateTime.now().microsecondsSinceEpoch}',
        beneficiaryId: model.beneficiaryId,
        relatedVisitId: model.id,
        relatedSponsorshipId: model.sponsorshipId,
        type: 'field_visit',
        status: 'open',
        title: 'متابعة زيارة لاحقة',
        description: model.summary,
        assignedTo: model.visitedBy,
        dueDate: model.nextVisitAt,
        createdBy: _auth.currentUser?.uid,
      );
      await upsertFollowupLocal(followup);
    }
  }

  Future<void> upsertFollowupLocal(BeneficiaryFollowupModel model) async {
    await _localStore.upsert(
      table: 'beneficiary_followups',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<ModuleSyncStats> uploadPendingVisits() async {
    await _mirrorPendingVisitsFromDrift();
    final pending = await _localStore.getPendingUploads('beneficiary_visits');
    developer.log('[VisitUpload] started pending=${pending.length}', name: 'VisitUpload');
    return _uploadTable('beneficiary_visits');
  }

  Future<ModuleSyncStats> uploadPendingFollowups() => _uploadTable('beneficiary_followups');

  Future<ModuleSyncStats> downloadVisits() => _downloadTable('beneficiary_visits');

  Future<ModuleSyncStats> downloadFollowups() => _downloadTable('beneficiary_followups');

  Future<ModuleSyncStats> _uploadTable(String table) async {
    final pending = await _localStore.getPendingUploads(table);
    var uploaded = 0;
    var failed = 0;

    for (final row in pending) {
      try {
        if (row.syncStatus == LocalSyncStatus.pendingDelete) {
          await _firestore.collection(table).doc(row.remoteId ?? row.localId).delete();
          await _localStore.markSynced(table: table, localId: row.localId, remoteId: row.remoteId);
          uploaded++;
          continue;
        }

        final payload = _toPayload(row.payload)
          ..putIfAbsent('id', () => row.remoteId ?? row.localId)
          ..putIfAbsent('createdBy', () => _auth.currentUser?.uid)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        payload.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

        await _firestore.collection(table).doc(row.remoteId ?? row.localId).set(payload, SetOptions(merge: true));
        await _localStore.markSynced(table: table, localId: row.localId, remoteId: row.remoteId ?? row.localId);

        if (table == 'beneficiary_visits') {
          await _database.visitsDao.updateVisitSyncStatus(row.localId, row.remoteId ?? row.localId);
          final fileNumber = payload['beneficiaryFileNumber']?.toString() ?? '-';
          developer.log(
            '[VisitUpload] uploaded localId=${row.localId} beneficiary=$fileNumber',
            name: 'VisitUpload',
          );
        }

        uploaded++;
      } catch (e) {
        failed++;
        await _localStore.markFailed(table: table, localId: row.localId, error: e.toString());
        if (table == 'beneficiary_visits') {
          developer.log(
            '[VisitUpload] failed localId=${row.localId} code=upload_failed message=$e',
            name: 'VisitUpload',
          );
        }
      }
    }

    if (table == 'beneficiary_visits') {
      developer.log('[VisitUpload] completed uploaded=$uploaded failed=$failed', name: 'VisitUpload');
    }

    return ModuleSyncStats(total: pending.length, uploaded: uploaded, failed: failed);
  }

  Future<ModuleSyncStats> _downloadTable(String table) async {
    var downloaded = 0;
    var failed = 0;

    try {
      final snapshot = await _firestore.collection(table).get();
      for (final doc in snapshot.docs) {
        await _localStore.mergeRemoteRecord(table: table, remoteId: doc.id, payload: doc.data());
        downloaded++;
      }
    } catch (_) {
      failed++;
    }

    return ModuleSyncStats(total: downloaded + failed, downloaded: downloaded, failed: failed);
  }

  Map<String, dynamic> _toPayload(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  Future<void> _mirrorPendingVisitsFromDrift() async {
    final visits = await _database.visitsDao.getPendingVisits();
    for (final visit in visits) {
      final beneficiaryLocalId = int.tryParse(visit.beneficiaryId);
      final beneficiary =
          beneficiaryLocalId == null ? null : await _database.beneficiariesDao.getBeneficiaryById(beneficiaryLocalId);

      final payload = <String, dynamic>{
        'id': visit.id,
        'localId': visit.id,
        'beneficiaryId': visit.beneficiaryId,
        'beneficiaryLocalId': beneficiaryLocalId?.toString(),
        'beneficiaryRemoteId': beneficiary?.serverId?.toString(),
        'beneficiaryFileNumber': beneficiary?.fileIdNumber,
        'visitType': 'field_visit',
        'status': visit.isSubmitted ? 'completed' : 'scheduled',
        'scheduledAt': visit.visitDate.toIso8601String(),
        'completedAt': visit.isSubmitted ? visit.updatedAt.toIso8601String() : null,
        'summary': visit.notes,
        'needs': const <String>[],
        'recommendations': null,
        'nextVisitAt': null,
        'createdBy': _auth.currentUser?.uid,
        'createdByEmail': _auth.currentUser?.email,
        'deviceId': 'unknown_device',
        'source': 'mobile_offline_app',
        'syncStatus': 'synced',
        'createdAtLocal': visit.createdAt.toIso8601String(),
        'updatedAtLocal': visit.updatedAt.toIso8601String(),
      };

      await _localStore.upsert(
        table: 'beneficiary_visits',
        localId: visit.id,
        remoteId: visit.serverId?.trim().isEmpty ?? true ? visit.id : visit.serverId,
        payload: payload,
        syncStatus: visit.syncState == 'failed' ? LocalSyncStatus.failedUpload : LocalSyncStatus.pendingUpload,
      );
    }
  }
}
