import 'package:json_annotation/json_annotation.dart';

part 'sync_models.g.dart';

// ============================================================================
// Sync Request Models
// ============================================================================

@JsonSerializable()
class SyncRequest {
  final List<SyncChange> changes;
  final DateTime timestamp;

  const SyncRequest({required this.changes, required this.timestamp});

  factory SyncRequest.fromJson(Map<String, dynamic> json) => _$SyncRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRequestToJson(this);
}

@JsonSerializable()
class SyncChange {
  @JsonKey(name: 'client_id')
  final String clientId;

  final String action; // 'create', 'update', 'delete'

  final Map<String, dynamic> data;

  final DateTime timestamp;

  const SyncChange({
    required this.clientId,
    required this.action,
    required this.data,
    required this.timestamp,
  });

  factory SyncChange.fromJson(Map<String, dynamic> json) => _$SyncChangeFromJson(json);

  Map<String, dynamic> toJson() => _$SyncChangeToJson(this);
}

// ============================================================================
// Sync Response Models
// ============================================================================

@JsonSerializable()
class SyncResponse {
  final List<SyncSuccess> success;
  final List<SyncConflict> conflicts;
  final List<SyncError> errors;

  const SyncResponse({
    required this.success,
    required this.conflicts,
    required this.errors,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) => _$SyncResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);

  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
  bool get isFullySuccessful => !hasConflicts && !hasErrors;
}

@JsonSerializable()
class SyncSuccess {
  @JsonKey(name: 'client_id')
  final String clientId;

  @JsonKey(name: 'server_id')
  final int serverId;

  final String status;

  const SyncSuccess({
    required this.clientId,
    required this.serverId,
    required this.status,
  });

  factory SyncSuccess.fromJson(Map<String, dynamic> json) => _$SyncSuccessFromJson(json);

  Map<String, dynamic> toJson() => _$SyncSuccessToJson(this);
}

@JsonSerializable()
class SyncConflict {
  @JsonKey(name: 'client_id')
  final String clientId;

  final String reason;

  @JsonKey(name: 'server_version')
  final ServerVersion serverVersion;

  const SyncConflict({
    required this.clientId,
    required this.reason,
    required this.serverVersion,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) => _$SyncConflictFromJson(json);

  Map<String, dynamic> toJson() => _$SyncConflictToJson(this);
}

@JsonSerializable()
class ServerVersion {
  final int id;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final Map<String, dynamic> data;

  const ServerVersion({
    required this.id,
    required this.updatedAt,
    required this.data,
  });

  factory ServerVersion.fromJson(Map<String, dynamic> json) => _$ServerVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ServerVersionToJson(this);
}

@JsonSerializable()
class SyncError {
  @JsonKey(name: 'client_id')
  final String? clientId;

  final String error;

  final String? message;

  const SyncError({required this.error, this.clientId, this.message});

  factory SyncError.fromJson(Map<String, dynamic> json) => _$SyncErrorFromJson(json);

  Map<String, dynamic> toJson() => _$SyncErrorToJson(this);
}

// ============================================================================
// Pull Changes Models
// ============================================================================

@JsonSerializable(genericArgumentFactories: true)
class PullChangesResponse<T> {
  final List<T> data;

  final PaginationMeta pagination;

  @JsonKey(name: 'sync_timestamp')
  final DateTime syncTimestamp;

  const PullChangesResponse({
    required this.data,
    required this.pagination,
    required this.syncTimestamp,
  });

  factory PullChangesResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PullChangesResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => _$PullChangesResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginationMeta {
  final int total;

  final int page;

  @JsonKey(name: 'per_page')
  final int perPage;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}

// ============================================================================
// Change Item Wrapper (for delta sync)
// ============================================================================

@JsonSerializable(genericArgumentFactories: true)
class ChangeItem<T> {
  final T item;

  @JsonKey(name: '_sync_action')
  final String syncAction; // 'created', 'updated', 'deleted'

  const ChangeItem({required this.item, required this.syncAction});

  factory ChangeItem.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ChangeItemFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => _$ChangeItemToJson(this, toJsonT);

  bool get isCreated => syncAction == 'created';
  bool get isUpdated => syncAction == 'updated';
  bool get isDeleted => syncAction == 'deleted';
}
