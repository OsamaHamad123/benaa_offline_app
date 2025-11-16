import '../../domain/entities/civil_person.dart';

/// 🗺️ Person Mapper - Maps database rows to CivilPerson entities
///
/// Single Responsibility: Data mapping only
class PersonMapper {
  /// Map database row to CivilPerson entity
  static CivilPerson fromDatabase(Map<String, dynamic> row) {
    return CivilPerson(
      nationalId: row['CI_ID_NUM']?.toString() ?? '',
      firstName: row['CI_FIRST_ARB'] as String? ?? '',
      fatherName: row['CI_FATHER_ARB'] as String? ?? '',
      grandFatherName: row['CI_GRAND_FATHER_ARB'] as String? ?? '',
      familyName: row['CI_FAMILY_ARB'] as String? ?? '',
      motherName: row['MOTHER_NAME1'] as String?,
      gender: Gender.fromCode(row['CI_SEX_CD'] as int?),
      birthDate: row['CI_BIRTH_DT'] as String?,
      city: row['CITY']?.toString(),
      governorate: row['CITY']?.toString(),
    );
  }

  /// Map list of database rows to list of CivilPerson entities
  static List<CivilPerson> fromDatabaseList(List<Map<String, dynamic>> rows) {
    return rows.map(fromDatabase).toList();
  }
}
