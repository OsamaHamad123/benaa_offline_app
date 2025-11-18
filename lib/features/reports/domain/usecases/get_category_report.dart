/// Get Category Report Use Case
/// Clean Architecture - Domain Layer

import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetCategoryReport {
  final ReportsRepository repository;

  const GetCategoryReport(this.repository);

  Future<List<CategoryCount>> call() async {
    return await repository.getCategoryReport();
  }
}
