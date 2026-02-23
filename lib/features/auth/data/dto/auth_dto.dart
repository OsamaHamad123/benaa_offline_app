import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

// ===========================
// 🔄 CUSTOM CONVERTERS
// ===========================

/// محول مخصص لتحويل أي قيمة (int, String, etc) إلى String بشكل آمن
class StringConverter implements JsonConverter<String?, Object?> {
  const StringConverter();

  @override
  String? fromJson(Object? json) {
    if (json == null) return null;
    return json.toString();
  }

  @override
  Object? toJson(String? object) => object;
}

// ===========================
// 📤 LOGIN REQUEST
// ===========================

/// 📤 طلب تسجيل الدخول - متوافق مع API الجديد
@JsonSerializable()
class MobileLoginRequest {
  final String email;
  final String password;

  @JsonKey(name: 'device_id')
  final String deviceId;

  @JsonKey(name: 'device_name')
  final String? deviceName;

  @JsonKey(name: 'device_platform')
  final String? devicePlatform;

  MobileLoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    this.deviceName,
    this.devicePlatform,
  });

  factory MobileLoginRequest.fromJson(Map<String, dynamic> json) => _$MobileLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MobileLoginRequestToJson(this);
}

// ===========================
// 📥 LOGIN RESPONSE
// ===========================

/// 📥 استجابة تسجيل الدخول الكاملة
@JsonSerializable()
class MobileLoginResponse {
  final bool success;
  final String? message;
  final MobileLoginData? data;
  final String? error;
  final Map<String, dynamic>? errors;

  MobileLoginResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.errors,
  });

  factory MobileLoginResponse.fromJson(Map<String, dynamic> json) => _$MobileLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MobileLoginResponseToJson(this);
}

/// 📦 بيانات تسجيل الدخول
@JsonSerializable()
class MobileLoginData {
  final MobileUserDto user;
  final MobileTokenDto token;

  @JsonKey(name: 'offline_config')
  final MobileOfflineConfigDto offlineConfig;

  MobileLoginData({
    required this.user,
    required this.token,
    required this.offlineConfig,
  });

  factory MobileLoginData.fromJson(Map<String, dynamic> json) => _$MobileLoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$MobileLoginDataToJson(this);
}

/// 👤 بيانات المستخدم
@JsonSerializable()
class MobileUserDto {
  final int id;
  final String name;
  final String email;

  @StringConverter()
  final String? phone;

  @StringConverter()
  final String? avatar;

  final String role;
  final List<String> roles;
  final List<String> permissions;

  MobileUserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role, this.phone,
    this.avatar,
    this.roles = const [],
    this.permissions = const [],
  });

  factory MobileUserDto.fromJson(Map<String, dynamic> json) => _$MobileUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MobileUserDtoToJson(this);
}

/// 🔑 بيانات الـ Token
@JsonSerializable()
class MobileTokenDto {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  @JsonKey(name: 'expires_in_days')
  final int expiresInDays;

  @JsonKey(name: 'expires_in_seconds')
  final int expiresInSeconds;

  MobileTokenDto({
    required this.accessToken,
    required this.expiresAt, required this.expiresInDays, required this.expiresInSeconds, this.tokenType = 'Bearer',
  });

  factory MobileTokenDto.fromJson(Map<String, dynamic> json) => _$MobileTokenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MobileTokenDtoToJson(this);

  /// 📅 تحويل expires_at إلى DateTime
  DateTime get expiresAtDateTime => DateTime.parse(expiresAt);
}

/// ⚙️ إعدادات Offline
@JsonSerializable()
class MobileOfflineConfigDto {
  @JsonKey(name: 'max_offline_days')
  final int maxOfflineDays;

  @JsonKey(name: 'require_online_reauth')
  final bool requireOnlineReauth;

  @JsonKey(name: 'sync_required_on_expiry')
  final bool syncRequiredOnExpiry;

  MobileOfflineConfigDto({
    this.maxOfflineDays = 10,
    this.requireOnlineReauth = true,
    this.syncRequiredOnExpiry = true,
  });

  factory MobileOfflineConfigDto.fromJson(Map<String, dynamic> json) => _$MobileOfflineConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MobileOfflineConfigDtoToJson(this);
}

// ===========================
// 🔄 VALIDATE TOKEN RESPONSE
// ===========================

/// ✅ استجابة التحقق من صلاحية الـ Token
@JsonSerializable()
class ValidateTokenResponse {
  final bool success;
  final bool valid;
  final String? message;
  final ValidateTokenData? data;
  final String? error;
  @JsonKey(name: 'action_required')
  final String? actionRequired;

  ValidateTokenResponse({
    required this.success,
    required this.valid,
    this.message,
    this.data,
    this.error,
    this.actionRequired,
  });

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) => _$ValidateTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateTokenResponseToJson(this);
}

@JsonSerializable()
class ValidateTokenData {
  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'user_name')
  final String userName;

  @JsonKey(name: 'token_expires_at')
  final String tokenExpiresAt;

  @JsonKey(name: 'remaining_days')
  final int remainingDays;

  @JsonKey(name: 'remaining_seconds')
  final int remainingSeconds;

  @JsonKey(name: 'should_refresh')
  final bool shouldRefresh;

  ValidateTokenData({
    required this.userId,
    required this.userName,
    required this.tokenExpiresAt,
    required this.remainingDays,
    required this.remainingSeconds,
    required this.shouldRefresh,
  });

  factory ValidateTokenData.fromJson(Map<String, dynamic> json) => _$ValidateTokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateTokenDataToJson(this);
}

// ===========================
// 🔄 REFRESH TOKEN REQUEST/RESPONSE
// ===========================

/// 🔄 طلب تجديد الـ Token
@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'device_id')
  final String deviceId;

  RefreshTokenRequest({required this.deviceId});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

/// 🔄 استجابة تجديد الـ Token
@JsonSerializable()
class RefreshTokenResponse {
  final bool success;
  final String? message;
  final RefreshTokenData? data;
  final String? error;

  RefreshTokenResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}

@JsonSerializable()
class RefreshTokenData {
  final MobileTokenDto token;

  RefreshTokenData({required this.token});

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) => _$RefreshTokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenDataToJson(this);
}

// ===========================
// 🚪 LOGOUT REQUEST
// ===========================

/// 🚪 طلب تسجيل الخروج
@JsonSerializable()
class LogoutRequest {
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'logout_all_devices')
  final bool? logoutAllDevices;

  LogoutRequest({this.deviceId, this.logoutAllDevices});

  factory LogoutRequest.fromJson(Map<String, dynamic> json) => _$LogoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}
