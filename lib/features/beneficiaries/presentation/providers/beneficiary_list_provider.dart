import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/usecases/beneficiary_usecases.dart';
import 'beneficiary_dependencies_provider.dart';
import '../../../../core/error_handling/result.dart';

/// 🔍 Beneficiary List State
class BeneficiaryListState {
  final List<Beneficiary> beneficiaries;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final BeneficiaryCategory? selectedCategory;
  final Gender? selectedGender;
  final String sortBy; // 'name', 'date', 'fileNo'
  final bool sortAscending;

  const BeneficiaryListState({
    this.beneficiaries = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedGender,
    this.sortBy = 'name',
    this.sortAscending = true,
  });

  BeneficiaryListState copyWith({
    List<Beneficiary>? beneficiaries,
    bool? isLoading,
    String? error,
    String? searchQuery,
    BeneficiaryCategory? selectedCategory,
    Gender? selectedGender,
    String? sortBy,
    bool? sortAscending,
    bool clearError = false,
    bool clearCategoryFilter = false,
    bool clearGenderFilter = false,
  }) {
    return BeneficiaryListState(
      beneficiaries: beneficiaries ?? this.beneficiaries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategoryFilter
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedGender:
          clearGenderFilter ? null : (selectedGender ?? this.selectedGender),
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory != null) count++;
    if (selectedGender != null) count++;
    return count;
  }

  bool get hasFilters => activeFiltersCount > 0 || searchQuery.isNotEmpty;
}

/// 📋 Beneficiary List Provider
class BeneficiaryListNotifier extends StateNotifier<BeneficiaryListState> {
  final ListBeneficiariesUseCase _listUseCase;
  final DeleteBeneficiaryUseCase _deleteUseCase;

  BeneficiaryListNotifier({
    required ListBeneficiariesUseCase listUseCase,
    required DeleteBeneficiaryUseCase deleteUseCase,
  })  : _listUseCase = listUseCase,
        _deleteUseCase = deleteUseCase,
        super(const BeneficiaryListState()) {
    loadBeneficiaries();
  }

  /// Load beneficiaries with current filters
  Future<void> loadBeneficiaries() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _listUseCase.execute(
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        category: state.selectedCategory,
        gender: state.selectedGender,
      );

      if (result is Failure<List<Beneficiary>>) {
        throw Exception(result.error.message);
      }

      final beneficiaries = (result as Success<List<Beneficiary>>).value;
      // Apply sorting
      final sorted = _sortBeneficiaries(beneficiaries);

      state = state.copyWith(beneficiaries: sorted, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Search beneficiaries
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadBeneficiaries();
  }

  /// Filter by category
  void filterByCategory(BeneficiaryCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategoryFilter: category == null,
    );
    loadBeneficiaries();
  }

  /// Filter by gender
  void filterByGender(Gender? gender) {
    state = state.copyWith(
      selectedGender: gender,
      clearGenderFilter: gender == null,
    );
    loadBeneficiaries();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearCategoryFilter: true,
      clearGenderFilter: true,
    );
    loadBeneficiaries();
  }

  /// Sort beneficiaries
  void sortBy(String sortField) {
    if (state.sortBy == sortField) {
      // Toggle direction
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      // Change sort field
      state = state.copyWith(sortBy: sortField, sortAscending: true);
    }

    // Re-sort current list
    final sorted = _sortBeneficiaries(state.beneficiaries);
    state = state.copyWith(beneficiaries: sorted);
  }

  /// Delete beneficiary
  Future<bool> delete(String id) async {
    try {
      await _deleteUseCase.execute(id);
      await loadBeneficiaries(); // Reload list
      return true;
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف المستفيد: $e');
      return false;
    }
  }

  /// Sort beneficiaries based on current sort settings
  List<Beneficiary> _sortBeneficiaries(List<Beneficiary> beneficiaries) {
    final list = List<Beneficiary>.from(beneficiaries);

    list.sort((a, b) {
      int comparison;
      switch (state.sortBy) {
        case 'name':
          comparison = a.fullName.compareTo(b.fullName);
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
        case 'fileNo':
          final aFileNo = a.fileNo ?? '';
          final bFileNo = b.fileNo ?? '';
          comparison = aFileNo.compareTo(bFileNo);
        default:
          comparison = 0;
      }
      return state.sortAscending ? comparison : -comparison;
    });

    return list;
  }
}

/// Provider for beneficiary list
final beneficiaryListProvider =
    StateNotifierProvider<BeneficiaryListNotifier, BeneficiaryListState>((ref) {
  final dependencies = ref.watch(beneficiaryDependenciesProvider);

  return BeneficiaryListNotifier(
    listUseCase: dependencies.listUseCase,
    deleteUseCase: dependencies.deleteUseCase,
  );
});

/// Provider for statistics
final beneficiaryStatisticsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final dependencies = ref.watch(beneficiaryDependenciesProvider);
  final result = await dependencies.statsUseCase.execute();

  if (result is Failure<Map<String, int>>) {
    throw Exception(result.error.message);
  }

  return (result as Success<Map<String, int>>).value;
});
