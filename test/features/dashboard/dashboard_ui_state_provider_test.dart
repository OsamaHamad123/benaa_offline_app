import 'package:benaa_offline_app/features/dashboard/presentation/providers/dashboard_ui_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardUIStateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    DashboardUIStateNotifier notifier() => container.read(dashboardUIStateProvider.notifier);

    DashboardUIState state() => container.read(dashboardUIStateProvider);

    // =========================================================================
    // Default State
    // =========================================================================

    test('default state has expected values', () {
      final s = state();
      expect(s.selectedFilter, 'all');
      expect(s.selectedTabIndex, 0);
      expect(s.selectedTimeContext, DashboardTimeContext.week);
      expect(s.showWelcomeBanner, false);
      expect(s.isOnline, true);
      expect(s.selectedCategory, isNull);
      expect(s.selectedGovernorate, isNull);
      expect(s.syncedOnly, isNull);
    });

    // =========================================================================
    // Selected Filter
    // =========================================================================

    test('setSelectedFilter updates selectedFilter', () {
      notifier().setSelectedFilter('orphans');
      expect(state().selectedFilter, 'orphans');
    });

    test('setSelectedFilter does not mutate other fields', () {
      notifier().setSelectedFilter('poor');
      final s = state();
      expect(s.selectedTabIndex, 0);
      expect(s.selectedCategory, isNull);
      expect(s.isOnline, true);
    });

    // =========================================================================
    // Dashboard Time Context (View Mode)
    // =========================================================================

    test('setTimeContext updates selectedTimeContext', () {
      notifier().setTimeContext(DashboardTimeContext.month);
      expect(state().selectedTimeContext, DashboardTimeContext.month);
    });

    test('setTimeContext to today updates correctly', () {
      notifier().setTimeContext(DashboardTimeContext.today);
      expect(state().selectedTimeContext, DashboardTimeContext.today);
    });

    // =========================================================================
    // Advanced Filters
    // =========================================================================

    test('applyAdvancedFilters sets all three filter fields', () {
      notifier().applyAdvancedFilters(
        category: 'orphans',
        governorate: 'Gaza',
        syncedOnly: true,
      );
      final s = state();
      expect(s.selectedCategory, 'orphans');
      expect(s.selectedGovernorate, 'Gaza');
      expect(s.syncedOnly, true);
    });

    test('applyAdvancedFilters with nulls clears those fields', () {
      notifier().applyAdvancedFilters(
        category: 'orphans',
        governorate: 'Gaza',
        syncedOnly: true,
      );
      notifier().applyAdvancedFilters(
        category: null,
        governorate: null,
        syncedOnly: null,
      );
      final s = state();
      expect(s.selectedCategory, isNull);
      expect(s.selectedGovernorate, isNull);
      expect(s.syncedOnly, isNull);
    });

    test('clearAdvancedFilters resets category/governorate/syncedOnly', () {
      notifier().applyAdvancedFilters(
        category: 'poor',
        governorate: 'Rafah',
        syncedOnly: false,
      );
      notifier().clearAdvancedFilters();
      final s = state();
      expect(s.selectedCategory, isNull);
      expect(s.selectedGovernorate, isNull);
      expect(s.syncedOnly, isNull);
    });

    test('clearAdvancedFilters preserves selectedFilter', () {
      notifier().setSelectedFilter('poor');
      notifier().applyAdvancedFilters(category: 'test');
      notifier().clearAdvancedFilters();
      expect(state().selectedFilter, 'poor');
    });

    // =========================================================================
    // Welcome Banner
    // =========================================================================

    test('showWelcomeBanner sets banner to true', () {
      notifier().showWelcomeBanner();
      expect(state().showWelcomeBanner, true);
    });

    test('hideWelcomeBanner sets banner to false', () {
      notifier().showWelcomeBanner();
      notifier().hideWelcomeBanner();
      expect(state().showWelcomeBanner, false);
    });

    // =========================================================================
    // Online Status
    // =========================================================================

    test('setOnlineStatus to false updates isOnline', () {
      notifier().setOnlineStatus(false);
      expect(state().isOnline, false);
    });

    test('setOnlineStatus to true restores isOnline', () {
      notifier().setOnlineStatus(false);
      notifier().setOnlineStatus(true);
      expect(state().isOnline, true);
    });

    // =========================================================================
    // No data-state mutation from UI-state changes
    // =========================================================================

    test('changing selectedFilter does not affect selectedCategory or syncedOnly', () {
      notifier().applyAdvancedFilters(category: 'orphans', syncedOnly: true);
      notifier().setSelectedFilter('poor');
      final s = state();
      expect(s.selectedCategory, 'orphans');
      expect(s.syncedOnly, true);
    });

    test('changing timeContext does not affect selectedFilter', () {
      notifier().setSelectedFilter('poor');
      notifier().setTimeContext(DashboardTimeContext.today);
      expect(state().selectedFilter, 'poor');
    });

    // =========================================================================
    // Computed helpers
    // =========================================================================

    test('notifier.hasAdvancedFilters is false with no filters', () {
      expect(notifier().hasAdvancedFilters, false);
    });

    test('notifier.hasAdvancedFilters is true after applying category', () {
      notifier().setCategory('orphans');
      expect(notifier().hasAdvancedFilters, true);
    });

    test('notifier.activeFiltersCount counts applied filters', () {
      notifier().applyAdvancedFilters(
        category: 'poor',
        governorate: 'Gaza',
        syncedOnly: null,
      );
      expect(notifier().activeFiltersCount, 2);
    });

    test('notifier.activeFiltersCount is 0 after clearAdvancedFilters', () {
      notifier().applyAdvancedFilters(
        category: 'poor',
        governorate: 'Gaza',
        syncedOnly: true,
      );
      notifier().clearAdvancedFilters();
      expect(notifier().activeFiltersCount, 0);
    });
  });
}
