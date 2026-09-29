import 'package:benaa_offline_app/features/dashboard/domain/entities/activity.dart';
import 'package:benaa_offline_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_dashboard_statistics.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_recent_activities.dart';
import 'package:benaa_offline_app/features/dashboard/domain/usecases/get_today_stats.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_notifier.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnusedRepository implements DashboardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('not used by this test');
}

/// A notifier whose state already holds [activities], without loading anything.
class _SeededNotifier extends DashboardNotifier {
  _SeededNotifier(List<Activity> activities)
      : super(
          getDashboardStatistics: GetDashboardStatistics(_UnusedRepository()),
          getTodayStats: GetTodayStats(_UnusedRepository()),
          getRecentActivities: GetRecentActivities(_UnusedRepository()),
        ) {
    // State lists are unmodifiable, as they are when the real notifier loads.
    state = DashboardState(activities: List.unmodifiable(activities));
  }
}

Activity _activity(String id, String type, DateTime at) =>
    Activity(id: id, type: type, description: id, timestamp: at);

void main() {
  final older = _activity('a', 'visit', DateTime(2026, 9, 1, 9));
  final newest = _activity('b', 'beneficiary', DateTime(2026, 9, 3, 9));
  final middle = _activity('c', 'visit', DateTime(2026, 9, 2, 9));

  ProviderContainer containerWith(List<Activity> activities) {
    final container = ProviderContainer(overrides: [
      dashboardProvider.overrideWith((ref) => _SeededNotifier(activities)),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('with no filter it sorts newest first without touching the state list',
      () {
    final container = containerWith([older, newest, middle]);

    // Regression: this threw "Cannot modify an unmodifiable list", because
    // with no filter the provider sorted the state's own list in place.
    final result = container.read(filteredActivitiesProvider({'type': 'all'}));

    expect(result, [newest, middle, older]);
    expect(
        container.read(dashboardProvider).activities, [older, newest, middle]);
  });

  test('filters by type and still sorts newest first', () {
    final container = containerWith([older, newest, middle]);

    final result =
        container.read(filteredActivitiesProvider({'type': 'visit'}));

    expect(result, [middle, older]);
  });
}
