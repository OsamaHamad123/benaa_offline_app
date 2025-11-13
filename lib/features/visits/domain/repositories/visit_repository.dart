import '../entities/visit_entity.dart';

/// Visit Repository Interface
abstract class VisitRepository {
  /// Create a new visit
  Future<void> createVisit(VisitEntity visit);

  /// Get all visits for a beneficiary
  Future<List<VisitEntity>> getBeneficiaryVisits(String beneficiaryId);

  /// Get visit by ID
  Future<VisitEntity?> getVisitById(String id);

  /// Update visit
  Future<void> updateVisit(VisitEntity visit);

  /// Delete visit
  Future<void> deleteVisit(String id);

  /// Count visits for a beneficiary
  Future<int> countBeneficiaryVisits(String beneficiaryId);

  /// Get last visit date for a beneficiary
  Future<DateTime?> getLastVisitDate(String beneficiaryId);

  /// Get recent visits (for activity feed)
  Future<List<VisitEntity>> getRecentVisits({int limit = 20});

  /// Count visits today
  Future<int> countVisitsToday();

  /// Get average visits per day
  Future<double> getAverageVisitsPerDay(int days);
}
