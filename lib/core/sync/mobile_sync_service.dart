import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:logger/logger.dart';

import 'package:benaa_offline_app/core/config/api_config.dart';
import '../../data/db/drift_database.dart';
import '../mappers/beneficiary_sync_mapper.dart' as mapper;
import '../mappers/visit_sync_mapper.dart' as visit_mapper;
import '../storage/secure_storage.dart';
import '../../features/sync/services/file_id_service.dart';
import '../../features/taxonomies/domain/repositories/taxonomy_repository.dart';

/// ========================================================================
/// 📱 Mobile Sync Service - للمزامنة مع Mobile Sync API
/// ========================================================================
/// هذا Service للمزامنة المؤقتة مع API الموبايل الموجود
/// الـ API بدون authentication ولا file upload لكن يسمح بمزامنة البيانات النصية
///
/// Base URL: https://palestine.benaadev.org
/// Database: u983550065_sy_test
///
/// ⚠️ LIMITATIONS:
/// - لا يوجد authentication (مؤقت)
/// - لا يوجد file upload (المرفقات ما بتنزامن)
/// - لا يوجد conflict resolution (server-wins)
/// - لا يوجد soft delete tracking
/// ========================================================================

class MobileSyncService {
  final AppDatabase _db;
  final Dio _dio;
  final SecureStorage _storage;
  final FileIdService? _fileIdService;
  final TaxonomyRepository? _taxonomyRepository;
  final Logger _logger = Logger();

  // Sync state
  final _statusController = StreamController<MobileSyncStatus>.broadcast();
  MobileSyncStatus _currentStatus = MobileSyncStatus();

  MobileSyncService(
    this._db,
    this._storage, {
    Dio? dio,
    FileIdService? fileIdService,
    TaxonomyRepository? taxonomyRepository,
  })  : _fileIdService = fileIdService,
        _taxonomyRepository = taxonomyRepository,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.defaultBaseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  Stream<MobileSyncStatus> get statusStream => _statusController.stream;
  MobileSyncStatus get currentStatus => _currentStatus;

  void _updateStatus(MobileSyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  // ========================================================================
  // 🔽 SYNC DOWN - تنزيل البيانات من السيرفر
  // ========================================================================

  /// مزامنة كاملة - تنزيل كل البيانات من السيرفر
  Future<MobileSyncResult> syncDown() async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري تنزيل البيانات من السيرفر...',
        progress: 0.0,
      ),
    );

    try {
      // 1. Sync Taxonomies (Lookups)
      if (_taxonomyRepository != null) {
        _logger.i('Syncing taxonomies...');
        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري تحديث القوائم والتصنيفات...',
            progress: 0.1,
          ),
        );
        try {
          await _taxonomyRepository.syncFromServer();
        } catch (e) {
          _logger.w('Taxonomy sync failed (non-critical): $e');
        }
      }

      // 2. Check File IDs
      if (_fileIdService != null) {
        _logger.i('Checking file ID reservation...');
        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري التحقق من مخزون الأرقام...',
            progress: 0.2,
          ),
        );
        try {
          await _fileIdService.ensureReservation();
        } catch (e) {
          _logger.w('File ID reservation failed (non-critical): $e');
        }
      }

      // Sync beneficiaries directly
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري تنزيل بيانات المستفيدين...',
          progress: 0.3,
        ),
      );

      final result = await _syncBeneficiariesDown();
      _logger.i('Synced ${result.recordsSynced} beneficiaries');

      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'تم تنزيل ${result.recordsSynced} مستفيد',
          progress: 1.0,
          isSyncing: false,
          lastSyncAt: DateTime.now(),
        ),
      );

      return result;
    } catch (e, stack) {
      _logger.e('Sync down failed', error: e, stackTrace: stack);

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );

      return MobileSyncResult(
        success: false,
        recordsSynced: 0,
        error: e.toString(),
      );
    }
  }

  /// مزامنة المستفيدين - تنزيل
  Future<MobileSyncResult> _syncBeneficiariesDown() async {
    int totalSynced = 0;
    int page = 1;
    const pageSize = 100; // Use pagination

    try {
      while (true) {
        // Fetch page using correct endpoint from ApiConfig
        final endpoint = ApiConfig.syncEndpoint;
        final fullUrl = '${_dio.options.baseUrl}$endpoint';

        _logger.i('Fetching page $page from: $fullUrl');

        final response = await _dio.get(
          endpoint,
          queryParameters: {
            'page': page,
            'per_page': pageSize,
            'order_by': 'id',
            'order_direction': 'ASC',
          },
        );

        _logger.i('✅ Response status: ${response.statusCode}');

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.data}');
        }

        final data = response.data as Map<String, dynamic>;
        final records = data['data'] as List<dynamic>;

        _logger.i('Received ${records.length} records on page $page');

        if (records.isEmpty) break;

        // Save to local database
        for (final record in records) {
          try {
            final companion = mapper.BeneficiaryMapper.fromBackend(
              record as Map<String, dynamic>,
            );

            // Check if exists by serverId
            final serverIdRaw = record['id'];
            final serverId =
                serverIdRaw is int ? serverIdRaw : (serverIdRaw != null ? int.tryParse(serverIdRaw.toString()) : null);
            if (serverId != null) {
              final existing = await (_db.select(
                _db.beneficiaries,
              )..where((b) => b.serverId.equals(serverId)))
                  .getSingleOrNull();

              if (existing != null) {
                // Update existing
                await (_db.update(
                  _db.beneficiaries,
                )..where((b) => b.id.equals(existing.id)))
                    .write(companion);
              } else {
                // Insert new
                await _db.into(_db.beneficiaries).insert(companion);
              }
            } else {
              // No serverId, just insert
              await _db.into(_db.beneficiaries).insert(companion);
            }

            totalSynced++;
          } catch (e) {
            _logger.w('Failed to sync record ${record['id']}: $e');
            // Continue with next record
          }
        }

        _logger.i('Page $page: ${records.length} records');

        // Check if more pages
        final pagination = data['pagination'] as Map<String, dynamic>?;
        if (pagination == null || pagination['current_page'] == pagination['last_page']) {
          break;
        }

        page++;
      }

      return MobileSyncResult(success: true, recordsSynced: totalSynced);
    } catch (e, stack) {
      _logger.e('Beneficiaries sync down failed', error: e, stackTrace: stack);
      return MobileSyncResult(
        success: false,
        recordsSynced: totalSynced,
        error: e.toString(),
      );
    }
  }

  // ========================================================================
  // 🔼 BATCH SYNC UP - رفع التغييرات المحلية مجمعة
  // ========================================================================

  /// رفع المستفيدين المحليين للسيرفر باستخدام الـ Batch API
  Future<MobileSyncResult> syncUp() async {
    _updateStatus(
      _currentStatus.copyWith(
        isSyncing: true,
        currentOperation: 'جاري رفع التغييرات (Batch Sync)...',
        progress: 0.0,
      ),
    );

    try {
      // Get local beneficiaries that need sync (pending or modified)
      final localBeneficiaries = await (_db.select(_db.beneficiaries)
            ..where(
              (b) => b.syncState.equals('pending') | b.syncState.equals('modified'),
            ))
          .get();

      final deviceId = await _storage.getDeviceId(); // 🆔 Get real device ID

      _logger.i('Found ${localBeneficiaries.length} beneficiaries to upload');

      if (localBeneficiaries.isEmpty) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: false,
            currentOperation: 'لا توجد تغييرات للرفع - جميع البيانات متزامنة ✓',
          ),
        );

        return MobileSyncResult(success: true, recordsSynced: 0);
      }

      // Process in batches
      final batchSize = ApiConfig.batchSize;
      int uploaded = 0;
      int failed = 0;

      for (int i = 0; i < localBeneficiaries.length; i += batchSize) {
        final end = (i + batchSize < localBeneficiaries.length) ? i + batchSize : localBeneficiaries.length;
        final batch = localBeneficiaries.sublist(i, end);

        _updateStatus(
          _currentStatus.copyWith(
            currentOperation: 'جاري رفع الدفعة ${(i ~/ batchSize) + 1}...',
            progress: (i + batch.length) / localBeneficiaries.length,
          ),
        );

        try {
          // Convert batch to backend format
          final dataList = batch.map((b) => mapper.BeneficiaryMapper.toBackend(b)).toList();

          final response = await _dio.post(
            ApiConfig.batchDataSyncEndpoint,
            data: {
              'records': dataList,
              'device_id': deviceId, // ✅ Using real device ID
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Mark these records as synced in DB
            final ids = batch.map((b) => b.id).toList();
            await (_db.update(_db.beneficiaries)..where((b) => b.id.isIn(ids))).write(
              BeneficiariesCompanion(
                syncState: const drift.Value('synced'),
                lastSyncedAt: drift.Value(DateTime.now()),
              ),
            );

            uploaded += batch.length;
            _logger.i('✅ Synced batch of ${batch.length} records');
          } else {
            failed += batch.length;
            _logger.w('❌ Sync batch failed: ${response.data}');
          }
        } catch (e) {
          failed += batch.length;
          _logger.e('Error syncing batch', error: e);
        }
      }

      // 1.5️⃣ Upload Visits
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري رفع الزيارات...',
          progress: 0.6,
        ),
      );

      final visitsResult = await _syncVisitsUp(deviceId);
      uploaded += visitsResult.recordsSynced;
      failed += visitsResult.recordsFailed;

      // 2️⃣ Upload Attachments
      _updateStatus(
        _currentStatus.copyWith(
          currentOperation: 'جاري رفع المرفقات...',
          progress: 0.8,
        ),
      );

      final attachmentResult = await _syncAttachmentsUp(deviceId);
      uploaded += attachmentResult.recordsSynced;
      failed += attachmentResult.recordsFailed;

      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: false,
          currentOperation: failed > 0 ? 'تم رفع $uploaded سجل (فشل $failed)' : 'تم رفع $uploaded سجل بنجاح ✓',
          progress: 1.0,
          lastSyncAt: DateTime.now(),
        ),
      );

      return MobileSyncResult(
        success: failed == 0,
        recordsSynced: uploaded,
        recordsFailed: failed,
      );
    } catch (e, stack) {
      _logger.e('Sync up failed', error: e, stackTrace: stack);
      _updateStatus(_currentStatus.copyWith(isSyncing: false, lastError: e.toString()));
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  /// مزامنة المرفقات محلية الرفع للسيرفر
  Future<MobileSyncResult> _syncAttachmentsUp(String deviceId) async {
    int uploaded = 0;
    int failedCount = 0;

    try {
      final pendingAttachments = await _db.attachmentsDao.getPendingAttachments();
      _logger.i('Found ${pendingAttachments.length} attachments to upload');

      for (final attachment in pendingAttachments) {
        try {
          final file = File(attachment.filePath);
          if (!await file.exists()) {
            _logger.w('File not found: ${attachment.filePath}');
            failedCount++;
            continue;
          }

          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(file.path, filename: attachment.fileName),
            'entity_type': 'beneficiary',
            'entity_id': attachment.beneficiaryId,
            'device_id': deviceId,
            'document_type': attachment.documentType,
            'notes': attachment.notes,
          });

          final response = await _dio.post(
            ApiConfig.attachmentUploadEndpoint,
            data: formData,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final serverUrl = response.data['url'] as String?;
            await _db.attachmentsDao.updateAttachmentSyncState(
              attachment.id,
              'synced',
              serverUrl: serverUrl,
            );
            uploaded++;
          } else {
            failedCount++;
            _logger.w('Failed to upload attachment ${attachment.id}: ${response.statusCode}');
          }
        } catch (e) {
          _logger.w('Error uploading attachment ${attachment.id}: $e');
          failedCount++;
        }
      }

      return MobileSyncResult(
        success: failedCount == 0,
        recordsSynced: uploaded,
        recordsFailed: failedCount,
      );
    } catch (e) {
      _logger.e('Attachments sync up failed', error: e);
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  /// مزامنة الزيارات محلية الرفع للسيرفر
  Future<MobileSyncResult> _syncVisitsUp(String deviceId) async {
    int uploaded = 0;
    int failedCount = 0;

    try {
      final pendingVisits = await _db.visitsDao.getPendingVisits();
      _logger.i('Found ${pendingVisits.length} visits to upload');

      if (pendingVisits.isEmpty) {
        return MobileSyncResult(success: true, recordsSynced: 0);
      }

      // Process in batches
      final batchSize = ApiConfig.batchSize;
      for (int i = 0; i < pendingVisits.length; i += batchSize) {
        final end = (i + batchSize < pendingVisits.length) ? i + batchSize : pendingVisits.length;
        final batch = pendingVisits.sublist(i, end);
        final dataList = batch.map(visit_mapper.VisitSyncMapper.toBackend).toList();

        try {
          final response = await _dio.post(
            ApiConfig.visitsBatchSyncEndpoint,
            data: {
              'records': dataList,
              'device_id': deviceId,
            },
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final results = response.data['results'] as List?;
            if (results != null) {
              for (var res in results) {
                final localId = res['local_id']?.toString();
                final serverId = res['id']?.toString();
                if (localId != null && serverId != null) {
                  await _db.visitsDao.updateVisitSyncStatus(localId, serverId);
                  uploaded++;
                }
              }
            }
          } else {
            failedCount += batch.length;
            _logger.w('❌ Visits sync batch failed: ${response.statusCode}');
          }
        } catch (e) {
          failedCount += batch.length;
          _logger.e('Error syncing visits batch', error: e);
        }
      }

      return MobileSyncResult(
        success: failedCount == 0,
        recordsSynced: uploaded,
        recordsFailed: failedCount,
      );
    } catch (e) {
      _logger.e('Visits sync up failed', error: e);
      return MobileSyncResult(success: false, recordsSynced: 0, error: e.toString());
    }
  }

  // ========================================================================
  // 📊 CLEANUP
  // ========================================================================

  /// Dispose
  void dispose() {
    _statusController.close();
  }
}

// ========================================================================
// 📦 DATA MODELS
// ========================================================================

/// Mobile Sync Status
class MobileSyncStatus {
  final bool isSyncing;
  final String currentOperation;
  final double progress;
  final DateTime? lastSyncAt;
  final String? lastError;

  MobileSyncStatus({
    this.isSyncing = false,
    this.currentOperation = 'جاهز',
    this.progress = 0.0,
    this.lastSyncAt,
    this.lastError,
  });

  MobileSyncStatus copyWith({
    bool? isSyncing,
    String? currentOperation,
    double? progress,
    DateTime? lastSyncAt,
    String? lastError,
  }) {
    return MobileSyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      currentOperation: currentOperation ?? this.currentOperation,
      progress: progress ?? this.progress,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
    );
  }
}

/// Mobile Sync Result
class MobileSyncResult {
  final bool success;
  final int recordsSynced;
  final int recordsFailed;
  final String? error;

  MobileSyncResult({
    required this.success,
    required this.recordsSynced,
    this.recordsFailed = 0,
    this.error,
  });
}
