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

  void setNationalIdQuery(String query) {
    state = state.copyWith(nationalIdQuery: query);
  }

  void setFileNumberQuery(String query) {
    state = state.copyWith(fileNumberQuery: query);
  }

  void setPhoneQuery(String query) {
    state = state.copyWith(phoneQuery: query);
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

  void setGender(int? gender) {
    state = state.copyWith(gender: gender);
  }

  void setMaritalStatus(int? maritalStatus) {
    state = state.copyWith(maritalStatus: maritalStatus);
  }

  void setAdvancedSearch({
    required String nameQuery,
    required String nationalIdQuery,
    required String fileNumberQuery,
    required String phoneQuery,
    required int? gender,
    required int? maritalStatus,
    required int? ageFrom,
    required int? ageTo,
  }) {
    state = state.copyWith(
      searchQuery: nameQuery,
      nationalIdQuery: nationalIdQuery,
      fileNumberQuery: fileNumberQuery,
      phoneQuery: phoneQuery,
      gender: gender,
      maritalStatus: maritalStatus,
      ageFrom: ageFrom,
      ageTo: ageTo,
    );
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

  void clearSearchInputs() {
    state = state.copyWith(
      searchQuery: '',
      nationalIdQuery: '',
      fileNumberQuery: '',
      phoneQuery: '',
    );
  }

  void clearGovernorate() {
    state = state.copyWith(governorateId: null, cityId: null);
  }

  void clearCity() {
    state = state.copyWith(cityId: null);
  }

  void clearGender() {
    state = state.copyWith(gender: null);
  }

  void clearMaritalStatus() {
    state = state.copyWith(maritalStatus: null);
  }

  void clearDateRange() {
    state = state.copyWith(dateFrom: null, dateTo: null);
  }

  void clearAgeRange() {
    state = state.copyWith(ageFrom: null, ageTo: null);
  }
}
