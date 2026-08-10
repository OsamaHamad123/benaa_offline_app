// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Taxonomy _$TaxonomyFromJson(Map<String, dynamic> json) => Taxonomy(
      id: json['id'] as String,
      group: json['group'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaxonomyToJson(Taxonomy instance) => <String, dynamic>{
      'id': instance.id,
      'group': instance.group,
      'code': instance.code,
      'label': instance.label,
      'isActive': instance.isActive,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
