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
import '../domain/entities/activity.dart'; // ✅ Import Activity
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
  final prefs = ref.watch(core_providers.sharedPreferencesProvider).requireValue;

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

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
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

// ============================================================================
// MEMOIZATION PROVIDERS - Cached computed data (Performance Optimization)
// ============================================================================

/// Chart data provider - يحسب فقط عند تغيير totalBeneficiaries
final trendChartDataProvider = Provider<List<double>>((ref) {
  final state = ref.watch(dashboardProvider);
  final totalBeneficiaries = state.statistics?.totalBeneficiaries ?? 0;

  if (totalBeneficiaries == 0) return [0, 0, 0, 0, 0, 0];

  // ✅ Memoization: يحسب مرة واحدة ويخزن النتيجة
  return [
    totalBeneficiaries * 0.5,
    totalBeneficiaries * 0.65,
    totalBeneficiaries * 0.75,
    totalBeneficiaries * 0.85,
    totalBeneficiaries * 0.92,
    totalBeneficiaries.toDouble(),
  ];
});

// ============================================================================
// COMPUTED DATA PROVIDERS - Move expensive calculations from build()
// ============================================================================

/// Filtered activities provider - تصفية وترتيب الأنشطة
final filteredActivitiesProvider = Provider.family<List<Activity>, Map<String, dynamic>>((ref, filters) {
  final state = ref.watch(dashboardProvider);
  var activities = state.activities;

  final filterType = filters['type'] as String? ?? 'all';
  final selectedDate = filters['date'] as DateTime?;

  // ✅ نقل التصفية من build إلى Provider
  if (filterType != 'all') {
    activities = activities.where((activity) => activity.type == filterType).toList();
  }

  if (selectedDate != null) {
    activities = activities.where((activity) {
      final activityDate = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );
      final selectedDateOnly = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return activityDate == selectedDateOnly;
    }).toList();
  }

  // ✅ نقل الترتيب من build إلى Provider
  return activities..sort((a, b) => b.timestamp.compareTo(a.timestamp));
});

/// Top governorates provider - ترتيب المحافظات حسب العدد
final topGovernoratesProvider = Provider.family<List<MapEntry<String, int>>, Map<String, int>>((ref, data) {
  if (data.isEmpty) return [];

  // ✅ نقل الترتيب من build إلى Provider
  final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return entries.take(5).toList();
});
