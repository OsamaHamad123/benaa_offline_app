import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'filters_provider.dart';
import '../beneficiary_dependencies.dart';
import '../../../../../data/db/drift_database.dart';

/// ⚡ Search Provider with Debounce - تحسين أداء البحث
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  final _searchController = BehaviorSubject<String>();

  /// Stream للبحث مع debounce 300ms
  Stream<String> get searchStream => _searchController.stream
      .debounceTime(const Duration(milliseconds: 300))
      .distinct();

  void updateQuery(String query) {
    state = query;
    _searchController.add(query);
  }

  void clear() {
    state = '';
    _searchController.add('');
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, String>((ref) {
  return SearchNotifier();
});

/// ⚡ Search Results Provider - يستمع للـ stream
final searchResultsProvider = StreamProvider.autoDispose<List<Beneficiary>>((
  ref,
) async* {
  final db = ref.watch(databaseProvider);
  final searchNotifier = ref.watch(searchProvider.notifier);
  final filters = ref.watch(filtersProvider);

  // الاستماع للـ search stream
  await for (final query in searchNotifier.searchStream) {
    if (query.isEmpty && !filters.hasActiveFilters) {
      // إذا كان البحث فارغ ولا توجد فلاتر، نرجع قائمة فارغة
      yield [];
      continue;
    }

    try {
      // تنفيذ البحث
      final results = await db.beneficiariesDao.searchBeneficiariesFiltered(
        query: query,
        category: filters.categoryId,
        governorate: filters.governorateId,
        limit: 100, // حد أقصى للنتائج
      );

      yield results;
    } catch (e) {
      debugPrint('Search error: $e');
      yield [];
    }
  }
});
