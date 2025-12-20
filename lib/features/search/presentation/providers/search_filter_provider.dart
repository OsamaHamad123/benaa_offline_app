import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/saved_filter.dart';
import '../../domain/entities/search_filter.dart' show AdvancedSearchFilter;

/// 🔍 Search Filter State
class SearchFilterState {
  final AdvancedSearchFilter currentFilter;
  final List<SavedFilter> savedFilters;
  final bool isLoading;

  const SearchFilterState({
    required this.currentFilter,
    required this.savedFilters,
    this.isLoading = false,
  });

  SearchFilterState copyWith({
    AdvancedSearchFilter? currentFilter,
    List<SavedFilter>? savedFilters,
    bool? isLoading,
  }) {
    return SearchFilterState(
      currentFilter: currentFilter ?? this.currentFilter,
      savedFilters: savedFilters ?? this.savedFilters,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 🔍 Search Filter Notifier
class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier()
      : super(SearchFilterState(
          currentFilter: AdvancedSearchFilter.empty(),
          savedFilters: [],
        )) {
    _loadSavedFilters();
  }

  static const String _savedFiltersKey = 'saved_search_filters';
  final _uuid = const Uuid();

  /// تحميل الفلاتر المحفوظة
  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_savedFiltersKey);

      if (filtersJson != null) {
        final filtersList = jsonDecode(filtersJson) as List<dynamic>;
        final savedFilters = filtersList
            .map((e) => SavedFilter.fromJson(e as Map<String, dynamic>))
            .toList();

        state = state.copyWith(savedFilters: savedFilters);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// حفظ الفلاتر
  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson =
          jsonEncode(state.savedFilters.map((e) => e.toJson()).toList());
      await prefs.setString(_savedFiltersKey, filtersJson);
    } catch (e) {
      // Handle error silently
    }
  }

  /// تحديث الفلتر الحالي
  void updateFilter(AdvancedSearchFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// مسح جميع الفلاتر
  void clearFilter() {
    state = state.copyWith(currentFilter: AdvancedSearchFilter.empty());
  }

  /// حفظ الفلتر الحالي
  Future<void> saveCurrentFilter(String name) async {
    final newFilter = SavedFilter(
      id: _uuid.v4(),
      name: name,
      filter: state.currentFilter,
      createdAt: DateTime.now(),
    );

    final updatedFilters = [...state.savedFilters, newFilter];
    state = state.copyWith(savedFilters: updatedFilters);
    await _saveFilters();
  }

  /// حذف فلتر محفوظ
  Future<void> deleteSavedFilter(String id) async {
    final updatedFilters = state.savedFilters.where((f) => f.id != id).toList();
    state = state.copyWith(savedFilters: updatedFilters);
    await _saveFilters();
  }

  /// تطبيق فلتر محفوظ
  Future<void> applySavedFilter(String id) async {
    final filter = state.savedFilters.firstWhere((f) => f.id == id);
    final updatedFilter = filter.copyWith(lastUsedAt: DateTime.now());

    // تحديث آخر استخدام
    final updatedFilters = state.savedFilters.map((f) {
      return f.id == id ? updatedFilter : f;
    }).toList();

    state = state.copyWith(
      currentFilter: filter.filter,
      savedFilters: updatedFilters,
    );

    await _saveFilters();
  }
}

/// Provider للفلتر
final searchFilterProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
  return SearchFilterNotifier();
});
