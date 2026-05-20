import 'dart:convert';

import 'package:benaa_offline_app/core/utils/unified_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// 🔐 Secure Storage - تخزين آمن للبيانات الحساسة
///
/// يستخدم لحفظ:
/// - Token المصادقة
/// - بيانات المستخدم
/// - رابط السيرفر
/// - إعدادات أخرى حساسة
class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  static String? _cachedDeviceId;
  static String? _cachedAuthToken;
  static bool _secureStoragePluginUnavailable = false;
  static final Map<String, String> _memoryFallbackStore = <String, String>{};
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // 🔑 Keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _serverUrlKey = 'server_url';
  static const String _deviceIdKey = 'device_id';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _syncLockUntilKey = 'sync_lock_until';
  static const String _syncLockOwnerKey = 'sync_lock_owner';
  static const String _isLoggedInKey = 'is_logged_in';
  // 🆕 New Keys for Auth Session
  static const String _authSessionKey = 'auth_session';
  static const String _offlineConfigKey = 'offline_config';
  static const String _userDataKey = 'user_data';
  static const String _lastOnlineAuthKey = 'last_online_auth';
  // 🆕 Remember Me Keys
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password_encrypted';
  static const String _lastSuccessfulEmailKey = 'last_successful_email';
  static const String _offlineAuthHashKey = 'offline_auth_hash';
  static const String _biometricEnabledKey = 'biometric_auth_enabled';

  // ===========================
  // 🔐 Authentication Methods
  // ===========================

  /// 💾 حفظ بيانات تسجيل الدخول الكاملة
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String email,
    String? refreshToken,
    String? userName,
    String? serverUrl,
  }) async {
    try {
      _cachedAuthToken = token;
      await Future.wait([
        _storage.write(key: _authTokenKey, value: token),
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userEmailKey, value: email),
        _storage.write(key: _isLoggedInKey, value: 'true'),
        if (refreshToken != null) _storage.write(key: _refreshTokenKey, value: refreshToken),
        if (userName != null) _storage.write(key: _userNameKey, value: userName),
        if (serverUrl != null) _storage.write(key: _serverUrlKey, value: serverUrl),
      ]);

      UnifiedLogger.success('✅ Auth data saved securely');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to save auth data', error: e);
      rethrow;
    }
  }

  /// 🔑 الحصول على Auth Token
  Future<String?> getAuthToken() async {
    try {
      if (_cachedAuthToken != null && _cachedAuthToken!.isNotEmpty) {
        return _cachedAuthToken;
      }

      final token = await _storage.read(key: _authTokenKey);
      if (token != null && token.isNotEmpty) {
        _cachedAuthToken = token;
      }
      return token;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read auth token', error: e);
      return null;
    }
  }

  /// 🔄 الحصول على Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read refresh token', error: e);
      return null;
    }
  }

  /// 📧 الحصول على البريد الإلكتروني
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read user email', error: e);
      return null;
    }
  }

  /// 👤 الحصول على اسم المستخدم
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read user name', error: e);
      return null;
    }
  }

  /// 🆔 الحصول على User ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read user ID', error: e);
      return null;
    }
  }

  /// 🌐 الحصول على رابط السيرفر
  Future<String?> getServerUrl() async {
    try {
      return await _storage.read(key: _serverUrlKey);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read server URL', error: e);
      return null;
    }
  }

  /// 📱 الحصول على Device ID (أو إنشاؤه إذا لم يكن موجود)
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    try {
      String? deviceId;

      if (_secureStoragePluginUnavailable) {
        deviceId = _memoryFallbackStore[_deviceIdKey];
      } else {
        deviceId = await _storage.read(key: _deviceIdKey);
      }

      if (deviceId == null || deviceId.isEmpty) {
        // 🆔 إنشاء معرف فريد عالمي (UUID V4)
        deviceId = const Uuid().v4();
        _cachedDeviceId = deviceId;

        if (_secureStoragePluginUnavailable) {
          _memoryFallbackStore[_deviceIdKey] = deviceId;
        } else {
          await _storage.write(key: _deviceIdKey, value: deviceId);
        }

        UnifiedLogger.info('📱 New persistent device ID created (UUID): $deviceId');
      } else {
        _cachedDeviceId = deviceId;
      }

      return deviceId;
    } on MissingPluginException {
      _secureStoragePluginUnavailable = true;

      final fallback = _memoryFallbackStore[_deviceIdKey];
      if (fallback != null && fallback.isNotEmpty) {
        _cachedDeviceId = fallback;
        return fallback;
      }

      final generated = const Uuid().v4();
      _cachedDeviceId = generated;
      _memoryFallbackStore[_deviceIdKey] = generated;
      UnifiedLogger.warning('⚠️ flutter_secure_storage plugin unavailable; using in-memory fallback for device ID');
      return generated;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to get device ID', error: e);
      if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
        return _cachedDeviceId!;
      }

      // Fallback (still tries to use UUID if possible, or timestamp as last resort)
      try {
        _cachedDeviceId = const Uuid().v4();
        return _cachedDeviceId!;
      } catch (_) {
        _cachedDeviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        return _cachedDeviceId!;
      }
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
      _cachedAuthToken = newToken;
      await _storage.write(key: _authTokenKey, value: newToken);
      UnifiedLogger.info('🔄 Auth token updated');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update auth token', error: e);
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
      UnifiedLogger.info('💾 Last sync time saved: $time');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to save last sync time', error: e);
    }
  }

  /// 📅 الحصول على آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timeStr = await _storage.read(key: _lastSyncTimeKey);
      if (timeStr == null || timeStr.isEmpty) return null;
      return DateTime.parse(timeStr);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read last sync time', error: e);
      return null;
    }
  }

  /// 🔒 Acquire distributed sync lock (works across foreground/background isolates)
  Future<bool> acquireSyncLock({
    required String owner,
    Duration ttl = const Duration(minutes: 10),
  }) async {
    try {
      final now = DateTime.now();
      final active = await getSyncLockInfo();
      if (active != null && active.until.isAfter(now) && active.owner != owner) {
        return false;
      }

      final lockUntil = now.add(ttl).toIso8601String();
      await Future.wait([
        _storage.write(key: _syncLockUntilKey, value: lockUntil),
        _storage.write(key: _syncLockOwnerKey, value: owner),
      ]);

      return true;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to acquire sync lock', error: e);
      return false;
    }
  }

  /// 🔓 Release distributed sync lock
  Future<void> releaseSyncLock({String? owner}) async {
    try {
      if (owner != null) {
        final currentOwner = await _storage.read(key: _syncLockOwnerKey);
        if (currentOwner != null && currentOwner != owner) {
          return;
        }
      }

      await Future.wait([
        _storage.delete(key: _syncLockUntilKey),
        _storage.delete(key: _syncLockOwnerKey),
      ]);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to release sync lock', error: e);
    }
  }

  /// ℹ️ Returns active lock info if present
  Future<({DateTime until, String? owner})?> getSyncLockInfo() async {
    try {
      final untilRaw = await _storage.read(key: _syncLockUntilKey);
      if (untilRaw == null || untilRaw.isEmpty) return null;

      final until = DateTime.tryParse(untilRaw);
      if (until == null) return null;

      final owner = await _storage.read(key: _syncLockOwnerKey);
      return (until: until, owner: owner);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read sync lock', error: e);
      return null;
    }
  }

  Future<bool> isSyncLockActive() async {
    final lockInfo = await getSyncLockInfo();
    if (lockInfo == null) return false;
    return lockInfo.until.isAfter(DateTime.now());
  }

  // ===========================
  // 🗑️ Cleanup Methods
  // ===========================

  /// 🗑️ حذف جميع البيانات (تسجيل الخروج)
  Future<void> clearAll() async {
    try {
      if (_secureStoragePluginUnavailable) {
        _memoryFallbackStore.clear();
      } else {
        await _storage.deleteAll();
      }
      _cachedDeviceId = null;
      _cachedAuthToken = null;
      UnifiedLogger.info('🗑️ All secure storage cleared');
    } on MissingPluginException {
      _secureStoragePluginUnavailable = true;
      _memoryFallbackStore.clear();
      _cachedDeviceId = null;
      _cachedAuthToken = null;
      UnifiedLogger.warning('⚠️ flutter_secure_storage plugin unavailable; cleared in-memory secure storage fallback');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to clear storage', error: e);
      rethrow;
    }
  }

  /// 🗑️ حذف بيانات المصادقة فقط
  Future<void> clearAuthData() async {
    try {
      _cachedAuthToken = null;
      await Future.wait([
        _storage.delete(key: _authTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userEmailKey),
        _storage.delete(key: _userNameKey),
        _storage.delete(key: _isLoggedInKey),
      ]);
      UnifiedLogger.info('🗑️ Auth data cleared');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to clear auth data', error: e);
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
      UnifiedLogger.error('❌ Failed to read all data', error: e);
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
      UnifiedLogger.error('❌ Failed to get user info', error: e);
      return {};
    }
  }

  // ===========================
  // 🆕 AUTH SESSION METHODS (New API)
  // ===========================

  /// 💾 حفظ Auth Session كاملة (JSON)
  Future<void> saveAuthSession(Map<String, dynamic> sessionData) async {
    try {
      final jsonStr = jsonEncode(sessionData);
      await _storage.write(key: _authSessionKey, value: jsonStr);

      // أيضاً حفظ Token expiry منفصلاً للوصول السريع
      if (sessionData['token'] != null) {
        final tokenData = sessionData['token'] as Map<String, dynamic>;
        if (tokenData['expires_at'] != null) {
          await _storage.write(
            key: _tokenExpiryKey,
            value: tokenData['expires_at'] as String,
          );
        }
        if (tokenData['access_token'] != null) {
          await _storage.write(
            key: _authTokenKey,
            value: tokenData['access_token'] as String,
          );
        }
      }

      // حفظ بيانات المستخدم منفصلة أيضاً
      if (sessionData['user'] != null) {
        await _storage.write(
          key: _userDataKey,
          value: jsonEncode(sessionData['user']),
        );
        final user = sessionData['user'] as Map<String, dynamic>;
        await _storage.write(key: _userIdKey, value: user['id'].toString());
        await _storage.write(key: _userEmailKey, value: user['email'] as String);
        if (user['name'] != null) {
          await _storage.write(key: _userNameKey, value: user['name'] as String);
        }
      }

      // حفظ offline config
      if (sessionData['offline_config'] != null) {
        await _storage.write(
          key: _offlineConfigKey,
          value: jsonEncode(sessionData['offline_config']),
        );
      }

      await _storage.write(key: _isLoggedInKey, value: 'true');
      await _storage.write(
        key: _lastOnlineAuthKey,
        value: DateTime.now().toIso8601String(),
      );

      UnifiedLogger.success('✅ Auth session saved securely');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to save auth session', error: e);
      rethrow;
    }
  }

  /// 📖 الحصول على Auth Session المحفوظة
  Future<Map<String, dynamic>?> getAuthSession() async {
    try {
      final jsonStr = await _storage.read(key: _authSessionKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read auth session', error: e);
      return null;
    }
  }

  /// 📅 الحصول على Token Expiry
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null || expiryStr.isEmpty) return null;
      return DateTime.parse(expiryStr);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read token expiry', error: e);
      return null;
    }
  }

  /// ⏰ التحقق من انتهاء صلاحية الـ Token
  Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  /// 📊 الحصول على عدد الأيام المتبقية للـ Token
  Future<int> getRemainingTokenDays() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return 0;
      final remaining = expiry.difference(DateTime.now()).inDays;
      return remaining < 0 ? 0 : remaining;
    } catch (e) {
      return 0;
    }
  }

  /// 🔄 هل يجب تجديد الـ Token (أقل من يومين)
  Future<bool> shouldRefreshToken() async {
    try {
      final remainingDays = await getRemainingTokenDays();
      return remainingDays <= 2 && remainingDays > 0;
    } catch (e) {
      return false;
    }
  }

  /// 🔄 تحديث Token فقط (بعد Refresh)
  Future<void> updateToken({
    required String accessToken,
    required DateTime expiresAt,
  }) async {
    try {
      // تحديث في auth_session
      final session = await getAuthSession();
      if (session != null) {
        session['token'] = {
          'access_token': accessToken,
          'token_type': 'Bearer',
          'expires_at': expiresAt.toIso8601String(),
        };
        await _storage.write(key: _authSessionKey, value: jsonEncode(session));
      }

      // تحديث القيم المفردة
      await _storage.write(key: _authTokenKey, value: accessToken);
      await _storage.write(key: _tokenExpiryKey, value: expiresAt.toIso8601String());

      UnifiedLogger.info('🔄 Token updated - expires: $expiresAt');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update token', error: e);
      rethrow;
    }
  }

  /// ⚙️ الحصول على Offline Config
  Future<Map<String, dynamic>?> getOfflineConfig() async {
    try {
      final jsonStr = await _storage.read(key: _offlineConfigKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read offline config', error: e);
      return null;
    }
  }

  /// 📅 الحصول على آخر تسجيل دخول online
  Future<DateTime?> getLastOnlineAuth() async {
    try {
      final timeStr = await _storage.read(key: _lastOnlineAuthKey);
      if (timeStr == null || timeStr.isEmpty) return null;
      return DateTime.parse(timeStr);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read last online auth', error: e);
      return null;
    }
  }

  /// 👤 الحصول على User Data الكامل
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonStr = await _storage.read(key: _userDataKey);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      UnifiedLogger.error('❌ Failed to read user data', error: e);
      return null;
    }
  }

  /// ✅ التحقق من وجود Session صالحة (Token غير منتهي)
  Future<bool> hasValidSession() async {
    try {
      final hasToken = await hasAuthToken();
      if (!hasToken) return false;

      final isExpired = await isTokenExpired();
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  /// 🗑️ حذف Auth Session كاملة
  Future<void> clearAuthSession() async {
    try {
      await Future.wait([
        _storage.delete(key: _authSessionKey),
        _storage.delete(key: _authTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _tokenExpiryKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userEmailKey),
        _storage.delete(key: _userNameKey),
        _storage.delete(key: _userDataKey),
        _storage.delete(key: _offlineConfigKey),
        _storage.delete(key: _isLoggedInKey),
        _storage.delete(key: _lastOnlineAuthKey),
      ]);
      UnifiedLogger.info('🗑️ Auth session cleared');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to clear auth session', error: e);
      rethrow;
    }
  }

  // ===========================
  // 🔐 REMEMBER ME METHODS
  // ===========================

  /// 💾 حفظ بيانات تسجيل الدخول (Remember Me)
  /// افتراضيًا: حفظ البريد الإلكتروني فقط لأمان أعلى.
  /// يمكن تفعيل حفظ كلمة المرور صراحة عبر [savePassword].
  Future<void> saveLoginCredentials({
    required String email,
    String? password,
    bool savePassword = false,
  }) async {
    try {
      final writes = <Future<void>>[
        _storage.write(key: _rememberMeKey, value: 'true'),
        _storage.write(key: _savedEmailKey, value: email),
      ];

      if (savePassword && password != null && password.isNotEmpty) {
        final encodedPassword = base64Encode(utf8.encode(password));
        writes.add(_storage.write(key: _savedPasswordKey, value: encodedPassword));
      } else {
        // تنظيف أي كلمة مرور قديمة كانت محفوظة من إصدارات سابقة
        writes.add(_storage.delete(key: _savedPasswordKey));
      }

      await Future.wait(writes);

      UnifiedLogger.success('✅ Login credentials saved securely');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to save login credentials', error: e);
      rethrow;
    }
  }

  /// 📖 الحصول على بيانات تسجيل الدخول المحفوظة
  Future<({String? email, String? password, bool rememberMe})> getSavedCredentials() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);

      if (rememberMe != 'true') {
        return (email: null, password: null, rememberMe: false);
      }

      final email = await _storage.read(key: _savedEmailKey);
      final encodedPassword = await _storage.read(key: _savedPasswordKey);

      String? password;
      if (encodedPassword != null && encodedPassword.isNotEmpty) {
        try {
          password = utf8.decode(base64Decode(encodedPassword));
        } catch (_) {
          password = null;
        }
      }

      return (email: email, password: password, rememberMe: true);
    } catch (e) {
      UnifiedLogger.error('❌ Failed to get saved credentials', error: e);
      return (email: null, password: null, rememberMe: false);
    }
  }

  /// ✅ التحقق من وجود بيانات محفوظة
  Future<bool> hasRememberMe() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      return false;
    }
  }

  /// 🗑️ حذف بيانات تسجيل الدخول المحفوظة
  Future<void> clearSavedCredentials() async {
    try {
      await Future.wait([
        _storage.delete(key: _rememberMeKey),
        _storage.delete(key: _savedEmailKey),
        _storage.delete(key: _savedPasswordKey),
      ]);
      UnifiedLogger.info('🗑️ Saved credentials cleared');
    } catch (e) {
      UnifiedLogger.error('❌ Failed to clear saved credentials', error: e);
    }
  }

  /// 🔄 تحديث حالة Remember Me فقط (بدون حذف البيانات)
  Future<void> setRememberMe(bool enabled) async {
    try {
      if (enabled) {
        await _storage.write(key: _rememberMeKey, value: 'true');
      } else {
        await clearSavedCredentials();
      }
    } catch (e) {
      UnifiedLogger.error('❌ Failed to update remember me', error: e);
    }
  }

  // ===========================
  // 🔐 OFFLINE AUTH METHODS
  // ===========================

  Future<void> saveLastSuccessfulEmail(String email) async {
    await _storage.write(key: _lastSuccessfulEmailKey, value: email);
  }

  Future<String?> getLastSuccessfulEmail() async {
    return _storage.read(key: _lastSuccessfulEmailKey);
  }

  Future<void> saveOfflineAuthHash(String hash) async {
    await _storage.write(key: _offlineAuthHashKey, value: hash);
  }

  Future<String?> getOfflineAuthHash() async {
    return _storage.read(key: _offlineAuthHashKey);
  }

  Future<void> setBiometricEnabledFlag(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<bool> getBiometricEnabledFlag() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }
}
