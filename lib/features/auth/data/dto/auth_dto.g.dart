// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobileLoginRequest _$MobileLoginRequestFromJson(Map<String, dynamic> json) =>
    MobileLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String?,
      devicePlatform: json['device_platform'] as String?,
    );

Map<String, dynamic> _$MobileLoginRequestToJson(MobileLoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'device_id': instance.deviceId,
      'device_name': instance.deviceName,
      'device_platform': instance.devicePlatform,
    };

MobileLoginResponse _$MobileLoginResponseFromJson(Map<String, dynamic> json) =>
    MobileLoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : MobileLoginData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MobileLoginResponseToJson(
        MobileLoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
      'errors': instance.errors,
    };

MobileLoginData _$MobileLoginDataFromJson(Map<String, dynamic> json) =>
    MobileLoginData(
      user: MobileUserDto.fromJson(json['user'] as Map<String, dynamic>),
      token: MobileTokenDto.fromJson(json['token'] as Map<String, dynamic>),
      offlineConfig: MobileOfflineConfigDto.fromJson(
          json['offline_config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MobileLoginDataToJson(MobileLoginData instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'offline_config': instance.offlineConfig,
    };

MobileUserDto _$MobileUserDtoFromJson(Map<String, dynamic> json) =>
    MobileUserDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: const StringConverter().fromJson(json['phone']),
      avatar: const StringConverter().fromJson(json['avatar']),
      role: json['role'] as String,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MobileUserDtoToJson(MobileUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': const StringConverter().toJson(instance.phone),
      'avatar': const StringConverter().toJson(instance.avatar),
      'role': instance.role,
      'roles': instance.roles,
      'permissions': instance.permissions,
    };

MobileTokenDto _$MobileTokenDtoFromJson(Map<String, dynamic> json) =>
    MobileTokenDto(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresAt: json['expires_at'] as String,
      expiresInDays: (json['expires_in_days'] as num).toInt(),
      expiresInSeconds: (json['expires_in_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$MobileTokenDtoToJson(MobileTokenDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_at': instance.expiresAt,
      'expires_in_days': instance.expiresInDays,
      'expires_in_seconds': instance.expiresInSeconds,
    };

MobileOfflineConfigDto _$MobileOfflineConfigDtoFromJson(
        Map<String, dynamic> json) =>
    MobileOfflineConfigDto(
      maxOfflineDays: (json['max_offline_days'] as num?)?.toInt() ?? 10,
      requireOnlineReauth: json['require_online_reauth'] as bool? ?? true,
      syncRequiredOnExpiry: json['sync_required_on_expiry'] as bool? ?? true,
    );

Map<String, dynamic> _$MobileOfflineConfigDtoToJson(
        MobileOfflineConfigDto instance) =>
    <String, dynamic>{
      'max_offline_days': instance.maxOfflineDays,
      'require_online_reauth': instance.requireOnlineReauth,
      'sync_required_on_expiry': instance.syncRequiredOnExpiry,
    };

ValidateTokenResponse _$ValidateTokenResponseFromJson(
        Map<String, dynamic> json) =>
    ValidateTokenResponse(
      success: json['success'] as bool,
      valid: json['valid'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : ValidateTokenData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] as String?,
      actionRequired: json['action_required'] as String?,
    );

Map<String, dynamic> _$ValidateTokenResponseToJson(
        ValidateTokenResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'valid': instance.valid,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
      'action_required': instance.actionRequired,
    };

ValidateTokenData _$ValidateTokenDataFromJson(Map<String, dynamic> json) =>
    ValidateTokenData(
      userId: (json['user_id'] as num).toInt(),
      userName: json['user_name'] as String,
      tokenExpiresAt: json['token_expires_at'] as String,
      remainingDays: (json['remaining_days'] as num).toInt(),
      remainingSeconds: (json['remaining_seconds'] as num).toInt(),
      shouldRefresh: json['should_refresh'] as bool,
    );

Map<String, dynamic> _$ValidateTokenDataToJson(ValidateTokenData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'user_name': instance.userName,
      'token_expires_at': instance.tokenExpiresAt,
      'remaining_days': instance.remainingDays,
      'remaining_seconds': instance.remainingSeconds,
      'should_refresh': instance.shouldRefresh,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(
      deviceId: json['device_id'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestToJson(
        RefreshTokenRequest instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
    };

RefreshTokenResponse _$RefreshTokenResponseFromJson(
        Map<String, dynamic> json) =>
    RefreshTokenResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : RefreshTokenData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$RefreshTokenResponseToJson(
        RefreshTokenResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
    };

RefreshTokenData _$RefreshTokenDataFromJson(Map<String, dynamic> json) =>
    RefreshTokenData(
      token: MobileTokenDto.fromJson(json['token'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RefreshTokenDataToJson(RefreshTokenData instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

LogoutRequest _$LogoutRequestFromJson(Map<String, dynamic> json) =>
    LogoutRequest(
      deviceId: json['device_id'] as String?,
      logoutAllDevices: json['logout_all_devices'] as bool?,
    );

Map<String, dynamic> _$LogoutRequestToJson(LogoutRequest instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'logout_all_devices': instance.logoutAllDevices,
    };
