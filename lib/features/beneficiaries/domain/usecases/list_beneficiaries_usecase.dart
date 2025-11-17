import '../../../../data/db/drift_database.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';

/// 📋 List Beneficiaries Use Case
///
/// Handles business logic for listing beneficiaries with filtering
class ListBeneficiariesUseCase {
  final BeneficiaryLocalDataSource dataSource;

  const ListBeneficiariesUseCase(this.dataSource);

  /// Get paginated beneficiaries list with filters
  Future<List<Beneficiary>> execute({
    String? searchQuery,
    int? category,
    int? gender,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final models = await dataSource.list(
        searchQuery: searchQuery,
        category: category,
        gender: gender,
        offset: page * pageSize,
        limit: pageSize,
      );

      // Models already return Drift Beneficiary entities
      return models.map((m) => m as Beneficiary).toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة المستفيدين: ${e.toString()}');
    }
  }
}
