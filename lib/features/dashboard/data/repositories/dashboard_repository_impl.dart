import '../../domain/entities/dashboard_statistics.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../../../../core/error_handling/result.dart';

/// Dashboard Repository Implementation
/// Implements the domain repository interface
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl(this.localDataSource);

  @override
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false}) async {
    try {
      final stats = await localDataSource.getStatistics(forceRefresh: forceRefresh);
      return Success(stats);
    } catch (e, stackTrace) {
      // 🛡️ Error Handling Strategy for Dashboard
      // invalid column errors (like SQLSTATE[42S22]) suggests schema mismatch
      if (e.toString().contains('SQLSTATE') || e.toString().contains('no such column')) {
        return Failure(DatabaseFailure('خطأ في هيكلية البيانات (يرجى التواصل مع الدعم الفني)', stackTrace));
      }
      return Failure(DatabaseFailure('فشل تحميل إحصائيات الداشبورد: $e', stackTrace));
    }
  }

  @override
  Future<Result<TodayStats>> getTodayStats() async {
    try {
      final stats = await localDataSource.getTodayStatsData();
      return Success(stats);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to get today stats: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<Activity>>> getRecentActivities({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final activities = await localDataSource.getRecentActivities(
        limit: limit,
        offset: offset,
      );
      return Success(activities);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to get recent activities: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> getNotificationsCount() async {
    try {
      final stats = await localDataSource.getTodayStatsData();
      return Success(stats.pendingTasks);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to get notifications count: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Success(null);
    } catch (e, stackTrace) {
      return Failure(CacheFailure('Failed to clear cache: $e', stackTrace));
    }
  }

  @override
  Stream<DashboardStatistics>? watchStatistics() {
    // TODO: Implement real-time updates with StreamController
    return null;
  }
}
