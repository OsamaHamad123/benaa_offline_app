/// Get Governorate Report Use Case
/// Clean Architecture - Domain Layer

import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetGovernorateReport {
  final ReportsRepository repository;

  const GetGovernorateReport(this.repository);

  Future<List<GovernorateCount>> call() async {
    return await repository.getGovernorateReport();
  }
}
