import '../entities/civil_registry_person.dart';

/// 📚 Civil Registry Repository Interface
///
/// Defines the contract for fetching data from the civil registry.
/// This is a pure interface with no implementation details.
abstract class CivilRegistryRepository {
  /// Fetch person data by national ID
  ///
  /// Returns [CivilRegistryPerson] if found, null otherwise.
  /// Throws [CivilRegistryException] on errors.
  Future<CivilRegistryPerson?> getByNationalId(String nationalId);

  /// Search for multiple people by name or other criteria
  ///
  /// Returns list of matching persons.
  Future<List<CivilRegistryPerson>> search({
    String? firstName,
    String? lastName,
    String? motherName,
    DateTime? birthDate,
  });

  /// Check if national ID exists in registry
  ///
  /// Lightweight check without fetching full data.
  Future<bool> exists(String nationalId);

  /// Clear cached data (if any)
  Future<void> clearCache();
}

/// ⚠️ Custom exception for civil registry operations
class CivilRegistryException implements Exception {
  final String message;
  final CivilRegistryErrorType type;

  const CivilRegistryException(this.message, this.type);

  @override
  String toString() => 'CivilRegistryException: $message (type: $type)';
}

/// Types of errors that can occur
enum CivilRegistryErrorType {
  notFound,
  connectionError,
  invalidNationalId,
  serverError,
  timeout,
  unknown,
}
