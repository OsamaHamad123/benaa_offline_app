import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../../data/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../providers/providers.dart';
import '../backend/backend_provider.dart';
import '../backend/remote_backend.dart';
import '../mappers/beneficiary_sync_mapper.dart';
import '../mappers/visit_sync_mapper.dart';
import '../utils/batch_operations.dart';
import '../notifications/notifications_service.dart';

// Provider للـ SyncManager
final syncManagerProvider = Provider<SyncManager>((ref) {
  final database = ref.watch(databaseProvider);
  final backend = ref.watch(remoteBackendProvider);
  return SyncManager(database, remoteBackend: backend);
});

// Provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.statusStream;
});

// حالة المزامنة
class SyncStatus {
  final bool isSyncing;
  final int totalItems;
  final int completedItems;
  final String? currentEntity;
  final String? lastError;

  SyncStatus({
    this.isSyncing = false,
    this.totalItems = 0,
    this.completedItems = 0,
    this.currentEntity,
    this.lastError,
  });

  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;

  SyncStatus copyWith({
    bool? isSyncing,
    int? totalItems,
    int? completedItems,
    String? currentEntity,
    String? lastError,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
      currentEntity: currentEntity ?? this.currentEntity,
      lastError: lastError ?? this.lastError,
    );
  }
}

// أولويات المزامنة
class SyncPriority {
  static const int auth = 10;
  static const int beneficiary = 9;
  static const int visit = 8;
  static const int attachment = 7;
  static const int taxonomy = 6;
}

// مدير المزامنة
class SyncManager {
  final AppDatabase _db;
  final RemoteBackend _remoteBackend;
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _uuid = const Uuid();

  Timer? _autoSyncTimer;
  SyncStatus _currentStatus = SyncStatus();
  bool _wasSyncingForNotification = false;
  int _lastSyncProgressNotification = -1;
  String _lastSyncEntityNotification = '';
  static const int _maxAttachmentBytes = 10 * 1024 * 1024; // 10 MB
  static const bool _deleteLocalAfterUpload = false;

  SyncManager(this._db, {required RemoteBackend remoteBackend}) : _remoteBackend = remoteBackend {
    _startAutoSync();
  }

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get currentStatus => _currentStatus;

  // بدء المزامنة التلقائية كل 5 دقائق
  void _startAutoSync() {
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );
  }

  // إيقاف المزامنة التلقائية
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  // تحديث الحالة
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
    _emitQueueSyncNotification(status);
  }

  void _emitQueueSyncNotification(SyncStatus status) {
    if (status.isSyncing) {
      final progressPercent =
          status.totalItems > 0 ? ((status.completedItems / status.totalItems) * 100).clamp(0, 100).round() : 0;
      final entityLabel = status.currentEntity?.trim() ?? '';

      if (progressPercent != _lastSyncProgressNotification || entityLabel != _lastSyncEntityNotification) {
        _lastSyncProgressNotification = progressPercent;
        _lastSyncEntityNotification = entityLabel;
        unawaited(
          NotificationsService.showSyncOperationProgress(
            operationLabel: entityLabel.isEmpty ? 'جاري مزامنة البيانات...' : 'جاري مزامنة: $entityLabel',
            percentage: progressPercent.toDouble(),
          ),
        );
      }

      _wasSyncingForNotification = true;
      return;
    }

    if (!_wasSyncingForNotification) {
      return;
    }

    final error = status.lastError?.trim();
    if (error != null && error.isNotEmpty) {
      unawaited(NotificationsService.showSyncOperationFailed(error));
    } else {
      unawaited(
        NotificationsService.showSyncOperationCompleted(
          summary: 'تمت مزامنة ${status.completedItems} عنصر بنجاح.',
        ),
      );
    }

    _wasSyncingForNotification = false;
    _lastSyncProgressNotification = -1;
    _lastSyncEntityNotification = '';
  }

  // ============================================================================
  // ADD TO SYNC QUEUE - إضافة للطابور
  // ============================================================================

  // إضافة مستفيد للمزامنة
  Future<void> queueBeneficiary(
    String beneficiaryId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    await _db.syncDao.addToSyncQueue(
      SyncQueueCompanion(
        id: drift.Value(_uuid.v4()),
        entity: const drift.Value('beneficiary'),
        entityId: drift.Value(beneficiaryId),
        operation: drift.Value(operation),
        payload: drift.Value(jsonEncode(data)),
        priority: const drift.Value(SyncPriority.beneficiary),
        createdAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // إضافة زيارة للمزامنة
  Future<void> queueVisit(
    String visitId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    await _db.syncDao.addToSyncQueue(
      SyncQueueCompanion(
        id: drift.Value(_uuid.v4()),
        entity: const drift.Value('visit'),
        entityId: drift.Value(visitId),
        operation: drift.Value(operation),
        payload: drift.Value(jsonEncode(data)),
        priority: const drift.Value(SyncPriority.visit),
        createdAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // إضافة مرفق للمزامنة
  Future<void> queueAttachment(
    String attachmentId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    await _db.syncDao.addToSyncQueue(
      SyncQueueCompanion(
        id: drift.Value(_uuid.v4()),
        entity: const drift.Value('attachment'),
        entityId: drift.Value(attachmentId),
        operation: drift.Value(operation),
        payload: drift.Value(jsonEncode(data)),
        priority: const drift.Value(SyncPriority.attachment),
        createdAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // SYNC EXECUTION - تنفيذ المزامنة
  // ============================================================================

  // مزامنة الكل
  Future<void> syncAll() async {
    // تحقق من الاتصال بالإنترنت
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _updateStatus(
        _currentStatus.copyWith(lastError: 'لا يوجد اتصال بالإنترنت'),
      );
      return;
    }

    _updateStatus(_currentStatus.copyWith(isSyncing: true));

    try {
      await _remoteBackend.initialize();

      // جلب قائمة المزامنة مرتبة حسب الأولوية
      final items = await _db.syncDao.getSyncQueue();

      _updateStatus(
        _currentStatus.copyWith(totalItems: items.length, completedItems: 0),
      );

      // استخدام BatchDatabaseHelper لمعالجة العمليات بكفاءة
      int processedCount = 0;
      await BatchDatabaseHelper.batchUpdate(
        items,
        (item) async {
          _updateStatus(
            _currentStatus.copyWith(
              currentEntity: item.entity,
              completedItems: processedCount++,
            ),
          );

          try {
            // تنفيذ المزامنة حسب نوع الكيان
            await _syncItem(item);

            // حذف من الطابور بعد النجاح
            await _db.syncDao.removeFromSyncQueue(item.id);
          } catch (e) {
            // تحديث عدد المحاولات والخطأ
            final nextAttempts = item.attempts + 1;
            final retryDelayMinutes = 1 << (nextAttempts.clamp(1, 6)); // 2,4,8,16,32,64
            final scheduledAt = DateTime.now().add(Duration(minutes: retryDelayMinutes));

            await _db.syncDao.updateSyncQueueRetry(
              id: item.id,
              error: e.toString(),
              attempts: nextAttempts,
              scheduledAt: scheduledAt,
            );
          }
        },
        batchSize: 10, // معالجة 10 عناصر في كل دفعة
      );

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, completedItems: items.length),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
    }
  }

  // مزامنة عنصر واحد
  Future<void> _syncItem(SyncQueueItem item) async {
    final data = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.entity) {
      case 'beneficiary':
        await _syncBeneficiary(item.entityId, item.operation, data);
        break;
      case 'visit':
        await _syncVisit(item.entityId, item.operation, data);
        break;
      case 'attachment':
        await _syncAttachment(item.entityId, item.operation, data);
        break;
      default:
        throw Exception('Unknown entity type: ${item.entity}');
    }
  }

  // مزامنة مستفيد
  Future<void> _syncBeneficiary(
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      // Convert String id to int for database lookup
      final intId = int.tryParse(id);
      if (intId == null) {
        throw Exception('Invalid beneficiary ID: $id');
      }

      // Convert local data to backend format
      final beneficiary = await _db.beneficiariesDao.getBeneficiaryById(intId);
      if (beneficiary == null) {
        throw Exception('Beneficiary not found: $id');
      }

      final backendData = BeneficiaryMapper.toBackend(beneficiary);

      // create/update are both handled as upsert in remote backend
      await _remoteBackend.upsertBeneficiary(backendData);

      final now = DateTime.now();
      await (_db.update(_db.beneficiaries)..where((b) => b.id.equals(intId))).write(
        BeneficiariesCompanion(
          syncState: const drift.Value('synced'),
          lastSyncedAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
    } catch (e) {
      throw Exception('Failed to sync beneficiary: $e');
    }
  }

  // مزامنة زيارة
  Future<void> _syncVisit(
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    final visit = await _db.visitsDao.getVisitById(id);
    if (visit == null) {
      throw Exception('Visit not found: $id');
    }

    final backendData = VisitSyncMapper.toBackend(visit);
    final beneficiaryId = visit.beneficiaryId.trim();
    if (beneficiaryId.isEmpty) {
      throw Exception('Visit beneficiary id is missing: $id');
    }

    await _remoteBackend.upsertVisit(beneficiaryId, backendData);
    await _db.visitsDao.updateVisitSyncStatus(id, visit.serverId ?? visit.id);
  }

  // مزامنة مرفق
  Future<void> _syncAttachment(
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    _AttachmentUploadPreparation? preparation;

    final attachment = await _db.attachmentsDao.getAttachment(id);
    if (attachment == null) {
      throw Exception('Attachment not found: $id');
    }

    final beneficiaryId = attachment.beneficiaryId.trim();
    if (beneficiaryId.isEmpty) {
      throw Exception('Attachment beneficiary id is missing: $id');
    }

    final file = File(attachment.filePath);
    if (!await file.exists()) {
      throw Exception('Attachment file does not exist: ${attachment.filePath}');
    }

    final normalizedType = attachment.type.trim().toLowerCase();
    if (normalizedType != 'image' && normalizedType != 'pdf') {
      throw Exception('Unsupported attachment type for sync: ${attachment.type}. Only image/pdf are allowed.');
    }

    try {
      preparation = await _prepareAttachmentForUpload(
        attachmentId: attachment.id,
        attachmentType: normalizedType,
        originalFile: file,
      );

      if (preparation.uploadFileSizeBytes > _maxAttachmentBytes) {
        throw Exception('Attachment exceeds max size (${_maxAttachmentBytes ~/ (1024 * 1024)} MB).');
      }

      // Rule: upload binary to storage first, then persist metadata in Firestore.
      final uploadedUrl = await _remoteBackend.uploadAttachment(
        beneficiaryId,
        preparation.uploadPath,
        preparation.storageFileName,
        preparation.contentType,
      );

      if (uploadedUrl == null || uploadedUrl.trim().isEmpty) {
        throw Exception('Attachment upload returned empty URL for: $id');
      }

      final metadata = <String, dynamic>{
        'id': attachment.id,
        'beneficiary_id': attachment.beneficiaryId,
        'visit_id': attachment.visitId,
        'file_name': attachment.fileName,
        'file_path': attachment.filePath,
        'file_type': attachment.type,
        'file_size': preparation.uploadFileSizeBytes,
        'thumbnail_path': attachment.thumbnailPath,
        'document_type': attachment.documentType,
        'person_type': attachment.personType,
        'person_id': attachment.personId,
        'notes': attachment.notes,
        'server_url': uploadedUrl,
        'download_url': uploadedUrl,
        'created_at': attachment.createdAt,
        'updated_at': DateTime.now(),
      };

      await _remoteBackend.upsertAttachmentMetadata(beneficiaryId, metadata);
      await _db.attachmentsDao.updateAttachmentSyncState(
        id,
        'synced',
        serverUrl: uploadedUrl,
      );
      await _db.customStatement(
        '''
        INSERT INTO attachments_contract_fields (
          attachment_id,
          download_url,
          updated_at
        ) VALUES (?, ?, ?)
        ON CONFLICT(attachment_id) DO UPDATE SET
          download_url = excluded.download_url,
          updated_at = excluded.updated_at
        ''',
        [
          attachment.id,
          uploadedUrl,
          DateTime.now().toIso8601String(),
        ],
      );

      if (_deleteLocalAfterUpload) {
        try {
          await file.delete();
        } catch (_) {
          // Non-blocking cleanup when explicitly enabled.
        }
      }
    } catch (e) {
      await _db.attachmentsDao.updateAttachmentSyncState(
        id,
        'failed',
      );
      throw Exception('Attachment upload failed for $id: $e');
    } finally {
      if (preparation?.isTemporary == true && preparation?.uploadPath != null) {
        try {
          final temp = File(preparation!.uploadPath);
          if (await temp.exists()) {
            await temp.delete();
          }
        } catch (_) {
          // Ignore temp cleanup failures.
        }
      }
    }
  }

  Future<_AttachmentUploadPreparation> _prepareAttachmentForUpload({
    required String attachmentId,
    required String attachmentType,
    required File originalFile,
  }) async {
    final safeOriginalName = path.basename(originalFile.path).replaceAll('/', '_').replaceAll('\\', '_');
    final storageFileName = '${attachmentId}_$safeOriginalName';

    if (attachmentType == 'pdf') {
      return _AttachmentUploadPreparation(
        uploadPath: originalFile.path,
        storageFileName: storageFileName,
        contentType: 'application/pdf',
        uploadFileSizeBytes: await originalFile.length(),
        isTemporary: false,
      );
    }

    // image: try compression first and use compressed file if available.
    final compressedPath = path.join(
      Directory.systemTemp.path,
      'benaa_sync_${attachmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      compressedPath,
      quality: 82,
      minHeight: 1920,
      minWidth: 1920,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      return _AttachmentUploadPreparation(
        uploadPath: originalFile.path,
        storageFileName: storageFileName,
        contentType: 'image/jpeg',
        uploadFileSizeBytes: await originalFile.length(),
        isTemporary: false,
      );
    }

    final compressedSize = await File(compressedFile.path).length();
    return _AttachmentUploadPreparation(
      uploadPath: compressedFile.path,
      storageFileName: storageFileName,
      contentType: 'image/jpeg',
      uploadFileSizeBytes: compressedSize,
      isTemporary: true,
    );
  }

  // ============================================================================
  // PULL FROM SERVER - جلب من السيرفر
  // ============================================================================

  // مزامنة المستفيدين من السيرفر (Pull)
  Future<int> pullBeneficiariesFromServer({DateTime? updatedAfter}) async {
    try {
      // جلب البيانات من السيرفر
      final beneficiariesData = await _remoteBackend.pullUpdatedBeneficiaries(since: updatedAfter);

      int insertedCount = 0;

      // استخدام BatchDatabaseHelper لمعالجة البيانات بكفاءة
      await BatchDatabaseHelper.batchInsert(
        beneficiariesData,
        (item) async {
          try {
            // تحويل من Backend JSON إلى Data Model ثم إلى Drift Companion
            final beneficiaryCompanion = BeneficiaryMapper.fromBackend(item);

            // البحث عن مستفيد موجود بنفس الـ serverId
            final serverId = item['id'] is int ? item['id'] as int : int.tryParse(item['id']?.toString() ?? '');
            if (serverId != null) {
              final existing = await _db.beneficiariesDao.getBeneficiaryByServerId(serverId);

              if (existing != null) {
                // تحديث الموجود
                await _db.beneficiariesDao.updateBeneficiaryCompanion(
                  existing.id,
                  beneficiaryCompanion,
                );
              } else {
                // إدراج جديد
                await _db.beneficiariesDao.insertBeneficiary(
                  beneficiaryCompanion,
                );
                insertedCount++;
              }
            } else {
              // إدراج جديد (بدون serverId)
              await _db.beneficiariesDao.insertBeneficiary(beneficiaryCompanion);
              insertedCount++;
            }
          } catch (e) {
            // تسجيل الخطأ والمتابعة
            debugPrint('Error processing beneficiary: $e');
          }
        },
        // معالجة 50 مستفيد في كل دفعة
      );

      return insertedCount;
    } catch (e) {
      throw Exception('Failed to pull beneficiaries from server: $e');
    }
  }

  // مزامنة التصنيفات من السيرفر
  Future<void> syncTaxonomiesFromServer() async {
    try {
      // TODO: Implement actual API call
      // final response = await _apiClient.get('/taxonomies');
      // final items = (response.data as List).map((item) {
      //   return TaxonomiesCompanion(
      //     id: drift.Value(item['id']),
      //     group: drift.Value(item['group']),
      //     code: drift.Value(item['code']),
      //     label: drift.Value(item['label']),
      //     parentId: drift.Value(item['parent_id']),
      //     sortOrder: drift.Value(item['sort_order']),
      //     isActive: drift.Value(item['is_active']),
      //     updatedAt: drift.Value(DateTime.parse(item['updated_at'])),
      //   );
      // }).toList();

      // await _db.syncTaxonomies(items);

      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to sync taxonomies: $e');
    }
  }

  // Dispose
  void dispose() {
    _autoSyncTimer?.cancel();
    _statusController.close();
  }
}

class _AttachmentUploadPreparation {
  const _AttachmentUploadPreparation({
    required this.uploadPath,
    required this.storageFileName,
    required this.contentType,
    required this.uploadFileSizeBytes,
    required this.isTemporary,
  });

  final String uploadPath;
  final String storageFileName;
  final String contentType;
  final int uploadFileSizeBytes;
  final bool isTemporary;
}
