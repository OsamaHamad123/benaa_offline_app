import '../../../../core/error_handling/result.dart';
import '../repositories/association_repository.dart';

/// 🗑️ Delete Association Use Case
class DeleteAssociationUseCase {
  final AssociationRepository repository;

  DeleteAssociationUseCase(this.repository);

  /// Soft delete (تعطيل فقط)
  Future<Result<void>> execute(String id, {bool hardDelete = false}) async {
    if (id.trim().isEmpty) {
      return const Failure(ValidationFailure('معرف الجمعية مطلوب'));
    }

    if (hardDelete) {
      return await repository.deleteAssociation(id);
    } else {
      return await repository.deactivateAssociation(id);
    }
  }
}
