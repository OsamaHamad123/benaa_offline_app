import '../entities/recent_search.dart';

/// 🔍 Recent Searches Repository - Domain Layer Interface
///
/// Clean Architecture: Domain layer defines the contract
/// Data layer implements the actual storage logic
abstract class RecentSearchesRepository {
  /// Get recent searches (max 5)
  Future<List<RecentSearch>> getRecentSearches();

  /// Save a new search
  Future<void> saveSearch(RecentSearch search);

  /// Clear all recent searches
  Future<void> clearRecentSearches();

  /// Remove a specific search
  Future<void> removeSearch(String query);
}
