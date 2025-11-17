import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/models/beneficiary_model.dart';

/// Use Case: Get Beneficiary Details with all related data
class GetBeneficiaryDetailsUseCase {
  final BeneficiaryLocalDataSource _dataSource;

  GetBeneficiaryDetailsUseCase(this._dataSource);

  /// Execute - جلب تفاصيل المستفيد
  Future<BeneficiaryModel?> execute(int beneficiaryId) async {
    return await _dataSource.getById(beneficiaryId);
  }

  /// Get with validation - مع التحقق من صحة البيانات
  Future<BeneficiaryDetails> executeWithValidation(int beneficiaryId) async {
    final beneficiary = await _dataSource.getById(beneficiaryId);

    if (beneficiary == null) {
      throw BeneficiaryNotFoundException(beneficiaryId);
    }

    // يمكن إضافة تحقق إضافي هنا
    return BeneficiaryDetails(
      beneficiary: beneficiary,
      isSynced: beneficiary == 'synced',
      hasAttachments: false, // سيتم تحديثه لاحقاً
      hasVisits: false, // سيتم تحديثه لاحقاً
    );
  }
}

/// Model: Beneficiary Details with metadata
class BeneficiaryDetails {
  final BeneficiaryModel beneficiary;
  final bool isSynced;
  final bool hasAttachments;
  final bool hasVisits;

  BeneficiaryDetails({
    required this.beneficiary,
    required this.isSynced,
    required this.hasAttachments,
    required this.hasVisits,
  });
}

/// Exception: Beneficiary not found
class BeneficiaryNotFoundException implements Exception {
  final int beneficiaryId;

  BeneficiaryNotFoundException(this.beneficiaryId);

  @override
  String toString() => 'Beneficiary with ID $beneficiaryId not found';
}
