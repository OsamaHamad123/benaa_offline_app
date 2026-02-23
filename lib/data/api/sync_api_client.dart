import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../dto/sync_dto.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/debug_logger.dart';

/// 🌐 Sync API Client - عميل الاتصال بالسيرفر للمزامنة
///
/// يتولى جميع الطلبات المتعلقة بالمزامنة مع السيرفر
class SyncApiClient {
  final Dio _dio;
  final String baseUrl;

  SyncApiClient({required this.baseUrl, String? authToken})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            sendTimeout: ApiConfig.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            validateStatus: (status) {
              // قبول جميع status codes لمعالجتها يدوياً
              return status != null && status < 500;
            },
          ),
        ) {
    _setupInterceptors();
  }

  /// إعداد Interceptors للـ Logging والمعالجة
  void _setupInterceptors() {
    // Logging Interceptor (في وضع Debug فقط)
    if (kDebugMode && ApiConfig.logNetworkRequests) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: ApiConfig.logNetworkResponses,
          responseHeader: false,
          responseBody: ApiConfig.logNetworkResponses,
          logPrint: (obj) => DebugLogger.info('🌐 $obj'),
        ),
      );
    }

    // Retry Interceptor للمحاولة مرة أخرى عند الفشل
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // إعادة المحاولة للأخطاء المؤقتة
          if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
            error.requestOptions.extra['retryCount'] = 0;
          }

          if (error.requestOptions.extra['retryCount'] != null) {
            final retryCount = error.requestOptions.extra['retryCount'] as int;
            if (retryCount < ApiConfig.maxRetries) {
              error.requestOptions.extra['retryCount'] = retryCount + 1;

              DebugLogger.warning(
                '⚠️ Retrying request (${retryCount + 1}/${ApiConfig.maxRetries})...',
              );

              // انتظار قبل إعادة المحاولة (exponential backoff)
              await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// التحقق من إمكانية إعادة المحاولة
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  // ===========================
  // 🔄 SYNC METHODS
  // ===========================

  /// 🔄 مزامنة البيانات مع السيرفر
  Future<SyncResponseDto> syncData(SyncRequestDto request) async {
    try {
      DebugLogger.info(
        '📤 Sending sync request with ${request.pendingChanges.length} pending changes...',
      );

      final response = await _dio.post(
        ApiConfig.batchDataSyncEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        DebugLogger.success('✅ Sync response received successfully');
        return SyncResponseDto.fromJson(response.data);
      } else if (response.statusCode == 409) {
        // Conflict - تعارض في البيانات
        DebugLogger.warning('⚠️ Sync conflict detected');
        return SyncResponseDto.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw SyncException(
          'غير مصرح - يرجى تسجيل الدخول مرة أخرى',
          code: 'UNAUTHORIZED',
        );
      } else {
        throw SyncException(
          'فشلت المزامنة: ${response.statusCode}',
          code: 'SYNC_FAILED',
        );
      }
    } on DioException catch (e) {
      DebugLogger.error('❌ Sync API error', e);
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('❌ Unexpected sync error', e);
      throw SyncException('خطأ غير متوقع في المزامنة');
    }
  }

  /// 📥 تحميل البيانات الأولية (عند أول استخدام)
  Future<SyncResponseDto> fetchInitialData() async {
    try {
      DebugLogger.info('📥 Fetching initial data from server...');

      final response = await _dio.get(ApiConfig.initialDataEndpoint);

      if (response.statusCode == 200) {
        DebugLogger.success('✅ Initial data received');
        return SyncResponseDto.fromJson(response.data);
      } else {
        throw SyncException('فشل تحميل البيانات الأولية');
      }
    } on DioException catch (e) {
      DebugLogger.error('❌ Failed to fetch initial data', e);
      throw _handleDioException(e);
    }
  }

  /// 🔍 التحقق من حالة السيرفر والمزامنة
  Future<SyncStatusResponse> checkSyncStatus() async {
    try {
      final response = await _dio.get(ApiConfig.syncStatusEndpoint);

      if (response.statusCode == 200) {
        return SyncStatusResponse(
          available: true,
          serverTime: DateTime.parse(response.data['serverTime']),
          version: response.data['version'],
        );
      } else {
        return SyncStatusResponse(available: false);
      }
    } catch (e) {
      DebugLogger.warning('⚠️ Failed to check sync status');
      return SyncStatusResponse(available: false);
    }
  }

  /// 📤 رفع بيانات معينة فقط (مزامنة جزئية)
  Future<bool> uploadChanges(List<PendingChangeDto> changes) async {
    try {
      DebugLogger.info('📤 Uploading ${changes.length} changes...');

      final response = await _dio.post(
        ApiConfig.batchDataSyncEndpoint,
        data: {'changes': changes.map((c) => c.toJson()).toList()},
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      DebugLogger.error('❌ Failed to upload changes', e);
      return false;
    }
  }

  /// 📥 تحميل بيانات معينة فقط
  Future<List<ServerEntityDto>> downloadEntities({
    required String entityType,
    DateTime? since,
  }) async {
    try {
      DebugLogger.info('📥 Downloading $entityType entities...');

      final queryParams = {
        'type': entityType,
        if (since != null) 'since': since.toIso8601String(),
      };

      final response = await _dio.get(
        ApiConfig.syncEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['entities'];
        return data.map((e) => ServerEntityDto.fromJson(e)).toList();
      } else {
        throw SyncException('فشل تحميل البيانات');
      }
    } on DioException catch (e) {
      DebugLogger.error('❌ Failed to download entities', e);
      throw _handleDioException(e);
    }
  }

  // ===========================
  // 🔐 AUTH METHODS
  // ===========================

  /// 🔑 تسجيل الدخول
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      DebugLogger.info('🔐 Attempting login...');

      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        DebugLogger.success('✅ Login successful');
        return LoginResponseDto.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return LoginResponseDto(
          success: false,
          message: 'البريد الإلكتروني أو كلمة السر غير صحيحة',
          errorCode: 'INVALID_CREDENTIALS',
        );
      } else {
        return LoginResponseDto(
          success: false,
          message: 'فشل تسجيل الدخول',
          errorCode: 'LOGIN_FAILED',
        );
      }
    } on DioException catch (e) {
      DebugLogger.error('❌ Login failed', e);
      return LoginResponseDto(
        success: false,
        message: _getDioErrorMessage(e),
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  /// 🚪 تسجيل الخروج
  Future<bool> logout() async {
    try {
      final response = await _dio.post(ApiConfig.logoutEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      DebugLogger.warning('⚠️ Logout request failed');
      return false; // يمكن تجاهل فشل تسجيل الخروج
    }
  }

  /// 🔄 تحديث Token
  Future<String?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data['token'];
      }
      return null;
    } catch (e) {
      DebugLogger.error('❌ Failed to refresh token', e);
      return null;
    }
  }

  // ===========================
  // 🛠️ HELPER METHODS
  // ===========================

  /// معالجة أخطاء Dio وتحويلها لـ SyncException
  SyncException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return SyncException('انتهت مهلة الاتصال', code: 'TIMEOUT');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return SyncException('انتهت مهلة استقبال البيانات', code: 'TIMEOUT');
    } else if (e.type == DioExceptionType.sendTimeout) {
      return SyncException('انتهت مهلة إرسال البيانات', code: 'TIMEOUT');
    } else if (e.type == DioExceptionType.connectionError) {
      return SyncException('فشل الاتصال بالسيرفر', code: 'CONNECTION_ERROR');
    } else if (e.response?.statusCode == 401) {
      return SyncException(
        'غير مصرح - يرجى تسجيل الدخول مرة أخرى',
        code: 'UNAUTHORIZED',
      );
    } else if (e.response?.statusCode == 404) {
      return SyncException('العنوان غير موجود', code: 'NOT_FOUND');
    } else if (e.response?.statusCode == 500) {
      return SyncException('خطأ في السيرفر', code: 'SERVER_ERROR');
    } else {
      return SyncException('فشل الاتصال بالسيرفر', code: 'UNKNOWN');
    }
  }

  /// الحصول على رسالة الخطأ من DioException
  String _getDioErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالسيرفر';
    } else if (e.response?.statusCode == 401) {
      return 'البريد الإلكتروني أو كلمة السر غير صحيحة';
    } else if (e.response?.statusCode == 404) {
      return 'رابط السيرفر غير صحيح';
    } else {
      return 'فشل الاتصال بالسيرفر';
    }
  }

  /// تحديث Auth Token
  void updateAuthToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
    DebugLogger.info('🔄 Auth token updated in API client');
  }

  /// إلغاء Auth Token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    DebugLogger.info('🗑️ Auth token cleared from API client');
  }
}

// ===========================
// 📋 HELPER CLASSES
// ===========================

/// استثناء المزامنة
class SyncException implements Exception {
  final String message;
  final String? code;

  SyncException(this.message, {this.code});

  @override
  String toString() => 'SyncException: $message${code != null ? ' ($code)' : ''}';
}

/// استجابة حالة المزامنة
class SyncStatusResponse {
  final bool available;
  final DateTime? serverTime;
  final String? version;

  SyncStatusResponse({required this.available, this.serverTime, this.version});
}
