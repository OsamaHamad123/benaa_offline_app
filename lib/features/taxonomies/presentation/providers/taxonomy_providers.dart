import 'dart:async';
import 'dart:developer' as developer;

import 'package:benaa_offline_app/core/error_handling/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/backend/backend_config.dart';
import '../../../../core/providers/providers.dart';
import '../../../../data/db/drift_database.dart' show AppDatabase;
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/repositories/taxonomy_repository.dart';
import '../../domain/usecases/taxonomy_usecases.dart';
import '../../data/datasources/taxonomy_remote_datasource.dart';
import '../../data/datasources/taxonomy_local_datasource.dart';
import '../../data/datasources/taxonomy_local_drift_datasource.dart';
import '../../data/dev/firestore_taxonomy_seeder.dart';
import '../../data/repositories/taxonomy_repository_impl.dart';
import '../../data/services/firestore_taxonomy_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'taxonomy_bridge_providers.dart';

// ═══════════════════════════════════════════════════════════════
// 📦 Dependency Injection Providers
// ═══════════════════════════════════════════════════════════════

/// Database Provider for taxonomy local storage (single source of truth)
final taxonomyDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('AppDatabase must be overridden in ProviderScope');
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
  final db = ref.watch(taxonomyDatabaseProvider);
  return TaxonomyLocalDriftDataSource(db.taxonomiesDao, db.syncMetadataDao);
});

/// Legacy taxonomy REST sync enablement.
///
/// Re-enable only when ALL conditions are true:
/// 1) --dart-define=ENABLE_LEGACY_TAXONOMY_REST_SYNC=true
/// 2) BACKEND_FLAVOR is not firebase
/// 3) apiBaseUrl is not the disabled placeholder host
final legacyTaxonomyRestSyncEnabledProvider = Provider<bool>((ref) {
  const explicitlyEnabled = bool.fromEnvironment('ENABLE_LEGACY_TAXONOMY_REST_SYNC');
  if (!explicitlyEnabled) {
    return false;
  }

  final backendIsFirebase = BackendConfig.current.flavor == BackendFlavor.firebase;
  if (backendIsFirebase) {
    return false;
  }

  final appConfigState = ref.watch(appConfigProvider);
  final appConfig = appConfigState.asData?.value;
  if (appConfig == null) {
    return false;
  }

  final baseUrl = appConfig.apiBaseUrl.trim().toLowerCase();
  final isDisabledPlaceholder = baseUrl.contains('disabled-api.example.com');
  if (isDisabledPlaceholder) {
    return false;
  }

  return true;
});

final firestoreTaxonomyServiceProvider = Provider<FirestoreTaxonomyService>((ref) {
  return FirestoreTaxonomyService();
});

final firestoreTaxonomySeederProvider = Provider<FirestoreTaxonomySeeder>((ref) {
  return FirestoreTaxonomySeeder();
});

/// Manual Firestore seed is currently running.
final taxonomySeedInProgressProvider = StateProvider<bool>((ref) => false);

/// Manual Firestore seed has completed once in current app session.
final taxonomyHasSeededThisSessionProvider = StateProvider<bool>((ref) => false);

/// Lock for running taxonomy master sync once per upload action.
final isTaxonomyMasterSyncRunningProvider = StateProvider<bool>((ref) => false);

/// Repository Provider
final taxonomyRepositoryProvider = Provider<TaxonomyRepository>((ref) {
  return TaxonomyRepositoryImpl(
    remoteDataSource: ref.watch(taxonomyRemoteDataSourceProvider),
    localDataSource: ref.watch(taxonomyLocalDataSourceProvider),
    legacyRestSyncEnabled: ref.watch(legacyTaxonomyRestSyncEnabledProvider),
    firestoreTaxonomyService: ref.watch(firestoreTaxonomyServiceProvider),
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

final batchTaxonomyMutationUseCaseProvider = Provider<BatchTaxonomyMutationUseCase>((ref) {
  return BatchTaxonomyMutationUseCase(ref.watch(taxonomyRepositoryProvider));
});

// ═══════════════════════════════════════════════════════════════
// 📊 State Providers
// ═══════════════════════════════════════════════════════════════

/// حالة المزامنة
enum TaxonomySyncStatus { idle, syncing, success, error }

/// حالة المزامنة التلقائية في الخلفية (periodic/resume)
class TaxonomyAutoSyncState {
  final bool enabled;
  final bool inFlight;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final DateTime? nextAttemptAt;
  final int consecutiveFailures;
  final String? lastError;
  final String? lastSkipReason;

  const TaxonomyAutoSyncState({
    this.enabled = true,
    this.inFlight = false,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.nextAttemptAt,
    this.consecutiveFailures = 0,
    this.lastError,
    this.lastSkipReason,
  });

  TaxonomyAutoSyncState copyWith({
    bool? enabled,
    bool? inFlight,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
    DateTime? nextAttemptAt,
    int? consecutiveFailures,
    String? lastError,
    String? lastSkipReason,
    bool clearLastError = false,
    bool clearLastSkipReason = false,
    bool clearNextAttemptAt = false,
  }) {
    return TaxonomyAutoSyncState(
      enabled: enabled ?? this.enabled,
      inFlight: inFlight ?? this.inFlight,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      nextAttemptAt: clearNextAttemptAt ? null : (nextAttemptAt ?? this.nextAttemptAt),
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastSkipReason: clearLastSkipReason ? null : (lastSkipReason ?? this.lastSkipReason),
    );
  }
}

/// حالة المزامنة الحالية
final taxonomySyncStatusProvider = StateProvider<TaxonomySyncStatus>((ref) {
  return TaxonomySyncStatus.idle;
});

/// حالة المزامنة التلقائية الدورية
final taxonomyAutoSyncStateProvider = StateProvider<TaxonomyAutoSyncState>((ref) {
  return const TaxonomyAutoSyncState();
});

/// تعليق مزامنة التصنيفات مؤقتاً أثناء الشاشات الثقيلة (مثل نموذج إضافة/تعديل المستفيد)
final taxonomyAutoSyncSuspendedProvider = StateProvider<bool>((ref) => false);

/// Current route path used by sync guard logic.
final taxonomyAutoSyncRoutePathProvider = StateProvider<String>((ref) => '/');

/// Emergency mode enabled by runtime watchdog when UI lag bursts are detected.
final taxonomyAutoSyncEmergencyModeProvider = StateProvider<bool>((ref) => false);

bool isHeavyUiRouteForSync(String routePath) {
  final route = routePath.trim().toLowerCase();
  if (route.isEmpty) return false;

  if (route == '/beneficiaries/add') return true;
  if (route.endsWith('/edit') && route.contains('/beneficiaries/')) return true;

  return false;
}

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

  bool _ensureAuthenticated() {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      return true;
    }

    const message = 'يجب تسجيل الدخول قبل مزامنة التصنيفات.';
    _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.error;
    _ref.read(taxonomyErrorMessageProvider.notifier).state = message;
    state = AsyncValue.error(StateError(message), StackTrace.current);
    return false;
  }

  Future<void> _seedFirestoreFromLocalIfNeeded() async {
    try {
      await _ref.read(taxonomyFirestoreHydratorProvider).seedFromLocalIfFirestoreEmpty();
    } on FirestoreTaxonomyPermissionDeniedException catch (e) {
      final message = e.toString();
      _ref.read(taxonomyErrorMessageProvider.notifier).state = message;
      developer.log(message, name: 'TaxonomySync');
    } catch (e, st) {
      developer.log('Failed to seed Firestore from local taxonomy cache: $e', name: 'TaxonomySync', stackTrace: st);
    }
  }

  TaxonomySyncResult _buildSkippedResult({
    required String message,
    int hydratedCount = 0,
  }) {
    return TaxonomySyncResult(
      addedCount: hydratedCount,
      updatedCount: 0,
      deletedCount: 0,
      syncTime: DateTime.now(),
      success: true,
      message: message,
    );
  }

  /// مزامنة كاملة
  Future<void> sync() async {
    if (!_ensureAuthenticated()) {
      return;
    }

    final legacyRestEnabled = _ref.read(legacyTaxonomyRestSyncEnabledProvider);
    if (!legacyRestEnabled) {
      state = const AsyncValue.loading();
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;
      _ref.read(taxonomyErrorMessageProvider.notifier).state = null;

      final hydratedCount = await _ref.read(taxonomyFirestoreHydratorProvider).hydrateAllGroups();
      final skippedResult = _buildSkippedResult(
        message: hydratedCount > 0
            ? 'Legacy taxonomy REST sync is disabled. Taxonomies hydrated from Firestore.'
            : 'Legacy taxonomy REST sync is disabled. Firestore returned no records.',
        hydratedCount: hydratedCount,
      );

      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = skippedResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(lastSyncTimeProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);
      state = AsyncValue.data(skippedResult);
      return;
    }

    state = const AsyncValue.loading();
    _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;
    _ref.read(taxonomyErrorMessageProvider.notifier).state = null;

    final result = await _syncUseCase.call();

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      await _seedFirestoreFromLocalIfNeeded();
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = syncResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(lastSyncTimeProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);
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
    if (!_ensureAuthenticated()) {
      return;
    }

    final legacyRestEnabled = _ref.read(legacyTaxonomyRestSyncEnabledProvider);
    if (!legacyRestEnabled) {
      state = const AsyncValue.loading();

      final hydratedCount = await _ref.read(taxonomyFirestoreHydratorProvider).hydrateGroup(group);
      final skippedResult = _buildSkippedResult(
        message: hydratedCount > 0
            ? 'Legacy taxonomy REST sync is disabled. Group hydrated from Firestore.'
            : 'Legacy taxonomy REST sync is disabled. No Firestore records found for this group.',
        hydratedCount: hydratedCount,
      );

      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider(group));
      state = AsyncValue.data(skippedResult);
      return;
    }

    state = const AsyncValue.loading();

    final result = await _syncUseCase.syncGroup(group);

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      await _seedFirestoreFromLocalIfNeeded();
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider(group));
      state = AsyncValue.data(syncResult);
    } else {
      final e = (result as Failure).error;
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// إعادة تعيين ومزامنة
  Future<void> resetAndSync() async {
    if (!_ensureAuthenticated()) {
      return;
    }

    final legacyRestEnabled = _ref.read(legacyTaxonomyRestSyncEnabledProvider);
    if (!legacyRestEnabled) {
      state = const AsyncValue.loading();
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;

      final hydratedCount = await _ref.read(taxonomyFirestoreHydratorProvider).hydrateAllGroups();
      final skippedResult = _buildSkippedResult(
        message: hydratedCount > 0
            ? 'Legacy taxonomy REST sync is disabled. Reset/hydration completed from Firestore.'
            : 'Legacy taxonomy REST sync is disabled. Firestore returned no records.',
        hydratedCount: hydratedCount,
      );

      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = skippedResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(lastSyncTimeProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);
      state = AsyncValue.data(skippedResult);
      return;
    }

    state = const AsyncValue.loading();
    _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.syncing;

    final result = await _syncUseCase.resetAndSync();

    if (result.isSuccess) {
      final syncResult = (result as Success<TaxonomySyncResult>).value;
      await _seedFirestoreFromLocalIfNeeded();
      _ref.read(taxonomySyncStatusProvider.notifier).state = TaxonomySyncStatus.success;
      _ref.read(lastSyncResultProvider.notifier).state = syncResult;
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(lastSyncTimeProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);
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

/// تنفيذ عمليات CRUD/Batch على التصنيفات
class TaxonomyCrudNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TaxonomyCrudNotifier(this._ref) : super(const AsyncData(null));

  Future<Result<Taxonomy>> create(Taxonomy taxonomy) async {
    state = const AsyncLoading();
    final useCase = _ref.read(createTaxonomyUseCaseProvider);
    final result = await useCase.call(taxonomy);
    _handleMutationResult(result);
    return result;
  }

  Future<Result<Taxonomy>> update(Taxonomy taxonomy) async {
    state = const AsyncLoading();
    final useCase = _ref.read(updateTaxonomyUseCaseProvider);
    final result = await useCase.call(taxonomy);
    _handleMutationResult(result);
    return result;
  }

  Future<Result<void>> delete(String id) async {
    state = const AsyncLoading();
    final useCase = _ref.read(deleteTaxonomyUseCaseProvider);
    final result = await useCase.call(id);
    _handleMutationResult(result);
    return result;
  }

  Future<Result<List<Taxonomy>>> createBatch(
    TaxonomyGroup group,
    List<String> names,
  ) async {
    state = const AsyncLoading();
    final useCase = _ref.read(batchTaxonomyMutationUseCaseProvider);
    final result = await useCase.create(group, names);
    _handleMutationResult(result);
    return result;
  }

  Future<Result<List<Taxonomy>>> updateBatch(
    TaxonomyGroup group,
    Map<String, String> updates,
  ) async {
    state = const AsyncLoading();
    final useCase = _ref.read(batchTaxonomyMutationUseCaseProvider);
    final result = await useCase.update(group, updates);
    _handleMutationResult(result);
    return result;
  }

  Future<Result<List<String>>> deleteBatch(
    TaxonomyGroup group,
    List<String> ids,
  ) async {
    state = const AsyncLoading();
    final useCase = _ref.read(batchTaxonomyMutationUseCaseProvider);
    final result = await useCase.delete(group, ids);
    _handleMutationResult(result);
    return result;
  }

  void _handleMutationResult<T>(Result<T> result) {
    if (result.isSuccess) {
      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);
      state = const AsyncData(null);
      return;
    }

    final error = (result as Failure).error;
    _ref.read(taxonomyErrorMessageProvider.notifier).state = error.message;
    state = AsyncError(error, StackTrace.current);
  }
}

final taxonomyCrudNotifierProvider = StateNotifierProvider<TaxonomyCrudNotifier, AsyncValue<void>>((ref) {
  return TaxonomyCrudNotifier(ref);
});

// ═══════════════════════════════════════════════════════════════
// 🔥 Firestore Taxonomy Integration (Minimal Safe)
// ═══════════════════════════════════════════════════════════════

final taxonomyFirestoreHydratorProvider = Provider<TaxonomyFirestoreHydrator>((ref) {
  final hydrator = TaxonomyFirestoreHydrator(ref);
  ref.onDispose(hydrator.dispose);
  return hydrator;
});

class TaxonomyFirestoreHydrator {
  final Ref _ref;
  final Map<TaxonomyGroup, StreamSubscription<List<Taxonomy>>> _groupSubscriptions =
      <TaxonomyGroup, StreamSubscription<List<Taxonomy>>>{};
  final Set<String> _permissionDeniedLoggedCollections = <String>{};
  final Set<TaxonomyGroup> _emptyGroupWatchLogged = <TaxonomyGroup>{};

  TaxonomyFirestoreHydrator(this._ref);

  void _setPermissionDeniedMessage(String collectionName) {
    final message =
        'Firestore taxonomy permission denied. Check Firestore rules for taxonomy_categories and confirm the app is connected to the correct Firebase project.';
    _ref.read(taxonomyErrorMessageProvider.notifier).state = message;
    if (_permissionDeniedLoggedCollections.add(collectionName)) {
      developer.log(message, name: 'TaxonomyFirestore');
      developer.log(
        'Check Firebase Console → App Check → Firestore enforcement. Disable enforcement for development or configure DebugAppCheckProvider.',
        name: 'TaxonomyFirestore',
      );
    }
  }

  Future<int> hydrateAllGroups() async {
    var total = 0;
    for (final group in TaxonomyGroup.values) {
      total += await hydrateGroup(group);
    }
    return total;
  }

  Future<void> ensureRealtimeGroupSync(TaxonomyGroup group) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return;
    }

    if (_groupSubscriptions.containsKey(group)) {
      return;
    }

    final service = _ref.read(firestoreTaxonomyServiceProvider);
    developer.log('Firestore taxonomy watch started: group=${group.value}', name: 'TaxonomyFirestore');

    final subscription = service.watchByGroup(group).listen(
      (remoteItems) async {
        if (remoteItems.isEmpty) {
          if (_emptyGroupWatchLogged.add(group)) {
            developer.log('Firestore taxonomy watch empty group: group=${group.value}', name: 'TaxonomyFirestore');
          }
          return;
        }

        _emptyGroupWatchLogged.remove(group);

        final repository = _ref.read(taxonomyRepositoryProvider);
        final result = await repository.upsertTaxonomies(remoteItems);
        if (!result.isSuccess) {
          return;
        }

        _ref.invalidate(allTaxonomiesProvider);
        _ref.invalidate(taxonomyStatisticsProvider);
        _ref.invalidate(lastSyncTimeProvider);
        _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
        _ref.invalidate(taxonomiesByGroupProvider);
      },
      onError: (error, _) {
        if (error is FirestoreTaxonomyPermissionDeniedException) {
          _setPermissionDeniedMessage(service.collectionName);
          return;
        }
        developer.log('Firestore taxonomy watch failed for ${group.value}: $error', name: 'TaxonomyFirestore');
      },
    );

    _groupSubscriptions[group] = subscription;
  }

  void dispose() {
    for (final subscription in _groupSubscriptions.values) {
      subscription.cancel();
    }
    _groupSubscriptions.clear();
  }

  Future<int> hydrateGroup(TaxonomyGroup group) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return 0;
    }

    final service = _ref.read(firestoreTaxonomyServiceProvider);
    try {
      final remoteItems = await service.fetchByGroup(group);
      if (remoteItems.isEmpty) {
        return 0;
      }

      final repository = _ref.read(taxonomyRepositoryProvider);
      final result = await repository.upsertTaxonomies(remoteItems);
      if (!result.isSuccess) {
        return 0;
      }

      _ref.invalidate(allTaxonomiesProvider);
      _ref.invalidate(taxonomyStatisticsProvider);
      _ref.invalidate(lastSyncTimeProvider);
      _ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
      _ref.invalidate(taxonomiesByGroupProvider);

      return remoteItems.length;
    } on FirestoreTaxonomyPermissionDeniedException {
      _setPermissionDeniedMessage(service.collectionName);
      return 0;
    }
  }

  Future<int> seedFromLocalIfFirestoreEmpty({List<TaxonomyGroup>? groups}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return 0;
    }

    final targetGroups = groups ?? TaxonomyGroup.values;
    final repository = _ref.read(taxonomyRepositoryProvider);
    final service = _ref.read(firestoreTaxonomyServiceProvider);

    var seeded = 0;

    for (final group in targetGroups) {
      final localResult = await repository.getTaxonomiesByGroup(group);
      if (!localResult.isSuccess) {
        continue;
      }

      final localItems = (localResult as Success<List<Taxonomy>>).value;
      if (localItems.isEmpty) {
        continue;
      }

      try {
        seeded += await service.seedGroupIfEmpty(group, localItems);
      } on FirestoreTaxonomyPermissionDeniedException {
        _setPermissionDeniedMessage(service.collectionName);
        return seeded;
      }
    }

    return seeded;
  }
}

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
