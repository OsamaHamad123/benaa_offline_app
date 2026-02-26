import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/dashboard/presentation/providers/dashboard_ui_state_provider.dart';

void main() {
  group('DashboardUIStateNotifier', () {
    test('clearAdvancedFilters resets nullable filters to null', () {
      final notifier = DashboardUIStateNotifier();

      notifier.applyAdvancedFilters(
        category: 'cat-1',
        governorate: 'gov-1',
        syncedOnly: true,
      );

      expect(notifier.state.selectedCategory, 'cat-1');
      expect(notifier.state.selectedGovernorate, 'gov-1');
      expect(notifier.state.syncedOnly, true);

      notifier.clearAdvancedFilters();

      expect(notifier.state.selectedCategory, isNull);
      expect(notifier.state.selectedGovernorate, isNull);
      expect(notifier.state.syncedOnly, isNull);
    });

    test('setSelectedTab updates selectedTabIndex', () {
      final notifier = DashboardUIStateNotifier();

      expect(notifier.state.selectedTabIndex, 0);
      notifier.setSelectedTab(2);
      expect(notifier.state.selectedTabIndex, 2);
    });
  });
}
