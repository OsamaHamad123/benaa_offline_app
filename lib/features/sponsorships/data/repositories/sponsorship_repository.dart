import '../../../../core/sync/module_sync_stats.dart';
import '../../domain/services/sponsorship_candidate_matcher.dart';
import '../models/sponsorship_models.dart';
import '../services/sponsorship_firestore_service.dart';

abstract class SponsorshipRepository {
  Future<void> upsertSponsorshipFileLocal(SponsorshipFileModel model);
  Future<void> upsertCandidateLocal(SponsorshipCandidateModel model);
  Future<void> upsertSponsorshipLocal(SponsorshipModel model);
  Future<void> upsertSponsorshipPaymentLocal(SponsorshipPaymentModel model);
  Future<CandidateMatchResult> runCandidateMatching({required String candidateLocalId});
  Future<int> createBeneficiaryFromCandidate({required String candidateLocalId});
  Future<ModuleSyncStats> uploadPendingCore();
  Future<ModuleSyncStats> downloadCore();
}

class SponsorshipRepositoryImpl implements SponsorshipRepository {
  SponsorshipRepositoryImpl(this._service);

  final SponsorshipFirestoreService _service;

  @override
  Future<void> upsertSponsorshipFileLocal(SponsorshipFileModel model) => _service.upsertSponsorshipFileLocal(model);

  @override
  Future<void> upsertCandidateLocal(SponsorshipCandidateModel model) => _service.upsertCandidateLocal(model);

  @override
  Future<void> upsertSponsorshipLocal(SponsorshipModel model) => _service.upsertSponsorshipLocal(model);

  @override
  Future<void> upsertSponsorshipPaymentLocal(SponsorshipPaymentModel model) =>
      _service.upsertSponsorshipPaymentLocal(model);

  @override
  Future<CandidateMatchResult> runCandidateMatching({required String candidateLocalId}) =>
      _service.runCandidateMatching(candidateLocalId: candidateLocalId);

  @override
  Future<int> createBeneficiaryFromCandidate({required String candidateLocalId}) =>
      _service.createBeneficiaryFromCandidate(candidateLocalId: candidateLocalId);

  @override
  Future<ModuleSyncStats> uploadPendingCore() => _service.uploadPendingCore();

  @override
  Future<ModuleSyncStats> downloadCore() => _service.downloadCore();
}
