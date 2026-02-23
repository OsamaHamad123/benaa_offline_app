import 'package:dio/dio.dart';
import '../../models/sync_models.dart';
import '../../../../data/models/taxonomy_dto.dart';
import '../../../../features/beneficiaries/data/models/beneficiary_data_model.dart';

/// 🌐 Remote Sync DataSource
///
/// مسؤول عن التواصل مع السيرفر لجلب ورفع البيانات
class RemoteSyncDataSource {
  final Dio _dio;

  static const Map<String, String> _taxonomyGroupToCategorySlug = {
    'category': 'categories',
    'marital_status': 'marital-statuses',
    'education_level': 'academic-degrees',
    'health_status': 'health-statuses',
    'gender': 'genders',
    'governorate': 'provinces',
    'displacement_status': 'displacement-statuses',
    'employment_status': 'employment-statuses',
    'housing_status': 'housing-statuses',
    'housing_type': 'accommodation-types',
  };

  const RemoteSyncDataSource(this._dio);

  // ═══════════════════════════════════════════════════════════════════════
  // 🏷️ TAXONOMIES SYNC
  // ═══════════════════════════════════════════════════════════════════════

  /// جلب التصنيفات من السيرفر
  ///
  /// [group] المجموعة (optional) - 'category', 'marital_status', etc.
  /// [since] جلب التغييرات منذ (optional) - delta sync
  ///
  /// Returns: قائمة التصنيفات + timestamp
  Future<TaxonomySyncResponse> pullTaxonomies({
    String? group,
    DateTime? since,
  }) async {
    try {
      final updatedAfter = since?.toIso8601String();
      final categorySlug = _toCategorySlug(group);

      if (categorySlug != null) {
        final response = await _dio.get(
          '/api/mobile/categories/$categorySlug',
          queryParameters: {
            if (updatedAfter != null) 'updated_after': updatedAfter,
            'per_page': 500,
          },
        );

        final normalized = _normalizeCategoryItemsResponse(
          response.data as Map<String, dynamic>,
          fallbackGroup: group ?? _toGroupValue(categorySlug),
          fallbackSlug: categorySlug,
        );

        return TaxonomySyncResponse.fromJson(normalized);
      }

      final response = await _dio.get(
        '/api/mobile/categories/sync-all',
        queryParameters: {
          if (updatedAfter != null) 'updated_after': updatedAfter,
        },
      );

      final normalized = _normalizeSyncAllTaxonomiesResponse(
        response.data as Map<String, dynamic>,
      );

      return TaxonomySyncResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب التصنيفات');
    }
  }

  /// جلب كل المجموعات المتاحة
  Future<List<String>> getAvailableGroups() async {
    try {
      final response = await _dio.get('/api/mobile/categories');
      final root = response.data as Map<String, dynamic>;
      final dataNode = root['data'];
      final categoriesNode = dataNode is Map<String, dynamic> ? dataNode['categories'] : null;
      final categories = categoriesNode is List ? categoriesNode : const [];

      final slugs = categories.map((item) => item is Map<String, dynamic> ? item['slug'] : null).whereType<String>();

      return slugs.map(_toGroupValue).toSet().toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب مجموعات التصنيفات');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 👥 BENEFICIARIES SYNC
  // ═══════════════════════════════════════════════════════════════════════

  /// جلب تغييرات المستفيدين (Delta Sync)
  ///
  /// [since] جلب التغييرات منذ
  /// [limit] الحد الأقصى للعناصر (default: 100)
  ///
  /// Returns: التغييرات + metadata
  Future<PullChangesResponse<BeneficiaryDataModel>> pullBeneficiaryChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{'per_page': limit, 'page': 1};
      if (since != null) {
        queryParams['updated_after'] = since.toIso8601String();
      }

      final response = await _dio.get(
        '/api/mobile/database/data',
        queryParameters: queryParams,
      );

      final normalized = _normalizePullResponse(
        response.data as Map<String, dynamic>,
      );

      return PullChangesResponse<BeneficiaryDataModel>.fromJson(
        normalized,
        (json) => BeneficiaryDataModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب تغييرات المستفيدين');
    }
  }

  /// رفع تغييرات المستفيدين للسيرفر
  ///
  /// [changes] قائمة التغييرات المحلية
  ///
  /// رفع تغييرات المستفيدين للسيرفر
  Future<SyncResponse> pushBeneficiaryChanges(List<SyncChange> changes) async {
    try {
      final response = await _dio.post(
        '/api/mobile/database/data/batch',
        data: {
          'changes': changes.map((c) => c.toJson()).toList(),
          'records': changes.map((c) => c.data).toList(),
        },
      );

      final normalized = _normalizePushResponse(
        response.data as Map<String, dynamic>,
        originalChanges: changes,
      );

      return SyncResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل رفع تغييرات المستفيدين');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏥 VISITS SYNC
  // ═══════════════════════════════════════════════════════════════════════

  /// جلب تغييرات الزيارات (Delta Sync)
  Future<PullChangesResponse<Map<String, dynamic>>> pullVisitChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{'per_page': limit, 'page': 1};
      if (since != null) {
        queryParams['updated_after'] = since.toIso8601String();
      }

      final response = await _dio.get(
        '/api/mobile/visits',
        queryParameters: queryParams,
      );

      final normalized = _normalizePullResponse(
        response.data as Map<String, dynamic>,
      );

      return PullChangesResponse<Map<String, dynamic>>.fromJson(
        normalized,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب تغييرات الزيارات');
    }
  }

  /// رفع تغييرات الزيارات للسيرفر
  Future<SyncResponse> pushVisitChanges(List<SyncChange> changes) async {
    try {
      final response = await _dio.post(
        '/api/mobile/visits/batch',
        data: {
          'changes': changes.map((c) => c.toJson()).toList(),
          'records': changes.map((c) => c.data).toList(),
        },
      );

      final normalized = _normalizePushResponse(
        response.data as Map<String, dynamic>,
        originalChanges: changes,
      );

      return SyncResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل رفع تغييرات الزيارات');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📎 ATTACHMENTS SYNC
  // ═══════════════════════════════════════════════════════════════════════

  /// رفع ملف مرفق
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String entityType,
    required String entityId,
    String? personIdentityNumber,
    String? fileType,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final resolvedPersonIdentityNumber = personIdentityNumber?.trim();
      final resolvedFileType = fileType?.trim();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (resolvedPersonIdentityNumber != null && resolvedPersonIdentityNumber.isNotEmpty)
          'person_identity_number': resolvedPersonIdentityNumber,
        if (resolvedFileType != null && resolvedFileType.isNotEmpty) 'file_type': resolvedFileType,
        if (entityType.trim().isNotEmpty) 'entity_type': entityType,
        if (entityId.trim().isNotEmpty) 'entity_id': entityId,
      });

      final response = await _dio.post(
        '/api/mobile/database/attachments',
        data: formData,
        onSendProgress: onProgress,
      );

      final root = response.data;
      if (root is Map<String, dynamic>) {
        final directUrl = root['url'];
        if (directUrl is String && directUrl.isNotEmpty) {
          return directUrl;
        }

        final dataNode = root['data'];
        if (dataNode is Map<String, dynamic>) {
          final nestedUrl = dataNode['url'];
          if (nestedUrl is String && nestedUrl.isNotEmpty) {
            return nestedUrl;
          }
        }
      }

      return '';
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل رفع الملف');
    }
  }

  /// حذف ملف مرفق
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      await _dio.delete('/api/mobile/database/attachments/$attachmentId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل حذف الملف');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 SYNC METADATA
  // ═══════════════════════════════════════════════════════════════════════

  /// الحصول على آخر timestamp من السيرفر
  ///
  /// مفيد للتأكد من تزامن الوقت بين الجهاز والسيرفر
  Future<DateTime> getServerTimestamp() async {
    try {
      final response = await _dio.get('/api/mobile/sync/timestamp');
      final root = response.data as Map<String, dynamic>;
      final timestamp = root['timestamp'] as String?;
      if (timestamp == null || timestamp.isEmpty) {
        return DateTime.now();
      }
      return DateTime.parse(timestamp);
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب وقت السيرفر');
    }
  }

  /// الحصول على معلومات حالة المزامنة من السيرفر
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final response = await _dio.get('/api/mobile/sync/status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب حالة المزامنة');
    }
  }

  String? _toCategorySlug(String? group) {
    if (group == null || group.trim().isEmpty) {
      return null;
    }

    final normalized = group.trim();
    return _taxonomyGroupToCategorySlug[normalized] ?? normalized.replaceAll('_', '-');
  }

  String _toGroupValue(String categorySlug) {
    for (final entry in _taxonomyGroupToCategorySlug.entries) {
      if (entry.value == categorySlug) {
        return entry.key;
      }
    }

    return categorySlug.replaceAll('-', '_');
  }

  Map<String, dynamic> _normalizeCategoryItemsResponse(
    Map<String, dynamic> raw, {
    required String fallbackGroup,
    required String fallbackSlug,
  }) {
    final now = DateTime.now();
    final dataNode = raw['data'];
    final items = dataNode is Map<String, dynamic>
        ? (dataNode['items'] is List ? dataNode['items'] as List : const [])
        : const [];

    final records = items.whereType<Map<String, dynamic>>().map((item) {
      final idValue = item['id']?.toString() ?? '';
      final updatedAt = (item['updated_at'] as String?) ?? now.toIso8601String();

      return {
        'id': idValue,
        'group': fallbackGroup,
        'code': (item['code'] as String?) ?? idValue,
        'label': (item['label'] as String?) ?? (item['name'] as String?) ?? (item['title'] as String?) ?? idValue,
        'parent_id': item['parent_id']?.toString(),
        'sort_order': item['sort_order'] as int? ?? 0,
        'is_active': item['is_active'] as bool? ?? true,
        'updated_at': updatedAt,
        '_category_slug': fallbackSlug,
      };
    }).toList();

    return {
      'data': records,
      'sync_timestamp': now.toIso8601String(),
      'total_count': records.length,
    };
  }

  Map<String, dynamic> _normalizeSyncAllTaxonomiesResponse(
    Map<String, dynamic> raw,
  ) {
    final now = DateTime.now();
    final dataNode = raw['data'];
    final categoriesNode = dataNode is Map<String, dynamic> ? dataNode['categories'] : null;

    final records = <Map<String, dynamic>>[];
    if (categoriesNode is Map<String, dynamic>) {
      categoriesNode.forEach((slug, value) {
        final group = _toGroupValue(slug);
        final items =
            value is Map<String, dynamic> ? (value['items'] is List ? value['items'] as List : const []) : const [];

        for (final rawItem in items.whereType<Map<String, dynamic>>()) {
          final idValue = rawItem['id']?.toString() ?? '';
          records.add({
            'id': idValue,
            'group': group,
            'code': (rawItem['code'] as String?) ?? idValue,
            'label': (rawItem['label'] as String?) ??
                (rawItem['name'] as String?) ??
                (rawItem['title'] as String?) ??
                idValue,
            'parent_id': rawItem['parent_id']?.toString(),
            'sort_order': rawItem['sort_order'] as int? ?? 0,
            'is_active': rawItem['is_active'] as bool? ?? true,
            'updated_at': (rawItem['updated_at'] as String?) ?? now.toIso8601String(),
          });
        }
      });
    }

    final syncTimestamp = dataNode is Map<String, dynamic> ? (dataNode['sync_timestamp'] as String?) : null;

    return {
      'data': records,
      'sync_timestamp': syncTimestamp ?? now.toIso8601String(),
      'total_count': records.length,
    };
  }

  Map<String, dynamic> _normalizePullResponse(Map<String, dynamic> raw) {
    final now = DateTime.now();
    final dataNode = raw['data'];

    List<dynamic> records = const [];
    Map<String, dynamic> pagination = const {};
    String? syncTimestamp;

    if (dataNode is Map<String, dynamic>) {
      final candidateRecords = dataNode['records'];
      if (candidateRecords is List) {
        records = candidateRecords;
      }

      final paginationNode = dataNode['pagination'];
      if (paginationNode is Map<String, dynamic>) {
        pagination = paginationNode;
      }

      syncTimestamp = dataNode['sync_timestamp'] as String?;
    }

    if (records.isEmpty && raw['data'] is List) {
      records = raw['data'] as List;
    }

    final currentPage = (pagination['current_page'] as int?) ?? (pagination['page'] as int?) ?? 1;
    final lastPage = (pagination['last_page'] as int?) ?? currentPage;
    final perPage = (pagination['per_page'] as int?) ?? records.length;
    final total = (pagination['total'] as int?) ?? records.length;
    final hasMore = (pagination['has_more'] as bool?) ?? (currentPage < lastPage);

    return {
      'data': records,
      'pagination': {
        'total': total,
        'page': currentPage,
        'per_page': perPage,
        'has_more': hasMore,
      },
      'sync_timestamp': syncTimestamp ?? now.toIso8601String(),
    };
  }

  Map<String, dynamic> _normalizePushResponse(
    Map<String, dynamic> raw, {
    required List<SyncChange> originalChanges,
  }) {
    if (raw.containsKey('success') && raw.containsKey('conflicts') && raw.containsKey('errors')) {
      return raw;
    }

    final successRows = <Map<String, dynamic>>[];
    final dataNode = raw['data'];

    final created =
        dataNode is Map<String, dynamic> && dataNode['created'] is List ? dataNode['created'] as List : const [];
    final updated =
        dataNode is Map<String, dynamic> && dataNode['updated'] is List ? dataNode['updated'] as List : const [];

    final changedIds = <String>{
      ...created.map((e) => e.toString()),
      ...updated.map((e) => e.toString()),
    };

    for (final change in originalChanges) {
      final data = change.data;
      final localId = data['id']?.toString() ?? data['file_id_number']?.toString();

      if (localId != null && changedIds.contains(localId)) {
        successRows.add({
          'client_id': change.clientId,
          'server_id': int.tryParse(localId) ?? 0,
          'status': 'synced',
        });
      }
    }

    if (successRows.isEmpty && (raw['success'] == true)) {
      for (final change in originalChanges) {
        successRows.add({
          'client_id': change.clientId,
          'server_id': 0,
          'status': 'synced',
        });
      }
    }

    return {
      'success': successRows,
      'conflicts': <Map<String, dynamic>>[],
      'errors': <Map<String, dynamic>>[],
    };
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔧 ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════════════

  /// معالجة أخطاء Dio وتحويلها لرسائل مفهومة
  Exception _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('انتهت مهلة الاتصال - تحقق من الإنترنت');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('خطأ في الاتصال - تحقق من الإنترنت');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return Exception(
            'بيانات غير صحيحة: ${data?['message'] ?? defaultMessage}',
          );
        case 401:
          return Exception('غير مصرح - يرجى تسجيل الدخول مرة أخرى');
        case 403:
          return Exception('ليس لديك صلاحية لهذه العملية');
        case 404:
          return Exception('العنصر غير موجود');
        case 409:
          return Exception('تعارض في البيانات');
        case 422:
          return Exception('خطأ في التحقق من البيانات');
        case 500:
          return Exception('خطأ في السيرفر - حاول مرة أخرى لاحقاً');
        default:
          return Exception('$defaultMessage (Code: $statusCode)');
      }
    }

    return Exception(defaultMessage);
  }
}

/// 📦 Response Model - Taxonomy Sync
class TaxonomySyncResponse {
  final List<TaxonomyDTO> data;
  final DateTime syncTimestamp;
  final int totalCount;

  const TaxonomySyncResponse({
    required this.data,
    required this.syncTimestamp,
    required this.totalCount,
  });

  factory TaxonomySyncResponse.fromJson(Map<String, dynamic> json) {
    return TaxonomySyncResponse(
      data: (json['data'] as List).map((item) => TaxonomyDTO.fromJson(item as Map<String, dynamic>)).toList(),
      syncTimestamp: DateTime.parse(json['sync_timestamp'] as String),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
