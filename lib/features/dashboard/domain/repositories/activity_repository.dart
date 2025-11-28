import '../entities/activity.dart';
import '../../../../core/error_handling/result.dart';

/// Activity Repository Interface
abstract class ActivityRepository {
  /// Get all activities
  Future<Result<List<Activity>>> getAllActivities();

  /// Get activities by type
  Future<Result<List<Activity>>> getActivitiesByType(String type);

  /// Get activities for a specific beneficiary
  Future<Result<List<Activity>>> getActivitiesForBeneficiary(String beneficiaryId);

  /// Log a new activity
  Future<Result<void>> logActivity(Activity activity);

  /// Delete an activity
  Future<Result<void>> deleteActivity(String activityId);

  /// Clear all activities
  Future<Result<void>> clearAllActivities();

  /// Get activities count
  Future<Result<int>> getActivitiesCount();
}
