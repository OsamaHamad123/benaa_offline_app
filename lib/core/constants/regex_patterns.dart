/// 🔍 Regex Patterns - توحيد جميع regex patterns في مكان واحد
///
/// استخدام:
/// ```dart
/// if (!RegexPatterns.iraqiPhone.hasMatch(phone)) {
///   return 'رقم هاتف غير صحيح';
/// }
/// ```
class RegexPatterns {
  // Private constructor to prevent instantiation
  RegexPatterns._();

  // ========== Phone Numbers ==========

  /// نمط رقم الهاتف العراقي: 07XXXXXXXXX (11 رقم)
  /// مثال: 07701234567
  static final RegExp iraqiPhone = RegExp(r'^07[0-9]{9}$');

  /// نمط رقم الهاتف السوري: 09XXXXXXXX (10 أرقام)
  /// مثال: 0991234567
  static final RegExp syrianPhone = RegExp(r'^09[0-9]{8}$');

  /// نمط رقم الهاتف الدولي: +XXX XXXXXXXXX
  /// مثال: +964 770 123 4567
  static final RegExp internationalPhone = RegExp(r'^\+[1-9]\d{1,14}$');

  // ========== National IDs ==========

  /// رقم الهوية الوطنية العراقية: 18 رقم
  /// مثال: 123456789012345678
  static final RegExp iraqiNationalId = RegExp(r'^[0-9]{18}$');

  /// رقم البطاقة الوطنية السورية: 11 رقم
  /// مثال: 01234567890
  static final RegExp syrianNationalId = RegExp(r'^[0-9]{11}$');

  // ========== Names ==========

  /// الأسماء العربية: حروف عربية ومسافات فقط
  /// يسمح بـ: أ-ي، المسافات، الهمزات
  static final RegExp arabicName = RegExp(r'^[\u0600-\u06FF\s]+$');

  /// الأسماء الإنجليزية: حروف إنجليزية ومسافات فقط
  /// يسمح بـ: A-Z, a-z, spaces
  static final RegExp englishName = RegExp(r'^[a-zA-Z\s]+$');

  /// أسماء مختلطة: عربي + إنجليزي + مسافات
  static final RegExp mixedName = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');

  // ========== Emails ==========

  /// عنوان البريد الإلكتروني
  /// مثال: user@example.com
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // ========== Dates ==========

  /// تاريخ بصيغة DD/MM/YYYY
  /// مثال: 25/12/2023
  static final RegExp dateSlash = RegExp(
    r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/\d{4}$',
  );

  /// تاريخ بصيغة DD-MM-YYYY
  /// مثال: 25-12-2023
  static final RegExp dateDash = RegExp(
    r'^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[012])-\d{4}$',
  );

  // ========== Numbers ==========

  /// أرقام فقط (integers)
  static final RegExp integerOnly = RegExp(r'^[0-9]+$');

  /// أرقام عشرية (decimals)
  /// مثال: 123.45
  static final RegExp decimal = RegExp(r'^[0-9]+(\.[0-9]+)?$');

  // ========== Addresses ==========

  /// عنوان عربي: حروف عربية + أرقام + رموز
  static final RegExp arabicAddress = RegExp(r'^[\u0600-\u06FF0-9\s،./\-]+$');

  // ========== Passport & Document Numbers ==========

  /// رقم جواز السفر: حروف + أرقام (8-12 حرف)
  /// مثال: AB1234567
  static final RegExp passport = RegExp(r'^[A-Z0-9]{8,12}$');

  // ========== Iraqi-Specific Patterns ==========

  /// رقم البطاقة الموحدة العراقية
  /// مثال: 1-2-3-123456
  static final RegExp iraqiUnifiedCard = RegExp(
    r'^[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,2}-[0-9]{6}$',
  );

  /// رقم البطاقة الغذائية
  /// مثال: 123456-789
  static final RegExp foodCard = RegExp(r'^[0-9]{6}-[0-9]{3}$');

  // ========== Utility Methods ==========

  /// التحقق من أن النص يحتوي على أرقام فقط
  static bool isNumericOnly(String text) {
    return integerOnly.hasMatch(text);
  }

  /// التحقق من أن النص يحتوي على حروف عربية فقط
  static bool isArabicOnly(String text) {
    return arabicName.hasMatch(text);
  }

  /// التحقق من أن النص يحتوي على حروف إنجليزية فقط
  static bool isEnglishOnly(String text) {
    return englishName.hasMatch(text);
  }

  /// التحقق من صحة رقم الهاتف (عراقي أو سوري)
  static bool isValidPhone(String phone) {
    return iraqiPhone.hasMatch(phone) || syrianPhone.hasMatch(phone);
  }

  /// التحقق من صحة رقم الهوية (عراقي أو سوري)
  static bool isValidNationalId(String id) {
    return iraqiNationalId.hasMatch(id) || syrianNationalId.hasMatch(id);
  }

  /// تنظيف النص من المسافات الزائدة
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// إزالة الأرقام من النص
  static String removeNumbers(String text) {
    return text.replaceAll(RegExp(r'[0-9]'), '');
  }

  /// إزالة الحروف من النص (الاحتفاظ بالأرقام فقط)
  static String removeLetters(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// تنسيق رقم الهاتف: 07701234567 → 0770 123 4567
  static String formatIraqiPhone(String phone) {
    if (!iraqiPhone.hasMatch(phone)) return phone;
    return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
  }

  /// تنسيق رقم الهوية: 123456789012345678 → 12-3456-7890-1234-5678
  static String formatIraqiNationalId(String id) {
    if (!iraqiNationalId.hasMatch(id)) return id;
    return '${id.substring(0, 2)}-${id.substring(2, 6)}-${id.substring(6, 10)}-${id.substring(10, 14)}-${id.substring(14)}';
  }
}

/// 🛡️ Validation Messages - رسائل التحقق الموحدة
class ValidationMessages {
  ValidationMessages._();

  // Phone
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String invalidIraqiPhone =
      'رقم الهاتف العراقي يجب أن يبدأ بـ 07';
  static const String invalidSyrianPhone =
      'رقم الهاتف السوري يجب أن يبدأ بـ 09';

  // National ID
  static const String invalidNationalId = 'رقم الهوية غير صحيح';
  static const String invalidIraqiNationalId = 'رقم الهوية يجب أن يكون 18 رقم';
  static const String invalidSyrianNationalId = 'رقم الهوية يجب أن يكون 11 رقم';

  // Names
  static const String invalidName = 'الاسم يحتوي على رموز غير مسموحة';
  static const String invalidArabicName = 'يجب إدخال الاسم بالعربية فقط';
  static const String invalidEnglishName = 'يجب إدخال الاسم بالإنجليزية فقط';

  // Email
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';

  // Date
  static const String invalidDate = 'التاريخ غير صحيح';

  // Required
  static const String required = 'هذا الحقل مطلوب';

  // General
  static const String tooShort = 'النص قصير جداً';
  static const String tooLong = 'النص طويل جداً';
}
