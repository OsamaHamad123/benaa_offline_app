import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(),
    lOptions: LinuxOptions(),
  );

  // Keys
  static const String _dbKeyName = 'db_encryption_key';
  static const String _fileEncKeyName = 'file_encryption_key';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  /// Get or generate database encryption key
  static Future<String> getDbKey() async {
    var key = await _storage.read(key: _dbKeyName);
    if (key == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      key = base64UrlEncode(bytes);
      await _storage.write(key: _dbKeyName, value: key);
    }
    return key;
  }

  /// Get or generate file encryption key
  static Future<String> getFileEncryptionKey() async {
    var key = await _storage.read(key: _fileEncKeyName);
    if (key == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      key = base64UrlEncode(bytes);
      await _storage.write(key: _fileEncKeyName, value: key);
    }
    return key;
  }

  /// Store authentication tokens
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? username,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (userId != null) _storage.write(key: _userIdKey, value: userId),
      if (username != null) _storage.write(key: _usernameKey, value: username),
    ]);
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Clear all auth data
  static Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _usernameKey),
    ]);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save the logged-in username (for login prefill).
  /// كلمات المرور لا تُخزن محلياً أبداً.
  static Future<void> saveCredentials(String username) async {
    // Store username and create a mock token for offline mode
    await storeTokens(
      accessToken: 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'offline_refresh_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      userId: username,
    );
  }

  /// Clear user credentials (for logout)
  static Future<void> clearCredentials() async {
    await clearAuth();
  }

  /// Store arbitrary secure value
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read arbitrary secure value
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete arbitrary secure value
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all stored data (use with caution!)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
