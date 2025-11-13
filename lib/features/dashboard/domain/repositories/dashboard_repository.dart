import '../entities/dashboard_statistics.dart';
import '../entities/activity.dart';

/// Dashboard Repository Interface - Contract for data operations
abstract class DashboardRepository {
  /// Get complete dashboard statistics
  Future<DashboardStatistics> getStatistics({bool forceRefresh = false});

  /// Get today's stats only (lighter operation)
  Future<TodayStats> getTodayStats();

  /// Get recent activities with pagination
  Future<List<Activity>> getRecentActivities({int limit = 10, int offset = 0});

  /// Get notifications count
  Future<int> getNotificationsCount();

  /// Clear cached data
  Future<void> clearCache();

  /// Stream for real-time updates (optional)
  Stream<DashboardStatistics>? watchStatistics();
}
