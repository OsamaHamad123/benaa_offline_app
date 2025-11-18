/// Get Summary Statistics Use Case
/// Clean Architecture - Domain Layer

import '../entities/summary_statistics.dart';
import '../repositories/reports_repository.dart';

class GetSummaryStatistics {
  final ReportsRepository repository;

  const GetSummaryStatistics(this.repository);

  Future<SummaryStatistics> call() async {
    return await repository.getSummaryStatistics();
  }
}
