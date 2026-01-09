import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/repositories/taxonomy_repository.dart';
import '../../domain/usecases/taxonomy_usecases.dart';
import '../../data/datasources/taxonomy_remote_datasource.dart';
import '../../data/datasources/taxonomy_local_datasource.dart';
import '../../data/repositories/taxonomy_repository_impl.dart';

// ═══════════════════════════════════════════════════════════════
// 📦 Dependency Injection Providers
// ═══════════════════════════════════════════════════════════════

/// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

/// Dio Provider for Taxonomy API
final taxonomyDioProvider = Provider<Dio>((ref) {
  throw UnimplementedError('Dio must be overridden in ProviderScope');
});

/// Remote Data Source Provider
final taxonomyRemoteDataSourceProvider = Provider<TaxonomyRemoteDataSource>((ref) {
  final dio = ref.watch(taxonomyDioProvider);
  return TaxonomyRemoteDataSourceImpl(dio);
});

/// Local Data Source Provider
final taxonomyLocalDataSourceProvider = Provider<TaxonomyLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TaxonomyLocalDataSourceImpl(prefs);
});

/// Repository Provider
final taxonomyRepositoryProvider = Provider<TaxonomyRepository>((ref) {
  return TaxonomyRepositoryImpl(
    remoteDataSource: ref.watch(taxonomyRemoteDataSourceProvider),
    localDataSource: ref.watch(taxonomyLocalDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════════
// 🎯 Use Case Providers
// ═══════════════════════════════════════════════════════════════

final syncTaxonomiesUseCaseProvider = Provider<SyncTaxonomiesUseCase>((ref) {
  return SyncTaxonomiesUseCase(ref.watch(taxonomyRepositoryProvider));
});

final getTaxonomiesUseCaseProvider = Provider<GetTaxonomiesUseCase>((ref) {
  return GetTaxonomiesUseCase(ref.watch(taxonomyRepositoryProvider));
});

final createTaxonomyUseCaseProvider = Provider<CreateTaxonomyUseCase>((ref) {
  return CreateTaxonomyUseCase(ref.watch(taxonomyRepositoryProvider));
});

final updateTaxonomyUseCaseProvider = Provider<UpdateTaxonomyUseCase>((ref) {
  return UpdateTaxonomyUseCase(ref.watch(taxonomyRepositoryProvider));
});

final deleteTaxonomyUseCaseProvider = Provider<DeleteTaxonomyUseCase>((ref) {
  return DeleteTaxonomyUseCase(ref.watch(taxonomyRepositoryProvider));
});

final taxonomyStatisticsUseCaseProvider = Provider<GetTaxonomyStatisticsUseCase>((ref) {
  return GetTaxonomyStatisticsUseCase(ref.watch(taxonomyRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════
// 📊 State Providers
// ═══════════════════════════════════════════════════════════════

/// حالة المزامنة
enum TaxonomySyncStatus { idle, syncing, success, error }

/// حالة المزامنة الحالية
final taxonomySyncStatusProvider = StateProvider<TaxonomySyncStatus>((ref) {
  return TaxonomySyncStatus.idle;
});

/// رسالة الخطأ
final taxonomyErrorMessageProvider = StateProvider<String?>((ref) {
  return null;
});

/// نتيجة المزامنة الأخيرة
final lastSyncResultProvider = StateProvider<TaxonomySyncResult?>((ref) {
  return null;
});

// ═══════════════════════════════════════════════════════════════
// 🔍 Data Providers
// ═══════════════════════════════════════════════════════════════

/// جلب جميع التصنيفات
final allTaxonomiesProvider = FutureProvider<List<Taxonomy>>((ref) async {
  final useCase = ref.watch(getTaxonomiesUseCaseProvider);
  final result = await useCase.call();

  return switch (result) {
    Success(value: final taxonomies) => taxonomies,
    Failure(error: final e) => throw Exception(e.message),
  };
});

/// جلب التصنيفات حسب المجموعة
final taxonomiesByGroupProvider = FutureProvider.family<List<Taxonomy>, TaxonomyGroup>(
  (ref, group) async {
    final useCase = ref.watch(getTaxonomiesUseCaseProvider);
    final result = await useCase.byGroup(group);

    return switch (result) {
      Success(value: final taxonomies) => taxonomies,
      Failure(error: final e) => throw Exception(e.message),
    };
  },
);

/// جلب تصنيف بالـ ID
final taxonomyByIdProvider = FutureProvider.family<Taxonomy?, String>(
  (ref, id) async {
    final useCase = ref.watch(getTaxonomiesUseCaseProvider);
    final result = await useCase.byId(id);

    return switch (result) {
      Success(value: final taxonomy) => taxonomy,
      Failure() => null,
    };
  },
);

/// البحث في التصنيفات
final searchTaxonomiesProvider = FutureProvider.family<List<Taxonomy>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    final useCase = ref.watch(getTaxonomiesUseCaseProvider);
    final result = await useCase.search(query);

    return switch (result) {
      Success(value: final taxonomies) => taxonomies,
      Failure() => [],
    };
  },
);

/// إحصائيات التصنيفات
final taxonomyStatisticsProvider = FutureProvider<TaxonomyStatistics>((ref) async {
  final useCase = ref.watch(taxonomyStatisticsUseCaseProvider);
  final result = await useCase.call();

  return switch (result) {
    Success(value: final stats) => stats,
    Failure(error: final e) => throw Exception(e.message),
  };
});

/// آخر وقت مزامنة
final lastSyncTimeProvider = FutureProvider<DateTime?>((ref) async {
  final repository = ref.watch(taxonomyRepositoryProvider);
  final result = await repository.getLastSyncTime();

  return switch (result) {
    Success(value: final time) => time,
    Failure() => null,
  };
});

// ═══════════════════════════════════════════════════════════════
// 🚀 Action Notifiers
// ═══════════════════════════════════════════════════════════════

/// مزامنة التصنيفات من السيرفر
class TaxonomySyncNotifier extends StateNotifier<AsyncValue<TaxonomySyncResult?>> {
  final SyncTaxonomiesUseCase _syncUseCase;
  final Ref _ref;

  TaxonomySyncNotifier(this._syncUseCase, this._ref) : super(const AsyncValue.data(null));

  /// مزامنة كاملة
  Future<void> sync() async {
    state = const AsyncValue.loading();
    _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;
    _ref.read(taxonomyErrorMessageProvider.notifier).state = null;

    final result = await _syncUseCase.call();

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = syncResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      state = AsyncValue.data(syncResult);
    } else {
      final e = (result as Failure).error;
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.error;
      _ref.read(taxonomyErrorMessageProvider.notifier).state = e.message;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// مزامنة مجموعة معينة
  Future<void> syncGroup(TaxonomyGroup group) async {
    state = const AsyncValue.loading();

    final result = await _syncUseCase.syncGroup(group);

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      _ref.invalidate(taxonomiesByGroupProvider(group));
      state = AsyncValue.data(syncResult);
    } else {
      final e = (result as Failure).error;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// إعادة تعيين ومزامنة
  Future<void> resetAndSync() async {
    state = const AsyncValue.loading();
    _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;

    final result = await _syncUseCase.resetAndSync();

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = syncResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      state = AsyncValue.data(syncResult);
    } else {
      final e = (result as Failure).error;
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.error;
      _ref.read(taxonomyErrorMessageProvider.notifier).state = e.message;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final taxonomySyncNotifierProvider =
    StateNotifierProvider<TaxonomySyncNotifier, AsyncValue<TaxonomySyncResult?>>((ref) {
  return TaxonomySyncNotifier(
    ref.watch(syncTaxonomiesUseCaseProvider),
    ref,
  );
});

// ═══════════════════════════════════════════════════════════════
// 🛠️ Utility Providers
// ═══════════════════════════════════════════════════════════════

/// الحصول على تصنيفات dropdown جاهزة
final taxonomyDropdownItemsProvider = FutureProvider.family<List<TaxonomyDropdownItem>, TaxonomyGroup>(
  (ref, group) async {
    final taxonomies = await ref.watch(taxonomiesByGroupProvider(group).future);
    return taxonomies
        .where((t) => t.isActive && !t.isDeleted)
        .map((t) => TaxonomyDropdownItem(
              id: t.id,
              code: t.code,
              label: t.label,
              labelEn: t.labelEn,
            ))
        .toList();
  },
);

/// عنصر Dropdown للتصنيف
class TaxonomyDropdownItem {
  final String id;
  final String code;
  final String label;
  final String? labelEn;

  const TaxonomyDropdownItem({
    required this.id,
    required this.code,
    required this.label,
    this.labelEn,
  });

  @override
  String toString() => label;
}
