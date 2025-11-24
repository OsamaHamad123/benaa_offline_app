import 'package:flutter/foundation.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../datasources/beneficiary_local_datasource.dart';
import '../models/beneficiary_model.dart';
import '../../../../core/monitoring/performance_monitor.dart';

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
      needsSync: true, // ✅ المستفيدين الجدد يحتاجون مزامنة
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
      needsSync: true, // ✅ التعديلات تحتاج مزامنة
    ).toDrift();

    final id = int.tryParse(beneficiary.id);
    if (id == null) throw Exception('Invalid beneficiary ID');
    await localDataSource.update(id, companion);
    return beneficiary;
  }

  @override
  Future<Beneficiary?> getById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final result = await localDataSource.getById(intId);
    return result as Beneficiary?;
  }

  @override
  Future<Beneficiary?> getByNationalId(String nationalId) async {
    // تنظيف الرقم الوطني من الفراغات والأحرف غير الرقمية
    final cleanedId = nationalId.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanedId.isEmpty) return null;

    final intNationalId = int.tryParse(cleanedId);
    if (intNationalId == null) {
      debugPrint(
        '⚠️ getByNationalId: Failed to parse national ID: $nationalId (cleaned: $cleanedId)',
      );
      return null;
    }

    try {
      final result = await localDataSource.getByNationalId(intNationalId);
      return result as Beneficiary?;
    } catch (e) {
      debugPrint(
        '⚠️ getByNationalId: Error querying national ID $intNationalId: $e',
      );
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) throw Exception('Invalid beneficiary ID');
    await localDataSource.delete(intId);
  }

  @override
  Future<List<Beneficiary>> list({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  }) async {
    return await PerformanceMonitor.measure(
      'BeneficiaryRepository.list',
      () async {
        final results = await localDataSource.list(
          searchQuery: searchQuery,
          category: category?.code,
          gender: gender == Gender.male
              ? 1
              : gender == Gender.female
              ? 2
              : null,
          limit: limit,
          offset: offset,
        );
        return results.cast<Beneficiary>();
      },
      metadata: {
        'searchQuery': searchQuery,
        'category': category?.code,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  @override
  Future<int> count({BeneficiaryCategory? category}) async {
    return await localDataSource.count(category: category?.code);
  }

  @override
  Future<Map<String, dynamic>?> loadFromCivilRegistry(String nationalId) async {
    // This will be implemented when we integrate with civil registry feature
    // For now, return null
    return null;
  }
}
