import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/debug_logger.dart';

/// 🔐 Secure Storage - تخزين آمن للبيانات الحساسة
///
/// يستخدم لحفظ:
/// - Token المصادقة
/// - بيانات المستخدم
/// - رابط السيرفر
/// - إعدادات أخرى حساسة
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // 🔑 Keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _serverUrlKey = 'server_url';
  static const String _deviceIdKey = 'device_id';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _isLoggedInKey = 'is_logged_in';

  // ===========================
  // 🔐 Authentication Methods
  // ===========================

  /// 💾 حفظ بيانات تسجيل الدخول الكاملة
  Future<void> saveAuthData({
    required String token,
    String? refreshToken,
    required String userId,
    required String email,
    String? userName,
    String? serverUrl,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _authTokenKey, value: token),
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userEmailKey, value: email),
        _storage.write(key: _isLoggedInKey, value: 'true'),
        if (refreshToken != null)
          _storage.write(key: _refreshTokenKey, value: refreshToken),
        if (userName != null)
          _storage.write(key: _userNameKey, value: userName),
        if (serverUrl != null)
          _storage.write(key: _serverUrlKey, value: serverUrl),
      ]);

      DebugLogger.success('✅ Auth data saved securely');
    } catch (e) {
      DebugLogger.error('❌ Failed to save auth data', e);
      rethrow;
    }
  }

  /// 🔑 الحصول على Auth Token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read auth token', e);
      return null;
    }
  }

  /// 🔄 الحصول على Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read refresh token', e);
      return null;
    }
  }

  /// 📧 الحصول على البريد الإلكتروني
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read user email', e);
      return null;
    }
  }

  /// 👤 الحصول على اسم المستخدم
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read user name', e);
      return null;
    }
  }

  /// 🆔 الحصول على User ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read user ID', e);
      return null;
    }
  }

  /// 🌐 الحصول على رابط السيرفر
  Future<String?> getServerUrl() async {
    try {
      return await _storage.read(key: _serverUrlKey);
    } catch (e) {
      DebugLogger.error('❌ Failed to read server URL', e);
      return null;
    }
  }

  /// 📱 الحصول على Device ID (أو إنشاؤه إذا لم يكن موجود)
  Future<String> getDeviceId() async {
    try {
      String? deviceId = await _storage.read(key: _deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await _storage.write(key: _deviceIdKey, value: deviceId);
        DebugLogger.info('📱 New device ID created: $deviceId');
      }

      return deviceId;
    } catch (e) {
      DebugLogger.error('❌ Failed to get device ID', e);
      // Fallback device ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// ✅ التحقق من وجود Token صالح
  Future<bool> hasAuthToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ✅ التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _isLoggedInKey);
      final hasToken = await hasAuthToken();
      return isLoggedIn == 'true' && hasToken;
    } catch (e) {
      return false;
    }
  }

  /// 🔄 تحديث Auth Token (بعد Refresh)
  Future<void> updateAuthToken(String newToken) async {
    try {
      await _storage.write(key: _authTokenKey, value: newToken);
      DebugLogger.info('🔄 Auth token updated');
    } catch (e) {
      DebugLogger.error('❌ Failed to update auth token', e);
      rethrow;
    }
  }

  // ===========================
  // 🔄 Sync Methods
  // ===========================

  /// 💾 حفظ آخر وقت مزامنة
  Future<void> saveLastSyncTime(DateTime time) async {
    try {
      await _storage.write(
        key: _lastSyncTimeKey,
        value: time.toIso8601String(),
      );
      DebugLogger.info('💾 Last sync time saved: $time');
    } catch (e) {
      DebugLogger.error('❌ Failed to save last sync time', e);
    }
  }

  /// 📅 الحصول على آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timeStr = await _storage.read(key: _lastSyncTimeKey);
      if (timeStr == null || timeStr.isEmpty) return null;
      return DateTime.parse(timeStr);
    } catch (e) {
      DebugLogger.error('❌ Failed to read last sync time', e);
      return null;
    }
  }

  // ===========================
  // 🗑️ Cleanup Methods
  // ===========================

  /// 🗑️ حذف جميع البيانات (تسجيل الخروج)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      DebugLogger.info('🗑️ All secure storage cleared');
    } catch (e) {
      DebugLogger.error('❌ Failed to clear storage', e);
      rethrow;
    }
  }

  /// 🗑️ حذف بيانات المصادقة فقط
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: _authTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userEmailKey),
        _storage.delete(key: _userNameKey),
        _storage.delete(key: _isLoggedInKey),
      ]);
      DebugLogger.info('🗑️ Auth data cleared');
    } catch (e) {
      DebugLogger.error('❌ Failed to clear auth data', e);
      rethrow;
    }
  }

  // ===========================
  // 🛠️ Utility Methods
  // ===========================

  /// 📋 الحصول على جميع البيانات المحفوظة (للتصحيح فقط)
  Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      DebugLogger.error('❌ Failed to read all data', e);
      return {};
    }
  }

  /// ✅ التحقق من صحة البيانات المحفوظة
  Future<bool> validateStoredData() async {
    try {
      final hasToken = await hasAuthToken();
      final userId = await getUserId();
      final email = await getUserEmail();

      return hasToken && userId != null && email != null;
    } catch (e) {
      return false;
    }
  }

  /// 📊 الحصول على معلومات المستخدم الكاملة
  Future<Map<String, String?>> getUserInfo() async {
    try {
      return {
        'userId': await getUserId(),
        'email': await getUserEmail(),
        'userName': await getUserName(),
        'serverUrl': await getServerUrl(),
      };
    } catch (e) {
      DebugLogger.error('❌ Failed to get user info', e);
      return {};
    }
  }
}
