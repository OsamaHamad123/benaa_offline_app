import 'form_controllers.dart';

/// 🎯 Smart Category Suggester
///
/// Suggests appropriate category based on beneficiary data
class CategorySuggester {
  /// Suggest category based on form data
  static String? suggestCategory(BeneficiaryFormControllers controllers) {
    // Calculate age
    final birthDate = controllers.birthDateController.text;
    int? age;
    if (birthDate.isNotEmpty) {
      try {
        final date = DateTime.parse(birthDate);
        final now = DateTime.now();
        age = now.year - date.year;
        if (now.month < date.month ||
            (now.month == date.month && now.day < date.day)) {
          age--;
        }
      } catch (e) {
        age = null;
      }
    }

    // Count deceased parents
    final deceasedCount = controllers.deceasedMembers.length;
    final hasOrphans = controllers.livingMembers.isNotEmpty;

    // Suggestion logic
    if (age != null && age < 18 && deceasedCount == 2) {
      return 'يتيم/يتيمة'; // Both parents deceased
    }

    if (age != null && age < 18 && deceasedCount == 1) {
      return 'يتيم أحد الوالدين'; // One parent deceased
    }

    if (age != null && age > 60) {
      return 'مسن/مسنة'; // Elderly
    }

    if (hasOrphans && controllers.selectedGender == '2') {
      return 'أرملة'; // Widow with orphans
    }

    if (controllers.hasDisability) {
      return 'ذوي احتياجات خاصة'; // Disabled
    }

    if (controllers.selectedDisplacementStatus != null &&
        controllers.selectedDisplacementStatus != '1') {
      return 'نازح/نازحة'; // Displaced
    }

    return null; // No clear suggestion
  }

  /// Get suggestion explanation
  static String getSuggestionReason(
    BeneficiaryFormControllers controllers,
    String suggestion,
  ) {
    switch (suggestion) {
      case 'يتيم/يتيمة':
        return 'كلا الوالدين متوفيان والعمر أقل من 18 سنة';
      case 'يتيم أحد الوالدين':
        return 'أحد الوالدين متوفى والعمر أقل من 18 سنة';
      case 'مسن/مسنة':
        return 'العمر أكثر من 60 سنة';
      case 'أرملة':
        return 'أنثى ولديها أيتام';
      case 'ذوي احتياجات خاصة':
        return 'لديه إعاقة';
      case 'نازح/نازحة':
        return 'تم تسجيله كنازح';
      default:
        return '';
    }
  }

  /// Check if suggestion is confident
  static bool isConfidentSuggestion(BeneficiaryFormControllers controllers) {
    final suggestion = suggestCategory(controllers);
    if (suggestion == null) return false;

    // High confidence for orphans and elderly
    if (suggestion.contains('يتيم') || suggestion.contains('مسن')) {
      return true;
    }

    return false;
  }
}

/// 📊 Form Completion Calculator
///
/// Calculates how many required fields are filled
class FormCompletionCalculator {
  static const List<String> requiredFields = [
    'firstName',
    'fatherName',
    'lastName',
    'nationalId',
    'birthDate',
    'gender',
    'category',
    'phone',
    'address',
  ];

  /// Calculate completion percentage
  static int calculateCompletion(BeneficiaryFormControllers controllers) {
    int completed = 0;
    final total = requiredFields.length;

    // Check each required field
    if (controllers.firstNameController.text.trim().isNotEmpty) completed++;
    if (controllers.fatherNameController.text.trim().isNotEmpty) completed++;
    if (controllers.lastNameController.text.trim().isNotEmpty) completed++;
    if (controllers.nationalIdController.text.trim().length == 9) completed++;
    if (controllers.birthDateController.text.isNotEmpty) completed++;
    if (controllers.selectedGender != null) completed++;
    if (controllers.selectedCategory != null) completed++;
    if (controllers.phoneController.text.trim().isNotEmpty) completed++;
    if (controllers.addressController.text.trim().isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }

  /// Get completed count
  static int getCompletedCount(BeneficiaryFormControllers controllers) {
    int completed = 0;

    if (controllers.firstNameController.text.trim().isNotEmpty) completed++;
    if (controllers.fatherNameController.text.trim().isNotEmpty) completed++;
    if (controllers.lastNameController.text.trim().isNotEmpty) completed++;
    if (controllers.nationalIdController.text.trim().length == 9) completed++;
    if (controllers.birthDateController.text.isNotEmpty) completed++;
    if (controllers.selectedGender != null) completed++;
    if (controllers.selectedCategory != null) completed++;
    if (controllers.phoneController.text.trim().isNotEmpty) completed++;
    if (controllers.addressController.text.trim().isNotEmpty) completed++;

    return completed;
  }

  /// Get total required fields count
  static int getTotalRequired() => requiredFields.length;
}
