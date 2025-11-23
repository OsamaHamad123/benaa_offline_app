/// Reports Repository Interface
/// Clean Architecture - Domain Layer
/// This defines the contract that data layer must implement
library;

import '../entities/report_data.dart';
import '../entities/summary_statistics.dart';
import '../../../beneficiaries/domain/entities/beneficiary.dart';

abstract class ReportsRepository {
  /// Get summary statistics for dashboard
  /// Supports optional date range filtering
  Future<SummaryStatistics> getSummaryStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get gender distribution report
  /// Supports optional date range filtering
  Future<List<GenderCount>> getGenderReport({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get governorate distribution report
  /// Supports optional date range filtering
  Future<List<GovernorateCount>> getGovernorateReport({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get category distribution report
  /// Supports optional date range filtering
  Future<List<CategoryCount>> getCategoryReport({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get age bracket distribution report
  /// Supports optional date range filtering
  Future<List<AgeCount>> getAgeReport({DateTime? startDate, DateTime? endDate});

  /// Get sync status distribution report
  /// Supports optional date range filtering
  Future<List<SyncStatusCount>> getSyncStatusReport({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get all beneficiaries for comprehensive export
  /// Returns complete list of all beneficiaries with full details
  Future<List<Beneficiary>> getAllBeneficiaries();
}
