import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../domain/repositories/i_sync_repository.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/usecases/delta_sync_usecase.dart';
import '../../domain/usecases/full_sync_usecase.dart';
import '../../domain/usecases/push_changes_usecase.dart';
import '../../domain/usecases/resolve_conflicts_usecase.dart';
import '../../data/datasources/local_sync_datasource.dart';
import '../../data/datasources/remote_sync_datasource.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../../../data/db/drift_database.dart';
import '../../../network/api_client.dart';

// ═══════════════════════════════════════════════════════════════════════
// 🔌 INFRASTRUCTURE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

/// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient provider must be overridden');
});

/// Dio Provider (from ApiClient)
final dioProvider = Provider<Dio>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.dio;
});

// ═══════════════════════════════════════════════════════════════════════
// 📊 DATA SOURCES PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

/// Remote Sync DataSource Provider
final remoteSyncDataSourceProvider = Provider<RemoteSyncDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return RemoteSyncDataSource(dio);
});

/// Local Sync DataSource Provider
final localSyncDataSourceProvider = Provider<LocalSyncDataSource>((ref) {
  final db = ref.watch(databaseProvider);

  return LocalSyncDataSource(
    taxonomiesDao: db.taxonomiesDao,
    beneficiariesDao: db.beneficiariesDao,
    syncMetadataDao: db.syncMetadataDao,
    syncDao: db.syncDao,
  );
});

// ═══════════════════════════════════════════════════════════════════════
// 🗄️ REPOSITORY PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

/// Sync Repository Provider
final syncRepositoryProvider = Provider<ISyncRepository>((ref) {
  final remote = ref.watch(remoteSyncDataSourceProvider);
  final local = ref.watch(localSyncDataSourceProvider);

  return SyncRepositoryImpl(remote: remote, local: local);
});

// ═══════════════════════════════════════════════════════════════════════
// 🎯 USE CASES PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

/// Delta Sync Use Case Provider
final deltaSyncUseCaseProvider = Provider<DeltaSyncUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return DeltaSyncUseCase(repository);
});

/// Full Sync Use Case Provider
final fullSyncUseCaseProvider = Provider<FullSyncUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return FullSyncUseCase(repository);
});

/// Push Changes Use Case Provider
final pushChangesUseCaseProvider = Provider<PushChangesUseCase>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return PushChangesUseCase(repository);
});

/// Resolve Conflicts Use Case Provider
final resolveConflictsUseCaseProvider = Provider<ResolveConflictsUseCase>((
  ref,
) {
  final repository = ref.watch(syncRepositoryProvider);
  return ResolveConflictsUseCase(repository);
});

// ═══════════════════════════════════════════════════════════════════════
// 🏷️ TAXONOMY PROVIDERS (Reactive Streams)
// ═══════════════════════════════════════════════════════════════════════

/// Categories Provider (يتيم، أرملة، فقير، معاق)
final categoriesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('category');
});

/// Marital Status Provider (أعزب، متزوج، مطلق، أرمل)
final maritalStatusesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('marital_status');
});

/// Education Levels Provider
final educationLevelsProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('education_level');
});

/// Health Statuses Provider
final healthStatusesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('health_status');
});

/// Genders Provider
final gendersProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('gender');
});

/// Governorates Provider (محافظات)
final governoratesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('governorate');
});

/// Displacement Statuses Provider
final displacementStatusesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('displacement_status');
});

/// Employment Statuses Provider
final employmentStatusesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('employment_status');
});

/// Housing Statuses Provider
final housingStatusesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('housing_status');
});

/// Housing Types Provider
final housingTypesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.taxonomiesDao.watchByGroup('housing_type');
});

// ═══════════════════════════════════════════════════════════════════════
// 📊 SYNC STATE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

/// Last Sync Time Provider
final lastSyncTimeProvider = FutureProvider.family<DateTime?, String>((
  ref,
  entityType,
) async {
  final repository = ref.watch(syncRepositoryProvider);
  return await repository.getLastSyncTime(entityType);
});

/// Pending Changes Count Provider
final pendingChangesCountProvider = FutureProvider.family<int, String>((
  ref,
  entityType,
) async {
  final repository = ref.watch(syncRepositoryProvider);
  return await repository.getPendingChangesCount(entityType);
});

/// Total Pending Changes Provider (all entities)
final totalPendingChangesProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(syncRepositoryProvider);

  int total = 0;
  for (final entityType in ['beneficiaries', 'visits', 'attachments']) {
    total += await repository.getPendingChangesCount(entityType);
  }

  return total;
});

/// Taxonomy Statistics Provider
final taxonomyStatisticsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  return await db.taxonomiesDao.getStatistics();
});

// ═══════════════════════════════════════════════════════════════════════
// 🔄 SYNC OPERATIONS PROVIDERS (StateNotifier for UI control)
// ═══════════════════════════════════════════════════════════════════════

/// Sync State
enum SyncStatus { idle, syncing, success, error }

/// Sync State Data
class SyncState {
  final SyncStatus status;
  final String? message;
  final int? itemsSynced;
  final String? error;

  const SyncState({
    required this.status,
    this.message,
    this.itemsSynced,
    this.error,
  });

  const SyncState.idle() : this(status: SyncStatus.idle);
  const SyncState.syncing(String message)
      : this(status: SyncStatus.syncing, message: message);
  const SyncState.success({required int itemsSynced, String? message})
      : this(
          status: SyncStatus.success,
          itemsSynced: itemsSynced,
          message: message,
        );
  const SyncState.error(String error)
      : this(status: SyncStatus.error, error: error);

  bool get isIdle => status == SyncStatus.idle;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get isSuccess => status == SyncStatus.success;
  bool get isError => status == SyncStatus.error;
}

/// Sync Controller (for manual sync triggers)
class SyncController extends StateNotifier<SyncState> {
  final DeltaSyncUseCase _deltaSyncUseCase;
  final FullSyncUseCase _fullSyncUseCase;

  SyncController({
    required DeltaSyncUseCase deltaSyncUseCase,
    required FullSyncUseCase fullSyncUseCase,
  })  : _deltaSyncUseCase = deltaSyncUseCase,
        _fullSyncUseCase = fullSyncUseCase,
        super(const SyncState.idle());

  /// Perform Delta Sync
  Future<void> deltaSync(String entityType) async {
    state = SyncState.syncing('جارٍ المزامنة...');

    final result = await _deltaSyncUseCase.execute(entityType);

    result.when(
      success: (success) {
        state = SyncState.success(
          itemsSynced: success.itemsSynced,
          message: success.message,
        );
      },
      partial: (partial) {
        state = SyncState.success(
          itemsSynced: partial.successCount,
          message: 'مزامنة جزئية: ${partial.conflicts.length} تعارض',
        );
      },
      failure: (failure) {
        state = SyncState.error(failure.error);
      },
    );
  }

  /// Perform Full Sync (all entities)
  Future<void> fullSyncAll() async {
    state = const SyncState.syncing('جارٍ المزامنة الكاملة...');

    final results = await _fullSyncUseCase.executeAll();

    int totalSynced = 0;
    final errors = <String>[];

    for (final entry in results.entries) {
      final result = entry.value;
      if (result is SyncSuccess) {
        totalSynced += result.itemsSynced;
      } else if (result is SyncPartial) {
        totalSynced += result.successCount;
      } else if (result is SyncFailure) {
        errors.add('\${entry.key}: \${result.error}');
      }
    }

    if (errors.isEmpty) {
      state = SyncState.success(
        itemsSynced: totalSynced,
        message: 'اكتملت المزامنة الكاملة',
      );
    } else {
      state = SyncState.error(errors.join('\n'));
    }
  }

  /// Reset state
  void reset() {
    state = const SyncState.idle();
  }
}

/// Sync Controller Provider
final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>(
  (ref) {
    return SyncController(
      deltaSyncUseCase: ref.watch(deltaSyncUseCaseProvider),
      fullSyncUseCase: ref.watch(fullSyncUseCaseProvider),
    );
  },
);

// ═══════════════════════════════════════════════════════════════════════
// 🔧 HELPER EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════

extension SyncResultX on Object {
  T when<T>({
    required T Function(dynamic success) success,
    required T Function(dynamic partial) partial,
    required T Function(dynamic failure) failure,
  }) {
    if (this is SyncSuccess) {
      return success(this);
    } else if (this is SyncPartial) {
      return partial(this);
    } else {
      return failure(this);
    }
  }
}
