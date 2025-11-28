import '../entities/dashboard_statistics.dart';
import '../entities/activity.dart';
import '../../../../core/error_handling/result.dart';

/// Dashboard Repository Interface - Contract for data operations
abstract class DashboardRepository {
  /// Get complete dashboard statistics
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false});

  /// Get today's stats only (lighter operation)
  Future<Result<TodayStats>> getTodayStats();

  /// Get recent activities with pagination
  Future<Result<List<Activity>>> getRecentActivities({int limit = 10, int offset = 0});

  /// Get notifications count
  Future<Result<int>> getNotificationsCount();

  /// Clear cached data
  Future<Result<void>> clearCache();

  /// Stream for real-time updates (optional)
  Stream<DashboardStatistics>? watchStatistics();
}
