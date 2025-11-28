import '../entities/beneficiary.dart';
import '../repositories/beneficiary_repository.dart';
import '../../../../core/error_handling/result.dart';

/// Create Beneficiary Use Case
class CreateBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const CreateBeneficiaryUseCase(this.repository);

  Future<Result<Beneficiary>> execute(Beneficiary beneficiary) async {
    // Business validation
    if (beneficiary.fullName.trim().isEmpty) {
      return Failure(ValidationFailure('الاسم الكامل مطلوب'));
    }
    if (beneficiary.nationalId.trim().isEmpty) {
      return Failure(ValidationFailure('الرقم الوطني مطلوب'));
    }

    return await repository.create(beneficiary);
  }
}

/// Update Beneficiary Use Case
class UpdateBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const UpdateBeneficiaryUseCase(this.repository);

  Future<Result<Beneficiary>> execute(Beneficiary beneficiary) async {
    return await repository.update(beneficiary);
  }
}

/// Get Beneficiary Use Case
class GetBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const GetBeneficiaryUseCase(this.repository);

  Future<Result<Beneficiary>> execute(String id) async {
    return await repository.getById(id);
  }
}

/// Delete Beneficiary Use Case
class DeleteBeneficiaryUseCase {
  final BeneficiaryRepository repository;
  const DeleteBeneficiaryUseCase(this.repository);

  Future<Result<void>> execute(String id) async {
    return await repository.delete(id);
  }
}

/// List Beneficiaries Use Case
class ListBeneficiariesUseCase {
  final BeneficiaryRepository repository;
  const ListBeneficiariesUseCase(this.repository);

  Future<Result<List<Beneficiary>>> execute({
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

/// Get Beneficiary Statistics Use Case
class GetBeneficiaryStatisticsUseCase {
  final BeneficiaryRepository repository;
  const GetBeneficiaryStatisticsUseCase(this.repository);

  Future<Result<Map<String, int>>> execute() async {
    final totalResult = await repository.count();
    if (totalResult is Failure<int>) {
      return Failure(totalResult.error);
    }

    final pendingResult = await repository.count(); // TODO: Add pendingSync filter
    if (pendingResult is Failure<int>) {
      return Failure(pendingResult.error);
    }

    return Success({
      'total': (totalResult as Success<int>).value,
      'pending': (pendingResult as Success<int>).value,
    });
  }
}

/// Load From Civil Registry Use Case
class LoadFromCivilRegistryUseCase {
  final BeneficiaryRepository repository;
  const LoadFromCivilRegistryUseCase(this.repository);

  Future<Result<Map<String, dynamic>>> execute(String nationalId) async {
    // Validate national ID format
    final cleaned = nationalId.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 8) {
      return Failure(ValidationFailure('الرقم الوطني غير صحيح'));
    }

    return await repository.loadFromCivilRegistry(cleaned);
  }
}
