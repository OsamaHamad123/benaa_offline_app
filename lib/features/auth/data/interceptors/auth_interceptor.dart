import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/core/storage/secure_storage.dart';
import 'package:benaa_offline_app/core/utils/unified_logger.dart';
import 'package:benaa_offline_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// 🔐 Auth Interceptor للـ Dio
///
/// يقوم بـ:
/// - إضافة Authorization header تلقائياً لكل طلب
/// - تجديد الـ Token عند انتهاء الصلاحية (401)
/// - إعادة محاولة الطلب الفاشل بعد التجديد
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorage _secureStorage;
  final AuthRepository _authRepository;
  final Dio _dio;

  AuthInterceptor({
    required SecureStorage secureStorage,
    required AuthRepository authRepository,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _authRepository = authRepository,
        _dio = dio;

  // ===========================
  // 📤 REQUEST INTERCEPTOR
  // ===========================

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // الحصول على الـ Token
      final token = await _secureStorage.getAuthToken();

      if (token != null && token.isNotEmpty) {
        // إضافة Authorization header
        options.headers['Authorization'] = 'Bearer $token';
        UnifiedLogger.debug('🔐 Added auth token to request: ${options.path}');
      }

      handler.next(options);
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Failed to add auth token', error: e, stackTrace: stackTrace);
      handler.next(options);
    }
  }

  // ===========================
  // ❌ ERROR INTERCEPTOR
  // ===========================

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // التحقق من خطأ 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      UnifiedLogger.warning('⚠️ Received 401 - Attempting token refresh');

      try {
        // محاولة تجديد الـ Token
        final refreshSuccess = await _attemptTokenRefresh();

        if (refreshSuccess) {
          // إعادة محاولة الطلب الأصلي
          final retryResponse = await _retryRequest(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (e, stackTrace) {
        UnifiedLogger.error('❌ Token refresh failed', error: e, stackTrace: stackTrace);
      }
    }

    // تمرير الخطأ للمستوى التالي
    handler.next(err);
  }

  // ===========================
  // 🔄 TOKEN REFRESH
  // ===========================

  /// محاولة تجديد الـ Token
  Future<bool> _attemptTokenRefresh() async {
    try {
      final deviceId = await _authRepository.getDeviceId();
      final result = await _authRepository.refreshToken(deviceId: deviceId);

      switch (result) {
        case Failure(error: final failure):
          UnifiedLogger.error('❌ Token refresh failed: ${failure.message}');
          return false;
        case Success(value: final newToken):
          UnifiedLogger.success('✅ Token refreshed successfully');
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// إعادة محاولة الطلب بعد تجديد الـ Token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // الحصول على الـ Token الجديد
    final newToken = await _secureStorage.getAuthToken();

    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    // إعادة الطلب
    UnifiedLogger.info('🔄 Retrying request: ${requestOptions.path}');

    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ===========================
  // ✅ RESPONSE INTERCEPTOR
  // ===========================

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // يمكن إضافة معالجة إضافية للاستجابات هنا
    handler.next(response);
  }
}

/// 📦 Helper لإنشاء Dio مع Auth Interceptor
class AuthDioFactory {
  static Dio create({
    required String baseUrl,
    required SecureStorage secureStorage,
    required AuthRepository authRepository,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
    ));

    // إضافة Auth Interceptor
    dio.interceptors.add(
      AuthInterceptor(
        secureStorage: secureStorage,
        authRepository: authRepository,
        dio: dio,
      ),
    );

    // إضافة Logger Interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => UnifiedLogger.debug('🌐 DIO: $object'),
      ),
    );

    return dio;
  }
}
