import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/debouncer.dart';
import '../providers/infinite_scroll_provider.dart';

/// 📜 Optimized Infinite List with Smart Prefetching
class OptimizedInfiniteList extends ConsumerStatefulWidget {
  const OptimizedInfiniteList({super.key});

  @override
  ConsumerState<OptimizedInfiniteList> createState() =>
      _OptimizedInfiniteListState();
}

class _OptimizedInfiniteListState extends ConsumerState<OptimizedInfiniteList> {
  final ScrollController _scrollController = ScrollController();
  late final Throttler _scrollThrottler; // ✅ Throttler for scroll

  @override
  void initState() {
    super.initState();
    _scrollThrottler = Throttler(interval: const Duration(milliseconds: 100));
    _scrollController.addListener(_onScroll);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(infiniteScrollProvider.notifier).loadNextPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollThrottler(() {
      final notifier = ref.read(infiniteScrollProvider.notifier);
      final scrollPosition = _scrollController.position.pixels;
      final maxScrollExtent = _scrollController.position.maxScrollExtent;

      // Smart prefetching at 80% scroll
      if (notifier.shouldPrefetch(scrollPosition, maxScrollExtent)) {
        notifier.loadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(infiniteScrollProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة محسنة'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(infiniteScrollProvider.notifier).reset();
              ref.read(infiniteScrollProvider.notifier).loadNextPage();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تحميل',
          ),
        ],
      ),
      body: state.items.isEmpty && state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Main List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return RepaintBoundary(
                        child: _OptimizedListTile(
                          key: ValueKey(state.items[index]),
                          title: state.items[index],
                        ),
                      );
                    },
                    childCount: state.items.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false, // We handle it manually
                  ),
                ),

                // Loading Indicator
                if (state.isLoading && state.items.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                // End Message
                if (!state.hasMore && state.items.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'لا يوجد المزيد من البيانات',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                // Error Message
                if (state.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'خطأ: ${state.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: state.items.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

/// Optimized List Tile with minimal rebuilds
class _OptimizedListTile extends StatelessWidget {
  final String title;

  const _OptimizedListTile({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            title.split(' ').last,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(title),
        subtitle: Text('تفاصيل $title'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Handle item tap
        },
      ),
    );
  }
}
