import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../repositories/association_repository.dart';

/// 🔍 Search Associations Use Case
class SearchAssociationsUseCase {
  final AssociationRepository repository;

  SearchAssociationsUseCase(this.repository);

  Future<Result<List<Association>>> execute(String query) async {
    if (query.trim().isEmpty) {
      // إذا كان البحث فارغ، إرجاع جميع الجمعيات النشطة
      return await repository.getAllActiveAssociations();
    }

    return await repository.searchAssociations(query.trim());
  }
}
