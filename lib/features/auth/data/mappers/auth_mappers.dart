import '../dto/auth_dto.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_session.dart';

/// 🔄 Mappers لتحويل DTOs إلى Entities والعكس
class AuthMappers {
  AuthMappers._();

  // ===========================
  // 👤 USER MAPPERS
  // ===========================

  /// تحويل MobileUserDto إلى AuthUser Entity
  static AuthUser userFromDto(MobileUserDto dto) {
    return AuthUser(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      avatar: dto.avatar,
      role: dto.role,
      roles: dto.roles,
      permissions: dto.permissions,
    );
  }

  /// تحويل AuthUser Entity إلى Map للتخزين المحلي
  static Map<String, dynamic> userToMap(AuthUser user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'avatar': user.avatar,
      'role': user.role,
      'roles': user.roles,
      'permissions': user.permissions,
    };
  }

  /// تحميل AuthUser من Map المخزن محلياً
  static AuthUser userFromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone']?.toString(),
      avatar: map['avatar']?.toString(),
      role: map['role'] as String,
      roles: List<String>.from(map['roles'] ?? []),
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }

  // ===========================
  // 🔑 TOKEN MAPPERS
  // ===========================

  /// تحويل MobileTokenDto إلى AuthToken Entity
  static AuthToken tokenFromDto(MobileTokenDto dto) {
    return AuthToken(
      accessToken: dto.accessToken,
      tokenType: dto.tokenType,
      expiresAt: dto.expiresAtDateTime,
      expiresInDays: dto.expiresInDays,
      expiresInSeconds: dto.expiresInSeconds,
    );
  }

  /// تحويل AuthToken Entity إلى Map للتخزين المحلي
  static Map<String, dynamic> tokenToMap(AuthToken token) {
    return {
      'access_token': token.accessToken,
      'token_type': token.tokenType,
      'expires_at': token.expiresAt.toIso8601String(),
    };
  }

  /// تحميل AuthToken من Map المخزن محلياً
  static AuthToken tokenFromMap(Map<String, dynamic> map) {
    final expiresAt = DateTime.parse(map['expires_at'] as String);
    final expiresInSeconds = map['expires_in_seconds'] as int? ?? expiresAt.difference(DateTime.now()).inSeconds;
    final expiresInDays = map['expires_in_days'] as int? ?? expiresAt.difference(DateTime.now()).inDays;

    return AuthToken(
      accessToken: map['access_token'] as String,
      tokenType: map['token_type'] as String? ?? 'Bearer',
      expiresAt: expiresAt,
      expiresInDays: expiresInDays,
      expiresInSeconds: expiresInSeconds,
    );
  }

  // ===========================
  // ⚙️ OFFLINE CONFIG MAPPERS
  // ===========================

  /// تحويل MobileOfflineConfigDto إلى OfflineConfig Entity
  static OfflineConfig configFromDto(MobileOfflineConfigDto dto) {
    return OfflineConfig(
      maxOfflineDays: dto.maxOfflineDays,
      requireOnlineReauth: dto.requireOnlineReauth,
      syncRequiredOnExpiry: dto.syncRequiredOnExpiry,
    );
  }

  /// تحويل OfflineConfig Entity إلى Map للتخزين المحلي
  static Map<String, dynamic> configToMap(OfflineConfig config) {
    return {
      'max_offline_days': config.maxOfflineDays,
      'require_online_reauth': config.requireOnlineReauth,
      'sync_required_on_expiry': config.syncRequiredOnExpiry,
    };
  }

  /// تحميل OfflineConfig من Map المخزن محلياً
  static OfflineConfig configFromMap(Map<String, dynamic> map) {
    return OfflineConfig(
      maxOfflineDays: map['max_offline_days'] as int? ?? 10,
      requireOnlineReauth: map['require_online_reauth'] as bool? ?? true,
      syncRequiredOnExpiry: map['sync_required_on_expiry'] as bool? ?? true,
    );
  }

  // ===========================
  // 📦 SESSION MAPPERS
  // ===========================

  /// تحويل MobileLoginResponse إلى AuthSession Entity
  static AuthSession? sessionFromLoginResponse(MobileLoginResponse response) {
    if (!response.success || response.data == null) {
      return null;
    }

    final data = response.data!;
    return AuthSession(
      user: userFromDto(data.user),
      token: tokenFromDto(data.token),
      offlineConfig: configFromDto(data.offlineConfig),
      loginAt: DateTime.now(),
    );
  }

  /// تحويل AuthSession Entity إلى Map للتخزين المحلي
  static Map<String, dynamic> sessionToMap(AuthSession session) {
    return {
      'user': userToMap(session.user),
      'token': tokenToMap(session.token),
      'offline_config': configToMap(session.offlineConfig),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// تحميل AuthSession من Map المخزن محلياً
  static AuthSession sessionFromMap(Map<String, dynamic> map) {
    return AuthSession(
      user: userFromMap(map['user'] as Map<String, dynamic>),
      token: tokenFromMap(map['token'] as Map<String, dynamic>),
      offlineConfig: configFromMap(map['offline_config'] as Map<String, dynamic>),
      loginAt: DateTime.parse(map['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  // ===========================
  // 🔄 REFRESH TOKEN MAPPER
  // ===========================

  /// تحديث Session بـ Token جديد من RefreshTokenResponse
  static AuthSession? updateSessionToken(
    AuthSession currentSession,
    RefreshTokenResponse response,
  ) {
    if (!response.success || response.data == null) {
      return null;
    }

    final newToken = tokenFromDto(response.data!.token);
    return currentSession.updateToken(newToken);
  }
}
