import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/backend/backend_config.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/local_file_number_pool_repository.dart';
import '../../data/services/firestore_file_number_service.dart';
import '../../data/datasources/file_id_remote_datasource.dart';
import '../../data/repositories/file_id_reservation_repository_impl.dart';
import '../../domain/repositories/file_id_reservation_repository.dart';
import '../../services/file_id_service.dart';

/// Legacy REST codes/file-id sync enablement.
///
/// Defaults to disabled for Firebase migration.
/// Re-enable only when ALL conditions are true:
/// 1) --dart-define=ENABLE_LEGACY_FILEID_SYNC=true
/// 2) BACKEND_FLAVOR is not firebase
/// 3) apiBaseUrl is not the disabled placeholder host
final legacyFileIdSyncEnabledProvider = Provider<bool>((ref) {
  const explicitlyEnabled = bool.fromEnvironment('ENABLE_LEGACY_FILEID_SYNC');
  if (!explicitlyEnabled) {
    return false;
  }

  final backendIsFirebase = BackendConfig.current.flavor == BackendFlavor.firebase;
  if (backendIsFirebase) {
    return false;
  }

  final appConfig = ref.watch(appConfigProvider).requireValue;
  final baseUrl = appConfig.apiBaseUrl.trim().toLowerCase();
  final isDisabledPlaceholder = baseUrl.contains('disabled-api.example.com');
  if (isDisabledPlaceholder) {
    return false;
  }

  return true;
});

/// 🌐 File ID Remote Data Source Provider
final fileIdRemoteDataSourceProvider = Provider<FileIdRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FileIdRemoteDataSourceImpl(apiClient.dio);
});

/// 🗄️ File ID Reservation Repository Provider
final fileIdReservationRepositoryProvider = Provider<FileIdReservationRepository>((ref) {
  final remote = ref.watch(fileIdRemoteDataSourceProvider);
  final db = ref.watch(databaseProvider);
  final legacySyncEnabled = ref.watch(legacyFileIdSyncEnabledProvider);
  return FileIdReservationRepositoryImpl(
    remoteDataSource: remote,
    localDao: db.fileIdReservationDao,
    legacyRemoteSyncEnabled: legacySyncEnabled,
  );
});

final localFileNumberPoolRepositoryProvider = Provider<LocalFileNumberPoolRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalFileNumberPoolRepository(db);
});

final firestoreFileNumberServiceProvider = Provider<FirestoreFileNumberService>((ref) {
  return FirestoreFileNumberService();
});

class FileNumberPoolStatus {
  final int available;
  final int pendingAssigned;
  final int synced;
  final int conflicts;
  final String? rangeStart;
  final String? rangeEnd;
  final bool warning;
  final bool critical;

  const FileNumberPoolStatus({
    required this.available,
    required this.pendingAssigned,
    required this.synced,
    required this.conflicts,
    required this.rangeStart,
    required this.rangeEnd,
    required this.warning,
    required this.critical,
  });
}

final fileNumberPoolStatusProvider = FutureProvider<FileNumberPoolStatus>((ref) async {
  final service = ref.watch(fileIdServiceProvider);
  final diagnostics = await service.getDiagnostics();
  final snapshot = await service.getLocalPoolSnapshot();
  final available = diagnostics?.availableCount ?? 0;
  return FileNumberPoolStatus(
    available: available,
    pendingAssigned: diagnostics?.usedUnsyncedCount ?? 0,
    synced: snapshot?.synced ?? 0,
    conflicts: snapshot?.conflicts ?? 0,
    rangeStart: snapshot?.rangeStart,
    rangeEnd: snapshot?.rangeEnd,
    warning: available < 50,
    critical: available <= 0,
  );
});

/// 🆔 File ID Service Provider
final fileIdServiceProvider = Provider<FileIdService>((ref) {
  final repository = ref.watch(fileIdReservationRepositoryProvider);
  final localPoolRepository = ref.watch(localFileNumberPoolRepositoryProvider);
  final firestoreService = ref.watch(firestoreFileNumberServiceProvider);
  final config = ref.watch(appConfigProvider).requireValue;
  return FileIdService(
    repository,
    localPoolRepository: localPoolRepository,
    firestoreFileNumberService: firestoreService,
    secureStorage: SecureStorage(),
    lowThreshold: config.fileIdRenewThreshold,
    reserveBatchSize: config.fileIdReserveBatchSize,
  );
});
