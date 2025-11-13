import '../entities/search_entities.dart';
import '../repositories/civil_search_repository.dart';

/// Use Case: Get civil registry statistics
///
/// Clean Architecture - Domain Layer
/// Encapsulates the business logic for retrieving statistics
class GetStatisticsUseCase {
  final CivilSearchRepository repository;

  const GetStatisticsUseCase(this.repository);

  /// Execute - Get all statistics
  Future<SearchStatistics> call() async {
    return await repository.getStatistics();
  }
}
