import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'beneficiaries_list_state.dart';

/// 🔍 Filters Provider
final filtersProvider = StateNotifierProvider<FiltersNotifier, FiltersState>(
  (ref) => FiltersNotifier(),
);

class FiltersNotifier extends StateNotifier<FiltersState> {
  FiltersNotifier() : super(const FiltersState());

  /// تحديث البحث
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// تحديث الفئة
  void setCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  /// تحديث المحافظة
  void setGovernorate(int? governorateId) {
    state = state.copyWith(
      governorateId: governorateId,
      cityId: null, // reset city when governorate changes
    );
  }

  /// تحديث المدينة
  void setCity(int? cityId) {
    state = state.copyWith(cityId: cityId);
  }

  /// تحديث الترتيب
  void setSorting(SortBy sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: ascending);
  }

  /// Toggle الترتيب
  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  /// تحديث نطاق التاريخ
  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(dateFrom: from, dateTo: to);
  }

  /// تحديث نطاق العمر
  void setAgeRange(int? from, int? to) {
    state = state.copyWith(ageFrom: from, ageTo: to);
  }

  /// Toggle معلق
  void togglePendingSync() {
    state = state.copyWith(onlyPendingSync: !state.onlyPendingSync);
  }

  /// Toggle مع هاتف
  void toggleWithPhone() {
    state = state.copyWith(onlyWithPhone: !state.onlyWithPhone);
  }

  /// Toggle مع موقع
  void toggleWithLocation() {
    state = state.copyWith(onlyWithLocation: !state.onlyWithLocation);
  }

  /// مسح كل الفلاتر
  void clearFilters() {
    state = const FiltersState();
  }

  /// مسح فلتر محدد
  void clearCategory() {
    state = state.copyWith(categoryId: null);
  }

  void clearGovernorate() {
    state = state.copyWith(governorateId: null, cityId: null);
  }

  void clearCity() {
    state = state.copyWith(cityId: null);
  }

  void clearDateRange() {
    state = state.copyWith(dateFrom: null, dateTo: null);
  }

  void clearAgeRange() {
    state = state.copyWith(ageFrom: null, ageTo: null);
  }
}
