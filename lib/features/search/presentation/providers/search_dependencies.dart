import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/civil_registry_local_datasource.dart';
import '../../data/repositories/civil_search_repository_impl.dart';
import '../../domain/repositories/civil_search_repository.dart';
import '../../domain/usecases/get_statistics.dart';
import '../../domain/usecases/search_by_name.dart';
import '../../domain/usecases/search_by_national_id.dart';

/// 🏗️ Dependency Injection Providers
///
/// Following Clean Architecture principles:
/// Data Source → Repository → Use Cases → State

// Data Layer
final civilRegistryDataSourceProvider = Provider<CivilRegistryLocalDataSource>((
  ref,
) {
  final dataSource = CivilRegistryLocalDataSource();
  // Initialize on first access
  dataSource.initialize();

  // Clean up when no longer needed
  ref.onDispose(() {
    dataSource.dispose();
  });

  return dataSource;
});

// Repository Layer
final civilSearchRepositoryProvider = Provider<CivilSearchRepository>((ref) {
  final dataSource = ref.watch(civilRegistryDataSourceProvider);
  return CivilSearchRepositoryImpl(dataSource);
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
