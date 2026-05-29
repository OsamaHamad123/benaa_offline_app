import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/offline/firestore_local_cache_store.dart';
import '../../../../core/offline/local_sync_status.dart';
import '../../../../core/sync/module_sync_stats.dart';
import '../../../../data/db/drift_database.dart';
import '../../../sync/services/file_id_service.dart';
import '../../domain/services/sponsorship_candidate_matcher.dart';
import '../models/sponsorship_models.dart';

class SponsorshipFirestoreService {
  SponsorshipFirestoreService({
    required AppDatabase database,
    required FirestoreLocalCacheStore localStore,
    required FileIdService fileIdService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _database = database,
        _matcher = SponsorshipCandidateMatcher(database),
        _localStore = localStore,
        _fileIdService = fileIdService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final AppDatabase _database;
  final SponsorshipCandidateMatcher _matcher;
  final FirestoreLocalCacheStore _localStore;
  final FileIdService _fileIdService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> upsertSponsorshipFileLocal(SponsorshipFileModel model) async {
    await _localStore.upsert(
      table: 'sponsorship_files',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<void> upsertCandidateLocal(SponsorshipCandidateModel model) async {
    await _localStore.upsert(
      table: 'sponsorship_candidates',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<void> upsertSponsorshipLocal(SponsorshipModel model) async {
    await _localStore.upsert(
      table: 'sponsorships',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreUpdateJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<void> upsertSponsorshipPaymentLocal(SponsorshipPaymentModel model) async {
    await _localStore.upsert(
      table: 'sponsorship_payments',
      localId: model.id,
      remoteId: model.id,
      payload: model.toFirestoreJson(),
      syncStatus: LocalSyncStatus.pendingUpload,
    );
  }

  Future<CandidateMatchResult> runCandidateMatching({
    required String candidateLocalId,
  }) async {
    final candidateRows = await _localStore.getAll('sponsorship_candidates');
    final row = candidateRows.where((e) => e.localId == candidateLocalId).cast<LocalCacheRecord?>().firstWhere(
          (e) => e != null,
          orElse: () => null,
        );
    if (row == null) {
      return const CandidateMatchResult(matchStatus: 'needs_review', score: 0, reason: 'candidate_not_found');
    }

    final payload = Map<String, dynamic>.from(row.payload);
    final result = await _matcher.matchCandidate(
      nationalId: payload['nationalId']?.toString(),
      phone: payload['phone']?.toString(),
      rawName: payload['rawName']?.toString() ?? '',
      city: payload['city']?.toString(),
    );

    payload['matchStatus'] = result.matchStatus;
    if (result.beneficiaryLocalId != null) {
      payload['matchedBeneficiaryId'] = result.beneficiaryLocalId.toString();
    }

    await _localStore.upsert(
      table: 'sponsorship_candidates',
      localId: row.localId,
      remoteId: row.remoteId,
      payload: payload,
      syncStatus: LocalSyncStatus.pendingUpload,
    );

    return result;
  }

  Future<int> createBeneficiaryFromCandidate({
    required String candidateLocalId,
  }) async {
    final candidateRows = await _localStore.getAll('sponsorship_candidates');
    final row = candidateRows.where((e) => e.localId == candidateLocalId).cast<LocalCacheRecord?>().firstWhere(
          (e) => e != null,
          orElse: () => null,
        );
    if (row == null) {
      throw StateError('Candidate not found in local cache');
    }

    final payload = Map<String, dynamic>.from(row.payload);
    final fileNumber = await _fileIdService.getNextFileNumber();
    if (fileNumber == null || fileNumber.trim().isEmpty) {
      throw StateError('No Cedar file number is available');
    }

    final nationalId = int.tryParse(payload['nationalId']?.toString() ?? '');
    final phone = int.tryParse(payload['phone']?.toString() ?? '');

    final now = DateTime.now();
    final beneficiaryId = await _database.into(_database.beneficiaries).insert(
          BeneficiariesCompanion.insert(
            idNumber: nationalId ?? now.millisecondsSinceEpoch.remainder(2147483647),
            phoneNumber: phone ?? 0,
            altPhoneNumber: phone ?? 0,
            firstName: Value(_firstName(payload['rawName']?.toString() ?? 'مستفيد')),
            fatherName: Value(_secondName(payload['rawName']?.toString() ?? 'جديد')),
            grandFatherName: const Value(''),
            familyName: const Value(''),
            currentAddress: Value(payload['address']?.toString()),
            province: Value(int.tryParse(payload['governorate']?.toString() ?? '')),
            city: Value(int.tryParse(payload['city']?.toString() ?? '')),
            numberOfIndividuals: Value((payload['familyMembersCount'] as num?)?.toInt()),
            descriptionNeeds: Value(payload['caseDescription']?.toString()),
            fileIdNumber: Value(fileNumber),
            syncState: const Value('pending'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    await _fileIdService.assignFileNumberToBeneficiary(
      fileNumber: fileNumber,
      beneficiaryLocalId: beneficiaryId,
    );

    payload['matchStatus'] = 'created_new_beneficiary';
    payload['createdBeneficiaryId'] = beneficiaryId.toString();
    await _localStore.upsert(
      table: 'sponsorship_candidates',
      localId: row.localId,
      remoteId: row.remoteId,
      payload: payload,
      syncStatus: LocalSyncStatus.pendingUpload,
    );

    final sponsorshipId = 'spon_${DateTime.now().microsecondsSinceEpoch}';
    final sponsorshipPayload = <String, dynamic>{
      'id': sponsorshipId,
      'beneficiaryId': beneficiaryId.toString(),
      'beneficiaryFileNumber': fileNumber,
      'associationId': payload['associationId']?.toString() ?? '',
      'sponsorshipFileId': payload['sponsorshipFileId']?.toString(),
      'candidateId': row.localId,
      'type': 'other',
      'status': 'pending',
      'amount': payload['requestedAmount'] ?? 0,
      'currency': payload['currency'] ?? 'ILS',
      'frequency': _mapFrequency(payload['sponsorshipType']?.toString()),
      'notes': payload['notes']?.toString(),
      'createdBy': _auth.currentUser?.uid,
    };

    await _localStore.upsert(
      table: 'sponsorships',
      localId: sponsorshipId,
      remoteId: sponsorshipId,
      payload: sponsorshipPayload,
      syncStatus: LocalSyncStatus.pendingUpload,
    );

    return beneficiaryId;
  }

  Future<ModuleSyncStats> uploadPendingCore() async {
    await _mirrorPendingSponsorshipsFromDrift();
    final fileStats = await _uploadTable('sponsorship_files');
    final candidateStats = await _uploadTable('sponsorship_candidates');
    final sponsorshipPending = await _localStore.getPendingUploads('sponsorships');
    developer.log('[SponsorshipUpload] started pending=${sponsorshipPending.length}', name: 'SponsorshipUpload');
    final sponsorshipStats = await _uploadTable('sponsorships');
    final paymentStats = await _uploadTable('sponsorship_payments');
    developer.log(
      '[SponsorshipUpload] completed uploaded=${sponsorshipStats.uploaded} failed=${sponsorshipStats.failed}',
      name: 'SponsorshipUpload',
    );
    return fileStats + candidateStats + sponsorshipStats + paymentStats;
  }

  Future<ModuleSyncStats> downloadCore() async {
    final fileStats = await _downloadTable('sponsorship_files');
    final candidateStats = await _downloadTable('sponsorship_candidates');
    final sponsorshipStats = await _downloadTable('sponsorships');
    final paymentStats = await _downloadTable('sponsorship_payments');
    return fileStats + candidateStats + sponsorshipStats + paymentStats;
  }

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

        final payload = _toFirestorePayload(row.payload)
          ..putIfAbsent('id', () => row.remoteId ?? row.localId)
          ..['updatedAt'] = FieldValue.serverTimestamp();
        payload.putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

        await _firestore.collection(table).doc(row.remoteId ?? row.localId).set(payload, SetOptions(merge: true));
        await _localStore.markSynced(table: table, localId: row.localId, remoteId: row.remoteId ?? row.localId);

        if (table == 'sponsorships') {
          final fileNo = int.tryParse(row.localId);
          if (fileNo != null) {
            await _database.sponsorshipsDao.updateSponsorshipSyncState(
              fileNo: fileNo,
              syncState: 'synced',
            );
          }
          final fileNumber = payload['beneficiaryFileNumber']?.toString() ?? '-';
          developer.log(
            '[SponsorshipUpload] uploaded localId=${row.localId} beneficiary=$fileNumber',
            name: 'SponsorshipUpload',
          );
        }

        uploaded++;
      } catch (e) {
        failed++;
        await _localStore.markFailed(table: table, localId: row.localId, error: e.toString());
        if (table == 'sponsorships') {
          developer.log(
            '[SponsorshipUpload] failed localId=${row.localId} code=upload_failed message=$e',
            name: 'SponsorshipUpload',
          );
        }
      }
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

  Map<String, dynamic> _toFirestorePayload(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  String _secondName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return '';
    return parts[1];
  }

  String _mapFrequency(String? sponsorshipType) {
    switch (sponsorshipType) {
      case 'quarterly':
      case 'yearly':
      case 'one_time':
      case 'monthly':
        return sponsorshipType!;
      case 'emergency':
        return 'one_time';
      default:
        return 'monthly';
    }
  }

  Future<void> _mirrorPendingSponsorshipsFromDrift() async {
    final rows = await (_database.select(_database.sponsorships)
          ..where(
            (s) => s.syncState.equals('pending') | s.syncState.equals('modified') | s.syncState.equals('failed'),
          ))
        .get();

    for (final s in rows) {
      final beneficiary = await _database.beneficiariesDao.getBeneficiaryById(s.beneficiaryId);
      final payload = <String, dynamic>{
        'id': s.fileNo.toString(),
        'localId': s.fileNo.toString(),
        'remoteId': s.serverId?.toString(),
        'beneficiaryLocalId': s.beneficiaryId.toString(),
        'beneficiaryRemoteId': beneficiary?.serverId?.toString(),
        'beneficiaryFileNumber': beneficiary?.fileIdNumber,
        'associationId': s.associationId,
        'sponsorshipFileId': null,
        'candidateId': null,
        'type': s.sponsorshipType,
        'status': s.status,
        'amount': s.amount,
        'currency': s.currency,
        'frequency': s.sponsorshipType,
        'startDate': s.startDate?.toIso8601String(),
        'endDate': s.endDate?.toIso8601String(),
        'sponsorName': s.sponsorName,
        'notes': s.notes,
        'syncStatus': 'synced',
        'createdBy': _auth.currentUser?.uid,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _localStore.upsert(
        table: 'sponsorships',
        localId: s.fileNo.toString(),
        remoteId: s.serverId?.toString() ?? s.fileNo.toString(),
        payload: payload,
        syncStatus: s.syncState == 'failed' ? LocalSyncStatus.failedUpload : LocalSyncStatus.pendingUpload,
      );
    }
  }
}
