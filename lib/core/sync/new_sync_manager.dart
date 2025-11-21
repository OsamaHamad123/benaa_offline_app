import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:device_info_plus/device_info_plus.dart'; // سيتم تفعيلها لاحقاً
import '../../data/api/sync_api_client.dart';
import '../../data/dto/sync_dto.dart';
import '../../data/db/drift_database.dart';
import '../storage/secure_storage.dart';
import '../config/api_config.dart';
import '../utils/debug_logger.dart';
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
    DebugLogger.success('✅ NewSyncManager initialized');
  }

  // ===========================
  // 🔄 SYNC OPERATIONS
  // ===========================

  /// 🔄 مزامنة كاملة
  Future<bool> syncAll() async {
    if (_isSyncing) {
      DebugLogger.warning('⚠️ Sync already in progress');
      return false;
    }

    if (!_isInitialized) {
      DebugLogger.warning('⚠️ SyncManager not initialized');
      return false;
    }

    _isSyncing = true;

    try {
      _syncStatusNotifier.startSync();
      DebugLogger.info('🔄 Starting full sync...');

      final startTime = DateTime.now();

      // 1️⃣ جمع التغييرات المعلقة
      final pendingChanges = await _collectPendingChanges();
      _syncStatusNotifier.updatePendingItems(pendingChanges.length);

      if (pendingChanges.isEmpty) {
        DebugLogger.info('ℹ️ No pending changes to sync');
      } else {
        DebugLogger.info('📦 Found ${pendingChanges.length} pending changes');
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

      DebugLogger.success(
        '✅ Sync completed successfully in ${duration.inSeconds}s',
      );

      if (response.stats != null) {
        DebugLogger.info(
          '📊 Stats: Received=${response.stats!.receivedCount}, '
          'Sent=${response.stats!.sentCount}, '
          'Failed=${response.stats!.failedCount}',
        );
      }

      return true;
    } catch (e) {
      DebugLogger.error('❌ Sync failed', e);
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
      final pendingRows =
          await (_db.select(_db.syncQueue)..orderBy([
                (t) => drift.OrderingTerm(
                  expression: t.priority,
                  mode: drift.OrderingMode.desc,
                ),
                (t) => drift.OrderingTerm(expression: t.createdAt),
              ]))
              .get();

      for (final row in pendingRows) {
        // تحويل البيانات من JSON string إلى Map
        final Map<String, dynamic> data = {};
        try {
          // payload قد يكون JSON string
          if (row.payload.isNotEmpty) {
            // استخدم البيانات مباشرة أو حاول parse-ها
            data.addAll({'raw': row.payload});
          }
        } catch (e) {
          DebugLogger.warning('⚠️ Failed to parse payload for ${row.id}');
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
      DebugLogger.error('❌ Failed to collect pending changes', e);
      return [];
    }
  }

  /// 📥 تطبيق التحديثات من السيرفر
  Future<void> _applyServerUpdates(SyncResponseDto response) async {
    try {
      DebugLogger.info(
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
            DebugLogger.warning('⚠️ Unknown entity type: ${entity.entityType}');
        }
      }

      // حذف البيانات المحذوفة على السيرفر
      if (response.deletedIds.isNotEmpty) {
        DebugLogger.info(
          '🗑️ Processing ${response.deletedIds.length} deletions...',
        );
        await _processDeletedItems(response.deletedIds);
      }

      DebugLogger.success('✅ Server updates applied successfully');
    } catch (e) {
      DebugLogger.error('❌ Failed to apply server updates', e);
      rethrow;
    }
  }

  /// 🔄 تحديث مستفيد
  Future<void> _updateBeneficiary(ServerEntityDto entity) async {
    // TODO: Implement beneficiary update
    // Note: Schema uses IntColumn for id, needs mapping from server String IDs
    DebugLogger.info(
      '⏭️ Beneficiary update not fully implemented yet - ID: ${entity.id}',
    );
  }

  /// 🔄 تحديث زيارة
  Future<void> _updateVisit(ServerEntityDto entity) async {
    // TODO: Implement visit update
    DebugLogger.info('⏭️ Visit update not implemented yet');
  }

  /// 🔄 تحديث مرفق
  Future<void> _updateAttachment(ServerEntityDto entity) async {
    // TODO: Implement attachment update
    DebugLogger.info('⏭️ Attachment update not implemented yet');
  }

  /// 🔄 تحديث taxonomy
  Future<void> _updateTaxonomy(ServerEntityDto entity) async {
    // TODO: Implement taxonomy update
    DebugLogger.info('⏭️ Taxonomy update not implemented yet');
  }

  /// 🔄 تحديث فرد متوفى
  Future<void> _updateFamilyDeceased(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final serverId = int.tryParse(entity.id);

      if (serverId == null) {
        DebugLogger.warning(
          '⚠️ Invalid family_deceased server ID: ${entity.id}',
        );
        return;
      }

      final companion = FamilyDeceasedTableCompanion(
        id: drift.Value(serverId),
        beneficiaryId: drift.Value(data['beneficiary_id'] as int),
        fullName: drift.Value(data['full_name'] as String),
        relationship: drift.Value(data['relationship'] as String),
        gender: drift.Value(data['gender'] as String? ?? 'male'),
        deathDate: data['death_date'] != null
            ? drift.Value(DateTime.parse(data['death_date']))
            : const drift.Value(null),
        deathCause: drift.Value(data['death_cause'] as String?),
        ageAtDeath: drift.Value(data['age_at_death'] as int?),
        notes: drift.Value(data['notes'] as String?),
        syncState: const drift.Value('synced'),
        serverId: drift.Value(serverId),
        lastSyncedAt: drift.Value(DateTime.now()),
        createdAt: data['created_at'] != null
            ? drift.Value(DateTime.parse(data['created_at']))
            : drift.Value(DateTime.now()),
        updatedAt: data['updated_at'] != null
            ? drift.Value(DateTime.parse(data['updated_at']))
            : drift.Value(DateTime.now()),
      );

      await _db.into(_db.familyDeceasedTable).insertOnConflictUpdate(companion);
      DebugLogger.info('✅ Updated family_deceased: ${entity.id}');
    } catch (e) {
      DebugLogger.error('❌ Failed to update family_deceased', e);
    }
  }

  /// 🔄 تحديث فرد من العائلة
  Future<void> _updateFamilyMember(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final serverId = int.tryParse(entity.id);

      if (serverId == null) {
        DebugLogger.warning('⚠️ Invalid family_member server ID: ${entity.id}');
        return;
      }

      final companion = FamilyMembersTableCompanion(
        id: drift.Value(serverId),
        beneficiaryId: drift.Value(data['beneficiary_id'] as int),
        fullName: drift.Value(data['full_name'] as String),
        relationship: drift.Value(data['relationship'] as String),
        gender: drift.Value(data['gender'] as String? ?? 'male'),
        nationalId: drift.Value(data['national_id'] as String?),
        birthDate: data['birth_date'] != null
            ? drift.Value(DateTime.parse(data['birth_date']))
            : const drift.Value(null),
        age: drift.Value(data['age'] as int?),
        maritalStatus: drift.Value(data['marital_status'] as String?),
        educationLevel: drift.Value(data['education_level'] as String?),
        occupation: drift.Value(data['occupation'] as String?),
        healthStatus: drift.Value(data['health_status'] as String?),
        hasDisability: drift.Value((data['has_disability'] as int? ?? 0) == 1),
        disabilityType: drift.Value(data['disability_type'] as String?),
        hasChronicDisease: drift.Value(
          (data['has_chronic_disease'] as int? ?? 0) == 1,
        ),
        chronicDiseaseType: drift.Value(
          data['chronic_disease_type'] as String?,
        ),
        livesWithBeneficiary: drift.Value(
          (data['lives_with_beneficiary'] as int? ?? 1) == 1,
        ),
        phone: drift.Value(data['phone'] as String?),
        syncState: const drift.Value('synced'),
        serverId: drift.Value(serverId),
        lastSyncedAt: drift.Value(DateTime.now()),
        createdAt: data['created_at'] != null
            ? drift.Value(DateTime.parse(data['created_at']))
            : drift.Value(DateTime.now()),
        updatedAt: data['updated_at'] != null
            ? drift.Value(DateTime.parse(data['updated_at']))
            : drift.Value(DateTime.now()),
      );

      await _db.into(_db.familyMembersTable).insertOnConflictUpdate(companion);
      DebugLogger.info('✅ Updated family_member: ${entity.id}');
    } catch (e) {
      DebugLogger.error('❌ Failed to update family_member', e);
    }
  }

  /// 🗑️ معالجة الحذف
  Future<void> _processDeletedItems(List<String> deletedIds) async {
    try {
      // TODO: Implement deletion logic based on proper ID mapping
      // Note: Schema uses IntColumn for IDs, need to map String IDs from server
      DebugLogger.info(
        '⏭️ Deletion processing not fully implemented yet - ${deletedIds.length} items',
      );
    } catch (e) {
      DebugLogger.error('❌ Failed to process deletions', e);
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
          )..where((t) => t.entityId.equals(change.entityId))).go();
        }
      }

      DebugLogger.info(
        '✅ Cleared ${pendingChanges.length - failedIds.length} successful changes',
      );
    } catch (e) {
      DebugLogger.error('❌ Failed to clear successful changes', e);
    }
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
      await _db
          .into(_db.syncQueue)
          .insertOnConflictUpdate(
            SyncQueueCompanion.insert(
              id: '${entityType}_${entityId}_${operation}',
              entity: entityType,
              entityId: entityId,
              operation: operation,
              payload: data.toString(), // أو استخدم jsonEncode(data)
              priority: drift.Value(priority),
              createdAt: DateTime.now(),
            ),
          );

      DebugLogger.info('📝 Added pending change: $entityType.$operation');

      // تحديث العداد
      final count = await (_db.select(_db.syncQueue)..limit(1000)).get();
      _syncStatusNotifier.updatePendingItems(count.length);
    } catch (e) {
      DebugLogger.error('❌ Failed to add pending change', e);
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
      DebugLogger.warning('⚠️ Failed to get device info');
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
      )..addColumns([_db.syncQueue.id.count()])).getSingle();

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
    DebugLogger.info('🗑️ All pending changes cleared');
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
