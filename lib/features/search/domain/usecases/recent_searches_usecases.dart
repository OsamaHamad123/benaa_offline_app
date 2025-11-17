import '../entities/recent_search.dart';
import '../repositories/recent_searches_repository.dart';

/// 🔍 Get Recent Searches Use Case - Domain Layer
///
/// Clean Architecture: Business logic in domain layer
class GetRecentSearches {
  final RecentSearchesRepository _repository;

  const GetRecentSearches(this._repository);

  Future<List<RecentSearch>> call() async {
    return await _repository.getRecentSearches();
  }
}

/// 🔍 Save Recent Search Use Case
class SaveRecentSearch {
  final RecentSearchesRepository _repository;

  const SaveRecentSearch(this._repository);

  Future<void> call(RecentSearch search) async {
    await _repository.saveSearch(search);
  }
}

/// 🔍 Clear Recent Searches Use Case
class ClearRecentSearches {
  final RecentSearchesRepository _repository;

  const ClearRecentSearches(this._repository);

  Future<void> call() async {
    await _repository.clearRecentSearches();
  }
}
