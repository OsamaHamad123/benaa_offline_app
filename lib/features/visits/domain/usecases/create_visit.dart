import '../entities/visit_entity.dart';
import '../repositories/visit_repository.dart';

/// Use Case: Create Visit
class CreateVisit {
  final VisitRepository repository;

  const CreateVisit(this.repository);

  Future<void> call(VisitEntity visit) async {
    return await repository.createVisit(visit);
  }
}
