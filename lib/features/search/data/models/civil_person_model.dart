import '../../domain/entities/civil_person.dart';

/// 📦 Civil Person Model - Data Layer
///
/// Maps database records to domain entities.
class CivilPersonModel extends CivilPerson {
  const CivilPersonModel({
    required super.nationalId,
    required super.firstName,
    required super.fatherName,
    required super.grandFatherName,
    required super.familyName,
    required super.gender, super.motherName,
    super.birthDate,
    super.city,
    super.governorate,
  });

  /// Create from database Map
  factory CivilPersonModel.fromMap(Map<String, dynamic> map) {
    return CivilPersonModel(
      nationalId: _safeString(map['CI_ID_NUM']),
      firstName: _safeString(map['CI_FIRST_ARB']),
      fatherName: _safeString(map['CI_FATHER_ARB']),
      grandFatherName: _safeString(map['CI_GRAND_FATHER_ARB']),
      familyName: _safeString(map['CI_FAMILY_ARB']),
      motherName: _safeString(map['MOTHER_NAME1'], allowEmpty: true),
      gender: Gender.fromCode(_safeInt(map['CI_SEX_CD'])),
      birthDate: _safeString(map['CI_DOB'], allowEmpty: true),
      city: _safeString(map['CITY'], allowEmpty: true),
      governorate: _safeString(map['CITY'], allowEmpty: true),
    );
  }

  /// Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'CI_ID_NUM': nationalId,
      'CI_FIRST_ARB': firstName,
      'CI_FATHER_ARB': fatherName,
      'CI_GRAND_FATHER_ARB': grandFatherName,
      'CI_FAMILY_ARB': familyName,
      'MOTHER_NAME1': motherName,
      'CI_SEX_CD': gender.code,
      'CI_DOB': birthDate,
      'CITY': city,
    };
  }

  /// Safe string extraction with validation
  static String _safeString(dynamic value, {bool allowEmpty = false}) {
    if (value == null) return allowEmpty ? '' : 'غير محدد';
    final str = value.toString().trim();
    if (str.isEmpty && !allowEmpty) return 'غير محدد';
    return str;
  }

  /// Safe integer extraction
  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
