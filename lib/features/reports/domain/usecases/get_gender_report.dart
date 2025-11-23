/// Get Gender Report Use Case
/// Clean Architecture - Domain Layer
library;

import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetGenderReport {
  final ReportsRepository repository;

  const GetGenderReport(this.repository);

  Future<List<GenderCount>> call() async {
    return await repository.getGenderReport();
  }
}
