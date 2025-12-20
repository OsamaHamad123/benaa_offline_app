import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_constants.dart';
import '../../domain/entities/civil_person.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/usecases/search_by_name.dart';
import '../../domain/usecases/search_by_national_id.dart';
import '../../data/services/search_analytics.dart';
import '../../data/services/search_performance_analytics.dart';
import '../../data/datasources/text_normalization_service.dart';
import 'search_dependencies.dart';

/// 🔍 Search State - Presentation Layer
class SearchState {
  final String query;
  final List<CivilPerson> results;
  final bool isSearching;
  final bool hasMore;
  final int currentPage;
  final SearchFilter filter;
  final String? error;
  final int totalResults;
  final int? searchDurationMs; // ⚡ Performance tracking

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.filter = const SearchFilter(),
    this.error,
    this.totalResults = 0,
    this.searchDurationMs,
  });

  SearchState copyWith({
    String? query,
    List<CivilPerson>? results,
    bool? isSearching,
    bool? hasMore,
    int? currentPage,
    SearchFilter? filter,
    String? error,
    int? totalResults,
    int? searchDurationMs,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter,
      error: error,
      totalResults: totalResults ?? this.totalResults,
      searchDurationMs: searchDurationMs ?? this.searchDurationMs,
    );
  }

  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
}

/// 🎯 Search State Notifier - Clean Architecture with Performance Optimizations
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchByNationalIdUseCase searchByNationalIdUseCase;
  final SearchByNameUseCase searchByNameUseCase;
  final Ref _ref; // For accessing other providers

  // ⚡ Optimized debouncing for performance
  // Note: Page-level adaptive debounce (50-200ms) happens first
  // This is a fallback for programmatic searches
  Timer? _debounceTimer;
  static final Duration _debounceDuration = AppConstants.searchDebounceDuration;

  // 🚫 Request cancellation token
  int _requestId = 0;

  // 💾 Memory-aware cache for instant results (optimized for mobile/tablet)
  final Map<String, List<CivilPerson>> _cache = {};
  static const int _maxCacheSize = AppConstants.maxCachedSearches;
  static const int _maxCacheMemoryBytes =
      AppConstants.searchCacheMaxMemoryBytes;
  int _currentCacheMemoryBytes = 0;

  // 🎯 Cache access tracking for LRU eviction
  final Map<String, DateTime> _cacheAccess = {};

  // 🎯 Autocomplete suggestions cache (lightweight - names only)
  final Map<String, List<String>> _suggestionsCache = {};
  static const int _maxSuggestions = AppConstants.maxSuggestions;

  /// Calculate accurate size of a CivilPerson object in memory
  int _calculatePersonSize(CivilPerson person) {
    // UTF-16 encoding: 2 bytes per character
    int size = 0;

    // Required fields
    size += person.nationalId.length * 2; // ~24 bytes
    size += person.fullName.length * 2; // ~60-100 bytes
    size += person.firstName.length * 2;
    size += person.fatherName.length * 2;
    size += person.grandFatherName.length * 2;
    size += person.familyName.length * 2;

    // Optional fields
    if (person.motherName != null) size += person.motherName!.length * 2;
    if (person.birthDate != null) size += person.birthDate!.length * 2;
    if (person.city != null) size += person.city!.length * 2;
    if (person.governorate != null) size += person.governorate!.length * 2;

    // Gender enum + object overhead
    size += 100; // ~100 bytes overhead (object pointers, padding, etc.)

    return size;
  }

  SearchNotifier({
    required this.searchByNationalIdUseCase,
    required this.searchByNameUseCase,
    required Ref ref,
  })  : _ref = ref,
        super(const SearchState());

  // ⚡ Optimized for 5M records: Page size from AppConstants
  static const int _pageSize = AppConstants.searchPageSize;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cache.clear();
    _cacheAccess.clear();
    _suggestionsCache.clear();
    super.dispose();
  }

  /// ⚡ Smart Cache Management - LRU eviction for mobile/tablet
  void _manageCacheSize() {
    // Check if cache is too large (memory or count)
    if (_cache.length <= _maxCacheSize &&
        _currentCacheMemoryBytes <= _maxCacheMemoryBytes) {
      return;
    }

    // ⚡ Sort by access time (oldest first)
    final sortedEntries = _cacheAccess.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Calculate how many entries to remove (25% of cache)
    final entriesToRemove = (_cache.length * 0.25).ceil();
    final keysToRemove =
        sortedEntries.take(entriesToRemove).map((e) => e.key).toList();

    // Remove old entries and recalculate memory
    var freedMemory = 0;
    for (final key in keysToRemove) {
      final results = _cache.remove(key);
      _cacheAccess.remove(key);

      if (results != null) {
        for (final person in results) {
          freedMemory += _calculatePersonSize(person);
        }
      }
    }

    _currentCacheMemoryBytes -= freedMemory;

    // Also clean suggestions cache
    if (_suggestionsCache.length > _maxCacheSize) {
      final suggestionKeys = _suggestionsCache.keys.toList();
      final toRemove = suggestionKeys.take(_suggestionsCache.length ~/ 2);
      for (final key in toRemove) {
        _suggestionsCache.remove(key);
      }
    }
  }

  /// Update query with instant feedback
  void setQuery(String query) {
    state = state.copyWith(query: query);

    // Instant clear if query is empty
    if (query.trim().isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(
        results: [],
        currentPage: 0,
        totalResults: 0,
        error: null,
      );
    }
  }

  /// Update filter - Governorate
  void setGovernorate(String? governorate) {
    final newFilter = governorate == null || governorate.isEmpty
        ? state.filter.clearGovernorate()
        : state.filter.copyWith(governorate: governorate);

    state = state.copyWith(filter: newFilter, currentPage: 0, results: []);
    _cache.clear(); // Clear cache when filter changes
  }

  /// Update filter - Gender
  void setGender(String? genderText) {
    Gender? gender;
    if (genderText == 'ذكر') {
      gender = Gender.male;
    } else if (genderText == 'أنثى') {
      gender = Gender.female;
    }

    final newFilter = gender == null
        ? state.filter.clearGender()
        : state.filter.copyWith(gender: gender);

    state = state.copyWith(filter: newFilter, currentPage: 0, results: []);
    _cache.clear(); // Clear cache when filter changes
  }

  /// Update filter - Age Range
  void setAgeRange(int? minAge, int? maxAge) {
    final newFilter = state.filter.copyWith(minAge: minAge, maxAge: maxAge);
    state = state.copyWith(filter: newFilter, currentPage: 0, results: []);
    _cache.clear(); // Clear cache when filter changes
  }

  /// Clear age filter
  void clearAgeFilter() {
    final newFilter = state.filter.clearAge();
    state = state.copyWith(filter: newFilter, currentPage: 0, results: []);
    _cache.clear();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      filter: const SearchFilter(),
      currentPage: 0,
      results: [],
    );
    _cache.clear();
  }

  /// Clear search
  void clearSearch() {
    _debounceTimer?.cancel();
    _cache.clear();
    state = const SearchState();
  }

  /// ⚡ Clear cache only (for memory cleanup when leaving page)
  void clearCache() {
    _cache.clear();
    _cacheAccess.clear();
    _suggestionsCache.clear();
    _currentCacheMemoryBytes = 0;
  }

  /// ⚡ Search with aggressive debouncing (400ms) - ELIMINATES LAG
  void searchDebounced({bool reset = true}) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Instant clear for empty query
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], currentPage: 0, error: null);
      return;
    }

    // Check cache first for instant results
    final cacheKey = _getCacheKey(state.query, state.filter);
    if (_cache.containsKey(cacheKey)) {
      state = state.copyWith(
        results: _cache[cacheKey]!,
        currentPage: 1,
        hasMore: false,
        isSearching: false,
        error: null,
      );
      return;
    }

    // Show searching state immediately
    state = state.copyWith(isSearching: true, error: null);

    // Debounce the actual search
    _debounceTimer = Timer(_debounceDuration, () {
      search(reset: reset);
    });
  }

  /// Perform search (unified method) with request cancellation
  Future<void> search({bool reset = false}) async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], currentPage: 0);
      return;
    }

    if (state.isSearching && !reset) return;

    // ⚡ Start timing
    final stopwatch = Stopwatch()..start();

    // Increment request ID to cancel previous requests
    final currentRequestId = ++_requestId;

    // Check cache first
    final cacheKey = _getCacheKey(state.query, state.filter);
    final fromCache = _cache.containsKey(cacheKey);

    if (fromCache && reset) {
      // ⚡ Update cache access time (LRU)
      _cacheAccess[cacheKey] = DateTime.now();

      stopwatch.stop();

      // 📊 Record analytics - cache hit
      SearchPerformanceAnalytics().recordSearch(
        query: state.query,
        durationMs: stopwatch.elapsedMilliseconds,
        resultsCount: _cache[cacheKey]!.length,
        fromCache: true,
      );

      state = state.copyWith(
        results: _cache[cacheKey]!,
        currentPage: 1,
        hasMore: false,
        isSearching: false,
        error: null,
        searchDurationMs: stopwatch.elapsedMilliseconds, // ⚡ Track duration
      );
      return;
    }

    // ⚡ Smart cache management - clean if needed
    _manageCacheSize();

    // Reset or continue pagination
    if (reset) {
      state = state.copyWith(
        isSearching: true,
        results: [],
        currentPage: 0,
        hasMore: false,
        error: null,
        totalResults: 0,
        searchDurationMs: null,
      );
    } else {
      state = state.copyWith(isSearching: true, error: null);
    }

    try {
      // Determine if this is a national ID search
      final isNationalId = SearchByNationalIdUseCase.isNationalIdFormat(
        state.query,
      );

      if (isNationalId) {
        // Search by national ID
        await _searchByNationalId(reset, currentRequestId, stopwatch);
      } else {
        // Search by name
        await _searchByName(reset, currentRequestId, stopwatch);
      }
    } catch (e) {
      // Only update state if this is still the current request
      if (currentRequestId != _requestId) return;

      stopwatch.stop();
      // Check if it's a database not found error
      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage = '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }
      state = state.copyWith(
        isSearching: false,
        error: errorMessage,
        searchDurationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// Search by national ID with cancellation
  Future<void> _searchByNationalId(
    bool reset,
    int requestId,
    Stopwatch stopwatch,
  ) async {
    try {
      final person = await searchByNationalIdUseCase(state.query);

      // Check if request is still valid
      if (requestId != _requestId) return;

      stopwatch.stop();

      if (person != null) {
        // 📊 Record analytics - successful national ID search
        SearchPerformanceAnalytics().recordSearch(
          query: state.query,
          durationMs: stopwatch.elapsedMilliseconds,
          resultsCount: 1,
          fromCache: false,
        );

        state = state.copyWith(
          results: [person],
          hasMore: false,
          currentPage: 1,
          isSearching: false,
          totalResults: 1,
          searchDurationMs: stopwatch.elapsedMilliseconds, // ⚡ Track duration
        );
      } else {
        // 📊 Record analytics - no results
        SearchPerformanceAnalytics().recordSearch(
          query: state.query,
          durationMs: stopwatch.elapsedMilliseconds,
          resultsCount: 0,
          fromCache: false,
        );

        state = state.copyWith(
          results: [],
          hasMore: false,
          currentPage: 0,
          isSearching: false,
          error: 'لم يتم العثور على الرقم الوطني',
          totalResults: 0,
          searchDurationMs: stopwatch.elapsedMilliseconds,
        );
      }
    } catch (e) {
      if (requestId != _requestId) return;

      stopwatch.stop();
      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage = '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }

      // 📊 Record error in analytics
      SearchPerformanceAnalytics().recordError(
        query: state.query,
        error: errorMessage,
      );

      state = state.copyWith(
        isSearching: false,
        error: errorMessage,
        searchDurationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// Search by name with filters and caching
  Future<void> _searchByName(
    bool reset,
    int requestId,
    Stopwatch stopwatch,
  ) async {
    try {
      final page = reset ? 1 : state.currentPage + 1;

      // ⚡ Use SearchByNameUseCase - sqflite already uses native threads
      final result = await searchByNameUseCase(
        query: state.query,
        filter: state.filter,
        page: page,
        pageSize: _pageSize,
      );

      // Check if request is still valid
      if (requestId != _requestId) return;

      stopwatch.stop();

      // Cache results for first page
      if (reset && result.persons.isNotEmpty) {
        final cacheKey = _getCacheKey(state.query, state.filter);
        _addToCache(cacheKey, result.persons);
      }

      if (reset) {
        // 📊 Record performance analytics
        SearchPerformanceAnalytics().recordSearch(
          query: state.query,
          durationMs: stopwatch.elapsedMilliseconds,
          resultsCount: result.persons.length,
          fromCache: false,
        );

        state = state.copyWith(
          results: result.persons,
          hasMore: result.hasMore,
          currentPage: page,
          isSearching: false,
          totalResults: result.totalResults,
          searchDurationMs: stopwatch.elapsedMilliseconds, // ⚡ Track duration
        );

        // 📊 Record search analytics
        SearchAnalytics.recordSearch(
          query: state.query,
          durationMs: stopwatch.elapsedMilliseconds,
          resultsCount: result.persons.length,
        );

        // 🔍 Save to recent searches (Clean Architecture!)
        if (result.persons.isNotEmpty) {
          _saveToRecentSearches(state.query, result.persons.length);
        }
      } else {
        state = state.copyWith(
          results: [...state.results, ...result.persons],
          hasMore: result.hasMore,
          currentPage: page,
          isSearching: false,
          totalResults: result.totalResults,
        );
      }

      if (state.results.isEmpty && reset) {
        state = state.copyWith(
          error: 'لم يتم العثور على نتائج',
          searchDurationMs: stopwatch.elapsedMilliseconds,
        );
      }
    } catch (e) {
      if (requestId != _requestId) return;

      stopwatch.stop();
      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage = '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }
      state = state.copyWith(
        isSearching: false,
        error: errorMessage,
        searchDurationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  // ============================================================================
  // CACHE HELPERS
  // ============================================================================

  String _getCacheKey(String query, SearchFilter filter) {
    return '${query}_${filter.governorate}_${filter.gender}';
  }

  void _addToCache(String key, List<CivilPerson> results) {
    // Memory-aware LRU cache with accurate size calculation
    int estimatedSize = 0;
    for (final person in results) {
      estimatedSize += _calculatePersonSize(person);
    }

    // Check if adding this would exceed memory limit
    if (_currentCacheMemoryBytes + estimatedSize > _maxCacheMemoryBytes) {
      // Evict oldest entries until we have space
      while (_cache.isNotEmpty &&
          _currentCacheMemoryBytes + estimatedSize > _maxCacheMemoryBytes) {
        final oldestKey = _cache.keys.first;
        final oldestResults = _cache.remove(oldestKey);
        if (oldestResults != null) {
          int oldSize = 0;
          for (final person in oldestResults) {
            oldSize += _calculatePersonSize(person);
          }
          _currentCacheMemoryBytes -= oldSize;
        }
      }
    }

    // Also check entry count limit
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      final oldestResults = _cache.remove(oldestKey);
      if (oldestResults != null) {
        int oldSize = 0;
        for (final person in oldestResults) {
          oldSize += _calculatePersonSize(person);
        }
        _currentCacheMemoryBytes -= oldSize;
      }
    }

    _cache[key] = results;
    _cacheAccess[key] = DateTime.now(); // ✅ Track access time for LRU
    _currentCacheMemoryBytes += estimatedSize;
  }

  /// Load more results (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isSearching) return;
    await search(reset: false);
  }

  /// 🎯 Get autocomplete suggestions from cache
  List<String> getSuggestions(String query) {
    if (query.length < 2) return [];

    final normalized = TextNormalizationService.normalize(query);

    // Check if we have cached suggestions for this prefix
    if (_suggestionsCache.containsKey(normalized)) {
      return _suggestionsCache[normalized]!;
    }

    // Generate suggestions from search cache
    final suggestions = <String>{};

    for (final entry in _cache.entries) {
      final cachedQuery = entry.key.split('|').first;
      final persons = entry.value;

      // Add matching query
      if (TextNormalizationService.normalize(
        cachedQuery,
      ).contains(normalized)) {
        suggestions.add(cachedQuery);
      }

      // Add matching person names (first 3 only)
      for (final person in persons.take(3)) {
        if (TextNormalizationService.normalize(
          person.fullName,
        ).contains(normalized)) {
          suggestions.add(person.fullName);
        }
        if (suggestions.length >= _maxSuggestions) break;
      }

      if (suggestions.length >= _maxSuggestions) break;
    }

    final suggestionsList = suggestions.take(_maxSuggestions).toList();
    _suggestionsCache[normalized] = suggestionsList;

    return suggestionsList;
  }

  /// 🔍 Save to recent searches (Clean Architecture - uses use case)
  void _saveToRecentSearches(String query, int resultsCount) {
    // Fire and forget - don't block UI
    Future.microtask(() async {
      try {
        final repository = _ref.read(recentSearchesRepositoryProvider);
        final search = RecentSearch(
          query: query,
          searchedAt: DateTime.now(),
          resultsCount: resultsCount,
        );
        await repository.saveSearch(search);
        // Don't invalidate here - causes performance issues!
        // Provider will auto-refresh when needed
      } catch (e) {
        // Fail silently - not critical
      }
    });
  }
}

/// Provider for Search State with auto-dispose for memory cleanup
final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  final searchByNationalId = ref.watch(searchByNationalIdUseCaseProvider);
  final searchByName = ref.watch(searchByNameUseCaseProvider);

  final notifier = SearchNotifier(
    searchByNationalIdUseCase: searchByNationalId,
    searchByNameUseCase: searchByName,
    ref: ref,
  );

  // ✅ Cleanup happens automatically via StateNotifier.dispose()
  // No need for explicit ref.onDispose() - it's called by autoDispose

  return notifier;
});

/// Statistics Provider with caching (10 minutes TTL)
final statisticsProvider = FutureProvider.autoDispose<SearchStatistics>((
  ref,
) async {
  // Keep provider alive for 10 minutes (stats don't change often)
  final link = ref.keepAlive();
  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  // Invalidate cache after 10 minutes
  timer = Timer(const Duration(minutes: 10), () {
    link.close();
  });

  final useCase = ref.watch(getStatisticsUseCaseProvider);
  return await useCase();
});
