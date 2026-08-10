import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/activities_table.dart';
// 🗑️ import '../tables/data_requests_table.dart'; - Removed (unused table)

part 'tracking_dao.g.dart';

/// Tracking Data Access Object
/// يحتوي على عمليات Activities فقط (تم حذف DataRequests)
@DriftAccessor(tables: [Activities])
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

  /// Get all activities
  Future<List<Activity>> getAllActivities({int? limit}) async {
    final query = select(activities)
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    return await query.get();
  }

  /// Get recent activities (last 10 by default)
  Future<List<Activity>> getRecentActivities({int limit = 10}) async {
    return await (select(activities)
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Get activities by type
  Future<List<Activity>> getActivitiesByType(String type, {int? limit}) async {
    final query = select(activities)
      ..where((a) => a.activityType.equals(type))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    return await query.get();
  }

  /// Delete activity by ID
  Future<void> deleteActivityById(String activityId) async {
    await (delete(activities)..where((a) => a.id.equals(activityId))).go();
  }

  /// Clear all activities
  Future<void> clearAllActivities() async {
    await delete(activities).go();
  }

  /// Get activities count
  Future<int> getActivitiesCount() async {
    final count = await (selectOnly(
      activities,
    )..addColumns([activities.id.count()]))
        .getSingle();
    return count.read(activities.id.count()) ?? 0;
  }

  /// Get activities count by type
  Future<int> getActivitiesCountByType(String type) async {
    final count = await (selectOnly(activities)
          ..where(activities.activityType.equals(type))
          ..addColumns([activities.id.count()]))
        .getSingle();
    return count.read(activities.id.count()) ?? 0;
  }

  // 🗑️ DATA REQUESTS OPERATIONS REMOVED
  // DataRequests table was unused and has been removed from the database
}
