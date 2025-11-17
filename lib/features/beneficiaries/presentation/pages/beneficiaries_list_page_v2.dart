import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/list/beneficiaries_list_provider.dart';
import '../providers/list/beneficiaries_list_state.dart';
import '../providers/list/filters_provider.dart';
import '../providers/list/selection_provider.dart';
import 'list_widgets/beneficiary_card_v2.dart';
import 'list_widgets/statistics_dashboard.dart';
import 'list_widgets/filters_bottom_sheet.dart';
import 'list_widgets/bulk_actions_bar.dart';
import '../../../../core/utils/responsive_utils.dart';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(beneficiariesListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(filtersProvider.notifier).setSearchQuery(value);
      ref.read(beneficiariesListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficiariesListProvider);
    final filters = ref.watch(filtersProvider);
    final selection = ref.watch(selectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: selection.isSelectionMode
            ? Text('${selection.selectedCount} محدد')
            : const Text('قائمة المستفيدين'),
        actions: selection.isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: 'تحديد الكل',
                  onPressed: () {
                    final allIds = state.items.map((b) => b.id).toList();
                    ref.read(selectionProvider.notifier).selectAll(allIds);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'إلغاء',
                  onPressed: () {
                    ref.read(selectionProvider.notifier).deselectAll();
                  },
                ),
              ]
            : [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'فلاتر',
                      onPressed: () => _showFilters(context),
                    ),
                    if (filters.hasActiveFilters)
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.h,
                          ),
                          child: Center(
                            child: Text(
                              '${filters.activeFiltersCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          // Statistics
          const StatisticsDashboard(),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم، الرقم الوطني، أو رقم الملف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filters.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          SizedBox(height: 16.h),

          // List
          Expanded(child: _buildList(state, selection)),
        ],
      ),
      floatingActionButton: selection.isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/beneficiaries/add'),
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة'),
            ),
      bottomNavigationBar: const BulkActionsBar(),
    );
  }

  Widget _buildList(state, selection) {
    if (state.isLoading) {
      return _buildLoadingShimmer();
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text('خطأ: ${state.error}'),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(beneficiariesListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد مستفيدين',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context.push('/beneficiaries/add'),
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة مستفيد'),
            ),
          ],
        ),
      );
    }

    final rv = ResponsiveUtils.getValues(context);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(beneficiariesListProvider.notifier).refresh();
      },
      child: rv.isTablet
          ? _buildGridView(state, selection, rv)
          : _buildListView(state, selection, rv),
    );
  }

  /// بناء ListView للموبايل
  Widget _buildListView(
    BeneficiariesListState state,
    SelectionState selection,
    ResponsiveValues rv,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.r),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        final beneficiary = state.items[index];
        final isSelected = selection.isSelected(beneficiary.id);

        return BeneficiaryCardV2(
          beneficiary: beneficiary,
          isSelectionMode: selection.isSelectionMode,
          isSelected: isSelected,
        );
      },
    );
  }

  /// بناء GridView للتابلت (عمودين)
  Widget _buildGridView(
    BeneficiariesListState state,
    SelectionState selection,
    ResponsiveValues rv,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5, // عرض أكبر من الطول للبطاقة
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

        return BeneficiaryCardV2(
          beneficiary: beneficiary,
          isSelectionMode: selection.isSelectionMode,
          isSelected: isSelected,
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16.r),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 1500),
        child: Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Container(
            height: 160.h,
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 150,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 60 + (i * 8).toDouble(),
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
