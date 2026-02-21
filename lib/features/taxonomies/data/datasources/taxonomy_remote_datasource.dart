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
      // Use sync-all endpoint for full or incremental sync
      final response = await _withRetry(
        () => _dio.get(
          '$_basePath/sync-all',
          queryParameters: since != null ? {'updated_after': since.toIso8601String()} : null,
        ),
      );
      final parsed = TaxonomiesResponseDTO.fromSyncAllJson(response.data);
      _logSyncAllDiagnostics(response.data, parsed);
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

    developer.log(
      'Taxonomy sync-all low coverage: parsedGroups=${parsedGroups.length}, '
      'items=${parsed.data.length}, dataKeys=[$dataKeys], categoriesShape=$categoriesShape, '
      'groups=[${parsedGroups.join(', ')}]',
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
          final response = await _withRetry(() => _dio.get('$_basePath/$candidate'));
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

  List<String> _groupEndpointCandidates(TaxonomyGroup group) {
    final base = group.value;
    final hyphen = base.replaceAll('_', '-');

    const aliases = <TaxonomyGroup, List<String>>{
      TaxonomyGroup.category: ['categories', 'beneficiary-categories'],
      TaxonomyGroup.governorate: ['governorates', 'provinces', 'cities'],
      TaxonomyGroup.maritalStatus: ['marital-statuses', 'social-statuses', 'social-status'],
      TaxonomyGroup.displacementStatus: ['displacement-statuses', 'displacement-status'],
      TaxonomyGroup.employmentStatus: ['employment-statuses', 'job-statuses', 'job-status'],
      TaxonomyGroup.educationLevel: ['education-levels', 'educational-levels', 'academic-degrees'],
      TaxonomyGroup.healthStatus: ['health-statuses', 'health-conditions'],
      TaxonomyGroup.housingType: ['housing-types', 'residence-types'],
      TaxonomyGroup.housingStatus: ['housing-statuses', 'housing-conditions', 'residence-status'],
      TaxonomyGroup.disabilityType: ['disability-types', 'special-needs-types'],
      TaxonomyGroup.incomeSource: ['income-sources', 'income'],
      TaxonomyGroup.associationType: ['association-types', 'associations-types'],
      TaxonomyGroup.sponsorshipType: ['sponsorship-types', 'sponsorship-categories', 'sponsorship'],
      TaxonomyGroup.gender: ['genders', 'sex'],
      TaxonomyGroup.visitType: ['visit-types', 'visits-types'],
      TaxonomyGroup.assistanceType: ['assistance-types', 'aid-types'],
      TaxonomyGroup.beneficiaryStatus: ['beneficiary-statuses', 'beneficiary-state'],
      TaxonomyGroup.relationship: ['relationships', 'kinship'],
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
      final response = await _withRetry(() => _dio.get('$_basePath/groups'));
      return TaxonomyGroupsResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> createTaxonomy(TaxonomyRequestDTO request) async {
    try {
      final response = await _withRetry(
        () => _dio.post(
          _basePath,
          data: request.toJson(),
        ),
      );
      return TaxonomyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> updateTaxonomy(String id, TaxonomyRequestDTO request) async {
    try {
      final response = await _withRetry(
        () => _dio.put(
          '$_basePath/$id',
          data: request.toJson(),
        ),
      );
      return TaxonomyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteTaxonomy(String id) async {
    try {
      await _withRetry(() => _dio.delete('$_basePath/$id'));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
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
          return TaxonomyApiException('انتهت مهلة الاتصال', null);
        }
        if (e.type == DioExceptionType.connectionError) {
          return TaxonomyApiException('لا يوجد اتصال بالإنترنت', null);
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
