// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRequest _$SyncRequestFromJson(Map<String, dynamic> json) => SyncRequest(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => SyncChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$SyncRequestToJson(SyncRequest instance) =>
    <String, dynamic>{
      'changes': instance.changes,
      'timestamp': instance.timestamp.toIso8601String(),
    };

SyncChange _$SyncChangeFromJson(Map<String, dynamic> json) => SyncChange(
      clientId: json['client_id'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$SyncChangeToJson(SyncChange instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'action': instance.action,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
    };

SyncResponse _$SyncResponseFromJson(Map<String, dynamic> json) => SyncResponse(
      success: (json['success'] as List<dynamic>)
          .map((e) => SyncSuccess.fromJson(e as Map<String, dynamic>))
          .toList(),
      conflicts: (json['conflicts'] as List<dynamic>)
          .map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => SyncError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncResponseToJson(SyncResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'conflicts': instance.conflicts,
      'errors': instance.errors,
    };

SyncSuccess _$SyncSuccessFromJson(Map<String, dynamic> json) => SyncSuccess(
      clientId: json['client_id'] as String,
      serverId: (json['server_id'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SyncSuccessToJson(SyncSuccess instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'server_id': instance.serverId,
      'status': instance.status,
    };

SyncConflict _$SyncConflictFromJson(Map<String, dynamic> json) => SyncConflict(
      clientId: json['client_id'] as String,
      reason: json['reason'] as String,
      serverVersion: ServerVersion.fromJson(
          json['server_version'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SyncConflictToJson(SyncConflict instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'reason': instance.reason,
      'server_version': instance.serverVersion,
    };

ServerVersion _$ServerVersionFromJson(Map<String, dynamic> json) =>
    ServerVersion(
      id: (json['id'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ServerVersionToJson(ServerVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'updated_at': instance.updatedAt.toIso8601String(),
      'data': instance.data,
    };

SyncError _$SyncErrorFromJson(Map<String, dynamic> json) => SyncError(
      clientId: json['client_id'] as String?,
      error: json['error'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SyncErrorToJson(SyncError instance) => <String, dynamic>{
      'client_id': instance.clientId,
      'error': instance.error,
      'message': instance.message,
    };

PullChangesResponse<T> _$PullChangesResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PullChangesResponse<T>(
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      pagination:
          PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
      syncTimestamp: DateTime.parse(json['sync_timestamp'] as String),
    );

Map<String, dynamic> _$PullChangesResponseToJson<T>(
  PullChangesResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': instance.data.map(toJsonT).toList(),
      'pagination': instance.pagination,
      'sync_timestamp': instance.syncTimestamp.toIso8601String(),
    };

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
      'has_more': instance.hasMore,
    };

ChangeItem<T> _$ChangeItemFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ChangeItem<T>(
      item: fromJsonT(json['item']),
      syncAction: json['_sync_action'] as String,
    );

Map<String, dynamic> _$ChangeItemToJson<T>(
  ChangeItem<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'item': toJsonT(instance.item),
      '_sync_action': instance.syncAction,
    };
