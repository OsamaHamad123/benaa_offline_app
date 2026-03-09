import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../models/taxonomy_dto.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';

/// 🌐 Taxonomy Remote Data Source
///
/// مصدر البيانات من API للتصنيفات
abstract class TaxonomyRemoteDataSource {
  /// جلب جميع التصنيفات
  Future<TaxonomiesResponseDTO> getAllTaxonomies({DateTime? since});

  /// جلب التصنيفات حسب المجموعة
  Future<TaxonomiesResponseDTO> getTaxonomiesByGroup(TaxonomyGroup group);

  /// جلب التصنيفات حسب slug مباشر من كتالوج السيرفر
  Future<TaxonomiesResponseDTO> getTaxonomiesBySlug(String slug);

  /// جلب عنصر واحد من مجموعة معينة
  Future<TaxonomyResponseDTO> getTaxonomyById(String group, String id);

  /// جلب المجموعات المتاحة
  Future<TaxonomyGroupsResponseDTO> getGroups();

  /// إنشاء تصنيف جديد
  Future<TaxonomyResponseDTO> createTaxonomy(TaxonomyRequestDTO request);

  /// تحديث تصنيف
  Future<TaxonomyResponseDTO> updateTaxonomy(String id, TaxonomyRequestDTO request);

  /// حذف تصنيف
  Future<void> deleteTaxonomy(String id, {String? group});

  /// إنشاء عدة تصنيفات دفعة واحدة
  Future<List<TaxonomyDTO>> createTaxonomiesBatch(String group, List<String> names);

  /// تحديث عدة تصنيفات دفعة واحدة
  Future<List<TaxonomyDTO>> updateTaxonomiesBatch(String group, Map<String, String> updates);

  /// حذف عدة تصنيفات دفعة واحدة
  Future<List<String>> deleteTaxonomiesBatch(String group, List<String> ids);

  /// مزامنة التصنيفات
  Future<TaxonomySyncResponseDTO> syncTaxonomies(TaxonomySyncRequestDTO request);
}

/// 🔌 Implementation
class TaxonomyRemoteDataSourceImpl implements TaxonomyRemoteDataSource {
  final Dio _dio;

  // ✅ Using categories endpoint as per API documentation
  static const String _basePath = '/api/mobile/categories';
  static final Options _nonThrowing4xxOptions = Options(
    validateStatus: (status) => status != null && status < 500,
  );

  TaxonomyRemoteDataSourceImpl(this._dio);

  Future<T> _withRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
  }) async {
    DioException? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await action();
      } on DioException catch (e) {
        lastError = e;
        final retryable = _isRetryableDioError(e);
        if (!retryable || attempt >= maxAttempts) {
          rethrow;
        }

        final delay = Duration(milliseconds: 300 * (1 << (attempt - 1)) + (attempt * 80));
        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Request failed without DioException');
  }

  bool _isRetryableDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status != null && (status == 429 || status >= 500)) {
      return true;
    }

    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  @override
  Future<TaxonomiesResponseDTO> getAllTaxonomies({DateTime? since}) async {
    try {
      final stopwatch = Stopwatch()..start();
      // Use sync-all endpoint for full or incremental sync
      final response = await _withRetry(
        () => _dio.get(
          '$_basePath/sync-all',
          queryParameters: since != null ? {'updated_after': since.toIso8601String()} : null,
        ),
      );
      stopwatch.stop();
      final parsed = TaxonomiesResponseDTO.fromSyncAllJson(response.data);
      _logSyncAllDiagnostics(response.data, parsed);
      if (parsed.data.isEmpty) {
        developer.log(
          'sync-all returned empty parsed list in ${stopwatch.elapsedMilliseconds}ms',
          name: 'TaxonomySync',
        );
      }
      return parsed;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  void _logSyncAllDiagnostics(dynamic raw, TaxonomiesResponseDTO parsed) {
    final parsedGroups = parsed.data.map((item) => item.groupValue).toSet();

    if (parsedGroups.length >= 8) {
      return;
    }

    final dataNode = raw is Map<String, dynamic> ? raw['data'] : null;
    final dataKeys = dataNode is Map<String, dynamic> ? dataNode.keys.join(', ') : 'non-map-data';
    final categoriesNode = dataNode is Map<String, dynamic> ? dataNode['categories'] : null;
    final categoriesShape = categoriesNode == null
        ? 'none'
        : categoriesNode is List
            ? 'list(${categoriesNode.length})'
            : categoriesNode is Map<String, dynamic>
                ? 'map(${categoriesNode.length})'
                : categoriesNode.runtimeType.toString();

    String firstCategoryDebug = 'n/a';
    if (categoriesNode is Map<String, dynamic> && categoriesNode.isNotEmpty) {
      final firstEntry = categoriesNode.entries.first;
      final firstValue = firstEntry.value;
      if (firstValue is Map<String, dynamic>) {
        firstCategoryDebug = 'key=${firstEntry.key}, valueType=map, keys=[${firstValue.keys.take(10).join(', ')}]';
      } else if (firstValue is List) {
        firstCategoryDebug = 'key=${firstEntry.key}, valueType=list(${firstValue.length})';
      } else {
        firstCategoryDebug = 'key=${firstEntry.key}, valueType=${firstValue.runtimeType}';
      }
    }

    developer.log(
      'Taxonomy sync-all low coverage: parsedGroups=${parsedGroups.length}, '
      'items=${parsed.data.length}, dataKeys=[$dataKeys], categoriesShape=$categoriesShape, '
      'groups=[${parsedGroups.join(', ')}], firstCategory={$firstCategoryDebug}',
      name: 'TaxonomySync',
    );
  }

  @override
  Future<TaxonomiesResponseDTO> getTaxonomiesByGroup(TaxonomyGroup group) async {
    final candidates = _groupEndpointCandidates(group);
    TaxonomyApiException? lastHandledError;

    try {
      for (final candidate in candidates) {
        try {
          final response = await _withRetry(
            () => _dio.get(
              '$_basePath/$candidate',
              options: _nonThrowing4xxOptions,
            ),
          );

          final statusCode = response.statusCode;
          if (statusCode == 404 || statusCode == 405) {
            continue;
          }

          if (statusCode != null && statusCode >= 400) {
            throw TaxonomyApiException(
              'فشل جلب تصنيفات ${group.arabicName}',
              statusCode,
            );
          }

          final parsed = TaxonomiesResponseDTO.fromGroupJson(
            response.data,
            fallbackGroup: group.value,
          );

          if (parsed.success && parsed.data.isNotEmpty) {
            return parsed;
          }
        } on DioException catch (e) {
          final handled = _handleDioError(e);
          if (handled is TaxonomyApiException) {
            lastHandledError = handled;
          }
          continue;
        }
      }

      if (lastHandledError != null) {
        throw lastHandledError;
      }

      return const TaxonomiesResponseDTO(success: true, data: []);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomiesResponseDTO> getTaxonomiesBySlug(String slug) async {
    final normalizedSlug = slug.trim();
    if (normalizedSlug.isEmpty) {
      return const TaxonomiesResponseDTO(success: true, data: []);
    }

    try {
      final response = await _withRetry(
        () => _dio.get(
          '$_basePath/$normalizedSlug',
          options: _nonThrowing4xxOptions,
        ),
      );

      final statusCode = response.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        return const TaxonomiesResponseDTO(success: true, data: []);
      }

      if (statusCode != null && statusCode >= 400) {
        throw TaxonomyApiException('فشل جلب التصنيفات ($normalizedSlug)', statusCode);
      }

      return TaxonomiesResponseDTO.fromGroupJson(
        response.data,
        fallbackGroup: normalizedSlug,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> getTaxonomyById(String group, String id) async {
    final remoteId = TaxonomyDTO.extractRemoteId(id);
    DioException? lastDioError;

    for (final categorySlug in _categorySlugCandidatesFromGroup(group)) {
      try {
        final response = await _withRetry(
          () => _dio.get(
            '$_basePath/$categorySlug/$remoteId',
            options: _nonThrowing4xxOptions,
          ),
        );

        final statusCode = response.statusCode;
        if (statusCode == 404 || statusCode == 405) {
          continue;
        }

        if (statusCode != null && statusCode >= 400) {
          throw TaxonomyApiException('فشل جلب عنصر التصنيف', statusCode);
        }

        final parsed = _parseTaxonomyFromResponse(
          response.data,
          fallbackGroup: group,
          fallbackId: remoteId,
        );
        if (parsed == null) {
          continue;
        }

        return TaxonomyResponseDTO(
          success: true,
          data: parsed,
          message: (response.data is Map<String, dynamic>) ? response.data['message']?.toString() : null,
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
      lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/$remoteId')),
    );
  }

  List<String> _groupEndpointCandidates(TaxonomyGroup group) {
    final base = group.value;
    final hyphen = base.replaceAll('_', '-');

    final out = <String>[base, hyphen];
    out.addAll(beneficiaryTaxonomyServerAliases[group] ?? const []);

    final seen = <String>{};
    final unique = <String>[];
    for (final item in out) {
      final normalized = item.trim();
      if (normalized.isEmpty) continue;
      if (seen.add(normalized)) unique.add(normalized);
    }
    return unique;
  }

  @override
  Future<TaxonomyGroupsResponseDTO> getGroups() async {
    try {
      final groupsResponse = await _withRetry(
        () => _dio.get(
          '$_basePath/groups',
          options: _nonThrowing4xxOptions,
        ),
      );

      final groupsStatusCode = groupsResponse.statusCode;
      if (groupsStatusCode != null && groupsStatusCode < 400) {
        final parsedGroups = TaxonomyGroupsResponseDTO.fromJson(groupsResponse.data);
        if (parsedGroups.data.isNotEmpty) {
          return parsedGroups;
        }
      }

      // Fallback to documented catalog endpoint: GET /api/mobile/categories
      final catalogResponse = await _withRetry(
        () => _dio.get(
          _basePath,
          options: _nonThrowing4xxOptions,
        ),
      );

      final catalogStatusCode = catalogResponse.statusCode;
      if (catalogStatusCode == 404 || catalogStatusCode == 405) {
        return const TaxonomyGroupsResponseDTO(success: true, data: []);
      }

      if (catalogStatusCode != null && catalogStatusCode >= 400) {
        throw TaxonomyApiException('فشل جلب مجموعات التصنيفات', catalogStatusCode);
      }

      return TaxonomyGroupsResponseDTO.fromJson(catalogResponse.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> createTaxonomy(TaxonomyRequestDTO request) async {
    DioException? lastDioError;
    final payload = _buildCategoryMutationPayload(request);

    for (final categorySlug in _categorySlugCandidatesFromGroup(request.group)) {
      try {
        final response = await _withRetry(
          () => _dio.post(
            '$_basePath/$categorySlug',
            data: payload,
          ),
        );
        final parsed = _parseTaxonomyFromResponse(
          response.data,
          fallbackGroup: request.group,
          fallbackCode: request.code,
          fallbackLabel: request.label,
        );
        if (parsed == null) {
          throw TaxonomyApiException('تعذر قراءة بيانات التصنيف المُنشأ');
        }
        return TaxonomyResponseDTO(
          success: true,
          data: parsed,
          message: (response.data is Map<String, dynamic>) ? response.data['message']?.toString() : null,
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}')));
  }

  @override
  Future<TaxonomyResponseDTO> updateTaxonomy(String id, TaxonomyRequestDTO request) async {
    DioException? lastDioError;
    final payload = _buildCategoryMutationPayload(request);
    final remoteId = TaxonomyDTO.extractRemoteId(id);

    for (final categorySlug in _categorySlugCandidatesFromGroup(request.group)) {
      try {
        final response = await _withRetry(
          () => _dio.put(
            '$_basePath/$categorySlug/$remoteId',
            data: payload,
          ),
        );
        final parsed = _parseTaxonomyFromResponse(
          response.data,
          fallbackGroup: request.group,
          fallbackId: remoteId,
          fallbackCode: request.code,
          fallbackLabel: request.label,
        );
        if (parsed == null) {
          throw TaxonomyApiException('تعذر قراءة بيانات التصنيف المحدّث');
        }
        return TaxonomyResponseDTO(
          success: true,
          data: parsed,
          message: (response.data is Map<String, dynamic>) ? response.data['message']?.toString() : null,
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
        lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/$remoteId')));
  }

  @override
  Future<void> deleteTaxonomy(String id, {String? group}) async {
    DioException? lastDioError;
    final remoteId = TaxonomyDTO.extractRemoteId(id);
    final categoryCandidates = (group != null && group.trim().isNotEmpty)
        ? _categorySlugCandidatesFromGroup(group)
        : _allCategorySlugCandidates();

    for (final categorySlug in categoryCandidates) {
      try {
        await _withRetry(() => _dio.delete('$_basePath/$categorySlug/$remoteId'));
        return;
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
        lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/$remoteId')));
  }

  @override
  Future<List<TaxonomyDTO>> createTaxonomiesBatch(String group, List<String> names) async {
    DioException? lastDioError;
    final payload = {
      'items': names.map((name) => {'name': name}).toList(growable: false),
    };

    for (final categorySlug in _categorySlugCandidatesFromGroup(group)) {
      try {
        final response = await _withRetry(
          () => _dio.post(
            '$_basePath/$categorySlug/batch',
            data: payload,
          ),
        );

        return _extractBatchTaxonomies(
          response.data,
          key: 'created',
          fallbackGroup: group,
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
      lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/batch')),
    );
  }

  @override
  Future<List<TaxonomyDTO>> updateTaxonomiesBatch(String group, Map<String, String> updates) async {
    DioException? lastDioError;
    final payload = {
      'items': updates.entries
          .map((entry) => {'id': TaxonomyDTO.extractRemoteId(entry.key), 'name': entry.value})
          .toList(growable: false),
    };

    for (final categorySlug in _categorySlugCandidatesFromGroup(group)) {
      try {
        final response = await _withRetry(
          () => _dio.put(
            '$_basePath/$categorySlug/batch',
            data: payload,
          ),
        );

        return _extractBatchTaxonomies(
          response.data,
          key: 'updated',
          fallbackGroup: group,
        );
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
      lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/batch')),
    );
  }

  @override
  Future<List<String>> deleteTaxonomiesBatch(String group, List<String> ids) async {
    DioException? lastDioError;
    final payload = {
      'ids': ids.map(TaxonomyDTO.extractRemoteId).toList(growable: false),
    };

    for (final categorySlug in _categorySlugCandidatesFromGroup(group)) {
      try {
        final response = await _withRetry(
          () => _dio.delete(
            '$_basePath/$categorySlug/batch',
            data: payload,
          ),
        );

        final rawDeleted = _extractCollectionNode(response.data, key: 'deleted');
        return rawDeleted
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['id']?.toString() ?? '';
              }
              return item?.toString() ?? '';
            })
            .where((id) => id.isNotEmpty)
            .toList(growable: false);
      } on DioException catch (e) {
        lastDioError = e;
        if (_isFallbackCategoryError(e)) {
          continue;
        }
        throw _handleDioError(e);
      }
    }

    throw _handleDioError(
      lastDioError ?? DioException(requestOptions: RequestOptions(path: '$_basePath/{category}/batch')),
    );
  }

  Map<String, dynamic> _buildCategoryMutationPayload(TaxonomyRequestDTO request) {
    final name = request.label.trim().isNotEmpty ? request.label.trim() : request.code.trim();

    return {
      'name': name,
      if (request.labelEn != null && request.labelEn!.trim().isNotEmpty) 'name_en': request.labelEn!.trim(),
      if (request.code.trim().isNotEmpty) 'code': request.code.trim(),
    };
  }

  List<String> _categorySlugCandidatesFromGroup(String group) {
    final normalizedGroup = TaxonomyGroup.normalizeValue(group) ?? group;
    final taxonomyGroup = TaxonomyGroup.fromString(normalizedGroup);

    if (taxonomyGroup != null) {
      return _groupEndpointCandidates(taxonomyGroup);
    }

    final fallback = <String>[
      normalizedGroup,
      normalizedGroup.replaceAll('_', '-'),
      group,
      group.replaceAll('_', '-'),
    ];

    final seen = <String>{};
    final unique = <String>[];
    for (final item in fallback) {
      final candidate = item.trim();
      if (candidate.isEmpty) continue;
      if (seen.add(candidate)) {
        unique.add(candidate);
      }
    }

    return unique;
  }

  List<String> _allCategorySlugCandidates() {
    final all = <String>[];
    for (final group in TaxonomyGroup.values) {
      all.addAll(_groupEndpointCandidates(group));
    }

    final seen = <String>{};
    final unique = <String>[];
    for (final candidate in all) {
      if (seen.add(candidate)) {
        unique.add(candidate);
      }
    }

    return unique;
  }

  bool _isFallbackCategoryError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 404 || status == 405) {
      return true;
    }

    if (status == 400 || status == 422) {
      final message = _extractErrorMessage(e.response?.data).toLowerCase();
      if (message.isEmpty) {
        return false;
      }

      const fallbackSignals = <String>[
        'category',
        'categories',
        'invalid category',
        'unsupported category',
        'unknown category',
        'must be one of',
        'غير صالح',
        'فئة',
        'تصنيف',
      ];

      return fallbackSignals.any(message.contains);
    }

    return false;
  }

  String _extractErrorMessage(dynamic payload) {
    if (payload == null) return '';
    if (payload is String) return payload;

    if (payload is Map) {
      final direct = payload['message'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct;
      }

      final error = payload['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }

      final errors = payload['errors'];
      if (errors is Map) {
        final buffer = StringBuffer();
        errors.forEach((_, value) {
          if (value is List && value.isNotEmpty) {
            buffer.write(' ${value.join(' ')}');
          } else if (value is String) {
            buffer.write(' $value');
          }
        });
        return buffer.toString().trim();
      }
    }

    return payload.toString();
  }

  TaxonomyDTO? _parseTaxonomyFromResponse(
    dynamic payload, {
    required String fallbackGroup,
    String? fallbackId,
    String? fallbackCode,
    String? fallbackLabel,
  }) {
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final data = payload['data'];
    Map<String, dynamic>? item;
    String? groupFromResponse;

    if (data is Map<String, dynamic>) {
      if (data['item'] is Map<String, dynamic>) {
        item = Map<String, dynamic>.from(data['item'] as Map<String, dynamic>);
      } else {
        final likelyItem = <String>{'id', 'name', 'label', 'code', 'created_at', 'updated_at'};
        if (likelyItem.any(data.containsKey)) {
          item = Map<String, dynamic>.from(data);
        }
      }

      final categoryNode = data['category'];
      if (categoryNode is Map<String, dynamic>) {
        groupFromResponse = (categoryNode['slug'] ?? categoryNode['name'] ?? categoryNode['group'])?.toString();
      }
    }

    item ??= payload['item'] is Map<String, dynamic> ? Map<String, dynamic>.from(payload['item'] as Map) : null;
    if (item == null) {
      return null;
    }

    final resolvedGroup = TaxonomyGroup.normalizeValue(groupFromResponse ?? fallbackGroup) ?? fallbackGroup;
    final id = (item['id'] ?? item['value'] ?? item['code'] ?? fallbackId)?.toString() ?? '';
    final label =
        (item['name'] ?? item['label'] ?? item['title'] ?? item['name_ar'] ?? item['label_ar'] ?? fallbackLabel)
                ?.toString() ??
            '';
    if (id.isEmpty || label.isEmpty) {
      return null;
    }

    final code = (item['code'] ?? item['slug'] ?? fallbackCode ?? id).toString();

    return TaxonomyDTO(
      id: id,
      groupValue: resolvedGroup,
      code: code,
      label: label,
      labelEn: (item['name_en'] ?? item['label_en'] ?? item['title_en'])?.toString(),
      parentId: item['parent_id']?.toString(),
      sortOrder: _parseInt(item['sort_order'] ?? item['sort'] ?? item['order']),
      isActive: _parseBool(item['is_active'] ?? item['active'] ?? item['enabled'], defaultValue: true),
      createdAt: _parseDateTime(item['created_at']),
      updatedAt: _parseDateTime(item['updated_at']),
      deletedAt: _parseDateTime(item['deleted_at']),
    );
  }

  List<TaxonomyDTO> _extractBatchTaxonomies(
    dynamic payload, {
    required String key,
    required String fallbackGroup,
  }) {
    final records = _extractCollectionNode(payload, key: key);
    final out = <TaxonomyDTO>[];
    final normalizedGroup = TaxonomyGroup.normalizeValue(fallbackGroup) ?? fallbackGroup;

    for (final row in records) {
      if (row is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(row);
      final id = (item['id'] ?? item['value'] ?? item['code'])?.toString() ?? '';
      final label = (item['name'] ?? item['label'] ?? item['title'])?.toString() ?? '';
      if (id.isEmpty || label.isEmpty) {
        continue;
      }

      out.add(TaxonomyDTO(
        id: id,
        groupValue: normalizedGroup,
        code: (item['code'] ?? item['slug'] ?? id).toString(),
        label: label,
        labelEn: (item['name_en'] ?? item['label_en'] ?? item['title_en'])?.toString(),
        sortOrder: _parseInt(item['sort_order'] ?? item['sort'] ?? item['order']),
        isActive: _parseBool(item['is_active'] ?? item['active'] ?? item['enabled'], defaultValue: true),
        createdAt: _parseDateTime(item['created_at']),
        updatedAt: _parseDateTime(item['updated_at']),
      ));
    }

    return out;
  }

  List<dynamic> _extractCollectionNode(dynamic payload, {required String key}) {
    if (payload is! Map) {
      return const [];
    }

    final map = Map<String, dynamic>.from(payload);
    final dataNode = map['data'];
    if (dataNode is Map<String, dynamic>) {
      final keyed = dataNode[key];
      if (keyed is List) {
        return keyed;
      }
    }

    final direct = map[key];
    if (direct is List) {
      return direct;
    }

    return const [];
  }

  int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return defaultValue;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  Future<TaxonomySyncResponseDTO> syncTaxonomies(TaxonomySyncRequestDTO request) async {
    try {
      final response = await _withRetry(
        () => _dio.get(
          '$_basePath/sync-all',
          queryParameters: request.lastSync != null
              ? {
                  'updated_after': request.lastSync!.toIso8601String(),
                }
              : null,
        ),
      );

      final parsed = TaxonomiesResponseDTO.fromSyncAllJson(response.data as Map<String, dynamic>);
      final deletedCount = parsed.data.where((item) => item.deletedAt != null).length;

      return TaxonomySyncResponseDTO(
        success: parsed.success,
        added: parsed.data.length,
        updated: 0,
        deleted: deletedCount,
        message: parsed.message,
        syncTime: parsed.syncTimestamp ?? DateTime.now(),
        taxonomies: parsed.data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] ?? e.message;

    switch (statusCode) {
      case 400:
        return TaxonomyApiException('طلب غير صالح: $message', statusCode);
      case 401:
        return TaxonomyApiException('غير مصرح', statusCode);
      case 403:
        return TaxonomyApiException('محظور', statusCode);
      case 404:
        return TaxonomyApiException('غير موجود: $message', statusCode);
      case 422:
        return TaxonomyApiException('خطأ في التحقق: $message', statusCode);
      case 500:
        return TaxonomyApiException('خطأ في السيرفر', statusCode);
      default:
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          return TaxonomyApiException('انتهت مهلة الاتصال');
        }
        if (e.type == DioExceptionType.connectionError) {
          return TaxonomyApiException('لا يوجد اتصال بالإنترنت');
        }
        return TaxonomyApiException('خطأ غير متوقع: $message', statusCode);
    }
  }
}

/// 🚨 API Exception
class TaxonomyApiException implements Exception {
  final String message;
  final int? statusCode;

  TaxonomyApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'TaxonomyApiException: $message (code: $statusCode)';
}
