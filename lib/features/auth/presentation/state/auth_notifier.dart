import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error_handling/result.dart';
import '../../../../core/security/auth_session_events.dart';
import '../../../../core/utils/unified_logger.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// 🔐 Auth State Notifier - إدارة حالة المصادقة
///
/// يدير جميع عمليات المصادقة مع دعم:
/// - تسجيل الدخول Online/Offline
/// - تجديد تلقائي للـ Token
/// - التعامل مع الأخطاء
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Connectivity _connectivity;

  AuthNotifier({
    required AuthRepository authRepository,
    Connectivity? connectivity,
  })  : _authRepository = authRepository,
        _connectivity = connectivity ?? Connectivity(),
        super(const AuthInitial());

  /// 📊 الحصول على الحالة الحالية
  AuthState get currentState => state;

  // ===========================
  // 🔄 INITIALIZATION
  // ===========================

  /// 🚀 فحص حالة المصادقة عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    state = const AuthLoading(message: 'جاري التحقق من الجلسة...');

    try {
      // التحقق من وجود جلسة محفوظة
      final sessionResult = await _authRepository.getStoredSession();

      switch (sessionResult) {
        case Failure(error: final failure):
          if (failure is OfflineSessionExpiredFailure) {
            await _authRepository.clearSession();
          }
          // لا يوجد جلسة محفوظة
          UnifiedLogger.info('📱 No stored session found');
          state = AuthUnauthenticated(message: failure.message);
        case Success(value: final session):
          // يوجد جلسة محفوظة
          UnifiedLogger.info('📱 Found stored session for: ${session.user.name}');

          // التحقق من الاتصال
          final connectivityResult = await _connectivity.checkConnectivity();
          final isOnline = connectivityResult.first != ConnectivityResult.none;

          if (isOnline) {
            // Online: التحقق من الـ Token مع السيرفر
            await _validateTokenOnline(session);
          } else {
            // Offline: استخدام الجلسة المحفوظة
            _handleOfflineSession(session);
          }
      }
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Auth check failed', error: e, stackTrace: stackTrace);
      state = AuthError(message: 'فشل التحقق من الجلسة: ${e.toString()}');
    }
  }

  /// ✅ التحقق من الـ Token Online
  Future<void> _validateTokenOnline(session) async {
    final validationResult = await _authRepository.validateToken();

    switch (validationResult) {
      case Failure(error: final failure):
        // Token غير صالح
        UnifiedLogger.warning('⚠️ Token validation failed: ${failure.message}');
        _setSessionExpired(lastUser: session.user);
      case Success(value: final result):
        if (result.valid) {
          // Token صالح
          if (result.shouldRefresh) {
            // يحتاج تجديد
            state = AuthTokenExpiring(
              session: session,
              remainingDays: result.remainingDays,
            );
            // محاولة تجديد تلقائي
            await refreshToken();
          } else {
            state = AuthAuthenticated(session: session);
          }
        } else {
          _setSessionExpired(lastUser: session.user);
        }
    }
  }

  /// 📴 معالجة الجلسة Offline
  void _handleOfflineSession(session) {
    if (session.isValid) {
      if (session.shouldRefreshToken) {
        state = AuthTokenExpiring(
          session: session,
          remainingDays: session.token.remainingDays,
        );
      } else {
        state = AuthAuthenticated(
          session: session,
          isOffline: true,
        );
      }
    } else {
      _setSessionExpired(lastUser: session.user);
    }
  }

  // ===========================
  // 🔑 LOGIN
  // ===========================

  /// 🔑 تسجيل الدخول
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading(message: 'جاري تسجيل الدخول...');

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isOnline = connectivityResult.first != ConnectivityResult.none;
      if (!isOnline) {
        state = const AuthError(
          message: 'الاتصال بالإنترنت مطلوب لتسجيل الدخول',
          canRetry: true,
        );
        return false;
      }

      final deviceId = await _authRepository.getDeviceId();
      final deviceName = await _authRepository.getDeviceName();
      final devicePlatform = _authRepository.getDevicePlatform();

      final result = await _authRepository.login(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
        devicePlatform: devicePlatform,
      );

      switch (result) {
        case Failure(error: final failure):
          UnifiedLogger.warning('⚠️ Login failed: ${failure.message}');
          state = AuthError(
            message: failure.message,
          );
          return false;
        case Success(value: final session):
          UnifiedLogger.success('✅ Login successful');
          state = AuthAuthenticated(session: session);
          return true;
      }
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Login error', error: e, stackTrace: stackTrace);
      state = AuthError(
        message: 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}',
      );
      return false;
    }
  }

  // ===========================
  // 🚪 LOGOUT
  // ===========================

  /// 🚪 تسجيل الخروج
  Future<void> logout({bool fromAllDevices = false}) async {
    state = const AuthLoading(message: 'جاري تسجيل الخروج...');

    try {
      final deviceId = await _authRepository.getDeviceId();

      await _authRepository.logout(
        deviceId: deviceId,
        logoutAllDevices: fromAllDevices,
      );

      state = const AuthUnauthenticated(message: 'تم تسجيل الخروج بنجاح');
      UnifiedLogger.success('✅ Logout successful');
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Logout error', error: e, stackTrace: stackTrace);
      // حتى لو فشل، نعتبره تسجيل خروج
      state = const AuthUnauthenticated();
    }
  }

  // ===========================
  // 🔄 TOKEN REFRESH
  // ===========================

  /// 🔄 تجديد الـ Token
  Future<bool> refreshToken() async {
    try {
      final currentSession = state.session;
      if (currentSession == null) {
        UnifiedLogger.warning('⚠️ No session to refresh');
        return false;
      }

      UnifiedLogger.info('🔄 Refreshing token...');

      final deviceId = await _authRepository.getDeviceId();
      final result = await _authRepository.refreshToken(deviceId: deviceId);

      switch (result) {
        case Failure(error: final failure):
          UnifiedLogger.warning('⚠️ Token refresh failed: ${failure.message}');
          // إذا فشل التجديد، نعرض رسالة لكن نبقي الجلسة
          return false;
        case Success(value: final newToken):
          final updatedSession = currentSession.updateToken(newToken);
          state = AuthAuthenticated(
            session: updatedSession,
            tokenRefreshed: true,
          );
          UnifiedLogger.success('✅ Token refreshed successfully');
          return true;
      }
    } catch (e, stackTrace) {
      UnifiedLogger.error('❌ Token refresh error', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ===========================
  // 🛠️ UTILITIES
  // ===========================

  /// 🔄 إعادة المحاولة بعد خطأ
  Future<void> retry() async {
    await checkAuthStatus();
  }

  /// 🗑️ مسح حالة الخطأ
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  /// 📱 التحقق من الاتصال وتحديث الحالة
  Future<void> checkConnectivityAndSync() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult.first != ConnectivityResult.none;

    if (isOnline && state.isOffline) {
      // كنا offline والآن online
      await checkAuthStatus();
    }
  }

  /// ✅ هل يوجد صلاحية معينة
  bool hasPermission(String permission) {
    return state.user?.hasPermission(permission) ?? false;
  }

  /// ✅ هل يوجد دور معين
  bool hasRole(String role) {
    return state.user?.hasRole(role) ?? false;
  }

  void _setSessionExpired({required lastUser}) {
    state = AuthSessionExpired(lastUser: lastUser);
    AuthSessionEvents.instance.notifySessionExpired();
  }
}
