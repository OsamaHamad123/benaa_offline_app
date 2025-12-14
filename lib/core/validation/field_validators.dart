import 'package:flutter/services.dart';

/// 📋 Field Validators - Centralized validation rules
///
/// مجموعة موحدة لقواعد التحقق من الحقول
/// استخدم في جميع الفورمات للاتساق
///
/// Features:
/// - ✅ National ID validation (9 digits)
/// - ✅ Phone validation (Iraqi format)
/// - ✅ Email validation
/// - ✅ Name validation (Arabic/English)
/// - ✅ Required field validation
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: FieldValidators.nationalId,
///   inputFormatters: FieldValidators.nationalIdFormatters,
/// )
/// ```
class FieldValidators {
  FieldValidators._(); // Private constructor

  // ==================== Length Constants ====================

  /// National ID length (9 digits)
  static const int nationalIdLength = 9;

  /// Phone min length (10 digits: 059XXXXXXX)
  static const int phoneMinLength = 10;

  /// Phone max length (16 digits with full country code: +970XXXXXXXXX)
  static const int phoneMaxLength = 16;

  // ==================== Validation Functions ====================

  /// Required field validator
  static String? required(String? value, {String fieldName = 'الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ $fieldName مطلوب';
    }
    return null;
  }

  /// National ID validator (9 digits)
  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ الرقم الوطني مطلوب';
    }

    final cleaned = value.trim();
    if (cleaned.length != nationalIdLength) {
      return '⚠️ يجب أن يكون الرقم الوطني $nationalIdLength أرقام';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return '⚠️ الرقم الوطني يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// Phone validator (Gaza/Palestine format)
  /// Accepts:
  /// - 059XXXXXXX (10 digits)
  /// - 056XXXXXXX (10 digits)
  /// - +970XXXXXXXXX (with country code)
  /// - +972XXXXXXXXX (with country code)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ رقم الهاتف مطلوب';
    }

    // Remove common formatting characters
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    String phoneDigits = cleaned;

    // Handle international formats
    if (cleaned.startsWith('+972') || cleaned.startsWith('+970')) {
      phoneDigits = '0${cleaned.substring(4)}';
    } else if (cleaned.startsWith('00972') || cleaned.startsWith('00970')) {
      phoneDigits = '0${cleaned.substring(5)}';
    }

    // Remove any remaining + signs
    phoneDigits = phoneDigits.replaceAll('+', '');

    // Check if contains only digits
    if (!RegExp(r'^\d+$').hasMatch(phoneDigits)) {
      return '⚠️ رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }

    // Validate Gaza/Palestine format: 059XXXXXXX or 056XXXXXXX
    if (!RegExp(r'^(059|056)\d{7}$').hasMatch(phoneDigits)) {
      return '⚠️ رقم غير صحيح\nمثال: 0595735352 أو +970595735352';
    }

    return null;
  }

  /// Optional phone validator (can be empty)
  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Valid if empty
    }
    return phone(value); // Use regular validation if not empty
  }

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return '⚠️ البريد الإلكتروني غير صحيح\nمثال: example@email.com';
    }

    return null;
  }

  /// Optional email validator
  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return email(value);
  }

  /// Birth date validator
  static String? birthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ تاريخ الميلاد مطلوب';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      if (date.isAfter(now)) {
        return '⚠️ تاريخ الميلاد لا يمكن أن يكون في المستقبل';
      }

      final age = now.year - date.year;
      if (age > 120) {
        return '⚠️ تاريخ الميلاد غير منطقي (العمر أكثر من 120 سنة)';
      }

      if (age < 0) {
        return '⚠️ تاريخ الميلاد غير صحيح';
      }

      return null;
    } catch (e) {
      return '⚠️ تاريخ الميلاد غير صحيح';
    }
  }

  /// Optional birth date validator
  static String? birthDateOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return birthDate(value);
  }

  /// Number range validator
  static String? numberRange(
    String? value,
    int min,
    int max, {
    String fieldName = 'الرقم',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ $fieldName مطلوب';
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return '⚠️ $fieldName يجب أن يكون رقماً صحيحاً';
    }

    if (number < min || number > max) {
      return '⚠️ $fieldName يجب أن يكون بين $min و $max';
    }

    return null;
  }

  /// Name validator (Arabic/English, min 2 chars)
  static String? name(String? value, {String fieldName = 'الاسم'}) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ $fieldName مطلوب';
    }

    if (value.trim().length < 2) {
      return '⚠️ $fieldName يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 50) {
      return '⚠️ $fieldName طويل جداً (الحد الأقصى 50 حرف)';
    }

    // Allow Arabic, English, spaces, and some special chars
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s\-\.]+$').hasMatch(value.trim())) {
      return '⚠️ $fieldName يحتوي على رموز غير مسموحة';
    }

    return null;
  }

  /// Arabic name validator (Arabic only, min 2 chars)
  static String? arabicName(String? value, {String fieldName = 'الاسم'}) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ الرجاء إدخال $fieldName';
    }

    if (value.trim().length < 2) {
      return '⚠️ $fieldName يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 50) {
      return '⚠️ $fieldName طويل جداً (الحد الأقصى 50 حرف)';
    }

    // Arabic characters only
    if (!RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value.trim())) {
      return '⚠️ الرجاء استخدام الأحرف العربية فقط في $fieldName';
    }

    return null;
  }

  // ==================== Backward Compatibility Aliases ====================

  /// Alias for backward compatibility
  static String? validateArabicName(String? value, String fieldName) => arabicName(value, fieldName: fieldName);

  /// Alias for backward compatibility
  static String? validateNationalId(String? value) => nationalId(value);

  /// Alias for backward compatibility
  static String? validatePhone(String? value, {bool isRequired = false}) =>
      isRequired ? phone(value) : phoneOptional(value);

  /// Alias for backward compatibility
  static String? validateEmail(String? value) => emailOptional(value);

  /// Alias for backward compatibility
  static String? validateBirthDate(String? value) => birthDateOptional(value);

  /// Alias for backward compatibility
  static String? validateRequired(String? value, String fieldName) => required(value, fieldName: fieldName);

  /// Alias for backward compatibility
  static String? validateNumberRange(
    String? value,
    int min,
    int max,
    String fieldName,
  ) =>
      numberRange(value, min, max, fieldName: fieldName);

  /// Positive number validator
  static String? positiveNumber(String? value, {String fieldName = 'الرقم'}) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ $fieldName مطلوب';
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return '⚠️ $fieldName يجب أن يكون رقماً صحيحاً';
    }

    if (number <= 0) {
      return '⚠️ $fieldName يجب أن يكون أكبر من صفر';
    }

    return null;
  }

  /// Min length validator
  static String? minLength(String? value, int min, {String fieldName = 'الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '⚠️ $fieldName مطلوب';
    }

    if (value.trim().length < min) {
      return '⚠️ $fieldName يجب أن يكون $min أحرف على الأقل';
    }

    return null;
  }

  /// Max length validator
  static String? maxLength(String? value, int max, {String fieldName = 'الحقل'}) {
    if (value != null && value.trim().length > max) {
      return '⚠️ $fieldName يجب ألا يتجاوز $max حرف';
    }
    return null;
  }

  // ==================== Input Formatters ====================

  /// National ID formatters (9 digits only)
  static List<TextInputFormatter> get nationalIdFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(nationalIdLength),
      ];

  /// Phone formatters (allows digits and + for international format)
  static List<TextInputFormatter> get phoneFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
        LengthLimitingTextInputFormatter(phoneMaxLength),
      ];

  /// Digits only formatter
  static List<TextInputFormatter> get digitsOnly => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  /// Arabic and English letters only
  static List<TextInputFormatter> get arabicEnglishOnly => [
        FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FFa-zA-Z\s\-\.]')),
      ];

  /// Positive numbers only
  static List<TextInputFormatter> get positiveNumbers => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  // ==================== Composite Validators ====================

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
