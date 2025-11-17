import '../../../search/data/datasources/civil_registry_database.dart';
import '../models/civil_registry_person_model.dart';
import '../../domain/repositories/civil_registry_repository.dart';

/// 💾 Civil Registry Local Data Source
///
/// Handles database operations for civil registry data.
/// Uses the same CivilRegistryDatabase as the search page (persons.db)
class CivilRegistryLocalDataSource {
  final CivilRegistryDatabase database;

  const CivilRegistryLocalDataSource(this.database);

  /// Fetch person by national ID
  Future<CivilRegistryPersonModel?> getByNationalId(String nationalId) async {
    try {
      final result = await database.searchByNationalId(nationalId);

      if (result == null) {
        return null;
      }

      return _mapFromCivilPerson(result);
    } catch (e) {
      throw CivilRegistryException(
        'خطأ في قاعدة البيانات: ${e.toString()}',
        CivilRegistryErrorType.serverError,
      );
    }
  }

  /// Search for people by name
  Future<List<CivilRegistryPersonModel>> searchByName({
    required String name,
    String? governorate,
    int? genderCode,
    int limit = 20,
  }) async {
    try {
      final results = await database.searchByName(
        name,
        governorate: governorate,
        genderCode: genderCode,
        limit: limit,
      );

      return results.map((r) => _mapFromCivilPerson(r)).toList();
    } catch (e) {
      throw CivilRegistryException(
        'خطأ في البحث: ${e.toString()}',
        CivilRegistryErrorType.serverError,
      );
    }
  }

  /// Check if national ID exists (lightweight)
  Future<bool> exists(String nationalId) async {
    try {
      final result = await database.searchByNationalId(nationalId);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Map CivilPerson (from search database) to CivilRegistryPersonModel
  CivilRegistryPersonModel _mapFromCivilPerson(dynamic civilPerson) {
    return CivilRegistryPersonModel(
      nationalId: civilPerson.nationalId,
      firstName: civilPerson.firstName,
      fatherName: civilPerson.fatherName,
      grandfatherName: civilPerson.grandFatherName,
      lastName: civilPerson.familyName,
      motherName: civilPerson.motherName,
      birthDate: civilPerson.birthDate != null
          ? DateTime.tryParse(civilPerson.birthDate!)
          : null,
      gender: civilPerson.gender.arabicLabel, // 'ذكر' or 'أنثى'
      birthPlace: civilPerson.city,
      address: _buildAddress(civilPerson),
      province: civilPerson.governorate,
      city: civilPerson.city,
      registrationDate: null, // Not in search database
      status: 'active', // Search database only has active records
    );
  }

  /// Build address from available fields
  String? _buildAddress(dynamic civilPerson) {
    final parts = <String>[];

    if (civilPerson.city != null) parts.add(civilPerson.city!);
    if (civilPerson.governorate != null) parts.add(civilPerson.governorate!);

    return parts.isEmpty ? null : parts.join(', ');
  }
}
