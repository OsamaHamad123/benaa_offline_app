// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
  id: json['id'] as String,
  beneficiaryId: json['beneficiaryId'] as String,
  visitId: json['visitId'] as String?,
  type: json['type'] as String,
  path: json['path'] as String,
  hash: json['hash'] as String,
  size: (json['size'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncState: json['syncState'] as String? ?? 'pending',
);

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'beneficiaryId': instance.beneficiaryId,
      'visitId': instance.visitId,
      'type': instance.type,
      'path': instance.path,
      'hash': instance.hash,
      'size': instance.size,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncState': instance.syncState,
    };
