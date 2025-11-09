// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Visit _$VisitFromJson(Map<String, dynamic> json) => Visit(
  id: json['id'] as String,
  beneficiaryId: json['beneficiaryId'] as String,
  visitDate: DateTime.parse(json['visitDate'] as String),
  staffName: json['staffName'] as String,
  notes: json['notes'] as String? ?? '',
  isSubmitted: json['isSubmitted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncState: json['syncState'] as String? ?? 'pending',
);

Map<String, dynamic> _$VisitToJson(Visit instance) => <String, dynamic>{
  'id': instance.id,
  'beneficiaryId': instance.beneficiaryId,
  'visitDate': instance.visitDate.toIso8601String(),
  'staffName': instance.staffName,
  'notes': instance.notes,
  'isSubmitted': instance.isSubmitted,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'syncState': instance.syncState,
};
