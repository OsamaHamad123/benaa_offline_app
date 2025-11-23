/// Get Sync Status Report Use Case
/// Clean Architecture - Domain Layer
library;

import '../entities/report_data.dart';
import '../repositories/reports_repository.dart';

class GetSyncStatusReport {
  final ReportsRepository repository;

  const GetSyncStatusReport(this.repository);

  Future<List<SyncStatusCount>> call() async {
    return await repository.getSyncStatusReport();
  }
}
