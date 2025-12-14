import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/arabic_normalizer.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../providers/search_provider.dart';

/// 🎯 Search Handlers
///
/// يحتوي على معالجات البحث:
/// - onSearchChanged
/// - onScroll
/// - performRecentSearch
/// - clearSearch
class SearchHandlers {
  SearchHandlers._();

  /// Handle search text changes with debouncing
  static void onSearchChanged({
    required String query,
    required WidgetRef ref,
    required Debouncer debouncer,
    required VoidCallback onSuggestionsUpdate,
  }) {
    final notifier = ref.read(searchProvider.notifier);

    if (query.trim().isEmpty) {
      debouncer.cancel();
      notifier.clearSearch();
      onSuggestionsUpdate();
      return;
    }

    // Normalize Arabic text
    final normalizedQuery = ArabicNormalizer.normalize(query);
    notifier.setQuery(normalizedQuery);

    // Update suggestions asynchronously
    final trimmedQuery = normalizedQuery.trim();
    if (trimmedQuery.length >= 2) {
      Future.microtask(() {
        onSuggestionsUpdate();
      });
    }

    // Debounced search
    debouncer.cancel();
    debouncer(() {
      if (trimmedQuery.length >= 2) {
        notifier.search(reset: true);
      }
    });
  }

  /// Handle scroll for infinite loading
  static void onScroll({
    required ScrollController controller,
    required WidgetRef ref,
    required Throttler throttler,
    required bool mounted,
  }) {
    throttler(() {
      if (!mounted) return;

      final searchState = ref.read(searchProvider);
      if (searchState.isSearching || !searchState.hasMore) return;

      final maxScroll = controller.position.maxScrollExtent;
      final currentScroll = controller.position.pixels;
      final threshold = maxScroll * 0.8;

      if (currentScroll >= threshold) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  /// Perform search from recent searches
  static void performRecentSearch({
    required String query,
    required TextEditingController controller,
    required WidgetRef ref,
  }) {
    controller.text = query;
    ref.read(searchProvider.notifier).search(reset: true);
  }

  /// Clear search and reset state
  static void clearSearch({
    required TextEditingController controller,
    required WidgetRef ref,
    required VoidCallback onClear,
  }) {
    controller.clear();
    ref.read(searchProvider.notifier).clearSearch();
    onClear();
  }
}
