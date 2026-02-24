import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/sync/data/datasources/local_sync_datasource.dart';
import '../../../../core/sync/data/datasources/remote_sync_datasource.dart';
import '../../../../core/sync/data/repositories/sync_repository_impl.dart';
import '../../../../core/sync/mobile_sync_service.dart';
import '../../../taxonomies/presentation/providers/taxonomy_providers.dart';
import '../../domain/usecases/mobile_sync_operations_usecases.dart';
import '../../domain/usecases/sync_associations_module_usecase.dart';
import '../../domain/usecases/sync_related_entities_up_usecase.dart';
import '../../domain/usecases/tombstone_delete_sync_usecase.dart';
import '../../../associations/data/datasources/associations_remote_sync_datasource.dart';
import '../../domain/utils/api_endpoint_normalizer.dart' as sync_endpoint;
import 'file_id_providers.dart';

final syncRelatedEntitiesUpUseCaseProvider = Provider<SyncRelatedEntitiesUpUseCase>((ref) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);

  return SyncRelatedEntitiesUpUseCase(
    database: database,
    dio: apiClient.dio,
    normalizeApiEndpoint: (endpoint) => sync_endpoint.normalizeApiEndpoint(
      endpoint: endpoint,
      baseUrl: apiClient.dio.options.baseUrl,
    ),
  );
});

final associationsRemoteSyncDataSourceProvider = Provider<AssociationsRemoteSyncDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AssociationsRemoteSyncDataSource(apiClient.dio);
});

final syncAssociationsModuleUseCaseProvider = Provider<SyncAssociationsModuleUseCase>((ref) {
  final database = ref.watch(databaseProvider);
  final remote = ref.watch(associationsRemoteSyncDataSourceProvider);

  return SyncAssociationsModuleUseCase(
    database: database,
    remote: remote,
  );
});

final mobileSyncServiceProvider = Provider<MobileSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = SecureStorage();
  final fileIdService = ref.watch(fileIdServiceProvider);
  final taxonomyRepository = ref.watch(taxonomyRepositoryProvider);
  final tombstoneDeleteSyncUseCase = ref.watch(tombstoneDeleteSyncUseCaseProvider);
  final syncRelatedEntitiesUpUseCase = ref.watch(syncRelatedEntitiesUpUseCaseProvider);
  final syncAssociationsModuleUseCase = ref.watch(syncAssociationsModuleUseCaseProvider);
  final unifiedSyncRepository = SyncRepositoryImpl(
    remote: RemoteSyncDataSource(apiClient.dio),
    local: LocalSyncDataSource(
      taxonomiesDao: database.taxonomiesDao,
      beneficiariesDao: database.beneficiariesDao,
      syncMetadataDao: database.syncMetadataDao,
      syncDao: database.syncDao,
    ),
  );

  return MobileSyncService(
    database,
    secureStorage,
    dio: apiClient.dio,
    fileIdService: fileIdService,
    taxonomyRepository: taxonomyRepository,
    syncRepository: unifiedSyncRepository,
    tombstoneDeleteSyncUseCase: tombstoneDeleteSyncUseCase,
    syncRelatedEntitiesUpUseCase: syncRelatedEntitiesUpUseCase,
    syncAssociationsModuleUseCase: syncAssociationsModuleUseCase,
  );
});

final tombstoneDeleteSyncUseCaseProvider = Provider<TombstoneDeleteSyncUseCase>((ref) {
  final database = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);

  return TombstoneDeleteSyncUseCase(
    syncDao: database.syncDao,
    dio: apiClient.dio,
    normalizeApiEndpoint: (endpoint) => sync_endpoint.normalizeApiEndpoint(
      endpoint: endpoint,
      baseUrl: apiClient.dio.options.baseUrl,
    ),
  );
});

final mobileSyncDownUseCaseProvider = Provider<MobileSyncDownUseCase>((ref) {
  final service = ref.watch(mobileSyncServiceProvider);
  return MobileSyncDownUseCase(service);
});

final mobileSyncUpUseCaseProvider = Provider<MobileSyncUpUseCase>((ref) {
  final service = ref.watch(mobileSyncServiceProvider);
  return MobileSyncUpUseCase(service);
});

final mobileSyncRecordByFileIdUseCaseProvider = Provider<MobileSyncRecordByFileIdUseCase>((ref) {
  final service = ref.watch(mobileSyncServiceProvider);
  return MobileSyncRecordByFileIdUseCase(service);
});

final mobileOfficialSyncUseCaseProvider = Provider<MobileOfficialSyncUseCase>((ref) {
  final syncDown = ref.watch(mobileSyncDownUseCaseProvider);
  final syncUp = ref.watch(mobileSyncUpUseCaseProvider);
  return MobileOfficialSyncUseCase(syncDown: syncDown, syncUp: syncUp);
});
