import '../entities/visit_entity.dart';
import '../repositories/visit_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Use Case: Get Beneficiary Visits
class GetBeneficiaryVisits {
  final VisitRepository repository;

  const GetBeneficiaryVisits(this.repository);

  Future<Result<List<VisitEntity>>> call(String beneficiaryId) async {
    return await repository.getBeneficiaryVisits(beneficiaryId);
  }
}
