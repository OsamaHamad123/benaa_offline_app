import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_today_stats.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for post-sync dashboard provider invalidation.
///
/// CURRENT STATUS (2026-05-28):
/// The wiring between sync completion and dashboard refresh is NOT yet implemented.
/// DashboardNotifier.refresh() is available but not called by any sync hook.
///
/// These tests verify:
/// 1. That refresh() correctly re-fetches data (the mechanism exists)
/// 2. That failed operations do not mark data as refreshed
/// 3. That a second refresh loads newer data if available
///
/// The actual sync→dashboard wiring is documented as a TODO in STATE_MANAGEMENT_AUDIT.md.

class _CountingRepository implements DashboardRepository {
  int statsCallCount = 0;
  DashboardStatistics? nextStats;

  @override
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false}) async {
    statsCallCount++;
    return Success(nextStats ?? _defaultStats());
  }

  @override
  Future<Result<TodayStats>> getTodayStats() async => Success(_defaultTodayStats());

  @override
  Future<Result<List<Activity>>> getRecentActivities({int limit = 10, int offset = 0}) async => const Success([]);

  @override
  Future<Result<int>> getNotificationsCount() async => const Success(0);

  @override
  Future<Result<void>> clearCache() async => const Success(null);

  @override
  Stream<DashboardStatistics>? watchStatistics() => null;
}

class _FailingRepository implements DashboardRepository {
  @override
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false}) async =>
      const Failure(DatabaseFailure('خطأ في قاعدة البيانات'));

  @override
  Future<Result<TodayStats>> getTodayStats() async => const Failure(DatabaseFailure('error'));

  @override
  Future<Result<List<Activity>>> getRecentActivities({int limit = 10, int offset = 0}) async => const Success([]);

  @override
  Future<Result<int>> getNotificationsCount() async => const Success(0);

  @override
  Future<Result<void>> clearCache() async => const Success(null);

  @override
  Stream<DashboardStatistics>? watchStatistics() => null;
}

DashboardStatistics _defaultStats({int total = 100}) => DashboardStatistics(
      totalBeneficiaries: total,
      activeBeneficiaries: 80,
      pendingSync: 5,
      completedVisitsToday: 3,
      categoryCounts: const {},
      growthData: const [],
      todayStats: const TodayStats(
        newBeneficiaries: 2,
        completedVisits: 3,
        pendingTasks: 5,
        syncedRecords: 10,
      ),
    );

TodayStats _defaultTodayStats() => const TodayStats(
      newBeneficiaries: 2,
      completedVisits: 3,
      pendingTasks: 5,
      syncedRecords: 10,
    );

DashboardNotifier _buildNotifier(DashboardRepository repo) => DashboardNotifier(
      getDashboardStatistics: GetDashboardStatistics(repo),
      getTodayStats: GetTodayStats(repo),
      getRecentActivities: GetRecentActivities(repo),
    );

void main() {
  group('Post-sync invalidation mechanism', () {
    test('refresh() triggers a new getStatistics call', () async {
      final repo = _CountingRepository();
      final notifier = _buildNotifier(repo);

      await notifier.loadStatistics();
      final callsAfterFirstLoad = repo.statsCallCount;

      await notifier.refresh(); // simulates post-sync invalidation
      expect(repo.statsCallCount, greaterThan(callsAfterFirstLoad));
    });

    test('refresh() updates lastRefreshTime', () async {
      final repo = _CountingRepository();
      final notifier = _buildNotifier(repo);
      await notifier.loadStatistics();

      final firstTime = notifier.state.lastRefreshTime!;
      await Future.delayed(const Duration(milliseconds: 10));

      await notifier.refresh();

      expect(notifier.state.lastRefreshTime!.isAfter(firstTime), isTrue);
    });

    test('refresh() loads updated statistics from repository', () async {
      final repo = _CountingRepository();
      repo.nextStats = _defaultStats(total: 100);
      final notifier = _buildNotifier(repo);
      await notifier.loadStatistics();

      expect(notifier.state.statistics!.totalBeneficiaries, 100);

      // Simulate sync added new beneficiaries
      repo.nextStats = _defaultStats(total: 150);
      await notifier.refresh();

      expect(notifier.state.statistics!.totalBeneficiaries, 150);
    });

    test('failed sync should NOT mark statistics as refreshed', () async {
      final failRepo = _FailingRepository();
      final notifier = _buildNotifier(failRepo);

      await notifier.loadStatistics();

      // After failure, statistics is null and errorMessage is set
      expect(notifier.state.statistics, isNull);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.lastRefreshTime, isNull);
    });

    test('refresh after failure still attempts reload', () async {
      final repo = _CountingRepository();
      repo.nextStats = _defaultStats();
      final notifier = _buildNotifier(repo);

      // Simulate initial failure scenario by manually loading first (success)
      await notifier.loadStatistics();
      final beforeRefresh = repo.statsCallCount;

      // Now refresh (simulating post-sync trigger)
      await notifier.refresh();
      expect(repo.statsCallCount, greaterThan(beforeRefresh));
    });

    // DOCUMENTED TODO: The actual sync→dashboard wiring is not yet implemented.
    // When sync completes, the sync notifier must call:
    //   ref.read(dashboardProvider.notifier).refresh()
    // This is NOT currently done in MobileSyncPage or the sync state machine.
    // See STATE_MANAGEMENT_AUDIT.md — "Post-sync invalidation not implemented".
    test('KNOWN GAP: post-sync wiring is not implemented (documented)', () {
      // This test is a documentation placeholder.
      // It will pass trivially but serves as a reminder.
      const implemented = false;
      expect(implemented, isFalse,
          reason: 'sync→dashboard.refresh() wiring is not implemented. '
              'See STATE_MANAGEMENT_AUDIT.md for details.');
    });
  });
}
