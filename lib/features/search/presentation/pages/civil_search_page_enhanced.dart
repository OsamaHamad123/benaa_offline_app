import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/civil_person.dart';
import '../providers/search_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_dependencies.dart';
import '../widgets/widgets.dart';

/// 🔍 Civil Search Page - Enhanced Clean Architecture
///
/// Features:
/// - Clean Architecture with Use Cases
/// - Responsive design with ResponsiveUtils
/// - Performance optimized (debounce, memo, lazy loading)
/// - Modern theme with gradients
/// - Complete data display
class CivilSearchPageEnhanced extends ConsumerStatefulWidget {
  const CivilSearchPageEnhanced({super.key});

  @override
  ConsumerState<CivilSearchPageEnhanced> createState() =>
      _CivilSearchPageEnhancedState();
}

class _CivilSearchPageEnhancedState
    extends ConsumerState<CivilSearchPageEnhanced>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // ⚡ Auto-scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Auto-load more when scrolled to 80% of the list
  void _onScroll() {
    if (!mounted) return;

    final searchState = ref.read(searchProvider);
    if (searchState.isSearching || !searchState.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load at 80%

    if (currentScroll >= threshold) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final notifier = ref.read(searchProvider.notifier);

    if (query.trim().isEmpty) {
      notifier.clearSearch();
      return;
    }

    notifier.setQuery(query);

    // 🚀 SMART DEBOUNCE: Fast for numbers, slower for names
    final isNumeric = RegExp(r'^\d+$').hasMatch(query.trim());
    final debounceMs = isNumeric ? 100 : 400; // 100ms for ID, 400ms for names

    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      if (query.trim().length >= 2) {
        notifier.search(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final searchState = ref.watch(searchProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final rv = ResponsiveUtils.getValues(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          // ⚡ Pull to refresh functionality
          if (searchState.query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
            await Future.delayed(const Duration(milliseconds: 500));
          }
        },
        child: CustomScrollView(
          controller: _scrollController, // ⚡ Auto-scroll controller
          physics:
              const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
          slivers: [
            _buildModernAppBar(statsAsync, rv),
            _buildSearchSection(searchState, rv),
            if (searchState.query.isNotEmpty)
              _buildFiltersSection(searchState, statsAsync, rv),
            _buildResultsSection(searchState, rv),
          ],
        ),
      ),
    );
  }

  /// Modern App Bar with statistics
  Widget _buildModernAppBar(AsyncValue statsAsync, ResponsiveValues rv) {
    return statsAsync.when(
      data: (stats) => SliverAppBar(
        expandedHeight: rv.isMobile ? 160.h : 180.h, // ⚡ Reduced to fix overlap
        floating: false,
        pinned: true,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 50.h,
          ), // ⚡ Adjusted
          title: Text(
            'السجل المدني',
            style: TextStyle(
              fontSize: rv.fontSize + 2, // ⚡ Reduced font size
              fontWeight: FontWeight.bold,
            ),
          ),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ⚡ Simplified for performance - removed nested gradients
                // Statistics
                Positioned(
                  bottom: 12.h, // ⚡ Reduced bottom padding
                  left: rv.padding.left,
                  right: rv.padding.right,
                  child: Wrap(
                    spacing: rv.spacing / 2, // ⚡ Reduced spacing
                    runSpacing: rv.spacing / 3,
                    children: [
                      _StatChip(
                        value: '${stats.totalPersons}',
                        label: 'مواطن',
                        icon: Icons.people,
                      ),
                      _StatChip(
                        value: '${stats.malesCount}',
                        label: 'ذكور',
                        icon: Icons.male,
                      ),
                      _StatChip(
                        value: '${stats.femalesCount}',
                        label: 'إناث',
                        icon: Icons.female,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => _buildLoadingAppBar(rv),
      error: (_, __) => _buildErrorAppBar(rv),
    );
  }

  Widget _buildLoadingAppBar(ResponsiveValues rv) {
    return SliverAppBar(
      expandedHeight: rv.isMobile ? 180.h : 200.h,
      floating: false,
      pinned: true,
      backgroundColor:
          Colors.grey.shade400, // ⚡ Simple color instead of gradient
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        centerTitle: true,
      ),
    );
  }

  Widget _buildErrorAppBar(ResponsiveValues rv) {
    return SliverAppBar(
      expandedHeight: rv.isMobile ? 180.h : 200.h,
      floating: false,
      pinned: true,
      backgroundColor:
          Colors.red.shade400, // ⚡ Simple color instead of gradient
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        centerTitle: true,
      ),
    );
  }

  /// Search section
  Widget _buildSearchSection(searchState, ResponsiveValues rv) {
    return SliverToBoxAdapter(
      child: Container(
        margin: rv.padding,
        padding: EdgeInsets.all(rv.spacing),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          // ⚡ Removed BoxShadow for better performance
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ابحث عن مواطن',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: rv.spacing),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'مثال: محمد أحمد أو 1234567890',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.sp,
                ),
                helperText: '💡 اكتب اسم كامل أو جزء من الرقم الوطني',
                helperStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: 24.w),
                suffixIcon: searchState.isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2.w),
                        ),
                      )
                    : searchState.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.5),
                ),
              ),
            ),
            // 🚀 LIVE SEARCH FEEDBACK
            if (searchState.query.isNotEmpty && !searchState.isSearching)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Row(
                  children: [
                    // Result count
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: searchState.results.isEmpty
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: searchState.results.isEmpty
                              ? Colors.orange.shade200
                              : Colors.blue.shade200,
                        ),
                      ),
                      child: Text(
                        '${searchState.results.length} نتيجة',
                        style: TextStyle(
                          color: searchState.results.isEmpty
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Speed indicator
                    if (searchState.searchDurationMs != null) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getSpeedColor(
                            searchState.searchDurationMs!,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _getSpeedColor(
                              searchState.searchDurationMs!,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${searchState.searchDurationMs}ms',
                              style: TextStyle(
                                color: _getSpeedColor(
                                  searchState.searchDurationMs!,
                                ),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              _getSpeedIcon(searchState.searchDurationMs!),
                              size: 16.w,
                              color: _getSpeedColor(
                                searchState.searchDurationMs!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            // 🔍 RECENT SEARCHES (only when search bar is empty)
            if (searchState.query.isEmpty) _buildRecentSearches(rv),
          ],
        ),
      ),
    );
  }

  /// Recent searches section
  Widget _buildRecentSearches(ResponsiveValues rv) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عمليات البحث الأخيرة',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: Text(
                      'مسح الكل',
                      style: TextStyle(fontSize: 12.sp, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: searches.map((search) {
                  return InkWell(
                    onTap: () => _performRecentSearch(search.query),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 16.w,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            search.query,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          InkWell(
                            onTap: () => _removeRecentSearch(search.query),
                            child: Icon(
                              Icons.close,
                              size: 16.w,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Filters section
  Widget _buildFiltersSection(
    searchState,
    AsyncValue statsAsync,
    ResponsiveValues rv,
  ) {
    return statsAsync.when(
      data: (stats) {
        if (!searchState.filter.hasActiveFilters) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: rv.padding.left),
            padding: EdgeInsets.all(rv.spacing),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  color: Colors.amber.shade700,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'الفلاتر النشطة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('إزالة الكل'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  /// Results section with lazy loading
  Widget _buildResultsSection(searchState, ResponsiveValues rv) {
    // Empty state - no query
    if (searchState.query.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search,
          title: 'ابحث عن مواطن',
          message: 'أدخل الاسم أو الرقم الوطني للبحث في السجل المدني',
          iconColor: Colors.blue,
        ),
      );
    }

    // Empty state - no results
    if (searchState.isEmpty && !searchState.isSearching) {
      return SliverFillRemaining(
        child: searchState.error != null
            ? EmptyState(
                icon: Icons.error_outline,
                title: 'حدث خطأ',
                message: searchState.error!,
                iconColor: Colors.red,
                action: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(searchProvider.notifier).search(reset: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              )
            : _buildEnhancedEmptyState(searchState.query),
      );
    }

    // Results list
    return SliverPadding(
      padding: rv.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // ⚡ Performance indicator at the top
            if (index == 0 && searchState.searchDurationMs != null) {
              return Padding(
                padding: EdgeInsets.only(bottom: rv.spacing),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: searchState.searchDurationMs! < 50
                        ? Colors.green.shade50
                        : searchState.searchDurationMs! < 100
                        ? Colors.orange.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: searchState.searchDurationMs! < 50
                          ? Colors.green.shade300
                          : searchState.searchDurationMs! < 100
                          ? Colors.orange.shade300
                          : Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        searchState.searchDurationMs! < 50
                            ? Icons.flash_on
                            : searchState.searchDurationMs! < 100
                            ? Icons.speed
                            : Icons.schedule,
                        size: 16.sp,
                        color: searchState.searchDurationMs! < 50
                            ? Colors.green.shade700
                            : searchState.searchDurationMs! < 100
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'سرعة البحث: ${searchState.searchDurationMs}ms',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: searchState.searchDurationMs! < 50
                              ? Colors.green.shade900
                              : searchState.searchDurationMs! < 100
                              ? Colors.orange.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        searchState.searchDurationMs! < 50
                            ? '⚡ سريع جداً'
                            : searchState.searchDurationMs! < 100
                            ? '✓ جيد'
                            : '⚠️ بطيء',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Adjust index for results
            final resultIndex = searchState.searchDurationMs != null
                ? index - 1
                : index;

            // Results
            if (resultIndex >= 0 && resultIndex < searchState.results.length) {
              final person = searchState.results[resultIndex];
              return RepaintBoundary(
                key: ValueKey(
                  'repaint_${person.nationalId}',
                ), // ⚡ Unique key for reuse
                // ⚡ Performance: Isolate repaints
                child: ResultCard(
                  key: ValueKey(
                    person.nationalId,
                  ), // ⚡ Unique key for each card
                  person: person,
                  onCopy: () => _copyToClipboard(person),
                  onAddAsBeneficiary: () => _addAsBeneficiary(person),
                ),
              );
            }

            // Load more button
            if (resultIndex == searchState.results.length &&
                searchState.hasMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: rv.spacing),
                child: Center(
                  child: searchState.isSearching
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: () {
                            ref.read(searchProvider.notifier).loadMore();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحميل المزيد'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
          childCount:
              searchState.results.length +
              (searchState.hasMore ? 1 : 0) +
              (searchState.searchDurationMs != null
                  ? 1
                  : 0), // ⚡ +1 for performance indicator
          // ⚡ Performance optimizations
          addAutomaticKeepAlives:
              false, // Don't keep state of scrolled-away items
          addRepaintBoundaries: true, // Each child paints independently
          addSemanticIndexes:
              false, // Reduce overhead for assistive technologies
        ),
      ),
    );
  }

  /// Event Handlers - Optimized for performance

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
  }

  // 🎨 Speed indicator helpers
  Color _getSpeedColor(int ms) {
    if (ms < 100) return Colors.green.shade600; // سريع جداً
    if (ms < 300) return Colors.orange.shade600; // مقبول
    return Colors.red.shade600; // بطيء
  }

  IconData _getSpeedIcon(int ms) {
    if (ms < 100) return Icons.bolt; // برق
    if (ms < 300) return Icons.schedule; // ساعة
    return Icons.hourglass_bottom; // ساعة رملية
  }

  // 🔍 Recent searches handlers
  void _performRecentSearch(String query) {
    _searchController.text = query;
    ref.read(searchProvider.notifier).setQuery(query);
    ref.read(searchProvider.notifier).search(reset: true);
  }

  Future<void> _removeRecentSearch(String query) async {
    final repository = ref.read(recentSearchesRepositoryProvider);
    await repository.removeSearch(query);
    ref.invalidate(recentSearchesProvider); // Refresh list
  }

  Future<void> _clearRecentSearches() async {
    final useCase = ref.read(clearRecentSearchesUseCaseProvider);
    await useCase();
    ref.invalidate(recentSearchesProvider); // Refresh list
  }

  /// 🎨 Enhanced Empty State with helpful tips
  Widget _buildEnhancedEmptyState(String query) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64.w, color: Colors.grey.shade300),
            SizedBox(height: 20.h),
            Text(
              'لا توجد نتائج لـ "$query"',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'نصائح للبحث:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 10.h),
            _buildSearchTip(
              Icons.abc,
              'جرب كتابة اسم جزئي (مثال: "محمد" بدلاً من "محمد أحمد")',
            ),
            SizedBox(height: 6.h),
            _buildSearchTip(
              Icons.filter_alt_outlined,
              'تحقق من الفلاتر (المحافظة، الجنس)',
            ),
            SizedBox(height: 6.h),
            _buildSearchTip(Icons.spellcheck, 'تأكد من صحة الإملاء'),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear_all, size: 20.w),
              label: const Text('مسح البحث'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: Colors.blue.shade600),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  void _onClearFilters() {
    final notifier = ref.read(searchProvider.notifier);
    notifier.clearFilters();
    notifier.search(reset: true);
  }

  void _copyToClipboard(CivilPerson person) {
    final text =
        '''
الاسم الكامل: ${person.fullName}
الرقم الوطني: ${person.nationalId}
الجنس: ${person.gender.arabicLabel}
${person.motherName != null ? 'اسم الأم: ${person.motherName}\n' : ''}${person.birthDate != null ? 'تاريخ الميلاد: ${person.birthDate}\n' : ''}${person.city != null ? 'المدينة: ${person.city}\n' : ''}${person.governorate != null ? 'المحافظة: ${person.governorate}\n' : ''}''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم النسخ إلى الحافظة ✓'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addAsBeneficiary(CivilPerson person) {
    context.push(
      '/beneficiaries/add',
      extra: {
        'name': person.fullName,
        'nationalId': person.nationalId,
        'gender': person.gender.arabicLabel,
        'motherName': person.motherName,
        'birthDate': person.birthDate,
        'city': person.city,
        'governorate': person.governorate,
      },
    );
  }
}

/// Statistics Chip Widget - const optimized
class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
