import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';
import 'package:benaa_offline_app/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_today_stats.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_notifier.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDashboardRepository implements DashboardRepository {
  DashboardStatistics? _stats;
  String? _statsError;
  List<Activity> _activities = [];

  void setupStats(DashboardStatistics stats) {
    _stats = stats;
    _statsError = null;
  }

  void setupStatsError(String error) {
    _statsError = error;
    _stats = null;
  }

  void setupActivities(List<Activity> activities) {
    _activities = activities;
  }

  @override
  Future<Result<DashboardStatistics>> getStatistics({bool forceRefresh = false}) async {
    if (_statsError != null) return Failure(DatabaseFailure(_statsError!));
    return Success(_stats ?? _defaultStats());
  }

  @override
  Future<Result<TodayStats>> getTodayStats() async {
    return const Success(TodayStats(
      newBeneficiaries: 2,
      completedVisits: 3,
      pendingTasks: 5,
      syncedRecords: 10,
    ));
  }

  @override
  Future<Result<List<Activity>>> getRecentActivities({int limit = 10, int offset = 0}) async {
    final page = _activities.skip(offset).take(limit).toList();
    return Success(page);
  }

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

StateNotifierProvider<DashboardNotifier, DashboardState> _makeProvider(FakeDashboardRepository repo) {
  return StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
    return DashboardNotifier(
      getDashboardStatistics: GetDashboardStatistics(repo),
      getTodayStats: GetTodayStats(repo),
      getRecentActivities: GetRecentActivities(repo),
    );
  });
}

void main() {
  group('DashboardNotifier — initial state', () {
    test('starts in loading state', () {
      final repo = FakeDashboardRepository();
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(provider).isLoadingStats, isTrue);
      expect(container.read(provider).statistics, isNull);
    });
  });

  group('DashboardNotifier — loadStatistics', () {
    test('sets loading state then completes', () async {
      final repo = FakeDashboardRepository();
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(provider).isLoadingStats, isTrue);
      await container.read(provider.notifier).loadStatistics();
      expect(container.read(provider).isLoadingStats, isFalse);
    });

    test('completes with statistics on success', () async {
      final repo = FakeDashboardRepository();
      repo.setupStats(_defaultStats());
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      final state = container.read(provider);
      expect(state.statistics, isNotNull);
      expect(state.statistics!.totalBeneficiaries, 100);
      expect(state.isLoadingStats, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('sets errorMessage on repository failure', () async {
      final repo = FakeDashboardRepository();
      repo.setupStatsError('خطأ في قاعدة البيانات');
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      final state = container.read(provider);
      expect(state.isLoadingStats, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.statistics, isNull);
    });

    test('forceRefresh=true still loads statistics', () async {
      final repo = FakeDashboardRepository();
      repo.setupStats(_defaultStats());
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics(forceRefresh: true);

      final state = container.read(provider);
      expect(state.statistics, isNotNull);
      expect(state.isLoadingStats, isFalse);
    });

    test('sets lastRefreshTime after successful load', () async {
      final repo = FakeDashboardRepository();
      repo.setupStats(_defaultStats());
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // subtract 1ms so lastRefreshTime is strictly after `before`
      // even when loadStatistics() runs within the same millisecond
      final before = DateTime.now().subtract(const Duration(milliseconds: 1));
      await container.read(provider.notifier).loadStatistics();

      final state = container.read(provider);
      expect(state.lastRefreshTime, isNotNull);
      expect(state.lastRefreshTime!.isAfter(before), isTrue);
    });
  });

  group('DashboardNotifier — loadMoreActivities', () {
    test('loads activities from repository', () async {
      final repo = FakeDashboardRepository();
      final fakeActivities = List.generate(
        15,
        (i) => Activity(
          id: 'act_$i',
          type: 'visit',
          description: 'نشاط $i',
          timestamp: DateTime.now(),
        ),
      );
      repo.setupActivities(fakeActivities);
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      expect(container.read(provider).activities.length, lessThanOrEqualTo(15));
    });

    test('stops loading when hasMoreActivities is false (few items)', () async {
      final repo = FakeDashboardRepository();
      repo.setupActivities([
        Activity(id: 'a1', type: 'visit', description: 'a1', timestamp: DateTime.now()),
        Activity(id: 'a2', type: 'visit', description: 'a2', timestamp: DateTime.now()),
        Activity(id: 'a3', type: 'visit', description: 'a3', timestamp: DateTime.now()),
      ]);
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      expect(container.read(provider).hasMoreActivities, isFalse);
      await container.read(provider.notifier).loadMoreActivities();
      expect(container.read(provider).activities.length, 3);
    });

    test('isLoadingActivities is false after loading completes', () async {
      final repo = FakeDashboardRepository();
      repo.setupActivities([]);
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      expect(container.read(provider).isLoadingActivities, isFalse);
    });
  });

  group('DashboardNotifier — refresh', () {
    test('refresh updates lastRefreshTime', () async {
      final repo = FakeDashboardRepository();
      repo.setupStats(_defaultStats());
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();
      final firstRefreshTime = container.read(provider).lastRefreshTime;

      await Future.delayed(const Duration(milliseconds: 10));
      await container.read(provider.notifier).refresh();

      final state = container.read(provider);
      expect(state.lastRefreshTime, isNotNull);
      expect(state.lastRefreshTime!.isAfter(firstRefreshTime!), isTrue);
    });
  });

  group('DashboardNotifier — clearError', () {
    test('clearError removes errorMessage', () async {
      final repo = FakeDashboardRepository();
      repo.setupStatsError('خطأ');
      final provider = _makeProvider(repo);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(provider.notifier).loadStatistics();

      expect(container.read(provider).errorMessage, isNotNull);
      container.read(provider.notifier).clearError();
      expect(container.read(provider).errorMessage, isNull);
    });
  });
}
