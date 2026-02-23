import '../../../../core/error_handling/result.dart';
import '../entities/representative.dart';
import '../repositories/association_repository.dart';

/// ➕ Create Representative Use Case
class CreateRepresentativeUseCase {
  final AssociationRepository repository;

  CreateRepresentativeUseCase(this.repository);

  Future<Result<Representative>> execute(String name) async {
    // Validation
    if (name.trim().isEmpty) {
      return const Failure(ValidationFailure('اسم المندوب مطلوب'));
    }

    // Create
    return await repository.createRepresentative(name.trim());
  }
}
