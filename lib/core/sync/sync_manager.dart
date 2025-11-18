import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/db/drift_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../providers/providers.dart';
import '../../features/beneficiaries/data/models/beneficiary_data_model.dart';
import '../network/api_client.dart';

// Provider للـ SyncManager
final syncManagerProvider = Provider<SyncManager>((ref) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return SyncManager(database, apiClient: apiClient);
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
  final ApiClient? _apiClient;
  final _statusController = StreamController<SyncStatus>.broadcast();
  final _uuid = const Uuid();

  Timer? _autoSyncTimer;
  SyncStatus _currentStatus = SyncStatus();

  SyncManager(this._db, {ApiClient? apiClient}) : _apiClient = apiClient {
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

    _updateStatus(_currentStatus.copyWith(isSyncing: true, lastError: null));

    try {
      // جلب قائمة المزامنة مرتبة حسب الأولوية
      final items = await _db.syncDao.getSyncQueue(limit: 100);

      _updateStatus(
        _currentStatus.copyWith(totalItems: items.length, completedItems: 0),
      );

      for (var i = 0; i < items.length; i++) {
        final item = items[i];

        _updateStatus(
          _currentStatus.copyWith(
            currentEntity: item.entity,
            completedItems: i,
          ),
        );

        try {
          // تنفيذ المزامنة حسب نوع الكيان
          await _syncItem(item);

          // حذف من الطابور بعد النجاح
          await _db.syncDao.removeFromSyncQueue(item.id);
        } catch (e) {
          // تحديث عدد المحاولات والخطأ
          await _db.syncDao.updateSyncQueueError(
            item.id,
            e.toString(),
            item.attempts + 1,
          );

          // إعادة جدولة للمحاولة لاحقاً (backoff exponential)
          final delay = Duration(minutes: (5 * (item.attempts + 1)).toInt());
          await _db.customStatement(
            'UPDATE sync_queue SET scheduled_at = ? WHERE id = ?',
            [
              drift.Variable.withDateTime(DateTime.now().add(delay)),
              drift.Variable.withString(item.id),
            ],
          );
        }
      }

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
    if (_apiClient == null) {
      throw Exception('ApiClient not configured');
    }

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

      // استخدام BeneficiaryDataModel للتحويل
      final dataModel = BeneficiaryDataModel.fromDrift(beneficiary);
      final backendData = dataModel.toJson();

      // Send to backend
      final response = await _apiClient.syncBeneficiaries([backendData]);

      // Update local record with server ID and sync status
      if (response['data'] != null && response['data'].isNotEmpty) {
        final serverRecord = response['data'][0];
        final serverId = serverRecord['id']?.toString();

        if (serverId != null) {
          await _db.customStatement(
            'UPDATE beneficiaries SET server_id = ?, last_synced_at = ?, sync_state = ? WHERE id = ?',
            [
              drift.Variable.withString(serverId),
              drift.Variable.withDateTime(DateTime.now()),
              drift.Variable.withString('synced'),
              drift.Variable.withString(id),
            ],
          );
        }
      }
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
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // مزامنة مرفق
  Future<void> _syncAttachment(
    String id,
    String operation,
    Map<String, dynamic> data,
  ) async {
    // TODO: Implement actual API call for file upload
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ============================================================================
  // PULL FROM SERVER - جلب من السيرفر
  // ============================================================================

  // مزامنة المستفيدين من السيرفر (Pull)
  Future<int> pullBeneficiariesFromServer({DateTime? updatedAfter}) async {
    if (_apiClient == null) {
      throw Exception('ApiClient not configured');
    }

    try {
      // جلب البيانات من السيرفر
      final response = await _apiClient.pullSync(updatedAfter: updatedAfter);
      final beneficiariesData = response['beneficiaries'] as List? ?? [];

      int insertedCount = 0;

      // تحويل وحفظ كل مستفيد
      for (final item in beneficiariesData) {
        try {
          // تحويل من Backend JSON إلى Data Model ثم إلى Drift Companion
          final dataModel = BeneficiaryDataModel.fromJson(
            item as Map<String, dynamic>,
          );
          final beneficiaryCompanion = dataModel.toDriftCompanion();

          // البحث عن مستفيد موجود بنفس الـ serverId
          final serverId = item['id'] as int?;
          if (serverId != null) {
            final existing = await _db.beneficiariesDao
                .getBeneficiaryByServerId(serverId);

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
      }

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
