import '../entities/beneficiary.dart';
import '../../../../core/error_handling/result.dart';

/// 📦 Beneficiary Repository Interface - Domain Layer
abstract class BeneficiaryRepository {
  /// Create new beneficiary
  Future<Result<Beneficiary>> create(Beneficiary beneficiary);

  /// Update existing beneficiary
  Future<Result<Beneficiary>> update(Beneficiary beneficiary);

  /// Get beneficiary by ID
  Future<Result<Beneficiary>> getById(String id);

  /// Get beneficiary by National ID
  Future<Result<Beneficiary>> getByNationalId(String nationalId);

  /// Delete beneficiary
  Future<Result<void>> delete(String id);

  /// List all beneficiaries with optional filters
  Future<Result<List<Beneficiary>>> list({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  });

  /// Count beneficiaries
  Future<Result<int>> count({BeneficiaryCategory? category});

  /// Load data from civil registry by national ID
  Future<Result<Map<String, dynamic>>> loadFromCivilRegistry(String nationalId);
}
