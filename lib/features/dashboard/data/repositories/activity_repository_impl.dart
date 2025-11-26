import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource localDataSource;

  ActivityRepositoryImpl(this.localDataSource);

  @override
  Future<List<Activity>> getAllActivities() async {
    try {
      return await localDataSource.getAllActivities();
    } catch (e) {
      throw Exception('Failed to get all activities: $e');
    }
  }

  @override
  Future<List<Activity>> getActivitiesByType(String type) async {
    try {
      return await localDataSource.getActivitiesByType(type);
    } catch (e) {
      throw Exception('Failed to get activities by type: $e');
    }
  }

  @override
  Future<List<Activity>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async {
    try {
      return await localDataSource.getActivitiesForBeneficiary(beneficiaryId);
    } catch (e) {
      throw Exception('Failed to get activities for beneficiary: $e');
    }
  }

  @override
  Future<void> logActivity(Activity activity) async {
    try {
      await localDataSource.logActivity(activity);
    } catch (e) {
      throw Exception('Failed to log activity: $e');
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    try {
      await localDataSource.deleteActivity(activityId);
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  @override
  Future<void> clearAllActivities() async {
    try {
      await localDataSource.clearAllActivities();
    } catch (e) {
      throw Exception('Failed to clear activities: $e');
    }
  }

  @override
  Future<int> getActivitiesCount() async {
    try {
      return await localDataSource.getActivitiesCount();
    } catch (e) {
      throw Exception('Failed to get activities count: $e');
    }
  }
}
