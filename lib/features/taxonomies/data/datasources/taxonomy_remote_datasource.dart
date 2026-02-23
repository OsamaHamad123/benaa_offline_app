import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import '../models/taxonomy_dto.dart';
import '../../domain/entities/taxonomy_group.dart';

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

  /// جلب المجموعات المتاحة
  Future<TaxonomyGroupsResponseDTO> getGroups();

  /// إنشاء تصنيف جديد
  Future<TaxonomyResponseDTO> createTaxonomy(TaxonomyRequestDTO request);

  /// تحديث تصنيف
  Future<TaxonomyResponseDTO> updateTaxonomy(String id, TaxonomyRequestDTO request);

  /// حذف تصنيف
  Future<void> deleteTaxonomy(String id);

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

  List<String> _groupEndpointCandidates(TaxonomyGroup group) {
    final base = group.value;
    final hyphen = base.replaceAll('_', '-');

    const aliases = <TaxonomyGroup, List<String>>{
      TaxonomyGroup.category: ['categories', 'beneficiary-categories', 'request-statuses'],
      TaxonomyGroup.governorate: ['governorates', 'provinces', 'cities'],
      TaxonomyGroup.maritalStatus: ['marital-statuses', 'social-statuses', 'social-status'],
      TaxonomyGroup.displacementStatus: ['displacement-statuses', 'displacement-status'],
      TaxonomyGroup.employmentStatus: ['employment-statuses', 'job-statuses', 'job-status'],
      TaxonomyGroup.educationLevel: ['education-levels', 'educational-levels', 'academic-degrees'],
      TaxonomyGroup.healthStatus: ['health-statuses', 'health-conditions'],
      TaxonomyGroup.housingType: ['housing-types', 'residence-types', 'accommodation-types'],
      TaxonomyGroup.housingStatus: ['housing-statuses', 'housing-conditions', 'residence-status'],
      TaxonomyGroup.disabilityType: ['disability-types', 'special-needs-types'],
      TaxonomyGroup.incomeSource: ['income-sources', 'income'],
      TaxonomyGroup.associationType: ['association-types', 'associations-types'],
      TaxonomyGroup.sponsorshipType: ['sponsorship-types', 'sponsorship-categories', 'sponsorship', 'guarantee-types'],
      TaxonomyGroup.gender: ['genders', 'sex'],
      TaxonomyGroup.visitType: ['visit-types', 'visits-types'],
      TaxonomyGroup.assistanceType: ['assistance-types', 'aid-types', 'aid-statuses'],
      TaxonomyGroup.beneficiaryStatus: [
        'beneficiary-statuses',
        'beneficiary-state',
        'aid-statuses',
        'request-statuses'
      ],
      TaxonomyGroup.relationship: ['relationships', 'kinship', 'relations'],
      TaxonomyGroup.section: ['sections', 'departments', 'department'],
    };

    final out = <String>[base, hyphen];
    out.addAll(aliases[group] ?? const []);

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
        return TaxonomyResponseDTO.fromJson(response.data as Map<String, dynamic>);
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
        return TaxonomyResponseDTO.fromJson(response.data as Map<String, dynamic>);
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
  Future<void> deleteTaxonomy(String id) async {
    DioException? lastDioError;
    final remoteId = TaxonomyDTO.extractRemoteId(id);

    for (final categorySlug in _allCategorySlugCandidates()) {
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
    return status == 404 || status == 405;
  }

  @override
  Future<TaxonomySyncResponseDTO> syncTaxonomies(TaxonomySyncRequestDTO request) async {
    try {
      final response = await _withRetry(
        () => _dio.post(
          '$_basePath/sync',
          data: request.toJson(),
        ),
      );
      return TaxonomySyncResponseDTO.fromJson(response.data);
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
