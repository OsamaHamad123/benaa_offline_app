import '../../../../core/error_handling/result.dart';
import '../entities/representative.dart';
import '../repositories/association_repository.dart';

/// 📋 Get All Representatives Use Case
class GetAllRepresentativesUseCase {
  final AssociationRepository repository;

  GetAllRepresentativesUseCase(this.repository);

  Future<Result<List<Representative>>> execute() async {
    return await repository.getAllRepresentatives();
  }
}
