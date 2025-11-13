import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/civil_registry_database.dart';
import '../../data/repositories/civil_search_repository_impl.dart';
import '../../domain/repositories/civil_search_repository.dart';
import '../../domain/usecases/get_statistics.dart';
import '../../domain/usecases/search_by_name.dart';
import '../../domain/usecases/search_by_national_id.dart';

/// 🏗️ Dependency Injection Providers - Direct SQLite Access 🚀
///
/// Following Clean Architecture principles:
/// CivilRegistryDatabase (SQLite) → Repository → Use Cases → State
/// ⚡ Performance: Direct access to downloaded civil_registry.db

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
