import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../repositories/association_repository.dart';

/// 🔍 Get Association By ID Use Case
class GetAssociationByIdUseCase {
  final AssociationRepository repository;

  GetAssociationByIdUseCase(this.repository);

  Future<Result<Association>> execute(String id) async {
    if (id.trim().isEmpty) {
      return const Failure(ValidationFailure('معرف الجمعية مطلوب'));
    }

    return await repository.getAssociationById(id);
  }
}
