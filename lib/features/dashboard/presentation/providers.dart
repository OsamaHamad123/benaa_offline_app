import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart' as core_providers;
import '../../../core/error_handling/result.dart';
import '../data/datasources/dashboard_local_datasource.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/usecases/get_dashboard_statistics.dart';
import '../domain/usecases/get_today_stats.dart';
import '../domain/usecases/get_recent_activities.dart';
import 'state/dashboard_state.dart';
import 'state/dashboard_notifier.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Dashboard Local Data Source
final dashboardLocalDataSourceProvider = Provider<DashboardLocalDataSource>((
  ref,
) {
  final database = ref.watch(core_providers.databaseProvider);
  final prefsAsync = ref.watch(core_providers.sharedPreferencesProvider);
  final prefs = prefsAsync.value;

  if (prefs == null) {
    throw Exception('SharedPreferences not loaded yet');
  }

  return DashboardLocalDataSource(database: database, prefs: prefs);
});

/// Dashboard Repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(dashboardLocalDataSourceProvider);
  return DashboardRepositoryImpl(dataSource);
});

// ============================================================================
// USE CASES PROVIDERS
// ============================================================================

final getDashboardStatisticsProvider = Provider<GetDashboardStatistics>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetDashboardStatistics(repository);
});

final getTodayStatsProvider = Provider<GetTodayStats>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetTodayStats(repository);
});

final getRecentActivitiesProvider = Provider<GetRecentActivities>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetRecentActivities(repository);
});

// ============================================================================
// DASHBOARD STATE PROVIDER - Main Dashboard Notifier
// ============================================================================

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final getStatistics = ref.watch(getDashboardStatisticsProvider);
  final getTodayStats = ref.watch(getTodayStatsProvider);
  final getActivities = ref.watch(getRecentActivitiesProvider);

  final notifier = DashboardNotifier(
    getDashboardStatistics: getStatistics,
    getTodayStats: getTodayStats,
    getRecentActivities: getActivities,
  );

  // Auto-initialize when created
  notifier.initialize();

  return notifier;
});

// ============================================================================
// CONVENIENCE PROVIDERS - For specific parts of state
// ============================================================================

/// Today's statistics only (auto-refresh every 2 minutes)
final todayStatsAutoRefreshProvider = FutureProvider.autoDispose<TodayStats>((
  ref,
) async {
  final getTodayStats = ref.watch(getTodayStatsProvider);

  // Keep alive for 2 minutes
  final link = ref.keepAlive();
  Future.delayed(const Duration(minutes: 2), link.close);

  final result = await getTodayStats();

  if (result is Failure<TodayStats>) {
    throw Exception(result.error.message);
  }

  return (result as Success<TodayStats>).value;
});

/// Notifications count from today's pending tasks
final notificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(dashboardProvider);
  return state.todayStats?.pendingTasks ?? 0;
});
