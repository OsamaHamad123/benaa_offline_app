import '../../../../../data/db/drift_database.dart';

/// 📊 List State - حالة القائمة
class BeneficiariesListState {
  final List<Beneficiary> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String? error;
  final int totalCount;
  final int pendingSyncCount;

  const BeneficiariesListState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.pageSize = 50,
    this.error,
    this.totalCount = 0,
    this.pendingSyncCount = 0,
  });

  /// هل القائمة فارغة؟
  bool get isEmpty => !isLoading && items.isEmpty;

  /// هل يوجد بيانات؟
  bool get hasData => items.isNotEmpty;

  BeneficiariesListState copyWith({
    List<Beneficiary>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? error,
    int? totalCount,
    int? pendingSyncCount,
  }) {
    return BeneficiariesListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      error: error ?? this.error,
      totalCount: totalCount ?? this.totalCount,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }
}

/// 🔍 Filters State - حالة الفلاتر
class FiltersState {
  final String searchQuery;
  final int? categoryId; // null = الكل
  final int? governorateId; // null = الكل
  final int? cityId; // null = الكل
  final SortBy sortBy;
  final bool sortAscending;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? ageFrom;
  final int? ageTo;
  final bool onlyPendingSync;
  final bool onlyWithPhone;
  final bool onlyWithLocation;

  const FiltersState({
    this.searchQuery = '',
    this.categoryId,
    this.governorateId,
    this.cityId,
    this.sortBy = SortBy.name,
    this.sortAscending = true,
    this.dateFrom,
    this.dateTo,
    this.ageFrom,
    this.ageTo,
    this.onlyPendingSync = false,
    this.onlyWithPhone = false,
    this.onlyWithLocation = false,
  });

  /// عدد الفلاتر النشطة (بدون البحث والترتيب)
  int get activeFiltersCount {
    int count = 0;
    if (categoryId != null) count++;
    if (governorateId != null) count++;
    if (cityId != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (ageFrom != null || ageTo != null) count++;
    if (onlyPendingSync) count++;
    if (onlyWithPhone) count++;
    if (onlyWithLocation) count++;
    return count;
  }

  /// هل يوجد فلاتر نشطة؟
  bool get hasActiveFilters => activeFiltersCount > 0;

  /// مفتاح الـ cache
  String get cacheKey =>
      '$searchQuery|$categoryId|$governorateId|$cityId|$sortBy|$sortAscending|$dateFrom|$dateTo|$ageFrom|$ageTo|$onlyPendingSync|$onlyWithPhone|$onlyWithLocation';

  FiltersState copyWith({
    String? searchQuery,
    Object? categoryId = _unset,
    Object? governorateId = _unset,
    Object? cityId = _unset,
    SortBy? sortBy,
    bool? sortAscending,
    Object? dateFrom = _unset,
    Object? dateTo = _unset,
    Object? ageFrom = _unset,
    Object? ageTo = _unset,
    Object? onlyPendingSync = _unset,
    Object? onlyWithPhone = _unset,
    Object? onlyWithLocation = _unset,
  }) {
    return FiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as int?,
      governorateId: identical(governorateId, _unset)
          ? this.governorateId
          : governorateId as int?,
      cityId: identical(cityId, _unset) ? this.cityId : cityId as int?,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      dateFrom: identical(dateFrom, _unset)
          ? this.dateFrom
          : dateFrom as DateTime?,
      dateTo: identical(dateTo, _unset) ? this.dateTo : dateTo as DateTime?,
      ageFrom: identical(ageFrom, _unset) ? this.ageFrom : ageFrom as int?,
      ageTo: identical(ageTo, _unset) ? this.ageTo : ageTo as int?,
      onlyPendingSync: identical(onlyPendingSync, _unset)
          ? this.onlyPendingSync
          : onlyPendingSync as bool,
      onlyWithPhone: identical(onlyWithPhone, _unset)
          ? this.onlyWithPhone
          : onlyWithPhone as bool,
      onlyWithLocation: identical(onlyWithLocation, _unset)
          ? this.onlyWithLocation
          : onlyWithLocation as bool,
    );
  }
}

const _unset = Object();

/// ☑️ Selection State - حالة التحديد المتعدد
class SelectionState {
  final bool isSelectionMode;
  final Set<int> selectedIds;

  const SelectionState({
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  /// عدد المحدد
  int get selectedCount => selectedIds.length;

  /// هل محدد الكل؟
  bool isAllSelected(int totalCount) =>
      selectedIds.isNotEmpty && selectedIds.length == totalCount;

  /// هل هذا العنصر محدد؟
  bool isSelected(int id) => selectedIds.contains(id);

  SelectionState copyWith({bool? isSelectionMode, Set<int>? selectedIds}) {
    return SelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

/// 📑 Sort Options
enum SortBy {
  name('الاسم'),
  date('التاريخ'),
  fileNo('رقم الملف'),
  age('العمر'),
  lastModified('آخر تعديل');

  final String label;
  const SortBy(this.label);
}
