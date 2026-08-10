/// 🎯 Form Validator - Clean validation logic separation
class BeneficiaryFormValidator {
  /// Validate first name (required, min 2 chars)
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم الأول مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم الأول يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate father name (required, min 2 chars)
  static String? validateFatherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الأب مطلوب';
    }
    if (value.trim().length < 2) {
      return 'اسم الأب يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate grandfather name (required, min 2 chars)
  static String? validateGrandfatherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الجد مطلوب';
    }
    if (value.trim().length < 2) {
      return 'اسم الجد يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate last name (required, min 2 chars)
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اللقب مطلوب';
    }
    if (value.trim().length < 2) {
      return 'اللقب يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate national ID (required, exactly 12 digits)
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهوية مطلوب';
    }

    final cleanValue = value.trim();
    if (!RegExp(r'^\d{12}$').hasMatch(cleanValue)) {
      return 'رقم الهوية يجب أن يكون 12 رقماً بالضبط';
    }

    return null;
  }

  /// Validate birth date (required)
  static String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تاريخ الميلاد مطلوب';
    }
    return null;
  }

  /// Validate phone (required, 10 digits with optional 0 prefix)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final cleanValue = value.trim().replaceAll(RegExp(r'\s+'), '');

    // Allow 10 digits or 10 digits with leading 0
    if (!RegExp(r'^0?\d{10}$').hasMatch(cleanValue)) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    return null;
  }

  /// Validate alternative phone (optional, but if provided must be valid)
  static String? validateAltPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final cleanValue = value.trim().replaceAll(RegExp(r'\s+'), '');

    if (!RegExp(r'^0?\d{10}$').hasMatch(cleanValue)) {
      return 'رقم الهاتف البديل يجب أن يكون 10 أرقام';
    }

    return null;
  }

  /// Validate address (required, min 5 chars)
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    if (value.trim().length < 5) {
      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
    }
    return null;
  }

  /// Validate neighborhood (optional, but if provided min 2 chars)
  static String? validateNeighborhood(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 2) {
      return 'الحي يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate mother name (optional, but if provided min 2 chars)
  static String? validateMotherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 2) {
      return 'اسم الأم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validate notes (optional)
  static String? validateNotes(String? value) {
    return null; // Notes are always optional
  }

  /// Validate entire form - returns list of error messages
  static List<String> validateFullForm({
    required String? firstName,
    required String? fatherName,
    required String? grandfatherName,
    required String? lastName,
    required String? nationalId,
    required String? birthDate,
    required String? phone,
    required String? address,
    String? altPhone,
    String? neighborhood,
    String? motherName,
  }) {
    final errors = <String>[];

    final firstNameError = validateFirstName(firstName);
    if (firstNameError != null) errors.add(firstNameError);

    final fatherNameError = validateFatherName(fatherName);
    if (fatherNameError != null) errors.add(fatherNameError);

    final grandfatherNameError = validateGrandfatherName(grandfatherName);
    if (grandfatherNameError != null) errors.add(grandfatherNameError);

    final lastNameError = validateLastName(lastName);
    if (lastNameError != null) errors.add(lastNameError);

    final nationalIdError = validateNationalId(nationalId);
    if (nationalIdError != null) errors.add(nationalIdError);

    final birthDateError = validateBirthDate(birthDate);
    if (birthDateError != null) errors.add(birthDateError);

    final phoneError = validatePhone(phone);
    if (phoneError != null) errors.add(phoneError);

    final addressError = validateAddress(address);
    if (addressError != null) errors.add(addressError);

    // Optional fields
    final altPhoneError = validateAltPhone(altPhone);
    if (altPhoneError != null) errors.add(altPhoneError);

    final neighborhoodError = validateNeighborhood(neighborhood);
    if (neighborhoodError != null) errors.add(neighborhoodError);

    final motherNameError = validateMotherName(motherName);
    if (motherNameError != null) errors.add(motherNameError);

    return errors;
  }

  /// Check if form has all required fields filled (basic check)
  static bool hasAllRequiredFields({
    required String? firstName,
    required String? fatherName,
    required String? grandfatherName,
    required String? lastName,
    required String? nationalId,
    required String? birthDate,
    required String? phone,
    required String? address,
  }) {
    return (firstName?.trim().isNotEmpty ?? false) &&
        (fatherName?.trim().isNotEmpty ?? false) &&
        (grandfatherName?.trim().isNotEmpty ?? false) &&
        (lastName?.trim().isNotEmpty ?? false) &&
        (nationalId?.trim().isNotEmpty ?? false) &&
        (birthDate?.trim().isNotEmpty ?? false) &&
        (phone?.trim().isNotEmpty ?? false) &&
        (address?.trim().isNotEmpty ?? false);
  }
}
