import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' show DioException, DioExceptionType;

import '../../../../core/backend/remote_backend.dart';
import '../../../../core/error_handling/result.dart';
import '../../../../core/services/password_hash_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/unified_logger.dart';
import '../../domain/entities/auth_device.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/auth_mappers.dart';

/// 🔐 Auth Repository Implementation
///
/// تنفيذ واجهة [AuthRepository] مع دعم كامل لـ:
/// - تسجيل الدخول عبر API
/// - تخزين آمن للجلسة
/// - دعم Offline-first
/// - تجديد تلقائي للـ Token
class AuthRepositoryImpl implements AuthRepository {
  final RemoteBackend _remoteBackend;
  final SecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfo;

  AuthRepositoryImpl({
    required RemoteBackend remoteBackend,
    required SecureStorage secureStorage,
    DeviceInfoPlugin? deviceInfo,
  })  : _remoteBackend = remoteBackend,
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
      final firebaseResult = await _remoteBackend.signIn(email, password);

      if (firebaseResult == null || (firebaseResult['uid']?.toString().isEmpty ?? true)) {
        return const Failure(InvalidCredentialsFailure('فشل تسجيل الدخول عبر Firebase'));
      }

      final session = _buildSessionFromFirebase(
        firebaseResult,
        email: email,
        deviceId: deviceId,
      );

      await saveSession(session);
      await _secureStorage.saveLastSuccessfulEmail(email);
      await _secureStorage.saveOfflineAuthHash(PasswordHashService.hashPassword(password));

      UnifiedLogger.success('✅ Firebase login successful for: ${session.user.name}');
      return Success(session);
    } on DioException catch (e) {
      return _tryOfflineLogin(email: email, password: password, fallbackError: _handleDioError(e));
    } catch (e, stackTrace) {
      UnifiedLogger.warning('⚠️ Online Firebase login unavailable, trying offline auth');
      final fallback = await _tryOfflineLogin(
        email: email,
        password: password,
        fallbackError: UnexpectedAuthFailure(e.toString()),
      );
      if (fallback is Failure<AuthSession>) {
        UnifiedLogger.error('❌ Login failed', error: e, stackTrace: stackTrace);
      }
      return fallback;
    }
  }

  @override
  Future<Result<void>> logout({
    String? deviceId,
    bool logoutAllDevices = false,
  }) async {
    try {
      UnifiedLogger.info('🚪 Attempting logout');

      try {
        await _remoteBackend.signOut();
      } catch (_) {
        UnifiedLogger.warning('⚠️ Firebase signOut failed, continuing local logout');
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
      final storedSession = await getStoredSession();
      if (storedSession is Success<AuthSession>) {
        return Success(storedSession.value.user);
      }

      return const Failure(NoStoredSessionFailure());
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
      final sessionResult = await getStoredSession();
      if (sessionResult is Failure<AuthSession>) {
        return const Failure(NoStoredSessionFailure());
      }
      final session = (sessionResult as Success<AuthSession>).value;

      return Success(TokenValidationResult(
        valid: session.token.isValid,
        userId: session.user.id,
        userName: session.user.name,
        tokenExpiresAt: session.token.expiresAt,
        remainingDays: session.token.remainingDays,
        remainingSeconds: session.token.remainingSeconds,
        shouldRefresh: session.token.shouldRefresh,
      ));
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
      final rawIdToken = await _secureStorage.getAuthToken();
      if (rawIdToken == null || rawIdToken.isEmpty) {
        return const Failure(TokenRefreshFailure('لا يوجد token محفوظ'));
      }

      final expiresAt = DateTime.now().add(const Duration(minutes: 55));
      final newToken = AuthToken(
        accessToken: rawIdToken,
        tokenType: 'Bearer',
        expiresAt: expiresAt,
        expiresInDays: expiresAt.difference(DateTime.now()).inDays,
        expiresInSeconds: expiresAt.difference(DateTime.now()).inSeconds,
      );

      final updatedSession = session.updateToken(newToken);
      await saveSession(updatedSession);

      UnifiedLogger.success('✅ Token refreshed locally (Firebase session)');
      return Success(newToken);
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

  Future<Result<AuthSession>> _tryOfflineLogin({
    required String email,
    required String password,
    required AppFailure fallbackError,
  }) async {
    final lastEmail = await _secureStorage.getLastSuccessfulEmail();
    final storedHash = await _secureStorage.getOfflineAuthHash();

    if (lastEmail == null || storedHash == null) {
      return Failure(fallbackError is AuthFailure ? fallbackError : const NoStoredSessionFailure());
    }

    final sameUser = lastEmail.trim().toLowerCase() == email.trim().toLowerCase();
    final validPassword = PasswordHashService.verifyPassword(password, storedHash);

    if (!sameUser || !validPassword) {
      return const Failure(InvalidCredentialsFailure('بيانات الدخول غير صحيحة'));
    }

    return getStoredSession();
  }

  AuthSession _buildSessionFromFirebase(
    JsonMap firebaseData, {
    required String email,
    required String deviceId,
  }) {
    final uid = firebaseData['uid']?.toString() ?? '';
    final idToken = firebaseData['idToken']?.toString() ?? uid;
    final resolvedEmail = firebaseData['email']?.toString() ?? email;
    final displayName = firebaseData['displayName']?.toString();

    final expiresAt = DateTime.now().add(const Duration(minutes: 55));
    final authToken = AuthToken(
      accessToken: idToken,
      tokenType: 'Bearer',
      expiresAt: expiresAt,
      expiresInDays: expiresAt.difference(DateTime.now()).inDays,
      expiresInSeconds: expiresAt.difference(DateTime.now()).inSeconds,
    );

    return AuthSession(
      user: AuthUser(
        id: uid.hashCode,
        name: (displayName == null || displayName.trim().isEmpty) ? resolvedEmail : displayName,
        email: resolvedEmail,
        role: 'user',
      ),
      token: authToken,
      offlineConfig: const OfflineConfig(
        maxOfflineDays: 10,
        requireOnlineReauth: false,
        syncRequiredOnExpiry: false,
      ),
      loginAt: DateTime.now(),
      deviceId: deviceId,
    );
  }
}
