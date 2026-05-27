import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
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

    _log('[BeneficiaryUpload] started pending=${pending.length}');

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
        _log('[BeneficiaryUpload] file number confirmed fileNumber=$fileNumber');

        final uploadedAttachments = await _uploadPendingAttachmentsMetadata(
          localBeneficiaryId: localId,
          remoteBeneficiaryId: remoteId,
        );
        attachmentsUploaded += uploadedAttachments;

        await markBeneficiarySynced(localId: current.id, remoteId: remoteId);
        _log('[BeneficiaryUpload] marked local synced localId=$localId');

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
        _log('[BeneficiaryUpload] failed localId=$localId code=upload_failed message=$errorText');
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

    _log('[BeneficiaryUpload] completed uploaded=$uploaded failed=$failed skipped=$skipped');

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
