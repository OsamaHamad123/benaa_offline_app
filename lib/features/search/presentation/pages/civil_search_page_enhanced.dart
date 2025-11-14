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
    extends ConsumerState<CivilSearchPageEnhanced> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final notifier = ref.read(searchProvider.notifier);

    if (query.trim().isEmpty) {
      notifier.clearSearch();
      return;
    }

    notifier.setQuery(query);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().length >= 2) {
        notifier.search(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final rv = ResponsiveUtils.getValues(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(statsAsync, rv),
          _buildSearchSection(searchState, rv),
          if (searchState.query.isNotEmpty)
            _buildFiltersSection(searchState, statsAsync, rv),
          _buildResultsSection(searchState, rv),
        ],
      ),
    );
  }

  /// Modern App Bar with statistics
  Widget _buildModernAppBar(AsyncValue statsAsync, ResponsiveValues rv) {
    return statsAsync.when(
      data: (stats) => SliverAppBar(
        expandedHeight: rv.isMobile ? 200.h : 220.h,
        floating: false,
        pinned: true,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 70.h),
          title: Text(
            'السجل المدني',
            style: TextStyle(
              fontSize: rv.fontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                  Colors.cyan.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Simplified background for better performance
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Removed Grid pattern for performance
                      // Simple overlay instead
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Logo/Icon
                      Positioned(
                        top: 60.h,
                        left: 20.w,
                        child: Icon(
                          Icons.account_balance,
                          size: 40.sp,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                // Statistics
                Positioned(
                  bottom: 16.h,
                  left: rv.padding.left,
                  right: rv.padding.right,
                  child: Wrap(
                    spacing: rv.spacing,
                    runSpacing: rv.spacing / 2,
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAppBar(ResponsiveValues rv) {
    return SliverAppBar(
      expandedHeight: rv.isMobile ? 180.h : 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('السجل المدني', style: TextStyle(fontSize: rv.fontSize)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 48),
          ),
        ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
              decoration: InputDecoration(
                hintText: 'الاسم أو الرقم الوطني',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: searchState.isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      )
                    : searchState.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
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
        child: EmptyState(
          icon: Icons.search_off,
          title: 'لا توجد نتائج',
          message: searchState.error ?? 'لم يتم العثور على نتائج مطابقة',
          iconColor: Colors.orange,
        ),
      );
    }

    // Results list
    return SliverPadding(
      padding: rv.padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Results
            if (index < searchState.results.length) {
              final person = searchState.results[index];
              return ResultCard(
                person: person,
                onCopy: () => _copyToClipboard(person),
                onAddAsBeneficiary: () => _addAsBeneficiary(person),
              );
            }

            // Load more button
            if (index == searchState.results.length && searchState.hasMore) {
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
              searchState.results.length + (searchState.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  /// Event Handlers - Optimized for performance

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
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

/// Statistics Chip Widget
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
