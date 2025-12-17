import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../repositories/association_repository.dart';

/// 📋 Get All Active Associations Use Case
class GetAllActiveAssociationsUseCase {
  final AssociationRepository repository;

  GetAllActiveAssociationsUseCase(this.repository);

  Future<Result<List<Association>>> execute() async {
    return await repository.getAllActiveAssociations();
  }
}
