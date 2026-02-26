import '../api/sync_api_client.dart';
import '../dto/sync_dto.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/debug_logger.dart';

/// 🔐 Authentication Service - خدمة المصادقة
///
/// تتولى:
/// - تسجيل الدخول والخروج
/// - حفظ واسترجاع بيانات المصادقة
/// - تحديث الـ Token
class AuthService {
  final SyncApiClient _apiClient;
  final SecureStorage _storage = SecureStorage();

  AuthService({String? serverUrl})
      : _apiClient = SyncApiClient(
          baseUrl: serverUrl ?? ApiConfig.defaultBaseUrl,
        );

  // ===========================
  // 🔑 AUTHENTICATION
  // ===========================

  /// 🔑 تسجيل الدخول
  Future<AuthResult> login({
    required String email,
    required String password,
    String? serverUrl,
  }) async {
    try {
      DebugLogger.info('🔐 Starting login process for: $email');

      // التحقق من صحة الإدخال
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          error: 'الرجاء إدخال البريد الإلكتروني وكلمة السر',
        );
      }

      // التحقق من صحة رابط السيرفر (إذا تم تزويده)
      if (serverUrl != null && !ApiConfig.isValidUrl(serverUrl)) {
        return AuthResult(success: false, error: 'رابط السيرفر غير صحيح');
      }

      // إنشاء API client جديد إذا كان هناك server URL مختلف
      final apiClient = serverUrl != null ? SyncApiClient(baseUrl: serverUrl) : _apiClient;

      // إنشاء طلب تسجيل الدخول
      final request = LoginRequestDto(
        email: email,
        password: password,
        deviceId: await _storage.getDeviceId(),
      );

      // إرسال الطلب
      final response = await apiClient.login(request);

      if (response.success && response.token != null && response.user != null) {
        // حفظ بيانات المصادقة
        await _storage.saveAuthData(
          token: response.token!,
          refreshToken: response.refreshToken,
          userId: response.user!.id,
          email: response.user!.email,
          userName: response.user!.name,
          serverUrl: serverUrl,
        );

        // تحديث الـ token في الـ API client الأساسي
        _apiClient.updateAuthToken(response.token!);

        DebugLogger.success(
          '✅ Login successful for user: ${response.user!.email}',
        );

        return AuthResult(
          success: true,
          user: response.user,
          token: response.token,
        );
      } else {
        return AuthResult(
          success: false,
          error: response.message ?? 'فشل تسجيل الدخول',
        );
      }
    } catch (e) {
      DebugLogger.error('❌ Login failed', e);
      return AuthResult(
        success: false,
        error: e is SyncException ? e.message : 'حدث خطأ غير متوقع',
      );
    }
  }

  /// 🚪 تسجيل الخروج
  Future<void> logout() async {
    try {
      DebugLogger.info('👋 Logging out...');

      // محاولة إرسال طلب تسجيل الخروج للسيرفر
      try {
        await _apiClient.logout();
      } catch (e) {
        // تجاهل أخطاء الشبكة عند تسجيل الخروج
        DebugLogger.warning('⚠️ Failed to notify server about logout');
      }

      // حذف بيانات المصادقة المحلية
      await _storage.clearAuthData();

      // إزالة الـ token من الـ API client
      _apiClient.clearAuthToken();

      DebugLogger.success('✅ Logged out successfully');
    } catch (e) {
      DebugLogger.error('❌ Logout error', e);
      rethrow;
    }
  }

  /// 🔄 تحديث Token (Refresh)
  Future<bool> refreshAuthToken() async {
    try {
      final deviceId = await _storage.getDeviceId();
      if (deviceId.trim().isEmpty) {
        DebugLogger.warning('⚠️ No device ID available');
        return false;
      }

      DebugLogger.info('🔄 Refreshing auth token...');

      final newToken = await _apiClient.refreshToken(deviceId: deviceId);
      if (newToken != null) {
        await _storage.updateAuthToken(newToken);
        _apiClient.updateAuthToken(newToken);

        DebugLogger.success('✅ Token refreshed successfully');
        return true;
      } else {
        DebugLogger.warning('⚠️ Failed to refresh token');
        return false;
      }
    } catch (e) {
      DebugLogger.error('❌ Token refresh error', e);
      return false;
    }
  }

  // ===========================
  // ✅ STATUS CHECKS
  // ===========================

  /// ✅ التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// ✅ التحقق من صحة الـ Token الحالي
  Future<bool> validateCurrentToken() async {
    try {
      final hasToken = await _storage.hasAuthToken();
      if (!hasToken) return false;

      // يمكن إضافة طلب للسيرفر للتحقق من صحة الـ token
      // final status = await _apiClient.checkSyncStatus();
      // return status.available;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ✅ الحصول على معلومات المستخدم الحالي
  Future<CurrentUserInfo?> getCurrentUser() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      if (!isLoggedIn) return null;

      final userInfo = await _storage.getUserInfo();
      final lastSync = await _storage.getLastSyncTime();

      return CurrentUserInfo(
        userId: userInfo['userId'],
        email: userInfo['email'],
        userName: userInfo['userName'],
        serverUrl: userInfo['serverUrl'],
        lastSyncTime: lastSync,
      );
    } catch (e) {
      DebugLogger.error('❌ Failed to get current user', e);
      return null;
    }
  }

  // ===========================
  // 🛠️ UTILITIES
  // ===========================

  /// 🔑 الحصول على الـ Token الحالي
  Future<String?> getAuthToken() async {
    return await _storage.getAuthToken();
  }

  /// 🌐 الحصول على رابط السيرفر المحفوظ
  Future<String?> getServerUrl() async {
    return await _storage.getServerUrl();
  }

  /// 🗑️ حذف جميع البيانات (للتنظيف الكامل)
  Future<void> clearAllData() async {
    await _storage.clearAll();
    _apiClient.clearAuthToken();
    DebugLogger.info('🗑️ All auth data cleared');
  }

  /// 📊 الحصول على حالة المصادقة
  Future<AuthStatus> getAuthStatus() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      final hasToken = await _storage.hasAuthToken();
      final userInfo = await _storage.getUserInfo();

      return AuthStatus(
        isLoggedIn: isLoggedIn,
        hasToken: hasToken,
        userId: userInfo['userId'],
        email: userInfo['email'],
        userName: userInfo['userName'],
      );
    } catch (e) {
      return AuthStatus(isLoggedIn: false, hasToken: false);
    }
  }
}

// ===========================
// 📋 HELPER CLASSES
// ===========================

/// نتيجة عملية المصادقة
class AuthResult {
  final bool success;
  final UserDto? user;
  final String? token;
  final String? error;

  AuthResult({required this.success, this.user, this.token, this.error});
}

/// معلومات المستخدم الحالي
class CurrentUserInfo {
  final String? userId;
  final String? email;
  final String? userName;
  final String? serverUrl;
  final DateTime? lastSyncTime;

  CurrentUserInfo({
    this.userId,
    this.email,
    this.userName,
    this.serverUrl,
    this.lastSyncTime,
  });
}

/// حالة المصادقة
class AuthStatus {
  final bool isLoggedIn;
  final bool hasToken;
  final String? userId;
  final String? email;
  final String? userName;

  AuthStatus({
    required this.isLoggedIn,
    required this.hasToken,
    this.userId,
    this.email,
    this.userName,
  });

  @override
  String toString() {
    return 'AuthStatus(isLoggedIn: $isLoggedIn, hasToken: $hasToken, email: $email)';
  }
}
