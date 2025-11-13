import '../entities/civil_person.dart';
import '../entities/search_entities.dart';

/// 📦 Civil Search Repository Interface (Domain Layer)
///
/// This defines the contract for civil search operations.
/// Implementation details are in the data layer.
abstract class CivilSearchRepository {
  /// Initialize the database connection
  Future<void> initialize();

  /// Search by exact national ID
  /// Returns null if not found
  Future<CivilPerson?> searchByNationalId(String nationalId);

  /// Search by name with filters and pagination
  Future<SearchResult> searchByName({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int page = 1,
    int pageSize = 20,
  });

  /// Get statistics about the civil registry
  Future<SearchStatistics> getStatistics();

  /// Dispose and clean up resources
  Future<void> dispose();
}
