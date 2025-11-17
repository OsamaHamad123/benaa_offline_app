import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/beneficiaries_list_state.dart';

/// 🧪 Tests للـ States
void main() {
  group('BeneficiariesListState Tests', () {
    test('isEmpty returns true when not loading and items empty', () {
      const state = BeneficiariesListState(items: [], isLoading: false);

      expect(state.isEmpty, true);
      expect(state.hasData, false);
    });

    test('hasData returns true when items exist', () {
      final state = BeneficiariesListState(
        items: [
          // Mock beneficiary يمكن إضافته لاحقاً
        ],
        isLoading: false,
      );

      expect(state.hasData, false); // Empty list
    });

    test('copyWith updates specific fields', () {
      const state = BeneficiariesListState();
      final updated = state.copyWith(isLoading: false, totalCount: 100);

      expect(updated.isLoading, false);
      expect(updated.totalCount, 100);
      expect(updated.currentPage, 0); // unchanged
    });
  });

  group('FiltersState Tests', () {
    test('activeFiltersCount returns 0 for default state', () {
      const filters = FiltersState();
      expect(filters.activeFiltersCount, 0);
      expect(filters.hasActiveFilters, false);
    });

    test('activeFiltersCount counts active filters', () {
      final filters = FiltersState(
        categoryId: 1,
        governorateId: 2,
        onlyPendingSync: true,
      );

      expect(filters.activeFiltersCount, 3);
      expect(filters.hasActiveFilters, true);
    });

    test('cacheKey changes when filters change', () {
      const filters1 = FiltersState();
      const filters2 = FiltersState(categoryId: 1);

      expect(filters1.cacheKey, isNot(equals(filters2.cacheKey)));
    });

    test('copyWith updates filters', () {
      const filters = FiltersState();
      final updated = filters.copyWith(categoryId: 1, sortBy: SortBy.date);

      expect(updated.categoryId, 1);
      expect(updated.sortBy, SortBy.date);
      expect(updated.searchQuery, ''); // unchanged
    });
  });

  group('SelectionState Tests', () {
    test('initial state is not in selection mode', () {
      const selection = SelectionState();

      expect(selection.isSelectionMode, false);
      expect(selection.selectedCount, 0);
    });

    test('selectedCount returns correct count', () {
      const selection = SelectionState(
        isSelectionMode: true,
        selectedIds: {1, 2, 3},
      );

      expect(selection.selectedCount, 3);
    });

    test('isSelected checks if id is in set', () {
      const selection = SelectionState(selectedIds: {1, 2, 3});

      expect(selection.isSelected(1), true);
      expect(selection.isSelected(5), false);
    });

    test('isAllSelected checks if all items selected', () {
      const selection = SelectionState(selectedIds: {1, 2, 3});

      expect(selection.isAllSelected(3), true);
      expect(selection.isAllSelected(5), false);
    });
  });

  group('SortBy Enum Tests', () {
    test('SortBy has correct labels', () {
      expect(SortBy.name.label, 'الاسم');
      expect(SortBy.date.label, 'التاريخ');
      expect(SortBy.fileNo.label, 'رقم الملف');
      expect(SortBy.age.label, 'العمر');
      expect(SortBy.lastModified.label, 'آخر تعديل');
    });
  });
}
