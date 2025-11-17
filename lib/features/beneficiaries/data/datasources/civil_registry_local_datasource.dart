import 'package:benaa_offline_app/data/db/daos/civil_registry_dao.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart';
import '../models/civil_registry_person_model.dart';
import '../../domain/repositories/civil_registry_repository.dart';

/// 💾 Civil Registry Local Data Source
///
/// Handles database operations for civil registry data.
/// Works with the existing CivilRegistryDao from Drift.
class CivilRegistryLocalDataSource {
  final CivilRegistryDao dao;

  const CivilRegistryLocalDataSource(this.dao);

  /// Fetch person by national ID
  Future<CivilRegistryPersonModel?> getByNationalId(String nationalId) async {
    try {
      final result = await dao.searchByNationalId(nationalId);

      if (result == null) {
        return null;
      }

      return _mapToModel(result);
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
      final results = await dao.searchByName(
        name,
        governorate: governorate,
        genderCode: genderCode,
        limit: limit,
      );

      return results.map((r) => _mapToModel(r)).toList();
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
      final result = await dao.searchByNationalId(nationalId);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Map database result to model
  CivilRegistryPersonModel _mapToModel(CivilRegistryData data) {
    return CivilRegistryPersonModel(
      nationalId: data.nationalId,
      firstName: data.firstName,
      fatherName: data.fatherName,
      grandfatherName: data.grandFatherName,
      lastName: data.familyName,
      motherName: data.motherName,
      birthDate: data.birthDate,
      gender: _mapGender(data.sexCode),
      birthPlace: data.cityName,
      address: _buildAddress(data),
      province: data.cityName, // Adjust based on your schema
      city: data.cityName,
      registrationDate: null, // Not in current schema
      status: _mapStatus(data.deadDate),
    );
  }

  /// Map gender code to string
  String? _mapGender(int? code) {
    if (code == null) return null;
    return code == 1 ? 'ذكر' : 'أنثى';
  }

  /// Map status code to string
  String? _mapStatus(int? deadDate) {
    if (deadDate == null) return 'active';
    return 'deceased';
  }

  /// Build address from available fields
  String? _buildAddress(CivilRegistryData data) {
    final parts = <String>[];

    if (data.street != null) parts.add(data.street!);
    if (data.houseNo != null) parts.add('رقم ${data.houseNo}');
    if (data.cityName != null) parts.add(data.cityName!);

    return parts.isEmpty ? null : parts.join(', ');
  }
}
