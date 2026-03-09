import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/visits_table.dart';

part 'visits_dao.g.dart';

/// Visits Data Access Object
/// يحتوي على جميع عمليات CRUD والاستعلامات الخاصة بالزيارات
@DriftAccessor(tables: [Visits])
class VisitsDao extends DatabaseAccessor<AppDatabase> with _$VisitsDaoMixin {
  VisitsDao(super.db);

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Insert visit
  Future<void> insertVisit(VisitsCompanion visit) async {
    await into(visits).insert(visit);
  }

  /// Get all visits for a beneficiary
  Future<List<Visit>> getBeneficiaryVisits(String beneficiaryId) async {
    return await (select(visits)
          ..where((v) => v.beneficiaryId.equals(beneficiaryId))
          ..orderBy([(v) => OrderingTerm.desc(v.visitDate)]))
        .get();
  }

  /// Get visit by ID
  Future<Visit?> getVisitById(String id) async {
    return await (select(
      visits,
    )..where((v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  /// Update visit
  Future<void> updateVisit(Visit visit) async {
    await update(visits).replace(visit);
  }

  /// Delete visit
  Future<void> deleteVisit(String id) async {
    await (delete(visits)..where((v) => v.id.equals(id))).go();
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Count visits for a beneficiary
  Future<int> countBeneficiaryVisits(String beneficiaryId) async {
    final result = await customSelect(
      'SELECT COUNT(*) as count FROM visits WHERE beneficiary_id = ?',
      variables: [Variable.withString(beneficiaryId)],
      readsFrom: {visits},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get last visit date for a beneficiary
  Future<DateTime?> getLastVisitDate(String beneficiaryId) async {
    final result = await customSelect(
      'SELECT MAX(visit_date) as last_date FROM visits WHERE beneficiary_id = ?',
      variables: [Variable.withString(beneficiaryId)],
      readsFrom: {visits},
    ).getSingleOrNull();

    if (result == null) return null;
    final timestamp = result.readNullable<int>('last_date');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// Get recent visits (all beneficiaries)
  Future<List<Visit>> getRecentVisits({int limit = 20}) async {
    return await (select(visits)
          ..orderBy([(v) => OrderingTerm.desc(v.visitDate)])
          ..limit(limit))
        .get();
  }

  /// Count visits today
  Future<int> countVisitsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      'SELECT COUNT(*) as count FROM visits WHERE visit_date >= ? AND visit_date < ?',
      variables: [
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
      readsFrom: {visits},
    ).getSingle();
    return result.read<int>('count');
  }

  /// Get average visits per day for the last X days
  Future<double> getAverageVisitsPerDay(int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    final result = await customSelect(
      '''SELECT COUNT(*) * 1.0 / ? as avg_visits 
         FROM visits 
         WHERE visit_date >= ?''',
      variables: [Variable.withInt(days), Variable.withDateTime(startDate)],
      readsFrom: {visits},
    ).getSingle();

    return result.read<double>('avg_visits');
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Get visits that need sync
  Future<List<Visit>> getPendingVisits() async {
    return await (select(visits)..where((v) => v.syncState.equals('pending') | v.syncState.equals('modified'))).get();
  }

  /// Update sync status after success
  Future<void> updateVisitSyncStatus(String id, String serverId) async {
    await (update(visits)..where((v) => v.id.equals(id))).write(
      VisitsCompanion(
        syncState: const Value('synced'),
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark all pending/modified visits as locally synced (no server upload mode)
  Future<int> markPendingVisitsAsLocalOnlySynced() async {
    return await (update(visits)..where((v) => v.syncState.equals('pending') | v.syncState.equals('modified'))).write(
      VisitsCompanion(
        syncState: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
