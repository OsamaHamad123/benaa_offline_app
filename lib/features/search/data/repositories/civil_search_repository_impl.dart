import '../../domain/entities/civil_person.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/civil_search_repository.dart';
import '../datasources/civil_registry_local_datasource.dart';

/// 📦 Civil Search Repository Implementation
///
/// Implements the repository interface using local data source.
class CivilSearchRepositoryImpl implements CivilSearchRepository {
  final CivilRegistryLocalDataSource dataSource;

  const CivilSearchRepositoryImpl(this.dataSource);

  @override
  Future<void> initialize() async {
    await dataSource.initialize();
  }

  @override
  Future<CivilPerson?> searchByNationalId(String nationalId) async {
    return await dataSource.searchByNationalId(nationalId);
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
    final results = await dataSource.searchByName(
      query: query,
      genderCode: filter.gender?.code,
      city: filter.governorate,
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
      totalResults = await dataSource.getSearchCount(
        query: query,
        genderCode: filter.gender?.code,
        city: filter.governorate,
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
    final stats = await dataSource.getStatistics();

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
    await dataSource.dispose();
  }
}
