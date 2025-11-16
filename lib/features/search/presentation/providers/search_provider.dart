import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/civil_person.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/usecases/search_by_name.dart';
import '../../domain/usecases/search_by_national_id.dart';
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

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.filter = const SearchFilter(),
    this.error,
    this.totalResults = 0,
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
    );
  }

  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
}

/// 🎯 Search State Notifier - Clean Architecture with Performance Optimizations
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchByNationalIdUseCase searchByNationalIdUseCase;
  final SearchByNameUseCase searchByNameUseCase;

  // ⚡ Aggressive debouncing to eliminate lag
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  // 🚫 Request cancellation token
  int _requestId = 0;

  // 💾 Smart cache for instant results (LRU-style)
  final Map<String, List<CivilPerson>> _cache = {};
  static const int _maxCacheSize = 50;

  SearchNotifier({
    required this.searchByNationalIdUseCase,
    required this.searchByNameUseCase,
  }) : super(const SearchState());

  static const int _pageSize = 20;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cache.clear();
    super.dispose();
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

    // Increment request ID to cancel previous requests
    final currentRequestId = ++_requestId;

    // Check cache first
    final cacheKey = _getCacheKey(state.query, state.filter);
    if (_cache.containsKey(cacheKey) && reset) {
      state = state.copyWith(
        results: _cache[cacheKey]!,
        currentPage: 1,
        hasMore: false,
        isSearching: false,
        error: null,
      );
      return;
    }

    // Reset or continue pagination
    if (reset) {
      state = state.copyWith(
        isSearching: true,
        results: [],
        currentPage: 0,
        hasMore: false,
        error: null,
        totalResults: 0,
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
        await _searchByNationalId(reset, currentRequestId);
      } else {
        // Search by name
        await _searchByName(reset, currentRequestId);
      }
    } catch (e) {
      // Only update state if this is still the current request
      if (currentRequestId != _requestId) return;

      // Check if it's a database not found error
      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage =
            '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }
      state = state.copyWith(isSearching: false, error: errorMessage);
    }
  }

  /// Search by national ID with cancellation
  Future<void> _searchByNationalId(bool reset, int requestId) async {
    try {
      final person = await searchByNationalIdUseCase(state.query);

      // Check if request is still valid
      if (requestId != _requestId) return;

      if (person != null) {
        state = state.copyWith(
          results: [person],
          hasMore: false,
          currentPage: 1,
          isSearching: false,
          totalResults: 1,
        );
      } else {
        state = state.copyWith(
          results: [],
          hasMore: false,
          currentPage: 0,
          isSearching: false,
          error: 'لم يتم العثور على الرقم الوطني',
          totalResults: 0,
        );
      }
    } catch (e) {
      if (requestId != _requestId) return;

      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage =
            '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }
      state = state.copyWith(isSearching: false, error: errorMessage);
    }
  }

  /// Search by name with filters and caching
  Future<void> _searchByName(bool reset, int requestId) async {
    try {
      final page = reset ? 1 : state.currentPage + 1;

      final result = await searchByNameUseCase(
        query: state.query,
        filter: state.filter,
        page: page,
        pageSize: _pageSize,
      );

      // Check if request is still valid
      if (requestId != _requestId) return;

      // Cache results for first page
      if (reset && result.persons.isNotEmpty) {
        final cacheKey = _getCacheKey(state.query, state.filter);
        _addToCache(cacheKey, result.persons);
      }

      if (reset) {
        state = state.copyWith(
          results: result.persons,
          hasMore: result.hasMore,
          currentPage: page,
          isSearching: false,
          totalResults: result.totalResults,
        );
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
        state = state.copyWith(error: 'لم يتم العثور على نتائج');
      }
    } catch (e) {
      if (requestId != _requestId) return;

      String errorMessage = 'خطأ في البحث: $e';
      if (e.toString().contains('قاعدة بيانات السجل المدني غير موجودة')) {
        errorMessage =
            '⚠️ قاعدة بيانات السجل المدني غير موجودة\n\n'
            'الرجاء الذهاب إلى:\n'
            '"تنزيل قاعدة بيانات السجل المدني"\n'
            'من القائمة الرئيسية أولاً.';
      }
      state = state.copyWith(isSearching: false, error: errorMessage);
    }
  }

  // ============================================================================
  // CACHE HELPERS
  // ============================================================================

  String _getCacheKey(String query, SearchFilter filter) {
    return '${query}_${filter.governorate}_${filter.gender}';
  }

  void _addToCache(String key, List<CivilPerson> results) {
    // Simple LRU: remove oldest if cache is full
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = results;
  }

  /// Load more results (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isSearching) return;
    await search(reset: false);
  }
}

/// Provider for Search State
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  final searchByNationalId = ref.watch(searchByNationalIdUseCaseProvider);
  final searchByName = ref.watch(searchByNameUseCaseProvider);

  return SearchNotifier(
    searchByNationalIdUseCase: searchByNationalId,
    searchByNameUseCase: searchByName,
  );
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
