import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/arabic_normalizer.dart';
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
import '../widgets/advanced_search_dialog.dart';
import '../services/export_service.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/swipeable_card_widget.dart';
import '../../../../core/widgets/quick_actions_menu.dart';
import '../../../../core/utils/feedback_utils.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/performance/widget_performance_analyzer.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../features/taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../features/taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../utils/taxonomy_value_resolver.dart';

/// 📋 Beneficiaries List Page V2 - Clean Architecture
class BeneficiariesListPageV2 extends ConsumerStatefulWidget {
  const BeneficiariesListPageV2({super.key});

  @override
  ConsumerState<BeneficiariesListPageV2> createState() => _BeneficiariesListPageV2State();
}

class _BeneficiariesListPageV2State extends ConsumerState<BeneficiariesListPageV2> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final Debouncer _searchDebouncer; // ✅ Debouncer for search
  late final Throttler _scrollThrottler; // ✅ Throttler for scroll
  bool _isSearching = false;
  String _lastCommittedSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchDebouncer = Debouncer();
    _scrollThrottler = Throttler(interval: const Duration(milliseconds: 100));
    _scrollController.addListener(_onScroll);

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appMonitoringProvider).logScreenView('BeneficiariesList');
      // Optional: Track widget build performance (lazy initialization)
      try {
        WidgetPerformanceAnalyzer.recordBuild('BeneficiariesListPage');
      } catch (_) {
        // Silently ignore if performance suite not initialized
      }
    });
  }

  @override
  void dispose() {
    // Log screen exit BEFORE disposing controllers
    try {
      ref.read(appMonitoringProvider).logScreenExit('BeneficiariesList');
    } catch (_) {
      // Ignore if ref is already disposed
    }

    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _searchDebouncer.dispose(); // ✅ Clean up Debouncer
    super.dispose();
  }

  void _onScroll() {
    _scrollThrottler(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        ref.read(beneficiariesListProvider.notifier).loadMore();
      }
    });
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
    final normalizedQuery = ArabicNormalizer.normalize(value);
    if (normalizedQuery == _lastCommittedSearchQuery) return;

    final isNumericQuery = int.tryParse(normalizedQuery) != null;
    final canSearchNow = normalizedQuery.isEmpty || isNumericQuery || normalizedQuery.length >= 2;

    if (!canSearchNow) {
      if (_isSearching && mounted) {
        setState(() => _isSearching = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isSearching = true);
    }

    _searchDebouncer(() async {
      final hadFocus = _searchFocusNode.hasFocus;
      _lastCommittedSearchQuery = normalizedQuery;
      ref.read(filtersProvider.notifier).setSearchQuery(normalizedQuery);
      await ref.read(beneficiariesListProvider.notifier).refresh(showLoading: false);
      if (mounted) {
        setState(() => _isSearching = false);
        if (hadFocus) {
          _searchFocusNode.requestFocus();
        }
      }
    });
  }

  void _onSearchSubmitted(String value) {
    final normalizedQuery = ArabicNormalizer.normalize(value);
    _lastCommittedSearchQuery = normalizedQuery;
    ref.read(filtersProvider.notifier).setSearchQuery(normalizedQuery);
    unawaited(ref.read(beneficiariesListProvider.notifier).refresh(showLoading: false));
  }

  Map<int, String> _buildTaxonomyLabelMap(Iterable<taxonomy_domain.Taxonomy> options) {
    final labels = <int, String>{};
    for (final taxonomy in options) {
      final value = TaxonomyValueResolver.resolveToInt(code: taxonomy.code, id: taxonomy.id);
      if (value == null) continue;
      labels.putIfAbsent(value, () => taxonomy.label);
    }
    return labels;
  }

  Map<int, Color> _buildTaxonomyColorMap(Iterable<taxonomy_domain.Taxonomy> options) {
    final colors = <int, Color>{};
    for (final taxonomy in options) {
      final value = TaxonomyValueResolver.resolveToInt(code: taxonomy.code, id: taxonomy.id);
      if (value == null) continue;
      final parsed = _parseTaxonomyColor(taxonomy.color);
      if (parsed != null) {
        colors.putIfAbsent(value, () => parsed);
      }
    }
    return colors;
  }

  Color? _parseTaxonomyColor(String? colorString) {
    if (colorString == null) {
      return null;
    }

    final trimmed = colorString.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      if (trimmed.startsWith('#')) {
        return Color(int.parse('0xFF${trimmed.substring(1)}'));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// 🗑️ Optimistic Delete with rollback
  Future<void> _handleDelete(int id) async {
    try {
      HapticFeedback.mediumImpact();
      await ref.read(beneficiariesListProvider.notifier).deleteBeneficiary(id);

      if (mounted) {
        HapticPatterns.success();
        EnhancedSnackbar.showSuccess(context, message: 'تم الحذف بنجاح');
      }
    } catch (e) {
      final message = _mapDeleteErrorMessage(e);
      if (mounted) {
        GlobalErrorHandler.handleError(
          context,
          AppError(
            type: ErrorType.database,
            message: message,
            originalError: e,
          ),
          onRetry: () => _handleDelete(id),
        );
      }
    }
  }

  String _mapDeleteErrorMessage(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('foreign key') || raw.contains('constraint failed')) {
      return 'تعذر الحذف لوجود بيانات مرتبطة بهذا المستفيد.';
    }
    return 'فشل الحذف، حاول مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficiariesListProvider);
    final filters = ref.watch(filtersProvider);
    final selection = ref.watch(selectionProvider);
    final taxonomyIndexAsync = ref.watch(bridgeTaxonomiesIndexOnceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final categoryLabelsById = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final sectionOptions = index[TaxonomyGroup.section] ?? const <taxonomy_domain.Taxonomy>[];
        final categoryOptions = index[TaxonomyGroup.category] ?? const <taxonomy_domain.Taxonomy>[];
        return _buildTaxonomyLabelMap([...categoryOptions, ...sectionOptions]);
      },
      orElse: () => const <int, String>{},
    );

    final categoryColorsById = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final sectionOptions = index[TaxonomyGroup.section] ?? const <taxonomy_domain.Taxonomy>[];
        final categoryOptions = index[TaxonomyGroup.category] ?? const <taxonomy_domain.Taxonomy>[];
        return _buildTaxonomyColorMap([...categoryOptions, ...sectionOptions]);
      },
      orElse: () => const <int, Color>{},
    );

    final governorateLabelsById = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final options = index[TaxonomyGroup.governorate] ?? const <taxonomy_domain.Taxonomy>[];
        return _buildTaxonomyLabelMap(options);
      },
      orElse: () => const <int, String>{},
    );

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
          // Statistics - Lazy loaded for better performance
          RepaintBoundary(
            child: FadeSlideTransition(
              duration: AppDurations.fast,
              child: GestureDetector(
                onTap: () {
                  unawaited(context.push('/statistics'));
                },
                child: const StatisticsDashboard(),
              ),
            ),
          ),

          // Search Bar
          RepaintBoundary(
            child: ScaleTransitionWidget(
              duration: AppDurations.fast,
              child: BeneficiariesSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                hintText: 'ابحث بالاسم، الرقم الوطني، أو رقم الملف...',
              ),
            ),
          ),

          // Search Progress Indicator
          if (_isSearching) const LinearProgressIndicator(minHeight: 2),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: _buildList(
              state,
              selection,
              rv,
              categoryLabelsById: categoryLabelsById,
              categoryColorsById: categoryColorsById,
              governorateLabelsById: governorateLabelsById,
            ),
          ),
        ],
      ),
      floatingActionButton: selection.isSelectionMode
          ? null
          : QuickActionsMenu(
              tooltip: 'إضافة',
              actions: [
                QuickAction(
                  label: 'إضافة مستفيد',
                  icon: Icons.person_add,
                  onTap: () async {
                    final result = await context.push('/beneficiaries/add');
                    if (result == true && mounted) {
                      ref.read(beneficiariesListProvider.notifier).clearCache();
                      await ref.read(beneficiariesListProvider.notifier).refresh();
                      if (context.mounted) {
                        VisualFeedback.showSuccess(
                          context,
                          'تمت الإضافة بنجاح',
                        );
                      }
                    }
                  },
                  backgroundColor: colorScheme.primary,
                ),
                QuickAction(
                  label: 'بحث متقدم',
                  icon: Icons.search,
                  onTap: () {
                    _showAdvancedSearch();
                  },
                  backgroundColor: colorScheme.secondary,
                ),
                QuickAction(
                  label: 'تصدير',
                  icon: Icons.download,
                  onTap: () {
                    _exportData();
                  },
                  backgroundColor: colorScheme.tertiary,
                ),
              ],
            ),
      bottomNavigationBar: const BulkActionsBar(),
    );
  }

  void _showAdvancedSearch() {
    HapticPatterns.medium();
    showDialog(
      context: context,
      builder: (context) => const AdvancedSearchDialog(),
    );
  }

  void _exportData() {
    HapticPatterns.medium();
    showDialog(
      context: context,
      builder: (context) => const ExportOptionsDialog(),
    );
  }

  /// ⚡ Build filter button with badge (memoized)
  Widget _buildFilterButton(FiltersState filters) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'فلاتر${filters.hasActiveFilters ? ' (${filters.activeFiltersCount} نشط)' : ''}',
      button: true,
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'فلاتر${filters.hasActiveFilters ? ' (${filters.activeFiltersCount} نشط)' : ''}',
            onPressed: () => _showFilters(context),
          ),
          if (filters.hasActiveFilters)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    '${filters.activeFiltersCount}',
                    style: TextStyle(
                      color: colorScheme.onError,
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

  Widget _buildList(
    state,
    selection,
    ResponsiveValues rv, {
    required Map<int, String> categoryLabelsById,
    required Map<int, Color> categoryColorsById,
    required Map<int, String> governorateLabelsById,
  }) {
    if (state.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SkeletonListItem(),
        ),
      );
    }

    if (state.error != null) {
      return RetryWidget(
        message: state.error ?? 'خطأ غير معروف',
        onRetry: () {
          ref.read(beneficiariesListProvider.notifier).refresh();
        },
      );
    }

    if (state.isEmpty) {
      final hasSearchOrFilters = ref.read(filtersProvider).hasSearchInput || ref.read(filtersProvider).hasActiveFilters;

      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: hasSearchOrFilters ? 'لا توجد نتائج مطابقة' : 'لا يوجد مستفيدين',
        message: hasSearchOrFilters ? 'جرّب تعديل كلمات البحث أو إزالة بعض الفلاتر' : 'ابدأ بإضافة مستفيد جديد',
        action: ElevatedButton.icon(
          onPressed: () {
            if (hasSearchOrFilters) {
              _searchController.clear();
              ref.read(filtersProvider.notifier).clearFilters();
              unawaited(ref.read(beneficiariesListProvider.notifier).refresh());
              return;
            }
            unawaited(context.push('/beneficiaries/add'));
          },
          icon: Icon(hasSearchOrFilters ? Icons.filter_alt_off : Icons.add),
          label: Text(hasSearchOrFilters ? 'مسح البحث والفلاتر' : 'إضافة مستفيد'),
        ),
      );
    }

    return PullToRefreshWrapper(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(beneficiariesListProvider.notifier).refresh();
        if (context.mounted) {
          HapticFeedback.lightImpact();
        }
      },
      child: rv.isTablet
          ? _buildGridView(
              state,
              selection,
              rv,
              categoryLabelsById: categoryLabelsById,
              categoryColorsById: categoryColorsById,
              governorateLabelsById: governorateLabelsById,
            )
          : _buildListView(
              state,
              selection,
              rv,
              categoryLabelsById: categoryLabelsById,
              categoryColorsById: categoryColorsById,
              governorateLabelsById: governorateLabelsById,
            ),
    );
  }

  /// بناء ListView للموبايل - OPTIMIZED
  Widget _buildListView(
    BeneficiariesListState state,
    SelectionState selection,
    ResponsiveValues rv, {
    required Map<int, String> categoryLabelsById,
    required Map<int, Color> categoryColorsById,
    required Map<int, String> governorateLabelsById,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // ⚡ Performance optimizations
      addAutomaticKeepAlives: false, // Don't keep offscreen items alive
      cacheExtent: 800, // Increased cache for smoother scrolling
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SmallLoadingIndicator(),
            ),
          );
        }

        final beneficiary = state.items[index];
        final isSelected = selection.isSelected(beneficiary.id);

        // ✨ Staggered slide animation with swipe actions
        return RepaintBoundary(
          child: AnimatedListItem(
            index: index,
            child: SwipeableCardWidget(
              enabled: !selection.isSelectionMode,
              onSwipeRight: () async {
                // تعديل
                HapticFeedback.lightImpact();
                await context.push('/beneficiaries/${beneficiary.id}/edit');
                if (mounted) {
                  unawaited(ref.read(beneficiariesListProvider.notifier).refresh());
                }
              },
              onSwipeLeft: () => _handleDelete(beneficiary.id),
              child: BeneficiaryCardV2(
                beneficiary: beneficiary,
                isSelectionMode: selection.isSelectionMode,
                isSelected: isSelected,
                categoryLabelsById: categoryLabelsById,
                categoryColorsById: categoryColorsById,
                governorateLabelsById: governorateLabelsById,
                onDelete: () => _handleDelete(beneficiary.id),
              ),
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
    ResponsiveValues rv, {
    required Map<int, String> categoryLabelsById,
    required Map<int, Color> categoryColorsById,
    required Map<int, String> governorateLabelsById,
  }) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // ⚡ Performance optimizations
      addAutomaticKeepAlives: false,
      cacheExtent: 800, // Increased cache for smoother scrolling
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
              child: SmallLoadingIndicator(),
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
              categoryLabelsById: categoryLabelsById,
              categoryColorsById: categoryColorsById,
              governorateLabelsById: governorateLabelsById,
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
