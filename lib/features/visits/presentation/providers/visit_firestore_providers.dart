import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../associations/presentation/providers/association_firestore_providers.dart';
import '../../../../core/providers/providers.dart';
import '../../data/repositories/visit_firestore_repository.dart';
import '../../data/services/visit_firestore_service.dart';

final visitFirestoreServiceProvider = Provider<VisitFirestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  final localStore = ref.watch(firestoreLocalCacheStoreProvider);
  return VisitFirestoreService(database: db, localStore: localStore);
});

final visitFirestoreRepositoryProvider = Provider<VisitFirestoreRepository>((ref) {
  final service = ref.watch(visitFirestoreServiceProvider);
  return VisitFirestoreRepositoryImpl(service);
});
