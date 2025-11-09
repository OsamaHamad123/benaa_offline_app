// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beneficiary _$BeneficiaryFromJson(Map<String, dynamic> json) => Beneficiary(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  fullNameNorm: json['fullNameNorm'] as String,
  nationalId: json['nationalId'] as String,
  fileNo: json['fileNo'] as String,
  governorate: json['governorate'] as String,
  gender: json['gender'] as String,
  category: json['category'] as String,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  notes: json['notes'] as String? ?? '',
  associationName: json['associationName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncState: json['syncState'] as String? ?? 'pending',
);

Map<String, dynamic> _$BeneficiaryToJson(Beneficiary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'fullNameNorm': instance.fullNameNorm,
      'nationalId': instance.nationalId,
      'fileNo': instance.fileNo,
      'governorate': instance.governorate,
      'gender': instance.gender,
      'category': instance.category,
      'birthDate': instance.birthDate?.toIso8601String(),
      'notes': instance.notes,
      'associationName': instance.associationName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncState': instance.syncState,
    };
