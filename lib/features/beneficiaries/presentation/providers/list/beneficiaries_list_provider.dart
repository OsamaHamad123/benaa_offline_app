import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/db/drift_database.dart';
import '../../../../../core/providers/providers.dart';
import 'package:benaa_offline_app/core/utils/unified_logger.dart';
import 'beneficiaries_list_state.dart';
import 'filters_provider.dart';
import 'cache_manager.dart';
import '../beneficiary_activity_providers.dart';

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

      // ✅ تحقق من الـ cache فقط إذا لم يكن في بحث نشط
      if (_lastCacheKey == cacheKey &&
          _cachedData != null &&
          filters.searchQuery.isEmpty) {
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
      CacheManager.updateCacheTime();

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

  /// 🔍 جلب البيانات من Database - OPTIMIZED (SQL filtering)
  Future<List<Beneficiary>> _fetchBeneficiaries(
    FiltersState filters,
    int page,
  ) async {
    // ✅ كل الفلترة في SQL - performance++
    final items = await _db.beneficiariesDao.searchBeneficiariesAdvanced(
      query: filters.searchQuery,
      categoryId: filters.categoryId,
      governorateId: filters.governorateId,
      cityId: filters.cityId,
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      sortBy: _getSortField(filters.sortBy),
      sortDesc: !filters.sortAscending, // inverted
      limit: state.pageSize,
      offset: page * state.pageSize,
    );

    // فلاتر معقدة تحتاج Dart (age, sync state, etc)
    return _applyDartOnlyFilters(items, filters);
  }

  /// 🎯 فلاتر تحتاج Dart فقط (calculated fields)
  List<Beneficiary> _applyDartOnlyFilters(
    List<Beneficiary> items,
    FiltersState filters,
  ) {
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

    return items;
  }

  /// Helper: تحويل SortBy إلى SQL field name
  String _getSortField(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.date:
        return 'created_at';
      case SortBy.fileNo:
        return 'file_id_number';
      case SortBy.name:
      default:
        return 'full_name';
    }
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

  /// 🗑️ Clear cache
  void clearCache() {
    _cachedData = null;
    _lastCacheKey = null;
    CacheManager.clearCache();
    state = const BeneficiariesListState();
  }

  /// ✅ Optimistic Delete with Activity Logging
  Future<void> deleteBeneficiary(int id) async {
    UnifiedLogger.info('Delete beneficiary #$id');

    // حفظ النسخة القديمة
    final oldItems = state.items;
    final oldCachedData = _cachedData;

    // احصل على معلومات المستفيد قبل الحذف
    final beneficiary = state.items.firstWhere((b) => b.id == id);

    // حذف فوري من UI
    final newItems = state.items.where((b) => b.id != id).toList();
    state = state.copyWith(items: newItems);
    _cachedData = newItems;

    final stopwatch = Stopwatch()..start();
    try {
      // 🔥 حذف من Database + تسجيل Activity
      final deleteBeneficiaryWithActivity = _ref.read(
        deleteBeneficiaryWithActivityProvider,
      );
      await deleteBeneficiaryWithActivity(
        beneficiaryId: id,
        beneficiaryName: beneficiary.fullName,
        fileNo: beneficiary.fileIdNumber,
      );

      await _updateStatistics();
      stopwatch.stop();
      UnifiedLogger.logPerformance(
        operation: 'Delete beneficiary #$id',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e, stackTrace) {
      // استرجاع في حالة الخطأ
      stopwatch.stop();
      UnifiedLogger.error(
        'Failed to delete beneficiary #$id',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(items: oldItems, error: e.toString());
      _cachedData = oldCachedData;
      rethrow;
    }
  }

  /// ✅ Bulk Delete
  Future<void> bulkDelete(Set<int> ids) async {
    UnifiedLogger.info('Bulk delete ${ids.length} beneficiaries');

    final oldItems = state.items;
    final oldCachedData = _cachedData;

    // حذف فوري من الواجهة
    final newItems = state.items.where((b) => !ids.contains(b.id)).toList();
    state = state.copyWith(items: newItems);
    _cachedData = newItems;

    final stopwatch = Stopwatch()..start();
    try {
      // استخدام batch delete للسرعة
      await _db.beneficiariesDao.batchDeleteBeneficiaries(ids.toList());
      await _updateStatistics();
      stopwatch.stop();
      UnifiedLogger.logPerformance(
        operation: 'Bulk delete ${ids.length} items',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      UnifiedLogger.error('Bulk delete failed',
          error: e, stackTrace: stackTrace);
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
