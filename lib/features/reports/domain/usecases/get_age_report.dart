/// Get Age Report Use Case
/// Clean Architecture - Domain Layer

import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetAgeReport {
  final ReportsRepository repository;

  const GetAgeReport(this.repository);

  Future<List<AgeCount>> call() async {
    return await repository.getAgeReport();
  }
}
