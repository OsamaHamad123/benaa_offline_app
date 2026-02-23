import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';
import '../../../../core/error_handling/result.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDataSource localDataSource;

  ActivityRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<Activity>>> getAllActivities() async {
    try {
      final activities = await localDataSource.getAllActivities();
      return Success(activities);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get all activities: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<Activity>>> getActivitiesByType(String type) async {
    try {
      final activities = await localDataSource.getActivitiesByType(type);
      return Success(activities);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get activities by type: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<Activity>>> getActivitiesForBeneficiary(
    String beneficiaryId,
  ) async {
    try {
      final activities =
          await localDataSource.getActivitiesForBeneficiary(beneficiaryId);
      return Success(activities);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure(
          'Failed to get activities for beneficiary: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> logActivity(Activity activity) async {
    try {
      await localDataSource.logActivity(activity);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to log activity: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteActivity(String activityId) async {
    try {
      await localDataSource.deleteActivity(activityId);
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to delete activity: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> clearAllActivities() async {
    try {
      await localDataSource.clearAllActivities();
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to clear activities: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> getActivitiesCount() async {
    try {
      final count = await localDataSource.getActivitiesCount();
      return Success(count);
    } catch (e, stackTrace) {
      return Failure(
          DatabaseFailure('Failed to get activities count: $e', stackTrace));
    }
  }
}
