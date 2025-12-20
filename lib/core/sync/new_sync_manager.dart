import 'package:benaa_offline_app/core/utils/unified_logger.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:device_info_plus/device_info_plus.dart'; // سيتم تفعيلها لاحقاً
import '../../data/api/sync_api_client.dart';
import '../../data/dto/sync_dto.dart';
import '../../data/db/drift_database.dart';
import '../storage/secure_storage.dart';
import '../config/api_config.dart';
import '../utils/family_enums.dart';
import 'background_sync_worker.dart';
import 'package:drift/drift.dart' as drift;

/// 🔄 Sync Manager - مدير المزامنة الرئيسي
///
/// يتولى:
/// - مزامنة البيانات مع السيرفر
/// - إدارة قائمة التغييرات المعلقة
/// - معالجة التعارضات
/// - إدارة حالة المزامنة
class NewSyncManager {
  static final NewSyncManager _instance = NewSyncManager._internal();
  factory NewSyncManager() => _instance;
  NewSyncManager._internal();

  late final SyncApiClient _apiClient;
  late final AppDatabase _db;
  final _storage = SecureStorage();

  final _syncStatusNotifier = SyncStatusNotifier();
  SyncStatusNotifier get statusNotifier => _syncStatusNotifier;

  bool _isInitialized = false;
  bool _isSyncing = false;

  // ===========================
  // 🔧 INITIALIZATION
  // ===========================

  /// ✅ تهيئة SyncManager (يُستدعى بعد تسجيل الدخول)
  Future<void> initialize(AppDatabase database) async {
    if (_isInitialized) return;

    _db = database;

    // الحصول على البيانات المحفوظة
    final token = await _storage.getAuthToken();
    final serverUrl = await _storage.getServerUrl() ?? ApiConfig.defaultBaseUrl;

    if (token == null) {
      throw Exception('لم يتم تسجيل الدخول');
    }

    _apiClient = SyncApiClient(baseUrl: serverUrl, authToken: token);

    _isInitialized = true;
    UnifiedLogger.success('✅ NewSyncManager initialized');
  }

  // ===========================
  // 🔄 SYNC OPERATIONS
  // ===========================

  /// 🔄 مزامنة كاملة
  Future<bool> syncAll() async {
    if (_isSyncing) {
      UnifiedLogger.warning('⚠️ Sync already in progress');
      return false;
    }

    if (!_isInitialized) {
      UnifiedLogger.warning('⚠️ SyncManager not initialized');
      return false;
    }

    _isSyncing = true;

    try {
      _syncStatusNotifier.startSync();
      UnifiedLogger.info('🔄 Starting full sync...');

      final startTime = DateTime.now();

      // 1️⃣ جمع التغييرات المعلقة
      final pendingChanges = await _collectPendingChanges();
      _syncStatusNotifier.updatePendingItems(pendingChanges.length);

      if (pendingChanges.isEmpty) {
        UnifiedLogger.info('ℹ️ No pending changes to sync');
      } else {
        UnifiedLogger.info('📦 Found ${pendingChanges.length} pending changes');
      }

      // 2️⃣ إعداد طلب المزامنة
      final request = SyncRequestDto(
        lastSyncTime: await _storage.getLastSyncTime(),
        pendingChanges: pendingChanges,
        deviceInfo: await _getDeviceInfo(),
        userId: await _storage.getUserId() ?? '',
      );

      // 3️⃣ إرسال للسيرفر
      final response = await _apiClient.syncData(request);

      if (!response.success) {
        throw Exception(response.message ?? 'Sync failed');
      }

      // 4️⃣ تطبيق التحديثات من السيرفر
      await _applyServerUpdates(response);

      // 5️⃣ حذف التغييرات المعلقة الناجحة
      await _clearSuccessfulChanges(pendingChanges, response.failedChanges);

      // 6️⃣ حفظ وقت المزامنة
      await _storage.saveLastSyncTime(response.serverTimestamp);

      final duration = DateTime.now().difference(startTime);

      _syncStatusNotifier.completeSync(
        pendingItems: response.failedChanges?.length ?? 0,
      );

      UnifiedLogger.success(
        '✅ Sync completed successfully in ${duration.inSeconds}s',
      );

      if (response.stats != null) {
        UnifiedLogger.info(
          '📊 Stats: Received=${response.stats!.receivedCount}, '
          'Sent=${response.stats!.sentCount}, '
          'Failed=${response.stats!.failedCount}',
        );
      }

      return true;
    } catch (e) {
      UnifiedLogger.error('❌ Sync failed', error: e);
      _syncStatusNotifier.failSync(e.toString());
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// 📝 جمع التغييرات المعلقة من قاعدة البيانات
  Future<List<PendingChangeDto>> _collectPendingChanges() async {
    final changes = <PendingChangeDto>[];

    try {
      // جمع من جدول sync_queue
      final pendingRows = await (_db.select(_db.syncQueue)
            ..orderBy([
              (t) => drift.OrderingTerm(
                    expression: t.priority,
                    mode: drift.OrderingMode.desc,
                  ),
              (t) => drift.OrderingTerm(expression: t.createdAt),
            ]))
          .get();

      for (final row in pendingRows) {
        // تحويل البيانات من JSON string إلى Map
        Map<String, dynamic> data = {};
        try {
          // payload قد يكون JSON string
          if (row.payload.isNotEmpty) {
            // استخدم البيانات مباشرة أو حاول parse-ها
            data.addAll({'raw': row.payload});
          }
        } catch (e) {
          UnifiedLogger.warning('⚠️ Failed to parse payload for ${row.id}');
        }

        // 🔄 تحويل البيانات من Local Integer إلى API String/Text
        if (row.entity == 'family_deceased') {
          data = _familyDeceasedToApi(data);
        } else if (row.entity == 'family_member') {
          data = _familyMemberToApi(data);
        }

        changes.add(
          PendingChangeDto(
            entityType: row.entity,
            entityId: row.entityId,
            operation: row.operation,
            data: data,
            timestamp: row.createdAt,
            priority: row.priority,
            retryCount: row.attempts,
          ),
        );
      }

      return changes;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to collect pending changes', error: e);
      return [];
    }
  }

  /// 📥 تطبيق التحديثات من السيرفر
  Future<void> _applyServerUpdates(SyncResponseDto response) async {
    try {
      UnifiedLogger.info(
        '📥 Applying ${response.updatedData.length} server updates...',
      );

      for (final entity in response.updatedData) {
        switch (entity.entityType) {
          case 'beneficiary':
            await _updateBeneficiary(entity);
            break;

          case 'visit':
            await _updateVisit(entity);
            break;

          case 'attachment':
            await _updateAttachment(entity);
            break;

          case 'taxonomy':
            await _updateTaxonomy(entity);
            break;

          case 'family_deceased':
            await _updateFamilyDeceased(entity);
            break;

          case 'family_member':
            await _updateFamilyMember(entity);
            break;

          default:
            UnifiedLogger.warning(
                '⚠️ Unknown entity type: ${entity.entityType}');
        }
      }

      // حذف البيانات المحذوفة على السيرفر
      if (response.deletedIds.isNotEmpty) {
        UnifiedLogger.info(
          '🗑️ Processing ${response.deletedIds.length} deletions...',
        );
        await _processDeletedItems(response.deletedIds);
      }

      UnifiedLogger.success('✅ Server updates applied successfully');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to apply server updates', error: e);
      rethrow;
    }
  }

  /// 🔄 تحديث مستفيد
  Future<void> _updateBeneficiary(ServerEntityDto entity) async {
    // TODO: Implement beneficiary update
    // Note: Schema uses IntColumn for id, needs mapping from server String IDs
    UnifiedLogger.info(
      '⏭️ Beneficiary update not fully implemented yet - ID: ${entity.id}',
    );
  }

  /// 🔄 تحديث زيارة
  Future<void> _updateVisit(ServerEntityDto entity) async {
    // TODO: Implement visit update
    UnifiedLogger.info('⏭️ Visit update not implemented yet');
  }

  /// 🔄 تحديث مرفق
  Future<void> _updateAttachment(ServerEntityDto entity) async {
    // TODO: Implement attachment update
    UnifiedLogger.info('⏭️ Attachment update not implemented yet');
  }

  /// 🔄 تحديث taxonomy
  Future<void> _updateTaxonomy(ServerEntityDto entity) async {
    // TODO: Implement taxonomy update
    UnifiedLogger.info('⏭️ Taxonomy update not implemented yet');
  }

  /// 🔄 تحديث فرد متوفى
  Future<void> _updateFamilyDeceased(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final serverId = int.tryParse(entity.id);

      if (serverId == null) {
        UnifiedLogger.warning(
          '⚠️ Invalid family_deceased server ID: ${entity.id}',
        );
        return;
      }

      // تحويل من String/Text (API) إلى Integer (Local)
      final deceasedTypeStr = data['deceased_type'] as String? ?? 'father';
      final deceasedTypeInt = DeceasedType.fromEnglish(deceasedTypeStr);

      final deathCauseStr = data['death_cause'] as String? ?? 'غير معروف';
      final deathCauseInt = DeathCause.fromArabic(deathCauseStr);

      final documentTypeStr = data['document_type'] as String?;
      final documentTypeInt = documentTypeStr != null ? DocumentType.fromArabic(documentTypeStr) : null;

      // تحويل nationalId إذا كان نص إلى رقم
      final nationalIdRaw = data['national_id'];
      final nationalIdInt = nationalIdRaw is String ? (int.tryParse(nationalIdRaw) ?? 0) : (nationalIdRaw as int? ?? 0);

      final companion = FamilyDeceasedTableCompanion(
        id: drift.Value(serverId),
        beneficiaryId: drift.Value(data['beneficiary_id'] as int),
        deceasedType: drift.Value(deceasedTypeInt),
        firstName: drift.Value(data['first_name'] as String? ?? ''),
        secondName: drift.Value(data['second_name'] as String?),
        thirdName: drift.Value(data['third_name'] as String?),
        familyName: drift.Value(data['family_name'] as String? ?? ''),
        nationalId: drift.Value(nationalIdInt),
        deathDate:
            data['death_date'] != null ? drift.Value(DateTime.parse(data['death_date'])) : drift.Value(DateTime.now()),
        deathCause: drift.Value(deathCauseInt),
        documentType: drift.Value(documentTypeInt),
        documentPath: drift.Value(data['document_path'] as String?),
        notes: drift.Value(data['notes'] as String?),
        syncState: const drift.Value('synced'),
        serverId: drift.Value(serverId),
        lastSyncedAt: drift.Value(DateTime.now()),
        createdAt:
            data['created_at'] != null ? drift.Value(DateTime.parse(data['created_at'])) : drift.Value(DateTime.now()),
        updatedAt:
            data['updated_at'] != null ? drift.Value(DateTime.parse(data['updated_at'])) : drift.Value(DateTime.now()),
      );

      await _db.into(_db.familyDeceasedTable).insertOnConflictUpdate(companion);
      UnifiedLogger.info('✅ Updated family_deceased: ${entity.id}');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update family_deceased', error: e);
    }
  }

  /// 🔄 تحديث فرد من العائلة
  Future<void> _updateFamilyMember(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final serverId = int.tryParse(entity.id);

      if (serverId == null) {
        UnifiedLogger.warning(
            '⚠️ Invalid family_member server ID: ${entity.id}');
        return;
      }

      // تحويل من String/Text (API) إلى Integer (Local)
      final genderStr = data['gender'] as String? ?? 'male';
      final genderInt = Gender.fromEnglish(genderStr);

      final healthStatusStr = data['health_status'] as String? ?? 'غير معروف';
      final healthStatusInt = HealthStatus.fromArabic(healthStatusStr);

      // تحويل orphan_national_id إذا كان نص إلى رقم
      final orphanNationalIdRaw = data['orphan_national_id'];
      final orphanNationalIdInt =
          orphanNationalIdRaw is String ? (int.tryParse(orphanNationalIdRaw) ?? 0) : (orphanNationalIdRaw as int? ?? 0);

      final companion = FamilyMembersTableCompanion(
        id: drift.Value(serverId),
        beneficiaryId: drift.Value(data['beneficiary_id'] as int),
        orphanNationalId: drift.Value(orphanNationalIdInt),
        firstName: drift.Value(data['first_name'] as String? ?? ''),
        secondName: drift.Value(data['second_name'] as String?),
        thirdName: drift.Value(data['third_name'] as String?),
        familyName: drift.Value(data['family_name'] as String? ?? ''),
        birthDate:
            data['birth_date'] != null ? drift.Value(DateTime.parse(data['birth_date'])) : drift.Value(DateTime.now()),
        age: drift.Value(data['age'] as int?),
        gender: drift.Value(genderInt),
        healthStatus: drift.Value(healthStatusInt),
        attachments: drift.Value(data['attachments'] as String?),
        notes: drift.Value(data['notes'] as String?),
        syncState: const drift.Value('synced'),
        serverId: drift.Value(serverId),
        lastSyncedAt: drift.Value(DateTime.now()),
        createdAt:
            data['created_at'] != null ? drift.Value(DateTime.parse(data['created_at'])) : drift.Value(DateTime.now()),
        updatedAt:
            data['updated_at'] != null ? drift.Value(DateTime.parse(data['updated_at'])) : drift.Value(DateTime.now()),
      );

      await _db.into(_db.familyMembersTable).insertOnConflictUpdate(companion);
      UnifiedLogger.info('✅ Updated family_member: ${entity.id}');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update family_member', error: e);
    }
  }

  /// 🗑️ معالجة الحذف
  Future<void> _processDeletedItems(List<String> deletedIds) async {
    try {
      // TODO: Implement deletion logic based on proper ID mapping
      // Note: Schema uses IntColumn for IDs, need to map String IDs from server
      UnifiedLogger.info(
        '⏭️ Deletion processing not fully implemented yet - ${deletedIds.length} items',
      );
    } catch (e) {
      UnifiedLogger.error('❌ Failed to process deletions', error: e);
    }
  }

  /// 🗑️ حذف التغييرات الناجحة من القائمة
  Future<void> _clearSuccessfulChanges(
    List<PendingChangeDto> pendingChanges,
    List<FailedChangeDto>? failedChanges,
  ) async {
    try {
      final failedIds = failedChanges?.map((e) => e.entityId).toSet() ?? {};

      for (final change in pendingChanges) {
        if (!failedIds.contains(change.entityId)) {
          await (_db.delete(
            _db.syncQueue,
          )..where((t) => t.entityId.equals(change.entityId)))
              .go();
        }
      }

      UnifiedLogger.info(
        '✅ Cleared ${pendingChanges.length - failedIds.length} successful changes',
      );
    } catch (e) {
      UnifiedLogger.error('❌ Failed to clear successful changes', error: e);
    }
  }

  // ===========================
  // 📤 CONVERT TO API FORMAT (Local Integer → API String/Text)
  // ===========================

  /// تحويل family_deceased من Local إلى API format
  Map<String, dynamic> _familyDeceasedToApi(Map<String, dynamic> localData) {
    final apiData = Map<String, dynamic>.from(localData);

    // تحويل deceased_type: Integer → String
    if (apiData['deceased_type'] is int) {
      apiData['deceased_type'] = DeceasedType.toEnglish(
        apiData['deceased_type'] as int,
      );
    }

    // تحويل death_cause: Integer → Arabic Text
    if (apiData['death_cause'] is int) {
      apiData['death_cause'] = DeathCause.toArabic(
        apiData['death_cause'] as int,
      );
    }

    // تحويل document_type: Integer → Arabic Text
    if (apiData['document_type'] is int) {
      apiData['document_type'] = DocumentType.toArabic(
        apiData['document_type'] as int,
      );
    }

    // تحويل national_id: Integer → String
    if (apiData['national_id'] is int) {
      apiData['national_id'] = apiData['national_id'].toString();
    }

    return apiData;
  }

  /// تحويل family_member من Local إلى API format
  Map<String, dynamic> _familyMemberToApi(Map<String, dynamic> localData) {
    final apiData = Map<String, dynamic>.from(localData);

    // تحويل gender: Integer → String
    if (apiData['gender'] is int) {
      apiData['gender'] = Gender.toEnglish(apiData['gender'] as int);
    }

    // تحويل health_status: Integer → Arabic Text
    if (apiData['health_status'] is int) {
      apiData['health_status'] = HealthStatus.toArabic(
        apiData['health_status'] as int,
      );
    }

    // تحويل orphan_national_id: Integer → String
    if (apiData['orphan_national_id'] is int) {
      apiData['orphan_national_id'] = apiData['orphan_national_id'].toString();
    }

    return apiData;
  }

  // ===========================
  // 📌 ADD PENDING CHANGES
  // ===========================

  /// 📌 إضافة تغيير معلق
  Future<void> addPendingChange({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    int priority = 5,
  }) async {
    try {
      await _db.into(_db.syncQueue).insertOnConflictUpdate(
            SyncQueueCompanion.insert(
              id: '${entityType}_${entityId}_$operation',
              entity: entityType,
              entityId: entityId,
              operation: operation,
              payload: data.toString(), // أو استخدم jsonEncode(data)
              priority: drift.Value(priority),
              createdAt: DateTime.now(),
            ),
          );

      UnifiedLogger.info('📝 Added pending change: $entityType.$operation');

      // تحديث العداد
      final count = await (_db.select(_db.syncQueue)..limit(1000)).get();
      _syncStatusNotifier.updatePendingItems(count.length);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to add pending change', error: e);
    }
  }

  // ===========================
  // 🛠️ HELPER METHODS
  // ===========================

  /// 📱 الحصول على معلومات الجهاز
  Future<DeviceInfoDto> _getDeviceInfo() async {
    // TODO: Enable device_info_plus after adding the package
    // For now, return basic info
    return DeviceInfoDto(
      deviceId: await _storage.getDeviceId(),
      appVersion: ApiConfig.appVersion,
      platform: defaultTargetPlatform.name,
    );

    /* Uncomment after adding device_info_plus to pubspec.yaml
    try {
      final deviceInfo = DeviceInfoPlugin();
      final deviceId = await _storage.getDeviceId();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return DeviceInfoDto(
          deviceId: deviceId,
          appVersion: ApiConfig.appVersion,
          platform: 'android',
          osVersion: androidInfo.version.release,
          deviceModel: androidInfo.model,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceInfoDto(
          deviceId: deviceId,
          appVersion: ApiConfig.appVersion,
          platform: 'ios',
          osVersion: iosInfo.systemVersion,
          deviceModel: iosInfo.model,
        );
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return DeviceInfoDto(
          deviceId: deviceId,
          appVersion: ApiConfig.appVersion,
          platform: 'windows',
          osVersion: windowsInfo.buildNumber.toString(),
          deviceModel: windowsInfo.computerName,
        );
      }
    } catch (e) {
      UnifiedLogger.warning('⚠️ Failed to get device info');
    }

    // Fallback
    return DeviceInfoDto(
      deviceId: await _storage.getDeviceId(),
      appVersion: ApiConfig.appVersion,
      platform: defaultTargetPlatform.name,
    );
    */
  }

  /// 📊 الحصول على إحصائيات المزامنة
  Future<SyncStats> getStats() async {
    try {
      final pendingCount = await (_db.selectOnly(
        _db.syncQueue,
      )..addColumns([_db.syncQueue.id.count()]))
          .getSingle();

      final lastSync = await _storage.getLastSyncTime();

      return SyncStats(
        pendingChanges: pendingCount.read(_db.syncQueue.id.count()) ?? 0,
        lastSyncTime: lastSync,
        isSyncing: _isSyncing,
      );
    } catch (e) {
      return SyncStats(pendingChanges: 0, lastSyncTime: null, isSyncing: false);
    }
  }

  /// 🗑️ حذف جميع البيانات المعلقة (للتنظيف)
  Future<void> clearAllPending() async {
    await _db.delete(_db.syncQueue).go();
    _syncStatusNotifier.updatePendingItems(0);
    UnifiedLogger.info('🗑️ All pending changes cleared');
  }

  /// 🔄 إعادة محاولة التغييرات الفاشلة
  Future<void> retryFailed() async {
    await syncAll();
  }

  void dispose() {
    _syncStatusNotifier.dispose();
  }
}

// ===========================
// 📊 HELPER CLASSES
// ===========================

/// إحصائيات المزامنة
class SyncStats {
  final int pendingChanges;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  SyncStats({
    required this.pendingChanges,
    this.lastSyncTime,
    required this.isSyncing,
  });
}

/// حالة المزامنة (SyncState enum)
enum SyncState { pending, syncing, synced, failed }
