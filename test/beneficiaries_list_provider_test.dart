import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/beneficiaries_list_state.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/filters_provider.dart';

/// 🧪 Integration Tests للـ Beneficiaries List Provider
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Filters Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
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

  // Pagination Tests تم تعطيلها لأنها تحتاج database context

  group('State Management Tests', () {
    test('state copyWith preserves unchanged values', () {
      const state = BeneficiariesListState(
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
      const emptyState = BeneficiariesListState(isLoading: false);

      expect(emptyState.isEmpty, true);
      expect(emptyState.hasData, false);
    });
  });
}
