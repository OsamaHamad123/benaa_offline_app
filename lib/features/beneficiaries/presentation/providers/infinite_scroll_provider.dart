import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📜 Infinite Scroll Provider for Beneficiaries List
class InfiniteScrollNotifier extends StateNotifier<InfiniteScrollState> {
  InfiniteScrollNotifier() : super(InfiniteScrollState.initial());

  static const int _pageSize = 20;
  static const double _prefetchThreshold = 0.8; // Load at 80% scroll

  /// Load next page of data
  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call - replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));

      final newItems = List.generate(
        _pageSize,
        (index) => 'Item ${state.items.length + index + 1}',
      );

      final hasMore = state.currentPage < 10; // Mock pagination limit

      state = state.copyWith(
        items: [...state.items, ...newItems],
        currentPage: state.currentPage + 1,
        isLoading: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Reset pagination
  void reset() {
    state = InfiniteScrollState.initial();
  }

  /// Check if should prefetch (80% scroll threshold)
  bool shouldPrefetch(double scrollPosition, double maxScrollExtent) {
    if (maxScrollExtent == 0) return false;
    final scrollPercentage = scrollPosition / maxScrollExtent;
    return scrollPercentage >= _prefetchThreshold;
  }
}

/// 📊 Infinite Scroll State
class InfiniteScrollState {
  final List<String> items;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const InfiniteScrollState({
    required this.items,
    required this.currentPage,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  factory InfiniteScrollState.initial() {
    return const InfiniteScrollState(
      items: [],
      currentPage: 0,
      isLoading: false,
      hasMore: true,
    );
  }

  InfiniteScrollState copyWith({
    List<String>? items,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return InfiniteScrollState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

/// Provider instance
final infiniteScrollProvider =
    StateNotifierProvider<InfiniteScrollNotifier, InfiniteScrollState>(
      (ref) => InfiniteScrollNotifier(),
    );
