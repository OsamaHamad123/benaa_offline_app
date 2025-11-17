import '../../data/datasources/beneficiary_local_datasource.dart';

/// Use Case: Delete Beneficiary
class DeleteBeneficiaryUseCase {
  final BeneficiaryLocalDataSource _dataSource;

  DeleteBeneficiaryUseCase(this._dataSource);

  /// Execute deletion
  Future<void> execute(int beneficiaryId) async {
    await _dataSource.delete(beneficiaryId);
  }
}
