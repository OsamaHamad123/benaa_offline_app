class AssociationFirestoreEntity {
  final String id;
  final String nameAr;
  final String? nameEn;
  final String type;
  final String? registrationNumber;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? email;
  final String? address;
  final String? governorate;
  final String? city;
  final String? notes;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssociationFirestoreEntity({
    required this.id,
    required this.nameAr,
    required this.type,
    this.nameEn,
    this.registrationNumber,
    this.contactPersonName,
    this.contactPersonPhone,
    this.email,
    this.address,
    this.governorate,
    this.city,
    this.notes,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}

class AssociationContactEntity {
  final String id;
  final String associationId;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  final String? notes;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssociationContactEntity({
    required this.id,
    required this.associationId,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.notes,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });
}
