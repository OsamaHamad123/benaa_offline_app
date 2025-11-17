import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/list/selection_provider.dart';

/// 🧪 Tests للـ Selection Provider
void main() {
  group('SelectionNotifier Tests', () {
    late ProviderContainer container;
    late SelectionNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(selectionProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is not in selection mode', () {
      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, false);
      expect(state.selectedCount, 0);
    });

    test('toggleSelectionMode activates mode', () {
      notifier.toggleSelectionMode();
      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, true);
    });

    test('toggleSelectionMode deactivates and clears', () {
      notifier.startSelectionWith(1);
      notifier.toggleSelectionMode();

      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, false);
      expect(state.selectedCount, 0);
    });

    test('toggleItem adds item to selection', () {
      notifier.toggleItem(1);
      final state = container.read(selectionProvider);

      expect(state.isSelectionMode, true); // Auto-enabled
      expect(state.selectedCount, 1);
      expect(state.isSelected(1), true);
    });

    test('toggleItem removes item from selection', () {
      notifier.toggleItem(1);
      notifier.toggleItem(1); // Toggle again

      final state = container.read(selectionProvider);
      expect(state.selectedCount, 0);
      expect(state.isSelectionMode, false); // Auto-disabled
    });

    test('selectAll selects all items', () {
      final allIds = [1, 2, 3, 4, 5];
      notifier.selectAll(allIds);

      final state = container.read(selectionProvider);
      expect(state.selectedCount, 5);
      expect(state.isAllSelected(5), true);
    });

    test('deselectAll clears everything', () {
      notifier.selectAll([1, 2, 3]);
      notifier.deselectAll();

      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, false);
      expect(state.selectedCount, 0);
    });

    test('clearSelections keeps mode active', () {
      notifier.selectAll([1, 2, 3]);
      notifier.clearSelections();

      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, true); // Still active
      expect(state.selectedCount, 0);
    });

    test('startSelectionWith starts with one item', () {
      notifier.startSelectionWith(5);

      final state = container.read(selectionProvider);
      expect(state.isSelectionMode, true);
      expect(state.selectedCount, 1);
      expect(state.isSelected(5), true);
    });
  });
}
