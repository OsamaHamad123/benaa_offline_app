import '../../../../core/sync/module_sync_stats.dart';
import '../models/beneficiary_visit_followup_models.dart';
import '../services/visit_firestore_service.dart';

abstract class VisitFirestoreRepository {
  Future<void> upsertVisitLocal(BeneficiaryVisitFirestoreModel model);
  Future<void> upsertFollowupLocal(BeneficiaryFollowupModel model);
  Future<ModuleSyncStats> uploadPendingVisits();
  Future<ModuleSyncStats> uploadPendingFollowups();
  Future<ModuleSyncStats> downloadVisits();
  Future<ModuleSyncStats> downloadFollowups();
}

class VisitFirestoreRepositoryImpl implements VisitFirestoreRepository {
  VisitFirestoreRepositoryImpl(this._service);

  final VisitFirestoreService _service;

  @override
  Future<void> upsertVisitLocal(BeneficiaryVisitFirestoreModel model) => _service.upsertVisitLocal(model);

  @override
  Future<void> upsertFollowupLocal(BeneficiaryFollowupModel model) => _service.upsertFollowupLocal(model);

  @override
  Future<ModuleSyncStats> uploadPendingVisits() => _service.uploadPendingVisits();

  @override
  Future<ModuleSyncStats> uploadPendingFollowups() => _service.uploadPendingFollowups();

  @override
  Future<ModuleSyncStats> downloadVisits() => _service.downloadVisits();

  @override
  Future<ModuleSyncStats> downloadFollowups() => _service.downloadFollowups();
}
