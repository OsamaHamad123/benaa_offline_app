import '../entities/search_entities.dart';
import '../repositories/civil_search_repository.dart';

/// Use Case: Search for civil persons
///
/// Clean Architecture - Domain Layer
/// This use case encapsulates the business logic for searching civil persons
class SearchCivilPersonUseCase {
  final CivilSearchRepository repository;

  const SearchCivilPersonUseCase(this.repository);

  /// Execute search with query and filters
  ///
  /// Parameters:
  /// - query: Search term (name or national ID)
  /// - filter: Search filter (governorate, gender)
  /// - page: Current page number
  /// - pageSize: Number of results per page
  Future<SearchResult> call({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    // Validate query
    if (query.trim().isEmpty) {
      return const SearchResult(
        persons: [],
        hasMore: false,
        currentPage: 1,
        totalResults: 0,
      );
    }

    // Determine search type
    final isNationalId = _isNationalId(query);

    if (isNationalId) {
      // Search by national ID (returns single result or null)
      final person = await repository.searchByNationalId(query.trim());
      return SearchResult(
        persons: person != null ? [person] : [],
        hasMore: false,
        currentPage: 1,
        totalResults: person != null ? 1 : 0,
      );
    } else {
      // Search by name with filters
      return await repository.searchByName(
        query: query.trim(),
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    }
  }

  /// Check if query looks like a national ID (numbers only)
  bool _isNationalId(String query) {
    return RegExp(r'^\d+$').hasMatch(query.trim());
  }
}
