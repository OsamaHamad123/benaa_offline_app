import 'package:flutter/services.dart';

/// 🔍 Field Validators
///
/// Real-time validation for form fields
class FieldValidators {
  /// Validate National ID (11 digits)
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم الوطني مطلوب';
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 9) {
      return 'الرقم الوطني يجب أن يتكون من 9 رقم';
    }

    return null;
  }

  /// Validate Phone Number (Iraqi format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Iraqi phone: 059xxxxxxxx (10 digits)
    if (!cleaned.startsWith('059') || cleaned.length != 10) {
      return 'رقم الهاتف غير صحيح (مثال: 059XXXXXXXXX)';
    }

    return null;
  }

  /// Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Validate Required Field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validate Number Range
  static String? validateNumberRange(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName يجب أن يكون رقم';
    }

    if (number < min || number > max) {
      return '$fieldName يجب أن يكون بين $min و $max';
    }

    return null;
  }
}

/// 📋 Input Formatters
class FieldFormatters {
  /// National ID Formatter (9 digits only)
  static final nationalId = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(9),
  ];

  /// Phone Number Formatter (10 digits only)
  static final phone = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  /// Numbers Only
  static final numbersOnly = [FilteringTextInputFormatter.digitsOnly];

  /// Text Only (Arabic + English)
  static final textOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FFa-zA-Z\s]')),
  ];
}
