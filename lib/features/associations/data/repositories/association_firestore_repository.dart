import '../../../../core/sync/module_sync_stats.dart';
import '../models/association_firestore_model.dart';
import '../services/association_firestore_service.dart';

abstract class AssociationFirestoreRepository {
  Future<void> upsertAssociationLocal(AssociationFirestoreModel model);
  Future<void> upsertAssociationContactLocal(AssociationContactModel model);
  Future<ModuleSyncStats> uploadPendingAssociations();
  Future<ModuleSyncStats> uploadPendingContacts();
  Future<ModuleSyncStats> downloadAssociations();
  Future<ModuleSyncStats> downloadAssociationContacts();
  Future<List<AssociationFirestoreModel>> getLocalAssociations();
}

class AssociationFirestoreRepositoryImpl implements AssociationFirestoreRepository {
  AssociationFirestoreRepositoryImpl(this._service);

  final AssociationFirestoreService _service;

  @override
  Future<void> upsertAssociationLocal(AssociationFirestoreModel model) => _service.upsertAssociationLocal(model);

  @override
  Future<void> upsertAssociationContactLocal(AssociationContactModel model) =>
      _service.upsertAssociationContactLocal(model);

  @override
  Future<ModuleSyncStats> uploadPendingAssociations() => _service.uploadPendingAssociations();

  @override
  Future<ModuleSyncStats> uploadPendingContacts() => _service.uploadPendingContacts();

  @override
  Future<ModuleSyncStats> downloadAssociations() => _service.downloadAssociations();

  @override
  Future<ModuleSyncStats> downloadAssociationContacts() => _service.downloadAssociationContacts();

  @override
  Future<List<AssociationFirestoreModel>> getLocalAssociations() => _service.getLocalAssociations();
}
