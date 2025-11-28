import '../entities/visit_entity.dart';
import '../../../../core/error_handling/result.dart';

/// Visit Repository Interface
abstract class VisitRepository {
  /// Create a new visit
  Future<Result<void>> createVisit(VisitEntity visit);

  /// Get all visits for a beneficiary
  Future<Result<List<VisitEntity>>> getBeneficiaryVisits(String beneficiaryId);

  /// Get visit by ID
  Future<Result<VisitEntity>> getVisitById(String id);

  /// Update visit
  Future<Result<void>> updateVisit(VisitEntity visit);

  /// Delete visit
  Future<Result<void>> deleteVisit(String id);

  /// Count visits for a beneficiary
  Future<Result<int>> countBeneficiaryVisits(String beneficiaryId);

  /// Get last visit date for a beneficiary
  Future<Result<DateTime>> getLastVisitDate(String beneficiaryId);

  /// Get recent visits (for activity feed)
  Future<Result<List<VisitEntity>>> getRecentVisits({int limit = 20});

  /// Count visits today
  Future<Result<int>> countVisitsToday();

  /// Get average visits per day
  Future<Result<double>> getAverageVisitsPerDay(int days);
}
