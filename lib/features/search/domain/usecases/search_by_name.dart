import '../entities/search_entities.dart';
import '../repositories/civil_search_repository.dart';

/// 🔍 Search By Name Use Case
///
/// Business logic for searching persons by name with filters and pagination.
class SearchByNameUseCase {
  final CivilSearchRepository repository;

  const SearchByNameUseCase(this.repository);

  /// Execute search by name
  ///
  /// Parameters:
  /// - query: Search text (name)
  /// - filter: Optional governorate/gender filters
  /// - page: Page number (1-based)
  /// - pageSize: Results per page
  Future<SearchResult> call({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    // Validate input
    final cleaned = _cleanQuery(query);
    if (cleaned.isEmpty) {
      return const SearchResult(
        persons: [],
        hasMore: false,
        currentPage: 0,
        totalResults: 0,
      );
    }

    // Perform search
    return await repository.searchByName(
      query: cleaned,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Clean and normalize search query
  String _cleanQuery(String query) {
    return query.trim();
  }
}
