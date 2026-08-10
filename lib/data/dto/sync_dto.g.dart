// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRequestDto _$SyncRequestDtoFromJson(Map<String, dynamic> json) =>
    SyncRequestDto(
      lastSyncTime: json['lastSyncTime'] == null
          ? null
          : DateTime.parse(json['lastSyncTime'] as String),
      pendingChanges: (json['pendingChanges'] as List<dynamic>)
          .map((e) => PendingChangeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      deviceInfo:
          DeviceInfoDto.fromJson(json['deviceInfo'] as Map<String, dynamic>),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$SyncRequestDtoToJson(SyncRequestDto instance) =>
    <String, dynamic>{
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'pendingChanges': instance.pendingChanges,
      'deviceInfo': instance.deviceInfo,
      'userId': instance.userId,
    };

PendingChangeDto _$PendingChangeDtoFromJson(Map<String, dynamic> json) =>
    PendingChangeDto(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: json['operation'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: (json['priority'] as num?)?.toInt() ?? 5,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PendingChangeDtoToJson(PendingChangeDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'operation': instance.operation,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': instance.priority,
      'retryCount': instance.retryCount,
    };

DeviceInfoDto _$DeviceInfoDtoFromJson(Map<String, dynamic> json) =>
    DeviceInfoDto(
      deviceId: json['deviceId'] as String,
      appVersion: json['appVersion'] as String,
      platform: json['platform'] as String,
      osVersion: json['osVersion'] as String?,
      deviceModel: json['deviceModel'] as String?,
    );

Map<String, dynamic> _$DeviceInfoDtoToJson(DeviceInfoDto instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'appVersion': instance.appVersion,
      'platform': instance.platform,
      'osVersion': instance.osVersion,
      'deviceModel': instance.deviceModel,
    };

SyncResponseDto _$SyncResponseDtoFromJson(Map<String, dynamic> json) =>
    SyncResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String?,
      updatedData: (json['updatedData'] as List<dynamic>)
          .map((e) => ServerEntityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedIds: (json['deletedIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      serverTimestamp: DateTime.parse(json['serverTimestamp'] as String),
      failedChanges: (json['failedChanges'] as List<dynamic>?)
          ?.map((e) => FailedChangeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: json['stats'] == null
          ? null
          : SyncStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SyncResponseDtoToJson(SyncResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'updatedData': instance.updatedData,
      'deletedIds': instance.deletedIds,
      'serverTimestamp': instance.serverTimestamp.toIso8601String(),
      'failedChanges': instance.failedChanges,
      'stats': instance.stats,
    };

ServerEntityDto _$ServerEntityDtoFromJson(Map<String, dynamic> json) =>
    ServerEntityDto(
      entityType: json['entityType'] as String,
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$ServerEntityDtoToJson(ServerEntityDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'id': instance.id,
      'data': instance.data,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

FailedChangeDto _$FailedChangeDtoFromJson(Map<String, dynamic> json) =>
    FailedChangeDto(
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      reason: json['reason'] as String,
      errorCode: json['errorCode'] as String?,
      retryable: json['retryable'] as bool? ?? true,
      conflictData: json['conflictData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FailedChangeDtoToJson(FailedChangeDto instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'reason': instance.reason,
      'errorCode': instance.errorCode,
      'retryable': instance.retryable,
      'conflictData': instance.conflictData,
    };

SyncStatsDto _$SyncStatsDtoFromJson(Map<String, dynamic> json) => SyncStatsDto(
      receivedCount: (json['receivedCount'] as num).toInt(),
      sentCount: (json['sentCount'] as num).toInt(),
      deletedCount: (json['deletedCount'] as num).toInt(),
      failedCount: (json['failedCount'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SyncStatsDtoToJson(SyncStatsDto instance) =>
    <String, dynamic>{
      'receivedCount': instance.receivedCount,
      'sentCount': instance.sentCount,
      'deletedCount': instance.deletedCount,
      'failedCount': instance.failedCount,
      'durationSeconds': instance.durationSeconds,
    };

LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) =>
    LoginRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'deviceId': instance.deviceId,
    };

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      success: json['success'] as bool,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
    );

Map<String, dynamic> _$LoginResponseDtoToJson(LoginResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
      'message': instance.message,
      'errorCode': instance.errorCode,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String?,
      permissions: json['permissions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'permissions': instance.permissions,
    };
