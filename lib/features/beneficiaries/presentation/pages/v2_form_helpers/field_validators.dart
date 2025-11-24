import 'package:flutter/services.dart';

/// 🔍 Field Validators
///
/// Real-time validation for form fields
class FieldValidators {
  /// Validate Arabic Name
  static String? validateArabicName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال $fieldName';
    }

    if (value.trim().length < 2) {
      return '$fieldName يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 50) {
      return '$fieldName طويل جداً (الحد الأقصى 50 حرف)';
    }

    // Check for Arabic characters only (allows spaces)
    if (!RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value.trim())) {
      return 'الرجاء استخدام الأحرف العربية فقط في $fieldName';
    }

    return null;
  }

  /// Validate National ID (9 digits)
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 9) {
      return 'الرقم الوطني يجب أن يكون 9 أرقام بالضبط\nمثال: 851234567';
    }

    // تحقق من الأرقام المتكررة (999999999 غير صحيح)
    if (RegExp(r'^(\d)\1+$').hasMatch(cleaned)) {
      return 'الرقم الوطني غير صحيح (لا يمكن أن تكون كل الأرقام متشابهة)';
    }

    // تحقق من سنة الميلاد (الرقمان الأولان)
    final yearPrefix = int.tryParse(cleaned.substring(0, 2));
    if (yearPrefix != null && (yearPrefix < 30 || yearPrefix > 99)) {
      return 'الرقم الوطني يبدأ بسنة الميلاد (30-99)\nمثال: 85 للمواليد 1985';
    }

    return null;
  }

  /// Validate Phone Number (Gaza/Palestine format)
  /// يدعم: 059XXXXXXX و 056XXXXXXX (10 أرقام)
  /// مع مفاتيح الدول: +972 و +970
  static String? validatePhone(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'الرجاء إدخال رقم الهاتف';
      }
      return null; // Optional field
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');

    // إزالة مفتاح الدولة للتحقق
    String phoneDigits = cleaned;
    if (cleaned.startsWith('+972')) {
      phoneDigits = '0' + cleaned.substring(4); // +972 59XXXXXXX -> 059XXXXXXX
    } else if (cleaned.startsWith('+970')) {
      phoneDigits = '0' + cleaned.substring(4); // +970 59XXXXXXX -> 059XXXXXXX
    } else if (cleaned.startsWith('00972')) {
      phoneDigits = '0' + cleaned.substring(5);
    } else if (cleaned.startsWith('00970')) {
      phoneDigits = '0' + cleaned.substring(5);
    }

    // إزالة + من البداية
    phoneDigits = phoneDigits.replaceAll('+', '');

    if (phoneDigits.length != 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام\nمثال: 0595735352 أو 0567654321';
    }

    // قبول مقدمات قطاع غزة فقط
    final validPrefixes = ['059', '056'];
    final prefix = phoneDigits.substring(0, 3);

    if (!validPrefixes.contains(prefix)) {
      return 'رقم الهاتف غير صحيح. يجب أن يبدأ بـ:\n056 (جوال) | 059 (جوال)\nمثال: 0595735352 أو +970595735352';
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

    if (!emailRegex.hasMatch(value.trim())) {
      return 'الرجاء إدخال بريد إلكتروني صحيح (مثال: example@email.com)';
    }

    return null;
  }

  /// Validate Birth Date
  static String? validateBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال تاريخ الميلاد';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      if (date.isAfter(now)) {
        return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل';
      }

      final age = now.year - date.year;
      if (age > 120) {
        return 'تاريخ الميلاد غير منطقي';
      }

      return null;
    } catch (e) {
      return 'تاريخ الميلاد غير صحيح';
    }
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
