import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/filters_provider.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/beneficiaries_list_state.dart';

/// 🧪 Tests للـ Filters Provider
void main() {
  group('FiltersNotifier Tests', () {
    late ProviderContainer container;
    late FiltersNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(filtersProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is default FiltersState', () {
      final state = container.read(filtersProvider);
      expect(state.searchQuery, '');
      expect(state.categoryId, isNull);
      expect(state.hasActiveFilters, false);
    });

    test('setSearchQuery updates search query', () {
      notifier.setSearchQuery('test');
      final state = container.read(filtersProvider);
      expect(state.searchQuery, 'test');
    });

    test('setCategory updates category', () {
      notifier.setCategory(1);
      final state = container.read(filtersProvider);
      expect(state.categoryId, 1);
      expect(state.hasActiveFilters, true);
    });

    test('setGovernorate resets city', () {
      notifier.setCity(10);
      notifier.setGovernorate(5);
      final state = container.read(filtersProvider);

      expect(state.governorateId, 5);
      expect(state.cityId, isNull); // Reset!
    });

    test('setSorting updates sort fields', () {
      notifier.setSorting(SortBy.date, false);
      final state = container.read(filtersProvider);

      expect(state.sortBy, SortBy.date);
      expect(state.sortAscending, false);
    });

    test('toggleSortDirection flips ascending flag', () {
      notifier.toggleSortDirection();
      final state = container.read(filtersProvider);
      expect(state.sortAscending, false);

      notifier.toggleSortDirection();
      final state2 = container.read(filtersProvider);
      expect(state2.sortAscending, true);
    });

    test('togglePendingSync flips flag', () {
      notifier.togglePendingSync();
      final state = container.read(filtersProvider);
      expect(state.onlyPendingSync, true);

      notifier.togglePendingSync();
      final state2 = container.read(filtersProvider);
      expect(state2.onlyPendingSync, false);
    });

    test('clearFilters resets to initial state', () {
      notifier.setCategory(1);
      notifier.setSearchQuery('test');
      notifier.togglePendingSync();

      notifier.clearFilters();
      final state = container.read(filtersProvider);

      expect(state.searchQuery, '');
      expect(state.categoryId, isNull);
      expect(state.onlyPendingSync, false);
    });

    test('clearCategory only clears category', () {
      notifier.setCategory(1);
      notifier.setSearchQuery('test');

      notifier.clearCategory();
      final state = container.read(filtersProvider);

      expect(state.categoryId, isNull);
      expect(state.searchQuery, 'test'); // Unchanged
    });
  });
}
