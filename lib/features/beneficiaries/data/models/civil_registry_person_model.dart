import '../../domain/entities/civil_registry_person.dart';

/// 📦 Civil Registry Person Model
///
/// Data layer model that converts between domain entity and JSON/database.
class CivilRegistryPersonModel extends CivilRegistryPerson {
  const CivilRegistryPersonModel({
    required super.nationalId,
    required super.firstName,
    required super.fatherName,
    super.grandfatherName,
    required super.lastName,
    super.motherName,
    super.birthDate,
    super.gender,
    super.birthPlace,
    super.address,
    super.province,
    super.city,
    super.registrationDate,
    super.status,
  });

  /// Create from JSON (from database or API)
  factory CivilRegistryPersonModel.fromJson(Map<String, dynamic> json) {
    return CivilRegistryPersonModel(
      nationalId: json['national_id'] as String,
      firstName: json['first_name'] as String,
      fatherName: json['father_name'] as String,
      grandfatherName: json['grandfather_name'] as String?,
      lastName: json['last_name'] as String,
      motherName: json['mother_name'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      birthPlace: json['birth_place'] as String?,
      address: json['address'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      registrationDate: json['registration_date'] != null
          ? DateTime.parse(json['registration_date'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'national_id': nationalId,
      'first_name': firstName,
      'father_name': fatherName,
      'grandfather_name': grandfatherName,
      'last_name': lastName,
      'mother_name': motherName,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'birth_place': birthPlace,
      'address': address,
      'province': province,
      'city': city,
      'registration_date': registrationDate?.toIso8601String(),
      'status': status,
    };
  }

  /// Convert from domain entity
  factory CivilRegistryPersonModel.fromEntity(CivilRegistryPerson entity) {
    return CivilRegistryPersonModel(
      nationalId: entity.nationalId,
      firstName: entity.firstName,
      fatherName: entity.fatherName,
      grandfatherName: entity.grandfatherName,
      lastName: entity.lastName,
      motherName: entity.motherName,
      birthDate: entity.birthDate,
      gender: entity.gender,
      birthPlace: entity.birthPlace,
      address: entity.address,
      province: entity.province,
      city: entity.city,
      registrationDate: entity.registrationDate,
      status: entity.status,
    );
  }

  /// Convert to domain entity
  CivilRegistryPerson toEntity() {
    return CivilRegistryPerson(
      nationalId: nationalId,
      firstName: firstName,
      fatherName: fatherName,
      grandfatherName: grandfatherName,
      lastName: lastName,
      motherName: motherName,
      birthDate: birthDate,
      gender: gender,
      birthPlace: birthPlace,
      address: address,
      province: province,
      city: city,
      registrationDate: registrationDate,
      status: status,
    );
  }
}
