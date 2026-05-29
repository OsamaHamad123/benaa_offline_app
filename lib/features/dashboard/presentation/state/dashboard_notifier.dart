import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_dashboard_statistics.dart';
import '../../domain/usecases/get_today_stats.dart';
import '../../domain/usecases/get_recent_activities.dart';
import '../../domain/entities/activity.dart';
import 'dashboard_state.dart';
import '../../../../core/error_handling/result.dart';
import '../../../../core/utils/log_sanitizer.dart';

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
  }) : super(const DashboardState.initial()) {
    // ✅ تفعيل إخفاء البيانات الحساسة في debug mode للاختبار
    LogSanitizer.enableDebugMasking();
  }

  // ============================================================================
  // INITIALIZATION - Auto-load on creation
  // ============================================================================

  Future<void> initialize() async {
    await loadStatistics();
  }

  // ============================================================================
  // STATISTICS LOADING - With Error Handling and Lazy Loading
  // ============================================================================

  Future<void> loadStatistics({bool forceRefresh = false}) async {
    final sw = Stopwatch()..start();
    debugPrint('[Dashboard] loadMetrics started forceRefresh=$forceRefresh');
    try {
      state = state.copyWith(isLoadingStats: true);

      // ✅ Lazy Loading: تحميل البيانات الأساسية أولاً
      final result = await getDashboardStatistics(forceRefresh: forceRefresh);

      if (result is Failure<DashboardStatistics>) {
        throw Exception(result.error.message);
      }

      final stats = (result as Success<DashboardStatistics>).value;

      // تحقق أن الـ notifier لم يُتلف قبل تحديث الحالة
      if (!mounted) return;

      state = state.copyWith(
        statistics: stats,
        todayStats: stats.todayStats,
        isLoadingStats: false,
        lastRefreshTime: DateTime.now(),
      );

      sw.stop();
      debugPrint('[Dashboard] loadMetrics completed ms=${sw.elapsedMilliseconds}');

      // ✅ تحميل البيانات الثانوية بشكل تدريجي بعد الإطار الأول
      // استخدام addPostFrameCallback بدلاً من Future.microtask لتجنب race conditions
      if (mounted) {
        await _loadInitialActivities();
      }
    } catch (e) {
      sw.stop();
      debugPrint('[Dashboard] loadMetrics failed ms=${sw.elapsedMilliseconds} error=${e.runtimeType}');
      if (!mounted) return;
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

      final result = await getRecentActivities();

      if (result is Failure<List<Activity>>) {
        throw Exception(result.error.message);
      }

      final activities = (result as Success<List<Activity>>).value;

      if (!mounted) return;
      state = state.copyWith(
        activities: activities,
        isLoadingActivities: false,
        hasMoreActivities: activities.length == _pageSize,
      );
    } catch (e) {
      if (!mounted) return;
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
      final result = await getTodayStats();

      if (result is Failure<TodayStats>) {
        throw Exception(result.error.message);
      }

      final todayStats = (result as Success<TodayStats>).value;
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
      final result = await getRecentActivities(
        offset: _currentPage * _pageSize,
      );

      if (result is Failure<List<Activity>>) {
        throw Exception(result.error.message);
      }

      final newActivities = (result as Success<List<Activity>>).value;

      if (!mounted) return;
      state = state.copyWith(
        activities: [...state.activities, ...newActivities],
        isLoadingActivities: false,
        hasMoreActivities: newActivities.length == _pageSize,
      );
    } catch (e) {
      if (!mounted) return;
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
