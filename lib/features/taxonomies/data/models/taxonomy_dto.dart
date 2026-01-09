import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';

/// 📦 Taxonomy DTO
///
/// Data Transfer Object لتصنيف من API
class TaxonomyDTO {
  final String id;
  final String groupValue;
  final String code;
  final String label;
  final String? labelEn;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final String? description;
  final String? color;
  final String? icon;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TaxonomyDTO({
    required this.id,
    required this.groupValue,
    required this.code,
    required this.label,
    this.labelEn,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.description,
    this.color,
    this.icon,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TaxonomyDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyDTO(
      id: json['id']?.toString() ?? '',
      groupValue: json['group']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString(),
      parentId: json['parent_id']?.toString(),
      sortOrder: _parseInt(json['sort_order']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] as Map<String, dynamic> : const {},
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupValue,
      'code': code,
      'label': label,
      if (labelEn != null) 'label_en': labelEn,
      if (parentId != null) 'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (metadata.isNotEmpty) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  /// تحويل إلى Entity
  Taxonomy toEntity() {
    return Taxonomy(
      id: id,
      group: TaxonomyGroup.fromString(groupValue) ?? TaxonomyGroup.category,
      code: code,
      label: label,
      labelEn: labelEn,
      parentId: parentId,
      sortOrder: sortOrder,
      isActive: isActive,
      description: description,
      color: color,
      icon: icon,
      metadata: metadata,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt,
    );
  }

  /// إنشاء من Entity
  static TaxonomyDTO fromEntity(Taxonomy entity) {
    return TaxonomyDTO(
      id: entity.id,
      groupValue: entity.group.value,
      code: entity.code,
      label: entity.label,
      labelEn: entity.labelEn,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      metadata: entity.metadata ?? const {},
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  TaxonomyDTO copyWith({
    String? id,
    String? groupValue,
    String? code,
    String? label,
    String? labelEn,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    String? description,
    String? color,
    String? icon,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaxonomyDTO(
      id: id ?? this.id,
      groupValue: groupValue ?? this.groupValue,
      code: code ?? this.code,
      label: label ?? this.label,
      labelEn: labelEn ?? this.labelEn,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Helper methods
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// 📋 API Response DTOs

/// رد جلب التصنيفات
class TaxonomiesResponseDTO {
  final bool success;
  final List<TaxonomyDTO> data;
  final String? message;
  final TaxonomyMetaDTO? meta;

  const TaxonomiesResponseDTO({
    required this.success,
    required this.data,
    this.message,
    this.meta,
  });

  factory TaxonomiesResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomiesResponseDTO(
      success: json['success'] == true,
      data:
          (json['data'] as List<dynamic>?)?.map((e) => TaxonomyDTO.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      message: json['message']?.toString(),
      meta: json['meta'] != null ? TaxonomyMetaDTO.fromJson(json['meta'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

/// رد تصنيف واحد
class TaxonomyResponseDTO {
  final bool success;
  final TaxonomyDTO data;
  final String? message;

  const TaxonomyResponseDTO({
    required this.success,
    required this.data,
    this.message,
  });

  factory TaxonomyResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyResponseDTO(
      success: json['success'] == true,
      data: TaxonomyDTO.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      if (message != null) 'message': message,
    };
  }
}

/// رد المجموعات
class TaxonomyGroupsResponseDTO {
  final bool success;
  final List<TaxonomyGroupInfoDTO> data;
  final String? message;

  const TaxonomyGroupsResponseDTO({
    required this.success,
    required this.data,
    this.message,
  });

  factory TaxonomyGroupsResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyGroupsResponseDTO(
      success: json['success'] == true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TaxonomyGroupInfoDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      if (message != null) 'message': message,
    };
  }
}

/// معلومات المجموعة
class TaxonomyGroupInfoDTO {
  final String name;
  final String arabicName;
  final int count;
  final bool isEditable;

  const TaxonomyGroupInfoDTO({
    required this.name,
    required this.arabicName,
    this.count = 0,
    this.isEditable = true,
  });

  factory TaxonomyGroupInfoDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyGroupInfoDTO(
      name: json['name']?.toString() ?? '',
      arabicName: json['arabic_name']?.toString() ?? '',
      count: (json['count'] as int?) ?? 0,
      isEditable: json['is_editable'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arabic_name': arabicName,
      'count': count,
      'is_editable': isEditable,
    };
  }
}

/// بيانات الميتا
class TaxonomyMetaDTO {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final DateTime? lastSync;

  const TaxonomyMetaDTO({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.lastSync,
  });

  factory TaxonomyMetaDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyMetaDTO(
      currentPage: json['current_page'] as int?,
      lastPage: json['last_page'] as int?,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      lastSync: json['last_sync'] != null ? DateTime.tryParse(json['last_sync'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (currentPage != null) 'current_page': currentPage,
      if (lastPage != null) 'last_page': lastPage,
      if (perPage != null) 'per_page': perPage,
      if (total != null) 'total': total,
      if (lastSync != null) 'last_sync': lastSync!.toIso8601String(),
    };
  }
}

/// رد المزامنة
class TaxonomySyncResponseDTO {
  final bool success;
  final int added;
  final int updated;
  final int deleted;
  final String? message;
  final DateTime? syncTime;
  final List<TaxonomyDTO>? taxonomies;

  const TaxonomySyncResponseDTO({
    required this.success,
    this.added = 0,
    this.updated = 0,
    this.deleted = 0,
    this.message,
    this.syncTime,
    this.taxonomies,
  });

  factory TaxonomySyncResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomySyncResponseDTO(
      success: json['success'] == true,
      added: (json['added'] as int?) ?? 0,
      updated: (json['updated'] as int?) ?? 0,
      deleted: (json['deleted'] as int?) ?? 0,
      message: json['message']?.toString(),
      syncTime: json['sync_time'] != null ? DateTime.tryParse(json['sync_time'].toString()) : null,
      taxonomies:
          (json['taxonomies'] as List<dynamic>?)?.map((e) => TaxonomyDTO.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'added': added,
      'updated': updated,
      'deleted': deleted,
      if (message != null) 'message': message,
      if (syncTime != null) 'sync_time': syncTime!.toIso8601String(),
      if (taxonomies != null) 'taxonomies': taxonomies!.map((e) => e.toJson()).toList(),
    };
  }

  /// تحويل إلى نتيجة المزامنة
  TaxonomySyncResult toSyncResult() {
    return TaxonomySyncResult(
      addedCount: added,
      updatedCount: updated,
      deletedCount: deleted,
      syncTime: syncTime ?? DateTime.now(),
      success: success,
      message: message,
    );
  }
}

/// طلب إنشاء/تحديث تصنيف
class TaxonomyRequestDTO {
  final String? id;
  final String group;
  final String code;
  final String label;
  final String? labelEn;
  final String? parentId;
  final int? sortOrder;
  final bool? isActive;
  final String? description;
  final String? color;
  final String? icon;
  final Map<String, dynamic>? metadata;

  const TaxonomyRequestDTO({
    this.id,
    required this.group,
    required this.code,
    required this.label,
    this.labelEn,
    this.parentId,
    this.sortOrder,
    this.isActive,
    this.description,
    this.color,
    this.icon,
    this.metadata,
  });

  factory TaxonomyRequestDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyRequestDTO(
      id: json['id']?.toString(),
      group: json['group']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString(),
      parentId: json['parent_id']?.toString(),
      sortOrder: json['sort_order'] as int?,
      isActive: json['is_active'] as bool?,
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'group': group,
      'code': code,
      'label': label,
      if (labelEn != null) 'label_en': labelEn,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// إنشاء من Entity
  static TaxonomyRequestDTO fromEntity(Taxonomy entity) {
    return TaxonomyRequestDTO(
      id: entity.id,
      group: entity.group.value,
      code: entity.code,
      label: entity.label,
      labelEn: entity.labelEn,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      metadata: entity.metadata,
    );
  }
}

/// طلب المزامنة
class TaxonomySyncRequestDTO {
  final DateTime? lastSync;
  final String? group;
  final bool includeDeleted;

  const TaxonomySyncRequestDTO({
    this.lastSync,
    this.group,
    this.includeDeleted = true,
  });

  factory TaxonomySyncRequestDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomySyncRequestDTO(
      lastSync: json['last_sync'] != null ? DateTime.tryParse(json['last_sync'].toString()) : null,
      group: json['group']?.toString(),
      includeDeleted: json['include_deleted'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lastSync != null) 'last_sync': lastSync!.toIso8601String(),
      if (group != null) 'group': group,
      'include_deleted': includeDeleted,
    };
  }
}
