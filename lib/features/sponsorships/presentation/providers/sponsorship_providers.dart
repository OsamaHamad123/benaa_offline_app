import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../associations/presentation/providers/association_firestore_providers.dart';
import '../../../sync/presentation/providers/file_id_providers.dart';
import '../../data/repositories/sponsorship_repository.dart';
import '../../data/services/sponsorship_firestore_service.dart';

final sponsorshipFirestoreServiceProvider = Provider<SponsorshipFirestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  final localStore = ref.watch(firestoreLocalCacheStoreProvider);
  final fileIdService = ref.watch(fileIdServiceProvider);
  return SponsorshipFirestoreService(
    database: db,
    localStore: localStore,
    fileIdService: fileIdService,
  );
});

final sponsorshipRepositoryProvider = Provider<SponsorshipRepository>((ref) {
  final service = ref.watch(sponsorshipFirestoreServiceProvider);
  return SponsorshipRepositoryImpl(service);
});
