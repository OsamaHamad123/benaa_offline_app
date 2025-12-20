import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../repositories/association_repository.dart';

/// ➕ Create Association Use Case
class CreateAssociationUseCase {
  final AssociationRepository repository;

  CreateAssociationUseCase(this.repository);

  Future<Result<Association>> execute(AssociationParams params) async {
    // Validation
    if (!params.isValid) {
      return Failure(
        ValidationFailure(params.validationError ?? 'بيانات غير صحيحة'),
      );
    }

    // Create
    return await repository.createAssociation(params);
  }
}
