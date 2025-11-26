import '../entities/activity.dart';

/// Activity Repository Interface
abstract class ActivityRepository {
  /// Get all activities
  Future<List<Activity>> getAllActivities();

  /// Get activities by type
  Future<List<Activity>> getActivitiesByType(String type);

  /// Get activities for a specific beneficiary
  Future<List<Activity>> getActivitiesForBeneficiary(String beneficiaryId);

  /// Log a new activity
  Future<void> logActivity(Activity activity);

  /// Delete an activity
  Future<void> deleteActivity(String activityId);

  /// Clear all activities
  Future<void> clearAllActivities();

  /// Get activities count
  Future<int> getActivitiesCount();
}
