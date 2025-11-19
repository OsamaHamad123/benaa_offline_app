import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/civil_registry_database.dart';
import '../../data/repositories/civil_search_repository_impl.dart';
import '../../data/repositories/recent_searches_repository_impl.dart';
import '../../domain/repositories/civil_search_repository.dart';
import '../../domain/repositories/recent_searches_repository.dart';
import '../../domain/usecases/get_statistics.dart';
import '../../domain/usecases/search_by_name.dart';
import '../../domain/usecases/search_by_national_id.dart';
import '../../domain/usecases/recent_searches_usecases.dart';

/// 🏗️ Dependency Injection Providers - Direct SQLite Access 🚀
///
/// Following Clean Architecture principles:
/// CivilRegistryDatabase (SQLite) → Repository → Use Cases → State
/// ⚡ Performance: Direct access to downloaded civil_registry.db
/// ⚡ sqflite already uses native threads - no need for isolates

// ============================================================================
// EXTERNAL DEPENDENCIES
// ============================================================================

/// Provides SharedPreferences instance (for recent searches)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// ============================================================================
// DATA ACCESS LAYER (Database)
// ============================================================================

/// Provides CivilRegistryDatabase instance
/// Direct SQLite access to downloaded civil_registry.db file
final civilRegistryDatabaseProvider = Provider<CivilRegistryDatabase>((ref) {
  return CivilRegistryDatabase.instance;
});

// ============================================================================
// REPOSITORY LAYER
// ============================================================================

/// Provides CivilSearchRepository implementation
/// 🔥 Fast searches with direct SQLite access
final civilSearchRepositoryProvider = Provider<CivilSearchRepository>((ref) {
  final database = ref.watch(civilRegistryDatabaseProvider);
  return CivilSearchRepositoryImpl(database);
});

// Use Cases Layer
final searchByNationalIdUseCaseProvider = Provider<SearchByNationalIdUseCase>((
  ref,
) {
  final repository = ref.watch(civilSearchRepositoryProvider);
  return SearchByNationalIdUseCase(repository);
});

final searchByNameUseCaseProvider = Provider<SearchByNameUseCase>((ref) {
  final repository = ref.watch(civilSearchRepositoryProvider);
  return SearchByNameUseCase(repository);
});

final getStatisticsUseCaseProvider = Provider<GetStatisticsUseCase>((ref) {
  final repository = ref.watch(civilSearchRepositoryProvider);
  return GetStatisticsUseCase(repository);
});

// ============================================================================
// RECENT SEARCHES (Clean Architecture)
// ============================================================================

/// Repository for recent searches (using SharedPreferences)
final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecentSearchesRepositoryImpl(prefs);
});

/// Use cases for recent searches
final getRecentSearchesUseCaseProvider = Provider<GetRecentSearches>((ref) {
  final repository = ref.watch(recentSearchesRepositoryProvider);
  return GetRecentSearches(repository);
});

final saveRecentSearchUseCaseProvider = Provider<SaveRecentSearch>((ref) {
  final repository = ref.watch(recentSearchesRepositoryProvider);
  return SaveRecentSearch(repository);
});

final clearRecentSearchesUseCaseProvider = Provider<ClearRecentSearches>((ref) {
  final repository = ref.watch(recentSearchesRepositoryProvider);
  return ClearRecentSearches(repository);
});
