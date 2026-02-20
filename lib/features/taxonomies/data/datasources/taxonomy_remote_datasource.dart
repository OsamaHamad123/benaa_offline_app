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

  @override
  Future<TaxonomiesResponseDTO> getAllTaxonomies({DateTime? since}) async {
    try {
      // Use sync-all endpoint for full or incremental sync
      final response = await _dio.get(
        '$_basePath/sync-all',
        queryParameters: since != null ? {'updated_after': since.toIso8601String()} : null,
      );
      return TaxonomiesResponseDTO.fromSyncAllJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomiesResponseDTO> getTaxonomiesByGroup(TaxonomyGroup group) async {
    try {
      final response = await _dio.get('$_basePath/${group.value}');
      return TaxonomiesResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyGroupsResponseDTO> getGroups() async {
    try {
      final response = await _dio.get('$_basePath/groups');
      return TaxonomyGroupsResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> createTaxonomy(TaxonomyRequestDTO request) async {
    try {
      final response = await _dio.post(
        _basePath,
        data: request.toJson(),
      );
      return TaxonomyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomyResponseDTO> updateTaxonomy(String id, TaxonomyRequestDTO request) async {
    try {
      final response = await _dio.put(
        '$_basePath/$id',
        data: request.toJson(),
      );
      return TaxonomyResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteTaxonomy(String id) async {
    try {
      await _dio.delete('$_basePath/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaxonomySyncResponseDTO> syncTaxonomies(TaxonomySyncRequestDTO request) async {
    try {
      final response = await _dio.post(
        '$_basePath/sync',
        data: request.toJson(),
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
