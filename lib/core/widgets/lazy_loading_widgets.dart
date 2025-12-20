import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⚡ Lazy Loading Widget
/// تحميل البيانات عند الوصول لنهاية القائمة

class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final double loadMoreThreshold;

  const LazyLoadingList({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  late ScrollController _scrollController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_isDisposed) return;

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * widget.loadMoreThreshold;

    if (position.pixels >= threshold &&
        !widget.isLoading &&
        widget.hasMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.sp,
                  color: Theme.of(context).colorScheme.outline,
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد بيانات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          // Loading indicator at the end
          return widget.loadingWidget ??
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                  ),
                ),
              );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// ⚡ Infinite Scroll List Widget
/// قائمة بتحميل تلقائي لا نهائي

class InfiniteScrollList<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;

  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.separator,
    this.emptyWidget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LazyLoadingList<T>(
      items: items,
      isLoading: isLoading,
      hasMore: hasMore,
      onLoadMore: onLoadMore,
      emptyWidget: emptyWidget,
      itemBuilder: (context, item, index) {
        final itemWidget = Padding(
          padding: padding ?? EdgeInsets.symmetric(vertical: 4.h),
          child: itemBuilder(context, item, index),
        );

        if (separator != null && index < items.length - 1) {
          return Column(
            children: [
              itemWidget,
              separator!,
            ],
          );
        }

        return itemWidget;
      },
    );
  }
}

/// ⚡ Lazy Loaded Grid
/// شبكة بتحميل كسول

class LazyLoadedGrid<T> extends StatefulWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final Widget? emptyWidget;

  const LazyLoadedGrid({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.emptyWidget,
  });

  @override
  State<LazyLoadedGrid<T>> createState() => _LazyLoadedGridState<T>();
}

class _LazyLoadedGridState<T> extends State<LazyLoadedGrid<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * 0.8;

    if (position.pixels >= threshold &&
        !widget.isLoading &&
        widget.hasMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ??
          Center(
            child: Text(
              'لا توجد بيانات',
              style: Theme.of(context).textTheme.bodyLarge,
              textDirection: TextDirection.rtl,
            ),
          );
    }

    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing.w,
        mainAxisSpacing: widget.mainAxisSpacing.h,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
