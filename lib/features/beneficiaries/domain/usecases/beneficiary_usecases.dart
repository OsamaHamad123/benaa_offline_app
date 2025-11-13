import '../entities/beneficiary.dart';
import '../repositories/beneficiary_repository.dart';

/// Create Beneficiary Use Case
class CreateBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const CreateBeneficiaryUseCase(this.repository);

  Future<Beneficiary> call(Beneficiary beneficiary) async {
    // Business validation
    if (beneficiary.fullName.trim().isEmpty) {
      throw Exception('الاسم الكامل مطلوب');
    }
    if (beneficiary.nationalId.trim().isEmpty) {
      throw Exception('الرقم الوطني مطلوب');
    }

    return await repository.create(beneficiary);
  }
}

/// Update Beneficiary Use Case
class UpdateBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const UpdateBeneficiaryUseCase(this.repository);

  Future<Beneficiary> call(Beneficiary beneficiary) async {
    return await repository.update(beneficiary);
  }
}

/// Get Beneficiary Use Case
class GetBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const GetBeneficiaryUseCase(this.repository);

  Future<Beneficiary?> call(String id) async {
    return await repository.getById(id);
  }
}

/// Delete Beneficiary Use Case
class DeleteBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const DeleteBeneficiaryUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}

/// List Beneficiaries Use Case
class ListBeneficiariesUseCase {
  final BeneficiaryRepository repository;
  const ListBeneficiariesUseCase(this.repository);

  Future<List<Beneficiary>> call({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  }) async {
    return await repository.list(
      searchQuery: searchQuery,
      category: category,
      gender: gender,
      limit: limit,
      offset: offset,
    );
  }
}

/// Load From Civil Registry Use Case
class LoadFromCivilRegistryUseCase {
  final BeneficiaryRepository repository;
  const LoadFromCivilRegistryUseCase(this.repository);

  Future<Map<String, dynamic>?> call(String nationalId) async {
    // Validate national ID format
    final cleaned = nationalId.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 8) {
      throw Exception('الرقم الوطني غير صحيح');
    }

    return await repository.loadFromCivilRegistry(cleaned);
  }
}
