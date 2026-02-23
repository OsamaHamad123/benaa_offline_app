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
            UnifiedLogger.warning('⚠️ Unknown entity type: ${entity.entityType}');
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
    try {
      final data = entity.data;
      final serverId = entity.id.trim();
      final beneficiaryId = (data['beneficiary_id'] ?? data['beneficiaryId'] ?? '').toString();

      if (serverId.isEmpty || beneficiaryId.isEmpty) {
        UnifiedLogger.warning('⚠️ Invalid visit payload for ID: ${entity.id}');
        return;
      }

      final existing = await (_db.select(_db.visits)..where((v) => v.serverId.equals(serverId))).getSingleOrNull();

      final localId = existing?.id ?? 'srv_visit_$serverId';
      final visitDateRaw = data['visit_date'] ?? data['visitDate'];
      final visitDate = visitDateRaw is String ? DateTime.tryParse(visitDateRaw) : null;

      final companion = VisitsCompanion(
        id: drift.Value(localId),
        beneficiaryId: drift.Value(beneficiaryId),
        visitDate: drift.Value(visitDate ?? entity.updatedAt),
        staffName: drift.Value((data['staff_name'] ?? data['staffName'] ?? 'system_sync').toString()),
        notes: drift.Value((data['notes'] ?? '').toString()),
        isSubmitted: const drift.Value(true),
        createdAt: drift.Value(entity.createdAt ?? entity.updatedAt),
        updatedAt: drift.Value(entity.updatedAt),
        syncState: const drift.Value('synced'),
        serverId: drift.Value(serverId),
        lastSyncedAt: drift.Value(DateTime.now()),
      );

      await _db.into(_db.visits).insertOnConflictUpdate(companion);
      UnifiedLogger.info('✅ Updated visit: ${entity.id}');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update visit', error: e);
    }
  }

  /// 🔄 تحديث مرفق
  Future<void> _updateAttachment(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final serverId = entity.id.trim();

      if (serverId.isEmpty) {
        UnifiedLogger.warning('⚠️ Invalid attachment server ID: ${entity.id}');
        return;
      }

      final beneficiaryId = (data['beneficiary_id'] ?? data['entity_id'] ?? '').toString();
      if (beneficiaryId.isEmpty) {
        UnifiedLogger.warning('⚠️ Missing beneficiary_id for attachment: ${entity.id}');
        return;
      }

      final fileName = (data['file_name'] ?? data['filename'] ?? data['name'] ?? 'attachment_$serverId').toString();
      final filePath = (data['file_path'] ?? data['path'] ?? data['url'] ?? '').toString();
      final type = (data['type'] ?? data['file_type'] ?? 'other').toString();
      final fileSizeRaw = data['file_size'] ?? data['size'];
      final fileSize = fileSizeRaw is int ? fileSizeRaw : int.tryParse(fileSizeRaw?.toString() ?? '') ?? 0;

      final companion = AttachmentsCompanion(
        id: drift.Value(serverId),
        beneficiaryId: drift.Value(beneficiaryId),
        visitId: drift.Value(data['visit_id']?.toString()),
        fileName: drift.Value(fileName),
        filePath: drift.Value(filePath),
        type: drift.Value(type),
        fileSize: drift.Value(fileSize),
        thumbnailPath: drift.Value(data['thumbnail_path']?.toString()),
        documentType: drift.Value(data['document_type']?.toString()),
        personType: drift.Value(data['person_type']?.toString()),
        personId: drift.Value(data['person_id']?.toString()),
        notes: drift.Value(data['notes']?.toString()),
        createdAt: drift.Value(entity.createdAt ?? entity.updatedAt),
        updatedAt: drift.Value(entity.updatedAt),
        syncState: const drift.Value('synced'),
        serverUrl: drift.Value(data['url']?.toString()),
        lastSyncedAt: drift.Value(DateTime.now()),
      );

      await _db.into(_db.attachments).insertOnConflictUpdate(companion);
      UnifiedLogger.info('✅ Updated attachment: ${entity.id}');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update attachment', error: e);
    }
  }

  /// 🔄 تحديث taxonomy
  Future<void> _updateTaxonomy(ServerEntityDto entity) async {
    try {
      final data = entity.data;
      final taxonomyId = entity.id.trim();

      if (taxonomyId.isEmpty) {
        UnifiedLogger.warning('⚠️ Invalid taxonomy ID: ${entity.id}');
        return;
      }

      final group = (data['group'] ?? data['category'] ?? 'category').toString();
      final code = (data['code'] ?? taxonomyId).toString();
      final label = (data['label'] ?? data['name'] ?? taxonomyId).toString();

      final companion = TaxonomiesCompanion(
        id: drift.Value(taxonomyId),
        group: drift.Value(group),
        code: drift.Value(code),
        label: drift.Value(label),
        parentId: drift.Value(data['parent_id']?.toString()),
        sortOrder: drift.Value(data['sort_order'] as int? ?? 0),
        isActive: drift.Value(data['is_active'] as bool? ?? true),
        updatedAt: drift.Value(entity.updatedAt),
      );

      await _db.into(_db.taxonomies).insertOnConflictUpdate(companion);
      UnifiedLogger.info('✅ Updated taxonomy: ${entity.id}');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update taxonomy', error: e);
    }
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
        UnifiedLogger.warning('⚠️ Invalid family_member server ID: ${entity.id}');
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
      int deletedCount = 0;

      for (final raw in deletedIds) {
        final parsed = _parseDeletedToken(raw);
        if (parsed == null) {
          UnifiedLogger.warning('⚠️ Skipping unrecognized deleted token: $raw');
          continue;
        }

        final entityType = parsed.$1;
        final entityId = parsed.$2;

        switch (entityType) {
          case 'beneficiary':
            final serverId = int.tryParse(entityId);
            if (serverId != null) {
              deletedCount += await (_db.delete(_db.beneficiaries)..where((b) => b.serverId.equals(serverId))).go();
            }
            break;
          case 'visit':
            deletedCount +=
                await (_db.delete(_db.visits)..where((v) => v.serverId.equals(entityId) | v.id.equals(entityId))).go();
            break;
          case 'attachment':
            deletedCount += await (_db.delete(_db.attachments)..where((a) => a.id.equals(entityId))).go();
            break;
          case 'taxonomy':
            deletedCount += await (_db.delete(_db.taxonomies)..where((t) => t.id.equals(entityId))).go();
            break;
          case 'family_member':
            final localId = int.tryParse(entityId);
            if (localId != null) {
              deletedCount += await (_db.delete(_db.familyMembersTable)
                    ..where((f) => f.id.equals(localId) | f.serverId.equals(localId)))
                  .go();
            }
            break;
          case 'family_deceased':
            final localId = int.tryParse(entityId);
            if (localId != null) {
              deletedCount += await (_db.delete(_db.familyDeceasedTable)
                    ..where((f) => f.id.equals(localId) | f.serverId.equals(localId)))
                  .go();
            }
            break;
          default:
            UnifiedLogger.warning('⚠️ Unsupported deleted entity type: $entityType');
        }
      }

      UnifiedLogger.info('✅ Deleted $deletedCount item(s) from local database');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to process deletions', error: e);
    }
  }

  (String, String)? _parseDeletedToken(String raw) {
    final token = raw.trim();
    if (token.isEmpty) {
      return null;
    }

    final colon = token.indexOf(':');
    if (colon > 0 && colon < token.length - 1) {
      return (token.substring(0, colon), token.substring(colon + 1));
    }

    final hash = token.indexOf('#');
    if (hash > 0 && hash < token.length - 1) {
      return (token.substring(0, hash), token.substring(hash + 1));
    }

    return null;
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
      return SyncStats(pendingChanges: 0, isSyncing: false);
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
    required this.isSyncing,
    this.lastSyncTime,
  });
}

/// حالة المزامنة (SyncState enum)
enum SyncState { pending, syncing, synced, failed }
