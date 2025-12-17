import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../repositories/association_repository.dart';

/// ✏️ Update Association Use Case
class UpdateAssociationUseCase {
  final AssociationRepository repository;

  UpdateAssociationUseCase(this.repository);

  Future<Result<Association>> execute(Association association) async {
    // Validation
    if (!association.isValid) {
      return Failure(ValidationFailure('بيانات الجمعية غير صحيحة'));
    }

    // Update
    return await repository.updateAssociation(association);
  }
}
