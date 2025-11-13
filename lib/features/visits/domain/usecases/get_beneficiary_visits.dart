import '../entities/visit_entity.dart';
import '../repositories/visit_repository.dart';

/// Use Case: Get Beneficiary Visits
class GetBeneficiaryVisits {
  final VisitRepository repository;

  const GetBeneficiaryVisits(this.repository);

  Future<List<VisitEntity>> call(String beneficiaryId) async {
    return await repository.getBeneficiaryVisits(beneficiaryId);
  }
}
