import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error_handling/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/unified_logger.dart';
import '../../domain/entities/auth_device.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/auth_dto.dart';
import '../mappers/auth_mappers.dart';

/// 🔐 Auth Repository Implementation
///
/// تنفيذ واجهة [AuthRepository] مع دعم كامل لـ:
/// - تسجيل الدخول عبر API
/// - تخزين آمن للجلسة
/// - دعم Offline-first
/// - تجديد تلقائي للـ Token
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfo;

  AuthRepositoryImpl({
    required Dio dio,
    required SecureStorage secureStorage,
    DeviceInfoPlugin? deviceInfo,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  // ===========================
  // 🔐 AUTHENTICATION
  // ===========================

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required String deviceId,
    String? deviceName,
    String? devicePlatform,
  }) async {
    try {
      UnifiedLogger.info('🔑 Attempting login for: $email');

      final request = MobileLoginRequest(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName ?? await getDeviceName(),
        devicePlatform: devicePlatform ?? getDevicePlatform(),
      );

      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginResponse = MobileLoginResponse.fromJson(response.data);

        if (loginResponse.success && loginResponse.data != null) {
          final session = AuthMappers.sessionFromLoginResponse(loginResponse);

          if (session != null) {
            // حفظ الجلسة محلياً
            await saveSession(session);
            UnifiedLogger.success('✅ Login successful for: ${session.user.name}');
            return Success(session);
          }
        }

        // فشل مع رسالة من السيرفر
        final errorMessage = loginResponse.message ?? loginResponse.error ?? 'فشل تسجيل الدخول';
        return Failure(InvalidCredentialsFailure(errorMessage));
      }

      return Failure(_handleHttpError(response.statusCode));
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Login failed', error: e, stackTrace: stackTrace);
      return Failure(UnexpectedAuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout({
    String? deviceId,
    bool logoutAllDevices = false,
  }) async {
    try {
      UnifiedLogger.info('🚪 Attempting logout');

      final token = await _secureStorage.getAuthToken();

      if (token != null) {
        try {
          await _dio.post(
            ApiConfig.logoutEndpoint,
            data: LogoutRequest(
              deviceId: deviceId,
              logoutAllDevices: logoutAllDevices,
            ).toJson(),
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );
        } catch (e) {
          // تجاهل خطأ API - نكمل الخروج المحلي
          UnifiedLogger.warning('⚠️ Server logout failed, continuing local logout');
        }
      }

      // حذف البيانات المحلية دائماً
      await clearSession();
      UnifiedLogger.success('✅ Logout complete');

      return const Success(null);
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Logout failed', error: e, stackTrace: stackTrace);
      // حتى لو فشل، نحذف محلياً
      await clearSession();
      return const Success(null);
    }
  }

  @override
  Future<Result<AuthUser>> getProfile() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        return const Failure(NoStoredSessionFailure());
      }

      final response = await _dio.get(
        ApiConfig.profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final root = (response.data as Map<String, dynamic>);
        final data = root['data'];
        if (data is Map<String, dynamic>) {
          final userMap = data['user'];
          if (userMap is Map<String, dynamic>) {
            return Success(_mapUser(userMap));
          }
        }
      }

      return const Failure(ServerConnectionFailure('استجابة غير متوقعة من الخادم'));
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Get profile failed', error: e, stackTrace: stackTrace);
      return Failure(UnexpectedAuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AuthDevice>>> getActiveDevices() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        return const Failure(NoStoredSessionFailure());
      }

      final response = await _dio.get(
        ApiConfig.devicesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final root = (response.data as Map<String, dynamic>);
        final data = root['data'];
        if (data is Map<String, dynamic>) {
          final devicesJson = data['devices'];
          if (devicesJson is List) {
            final devices = devicesJson.whereType<Map<String, dynamic>>().map(_mapDevice).toList(growable: false);
            return Success(devices);
          }
        }
      }

      return const Success(<AuthDevice>[]);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Get devices failed', error: e, stackTrace: stackTrace);
      return Failure(UnexpectedAuthFailure(e.toString()));
    }
  }

  // ===========================
  // 🔄 TOKEN MANAGEMENT
  // ===========================

  @override
  Future<Result<TokenValidationResult>> validateToken() async {
    try {
      final token = await _secureStorage.getAuthToken();

      if (token == null) {
        return const Failure(NoStoredSessionFailure());
      }

      UnifiedLogger.info('✅ Validating token with server');

      final response = await _dio.get(
        ApiConfig.validateTokenEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final validateResponse = ValidateTokenResponse.fromJson(response.data);

        if (validateResponse.valid && validateResponse.data != null) {
          final data = validateResponse.data!;

          return Success(TokenValidationResult(
            valid: true,
            userId: data.userId,
            userName: data.userName,
            tokenExpiresAt: DateTime.parse(data.tokenExpiresAt),
            remainingDays: data.remainingDays,
            remainingSeconds: data.remainingSeconds,
            shouldRefresh: data.shouldRefresh,
            actionRequired: validateResponse.actionRequired,
          ));
        }

        return const Failure(InvalidTokenFailure());
      }

      return Failure(_handleHttpError(response.statusCode));
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Token validation failed', error: e, stackTrace: stackTrace);
      return Failure(UnexpectedAuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthToken>> refreshToken({
    required String deviceId,
  }) async {
    try {
      final currentSessionResult = await getStoredSession();
      if (currentSessionResult is Failure<AuthSession>) {
        return Failure(currentSessionResult.error);
      }

      final session = (currentSessionResult as Success<AuthSession>).value;
      final token = session.token.accessToken;

      UnifiedLogger.info('🔄 Refreshing token');

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: RefreshTokenRequest(deviceId: deviceId).toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data);

        if (refreshResponse.success && refreshResponse.data != null) {
          final newToken = AuthMappers.tokenFromDto(refreshResponse.data!.token);

          // تحديث الجلسة في الذاكرة والتخزين
          final updatedSession = session.updateToken(newToken);
          await saveSession(updatedSession);

          UnifiedLogger.success('✅ Token refreshed - expires in ${newToken.remainingDays} days');
          return Success(newToken);
        }

        return const Failure(TokenRefreshFailure());
      }

      return Failure(_handleHttpError(response.statusCode));
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Token refresh failed', error: e, stackTrace: stackTrace);
      return Failure(TokenRefreshFailure(e.toString()));
    }
  }

  @override
  Future<bool> shouldRefreshToken() async {
    return await _secureStorage.shouldRefreshToken();
  }

  // ===========================
  // 💾 LOCAL SESSION
  // ===========================

  @override
  Future<Result<AuthSession>> getStoredSession() async {
    try {
      final sessionData = await _secureStorage.getAuthSession();

      if (sessionData == null) {
        return const Failure(NoStoredSessionFailure());
      }

      final session = AuthMappers.sessionFromMap(sessionData);

      // التحقق من صلاحية الـ Token
      if (!session.isValid) {
        final expiredDays = session.token.expiresAt.difference(DateTime.now()).inDays.abs();
        return Failure(OfflineSessionExpiredFailure(expiredDaysAgo: expiredDays));
      }

      return Success(session);
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Failed to get stored session', error: e, stackTrace: stackTrace);
      return Failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveSession(AuthSession session) async {
    try {
      final sessionMap = AuthMappers.sessionToMap(session);
      await _secureStorage.saveAuthSession(sessionMap);
      return const Success(null);
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Failed to save session', error: e, stackTrace: stackTrace);
      return Failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearSession() async {
    try {
      await _secureStorage.clearAuthSession();
      return const Success(null);
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Failed to clear session', error: e, stackTrace: stackTrace);
      return Failure(StorageFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasValidSession() async {
    return await _secureStorage.hasValidSession();
  }

  // ===========================
  // 📱 DEVICE INFO
  // ===========================

  @override
  Future<String> getDeviceId() async {
    return await _secureStorage.getDeviceId();
  }

  @override
  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.name;
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  @override
  String getDevicePlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  // ===========================
  // 🛠️ HELPERS
  // ===========================

  /// معالجة أخطاء HTTP
  AppFailure _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 401:
        return const InvalidTokenFailure();
      case 403:
        return const AccountDisabledFailure();
      case 422:
        return const InvalidCredentialsFailure();
      case 429:
        return const TooManyAttemptsFailure();
      case 500:
      case 502:
      case 503:
        return const ServerConnectionFailure('خطأ في الخادم');
      default:
        return ServerConnectionFailure('خطأ غير متوقع: $statusCode');
    }
  }

  /// معالجة أخطاء Dio
  AppFailure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerConnectionFailure('انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return const ServerConnectionFailure('لا يوجد اتصال بالإنترنت');
      case DioExceptionType.badResponse:
        return _handleHttpError(e.response?.statusCode);
      default:
        return ServerConnectionFailure(e.message ?? 'خطأ في الاتصال');
    }
  }

  AuthUser _mapUser(Map<String, dynamic> userMap) {
    final rolesRaw = userMap['roles'];
    final permissionsRaw = userMap['permissions'];

    return AuthUser(
      id: (userMap['id'] as num?)?.toInt() ?? 0,
      name: userMap['name']?.toString() ?? '',
      email: userMap['email']?.toString() ?? '',
      phone: userMap['phone']?.toString(),
      avatar: userMap['avatar']?.toString(),
      role: userMap['role']?.toString() ?? '',
      roles: rolesRaw is List ? rolesRaw.map((e) => e.toString()).toList(growable: false) : const <String>[],
      permissions:
          permissionsRaw is List ? permissionsRaw.map((e) => e.toString()).toList(growable: false) : const <String>[],
    );
  }

  AuthDevice _mapDevice(Map<String, dynamic> deviceMap) {
    return AuthDevice(
      deviceId: deviceMap['device_id']?.toString() ?? '',
      deviceName: deviceMap['device_name']?.toString(),
      devicePlatform: deviceMap['device_platform']?.toString(),
      lastLoginAt: _tryParseDateTime(deviceMap['last_login_at']),
      expiresAt: _tryParseDateTime(deviceMap['expires_at']),
      ipAddress: deviceMap['ip_address']?.toString(),
    );
  }

  DateTime? _tryParseDateTime(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
