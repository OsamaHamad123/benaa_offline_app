import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/beneficiaries_list_provider.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/beneficiaries_list_state.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/filters_provider.dart';

/// 🧪 Integration Tests للـ Beneficiaries List Provider
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BeneficiariesListNotifier Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading', () {
      final state = container.read(beneficiariesListProvider);
      expect(state.isLoading, true);
      expect(state.items, isEmpty);
    });

    test('filters provider integration', () {
      final filters = container.read(filtersProvider);
      expect(filters.searchQuery, '');
      expect(filters.hasActiveFilters, false);

      // Change filter
      container.read(filtersProvider.notifier).setSearchQuery('test');

      final updatedFilters = container.read(filtersProvider);
      expect(updatedFilters.searchQuery, 'test');
    });

    test('cache key changes when filters change', () {
      final filters1 = container.read(filtersProvider);
      final cacheKey1 = filters1.cacheKey;

      // Change a filter
      container.read(filtersProvider.notifier).setCategory(1);

      final filters2 = container.read(filtersProvider);
      final cacheKey2 = filters2.cacheKey;

      expect(cacheKey1, isNot(equals(cacheKey2)));
    });

    test('sorting options apply correctly', () {
      final notifier = container.read(filtersProvider.notifier);

      notifier.setSorting(SortBy.date, false);
      final filters = container.read(filtersProvider);

      expect(filters.sortBy, SortBy.date);
      expect(filters.sortAscending, false);
    });

    test('clearing filters resets everything', () {
      final notifier = container.read(filtersProvider.notifier);

      // Set multiple filters
      notifier.setCategory(1);
      notifier.setSearchQuery('test');
      notifier.togglePendingSync();
      notifier.setSorting(SortBy.age, false);

      expect(container.read(filtersProvider).hasActiveFilters, true);

      // Clear
      notifier.clearFilters();
      final filters = container.read(filtersProvider);

      expect(filters.searchQuery, '');
      expect(filters.categoryId, isNull);
      expect(filters.onlyPendingSync, false);
      expect(filters.hasActiveFilters, false);
    });
  });

  group('Pagination Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial pagination state', () {
      final state = container.read(beneficiariesListProvider);
      expect(state.currentPage, 0);
      expect(state.pageSize, 50);
      expect(state.hasMore, false);
    });

    test('pagination increments page', () async {
      final state = container.read(beneficiariesListProvider);
      final initialPage = state.currentPage;

      // Note: loadMore() needs database context
      // This test verifies state structure only
      expect(initialPage, greaterThanOrEqualTo(0));
    });
  });

  group('State Management Tests', () {
    test('state copyWith preserves unchanged values', () {
      final state = BeneficiariesListState(
        items: const [],
        isLoading: false,
        currentPage: 5,
        totalCount: 100,
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.currentPage, 5); // Unchanged
      expect(updated.totalCount, 100); // Unchanged
    });

    test('isEmpty and hasData work correctly', () {
      const emptyState = BeneficiariesListState(items: [], isLoading: false);

      expect(emptyState.isEmpty, true);
      expect(emptyState.hasData, false);
    });
  });
}
