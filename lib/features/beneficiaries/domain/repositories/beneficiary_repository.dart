import '../entities/beneficiary.dart';

/// 📦 Beneficiary Repository Interface - Domain Layer
abstract class BeneficiaryRepository {
  /// Create new beneficiary
  Future<Beneficiary> create(Beneficiary beneficiary);

  /// Update existing beneficiary
  Future<Beneficiary> update(Beneficiary beneficiary);

  /// Get beneficiary by ID
  Future<Beneficiary?> getById(String id);

  /// Get beneficiary by National ID
  Future<Beneficiary?> getByNationalId(String nationalId);

  /// Delete beneficiary
  Future<void> delete(String id);

  /// List all beneficiaries with optional filters
  Future<List<Beneficiary>> list({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  });

  /// Count beneficiaries
  Future<int> count({BeneficiaryCategory? category});

  /// Load data from civil registry by national ID
  Future<Map<String, dynamic>?> loadFromCivilRegistry(String nationalId);
}
