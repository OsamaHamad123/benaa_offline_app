import 'package:drift/drift.dart' hide JsonKey;
import 'package:uuid/uuid.dart';
import '../../../../data/db/drift_database.dart';
import '../../domain/entities/activity.dart' as domain;

abstract class ActivityLocalDataSource {
  Future<List<domain.Activity>> getAllActivities();
  Future<List<domain.Activity>> getActivitiesByType(String type);
  Future<List<domain.Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  );
  Future<void> logActivity(domain.Activity activity);
  Future<void> deleteActivity(String activityId);
  Future<void> clearAllActivities();
  Future<int> getActivitiesCount();
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  final AppDatabase database;
  final _uuid = const Uuid();

  ActivityLocalDataSourceImpl(this.database);

  @override
  Future<List<domain.Activity>> getAllActivities() async {
    final activities = await database.trackingDao.getAllActivities();
    return activities.map(_mapToDomain).toList();
  }

  @override
  Future<List<domain.Activity>> getActivitiesByType(String type) async {
    final activities = await database.trackingDao.getActivitiesByType(type);
    return activities.map(_mapToDomain).toList();
  }

  @override
  Future<List<domain.Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async {
    final activities = await database.trackingDao.getBeneficiaryActivities(
      beneficiaryId,
    );
    return activities.map(_mapToDomain).toList();
  }

  @override
  Future<void> logActivity(domain.Activity activity) async {
    final companion = ActivitiesCompanion(
      id: Value(activity.id.isEmpty ? _uuid.v4() : activity.id),
      beneficiaryId: Value(activity.beneficiaryId ?? ''),
      userId: const Value('current_user'), // TODO: Get from auth service
      activityType: Value(activity.type),
      description: Value(activity.description),
      changes: Value(activity.metadata?.toString()),
      createdAt: Value(activity.timestamp),
      syncState: const Value('pending'),
    );

    await database.trackingDao.addActivity(companion);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    await database.trackingDao.deleteActivityById(activityId);
  }

  @override
  Future<void> clearAllActivities() async {
    await database.trackingDao.clearAllActivities();
  }

  @override
  Future<int> getActivitiesCount() async {
    return await database.trackingDao.getActivitiesCount();
  }

  /// Map database Activity to domain Activity
  domain.Activity _mapToDomain(Activity dbActivity) {
    return domain.Activity(
      id: dbActivity.id,
      type: dbActivity.activityType,
      description: dbActivity.description,
      timestamp: dbActivity.createdAt,
      beneficiaryId: dbActivity.beneficiaryId.isEmpty
          ? null
          : dbActivity.beneficiaryId,
      beneficiaryName: null, // Will be fetched if needed
      metadata: null, // Parse from changes if needed
    );
  }
}
