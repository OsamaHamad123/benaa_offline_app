import '../../domain/entities/dashboard_statistics.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

/// Dashboard Repository Implementation
/// Implements the domain repository interface
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl(this.localDataSource);

  @override
  Future<DashboardStatistics> getStatistics({bool forceRefresh = false}) async {
    return await localDataSource.getStatistics(forceRefresh: forceRefresh);
  }

  @override
  Future<TodayStats> getTodayStats() async {
    return await localDataSource.getTodayStatsData();
  }

  @override
  Future<List<Activity>> getRecentActivities({
    int limit = 10,
    int offset = 0,
  }) async {
    return await localDataSource.getRecentActivities(
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> getNotificationsCount() async {
    final stats = await localDataSource.getTodayStatsData();
    return stats.pendingTasks;
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }

  @override
  Stream<DashboardStatistics>? watchStatistics() {
    // TODO: Implement real-time updates with StreamController
    return null;
  }
}
