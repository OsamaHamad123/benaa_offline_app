import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardTimeContext { today, week, month }

/// Dashboard UI State - حالة واجهة المستخدم
class DashboardUIState {
  static const Object _unset = Object();

  final int selectedTabIndex;
  final DashboardTimeContext selectedTimeContext;
  final bool showWelcomeBanner;
  final String selectedFilter;
  final bool isOnline;
  final String? selectedCategory;
  final String? selectedGovernorate;
  final bool? syncedOnly;

  const DashboardUIState({
    this.selectedTabIndex = 0,
    this.selectedTimeContext = DashboardTimeContext.week,
    this.showWelcomeBanner = false,
    this.selectedFilter = 'all',
    this.isOnline = true,
    this.selectedCategory,
    this.selectedGovernorate,
    this.syncedOnly,
  });

  DashboardUIState copyWith({
    int? selectedTabIndex,
    DashboardTimeContext? selectedTimeContext,
    bool? showWelcomeBanner,
    String? selectedFilter,
    bool? isOnline,
    Object? selectedCategory = _unset,
    Object? selectedGovernorate = _unset,
    Object? syncedOnly = _unset,
  }) {
    return DashboardUIState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedTimeContext: selectedTimeContext ?? this.selectedTimeContext,
      showWelcomeBanner: showWelcomeBanner ?? this.showWelcomeBanner,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isOnline: isOnline ?? this.isOnline,
      selectedCategory: identical(selectedCategory, _unset) ? this.selectedCategory : selectedCategory as String?,
      selectedGovernorate:
          identical(selectedGovernorate, _unset) ? this.selectedGovernorate : selectedGovernorate as String?,
      syncedOnly: identical(syncedOnly, _unset) ? this.syncedOnly : syncedOnly as bool?,
    );
  }
}

/// Dashboard UI State Notifier
class DashboardUIStateNotifier extends StateNotifier<DashboardUIState> {
  DashboardUIStateNotifier() : super(const DashboardUIState());

  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void setTimeContext(DashboardTimeContext context) {
    state = state.copyWith(selectedTimeContext: context);
  }

  // === Welcome Banner ===

  void showWelcomeBanner() {
    state = state.copyWith(showWelcomeBanner: true);
  }

  void hideWelcomeBanner() {
    state = state.copyWith(showWelcomeBanner: false);
  }

  // === Filters ===

  void setSelectedFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setGovernorate(String? governorate) {
    state = state.copyWith(selectedGovernorate: governorate);
  }

  void setSyncedOnly(bool? syncedOnly) {
    state = state.copyWith(syncedOnly: syncedOnly);
  }

  void applyAdvancedFilters({
    String? category,
    String? governorate,
    bool? syncedOnly,
  }) {
    state = state.copyWith(
      selectedCategory: category,
      selectedGovernorate: governorate,
      syncedOnly: syncedOnly,
    );
  }

  void clearAdvancedFilters() {
    state = state.copyWith(
      selectedCategory: null,
      selectedGovernorate: null,
      syncedOnly: null,
    );
  }

  // === Connectivity ===

  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  // === Computed Properties ===

  bool get hasAdvancedFilters =>
      state.selectedCategory != null || state.selectedGovernorate != null || state.syncedOnly != null;

  int get activeFiltersCount {
    int count = 0;
    if (state.selectedCategory != null) count++;
    if (state.selectedGovernorate != null) count++;
    if (state.syncedOnly != null) count++;
    return count;
  }
}

/// Provider
final dashboardUIStateProvider = StateNotifierProvider<DashboardUIStateNotifier, DashboardUIState>((ref) {
  return DashboardUIStateNotifier();
});
