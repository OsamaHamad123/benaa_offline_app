import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/state/dashboard_state.dart';

void main() {
  group('DashboardState.copyWith', () {
    test('keeps existing errorMessage when errorMessage is omitted', () {
      const state = DashboardState(errorMessage: 'network error');

      final updated = state.copyWith(isLoadingStats: true);

      expect(updated.errorMessage, 'network error');
      expect(updated.isLoadingStats, true);
    });

    test('clears errorMessage when errorMessage is explicitly null', () {
      const state = DashboardState(errorMessage: 'network error');

      final updated = state.copyWith(errorMessage: null);

      expect(updated.errorMessage, isNull);
    });
  });
}
