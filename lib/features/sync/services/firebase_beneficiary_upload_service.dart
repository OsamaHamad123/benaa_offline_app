import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/backend/mappers/beneficiary_firestore_mapper.dart';
import '../../../core/backend/firebase/firebase_firestore_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/db/drift_database.dart';
import '../../beneficiaries/data/models/beneficiary_model.dart';
import 'file_id_service.dart';

class BeneficiaryUploadProgress {
  final String phase;
  final int total;
  final int processed;
  final int uploaded;
  final int failed;
  final int skipped;
  final int fileNumbersConfirmed;
  final String? currentLocalId;
  final String? currentName;
  final String? currentFileNumber;
  final String? message;
  final String? errorCode;
  final String? errorMessage;

  const BeneficiaryUploadProgress({
    required this.phase,
    required this.total,
    required this.processed,
    required this.uploaded,
    required this.failed,
    required this.skipped,
    required this.fileNumbersConfirmed,
    this.currentLocalId,
    this.currentName,
    this.currentFileNumber,
    this.message,
    this.errorCode,
    this.errorMessage,
  });
}

class BeneficiaryUploadFailure {
  final String localId;
  final String? fileNumber;
  final String code;
  final String message;

  const BeneficiaryUploadFailure({
    required this.localId,
    required this.code,
    required this.message,
    this.fileNumber,
  });
}

class BeneficiaryUploadSummary {
  final int totalPending;
  final int uploaded;
  final int failed;
  final int skipped;
  final int fileNumbersConfirmed;
  final int attachmentsUploaded;
  final DateTime completedAt;
  final bool pausedByNetwork;
  final bool hadNoPending;
  final List<BeneficiaryUploadFailure> failures;

  const BeneficiaryUploadSummary({
    required this.totalPending,
    required this.uploaded,
    required this.failed,
    required this.skipped,
    required this.fileNumbersConfirmed,
    required this.attachmentsUploaded,
    required this.completedAt,
    required this.pausedByNetwork,
    required this.hadNoPending,
    required this.failures,
  });
}

class BeneficiaryDownloadProgress {
  final String phase;
  final int total;
  final int processed;
  final int created;
  final int updated;
  final int skipped;
  final int failed;
  final int conflicts;
  final String? currentRemoteId;
  final String? currentName;
  final String? currentFileNumber;
  final String? message;
  final String? errorCode;
  final String? errorMessage;

  const BeneficiaryDownloadProgress({
    required this.phase,
    required this.total,
    required this.processed,
    required this.created,
    required this.updated,
    required this.skipped,
    required this.failed,
    required this.conflicts,
    this.currentRemoteId,
    this.currentName,
    this.currentFileNumber,
    this.message,
    this.errorCode,
    this.errorMessage,
  });
}

class BeneficiaryDownloadSummary {
  final int remoteFetched;
  final int created;
  final int updated;
  final int skipped;
  final int failed;
  final int conflicts;
  final bool pausedByNetwork;
  final DateTime completedAt;

  const BeneficiaryDownloadSummary({
    required this.remoteFetched,
    required this.created,
    required this.updated,
    required this.skipped,
    required this.failed,
    required this.conflicts,
    required this.pausedByNetwork,
    required this.completedAt,
  });
}

class LocalResetSummary {
  final int deletedBeneficiaries;
  final int pendingBeforeDelete;
  final DateTime completedAt;

  const LocalResetSummary({
    required this.deletedBeneficiaries,
    required this.pendingBeforeDelete,
    required this.completedAt,
  });
}

class FirestoreHealthCheckResult {
  final bool readOk;
  final bool writeOk;
  final String? readError;
  final String? writeError;
  final DateTime checkedAt;

  const FirestoreHealthCheckResult({
    required this.readOk,
    required this.writeOk,
    required this.checkedAt,
    this.readError,
    this.writeError,
  });
}

class FirebaseBeneficiaryUploadService {
  FirebaseBeneficiaryUploadService({
    required AppDatabase database,
    required FileIdService fileIdService,
    FirebaseFirestore? firestore,
    FirebaseFirestoreService? firestoreService,
    FirebaseAuth? auth,
    SecureStorage? secureStorage,
    Connectivity? connectivity,
  })  : _db = database,
        _fileIdService = fileIdService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firestoreService = firestoreService ?? FirebaseFirestoreService(firestore: firestore),
        _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? SecureStorage(),
        _connectivity = connectivity ?? Connectivity();

  final AppDatabase _db;
  final FileIdService _fileIdService;
  final FirebaseFirestore _firestore;
  final FirebaseFirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final SecureStorage _secureStorage;
  final Connectivity _connectivity;

  Future<List<Beneficiary>> getPendingBeneficiaries() async {
    return (_db.select(_db.beneficiaries)
          ..where((b) => b.syncState.isIn(const <String>['pending', 'modified', 'failed']))
          ..orderBy([
            (b) => OrderingTerm.asc(b.updatedAt),
            (b) => OrderingTerm.asc(b.id),
          ]))
        .get();
  }

  Future<int> getPendingUploadsCount() async {
    return (_db.select(_db.beneficiaries)
          ..where((b) => b.syncState.isIn(const <String>['pending', 'modified', 'failed'])))
        .get()
        .then((rows) => rows.length);
  }

  Future<int?> getRemoteBeneficiariesCount() async {
    try {
      final aggregate = await _firestore.collection('beneficiaries').count().get();
      return aggregate.count;
    } catch (_) {
      return null;
    }
  }

  Future<FirestoreHealthCheckResult> runFirestoreHealthChecks() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('لا يوجد مستخدم Firebase مسجل الدخول.');
    }

    bool readOk = false;
    bool writeOk = false;
    String? readError;
    String? writeError;

    try {
      await _firestore.collection('beneficiaries').limit(1).get();
      readOk = true;
    } catch (e) {
      readError = e.toString();
    }

    try {
      await _firestore.collection('sync_health_checks').doc(user.uid).set(
        <String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'checkedAt': FieldValue.serverTimestamp(),
          'source': 'mobile_sync_page',
        },
        SetOptions(merge: true),
      );
      writeOk = true;
    } catch (e) {
      writeError = e.toString();
    }

    return FirestoreHealthCheckResult(
      readOk: readOk,
      writeOk: writeOk,
      readError: readError,
      writeError: writeError,
      checkedAt: DateTime.now(),
    );
  }

  Future<BeneficiaryUploadSummary> uploadPendingBeneficiaries({
    Future<void> Function(BeneficiaryUploadProgress progress)? onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('لا يوجد مستخدم Firebase مسجل الدخول.');
    }

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      await onProgress?.call(
        const BeneficiaryUploadProgress(
          phase: 'paused_due_to_network',
          total: 0,
          processed: 0,
          uploaded: 0,
          failed: 0,
          skipped: 0,
          fileNumbersConfirmed: 0,
          message: 'لا يوجد اتصال إنترنت مستقر. سيتم الاستكمال لاحقاً.',
          errorCode: 'offline',
          errorMessage: 'لا يوجد اتصال إنترنت مستقر. سيتم الاستكمال لاحقاً.',
        ),
      );

      return BeneficiaryUploadSummary(
        totalPending: 0,
        uploaded: 0,
        failed: 0,
        skipped: 0,
        fileNumbersConfirmed: 0,
        attachmentsUploaded: 0,
        completedAt: DateTime.now(),
        pausedByNetwork: true,
        hadNoPending: false,
        failures: const <BeneficiaryUploadFailure>[],
      );
    }

    final pending = await getPendingBeneficiaries();
    if (pending.isEmpty) {
      await onProgress?.call(
        const BeneficiaryUploadProgress(
          phase: 'completed',
          total: 0,
          processed: 0,
          uploaded: 0,
          failed: 0,
          skipped: 0,
          fileNumbersConfirmed: 0,
          message: 'لا توجد تغييرات لرفعها',
        ),
      );

      return BeneficiaryUploadSummary(
        totalPending: 0,
        uploaded: 0,
        failed: 0,
        skipped: 0,
        fileNumbersConfirmed: 0,
        attachmentsUploaded: 0,
        completedAt: DateTime.now(),
        pausedByNetwork: false,
        hadNoPending: true,
        failures: const <BeneficiaryUploadFailure>[],
      );
    }

    final deviceId = await _resolveDeviceId();
    final failures = <BeneficiaryUploadFailure>[];

    int uploaded = 0;
    int failed = 0;
    int skipped = 0;
    int fileNumbersConfirmed = 0;
    int attachmentsUploaded = 0;
    int processed = 0;

    _log('[SyncUpload] started pending=${pending.length}');

    await onProgress?.call(
      BeneficiaryUploadProgress(
        phase: 'preparing',
        total: pending.length,
        processed: 0,
        uploaded: 0,
        failed: 0,
        skipped: 0,
        fileNumbersConfirmed: 0,
        message: 'جاري تجهيز رفع المستفيدين...',
      ),
    );

    for (final row in pending) {
      processed += 1;
      final localId = row.id.toString();

      try {
        var current = row;
        var fileNumber = (current.fileIdNumber ?? '').trim();

        if (fileNumber.isEmpty) {
          fileNumber = await _assignMissingFileNumber(current);
          if (fileNumber.isEmpty) {
            const message = 'لا يوجد رقم ملف متاح لهذا المستفيد';
            await markBeneficiaryUploadFailed(localId: current.id, error: message);
            failures.add(
              BeneficiaryUploadFailure(
                localId: localId,
                code: 'missing_file_number',
                message: message,
              ),
            );
            failed += 1;
            await onProgress?.call(
              BeneficiaryUploadProgress(
                phase: 'failed',
                total: pending.length,
                processed: processed,
                uploaded: uploaded,
                failed: failed,
                skipped: skipped,
                fileNumbersConfirmed: fileNumbersConfirmed,
                currentLocalId: localId,
                currentName: current.fullName,
                message: message,
                errorCode: 'missing_file_number',
                errorMessage: message,
              ),
            );
            continue;
          }

          final refreshed =
              await (_db.select(_db.beneficiaries)..where((b) => b.id.equals(current.id))).getSingleOrNull();
          if (refreshed != null) {
            current = refreshed;
          }
        }

        final fullName = (current.fullName).trim();
        final nationalId = current.idNumber.toString().trim();
        if (fullName.isEmpty || nationalId.isEmpty) {
          const message = 'بيانات المستفيد غير مكتملة (الاسم/الرقم الوطني).';
          await markBeneficiaryUploadFailed(localId: current.id, error: message);
          failures.add(
            BeneficiaryUploadFailure(
              localId: localId,
              code: 'validation_failed',
              message: message,
              fileNumber: fileNumber,
            ),
          );
          failed += 1;
          continue;
        }

        await onProgress?.call(
          BeneficiaryUploadProgress(
            phase: 'uploading',
            total: pending.length,
            processed: processed,
            uploaded: uploaded,
            failed: failed,
            skipped: skipped,
            fileNumbersConfirmed: fileNumbersConfirmed,
            currentLocalId: localId,
            currentName: fullName,
            currentFileNumber: fileNumber,
            message: 'جاري رفع المستفيد: $fullName ($fileNumber)',
          ),
        );

        final remoteId = await uploadSingleBeneficiary(
          current,
          fileNumber: fileNumber,
          userId: user.uid,
          userEmail: user.email,
          deviceId: deviceId,
        );

        await onProgress?.call(
          BeneficiaryUploadProgress(
            phase: 'confirming_file_number',
            total: pending.length,
            processed: processed,
            uploaded: uploaded,
            failed: failed,
            skipped: skipped,
            fileNumbersConfirmed: fileNumbersConfirmed,
            currentLocalId: localId,
            currentName: fullName,
            currentFileNumber: fileNumber,
            message: 'جاري تأكيد رقم الملف...',
          ),
        );

        await confirmFileNumberAllocation(
          fileNumber: fileNumber,
          beneficiaryLocalId: localId,
          beneficiaryRemoteId: remoteId,
          deviceId: deviceId,
          userId: user.uid,
        );

        fileNumbersConfirmed += 1;
        _log('[SyncUpload] file number confirmed fileNumber=$fileNumber');

        final uploadedAttachments = await _uploadPendingAttachmentsMetadata(
          localBeneficiaryId: localId,
          remoteBeneficiaryId: remoteId,
        );
        attachmentsUploaded += uploadedAttachments;

        await markBeneficiarySynced(localId: current.id, remoteId: remoteId);
        _log('[SyncUpload] uploaded localId=$localId remoteId=$remoteId fileNumber=$fileNumber');

        uploaded += 1;
      } catch (e) {
        final errorText = e.toString();
        await markBeneficiaryUploadFailed(localId: row.id, error: errorText);
        failures.add(
          BeneficiaryUploadFailure(
            localId: localId,
            code: 'upload_failed',
            message: errorText,
            fileNumber: row.fileIdNumber,
          ),
        );
        failed += 1;
        _log('[SyncUpload] failed localId=$localId code=upload_failed message=$errorText');
      }

      if (processed % 20 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    await onProgress?.call(
      BeneficiaryUploadProgress(
        phase: failed > 0 ? 'failed' : 'completed',
        total: pending.length,
        processed: processed,
        uploaded: uploaded,
        failed: failed,
        skipped: skipped,
        fileNumbersConfirmed: fileNumbersConfirmed,
        message: failed > 0 ? 'فشل رفع بعض المستفيدين، يمكنك إعادة المحاولة' : 'تم رفع كل المستفيدين بنجاح',
      ),
    );

    _log('[SyncUpload] completed uploaded=$uploaded failed=$failed skipped=$skipped');

    await _db.syncMetadataDao.updateSyncSuccess(
      'beneficiaries_upload',
      totalSynced: uploaded,
      syncTime: DateTime.now(),
    );

    return BeneficiaryUploadSummary(
      totalPending: pending.length,
      uploaded: uploaded,
      failed: failed,
      skipped: skipped,
      fileNumbersConfirmed: fileNumbersConfirmed,
      attachmentsUploaded: attachmentsUploaded,
      completedAt: DateTime.now(),
      pausedByNetwork: false,
      hadNoPending: false,
      failures: List<BeneficiaryUploadFailure>.unmodifiable(failures),
    );
  }

  Future<void> markBeneficiarySynced({
    required int localId,
    required String remoteId,
  }) async {
    await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(localId))).write(
      BeneficiariesCompanion(
        syncState: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
        serverId: Value(int.tryParse(remoteId)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<BeneficiaryDownloadSummary> syncDownBeneficiariesFromFirebase({
    Future<void> Function(BeneficiaryDownloadProgress progress)? onProgress,
    DateTime? since,
    bool incremental = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('لا يوجد مستخدم Firebase مسجل الدخول.');
    }

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      await onProgress?.call(
        const BeneficiaryDownloadProgress(
          phase: 'paused_due_to_network',
          total: 0,
          processed: 0,
          created: 0,
          updated: 0,
          skipped: 0,
          failed: 0,
          conflicts: 0,
          message: 'لا يوجد اتصال إنترنت مستقر. سيتم الاستكمال لاحقاً.',
          errorCode: 'offline',
          errorMessage: 'لا يوجد اتصال إنترنت مستقر. سيتم الاستكمال لاحقاً.',
        ),
      );

      return BeneficiaryDownloadSummary(
        remoteFetched: 0,
        created: 0,
        updated: 0,
        skipped: 0,
        failed: 0,
        conflicts: 0,
        pausedByNetwork: true,
        completedAt: DateTime.now(),
      );
    }

    _log('[SyncDown] started mode=${incremental ? 'incremental' : 'full'}');
    await onProgress?.call(
      const BeneficiaryDownloadProgress(
        phase: 'preparing',
        total: 0,
        processed: 0,
        created: 0,
        updated: 0,
        skipped: 0,
        failed: 0,
        conflicts: 0,
        message: 'جاري التحضير لتنزيل المستفيدين...',
      ),
    );

    Query<Map<String, dynamic>> query = _firestore.collection('beneficiaries');
    if (incremental && since != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(since));
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    _log('[SyncDown] fetched remoteCount=${docs.length}');

    int processed = 0;
    int created = 0;
    int updated = 0;
    int skipped = 0;
    int failed = 0;
    int conflicts = 0;

    await onProgress?.call(
      BeneficiaryDownloadProgress(
        phase: 'downloading',
        total: docs.length,
        processed: 0,
        created: 0,
        updated: 0,
        skipped: 0,
        failed: 0,
        conflicts: 0,
        message: 'جاري تنزيل البيانات من Firebase...',
      ),
    );

    for (final doc in docs) {
      final data = doc.data();
      processed += 1;

      final remoteId = (data['remoteId'] ?? data['id'] ?? doc.id).toString();
      final localIdRaw = data['localId']?.toString();
      final fileNumber = _asTrimmedString(
        data['fileNumber'] ?? data['fileIdNumber'] ?? data['file_no'] ?? data['file_id_number'],
      );
      final nationalId = _asTrimmedString(data['nationalId'] ?? data['national_id']);
      final displayName = _asTrimmedString(data['fullName'] ?? data['full_name']) ?? 'بدون اسم';

      final hasPendingDelete = await _hasPendingLocalDeleteTombstone(
        remoteId: remoteId,
        fileNumber: fileNumber,
        nationalId: nationalId,
      );
      if (hasPendingDelete) {
        skipped += 1;
        _log('[SyncDown] skipped remoteId=$remoteId reason=pending_local_delete');
        continue;
      }

      final isDeleted = _isRemoteDeleted(data);
      if (isDeleted) {
        skipped += 1;
        await onProgress?.call(
          BeneficiaryDownloadProgress(
            phase: 'merging_local',
            total: docs.length,
            processed: processed,
            created: created,
            updated: updated,
            skipped: skipped,
            failed: failed,
            conflicts: conflicts,
            currentRemoteId: remoteId,
            currentName: displayName,
            currentFileNumber: fileNumber,
            message: 'تم تخطي سجل محذوف على Firebase.',
          ),
        );
        continue;
      }

      try {
        final existing = await _findExistingLocalBeneficiary(
          localIdRaw: localIdRaw,
          remoteIdRaw: remoteId,
          fileNumber: fileNumber,
          nationalId: nationalId,
        );

        if (existing != null && _isLocalUnsynced(existing.syncState)) {
          conflicts += 1;
          skipped += 1;
          _log(
            '[SyncDown] conflict localId=${existing.id} remoteId=$remoteId reason=local_unsynced_state_${existing.syncState}',
          );
        } else {
          final companion = _buildBeneficiaryCompanionFromFirestore(
            data,
            remoteId: remoteId,
            localIdRaw: localIdRaw,
            fallbackFileNumber: fileNumber,
          );

          if (companion == null) {
            failed += 1;
            _log('[SyncDown] mapping failed remoteId=$remoteId');
          } else if (existing != null) {
            await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(existing.id))).write(companion);
            updated += 1;
          } else {
            await _db.into(_db.beneficiaries).insert(companion);
            created += 1;
          }
        }
      } catch (e) {
        failed += 1;
        _log('[SyncDown] failed remoteId=$remoteId error=$e');
      }

      if (processed == docs.length || processed % 20 == 0) {
        await onProgress?.call(
          BeneficiaryDownloadProgress(
            phase: 'merging_local',
            total: docs.length,
            processed: processed,
            created: created,
            updated: updated,
            skipped: skipped,
            failed: failed,
            conflicts: conflicts,
            currentRemoteId: remoteId,
            currentName: displayName,
            currentFileNumber: fileNumber,
            message: 'جاري الدمج محلياً...',
          ),
        );
      }

      if (processed % 20 == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    await _db.syncMetadataDao.updateSyncSuccess(
      'beneficiaries_download',
      totalSynced: created + updated,
      syncTime: DateTime.now(),
    );

    _log('[SyncDown] upserted localCount=${created + updated}');
    _log('[SyncDown] completed downloaded=${docs.length} updated=$updated skipped=$skipped conflicts=$conflicts');

    await onProgress?.call(
      BeneficiaryDownloadProgress(
        phase: failed > 0 ? 'failed' : 'completed',
        total: docs.length,
        processed: processed,
        created: created,
        updated: updated,
        skipped: skipped,
        failed: failed,
        conflicts: conflicts,
        message:
            failed > 0 ? 'اكتمل التنزيل مع بعض الأخطاء، يمكن إعادة المحاولة.' : 'اكتمل تنزيل البيانات ودمجها محلياً.',
        errorCode: failed > 0 ? 'partial_failure' : null,
        errorMessage: failed > 0 ? 'فشل معالجة بعض السجلات.' : null,
      ),
    );

    return BeneficiaryDownloadSummary(
      remoteFetched: docs.length,
      created: created,
      updated: updated,
      skipped: skipped,
      failed: failed,
      conflicts: conflicts,
      pausedByNetwork: false,
      completedAt: DateTime.now(),
    );
  }

  Future<LocalResetSummary> resetBeneficiariesLocalCache({
    required bool force,
  }) async {
    final pendingBeforeDelete = await getPendingUploadsCount();
    if (pendingBeforeDelete > 0 && !force) {
      throw StateError('يوجد عناصر بانتظار الرفع. يجب التأكيد الإجباري قبل المسح.');
    }

    final beforeCount = await (_db.select(_db.beneficiaries)).get().then((rows) => rows.length);

    await _db.transaction(() async {
      await _db.delete(_db.visits).go();
      await _db.delete(_db.attachments).go();
      await _db.delete(_db.familyMembersTable).go();
      await _db.delete(_db.familyDeceasedTable).go();
      await _db.delete(_db.sponsorships).go();
      await _db.delete(_db.beneficiaries).go();

      await _db.customStatement("DELETE FROM sync_tombstones WHERE entity_type = 'data';").catchError((_) {});
      await _db.customStatement(
        "DELETE FROM sync_metadata_table WHERE entity IN ('beneficiaries', 'beneficiaries_download', 'beneficiaries_upload', 'full_sync');",
      );
    });

    return LocalResetSummary(
      deletedBeneficiaries: beforeCount,
      pendingBeforeDelete: pendingBeforeDelete,
      completedAt: DateTime.now(),
    );
  }

  Future<void> resetTaxonomiesLocalCache() async {
    await _db.transaction(() async {
      await _db.delete(_db.taxonomies).go();
      await _db.customStatement("DELETE FROM sync_metadata_table WHERE entity = 'taxonomies';");
    });
  }

  Future<void> resetFileNumberPoolLocalCache() async {
    await _db.transaction(() async {
      await _db.customStatement('DELETE FROM local_file_numbers;').catchError((_) {});
      await _db.customStatement('DELETE FROM local_file_number_blocks;').catchError((_) {});
      await _db.customStatement('DELETE FROM local_codes;').catchError((_) {});
      await _db.delete(_db.fileIdReservationTable).go();
    });
  }

  Future<void> markBeneficiaryUploadFailed({
    required int localId,
    required String error,
  }) async {
    await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(localId))).write(
      BeneficiariesCompanion(
        syncState: const Value('failed'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> confirmFileNumberAllocation({
    required String fileNumber,
    required String beneficiaryLocalId,
    required String beneficiaryRemoteId,
    required String deviceId,
    required String userId,
  }) async {
    await _firestore.collection('file_number_allocations').doc(fileNumber).set(
      <String, dynamic>{
        'fileNumber': fileNumber,
        'status': 'synced',
        'beneficiaryLocalId': beneficiaryLocalId,
        'beneficiaryRemoteId': beneficiaryRemoteId,
        'deviceId': deviceId,
        'userId': userId,
        'uploadedAt': FieldValue.serverTimestamp(),
        'source': 'beneficiary_upload',
      },
      SetOptions(merge: true),
    );

    await _fileIdService.markFileNumberSynced(fileNumber);
  }

  Future<String> _assignMissingFileNumber(Beneficiary row) async {
    final nextFileNumber = await _fileIdService.getNextFileNumber();
    if (nextFileNumber == null || nextFileNumber.trim().isEmpty) {
      return '';
    }

    await _fileIdService.assignFileNumberToBeneficiary(
      fileNumber: nextFileNumber,
      beneficiaryLocalId: row.id,
    );

    await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(row.id))).write(
      BeneficiariesCompanion(
        fileIdNumber: Value(nextFileNumber),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return nextFileNumber;
  }

  Future<int> _uploadPendingAttachmentsMetadata({
    required String localBeneficiaryId,
    required String remoteBeneficiaryId,
  }) async {
    final pending = await (_db.select(_db.attachments)
          ..where((a) => a.beneficiaryId.equals(localBeneficiaryId) & a.syncState.equals('pending')))
        .get();

    if (pending.isEmpty) {
      return 0;
    }

    int uploaded = 0;
    for (final attachment in pending) {
      final payload = <String, dynamic>{
        'id': attachment.id,
        'beneficiaryId': remoteBeneficiaryId,
        'fileName': attachment.fileName,
        'type': attachment.type,
        'fileSize': attachment.fileSize,
        'documentType': attachment.documentType,
        'personType': attachment.personType,
        'personId': attachment.personId,
        'notes': attachment.notes,
        'source': 'mobile_offline_app',
      };

      await _firestoreService.upsertAttachmentMetadata(remoteBeneficiaryId, payload);
      await _db.attachmentsDao.updateAttachmentSyncState(
        attachment.id,
        'synced',
        serverUrl: attachment.serverUrl,
      );
      uploaded += 1;
    }

    return uploaded;
  }

  String _resolveRemoteId(Beneficiary row) {
    final existingServerId = row.serverId;
    if (existingServerId != null && existingServerId > 0) {
      return existingServerId.toString();
    }
    return row.id.toString();
  }

  Future<String> _resolveDeviceId() async {
    try {
      final value = (await _secureStorage.getDeviceId()).trim();
      if (value.isNotEmpty) {
        return value;
      }
    } catch (_) {
      // Ignore and fallback.
    }

    return 'unknown-device';
  }

  Future<bool> _hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  bool _isLocalUnsynced(String syncState) {
    return syncState == 'pending' || syncState == 'modified' || syncState == 'failed';
  }

  bool _isRemoteDeleted(Map<String, dynamic> data) {
    final deletedAt = data['deletedAt'] ?? data['deleted_at'];
    if (deletedAt != null) {
      final raw = deletedAt.toString().trim();
      if (raw.isNotEmpty && raw.toLowerCase() != 'null') {
        return true;
      }
    }

    final boolLike = data['isDeleted'] ?? data['is_deleted'];
    if (boolLike is bool) {
      return boolLike;
    }
    final rawBool = boolLike?.toString().trim().toLowerCase();
    return rawBool == 'true' || rawBool == '1' || rawBool == 'yes';
  }

  Future<Beneficiary?> _findExistingLocalBeneficiary({
    required String? localIdRaw,
    required String remoteIdRaw,
    required String? fileNumber,
    required String? nationalId,
  }) async {
    final localId = int.tryParse((localIdRaw ?? '').trim());
    if (localId != null) {
      final byLocalId = await (_db.select(_db.beneficiaries)..where((b) => b.id.equals(localId))).getSingleOrNull();
      if (byLocalId != null) return byLocalId;
    }

    final remoteAsInt = int.tryParse(remoteIdRaw.trim());
    if (remoteAsInt != null) {
      final byServerId =
          await (_db.select(_db.beneficiaries)..where((b) => b.serverId.equals(remoteAsInt))).getSingleOrNull();
      if (byServerId != null) return byServerId;
    }

    final normalizedFile = _asTrimmedString(fileNumber);
    if (normalizedFile != null && normalizedFile.isNotEmpty) {
      final byFile =
          await (_db.select(_db.beneficiaries)..where((b) => b.fileIdNumber.equals(normalizedFile))).getSingleOrNull();
      if (byFile != null) return byFile;
    }

    final parsedNational = int.tryParse((nationalId ?? '').trim());
    if (parsedNational != null) {
      final byNational =
          await (_db.select(_db.beneficiaries)..where((b) => b.idNumber.equals(parsedNational))).getSingleOrNull();
      if (byNational != null) return byNational;
    }

    return null;
  }

  BeneficiariesCompanion? _buildBeneficiaryCompanionFromFirestore(
    Map<String, dynamic> data, {
    required String remoteId,
    required String? localIdRaw,
    required String? fallbackFileNumber,
  }) {
    final nationalIdText = _asTrimmedString(data['nationalId'] ?? data['national_id']);
    final nationalId = int.tryParse((nationalIdText ?? '').replaceAll(RegExp(r'\D'), ''));
    if (nationalId == null || nationalId <= 0) {
      return null;
    }

    final phoneText = _asTrimmedString(data['phone'] ?? data['phone_number'] ?? data['phoneNumber']);
    final phone = int.tryParse((phoneText ?? '').replaceAll(RegExp(r'\D'), '')) ?? 0;

    final altPhoneText = _asTrimmedString(data['alt_phone_number'] ?? data['altPhoneNumber']);
    final altPhone = int.tryParse((altPhoneText ?? '').replaceAll(RegExp(r'\D'), '')) ?? 0;

    final fullName = _asTrimmedString(data['full_name'] ?? data['fullName']);
    final parts = _splitFullName(fullName);
    final fileNumber = _asTrimmedString(
      data['fileNumber'] ?? data['fileIdNumber'] ?? data['file_id_number'] ?? data['file_no'] ?? fallbackFileNumber,
    );

    final remoteUpdatedAt = _asDateTime(data['updatedAt'] ?? data['updated_at']) ?? DateTime.now();
    final remoteCreatedAt = _asDateTime(data['createdAt'] ?? data['created_at']) ?? remoteUpdatedAt;

    final sectionId = _asInt(data['section_id'] ?? data['sectionId'] ?? data['category_code']);
    final requestStatus = _asInt(data['request_status'] ?? data['requestStatus']) ?? 1;

    return BeneficiariesCompanion(
      fileIdNumber: Value(fileNumber),
      sectionId: Value(sectionId),
      requestStatus: Value(requestStatus),
      idNumber: Value(nationalId),
      firstName: Value(parts.$1),
      fatherName: Value(parts.$2),
      grandFatherName: Value(parts.$3),
      familyName: Value(parts.$4),
      relationship: Value(_asInt(data['relationship'])),
      birthDate: Value(_asDateTime(data['birth_date'] ?? data['birthDate'])),
      gender: Value(_asGenderCode(data['gender'])),
      phoneNumber: Value(phone),
      altPhoneNumber: Value(altPhone),
      numberOfIndividuals: Value(_asInt(data['family_size'] ?? data['familySize'])),
      maritalStatus: Value(_asInt(data['marital_status'])),
      numberOfMales: Value(_asInt(data['number_of_males'])),
      numberOfFemales: Value(_asInt(data['number_of_females'])),
      academicQualification: Value(_asInt(data['education_level'])),
      employmentStatusBreadwinner: Value(_asInt(data['employment_status'])),
      displacementStatus: Value(_asInt(data['displacement_status'])),
      addressBeforeDisplacement: Value(_asTrimmedString(data['address_before_displacement'])),
      currentAddress: Value(_asTrimmedString(data['current_address'] ?? data['address'])),
      city: Value(_asInt(data['city'] ?? data['district'])),
      province: Value(_asInt(data['province'] ?? data['governorate'])),
      healthStatus: Value(_asInt(data['health_status']) ?? 1),
      numberOfIndividualsWithChronicDiseases: Value(_asInt(data['chronic_diseases_count'])),
      numberOfPeopleWithSpecialNeeds: Value(_asInt(data['special_needs_count'])),
      housingStatus: Value(_asInt(data['housing_status'])),
      currentHousingType: Value(_asInt(data['housing_type'])),
      assistanceTypeCode: Value(_asTrimmedString(data['assistance_type_code'])),
      disabilityTypeCode: Value(_asTrimmedString(data['disability_type_code'])),
      incomeSourceCode: Value(_asTrimmedString(data['income_source_code'])),
      guaranteeTypeCode: Value(_asTrimmedString(data['guarantee_type_code'])),
      descriptionNeeds: Value(_asTrimmedString(data['notes'])),
      userInsertData: Value(_asTrimmedString(data['createdBy'] ?? data['created_by_user'])),
      createdAt: Value(remoteCreatedAt),
      updatedAt: Value(remoteUpdatedAt),
      syncState: const Value('synced'),
      serverId: Value(int.tryParse(remoteId) ?? int.tryParse((localIdRaw ?? '').trim())),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  (String?, String?, String?, String?) _splitFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return (null, null, null, null);
    }

    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.trim().isNotEmpty).toList(growable: false);

    final first = parts.isNotEmpty ? parts[0] : null;
    final father = parts.length > 1 ? parts[1] : null;
    final grand = parts.length > 2 ? parts[2] : null;
    final family = parts.length > 3 ? parts.sublist(3).join(' ') : null;
    return (first, father, grand, family);
  }

  String? _asTrimmedString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return int.tryParse(text) ?? int.tryParse(text.replaceAll(RegExp(r'\D'), ''));
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    final text = value.toString();
    return DateTime.tryParse(text);
  }

  int? _asGenderCode(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final text = value.toString().trim().toLowerCase();
    if (text == '1' || text == 'male' || text == 'ذكر') return 1;
    if (text == '2' || text == 'female' || text == 'أنثى' || text == 'انثى') return 2;
    return _asInt(value);
  }

  Future<bool> _hasPendingLocalDeleteTombstone({
    required String remoteId,
    required String? fileNumber,
    required String? nationalId,
  }) async {
    final candidates = <String>{
      remoteId.trim(),
      if (fileNumber != null && fileNumber.trim().isNotEmpty) fileNumber.trim(),
      if (nationalId != null && nationalId.trim().isNotEmpty) nationalId.trim(),
    };

    for (final candidate in candidates) {
      final rows = await _db.customSelect(
        '''
        SELECT id
        FROM sync_tombstones
        WHERE entity_type = 'data'
          AND sync_state = 'pending'
          AND entity_id = ?
        LIMIT 1
        ''',
        variables: <Variable<Object>>[Variable.withString(candidate)],
      ).get();
      if (rows.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  void _log(String message) {
    developer.log(message, name: 'BeneficiaryUpload');
  }

  Future<String> uploadSingleBeneficiary(
    Beneficiary row, {
    required String fileNumber,
    required String userId,
    required String? userEmail,
    required String deviceId,
  }) async {
    final remoteId = _resolveRemoteId(row);
    final localId = row.id.toString();
    final fullName = row.fullName.trim();
    final nationalId = row.idNumber.toString().trim();

    _log('[BeneficiaryUpload] current localId=$localId fileNumber=$fileNumber');

    final entity = BeneficiaryModel.fromDrift(row);
    final payload = BeneficiaryFirestoreMapper.toFirestore(
      entity,
      userId: userId,
      deviceId: deviceId,
      syncedAt: DateTime.now().toUtc(),
    );

    payload
      ..['id'] = remoteId
      ..['remoteId'] = remoteId
      ..['localId'] = localId
      ..['fileNumber'] = fileNumber
      ..['fileIdNumber'] = fileNumber
      ..['nationalId'] = nationalId
      ..['fullName'] = fullName
      ..['governorate'] = row.province?.toString()
      ..['city'] = row.city?.toString()
      ..['phone'] = row.phoneNumber.toString()
      ..['address'] = row.currentAddress
      ..['familyMembers'] = const <Map<String, dynamic>>[]
      ..['documents'] = const <Map<String, dynamic>>[]
      ..['bankAccounts'] = const <Map<String, dynamic>>[]
      ..['healthInfo'] = <String, dynamic>{'healthStatus': row.healthStatus}
      ..['housingInfo'] = <String, dynamic>{
        'housingStatus': row.housingStatus,
        'housingType': row.currentHousingType,
      }
      ..['incomeInfo'] = <String, dynamic>{
        'incomeSourceCode': row.incomeSourceCode,
      }
      ..['createdBy'] = userId
      ..['createdByEmail'] = userEmail
      ..['deviceId'] = deviceId
      ..['source'] = 'mobile_offline_app'
      ..['syncStatus'] = 'synced'
      ..['createdAtLocal'] = row.createdAt?.toIso8601String()
      ..['updatedAtLocal'] = row.updatedAt?.toIso8601String()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    _log('[BeneficiaryUpload] mapped payload keys=${payload.length}');
    await _firestore.collection('beneficiaries').doc(remoteId).set(payload, SetOptions(merge: true));
    _log('[BeneficiaryUpload] uploaded remoteId=$remoteId');
    return remoteId;
  }
}
