import '../../../domain/entities/beneficiary.dart';
import 'form_controllers.dart';

/// 🏗️ Beneficiary Entity Builder
///
/// Builds Beneficiary entity from form controllers
class BeneficiaryEntityBuilder {
  /// Build Beneficiary entity from form data
  static Beneficiary build({
    required BeneficiaryFormControllers controllers,
    required String? existingId,
    required String? existingFileNo,
    required DateTime? existingCreatedAt,
  }) {
    // Build full name
    final fullName = [
      controllers.firstNameController.text.trim(),
      controllers.fatherNameController.text.trim(),
      controllers.grandfatherNameController.text.trim(),
      controllers.lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    // Parse gender from taxonomy code/label/value
    final gender = _parseGender(controllers.selectedGender);

    // Generate timestamps
    final now = DateTime.now();
    final fileNo = existingFileNo ?? 'F-${now.millisecondsSinceEpoch}';

    return Beneficiary(
      id: existingId ?? '',
      fullName: fullName,
      nationalId: controllers.nationalIdController.text.trim(),
      fileNo: fileNo,
      gender: gender,
      category: _parseCategory(controllers.selectedCategory),
      birthDate: controllers.birthDateController.text.isNotEmpty
          ? DateTime.tryParse(controllers.birthDateController.text)
          : null,
      motherName: _trimOrNull(controllers.motherNameController.text),
      fatherName: _trimOrNull(controllers.fatherNameController.text),
      grandFatherName: _trimOrNull(controllers.grandfatherNameController.text),
      familyName: _trimOrNull(controllers.lastNameController.text),
      phoneNumber: _trimOrNull(controllers.phoneController.text),
      altPhoneNumber: _trimOrNull(controllers.altPhoneController.text),
      address: _trimOrNull(controllers.addressController.text),
      district: _trimOrNull(controllers.neighborhoodController.text),
      governorate: controllers.selectedProvince,
      currentAddress: _trimOrNull(controllers.addressController.text),
      addressBeforeDisplacement: _trimOrNull(
        controllers.addressBeforeDisplacementController.text,
      ),
      maritalStatus: _parseEnum<MaritalStatus>(
        controllers.selectedMaritalStatus,
        MaritalStatus.values,
        MaritalStatus.single,
      ),
      educationLevel: _parseEnum<EducationLevel>(
        controllers.selectedEducationLevel,
        EducationLevel.values,
        EducationLevel.none,
      ),
      employmentStatus: _parseEnum<EmploymentStatus>(
        controllers.selectedEmploymentStatus,
        EmploymentStatus.values,
        EmploymentStatus.unemployed,
      ),
      displacementStatus: _parseEnum<DisplacementStatus>(
        controllers.selectedDisplacementStatus,
        DisplacementStatus.values,
        DisplacementStatus.notDisplaced,
      ),
      healthStatus: _parseEnum<HealthStatus>(
            controllers.selectedHealthStatus,
            HealthStatus.values,
            HealthStatus.good,
          ) ??
          HealthStatus.good,
      housingStatus: _parseEnum<HousingStatus>(
        controllers.selectedHousingStatus,
        HousingStatus.values,
        HousingStatus.rented,
      ),
      housingType: _parseEnum<HousingType>(
        controllers.selectedHousingType,
        HousingType.values,
        HousingType.other,
      ),
      hasDisability: controllers.hasDisability,
      chronicDiseasesCount: _parseIntOrNull(
        controllers.chronicDiseasesController.text,
      ),
      familySize: _parseIntOrNull(
        controllers.numberOfDependentsController.text,
      ),
      numberOfMales: _parseIntOrNull(controllers.numberOfMalesController.text),
      numberOfFemales: _parseIntOrNull(
        controllers.numberOfFemalesController.text,
      ),
      specialNeedsCount: _parseIntOrNull(
        controllers.specialNeedsCountController.text,
      ),
      notes: _trimOrNull(controllers.notesController.text),
      createdByUser: _trimOrNull(controllers.createdByUserController.text),
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
  }

  /// Parse category with default
  static BeneficiaryCategory _parseCategory(String? value) {
    if (value == null) return BeneficiaryCategory.other;
    try {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return BeneficiaryCategory.other;

      final numericCode = int.tryParse(trimmed);
      if (numericCode != null) {
        return BeneficiaryCategory.fromCode(numericCode);
      }

      return BeneficiaryCategory.values.firstWhere(
        (e) => e.name == trimmed || e.englishValue == trimmed || e.arabicLabel == trimmed,
        orElse: () => BeneficiaryCategory.other,
      );
    } catch (_) {
      return BeneficiaryCategory.other;
    }
  }

  static Gender _parseGender(String? value) {
    if (value == null || value.trim().isEmpty) return Gender.unknown;
    final normalized = value.trim();
    if (normalized == '1' || normalized == 'male' || normalized == 'ذكر') {
      return Gender.male;
    }
    if (normalized == '2' || normalized == 'female' || normalized == 'أنثى') {
      return Gender.female;
    }
    return Gender.fromString(normalized);
  }

  /// Parse enum with null safety
  static T? _parseEnum<T extends Enum>(
    String? value,
    List<T> values,
    T defaultValue,
  ) {
    if (value == null) return null;
    try {
      return values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => defaultValue,
      );
    } catch (_) {
      return null;
    }
  }

  /// Trim string or return null if empty
  static String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Parse int or return null
  static int? _parseIntOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : int.tryParse(trimmed);
  }
}
