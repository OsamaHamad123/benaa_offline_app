/// 🛡️ Beneficiary Validator - التحقق من صحة بيانات المستفيدين
class BeneficiaryValidator {
  /// التحقق من صحة كل البيانات
  static ValidationResult validate({
    required String fullName,
    required int phoneNumber,
    DateTime? birthDate,
    int? province,
    int? city,
    String? fileIdNumber,
  }) {
    final errors = <String, String>{};

    // Name validation
    final nameError = validateName(fullName);
    if (nameError != null) {
      errors['fullName'] = nameError;
    }

    // Phone validation
    final phoneError = validatePhone(phoneNumber);
    if (phoneError != null) {
      errors['phoneNumber'] = phoneError;
    }

    // Birth date validation
    if (birthDate != null) {
      final birthDateError = validateBirthDate(birthDate);
      if (birthDateError != null) {
        errors['birthDate'] = birthDateError;
      }
    }

    // Province/City validation
    if (province != null && city != null) {
      final locationError = validateCityForProvince(province, city);
      if (locationError != null) {
        errors['city'] = locationError;
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// التحقق من الاسم
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    if (name.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }

    if (name.trim().length > 100) {
      return 'الاسم طويل جداً (الحد الأقصى 100 حرف)';
    }

    // Check if contains Arabic letters
    if (!_containsArabic(name)) {
      return 'الاسم يجب أن يحتوي على أحرف عربية';
    }

    return null;
  }

  /// التحقق من رقم الهاتف
  static String? validatePhone(int phone) {
    if (phone == 0) {
      return 'رقم الهاتف مطلوب';
    }

    final phoneStr = phone.toString();

    // Syrian phone format: 09XXXXXXXX (10 digits)
    if (phoneStr.length != 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    if (!phoneStr.startsWith('09')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 09';
    }

    return null;
  }

  /// التحقق من تاريخ الميلاد
  static String? validateBirthDate(DateTime birthDate) {
    final now = DateTime.now();

    // Check if in future
    if (birthDate.isAfter(now)) {
      return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل';
    }

    // Calculate age
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Check reasonable age range
    if (age < 0) {
      return 'تاريخ الميلاد غير صحيح';
    }

    if (age > 120) {
      return 'تاريخ الميلاد غير معقول (العمر أكثر من 120 سنة)';
    }

    return null;
  }

  /// التحقق من رقم الملف
  static String? validateFileId(String? fileId) {
    if (fileId == null || fileId.trim().isEmpty) {
      return null; // Optional field
    }

    if (fileId.trim().length > 50) {
      return 'رقم الملف طويل جداً (الحد الأقصى 50 حرف)';
    }

    return null;
  }

  /// التحقق من المدينة للمحافظة
  static String? validateCityForProvince(int province, int city) {
    // TODO: Implement actual province-city mapping validation
    // For now, just check if both are positive
    if (province <= 0 || city <= 0) {
      return 'يرجى اختيار المحافظة والمدينة';
    }

    return null;
  }

  /// حساب العمر من تاريخ الميلاد
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// التحقق من وجود أحرف عربية
  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// التحقق من أن النص عربي فقط
  static bool _isArabicOnly(String text) {
    return RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);
  }
}

/// نتيجة التحقق
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({required this.isValid, required this.errors});

  /// الحصول على خطأ حقل معين
  String? getError(String field) => errors[field];

  /// التحقق من وجود خطأ في حقل معين
  bool hasError(String field) => errors.containsKey(field);

  /// الحصول على أول خطأ
  String? get firstError =>
      errors.values.isNotEmpty ? errors.values.first : null;

  /// الحصول على جميع الأخطاء كنص
  String get errorsText => errors.values.join('\n');
}
