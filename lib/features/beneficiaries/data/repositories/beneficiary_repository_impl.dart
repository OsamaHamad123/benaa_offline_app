import 'package:flutter/foundation.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../datasources/beneficiary_local_datasource.dart';
import '../models/beneficiary_model.dart';
import '../../../../core/monitoring/performance_monitor.dart';
import '../../../../core/error_handling/result.dart';
import '../../../../core/error_handling/error_logger.dart';

/// 📦 Beneficiary Repository Implementation
///
/// Implements the repository interface using local datasource.
class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryLocalDataSource localDataSource;

  const BeneficiaryRepositoryImpl(this.localDataSource);

  @override
  Future<Result<Beneficiary>> create(Beneficiary beneficiary) async {
    try {
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
      return Success(result as Beneficiary);
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        e,
        stackTrace,
        context: {
          'operation': 'create_beneficiary',
          'beneficiary_id': beneficiary.id,
          'national_id': beneficiary.nationalId,
        },
        hint: 'Failed to create beneficiary in database',
      );
      return Failure(DatabaseFailure('Failed to create beneficiary: $e', stackTrace));
    }
  }

  @override
  Future<Result<Beneficiary>> update(Beneficiary beneficiary) async {
    try {
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
      if (id == null) {
        return Failure(ValidationFailure('Invalid beneficiary ID'));
      }

      await localDataSource.update(id, companion);
      return Success(beneficiary);
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        e,
        stackTrace,
        context: {
          'operation': 'update_beneficiary',
          'beneficiary_id': beneficiary.id,
          'national_id': beneficiary.nationalId,
        },
        hint: 'Failed to update beneficiary in database',
      );
      return Failure(DatabaseFailure('Failed to update beneficiary: $e', stackTrace));
    }
  }

  @override
  Future<Result<Beneficiary>> getById(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        return Failure(ValidationFailure('Invalid beneficiary ID'));
      }

      final result = await localDataSource.getById(intId);
      if (result == null) {
        return Failure(NotFoundFailure('Beneficiary not found with ID: $id'));
      }

      return Success(result as Beneficiary);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to get beneficiary: $e', stackTrace));
    }
  }

  @override
  Future<Result<Beneficiary>> getByNationalId(String nationalId) async {
    try {
      // تنظيف الرقم الوطني من الفراغات والأحرف غير الرقمية
      final cleanedId = nationalId.trim().replaceAll(RegExp(r'\D'), '');
      if (cleanedId.isEmpty) {
        return Failure(ValidationFailure('Invalid national ID'));
      }

      final intNationalId = int.tryParse(cleanedId);
      if (intNationalId == null) {
        debugPrint(
          '⚠️ getByNationalId: Failed to parse national ID: $nationalId (cleaned: $cleanedId)',
        );
        return Failure(ValidationFailure('Invalid national ID format'));
      }

      final result = await localDataSource.getByNationalId(intNationalId);
      if (result == null) {
        return Failure(NotFoundFailure('No beneficiary found with national ID: $nationalId'));
      }

      return Success(result as Beneficiary);
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        e,
        stackTrace,
        context: {
          'operation': 'get_by_national_id',
          'national_id': nationalId,
        },
        hint: 'Failed to query beneficiary by national ID',
      );
      return Failure(DatabaseFailure('Failed to query national ID: $e', stackTrace));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) {
        return Failure(ValidationFailure('Invalid beneficiary ID'));
      }

      await localDataSource.delete(intId);
      return Success(null);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to delete beneficiary: $e', stackTrace));
    }
  }

  @override
  Future<Result<List<Beneficiary>>> list({
    String? searchQuery,
    BeneficiaryCategory? category,
    Gender? gender,
    int? limit,
    int? offset,
  }) async {
    try {
      final results = await PerformanceMonitor.measure(
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

      return Success(results);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to list beneficiaries: $e', stackTrace));
    }
  }

  @override
  Future<Result<int>> count({BeneficiaryCategory? category}) async {
    try {
      final result = await localDataSource.count(category: category?.code);
      return Success(result);
    } catch (e, stackTrace) {
      return Failure(DatabaseFailure('Failed to count beneficiaries: $e', stackTrace));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> loadFromCivilRegistry(String nationalId) async {
    try {
      // This will be implemented when we integrate with civil registry feature
      // For now, return not found
      return Failure(NotFoundFailure('Civil registry integration not yet implemented'));
    } catch (e, stackTrace) {
      return Failure(UnknownFailure('Failed to load from civil registry: $e', stackTrace));
    }
  }
}
