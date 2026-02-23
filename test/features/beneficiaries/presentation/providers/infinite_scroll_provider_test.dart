import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/infinite_scroll_provider.dart';

void main() {
  group('InfiniteScrollState', () {
    test('initial state should have correct defaults', () {
      final state = InfiniteScrollState.initial();

      expect(state.items, isEmpty);
      expect(state.currentPage, 0);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
      expect(state.error, null);
    });

    test('copyWith should update only specified fields', () {
      final original = InfiniteScrollState.initial();
      final updated = original.copyWith(
        items: ['Item 1', 'Item 2'],
        currentPage: 1,
        isLoading: true,
      );

      expect(updated.items, ['Item 1', 'Item 2']);
      expect(updated.currentPage, 1);
      expect(updated.isLoading, true);
      expect(updated.hasMore, true); // Unchanged
      expect(updated.error, null); // Unchanged
    });

    test('copyWith should preserve original when no changes', () {
      const original = InfiniteScrollState(
        items: ['Item 1'],
        currentPage: 1,
        isLoading: false,
        hasMore: true,
        error: 'Test error',
      );

      final updated = original.copyWith();

      expect(updated.items, original.items);
      expect(updated.currentPage, original.currentPage);
      expect(updated.isLoading, original.isLoading);
      expect(updated.hasMore, original.hasMore);
      expect(updated.error, original.error);
    });
  });

  group('InfiniteScrollNotifier', () {
    late ProviderContainer container;
    late InfiniteScrollNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(infiniteScrollProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be correct', () {
      final state = container.read(infiniteScrollProvider);

      expect(state.items, isEmpty);
      expect(state.currentPage, 0);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
    });

    test('loadNextPage should load items and update state', () async {
      await notifier.loadNextPage();
      final state = container.read(infiniteScrollProvider);

      expect(state.items, hasLength(20));
      expect(state.currentPage, 1);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
    });

    test('multiple loadNextPage calls should accumulate items', () async {
      await notifier.loadNextPage();
      await notifier.loadNextPage();
      await notifier.loadNextPage();

      final state = container.read(infiniteScrollProvider);

      expect(state.items, hasLength(60)); // 3 pages * 20 items
      expect(state.currentPage, 3);
    });

    test('should not load when already loading', () async {
      final future1 = notifier.loadNextPage();
      final future2 = notifier.loadNextPage(); // Should be ignored

      await Future.wait([future1, future2]);
      final state = container.read(infiniteScrollProvider);

      expect(state.items, hasLength(20)); // Only one page loaded
    });

    test('should not load when hasMore is false', () async {
      // Load all pages until hasMore becomes false (mock has 10 pages max)
      for (var i = 0; i < 11; i++) {
        await notifier.loadNextPage();
      }

      final stateBefore = container.read(infiniteScrollProvider);
      // After page 10, hasMore should be false
      expect(stateBefore.currentPage >= 10, true);

      await notifier.loadNextPage(); // Should not add more items
      final stateAfter = container.read(infiniteScrollProvider);

      expect(stateAfter.items.length, stateBefore.items.length);
    });

    test('reset should clear all data', () async {
      await notifier.loadNextPage();
      await notifier.loadNextPage();

      notifier.reset();
      final state = container.read(infiniteScrollProvider);

      expect(state.items, isEmpty);
      expect(state.currentPage, 0);
      expect(state.isLoading, false);
      expect(state.hasMore, true);
    });

    test('shouldPrefetch should return true at 80% threshold', () {
      expect(notifier.shouldPrefetch(800, 1000), true);
      expect(notifier.shouldPrefetch(850, 1000), true);
      expect(notifier.shouldPrefetch(900, 1000), true);
    });

    test('shouldPrefetch should return false below 80% threshold', () {
      expect(notifier.shouldPrefetch(700, 1000), false);
      expect(notifier.shouldPrefetch(500, 1000), false);
      expect(notifier.shouldPrefetch(100, 1000), false);
    });

    test('shouldPrefetch should handle edge cases', () {
      expect(notifier.shouldPrefetch(0, 0), false); // Zero extent
      expect(notifier.shouldPrefetch(0, 1000), false); // At start
      expect(notifier.shouldPrefetch(1000, 1000), true); // At end
    });

    test('loading state should be set correctly during load', () async {
      final statesBefore = <bool>[];
      final statesDuring = <bool>[];
      final statesAfter = <bool>[];

      container.listen(infiniteScrollProvider, (previous, next) {
        if (next.isLoading) {
          statesDuring.add(true);
        } else if (previous?.isLoading == true) {
          statesAfter.add(false);
        }
      });

      statesBefore.add(container.read(infiniteScrollProvider).isLoading);
      await notifier.loadNextPage();

      expect(statesBefore, [false]);
      expect(statesDuring, isNotEmpty);
      expect(statesAfter, isNotEmpty);
    });

    test('items should have correct format', () async {
      await notifier.loadNextPage();
      final state = container.read(infiniteScrollProvider);

      expect(state.items.first, 'Item 1');
      expect(state.items.last, 'Item 20');
      expect(state.items[9], 'Item 10');
    });

    test('should handle rapid reset and reload', () async {
      await notifier.loadNextPage();
      notifier.reset();
      await notifier.loadNextPage();
      notifier.reset();
      await notifier.loadNextPage();

      final state = container.read(infiniteScrollProvider);
      expect(state.items, hasLength(20));
      expect(state.currentPage, 1);
    });
  });
}
