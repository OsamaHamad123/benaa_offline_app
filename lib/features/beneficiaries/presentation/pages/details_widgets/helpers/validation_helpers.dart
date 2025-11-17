/// 🔍 Validation Helpers - Clean Architecture
///
/// Contains validation logic for beneficiary data
class BeneficiaryValidationHelpers {
  /// Check if beneficiary has family information
  static bool hasFamilyInfo(dynamic beneficiary) {
    return (beneficiary.fatherName != null &&
            beneficiary.fatherName!.isNotEmpty) ||
        (beneficiary.grandFatherName != null &&
            beneficiary.grandFatherName!.isNotEmpty) ||
        (beneficiary.familyName != null &&
            beneficiary.familyName!.isNotEmpty) ||
        beneficiary.maritalStatus != null ||
        beneficiary.familySize != null ||
        beneficiary.numberOfMales != null ||
        beneficiary.numberOfFemales != null;
  }

  /// Check if beneficiary has location/displacement information
  static bool hasLocationInfo(dynamic beneficiary) {
    return (beneficiary.currentAddress != null &&
            beneficiary.currentAddress!.isNotEmpty) ||
        (beneficiary.addressBeforeDisplacement != null &&
            beneficiary.addressBeforeDisplacement!.isNotEmpty) ||
        beneficiary.displacementStatus != null ||
        beneficiary.housingStatus != null ||
        beneficiary.housingType != null;
  }

  /// Check if beneficiary has education/health information
  static bool hasEducationHealthInfo(dynamic beneficiary) {
    return beneficiary.educationLevel != null ||
        beneficiary.employmentStatus != null ||
        (beneficiary.chronicDiseasesCount != null &&
            beneficiary.chronicDiseasesCount! > 0) ||
        (beneficiary.specialNeedsCount != null &&
            beneficiary.specialNeedsCount! > 0);
  }

  /// Check if beneficiary has notes
  static bool hasNotes(dynamic beneficiary) {
    return beneficiary.notes != null && beneficiary.notes!.isNotEmpty;
  }
}
