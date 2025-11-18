import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/list/beneficiaries_list_provider.dart';
import '../providers/list/beneficiaries_list_state.dart';
import '../providers/list/filters_provider.dart';
import '../providers/list/selection_provider.dart';
import 'list_widgets/beneficiary_card_v2.dart';
import 'list_widgets/statistics_dashboard.dart';
import 'list_widgets/filters_bottom_sheet.dart';
import 'list_widgets/bulk_actions_bar.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/beneficiaries_search_bar.dart';
import '../widgets/list_app_bar.dart';
import '../widgets/beneficiaries_loading_shimmer.dart';
import '../widgets/beneficiaries_states.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/micro_interactions.dart';

/// 📋 Beneficiaries List Page V2 - Clean Architecture
class BeneficiariesListPageV2 extends ConsumerStatefulWidget {
  const BeneficiariesListPageV2({super.key});

  @override
  ConsumerState<BeneficiariesListPageV2> createState() =>
      _BeneficiariesListPageV2State();
}

class _BeneficiariesListPageV2State
    extends ConsumerState<BeneficiariesListPageV2> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(beneficiariesListProvider.notifier).loadMore();
    }
  }

  /// 📐 Dynamic grid columns based on screen width
  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1400) return 4; // Desktop large
    if (width > 1024) return 3; // Desktop/Tablet landscape
    if (width > 600) return 2; // Tablet portrait
    return 1; // Mobile
  }

  /// 📐 Dynamic child aspect ratio
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1400) return 3.0; // More width for desktop
    if (width > 1024) return 2.8;
    if (width > 600) return 2.5;
    return 2.2; // Slightly taller for mobile
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    setState(() => _isSearching = true);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(filtersProvider.notifier).setSearchQuery(value);
      ref.read(beneficiariesListProvider.notifier).refresh();
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  /// 🗑️ Optimistic Delete with rollback
  Future<void> _handleDelete(int id) async {
    try {
      HapticFeedback.mediumImpact();
      await ref.read(beneficiariesListProvider.notifier).deleteBeneficiary(id);

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحذف بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحذف: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _handleDelete(id),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficiariesListProvider);
    final filters = ref.watch(filtersProvider);
    final selection = ref.watch(selectionProvider);

    // ⚡ Cache ResponsiveUtils to avoid rebuilds
    final rv = ResponsiveUtils.getValues(context);

    return Scaffold(
      appBar: ListAppBar(
        isSelectionMode: selection.isSelectionMode,
        selectedCount: selection.selectedCount,
        normalTitle: 'قائمة المستفيدين',
        normalActions: [_buildFilterButton(filters)],
        onSelectAll: () {
          final allIds = state.items.map((b) => b.id).toList();
          ref.read(selectionProvider.notifier).selectAll(allIds);
        },
        onDeselectAll: () {
          ref.read(selectionProvider.notifier).deselectAll();
        },
      ),
      body: Column(
        children: [
          // Statistics
          const StatisticsDashboard(),

          // Search Bar
          BeneficiariesSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: 'ابحث بالاسم، الرقم الوطني، أو رقم الملف...',
          ),

          // Search Progress Indicator
          if (_isSearching) const LinearProgressIndicator(minHeight: 2),

          const SizedBox(height: 16),

          // List
          Expanded(child: _buildList(state, selection, rv)),
        ],
      ),
      floatingActionButton: selection.isSelectionMode
          ? null
          : MicroInteractions.bounceButton(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final result = await context.push('/beneficiaries/add');
                if (result == true && mounted) {
                  ref.read(beneficiariesListProvider.notifier).clearCache();
                  await ref.read(beneficiariesListProvider.notifier).refresh();
                }
              },
              child: FloatingActionButton.extended(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final result = await context.push('/beneficiaries/add');
                  if (result == true && mounted) {
                    ref.read(beneficiariesListProvider.notifier).clearCache();
                    await ref
                        .read(beneficiariesListProvider.notifier)
                        .refresh();
                  }
                },
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة'),
              ),
            ),
      bottomNavigationBar: const BulkActionsBar(),
    );
  }

  /// ⚡ Build filter button with badge (memoized)
  Widget _buildFilterButton(FiltersState filters) {
    return Semantics(
      label:
          'فلاتر${filters.hasActiveFilters ? ' (${filters.activeFiltersCount} نشط)' : ''}',
      button: true,
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip:
                'فلاتر${filters.hasActiveFilters ? ' (${filters.activeFiltersCount} نشط)' : ''}',
            onPressed: () => _showFilters(context),
          ),
          if (filters.hasActiveFilters)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    '${filters.activeFiltersCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(state, selection, ResponsiveValues rv) {
    if (state.isLoading) {
      return const BeneficiariesLoadingShimmer();
    }

    if (state.error != null) {
      return BeneficiariesErrorState(
        error: state.error ?? 'خطأ غير معروف',
        onRetry: () {
          ref.read(beneficiariesListProvider.notifier).refresh();
        },
      );
    }

    if (state.isEmpty) {
      return const BeneficiariesEmptyState(actionText: 'إضافة مستفيد');
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(beneficiariesListProvider.notifier).refresh();
        if (context.mounted) {
          HapticFeedback.lightImpact();
        }
      },
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      strokeWidth: 3.0,
      child: rv.isTablet
          ? _buildGridView(state, selection, rv)
          : _buildListView(state, selection, rv),
    );
  }

  /// بناء ListView للموبايل - OPTIMIZED
  Widget _buildListView(
    BeneficiariesListState state,
    SelectionState selection,
    ResponsiveValues rv,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // ⚡ Performance optimizations
      addAutomaticKeepAlives: false, // Don't keep offscreen items alive
      addRepaintBoundaries: true, // Each item has repaint boundary
      cacheExtent: 500, // Pre-cache 500px ahead/behind
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final beneficiary = state.items[index];
        final isSelected = selection.isSelected(beneficiary.id);

        // ✨ Staggered slide animation
        return RepaintBoundary(
          child: AnimatedListItem(
            index: index,
            type: AnimationType.slide,
            child: BeneficiaryCardV2(
              beneficiary: beneficiary,
              isSelectionMode: selection.isSelectionMode,
              isSelected: isSelected,
              onDelete: () => _handleDelete(beneficiary.id),
            ),
          ),
        );
      },
    );
  }

  /// بناء GridView للتابلت - DYNAMIC COLUMNS
  Widget _buildGridView(
    BeneficiariesListState state,
    SelectionState selection,
    ResponsiveValues rv,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // ⚡ Performance optimizations
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 500,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridColumns(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final beneficiary = state.items[index];
        final isSelected = selection.isSelected(beneficiary.id);

        // ✨ Staggered scale animation
        return RepaintBoundary(
          child: AnimatedListItem(
            index: index,
            type: AnimationType.scale,
            delay: 25,
            duration: const Duration(milliseconds: 250),
            child: BeneficiaryCardV2(
              beneficiary: beneficiary,
              isSelectionMode: selection.isSelectionMode,
              isSelected: isSelected,
              onDelete: () => _handleDelete(beneficiary.id),
            ),
          ),
        );
      },
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FiltersBottomSheet(),
    );
  }
}
