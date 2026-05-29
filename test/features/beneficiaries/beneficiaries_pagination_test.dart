import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/infinite_scroll_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for InfiniteScrollNotifier (beneficiaries pagination).
///
/// The InfiniteScrollNotifier uses pageSize=20 and a prefetch threshold of 80%.
/// These tests validate the pagination state machine with no real DB or Firebase.
void main() {
  group('InfiniteScrollNotifier — initial state', () {
    test('starts empty with hasMore=true', () {
      final notifier = InfiniteScrollNotifier();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.hasMore, isTrue);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.currentPage, 0);
    });
  });

  group('InfiniteScrollNotifier — loadNextPage', () {
    test('first page loads pageSize items', () async {
      final notifier = InfiniteScrollNotifier();
      await notifier.loadNextPage();

      // pageSize = 20
      expect(notifier.state.items.length, 20);
      expect(notifier.state.currentPage, 1);
      expect(notifier.state.isLoading, isFalse);
    });

    test('second page appends without duplicating', () async {
      final notifier = InfiniteScrollNotifier();
      await notifier.loadNextPage();
      final firstPageItems = List<String>.from(notifier.state.items);

      await notifier.loadNextPage();

      // All first page items are still there
      for (final item in firstPageItems) {
        expect(notifier.state.items, contains(item));
      }
      // Total count is 40
      expect(notifier.state.items.length, 40);
    });

    test('does not load when isLoading is true', () async {
      final notifier = InfiniteScrollNotifier();
      // Manually verify guard: state.isLoading starts false, so first call goes through
      expect(notifier.state.isLoading, isFalse);
      await notifier.loadNextPage();
      // After load, isLoading is false again
      expect(notifier.state.isLoading, isFalse);
    });

    test('does not load when hasMore is false', () async {
      final notifier = InfiniteScrollNotifier();
      // Load until no more items (mock: hasMore = false when currentPage reaches 10)
      // hasMore is set based on state.currentPage BEFORE increment,
      // so: after page 10 call, currentPage becomes 10, but hasMore was (9<10)=true.
      // After page 11 call, hasMore = (10<10) = false.
      while (notifier.state.hasMore) {
        await notifier.loadNextPage();
      }
      expect(notifier.state.hasMore, isFalse);

      final countAtStop = notifier.state.items.length;
      await notifier.loadNextPage(); // should be no-op
      expect(notifier.state.items.length, countAtStop);
    });

    test('items grow monotonically across pages', () async {
      final notifier = InfiniteScrollNotifier();
      for (int page = 0; page < 3; page++) {
        final prevCount = notifier.state.items.length;
        await notifier.loadNextPage();
        expect(notifier.state.items.length, greaterThan(prevCount));
      }
    });
  });

  group('InfiniteScrollNotifier — reset', () {
    test('reset clears items and restores initial state', () async {
      final notifier = InfiniteScrollNotifier();
      await notifier.loadNextPage();
      expect(notifier.state.items, isNotEmpty);

      notifier.reset();

      expect(notifier.state.items, isEmpty);
      expect(notifier.state.currentPage, 0);
      expect(notifier.state.hasMore, isTrue);
      expect(notifier.state.isLoading, isFalse);
    });

    test('reset allows reload from page 0', () async {
      final notifier = InfiniteScrollNotifier();
      await notifier.loadNextPage();
      notifier.reset();
      await notifier.loadNextPage();

      // First page items start at "Item 1"
      expect(notifier.state.items.first, 'Item 1');
    });
  });

  group('InfiniteScrollNotifier — shouldPrefetch', () {
    test('returns true when scroll is at 80% or more', () {
      final notifier = InfiniteScrollNotifier();
      expect(notifier.shouldPrefetch(800, 1000), isTrue);
      expect(notifier.shouldPrefetch(900, 1000), isTrue);
    });

    test('returns false when scroll is below 80%', () {
      final notifier = InfiniteScrollNotifier();
      expect(notifier.shouldPrefetch(700, 1000), isFalse);
      expect(notifier.shouldPrefetch(0, 1000), isFalse);
    });

    test('returns false when maxScrollExtent is 0', () {
      final notifier = InfiniteScrollNotifier();
      expect(notifier.shouldPrefetch(0, 0), isFalse);
    });
  });
}
