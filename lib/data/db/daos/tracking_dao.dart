import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/activities_table.dart';
import '../tables/data_requests_table.dart';

part 'tracking_dao.g.dart';

/// Tracking Data Access Object
/// يحتوي على عمليات Activities و DataRequests
@DriftAccessor(tables: [Activities, DataRequests])
class TrackingDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingDaoMixin {
  TrackingDao(super.db);

  // ============================================================================
  // ACTIVITIES OPERATIONS
  // ============================================================================

  /// Add activity log
  Future<void> addActivity(ActivitiesCompanion activity) async {
    await into(activities).insert(activity);
  }

  /// Get activities for a beneficiary
  Future<List<Activity>> getBeneficiaryActivities(
    String beneficiaryId, {
    int limit = 50,
  }) async {
    return await (select(activities)
          ..where((a) => a.beneficiaryId.equals(beneficiaryId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
          ..limit(limit))
        .get();
  }

  // ============================================================================
  // DATA REQUESTS OPERATIONS
  // ============================================================================

  /// Add data request
  Future<void> addDataRequest(DataRequestsCompanion request) async {
    await into(dataRequests).insert(request);
  }

  /// Get data requests for a beneficiary
  Future<List<DataRequest>> getBeneficiaryRequests(String beneficiaryId) async {
    return await (select(dataRequests)
          ..where((r) => r.beneficiaryId.equals(beneficiaryId))
          ..orderBy([(r) => OrderingTerm.desc(r.requestDate)]))
        .get();
  }

  /// Get pending data requests
  Future<List<DataRequest>> getPendingRequests({int limit = 50}) async {
    return await (select(dataRequests)
          ..where((r) => r.status.equals('pending'))
          ..orderBy([(r) => OrderingTerm.asc(r.requestDate)])
          ..limit(limit))
        .get();
  }

  /// Update request status
  Future<void> updateRequestStatus(
    String id,
    String status, {
    String? respondedBy,
  }) async {
    await (update(dataRequests)..where((r) => r.id.equals(id))).write(
      DataRequestsCompanion(
        status: Value(status),
        responseDate: Value(DateTime.now()),
        respondedBy: Value(respondedBy),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
