import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/firestore_local_cache_store.dart';
import '../../../../core/providers/providers.dart';
import '../../data/repositories/association_firestore_repository.dart';
import '../../data/services/association_firestore_service.dart';

final firestoreLocalCacheStoreProvider = Provider<FirestoreLocalCacheStore>((ref) {
  final db = ref.watch(databaseProvider);
  return FirestoreLocalCacheStore(db);
});

final associationFirestoreServiceProvider = Provider<AssociationFirestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  final store = ref.watch(firestoreLocalCacheStoreProvider);
  return AssociationFirestoreService(database: db, localStore: store);
});

final associationFirestoreRepositoryProvider = Provider<AssociationFirestoreRepository>((ref) {
  final service = ref.watch(associationFirestoreServiceProvider);
  return AssociationFirestoreRepositoryImpl(service);
});
