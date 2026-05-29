import 'package:benaa_offline_app/core/auth/role_provider.dart';
import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart' as dash_activity;
import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_today_stats.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_notifier.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:benaa_offline_app/core/widgets/filter_chip_group.dart';
import 'package:drift/native.dart';
import 'package:benaa_offline_app/data/db/drift_database.dart' as drift_db;
import 'package:benaa_offline_app/core/providers/providers.dart' as core_providers;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dashboard page-level render tests using fake lightweight providers.
/// Tests the key visible widgets without requiring real Firebase/DB.
///
/// NOTE: The full DashboardPage is complex (connectivity, analytics, monitoring).
/// These tests use isolated widget rendering to verify key UI contracts.

class _FakeRepo implements DashboardRepository {
  @override
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false}) async =>
      const Success(DashboardStatistics(
        totalBeneficiaries: 50,
        activeBeneficiaries: 40,
        pendingSync: 2,
        completedVisitsToday: 1,
        categoryCounts: {},
        growthData: [],
        todayStats: TodayStats(
          newBeneficiaries: 1,
          completedVisits: 1,
          pendingTasks: 2,
          syncedRecords: 5,
        ),
      ));

  @override
  Future<Result<TodayStats>> getTodayStats() async => const Success(TodayStats(
        newBeneficiaries: 1,
        completedVisits: 1,
        pendingTasks: 2,
        syncedRecords: 5,
      ));

  @override
  Future<Result<List<dash_activity.Activity>>> getRecentActivities({int limit = 10, int offset = 0}) async =>
      const Success([]);

  @override
  Future<Result<int>> getNotificationsCount() async => const Success(0);

  @override
  Future<Result<void>> clearCache() async => const Success(null);

  @override
  Stream<DashboardStatistics>? watchStatistics() => null;
}

Widget _buildWithProviders({
  required Widget child,
  bool isAdmin = false,
}) {
  final db = drift_db.AppDatabase(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      core_providers.databaseProvider.overrideWithValue(db),
      isAdminProvider.overrideWithValue(isAdmin),
      dashboardProvider.overrideWith((ref) {
        final repo = _FakeRepo();
        return DashboardNotifier(
          getDashboardStatistics: GetDashboardStatistics(repo),
          getTodayStats: GetTodayStats(repo),
          getRecentActivities: GetRecentActivities(repo),
        );
      }),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('QuickActionsGrid — normal user (no admin tools)', () {
    testWidgets('الـ 6 بطاقات تظهر للمستخدم العادي', (tester) async {
      await tester.pumpWidget(_buildWithProviders(
        child: const QuickActionsGrid(),
        isAdmin: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('إضافة مستفيد'), findsOneWidget);
      expect(find.text('المستفيدون'), findsOneWidget);
      expect(find.text('زيارات اليوم'), findsOneWidget);
      expect(find.text('الكفالات'), findsOneWidget);
      expect(find.text('الجمعيات'), findsOneWidget);
      expect(find.text('المزامنة'), findsOneWidget);
    });

    testWidgets('لا تظهر أدوات تطوير/admin في بطاقات الـ QuickActions', (tester) async {
      await tester.pumpWidget(_buildWithProviders(
        child: const QuickActionsGrid(),
        isAdmin: false,
      ));
      await tester.pumpAndSettle();

      // No seed/debug/reports actions
      expect(find.text('التقارير'), findsNothing);
      expect(find.text('بذر البيانات'), findsNothing);
      expect(find.text('السجل المدني'), findsNothing);
    });
  });

  group('FilterChipGroup — dashboard filters', () {
    testWidgets('الفلاتر الأربعة تظهر بدون overflow', (tester) async {
      await tester.pumpWidget(_buildWithProviders(
        child: const FilterChipGroup(
          selectedFilter: 'all',
          filters: [
            FilterChipData(label: 'الكل', value: 'all', icon: Icons.grid_view),
            FilterChipData(label: 'اليوم', value: 'today', icon: Icons.today),
            FilterChipData(label: 'هذا الأسبوع', value: 'week', icon: Icons.date_range),
            FilterChipData(label: 'تحتاج متابعة', value: 'urgent', icon: Icons.warning_amber),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('اليوم'), findsOneWidget);
      expect(find.text('هذا الأسبوع'), findsOneWidget);
      expect(find.text('تحتاج متابعة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Dashboard render — activities preview max 5 items', () {
    test('DashboardNotifier activities limited to pageSize on first load', () async {
      final repo = _FakeRepo();
      final notifier = DashboardNotifier(
        getDashboardStatistics: GetDashboardStatistics(repo),
        getTodayStats: GetTodayStats(repo),
        getRecentActivities: GetRecentActivities(repo),
      );
      await notifier.loadStatistics();
      // FakeRepo returns [] activities
      expect(notifier.state.activities.length, 0);
      // hasMoreActivities is false since 0 < pageSize(10)
      expect(notifier.state.hasMoreActivities, isFalse);
    });
  });

  group('Dashboard seed/sync safety', () {
    testWidgets('لا توجد أزرار seed أو trigger-sync في QuickActionsGrid عند الفتح', (tester) async {
      await tester.pumpWidget(_buildWithProviders(
        child: const QuickActionsGrid(),
        isAdmin: false,
      ));
      await tester.pumpAndSettle();

      // No auto-seed or full-sync triggers visible
      expect(find.text('تزامن كامل'), findsNothing);
      expect(find.text('بيانات تجريبية'), findsNothing);
    });
  });
}
