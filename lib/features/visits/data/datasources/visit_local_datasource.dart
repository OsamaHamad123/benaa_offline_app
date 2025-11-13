import '../../../../data/db/drift_database.dart';
import '../models/visit_model.dart';

/// Visit Local DataSource - handles all database operations for visits
class VisitLocalDataSource {
  final AppDatabase _database;

  const VisitLocalDataSource(this._database);

  /// Insert a new visit
  Future<void> insertVisit(VisitsCompanion visit) async {
    await _database.visitsDao.insertVisit(visit);
  }

  /// Get all visits for a beneficiary
  Future<List<VisitModel>> getBeneficiaryVisits(String beneficiaryId) async {
    final visits = await _database.visitsDao.getBeneficiaryVisits(
      beneficiaryId,
    );
    return visits.map((v) => VisitModel.fromDrift(v)).toList();
  }

  /// Get visit by ID
  Future<VisitModel?> getVisitById(String id) async {
    final visit = await _database.visitsDao.getVisitById(id);
    return visit != null ? VisitModel.fromDrift(visit) : null;
  }

  /// Update visit
  Future<void> updateVisit(Visit visit) async {
    await _database.visitsDao.updateVisit(visit);
  }

  /// Delete visit
  Future<void> deleteVisit(String id) async {
    await _database.visitsDao.deleteVisit(id);
  }

  /// Count visits for a beneficiary
  Future<int> countBeneficiaryVisits(String beneficiaryId) async {
    return await _database.visitsDao.countBeneficiaryVisits(beneficiaryId);
  }

  /// Get last visit date for a beneficiary
  Future<DateTime?> getLastVisitDate(String beneficiaryId) async {
    return await _database.visitsDao.getLastVisitDate(beneficiaryId);
  }

  /// Get recent visits
  Future<List<VisitModel>> getRecentVisits({int limit = 20}) async {
    final visits = await _database.visitsDao.getRecentVisits(limit: limit);
    return visits.map((v) => VisitModel.fromDrift(v)).toList();
  }

  /// Count visits today
  Future<int> countVisitsToday() async {
    return await _database.visitsDao.countVisitsToday();
  }

  /// Get average visits per day
  Future<double> getAverageVisitsPerDay(int days) async {
    return await _database.visitsDao.getAverageVisitsPerDay(days);
  }
}
