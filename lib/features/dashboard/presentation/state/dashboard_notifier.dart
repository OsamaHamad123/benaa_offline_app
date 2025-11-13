import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_dashboard_statistics.dart';
import '../../domain/usecases/get_today_stats.dart';
import '../../domain/usecases/get_recent_activities.dart';
import 'dashboard_state.dart';

/// Dashboard Notifier - Manages Dashboard State
class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDashboardStatistics getDashboardStatistics;
  final GetTodayStats getTodayStats;
  final GetRecentActivities getRecentActivities;

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 10;

  DashboardNotifier({
    required this.getDashboardStatistics,
    required this.getTodayStats,
    required this.getRecentActivities,
  }) : super(const DashboardState.initial());

  // ============================================================================
  // INITIALIZATION - Auto-load on creation
  // ============================================================================

  Future<void> initialize() async {
    await loadStatistics();
  }

  // ============================================================================
  // STATISTICS LOADING - With Error Handling
  // ============================================================================

  Future<void> loadStatistics({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoadingStats: true, errorMessage: null);

      // Load full statistics
      final stats = await getDashboardStatistics(forceRefresh: forceRefresh);

      state = state.copyWith(
        statistics: stats,
        todayStats: stats.todayStats,
        isLoadingStats: false,
        lastRefreshTime: DateTime.now(),
      );

      // Load activities after stats
      await _loadInitialActivities();
    } catch (e) {
      state = state.copyWith(
        isLoadingStats: false,
        errorMessage: 'فشل تحميل البيانات: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // ACTIVITIES - Paginated Loading
  // ============================================================================

  Future<void> _loadInitialActivities() async {
    try {
      _currentPage = 0;
      state = state.copyWith(isLoadingActivities: true, activities: []);

      final activities = await getRecentActivities(limit: _pageSize, offset: 0);

      state = state.copyWith(
        activities: activities,
        isLoadingActivities: false,
        hasMoreActivities: activities.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingActivities: false,
        errorMessage: 'فشل تحميل الأنشطة',
      );
    }
  }

  // ============================================================================
  // TODAY STATS - Lightweight refresh
  // ============================================================================

  Future<void> refreshTodayStats() async {
    try {
      final todayStats = await getTodayStats();
      state = state.copyWith(todayStats: todayStats);
    } catch (e) {
      // Silent fail for today stats refresh
    }
  }

  Future<void> loadMoreActivities() async {
    if (state.isLoadingActivities || !state.hasMoreActivities) return;

    try {
      state = state.copyWith(isLoadingActivities: true);

      _currentPage++;
      final newActivities = await getRecentActivities(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      state = state.copyWith(
        activities: [...state.activities, ...newActivities],
        isLoadingActivities: false,
        hasMoreActivities: newActivities.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingActivities: false,
        errorMessage: 'فشل تحميل المزيد من الأنشطة',
      );
    }
  }

  // ============================================================================
  // REFRESH - Pull-to-refresh
  // ============================================================================

  Future<void> refresh() async {
    await loadStatistics(forceRefresh: true);
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
