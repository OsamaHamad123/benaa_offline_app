import '../entities/visit_entity.dart';
import '../repositories/visit_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Use Case: Create Visit
class CreateVisit {
  final VisitRepository repository;

  const CreateVisit(this.repository);

  Future<Result<void>> call(VisitEntity visit) async {
    return await repository.createVisit(visit);
  }
}
