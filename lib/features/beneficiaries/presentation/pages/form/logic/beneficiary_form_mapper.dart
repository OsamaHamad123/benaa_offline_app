import '../../../../domain/entities/beneficiary.dart';
import '../../v2_form_helpers/form_controllers.dart';

/// 🎯 Form Data Mapper - Maps between UI controllers and domain entities
/// Updated to match actual Beneficiary entity structure
class BeneficiaryFormMapper {
  /// Map controllers to Beneficiary entity for saving
  static Beneficiary mapControllersToBeneficiary({
    required BeneficiaryFormControllers controllers,
    String? beneficiaryId,
    String? createdByUser,
  }) {
    // بناء الاسم الكامل من الحقول الفردية
    final fullName = [
      controllers.firstNameController.text.trim(),
      controllers.fatherNameController.text.trim(),
      controllers.grandfatherNameController.text.trim(),
      controllers.lastNameController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    return Beneficiary(
      id: beneficiaryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      nationalId: controllers.nationalIdController.text.trim(),

      // Parse Gender from string to enum
      gender: _parseGender(controllers.selectedGender),

      // Parse Category from string to enum
      category: _parseCategory(controllers.selectedCategory),

      // Parse birth date string to DateTime
      birthDate: _parseDateString(controllers.birthDateController.text),

      // Family Info
      motherName:
          controllers.motherNameController.text.trim().isNotEmpty ? controllers.motherNameController.text.trim() : null,
      fatherName:
          controllers.fatherNameController.text.trim().isNotEmpty ? controllers.fatherNameController.text.trim() : null,
      grandFatherName: controllers.grandfatherNameController.text.trim().isNotEmpty
          ? controllers.grandfatherNameController.text.trim()
          : null,
      familyName:
          controllers.lastNameController.text.trim().isNotEmpty ? controllers.lastNameController.text.trim() : null,

      // Parse relationship from string to int
      relationship: _parseRelationship(controllers.selectedRelationship),

      // Parse section from string to int
      sectionId: _parseSection(controllers.selectedSection),

      // Contact Info
      phoneNumber: controllers.phoneController.text.trim().isNotEmpty ? controllers.phoneController.text.trim() : null,
      altPhoneNumber:
          controllers.altPhoneController.text.trim().isNotEmpty ? controllers.altPhoneController.text.trim() : null,

      // Parse governorate and district from string to int (if stored as codes)
      governorate: controllers.selectedProvince,
      district: controllers.selectedCity,

      address: controllers.addressController.text.trim().isNotEmpty ? controllers.addressController.text.trim() : null,
      currentAddress:
          controllers.addressController.text.trim().isNotEmpty ? controllers.addressController.text.trim() : null,
      addressBeforeDisplacement: controllers.addressBeforeDisplacementController.text.trim().isNotEmpty
          ? controllers.addressBeforeDisplacementController.text.trim()
          : null,

      // Additional Info
      fileNo: null, // سيتم توليده من النظام
      associationName: null,

      // Parse enums
      maritalStatus: _parseMaritalStatus(controllers.selectedMaritalStatus),
      educationLevel: _parseEducationLevel(controllers.selectedEducationLevel),
      healthStatus: _parseHealthStatus(controllers.selectedHealthStatus) ?? HealthStatus.good,
      hasDisability: controllers.hasDisability,

      // Family Details
      familySize: _parseInt(controllers.numberOfDependentsController.text),
      numberOfMales: _parseInt(controllers.numberOfMalesController.text),
      numberOfFemales: _parseInt(controllers.numberOfFemalesController.text),
      chronicDiseasesCount: _parseInt(controllers.chronicDiseasesController.text),
      specialNeedsCount: null, // يمكن حسابه من family members

      // Status Fields
      displacementStatus: _parseDisplacementStatus(controllers.selectedDisplacementStatus),
      employmentStatus: _parseEmploymentStatus(controllers.selectedEmploymentStatus),
      housingStatus: _parseHousingStatus(controllers.selectedHousingStatus),
      housingType: _parseHousingType(controllers.selectedHousingType),
      requestStatus: null, // يتم تحديده من النظام

      notes: controllers.notesController.text.trim().isNotEmpty ? controllers.notesController.text.trim() : null,

      // System Fields
      createdByUser: createdByUser,
      createdAt: beneficiaryId == null ? DateTime.now() : DateTime.now(),
      updatedAt: DateTime.now(),
      needsSync: true,
    );
  }

  /// Map Beneficiary entity to controllers for editing
  static void mapBeneficiaryToControllers({
    required Beneficiary beneficiary,
    required BeneficiaryFormControllers controllers,
  }) {
    // Split fullName إلى أجزاء
    final nameParts = beneficiary.fullName.split(' ');

    controllers.firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    controllers.fatherNameController.text = nameParts.length > 1 ? nameParts[1] : '';
    controllers.grandfatherNameController.text = nameParts.length > 2 ? nameParts[2] : '';
    controllers.lastNameController.text = nameParts.length > 3 ? nameParts[3] : '';
    controllers.motherNameController.text = beneficiary.motherName ?? '';

    controllers.nationalIdController.text = beneficiary.nationalId;

    // Format DateTime to string for birthDate
    if (beneficiary.birthDate != null) {
      controllers.birthDateController.text = _formatDate(beneficiary.birthDate!);
    }

    // Contact Info
    controllers.phoneController.text = beneficiary.phoneNumber ?? '';
    controllers.altPhoneController.text = beneficiary.altPhoneNumber ?? '';
    controllers.addressController.text = beneficiary.address ?? '';
    controllers.neighborhoodController.text = ''; // غير موجود في Entity
    controllers.addressBeforeDisplacementController.text = beneficiary.addressBeforeDisplacement ?? '';

    // Dropdowns - Convert enums back to strings
    controllers.selectedGender = beneficiary.gender.arabicLabel;
    controllers.selectedMaritalStatus = beneficiary.maritalStatus?.arabicLabel;
    controllers.selectedEducationLevel = beneficiary.educationLevel?.arabicLabel;
    controllers.selectedEmploymentStatus = beneficiary.employmentStatus?.arabicLabel.toString();
    controllers.selectedCategory = beneficiary.category.arabicLabel;
    controllers.selectedDisplacementStatus = beneficiary.displacementStatus?.arabicLabel;
    controllers.selectedHealthStatus = beneficiary.healthStatus.arabicLabel;
    controllers.selectedHousingStatus = beneficiary.housingStatus?.arabicLabel;
    controllers.selectedHousingType = beneficiary.housingType?.arabicLabel;
    controllers.hasDisability = beneficiary.hasDisability;

    // Convert relationship int to string representation
    controllers.selectedRelationship = beneficiary.relationship?.toString();
    controllers.selectedSection = beneficiary.sectionId?.toString();

    // Convert location codes to strings
    controllers.selectedProvince = beneficiary.governorate;
    controllers.selectedCity = beneficiary.district;

    // Family counts
    if (beneficiary.numberOfMales != null) {
      controllers.numberOfMalesController.text = beneficiary.numberOfMales.toString();
    }
    if (beneficiary.numberOfFemales != null) {
      controllers.numberOfFemalesController.text = beneficiary.numberOfFemales.toString();
    }
    if (beneficiary.chronicDiseasesCount != null) {
      controllers.chronicDiseasesController.text = beneficiary.chronicDiseasesCount.toString();
    }

    // Notes
    controllers.notesController.text = beneficiary.notes ?? '';
  }

  /// Map controllers to draft data (for auto-save)
  static Map<String, dynamic> mapControllersToDraftData({
    required BeneficiaryFormControllers controllers,
    required int currentTabIndex,
    String? beneficiaryId,
  }) {
    return {
      'firstName': controllers.firstNameController.text,
      'fatherName': controllers.fatherNameController.text,
      'grandfatherName': controllers.grandfatherNameController.text,
      'lastName': controllers.lastNameController.text,
      'motherName': controllers.motherNameController.text,
      'nationalId': controllers.nationalIdController.text,
      'birthDate': controllers.birthDateController.text,
      'phone': controllers.phoneController.text,
      'altPhone': controllers.altPhoneController.text,
      'address': controllers.addressController.text,
      'neighborhood': controllers.neighborhoodController.text,
      'notes': controllers.notesController.text,
      'gender': controllers.selectedGender,
      'maritalStatus': controllers.selectedMaritalStatus,
      'educationLevel': controllers.selectedEducationLevel,
      'employmentStatus': controllers.selectedEmploymentStatus,
      'category': controllers.selectedCategory,
      'displacementStatus': controllers.selectedDisplacementStatus,
      'healthStatus': controllers.selectedHealthStatus,
      'housingStatus': controllers.selectedHousingStatus,
      'housingType': controllers.selectedHousingType,
      'hasDisability': controllers.hasDisability,
      'relationship': controllers.selectedRelationship,
      'section': controllers.selectedSection,
      'province': controllers.selectedProvince,
      'city': controllers.selectedCity,
      'currentTab': currentTabIndex,
      'beneficiaryId': beneficiaryId,
    };
  }

  /// Map draft data to controllers (for restoring)
  static void mapDraftDataToControllers({
    required Map<String, dynamic> draftData,
    required BeneficiaryFormControllers controllers,
  }) {
    final formData = draftData['formData'] as Map<String, dynamic>;

    // Basic Info
    controllers.firstNameController.text = formData['firstName'] ?? '';
    controllers.fatherNameController.text = formData['fatherName'] ?? '';
    controllers.grandfatherNameController.text = formData['grandfatherName'] ?? '';
    controllers.lastNameController.text = formData['lastName'] ?? '';
    controllers.motherNameController.text = formData['motherName'] ?? '';
    controllers.nationalIdController.text = formData['nationalId'] ?? '';
    controllers.birthDateController.text = formData['birthDate'] ?? '';

    // Contact Info
    controllers.phoneController.text = formData['phone'] ?? '';
    controllers.altPhoneController.text = formData['altPhone'] ?? '';
    controllers.addressController.text = formData['address'] ?? '';
    controllers.neighborhoodController.text = formData['neighborhood'] ?? '';

    // Dropdowns
    controllers.selectedGender = formData['gender'];
    controllers.selectedMaritalStatus = formData['maritalStatus'];
    controllers.selectedEducationLevel = formData['educationLevel'];
    controllers.selectedEmploymentStatus = formData['employmentStatus'];
    controllers.selectedCategory = formData['category'];
    controllers.selectedDisplacementStatus = formData['displacementStatus'];
    controllers.selectedHealthStatus = formData['healthStatus'];
    controllers.selectedHousingStatus = formData['housingStatus'];
    controllers.selectedHousingType = formData['housingType'];
    controllers.hasDisability = formData['hasDisability'] ?? false;
    controllers.selectedRelationship = formData['relationship'];
    controllers.selectedSection = formData['section'];
    controllers.selectedProvince = formData['province'];
    controllers.selectedCity = formData['city'];

    // Notes
    controllers.notesController.text = formData['notes'] ?? '';
  }

  /// Calculate filled fields count
  static int calculateFilledFieldsCount(BeneficiaryFormControllers controllers) {
    int filled = 0;

    // Required text fields
    if (controllers.firstNameController.text.isNotEmpty) filled++;
    if (controllers.fatherNameController.text.isNotEmpty) filled++;
    if (controllers.grandfatherNameController.text.isNotEmpty) filled++;
    if (controllers.lastNameController.text.isNotEmpty) filled++;
    if (controllers.nationalIdController.text.isNotEmpty) filled++;
    if (controllers.birthDateController.text.isNotEmpty) filled++;
    if (controllers.phoneController.text.isNotEmpty) filled++;
    if (controllers.addressController.text.isNotEmpty) filled++;

    // Dropdowns
    if (controllers.selectedGender != null) filled++;
    if (controllers.selectedMaritalStatus != null) filled++;
    if (controllers.selectedEducationLevel != null) filled++;

    return filled;
  }

  // ==================== Helper Methods ====================

  static Gender _parseGender(String? value) {
    if (value == null) return Gender.unknown;
    return Gender.values.firstWhere(
      (g) => g.arabicLabel == value,
      orElse: () => Gender.unknown,
    );
  }

  static BeneficiaryCategory _parseCategory(String? value) {
    if (value == null) return BeneficiaryCategory.other;
    return BeneficiaryCategory.values.firstWhere(
      (c) => c.arabicLabel == value,
      orElse: () => BeneficiaryCategory.other,
    );
  }

  static MaritalStatus? _parseMaritalStatus(String? value) {
    if (value == null) return null;
    return MaritalStatus.values.firstWhere(
      (m) => m.arabicLabel == value,
      orElse: () => MaritalStatus.single,
    );
  }

  static EducationLevel? _parseEducationLevel(String? value) {
    if (value == null) return null;
    return EducationLevel.values.firstWhere(
      (e) => e.arabicLabel == value,
      orElse: () => EducationLevel.none,
    );
  }

  static HealthStatus? _parseHealthStatus(String? value) {
    if (value == null) return null;
    return HealthStatus.values.firstWhere(
      (h) => h.arabicLabel == value,
      orElse: () => HealthStatus.good,
    );
  }

  static DisplacementStatus? _parseDisplacementStatus(String? value) {
    if (value == null) return null;
    return DisplacementStatus.values.firstWhere(
      (d) => d.arabicLabel == value,
      orElse: () => DisplacementStatus.notDisplaced,
    );
  }

  static EmploymentStatus? _parseEmploymentStatus(String? value) {
    if (value == null) return null;
    return EmploymentStatus.values.firstWhere(
      (e) => e.arabicLabel == value,
      orElse: () => EmploymentStatus.unemployed,
    );
  }

  static HousingStatus? _parseHousingStatus(String? value) {
    if (value == null) return null;
    return HousingStatus.values.firstWhere(
      (h) => h.arabicLabel == value,
      orElse: () => HousingStatus.rented,
    );
  }

  static HousingType? _parseHousingType(String? value) {
    if (value == null) return null;
    return HousingType.values.firstWhere(
      (h) => h.arabicLabel == value,
      orElse: () => HousingType.house,
    );
  }

  static int? _parseRelationship(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  static int? _parseSection(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  static DateTime? _parseDateString(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      // محاولة parse من تنسيقات مختلفة
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static int? _parseInt(String value) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }
}
