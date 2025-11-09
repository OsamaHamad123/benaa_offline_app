import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/drift_database.dart';
import '../network/api_client.dart';
import '../providers/providers.dart';
import 'package:drift/drift.dart' as drift;

/// Provider للـ CivilRegistrySyncService
final civilRegistrySyncServiceProvider = Provider<CivilRegistrySyncService>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return CivilRegistrySyncService(database, apiClient: apiClient);
});

/// حالة مزامنة السجل المدني
class CivilSyncStatus {
  final bool isSyncing;
  final int totalRecords;
  final int syncedRecords;
  final String? currentBatch;
  final String? lastError;
  final DateTime? lastSyncTime;

  CivilSyncStatus({
    this.isSyncing = false,
    this.totalRecords = 0,
    this.syncedRecords = 0,
    this.currentBatch,
    this.lastError,
    this.lastSyncTime,
  });

  double get progress => totalRecords > 0 ? syncedRecords / totalRecords : 0.0;

  CivilSyncStatus copyWith({
    bool? isSyncing,
    int? totalRecords,
    int? syncedRecords,
    String? currentBatch,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return CivilSyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      totalRecords: totalRecords ?? this.totalRecords,
      syncedRecords: syncedRecords ?? this.syncedRecords,
      currentBatch: currentBatch ?? this.currentBatch,
      lastError: lastError ?? this.lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// خدمة مزامنة السجل المدني مع قاعدة البيانات الرئيسية
/// تقوم بجلب البيانات من API الخاص بقاعدة البيانات الرئيسية وحفظها محلياً
class CivilRegistrySyncService {
  final AppDatabase _db;
  final ApiClient? _apiClient;
  final _statusController = StreamController<CivilSyncStatus>.broadcast();

  CivilSyncStatus _currentStatus = CivilSyncStatus();

  CivilRegistrySyncService(this._db, {ApiClient? apiClient})
    : _apiClient = apiClient;

  Stream<CivilSyncStatus> get statusStream => _statusController.stream;
  CivilSyncStatus get currentStatus => _currentStatus;

  /// تحديث الحالة
  void _updateStatus(CivilSyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// مزامنة شاملة - جلب جميع البيانات من قاعدة البيانات الرئيسية
  /// يستخدم Batch Processing لتحسين الأداء
  Future<void> syncAll({
    int batchSize = 1000,
    void Function(int synced, int total)? onProgress,
  }) async {
    if (_apiClient == null) {
      throw Exception('API Client غير متوفر - تأكد من تكوين الاتصال');
    }

    try {
      _updateStatus(_currentStatus.copyWith(isSyncing: true, lastError: null));

      // الخطوة 1: الحصول على العدد الإجمالي للسجلات
      final totalCount = await _getTotalRecordsCount();
      _updateStatus(_currentStatus.copyWith(totalRecords: totalCount));

      // الخطوة 2: جلب البيانات على دفعات
      int offset = 0;
      int syncedCount = 0;

      while (offset < totalCount) {
        _updateStatus(
          _currentStatus.copyWith(
            currentBatch: 'جلب السجلات ${offset + 1} - ${offset + batchSize}',
          ),
        );

        // جلب دفعة من البيانات
        final records = await _fetchCivilRecordsBatch(
          offset: offset,
          limit: batchSize,
        );

        // حفظ الدفعة في قاعدة البيانات المحلية
        await _saveCivilRecordsBatch(records);

        syncedCount += records.length;
        offset += batchSize;

        _updateStatus(_currentStatus.copyWith(syncedRecords: syncedCount));
        onProgress?.call(syncedCount, totalCount);

        // تجنب الضغط على السيرفر
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastSyncTime: DateTime.now()),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
      rethrow;
    }
  }

  /// مزامنة تزايدية - جلب التحديثات الجديدة فقط منذ آخر مزامنة
  Future<void> syncIncremental({
    DateTime? lastSyncTime,
    int batchSize = 1000,
  }) async {
    if (_apiClient == null) {
      throw Exception('API Client غير متوفر - تأكد من تكوين الاتصال');
    }

    try {
      _updateStatus(_currentStatus.copyWith(isSyncing: true, lastError: null));

      // استخدام آخر وقت مزامنة محفوظ إذا لم يتم تحديده
      final syncTime = lastSyncTime ?? _currentStatus.lastSyncTime;

      if (syncTime == null) {
        // إذا لم تكن هناك مزامنة سابقة، نقوم بمزامنة شاملة
        await syncAll(batchSize: batchSize);
        return;
      }

      // الخطوة 1: الحصول على عدد السجلات المحدثة
      final updatedCount = await _getUpdatedRecordsCount(syncTime);
      _updateStatus(_currentStatus.copyWith(totalRecords: updatedCount));

      if (updatedCount == 0) {
        _updateStatus(
          _currentStatus.copyWith(
            isSyncing: false,
            lastSyncTime: DateTime.now(),
          ),
        );
        return;
      }

      // الخطوة 2: جلب السجلات المحدثة على دفعات
      int offset = 0;
      int syncedCount = 0;

      while (offset < updatedCount) {
        _updateStatus(
          _currentStatus.copyWith(
            currentBatch: 'جلب التحديثات ${offset + 1} - ${offset + batchSize}',
          ),
        );

        final records = await _fetchUpdatedRecordsBatch(
          since: syncTime,
          offset: offset,
          limit: batchSize,
        );

        await _updateCivilRecordsBatch(records);

        syncedCount += records.length;
        offset += batchSize;

        _updateStatus(_currentStatus.copyWith(syncedRecords: syncedCount));

        await Future.delayed(const Duration(milliseconds: 100));
      }

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastSyncTime: DateTime.now()),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
      rethrow;
    }
  }

  /// مزامنة سجل محدد بالرقم الوطني
  Future<void> syncByNationalId(String nationalId) async {
    if (_apiClient == null) {
      throw Exception('API Client غير متوفر - تأكد من تكوين الاتصال');
    }

    try {
      _updateStatus(_currentStatus.copyWith(isSyncing: true));

      final response = await _apiClient.getCivilRecord(nationalId);

      if (response['data'] != null) {
        final record = _parseRecord(response['data']);
        await _db.into(_db.civilRegistry).insertOnConflictUpdate(record);
      }

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastSyncTime: DateTime.now()),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
      rethrow;
    }
  }

  /// مزامنة مجموعة من السجلات بأرقامها الوطنية
  Future<void> syncMultipleByNationalIds(
    List<String> nationalIds, {
    int batchSize = 100,
  }) async {
    if (_apiClient == null) {
      throw Exception('API Client غير متوفر - تأكد من تكوين الاتصال');
    }

    try {
      _updateStatus(
        _currentStatus.copyWith(
          isSyncing: true,
          totalRecords: nationalIds.length,
        ),
      );

      // معالجة على دفعات
      for (int i = 0; i < nationalIds.length; i += batchSize) {
        final batch = nationalIds.skip(i).take(batchSize).toList();

        _updateStatus(
          _currentStatus.copyWith(
            currentBatch: 'جلب السجلات ${i + 1} - ${i + batch.length}',
          ),
        );

        final response = await _apiClient.getCivilRecordsByNationalIds(batch);

        if (response['data'] != null) {
          final records = (response['data'] as List)
              .map((item) => _parseRecord(item))
              .toList();

          await _saveCivilRecordsBatch(records);
        }

        _updateStatus(_currentStatus.copyWith(syncedRecords: i + batch.length));

        await Future.delayed(const Duration(milliseconds: 100));
      }

      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastSyncTime: DateTime.now()),
      );
    } catch (e) {
      _updateStatus(
        _currentStatus.copyWith(isSyncing: false, lastError: e.toString()),
      );
      rethrow;
    }
  }

  /// الحصول على العدد الإجمالي للسجلات من السيرفر
  Future<int> _getTotalRecordsCount() async {
    return await _apiClient!.getCivilRegistryCount();
  }

  /// الحصول على عدد السجلات المحدثة منذ وقت معين
  Future<int> _getUpdatedRecordsCount(DateTime since) async {
    return await _apiClient!.getCivilRegistryCountUpdated(since);
  }

  /// جلب دفعة من السجلات
  Future<List<CivilRegistryCompanion>> _fetchCivilRecordsBatch({
    required int offset,
    required int limit,
  }) async {
    final response = await _apiClient!.getCivilRecordsBatch(
      offset: offset,
      limit: limit,
    );

    final data = response['data'] as List? ?? [];
    return data.map((item) => _parseRecord(item)).toList();
  }

  /// جلب السجلات المحدثة منذ وقت معين
  Future<List<CivilRegistryCompanion>> _fetchUpdatedRecordsBatch({
    required DateTime since,
    required int offset,
    required int limit,
  }) async {
    final response = await _apiClient!.getCivilRecordsUpdated(
      since: since,
      offset: offset,
      limit: limit,
    );

    final data = response['data'] as List? ?? [];
    return data.map((item) => _parseRecord(item)).toList();
  }

  /// حفظ دفعة من السجلات في قاعدة البيانات
  Future<void> _saveCivilRecordsBatch(
    List<CivilRegistryCompanion> records,
  ) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.civilRegistry, records);
    });
  }

  /// تحديث دفعة من السجلات
  Future<void> _updateCivilRecordsBatch(
    List<CivilRegistryCompanion> records,
  ) async {
    await _db.batch((batch) {
      for (final record in records) {
        batch.update(
          _db.civilRegistry,
          record,
          where: (_) =>
              _db.civilRegistry.nationalId.equals(record.nationalId.value),
        );
      }
    });
  }

  /// تحويل بيانات API إلى CivilRegistryCompanion
  CivilRegistryCompanion _parseRecord(Map<String, dynamic> data) {
    return CivilRegistryCompanion(
      id: drift.Value(data['id'] as int? ?? 0),
      nationalId: drift.Value(data['CI_ID_NUM']?.toString() ?? ''),
      firstName: drift.Value(data['CI_FIRST_ARB']?.toString() ?? ''),
      fatherName: drift.Value(data['CI_FATHER_ARB']?.toString() ?? ''),
      grandFatherName: drift.Value(
        data['CI_GRAND_FATHER_ARB']?.toString() ?? '',
      ),
      familyName: drift.Value(data['CI_FAMILY_ARB']?.toString() ?? ''),
      birthCertificateId: drift.Value(
        data['CI_BIRTH_TB_CD'] != null
            ? int.tryParse(data['CI_BIRTH_TB_CD'].toString())
            : null,
      ),
      birthCodeId: drift.Value(data['CI_BIRTH_CD'] as int?),
      birthDate: data['CI_BIRTH_DT'] != null
          ? drift.Value(DateTime.tryParse(data['CI_BIRTH_DT'].toString()))
          : const drift.Value.absent(),
      sexCode: drift.Value(data['CI_SEX_CD'] as int?),
      personalCodeId: drift.Value(data['CI_PERSONAL_CD'] as int?),
      deadDate: drift.Value(
        data['CI_DEAD_DT'] != null
            ? int.tryParse(data['CI_DEAD_DT'].toString())
            : null,
      ),
      motherName: drift.Value(data['MOTHER_NAME1']?.toString()),
      cityId: drift.Value(data['CITY'] as int?),
      cityName: drift.Value(data['CITY_NAME']?.toString()),
      street: drift.Value(data['STREET']?.toString()),
      houseNo: drift.Value(data['HOUSE_NO']?.toString()),
      relationId: drift.Value(
        data['CF_ID_NUM'] != null
            ? int.tryParse(data['CF_ID_NUM'].toString())
            : null,
      ),
      relativeCodeId: drift.Value(data['CF_RELATIVE_CD'] as int?),
      relativeId: drift.Value(
        data['CF_ID_RELATIVE'] != null
            ? int.tryParse(data['CF_ID_RELATIVE'].toString())
            : null,
      ),
      fullName: drift.Value(
        _buildFullName(
          data['CI_FIRST_ARB']?.toString(),
          data['CI_FATHER_ARB']?.toString(),
          data['CI_GRAND_FATHER_ARB']?.toString(),
          data['CI_FAMILY_ARB']?.toString(),
        ),
      ),
      fullNameNormalized: drift.Value(
        _normalizeArabicName(
          _buildFullName(
            data['CI_FIRST_ARB']?.toString(),
            data['CI_FATHER_ARB']?.toString(),
            data['CI_GRAND_FATHER_ARB']?.toString(),
            data['CI_FAMILY_ARB']?.toString(),
          ),
        ),
      ),
      governorate: drift.Value(data['GOVERNORATE']?.toString()),
      district: drift.Value(data['DISTRICT']?.toString()),
      createdAt: data['CREATED_AT'] != null
          ? drift.Value(DateTime.parse(data['CREATED_AT'].toString()))
          : drift.Value(DateTime.now()),
      updatedAt: data['UPDATED_AT'] != null
          ? drift.Value(DateTime.parse(data['UPDATED_AT'].toString()))
          : drift.Value(DateTime.now()),
      lastSyncedAt: drift.Value(DateTime.now()),
    );
  }

  /// بناء الاسم الكامل
  String _buildFullName(
    String? firstName,
    String? fatherName,
    String? grandFatherName,
    String? familyName,
  ) {
    final parts = [
      firstName,
      fatherName,
      grandFatherName,
      familyName,
    ].where((p) => p != null && p.isNotEmpty).toList();

    return parts.join(' ');
  }

  /// تطبيع الأسماء العربية للبحث
  String _normalizeArabicName(String name) {
    return name
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '') // إزالة التشكيل
        .trim()
        .toLowerCase();
  }

  /// مسح جميع البيانات المحلية
  Future<void> clearLocalData() async {
    await _db.delete(_db.civilRegistry).go();
    _updateStatus(CivilSyncStatus());
  }

  /// الحصول على إحصائيات المزامنة
  Future<Map<String, dynamic>> getSyncStats() async {
    final totalRecords = await _db
        .customSelect(
          'SELECT COUNT(*) as count FROM civil_registry',
          readsFrom: {_db.civilRegistry},
        )
        .getSingle();

    final lastSynced = await _db
        .customSelect(
          'SELECT MAX(last_synced_at) as last_sync FROM civil_registry',
          readsFrom: {_db.civilRegistry},
        )
        .getSingleOrNull();

    return {
      'total_records': totalRecords.read<int>('count'),
      'last_synced_at': lastSynced?.read<DateTime?>('last_sync'),
      'current_status': _currentStatus,
    };
  }

  void dispose() {
    _statusController.close();
  }
}
