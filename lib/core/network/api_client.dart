import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../config/app_config.dart';
import '../security/auth_session_events.dart';
import '../storage/secure_store.dart';
import '../storage/secure_storage.dart';
import '../errors/failure.dart';

class ApiClient {
  static const String _retriedKey = 'x-auth-retried';

  late final Dio _dio;
  final AppConfig config;
  final Logger _logger = Logger();

  /// Expose Dio instance for custom usage (e.g., sync datasources)
  Dio get dio => _dio;

  ApiClient(this.config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options.path)) {
      final storage = SecureStorage();
      final isExpired = await storage.isTokenExpired();
      if (isExpired) {
        await _clearSessionOnUnauthorized();
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {
                'error': 'token_expired',
                'message': 'Token expired locally',
              },
            ),
            error: 'Token expired locally',
          ),
        );
        return;
      }
    }

    // Add auth token if available
    final token = await SecureStore.getAccessToken() ?? await SecureStorage().getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    _logger.d('Request: ${options.method} ${options.path}');
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      'Response: ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e(
      'Error: ${err.message}',
      error: err.error,
      stackTrace: err.stackTrace,
    );

    final requestOptions = err.requestOptions;
    final isAlreadyRetried = requestOptions.extra[_retriedKey] == true;
    final shouldHandle401 =
        err.response?.statusCode == 401 && !_isAuthEndpoint(requestOptions.path) && !isAlreadyRetried;

    // Handle 401 unauthorized - try to refresh token
    if (shouldHandle401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the failed request
        try {
          requestOptions.extra[_retriedKey] = true;
          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // If retry fails, continue with error
        }
      } else {
        await _clearSessionOnUnauthorized();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final storage = SecureStorage();
      final accessToken = await storage.getAuthToken();
      if (accessToken == null || accessToken.isEmpty) return false;

      final deviceId = await storage.getDeviceId();

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'device_id': deviceId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          final tokenObj = payload['token'];
          if (tokenObj is Map<String, dynamic>) {
            final newAccessToken = tokenObj['access_token']?.toString();
            final expiresAtRaw = tokenObj['expires_at']?.toString();

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              if (expiresAtRaw != null && expiresAtRaw.isNotEmpty) {
                final expiresAt = DateTime.tryParse(expiresAtRaw);
                if (expiresAt != null) {
                  await storage.updateToken(accessToken: newAccessToken, expiresAt: expiresAt);
                  return true;
                }
              }

              await storage.updateAuthToken(newAccessToken);
              return true;
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
    }
    return false;
  }

  bool _isAuthEndpoint(String path) {
    return path == ApiConfig.loginEndpoint ||
        path == ApiConfig.logoutEndpoint ||
        path == ApiConfig.refreshTokenEndpoint ||
        path == ApiConfig.validateTokenEndpoint ||
        path == ApiConfig.profileEndpoint ||
        path == ApiConfig.devicesEndpoint;
  }

  Future<void> _clearSessionOnUnauthorized() async {
    try {
      await SecureStorage().clearAuthSession();
    } catch (_) {}
    try {
      await SecureStore.clearAuth();
    } catch (_) {}
    AuthSessionEvents.instance.notifySessionExpired();
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final deviceId = await SecureStorage().getDeviceId();
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': username,
          'password': password,
          'device_id': deviceId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      final deviceId = await SecureStorage().getDeviceId();
      await _dio.post(
        ApiConfig.logoutEndpoint,
        data: {'device_id': deviceId},
      );
    } catch (e) {
      _logger.e('Logout error', error: e);
    } finally {
      await SecureStore.clearAuth();
      try {
        await SecureStorage().clearAuthSession();
      } catch (_) {}
    }
  }

  // Taxonomies - Updated for Clean Architecture Sync
  Future<Map<String, dynamic>> getTaxonomies({
    String? group,
    DateTime? since,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (group != null) params['group'] = group;
      if (since != null) params['since'] = since.toIso8601String();

      final response = await _dio.get(
        '/api/v1/taxonomies',
        queryParameters: params.isEmpty ? null : params,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Beneficiaries - Delta Sync Support
  Future<Map<String, dynamic>> getBeneficiaryChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/beneficiaries/changes',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Beneficiaries bulk sync
  Future<Map<String, dynamic>> syncBeneficiaries(
    List<Map<String, dynamic>> changes,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/beneficiaries/sync',
        data: {'changes': changes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Visits - Delta Sync Support
  Future<Map<String, dynamic>> getVisitChanges({
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/visits/changes',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Visits bulk sync
  Future<Map<String, dynamic>> syncVisits(
    List<Map<String, dynamic>> changes,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/visits/sync',
        data: {'changes': changes},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Attachment upload
  Future<String> initAttachmentUpload(Map<String, dynamic> metadata) async {
    try {
      final response = await _dio.post('/attachments/init', data: metadata);
      return response.data['upload_id'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Civil Registry endpoints
  Future<Map<String, dynamic>> getCivilRecord(String nationalId) async {
    try {
      final response = await _dio.get(
        '/civil-registry/by-national-id/$nationalId',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCivilRecordsBatch({
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/civil-registry',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCivilRecordsUpdated({
    required DateTime since,
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/civil-registry/updated',
        queryParameters: {
          'since': since.toIso8601String(),
          'offset': offset,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<int> getCivilRegistryCount() async {
    try {
      final response = await _dio.get('/civil-registry/count');
      return response.data['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<int> getCivilRegistryCountUpdated(DateTime since) async {
    try {
      final response = await _dio.get(
        '/civil-registry/count-updated',
        queryParameters: {'since': since.toIso8601String()},
      );
      return response.data['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCivilRecordsByNationalIds(
    List<String> nationalIds,
  ) async {
    try {
      final response = await _dio.post(
        '/civil-registry/batch',
        data: {'national_ids': nationalIds},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> uploadAttachmentChunk({
    required String uploadId,
    required int chunkIndex,
    required List<int> data,
  }) async {
    try {
      await _dio.post(
        '/attachments/chunk',
        data: FormData.fromMap({
          'upload_id': uploadId,
          'chunk_index': chunkIndex,
          'data': MultipartFile.fromBytes(data),
        }),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> commitAttachmentUpload({
    required String uploadId,
    required String hash,
  }) async {
    try {
      await _dio.post(
        '/attachments/commit',
        data: {'upload_id': uploadId, 'hash': hash},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Pull sync
  Future<Map<String, dynamic>> pullSync({DateTime? updatedAfter}) async {
    try {
      final response = await _dio.get(
        '/sync/pull',
        queryParameters: {
          if (updatedAfter != null) 'updated_after': updatedAfter.toIso8601String(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  NetworkFailure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      return NetworkFailure(
        message: 'Connection timeout',
        code: 'TIMEOUT',
        error: error,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        message: 'No internet connection',
        code: 'NO_CONNECTION',
        error: error,
      );
    }

    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? error.message ?? 'Unknown error';

    return NetworkFailure(
      message: message,
      code: statusCode?.toString(),
      error: error,
    );
  }
}
