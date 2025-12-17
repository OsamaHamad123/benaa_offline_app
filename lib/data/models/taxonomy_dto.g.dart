// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxonomyDTO _$TaxonomyDTOFromJson(Map<String, dynamic> json) => TaxonomyDTO(
      id: json['id'] as String,
      group: json['group'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      parentId: json['parent_id'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TaxonomyDTOToJson(TaxonomyDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group': instance.group,
      'code': instance.code,
      'label': instance.label,
      'parent_id': instance.parentId,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
