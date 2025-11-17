import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/db/drift_database.dart';
import '../../../../../core/providers/providers.dart';
import 'beneficiaries_list_state.dart';
import 'filters_provider.dart';

/// 📊 Beneficiaries List Provider
final beneficiariesListProvider =
    StateNotifierProvider<BeneficiariesListNotifier, BeneficiariesListState>(
      (ref) => BeneficiariesListNotifier(ref),
    );

class BeneficiariesListNotifier extends StateNotifier<BeneficiariesListState> {
  final Ref _ref;
  List<Beneficiary>? _cachedData;
  String? _lastCacheKey;

  BeneficiariesListNotifier(this._ref) : super(const BeneficiariesListState()) {
    _init();
  }

  AppDatabase get _db => _ref.read(databaseProvider);
  FiltersState get _filters => _ref.read(filtersProvider);

  Future<void> _init() async {
    await loadInitialData();
  }

  /// 🔄 تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final filters = _filters;
      final cacheKey = filters.cacheKey;

      // استخدام Cache إذا كان المفتاح نفسه
      if (_lastCacheKey == cacheKey && _cachedData != null) {
        state = state.copyWith(
          items: _cachedData!,
          isLoading: false,
          currentPage: 0,
          hasMore: _cachedData!.length >= state.pageSize,
        );
        await _updateStatistics();
        return;
      }

      // جلب البيانات
      final items = await _fetchBeneficiaries(filters, 0);

      _cachedData = items;
      _lastCacheKey = cacheKey;

      state = state.copyWith(
        items: items,
        isLoading: false,
        currentPage: 0,
        hasMore: items.length >= state.pageSize,
        error: null,
      );

      await _updateStatistics();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 📄 تحميل المزيد (Pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newItems = await _fetchBeneficiaries(_filters, nextPage);

      if (newItems.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
        return;
      }

      final updatedItems = [...state.items, ...newItems];
      _cachedData = updatedItems;

      state = state.copyWith(
        items: updatedItems,
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newItems.length >= state.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// 🔍 جلب البيانات من Database
  Future<List<Beneficiary>> _fetchBeneficiaries(
    FiltersState filters,
    int page,
  ) async {
    var items = await _db.beneficiariesDao.searchBeneficiaries(
      filters.searchQuery,
    );

    // تطبيق الفلاتر
    items = _applyFilters(items, filters);

    // الترتيب
    items = _applySorting(items, filters);

    // Pagination
    final offset = page * state.pageSize;
    return items.skip(offset).take(state.pageSize).toList();
  }

  /// 🎯 تطبيق الفلاتر
  List<Beneficiary> _applyFilters(
    List<Beneficiary> items,
    FiltersState filters,
  ) {
    // Category Filter
    if (filters.categoryId != null) {
      items = items.where((b) => b.sectionId == filters.categoryId).toList();
    }

    // Governorate Filter
    if (filters.governorateId != null) {
      items = items.where((b) => b.province == filters.governorateId).toList();
    }

    // City Filter
    if (filters.cityId != null) {
      items = items.where((b) => b.city == filters.cityId).toList();
    }

    // Date Range Filter
    if (filters.dateFrom != null) {
      items = items.where((b) {
        final date = b.createdAt;
        return date != null && date.isAfter(filters.dateFrom!);
      }).toList();
    }
    if (filters.dateTo != null) {
      items = items.where((b) {
        final date = b.createdAt;
        return date != null && date.isBefore(filters.dateTo!);
      }).toList();
    }

    // Age Range Filter (calculated from birthDate)
    if (filters.ageFrom != null) {
      items = items.where((b) {
        if (b.birthDate == null) return false;
        final age = _calculateAge(b.birthDate!);
        return age >= filters.ageFrom!;
      }).toList();
    }
    if (filters.ageTo != null) {
      items = items.where((b) {
        if (b.birthDate == null) return false;
        final age = _calculateAge(b.birthDate!);
        return age <= filters.ageTo!;
      }).toList();
    }

    // Pending Sync Filter
    if (filters.onlyPendingSync) {
      items = items.where((b) => b.syncState != 'synced').toList();
    }

    // Phone Filter
    if (filters.onlyWithPhone) {
      items = items.where((b) => b.phoneNumber != 0).toList();
    }

    // Location Filter - TODO: Add location fields to database if needed
    // if (filters.onlyWithLocation) {
    //   items = items.where((b) => b.hasLocation).toList();
    // }

    return items;
  }

  /// 📊 تطبيق الترتيب
  List<Beneficiary> _applySorting(
    List<Beneficiary> items,
    FiltersState filters,
  ) {
    items.sort((a, b) {
      int comparison;
      switch (filters.sortBy) {
        case SortBy.name:
          comparison = a.fullName.compareTo(b.fullName);
        case SortBy.date:
          comparison = (a.createdAt ?? DateTime(1900)).compareTo(
            b.createdAt ?? DateTime(1900),
          );
        case SortBy.fileNo:
          comparison = (a.fileIdNumber ?? '').compareTo(b.fileIdNumber ?? '');
        case SortBy.age:
          final ageA = a.birthDate != null ? _calculateAge(a.birthDate!) : 0;
          final ageB = b.birthDate != null ? _calculateAge(b.birthDate!) : 0;
          comparison = ageA.compareTo(ageB);
        case SortBy.lastModified:
          comparison = (a.updatedAt ?? DateTime(1900)).compareTo(
            b.updatedAt ?? DateTime(1900),
          );
      }
      return filters.sortAscending ? comparison : -comparison;
    });

    return items;
  }

  /// 📈 تحديث الإحصائيات
  Future<void> _updateStatistics() async {
    try {
      final results = await Future.wait([
        _db.beneficiariesDao.countBeneficiaries(),
        _db.beneficiariesDao.countPendingSync(),
      ]);

      state = state.copyWith(
        totalCount: results[0],
        pendingSyncCount: results[1],
      );
    } catch (e) {
      // تجاهل خطأ الإحصائيات
    }
  }

  /// 🔄 Refresh
  Future<void> refresh() async {
    _cachedData = null;
    _lastCacheKey = null;
    await loadInitialData();
  }

  /// ✅ Optimistic Delete
  Future<void> deleteBeneficiary(int id) async {
    // حفظ النسخة القديمة
    final oldItems = state.items;
    final oldCachedData = _cachedData;

    // حذف فوري من UI
    final newItems = state.items.where((b) => b.id != id).toList();
    state = state.copyWith(items: newItems);
    _cachedData = newItems;

    try {
      // حذف من Database
      await _db.beneficiariesDao.deleteBeneficiary(id);
      await _updateStatistics();
    } catch (e) {
      // استرجاع في حالة الخطأ
      state = state.copyWith(items: oldItems, error: e.toString());
      _cachedData = oldCachedData;
      rethrow;
    }
  }

  /// ✅ Bulk Delete
  Future<void> bulkDelete(Set<int> ids) async {
    final oldItems = state.items;
    final oldCachedData = _cachedData;

    // حذف فوري
    final newItems = state.items.where((b) => !ids.contains(b.id)).toList();
    state = state.copyWith(items: newItems);
    _cachedData = newItems;

    try {
      for (final id in ids) {
        await _db.beneficiariesDao.deleteBeneficiary(id);
      }
      await _updateStatistics();
    } catch (e) {
      state = state.copyWith(items: oldItems, error: e.toString());
      _cachedData = oldCachedData;
      rethrow;
    }
  }

  /// 🔄 إعادة المزامنة
  Future<void> resyncBeneficiary(int id) async {
    // يمكن إضافة منطق المزامنة هنا
    await refresh();
  }

  /// 📅 حساب العمر من تاريخ الميلاد
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
