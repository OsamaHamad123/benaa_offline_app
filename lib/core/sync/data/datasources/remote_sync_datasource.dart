import 'package:dio/dio.dart';
import '../../models/sync_models.dart';
import '../../../../data/models/taxonomy_dto.dart';
import '../../../../features/beneficiaries/data/models/beneficiary_data_model.dart';

/// 🌐 Remote Sync DataSource
///
/// مسؤول عن التواصل مع السيرفر لجلب ورفع البيانات
class RemoteSyncDataSource {
  final Dio _dio;

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
      final queryParams = <String, dynamic>{};
      if (group != null) queryParams['group'] = group;
      if (since != null) queryParams['since'] = since.toIso8601String();

      final response = await _dio.get(
        '/api/v1/taxonomies',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      return TaxonomySyncResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب التصنيفات');
    }
  }

  /// جلب كل المجموعات المتاحة
  Future<List<String>> getAvailableGroups() async {
    try {
      final response = await _dio.get('/api/v1/taxonomies/groups');
      return List<String>.from(response.data['groups'] as List);
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
      final queryParams = <String, dynamic>{'limit': limit};
      if (since != null) {
        queryParams['since'] = since.toIso8601String();
      }

      final response = await _dio.get(
        '/api/v1/beneficiaries/changes',
        queryParameters: queryParams,
      );

      return PullChangesResponse<BeneficiaryDataModel>.fromJson(
        response.data as Map<String, dynamic>,
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
        '/api/v1/beneficiaries/sync',
        data: {'changes': changes.map((c) => c.toJson()).toList()},
      );

      return SyncResponse.fromJson(response.data as Map<String, dynamic>);
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
      final queryParams = <String, dynamic>{'limit': limit};
      if (since != null) {
        queryParams['since'] = since.toIso8601String();
      }

      final response = await _dio.get(
        '/api/v1/visits/changes',
        queryParameters: queryParams,
      );

      return PullChangesResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
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
        '/api/v1/visits/sync',
        data: {'changes': changes.map((c) => c.toJson()).toList()},
      );

      return SyncResponse.fromJson(response.data as Map<String, dynamic>);
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
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'entity_type': entityType,
        'entity_id': entityId,
      });

      final response = await _dio.post(
        '/api/v1/attachments/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      return response.data['url'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل رفع الملف');
    }
  }

  /// حذف ملف مرفق
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      await _dio.delete('/api/v1/attachments/$attachmentId');
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
      final response = await _dio.get('/api/v1/sync/timestamp');
      return DateTime.parse(response.data['timestamp'] as String);
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب وقت السيرفر');
    }
  }

  /// الحصول على معلومات حالة المزامنة من السيرفر
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final response = await _dio.get('/api/v1/sync/status');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل جلب حالة المزامنة');
    }
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
      data: (json['data'] as List)
          .map((item) => TaxonomyDTO.fromJson(item as Map<String, dynamic>))
          .toList(),
      syncTimestamp: DateTime.parse(json['sync_timestamp'] as String),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}
