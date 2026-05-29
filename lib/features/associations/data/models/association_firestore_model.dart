import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/association_firestore_entity.dart';

class AssociationFirestoreModel extends AssociationFirestoreEntity {
  const AssociationFirestoreModel({
    required super.id,
    required super.nameAr,
    required super.type,
    super.nameEn,
    super.registrationNumber,
    super.contactPersonName,
    super.contactPersonPhone,
    super.email,
    super.address,
    super.governorate,
    super.city,
    super.notes,
    super.isActive,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory AssociationFirestoreModel.fromJson(Map<String, dynamic> json) {
    return AssociationFirestoreModel(
      id: (json['id'] ?? '').toString(),
      nameAr: (json['nameAr'] ?? '').toString(),
      nameEn: json['nameEn']?.toString(),
      type: (json['type'] ?? 'other').toString(),
      registrationNumber: json['registrationNumber']?.toString(),
      contactPersonName: json['contactPersonName']?.toString(),
      contactPersonPhone: json['contactPersonPhone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      governorate: json['governorate']?.toString(),
      city: json['city']?.toString(),
      notes: json['notes']?.toString(),
      isActive: json['isActive'] == true,
      createdBy: json['createdBy']?.toString(),
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestoreCreateJson({required String uid}) {
    return <String, dynamic>{
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'type': type,
      'registrationNumber': registrationNumber,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'email': email,
      'address': address,
      'governorate': governorate,
      'city': city,
      'notes': notes,
      'isActive': isActive,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreUpdateJson() {
    return <String, dynamic>{
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'type': type,
      'registrationNumber': registrationNumber,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'email': email,
      'address': address,
      'governorate': governorate,
      'city': city,
      'notes': notes,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AssociationContactModel extends AssociationContactEntity {
  const AssociationContactModel({
    required super.id,
    required super.associationId,
    required super.name,
    required super.role,
    super.phone,
    super.email,
    super.notes,
    super.isPrimary,
    super.createdAt,
    super.updatedAt,
  });

  factory AssociationContactModel.fromJson(Map<String, dynamic> json) {
    return AssociationContactModel(
      id: (json['id'] ?? '').toString(),
      associationId: (json['associationId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? 'other').toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      notes: json['notes']?.toString(),
      isPrimary: json['isPrimary'] == true,
      createdAt: _readDate(json['createdAt']),
      updatedAt: _readDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestoreCreateJson() {
    return <String, dynamic>{
      'id': id,
      'associationId': associationId,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'notes': notes,
      'isPrimary': isPrimary,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toFirestoreUpdateJson() {
    return <String, dynamic>{
      'id': id,
      'associationId': associationId,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'notes': notes,
      'isPrimary': isPrimary,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
