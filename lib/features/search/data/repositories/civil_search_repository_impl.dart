import '../datasources/civil_registry_database.dart';
import '../../domain/entities/civil_person.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/civil_search_repository.dart';

/// 📦 Civil Search Repository Implementation - Direct SQLite 🚀
///
/// ✅ Uses CivilRegistryDatabase with direct SQLite access
/// ⚡ Performance: Fast searches on downloaded persons.db
/// 🔥 Optimized with indexes
class CivilSearchRepositoryImpl implements CivilSearchRepository {
  final CivilRegistryDatabase database;

  const CivilSearchRepositoryImpl(this.database);

  @override
  Future<void> initialize() async {
    // Database initializes on first access
  }

  @override
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    return await database.searchByNationalId(nationalId);
  }

  @override
  Future<SearchResult> searchByName({
    required String query,
    SearchFilter filter = const SearchFilter(),
    int page = 1,
    int pageSize = 20,
  }) async {
    // Calculate offset
    final offset = (page - 1) * pageSize;

    // Get one extra result to check if there are more
    final results = await database.searchByName(
      query,
      governorate: filter.governorate,
      genderCode: filter.gender?.code,
      limit: pageSize + 1,
      offset: offset,
    );

    // Check if there are more results
    final hasMore = results.length > pageSize;
    final persons = results.take(pageSize).toList();

    // Get total count for better UX (optional, can be cached)
    int totalResults = persons.length;
    if (page == 1 && persons.isNotEmpty) {
      // Only count on first page to avoid overhead
      totalResults = await database.getSearchCount(
        query,
        governorate: filter.governorate,
        genderCode: filter.gender?.code,
      );
    }

    return SearchResult(
      persons: persons,
      hasMore: hasMore,
      currentPage: page,
      totalResults: totalResults,
    );
  }

  @override
  Future<SearchStatistics> getStatistics() async {
    final stats = await database.getStatistics();

    return SearchStatistics(
      totalPersons: stats['total'] as int? ?? 0,
      malesCount: stats['males'] as int? ?? 0,
      femalesCount: stats['females'] as int? ?? 0,
      relationsCount: stats['relations'] as int? ?? 0,
      governorates:
          (stats['governorates'] as List?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }

  @override
  Future<void> dispose() async {
    // Database will be closed when app terminates
  }
}
