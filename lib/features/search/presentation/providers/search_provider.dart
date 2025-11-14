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

/// 🎯 Search State Notifier - Clean Architecture
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchByNationalIdUseCase searchByNationalIdUseCase;
  final SearchByNameUseCase searchByNameUseCase;

  SearchNotifier({
    required this.searchByNationalIdUseCase,
    required this.searchByNameUseCase,
  }) : super(const SearchState());

  static const int _pageSize = 20;

  /// Update query
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Update filter - Governorate
  void setGovernorate(String? governorate) {
    final newFilter = governorate == null || governorate.isEmpty
        ? state.filter.clearGovernorate()
        : state.filter.copyWith(governorate: governorate);

    state = state.copyWith(filter: newFilter, currentPage: 0, results: []);
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
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      filter: const SearchFilter(),
      currentPage: 0,
      results: [],
    );
  }

  /// Clear search
  void clearSearch() {
    state = const SearchState();
  }

  /// Perform search (unified method)
  Future<void> search({bool reset = false}) async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: [], currentPage: 0);
      return;
    }

    if (state.isSearching) return;

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
        await _searchByNationalId(reset);
      } else {
        // Search by name
        await _searchByName(reset);
      }
    } catch (e) {
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

  /// Search by national ID
  Future<void> _searchByNationalId(bool reset) async {
    try {
      final person = await searchByNationalIdUseCase(state.query);

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

  /// Search by name with filters
  Future<void> _searchByName(bool reset) async {
    try {
      final page = reset ? 1 : state.currentPage + 1;

      final result = await searchByNameUseCase(
        query: state.query,
        filter: state.filter,
        page: page,
        pageSize: _pageSize,
      );

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

/// Statistics Provider (cached)
final statisticsProvider = FutureProvider<SearchStatistics>((ref) async {
  final useCase = ref.watch(getStatisticsUseCaseProvider);
  return await useCase();
});
