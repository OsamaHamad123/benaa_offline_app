import '../entities/search_entities.dart';
import '../repositories/civil_search_repository.dart';

/// 📊 Get Statistics Use Case
///
/// Retrieves statistics about the civil registry.
class GetStatisticsUseCase {
  final CivilSearchRepository repository;

  const GetStatisticsUseCase(this.repository);

  /// Execute - Get statistics
  Future<SearchStatistics> call() async {
    return await repository.getStatistics();
  }
}
