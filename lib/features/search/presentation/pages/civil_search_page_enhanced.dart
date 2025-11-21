import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/entities/civil_person.dart';
import '../../data/services/search_analytics.dart';
import '../providers/search_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_dependencies.dart';
import '../widgets/widgets.dart';

/// 🔍 Civil Search Page - Enhanced Clean Architecture
///
/// Features:
/// - Clean Architecture with Use Cases
/// - Responsive design with ResponsiveUtils
/// - ⚡ Performance optimizations for 5M records
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
  // ⚡ Removed AutomaticKeepAliveClientMixin for better performance
  // This was causing memory issues and lag across the app

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode(); // ⚡ Focus control for keyboard
  Timer? _debounceTimer;
  Timer? _scrollDebounceTimer; // ⚡ Debounce for scroll events

  // ⚡ Track if this is first search (for showing optimization message)
  bool _isFirstSearch = true;

  // 🎯 Autocomplete suggestions
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  // ⚡ Performance: Cache responsive values to avoid recalculating every frame
  ResponsiveValues? _cachedRv;
  Size? _lastScreenSize; // Track screen width AND height changes

  // ⚡ Cache gradient to avoid recreation
  static const _kAppBarGradient = LinearGradient(
    colors: [
      Color(0xFF1976D2),
      Color(0xFF42A5F5),
    ], // Colors.blue.shade700, shade500
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _scrollDebounceTimer?.cancel();

    // ⚡ Clean up cache when leaving page to free memory
    // This prevents GC lag when navigating to other pages
    try {
      ref.read(searchProvider.notifier).clearCache();
    } catch (e) {
      // Ignore if provider already disposed
    }

    super.dispose();
  }

  /// Auto-load more when scrolled to 80% of the list
  void _onScroll() {
    if (!mounted) return;

    // ⚡ Debounce scroll events to reduce provider reads
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final searchState = ref.read(searchProvider);
      if (searchState.isSearching || !searchState.hasMore) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.8; // Load at 80%

      if (currentScroll >= threshold) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final notifier = ref.read(searchProvider.notifier);

    if (query.trim().isEmpty) {
      notifier.clearSearch();
      // ⚡ Single setState with mounted check
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
      return;
    }

    notifier.setQuery(query);

    // Get autocomplete suggestions
    if (query.trim().length >= 2) {
      final suggestions = notifier.getSuggestions(query.trim());
      // ⚡ Single setState with mounted check
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      }
    } else {
      // ⚡ Single setState with mounted check
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    }

    // ⚡ SMART ADAPTIVE DEBOUNCE - optimized for different query types
    final trimmedQuery = query.trim();
    final queryLength = trimmedQuery.length;
    final isNumeric = RegExp(r'^\d+$').hasMatch(trimmedQuery);

    int debounceMs;

    if (isNumeric) {
      // National ID: Almost instant (50ms)
      debounceMs = 50;
    } else if (queryLength <= 2) {
      // Very short queries: Fast (100ms)
      debounceMs = 100;
    } else if (queryLength <= 4) {
      // Short queries: Medium (150ms)
      debounceMs = 150;
    } else {
      // Long queries: Normal (200ms)
      // Longer queries are more specific, less typing expected
      debounceMs = 200;
    }

    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      if (trimmedQuery.length >= 2) {
        notifier.search(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ Performance: Watch only what we need using select() for granular updates
    final searchState = ref.watch(searchProvider);
    final statsAsync = ref.watch(statisticsProvider);

    // ⚡ Cache responsive values - only recalculate when screen size changes
    final currentSize = MediaQuery.of(context).size;
    if (_cachedRv == null || _lastScreenSize != currentSize) {
      _cachedRv = ResponsiveUtils.getValues(context);
      _lastScreenSize = currentSize;
    }
    final rv = _cachedRv!;

    // Check if database not found error
    if (searchState.error != null &&
        searchState.error!.contains('قاعدة بيانات السجل المدني غير موجودة')) {
      return _buildDatabaseNotFoundScreen(rv);
    }

    return Scaffold(
      // ⚡ FAB for Export/Share - Mobile/Tablet optimized
      floatingActionButton: searchState.results.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _exportResults(searchState.results, rv),
              icon: const Icon(Icons.share, size: 20),
              label: Text(
                rv.isMobile ? 'مشاركة' : 'مشاركة النتائج',
                style: TextStyle(fontSize: rv.fontSize * 0.9),
              ),
              backgroundColor: Colors.blue.shade700,
              elevation: 4,
            )
          : null,
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          // ⚡ Pull to refresh functionality
          if (searchState.query.isNotEmpty) {
            await ref.read(searchProvider.notifier).search(reset: true);
          }
        },
        child: CustomScrollView(
          controller: _scrollController, // ⚡ Auto-scroll controller
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ), // ⚡ Smooth iOS-style bounce
          cacheExtent: 500, // ⚡ Cache 500px ahead for smooth scrolling
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

  /// Database not found screen with helpful guidance
  Widget _buildDatabaseNotFoundScreen(ResponsiveValues rv) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('السجل المدني'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: rv.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_download_outlined,
                size: 120,
                color: Colors.blue.shade300,
              ),
              SizedBox(height: rv.spacing * 2.5),
              Text(
                'قاعدة البيانات غير موجودة',
                style: TextStyle(
                  fontSize: rv.fontSize * 1.7,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: rv.spacing * 1.3),
              Text(
                'يجب تنزيل قاعدة بيانات السجل المدني أولاً\nللبحث عن المواطنين',
                style: TextStyle(
                  fontSize: rv.fontSize * 1.15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: rv.spacing * 4),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to download page
                  context.push('/civil-registry-download');
                },
                icon: const Icon(Icons.download, size: 24),
                label: const Text('تنزيل قاعدة البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: rv.spacing * 2.5,
                    vertical: rv.spacing * 1.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              SizedBox(height: rv.spacing * 1.3),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('العودة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: EdgeInsets.symmetric(
                    horizontal: rv.spacing * 2,
                    vertical: rv.spacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Modern App Bar with statistics and smooth animations
  Widget _buildModernAppBar(AsyncValue statsAsync, ResponsiveValues rv) {
    return statsAsync.when(
      data: (stats) => SliverAppBar(
        expandedHeight: rv.isMobile
            ? 200
            : (rv.isTablet ? 220 : 240), // ⚡ Increased to prevent overlap
        floating: false,
        pinned: true,
        elevation: 0,
        stretch: true, // ⚡ Smooth bounce effect
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets
              .zero, // ⚡ Remove title padding - we'll position manually
          centerTitle: false,
          background: Container(
            decoration: const BoxDecoration(
              gradient: _kAppBarGradient, // ⚡ Use cached gradient
            ),
            child: Stack(
              children: [
                // ⚡ Title at top with SafeArea
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: rv.spacing,
                        right: rv.spacing,
                        top: rv.spacing * 0.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'السجل المدني',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          // 🔧 Update Normalization Button (Debug)
                          IconButton(
                            icon: const Icon(
                              Icons.build_circle_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              context.push('/update-normalization');
                            },
                            tooltip: 'تحديث Normalization',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ⚡ Statistics at bottom with more spacing
                Positioned(
                  bottom: rv.spacing * 1.2,
                  left: rv.padding.left,
                  right: rv.padding.right,
                  child: RepaintBoundary(
                    child: Wrap(
                      spacing: rv.spacing * 0.6,
                      runSpacing: rv.spacing * 0.4,
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
      expandedHeight: rv.isMobile ? 160 : (rv.isTablet ? 180 : 200),
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
      expandedHeight: rv.isMobile ? 160 : (rv.isTablet ? 180 : 200),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          // ⚡ Removed BoxShadow for better performance
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ابحث عن مواطن',
              style: TextStyle(
                fontSize: rv.fontSize * 1.3,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: rv.spacing),
            RepaintBoundary(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode, // ⚡ Focus management
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                enableSuggestions: false, // ⚡ Disable OS suggestions
                autocorrect: false, // ⚡ Faster typing
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontSize: rv.fontSize,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText:
                      'ابحث بالاسم الكامل (مثال: محمد أحمد علي) أو جزء منه، أو الرقم الوطني...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: rv.fontSize,
                  ),
                  helperText: '💡 اكتب اسم كامل أو جزء من الرقم الوطني',
                  helperStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: rv.fontSize * 0.85,
                  ),
                  helperMaxLines: 2,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blue,
                    size: 24,
                  ),
                  suffixIcon: searchState.isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            // 🚀 LIVE SEARCH FEEDBACK
            if (searchState.query.isNotEmpty && !searchState.isSearching)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    // Result count
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: searchState.results.isEmpty
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
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
                          fontSize: rv.fontSize * 0.93,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Speed indicator
                    if (searchState.searchDurationMs != null) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getSpeedColor(
                            searchState.searchDurationMs!,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                                fontSize: rv.fontSize * 0.93,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              _getSpeedIcon(searchState.searchDurationMs!),
                              size: 16,
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
            // 🎯 FILTER BUTTONS ROW
            SizedBox(height: rv.spacing),
            _FilterButtonsRow(
              filter: searchState.filter,
              fontSize: rv.fontSize,
              onAgeFilterTap: _showAgeFilterBottomSheet,
              onGovernorateFilterTap: _showGovernorateFilterBottomSheet,
              onGenderFilterTap: _showGenderFilterBottomSheet,
            ),
            // 🎯 AUTOCOMPLETE SUGGESTIONS
            if (_showSuggestions && searchState.query.isNotEmpty)
              RepaintBoundary(
                child: AutocompleteSuggestions(
                  suggestions: _suggestions,
                  fontSize: rv.fontSize,
                  onSuggestionTap: (suggestion) {
                    _searchController.text = suggestion;
                    if (mounted) {
                      setState(() {
                        _showSuggestions = false;
                        _suggestions = [];
                      });
                    }
                    final notifier = ref.read(searchProvider.notifier);
                    notifier.setQuery(suggestion);
                    notifier.search(reset: true);
                  },
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
    // ⚡ Only watch when search is empty to avoid unnecessary rebuilds
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: rv.spacing * 1.3),
          child: _RecentSearchesList(
            searches: searches,
            spacing: rv.spacing,
            fontSize: rv.fontSize,
            onSearchTap: _performRecentSearch,
            onRemove: _removeRecentSearch,
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
          child: RepaintBoundary(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: rv.padding.left),
              padding: EdgeInsets.all(rv.spacing),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الفلاتر النشطة',
                          style: TextStyle(
                            fontSize: rv.fontSize,
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
                  // Show active filters
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (searchState.filter.hasAgeFilter)
                        _buildFilterChip(
                          Icons.calendar_today,
                          'العمر: ${searchState.filter.ageRangeText}',
                          () {
                            ref.read(searchProvider.notifier).clearAgeFilter();
                            if (searchState.query.isNotEmpty) {
                              ref
                                  .read(searchProvider.notifier)
                                  .search(reset: true);
                            }
                          },
                        ),
                      if (searchState.filter.governorate != null)
                        _buildFilterChip(
                          Icons.location_city,
                          'المحافظة: ${searchState.filter.governorate}',
                          () {
                            ref
                                .read(searchProvider.notifier)
                                .setGovernorate(null);
                            if (searchState.query.isNotEmpty) {
                              ref
                                  .read(searchProvider.notifier)
                                  .search(reset: true);
                            }
                          },
                          color: Colors.green,
                        ),
                      if (searchState.filter.gender != null)
                        _buildFilterChip(
                          searchState.filter.gender!.code == 1
                              ? Icons.male
                              : Icons.female,
                          'الجنس: ${searchState.filter.gender!.arabicLabel}',
                          () {
                            ref.read(searchProvider.notifier).setGender(null);
                            if (searchState.query.isNotEmpty) {
                              ref
                                  .read(searchProvider.notifier)
                                  .search(reset: true);
                            }
                          },
                          color: Colors.purple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  /// Results section with lazy loading and skeleton loader
  Widget _buildResultsSection(searchState, ResponsiveValues rv) {
    // Empty state - no query
    if (searchState.query.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search,
          title: 'ابحث عن مواطن',
          message: 'أدخل الاسم أو الرقم الوطني للبحث في السجل المدني',
          iconColor: Colors.blue,
        ),
      );
    }

    // ⚡ Skeleton loading - modern shimmer effect with optimization tip
    if (searchState.isSearching && searchState.results.isEmpty) {
      // Mark that we've started searching
      if (_isFirstSearch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isFirstSearch = false);
        });
      }

      return SliverPadding(
        padding: rv.padding,
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              // Show tip on first search
              Container(
                margin: EdgeInsets.only(bottom: rv.spacing * 2),
                padding: EdgeInsets.all(rv.spacing * 1.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'جاري البحث في 5 مليون سجل...\n${_isFirstSearch ? "قد يستغرق البحث الأول ثوانٍ لتحسين الأداء" : "البحث سريع الآن ⚡"}',
                        style: TextStyle(
                          fontSize: rv.fontSize * 0.9,
                          color: Colors.blue.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SkeletonLoader(itemCount: 5, spacing: rv.spacing),
            ],
          ),
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
            : _buildEnhancedEmptyState(searchState.query, rv),
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
              return _PerformanceIndicator(
                durationMs: searchState.searchDurationMs!,
                spacing: rv.spacing,
                fontSize: rv.fontSize,
              );
            }

            // Adjust index for results
            final resultIndex = searchState.searchDurationMs != null
                ? index - 1
                : index;

            // Results
            if (resultIndex >= 0 && resultIndex < searchState.results.length) {
              final person = searchState.results[resultIndex];
              // ⚡ No manual RepaintBoundary - delegate adds it automatically
              return ResultCard(
                key: ValueKey(person.nationalId),
                person: person,
                searchQuery: searchState.query, // 🎯 تمرير الـ query للتظليل
                onCopy: () => _copyToClipboard(person),
                onAddAsBeneficiary: () => _addAsBeneficiary(person),
              );
            }

            // Enhanced loading indicator at bottom with skeleton
            if (resultIndex == searchState.results.length &&
                searchState.hasMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: rv.spacing * 2),
                child: Center(
                  child: searchState.isSearching
                      ? const InlineSkeletonLoader()
                      : AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref.read(searchProvider.notifier).loadMore();
                            },
                            icon: const Icon(
                              Icons.arrow_downward_rounded,
                              size: 20,
                            ),
                            label: const Text('تحميل المزيد من النتائج'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: rv.spacing * 2,
                                vertical: rv.spacing * 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Colors.blue.shade300,
                                width: 2,
                              ),
                              foregroundColor: Colors.blue.shade700,
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
          addRepaintBoundaries:
              true, // ⚡ Isolate card repaints (ResultCard no longer wraps)
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
    try {
      _searchController.text = query;
      ref.read(searchProvider.notifier).setQuery(query);
      ref.read(searchProvider.notifier).search(reset: true);
    } catch (e) {
      // Handle search errors gracefully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في البحث: يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeRecentSearch(String query) async {
    final repository = ref.read(recentSearchesRepositoryProvider);
    await repository.removeSearch(query);
    ref.invalidate(recentSearchesProvider); // Refresh list
  }

  // 🎯 Age Filter handlers
  void _showAgeFilterBottomSheet() {
    final currentFilter = ref.read(searchProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AgeFilterBottomSheet(
        initialMinAge: currentFilter.minAge,
        initialMaxAge: currentFilter.maxAge,
        onApply: (minAge, maxAge) {
          // ⚡ Cache notifier to avoid multiple reads
          final notifier = ref.read(searchProvider.notifier);
          notifier.setAgeRange(minAge, maxAge);
          if (ref.read(searchProvider).query.isNotEmpty) {
            notifier.search(reset: true);
          }
        },
      ),
    );
  }

  // 🏛️ Governorate Filter handlers
  void _showGovernorateFilterBottomSheet() async {
    final currentFilter = ref.read(searchProvider).filter;

    // Get available governorates from statistics
    final statsAsync = ref.read(statisticsProvider);
    final governorates = statsAsync.when(
      data: (stats) => stats.governorates,
      loading: () => <String>[],
      error: (_, __) => <String>[],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GovernorateFilterBottomSheet(
        currentGovernorate: currentFilter.governorate,
        availableGovernorates: governorates,
        onApply: (governorate) {
          ref.read(searchProvider.notifier).setGovernorate(governorate);
          if (ref.read(searchProvider).query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
          }
        },
      ),
    );
  }

  // 👥 Gender Filter handlers
  void _showGenderFilterBottomSheet() {
    final currentFilter = ref.read(searchProvider).filter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenderFilterBottomSheet(
        currentGender: currentFilter.gender?.arabicLabel,
        onApply: (genderText) {
          // ⚡ Cache notifier to avoid multiple reads
          final notifier = ref.read(searchProvider.notifier);
          notifier.setGender(genderText);
          if (ref.read(searchProvider).query.isNotEmpty) {
            ref.read(searchProvider.notifier).search(reset: true);
          }
        },
      ),
    );
  }

  /// 🎨 Enhanced Empty State with helpful tips - Mobile optimized
  Widget _buildEnhancedEmptyState(String query, ResponsiveValues rv) {
    // ⚡ Smart suggestions based on query
    final smartSuggestions = _getSmartSuggestions(query);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(rv.spacing * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⚡ Adaptive icon size
            Icon(
              Icons.search_off,
              size: rv.isMobile ? 56 : 64,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: rv.spacing * 1.3),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: rv.fontSize * 1.15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            if (query.length > 20 && rv.isMobile)
              Padding(
                padding: EdgeInsets.only(top: rv.spacing * 0.5),
                child: Text(
                  '"${query.substring(0, 20)}..."',
                  style: TextStyle(
                    fontSize: rv.fontSize * 0.85,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(top: rv.spacing * 0.5),
                child: Text(
                  '"$query"',
                  style: TextStyle(
                    fontSize: rv.fontSize * 0.85,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // ⚡ Smart suggestions
            if (smartSuggestions.isNotEmpty) ...[
              SizedBox(height: rv.spacing * 1.5),
              Container(
                padding: EdgeInsets.all(rv.spacing),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'جرب البحث عن:',
                          style: TextStyle(
                            fontSize: rv.fontSize * 0.9,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: rv.spacing * 0.7),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: smartSuggestions.map((suggestion) {
                        return InkWell(
                          onTap: () {
                            _searchController.text = suggestion;
                            ref
                                .read(searchProvider.notifier)
                                .setQuery(suggestion);
                            ref
                                .read(searchProvider.notifier)
                                .search(reset: true);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade300),
                            ),
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: rv.fontSize * 0.85,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: rv.spacing * 1.2),
            Text(
              'نصائح للبحث:',
              style: TextStyle(
                fontSize: rv.fontSize * 0.9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: rv.spacing * 0.7),
            _buildSearchTip(
              Icons.abc,
              rv.isMobile
                  ? 'استخدم اسم جزئي'
                  : 'جرب كتابة اسم جزئي (مثال: "محمد" بدلاً من "محمد أحمد")',
              rv,
            ),
            SizedBox(height: rv.spacing * 0.4),
            _buildSearchTip(
              Icons.filter_alt_outlined,
              'تحقق من الفلاتر (المحافظة، الجنس)',
              rv,
            ),
            SizedBox(height: rv.spacing * 0.5),
            _buildSearchTip(Icons.spellcheck, 'تأكد من صحة الإملاء', rv),
            SizedBox(height: rv.spacing * 1.6),
            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('مسح البحث'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: rv.spacing * 2,
                  vertical: rv.spacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTip(IconData icon, String text, ResponsiveValues rv) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        SizedBox(width: rv.spacing * 0.7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: rv.fontSize * 0.93,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    IconData icon,
    String label,
    VoidCallback onRemove, {
    MaterialColor color = Colors.blue,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: color.shade700),
          ),
        ],
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addAsBeneficiary(CivilPerson person) {
    // 📊 تسجيل النقرة في Analytics
    SearchAnalytics.recordClick(ref.read(searchProvider).query);

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

  /// 📤 Export/Share results - Mobile/Tablet optimized with safety limits
  void _exportResults(List<CivilPerson> results, ResponsiveValues rv) {
    if (results.isEmpty) return;

    try {
      // ⚡ Safety limit: Max 50 results to prevent clipboard crash
      const maxResults = 50;
      final limitedResults = results.take(maxResults).toList();

      final text = StringBuffer();
      text.writeln('نتائج البحث في السجل المدني');
      text.writeln('================================');
      text.writeln('عدد النتائج: ${limitedResults.length}');
      if (results.length > maxResults) {
        text.writeln(
          '(تم تصدير أول $maxResults نتيجة من أصل ${results.length})',
        );
      }
      text.writeln('================================\n');

      for (var i = 0; i < limitedResults.length; i++) {
        final person = limitedResults[i];
        text.writeln('${i + 1}. ${person.fullName}');
        text.writeln('   الرقم الوطني: ${person.nationalId}');
        text.writeln('   الجنس: ${person.gender.arabicLabel}');
        if (person.governorate != null) {
          text.writeln('   المحافظة: ${person.governorate}');
        }
        text.writeln('');
      }

      // Copy to clipboard
      Clipboard.setData(ClipboardData(text: text.toString()));

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            results.length > maxResults
                ? 'تم نسخ أول $maxResults نتيجة من أصل ${results.length}'
                : 'تم نسخ ${limitedResults.length} نتيجة إلى الحافظة',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(rv.spacing),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      // Handle export errors gracefully
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('خطأ في تصدير النتائج. حاول تقليل عدد النتائج'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(rv.spacing),
        ),
      );
    }
  }

  /// 💡 Get smart search suggestions based on query
  List<String> _getSmartSuggestions(String query) {
    final suggestions = <String>[];
    final normalized = query.trim().toLowerCase();

    // If query is too short, suggest expanding
    if (normalized.length < 3) {
      return [];
    }

    // If query contains multiple words, suggest first word only
    final words = normalized.split(' ');
    if (words.length > 1) {
      suggestions.add(words.first);
      suggestions.add(words.last);
    }

    // If query looks like it might have typos, suggest variations
    if (normalized.contains('عبد ال')) {
      suggestions.add(normalized.replaceAll('عبد ال', 'عبدال'));
    }
    if (normalized.contains('ابو ')) {
      suggestions.add(normalized.replaceAll('ابو ', 'أبو'));
    }

    // Suggest removing 'ال' prefix
    if (normalized.startsWith('ال')) {
      suggestions.add(normalized.substring(2));
    }

    // Remove duplicates and return max 3 suggestions
    return suggestions.toSet().take(3).toList();
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
    // ⚡ Smaller, optimized design
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ⚡ Performance Indicator Widget - Optimized with const
class _PerformanceIndicator extends StatelessWidget {
  final int durationMs;
  final double spacing;
  final double fontSize;

  const _PerformanceIndicator({
    required this.durationMs,
    required this.spacing,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isFast = durationMs < 50;
    final isGood = durationMs < 100;

    final color = isFast
        ? Colors.green.shade700
        : (isGood ? Colors.orange.shade700 : Colors.red.shade700);

    final bgColor = isFast
        ? Colors.green.shade50
        : (isGood ? Colors.orange.shade50 : Colors.red.shade50);

    final borderColor = isFast
        ? Colors.green.shade300
        : (isGood ? Colors.orange.shade300 : Colors.red.shade300);

    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFast ? Icons.flash_on : (isGood ? Icons.speed : Icons.schedule),
              size: fontSize * 1.15,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              'سرعة البحث: ${durationMs}ms',
              style: TextStyle(
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w600,
                color: isFast
                    ? Colors.green.shade900
                    : (isGood ? Colors.orange.shade900 : Colors.red.shade900),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isFast ? '⚡ سريع جداً' : (isGood ? '✓ جيد' : '⚠️ بطيء'),
              style: TextStyle(
                fontSize: fontSize * 0.78,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⚡ Recent Searches List - Extracted for better performance
class _RecentSearchesList extends StatelessWidget {
  final List searches;
  final double spacing;
  final double fontSize;
  final Function(String) onSearchTap;
  final Function(String) onRemove;

  const _RecentSearchesList({
    required this.searches,
    required this.spacing,
    required this.fontSize,
    required this.onSearchTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عمليات البحث الأخيرة',
              style: TextStyle(
                fontSize: fontSize * 0.93,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.7),
        Wrap(
          spacing: spacing * 0.7,
          runSpacing: spacing * 0.7,
          children: searches.map((search) {
            return InkWell(
              onTap: () => onSearchTap(search.query),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      search.query,
                      style: TextStyle(
                        fontSize: fontSize * 0.93,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => onRemove(search.query),
                      child: Icon(
                        Icons.close,
                        size: 16,
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
    );
  }
}

/// 🎯 Filter Buttons Row Widget - Optimized for performance
class _FilterButtonsRow extends StatelessWidget {
  final dynamic filter;
  final double fontSize;
  final VoidCallback onAgeFilterTap;
  final VoidCallback onGovernorateFilterTap;
  final VoidCallback onGenderFilterTap;

  const _FilterButtonsRow({
    required this.filter,
    required this.fontSize,
    required this.onAgeFilterTap,
    required this.onGovernorateFilterTap,
    required this.onGenderFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Age Filter Button
        Expanded(
          child: _FilterButton(
            onPressed: onAgeFilterTap,
            icon: Icons.calendar_today,
            label: filter.hasAgeFilter ? filter.ageRangeText : 'العمر',
            isActive: filter.hasAgeFilter,
            activeColor: Colors.blue,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 8),
        // Governorate Filter Button
        Expanded(
          child: _FilterButton(
            onPressed: onGovernorateFilterTap,
            icon: Icons.location_city,
            label: filter.governorate ?? 'المحافظة',
            isActive: filter.governorate != null,
            activeColor: Colors.green,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 8),
        // Gender Filter Button
        Expanded(
          child: _FilterButton(
            onPressed: onGenderFilterTap,
            icon: filter.gender?.code == 1
                ? Icons.male
                : filter.gender?.code == 2
                ? Icons.female
                : Icons.people_alt,
            label: filter.gender?.arabicLabel ?? 'الجنس',
            isActive: filter.gender != null,
            activeColor: Colors.purple,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

/// 🎨 Individual Filter Button - Reusable
class _FilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isActive;
  final MaterialColor activeColor;
  final double fontSize;

  const _FilterButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact(); // ⚡ Tactile feedback
        onPressed();
      },
      icon: Icon(
        icon,
        size: 18,
        color: isActive ? activeColor.shade700 : Colors.grey.shade600,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize * 0.85,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        backgroundColor: isActive ? activeColor.shade50 : Colors.transparent,
        foregroundColor: isActive ? activeColor.shade700 : Colors.grey.shade700,
        side: BorderSide(
          color: isActive ? activeColor.shade300 : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
