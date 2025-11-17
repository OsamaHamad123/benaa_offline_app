import '../../data/datasources/beneficiary_local_datasource.dart';

/// 📊 Get Beneficiaries Statistics Use Case
///
/// Returns statistics about beneficiaries
class GetBeneficiariesStatisticsUseCase {
  final BeneficiaryLocalDataSource dataSource;

  const GetBeneficiariesStatisticsUseCase(this.dataSource);

  /// Execute - get all statistics
  Future<Map<String, int>> execute() async {
    try {
      return await dataSource.getStatistics();
    } catch (e) {
      throw Exception('فشل في جلب الإحصائيات: ${e.toString()}');
    }
  }
}
