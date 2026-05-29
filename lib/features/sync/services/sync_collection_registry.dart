import 'dart:developer' as developer;

import '../../../core/offline/firestore_local_cache_store.dart';
import '../../../data/db/drift_database.dart';
import '../domain/models/sync_collection_summary.dart';
import '../domain/usecases/sync_firestore_modules_usecase.dart';
import 'firebase_beneficiary_upload_service.dart';

class SyncCollectionRegistry {
  SyncCollectionRegistry({
    required AppDatabase database,
    required FirestoreLocalCacheStore localCacheStore,
    required FirebaseBeneficiaryUploadService beneficiaryUploadService,
    required SyncFirestoreModulesUseCase modulesUseCase,
  })  : _db = database,
        _localCacheStore = localCacheStore,
        _beneficiaryUploadService = beneficiaryUploadService,
        _modulesUseCase = modulesUseCase;

  final AppDatabase _db;
  final FirestoreLocalCacheStore _localCacheStore;
  final FirebaseBeneficiaryUploadService _beneficiaryUploadService;
  final SyncFirestoreModulesUseCase _modulesUseCase;

  static const _pendingStatesWithFailed = <String>['pending', 'modified', 'failed'];
  static const _pendingUploadStates = <String>['pending_upload'];
  static const _failedUploadStates = <String>['failed_upload'];

  Future<List<SyncCollectionSummary>> loadSummaries({int? remoteBeneficiariesCount}) async {
    final beneficiaries = await _db.select(_db.beneficiaries).get();
    final visits = await _db.select(_db.visits).get();
    final sponsorships = await _db.select(_db.sponsorships).get();
    final associations = await _db.select(_db.associations).get();

    final summaries = <SyncCollectionSummary>[
      SyncCollectionSummary(
        collectionName: 'beneficiaries',
        labelAr: 'المستفيدين',
        localCount: beneficiaries.length,
        remoteCount: remoteBeneficiariesCount ?? 0,
        pendingUpload: beneficiaries.where((e) => _pendingStatesWithFailed.contains(e.syncState)).length,
        failedUpload: beneficiaries.where((e) => e.syncState == 'failed').length,
        conflicts: 0,
        lastUploadAt: await _db.syncMetadataDao.getLastSyncTime('beneficiaries_upload'),
      ),
      SyncCollectionSummary(
        collectionName: 'beneficiary_visits',
        labelAr: 'الزيارات',
        localCount: visits.length,
        remoteCount: 0,
        pendingUpload: visits.where((e) => _pendingStatesWithFailed.contains(e.syncState)).length,
        failedUpload: visits.where((e) => e.syncState == 'failed').length,
        conflicts: 0,
        lastUploadAt: await _db.syncMetadataDao.getLastSyncTime('visit_upload'),
      ),
      SyncCollectionSummary(
        collectionName: 'sponsorships',
        labelAr: 'الكفالات',
        localCount: sponsorships.length,
        remoteCount: 0,
        pendingUpload: sponsorships.where((e) => _pendingStatesWithFailed.contains(e.syncState)).length,
        failedUpload: sponsorships.where((e) => e.syncState == 'failed').length,
        conflicts: 0,
        lastUploadAt: await _db.syncMetadataDao.getLastSyncTime('sponsorship_upload'),
      ),
      SyncCollectionSummary(
        collectionName: 'associations',
        labelAr: 'الجمعيات',
        localCount: associations.length,
        remoteCount: 0,
        pendingUpload: associations.where((e) => _pendingStatesWithFailed.contains(e.syncState)).length,
        failedUpload: associations.where((e) => e.syncState == 'failed').length,
        conflicts: 0,
        lastUploadAt: await _db.syncMetadataDao.getLastSyncTime('association_upload'),
      ),
      await _cacheSummary('association_contacts', 'جهات اتصال الجمعيات', 'association_contacts_upload'),
      await _cacheSummary('sponsorship_files', 'ملفات الكفالات', 'sponsorship_upload'),
      await _cacheSummary('sponsorship_candidates', 'مرشحو الكفالات', 'sponsorship_upload'),
      await _cacheSummary('sponsorship_payments', 'دفعات الكفالات', 'sponsorship_upload'),
      await _cacheSummary('beneficiary_followups', 'المتابعات', 'followup_upload'),
    ];

    return summaries;
  }

  Future<SyncCollectionSummary> _cacheSummary(String table, String labelAr, String syncKey) async {
    final localCount = await _localCacheStore.countAll(table);
    final pendingUpload = await _localCacheStore.countByStatuses(table, _pendingUploadStates);
    final failedUpload = await _localCacheStore.countByStatuses(table, _failedUploadStates);

    return SyncCollectionSummary(
      collectionName: table,
      labelAr: labelAr,
      localCount: localCount,
      remoteCount: 0,
      pendingUpload: pendingUpload,
      failedUpload: failedUpload,
      conflicts: 0,
      lastUploadAt: await _db.syncMetadataDao.getLastSyncTime(syncKey),
    );
  }

  Future<int> totalPendingChanges({int? remoteBeneficiariesCount}) async {
    final summaries = await loadSummaries(remoteBeneficiariesCount: remoteBeneficiariesCount);
    return summaries.fold<int>(0, (sum, item) => sum + item.pendingUpload + item.failedUpload);
  }

  Future<SyncUploadAllResult> uploadAllPendingChangesToFirebase() async {
    final totalPending = await totalPendingChanges();
    if (totalPending == 0) {
      developer.log('[SyncUpload] no data totalPending=0', name: 'SyncUpload');
      return const SyncUploadAllResult(
        totalPending: 0,
        totalUploaded: 0,
        totalFailed: 0,
        noData: true,
        moduleBreakdown: <String, int>{},
      );
    }

    developer.log('[SyncUpload] started totalPending=$totalPending', name: 'SyncUpload');

    final beneficiarySummary = await _beneficiaryUploadService.uploadPendingBeneficiaries();
    final modulesSummary = await _modulesUseCase.uploadAll();

    final uploaded = beneficiarySummary.uploaded + modulesSummary.aggregate.uploaded;
    final failed = beneficiarySummary.failed + modulesSummary.aggregate.failed;

    developer.log('[SyncUpload] completed uploaded=$uploaded failed=$failed', name: 'SyncUpload');

    return SyncUploadAllResult(
      totalPending: totalPending,
      totalUploaded: uploaded,
      totalFailed: failed,
      noData: false,
      moduleBreakdown: <String, int>{
        'beneficiaries': beneficiarySummary.uploaded,
        ...modulesSummary.operations.map((key, value) => MapEntry(key, value.uploaded)),
      },
    );
  }
}
