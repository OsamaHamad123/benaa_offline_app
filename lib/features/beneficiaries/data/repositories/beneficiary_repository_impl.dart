import '../../domain/entities/beneficiary.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../datasources/beneficiary_local_datasource.dart';
import '../models/beneficiary_model.dart';

/// 📦 Beneficiary Repository Implementation
///
/// Implements the repository interface using local datasource.
class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryLocalDataSource localDataSource;

  const BeneficiaryRepositoryImpl(this.localDataSource);

  @override
  Future<Beneficiary> create(Beneficiary beneficiary) async {
    final companion = BeneficiaryModel(
      id: beneficiary.id,
      fullName: beneficiary.fullName,
      nationalId: beneficiary.nationalId,
      gender: beneficiary.gender,
      category: beneficiary.category,
      birthDate: beneficiary.birthDate,
      motherName: beneficiary.motherName,
      fatherName: beneficiary.fatherName,
      grandFatherName: beneficiary.grandFatherName,
      familyName: beneficiary.familyName,
      phoneNumber: beneficiary.phoneNumber,
      altPhoneNumber: beneficiary.altPhoneNumber,
      governorate: beneficiary.governorate,
      district: beneficiary.district,
      address: beneficiary.address,
      currentAddress: beneficiary.currentAddress,
      addressBeforeDisplacement: beneficiary.addressBeforeDisplacement,
      fileNo: beneficiary.fileNo,
      associationName: beneficiary.associationName,
      maritalStatus: beneficiary.maritalStatus,
      educationLevel: beneficiary.educationLevel,
      healthStatus: beneficiary.healthStatus,
      hasDisability: beneficiary.hasDisability,
      familySize: beneficiary.familySize,
      numberOfMales: beneficiary.numberOfMales,
      numberOfFemales: beneficiary.numberOfFemales,
      chronicDiseasesCount: beneficiary.chronicDiseasesCount,
      specialNeedsCount: beneficiary.specialNeedsCount,
      displacementStatus: beneficiary.displacementStatus,
      employmentStatus: beneficiary.employmentStatus,
      housingStatus: beneficiary.housingStatus,
      housingType: beneficiary.housingType,
      requestStatus: beneficiary.requestStatus,
      notes: beneficiary.notes,
      createdAt: beneficiary.createdAt,
      updatedAt: beneficiary.updatedAt,
      needsSync: beneficiary.needsSync,
    ).toDrift();

    final result = await localDataSource.create(companion);
    return result as Beneficiary;
  }

  @override
  Future<Beneficiary> update(Beneficiary beneficiary) async {
    final companion = BeneficiaryModel(
      id: beneficiary.id,
      fullName: beneficiary.fullName,
      nationalId: beneficiary.nationalId,
      gender: beneficiary.gender,
      category: beneficiary.category,
      birthDate: beneficiary.birthDate,
      motherName: beneficiary.motherName,
      fatherName: beneficiary.fatherName,
      grandFatherName: beneficiary.grandFatherName,
      familyName: beneficiary.familyName,
      phoneNumber: beneficiary.phoneNumber,
      altPhoneNumber: beneficiary.altPhoneNumber,
      governorate: beneficiary.governorate,
      district: beneficiary.district,
      address: beneficiary.address,
      currentAddress: beneficiary.currentAddress,
      addressBeforeDisplacement: beneficiary.addressBeforeDisplacement,
      fileNo: beneficiary.fileNo,
      associationName: beneficiary.associationName,
      maritalStatus: beneficiary.maritalStatus,
      educationLevel: beneficiary.educationLevel,
      healthStatus: beneficiary.healthStatus,
      displacementStatus: beneficiary.displacementStatus,
      employmentStatus: beneficiary.employmentStatus,
      housingStatus: beneficiary.housingStatus,
      housingType: beneficiary.housingType,
      familySize: beneficiary.familySize,
      numberOfMales: beneficiary.numberOfMales,
      numberOfFemales: beneficiary.numberOfFemales,
      chronicDiseasesCount: beneficiary.chronicDiseasesCount,
      specialNeedsCount: beneficiary.specialNeedsCount,
      hasDisability: beneficiary.hasDisability,
      notes: beneficiary.notes,
      requestStatus: beneficiary.requestStatus,
      createdAt: beneficiary.createdAt,
      updatedAt: beneficiary.updatedAt,
      needsSync: beneficiary.needsSync,
    ).toDrift();

    await localDataSource.update(beneficiary.id, companion);
    return beneficiary;
  }

  @override
  Future<Beneficiary?> getById(String id) async {
    final result = await localDataSource.getById(id);
    return result as Beneficiary?;
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<List<Beneficiary>> list({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  }) async {
    final results = await localDataSource.list(
      searchQuery: searchQuery,
      category: category?.name,
      gender: gender?.name,
      limit: limit,
      offset: offset,
    );
    return results.cast<Beneficiary>();
  }

  @override
  Future<int> count({BeneficiaryCategory? category}) async {
    return await localDataSource.count(category: category?.name);
  }

  @override
  Future<Map<String, dynamic>?> loadFromCivilRegistry(String nationalId) async {
    // This will be implemented when we integrate with civil registry feature
    // For now, return null
    return null;
  }
}
