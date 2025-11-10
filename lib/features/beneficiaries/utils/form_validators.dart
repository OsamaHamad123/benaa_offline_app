/// 🔍 Form Validators
/// مجموعة من validators للحقول

class FormValidators {
  /// التحقق من الحقل الإجباري
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال ${fieldName ?? 'هذا الحقل'}';
    }
    return null;
  }

  /// التحقق من الاسم الكامل (على الأقل كلمتين)
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'الرجاء إدخال الاسم الثلاثي على الأقل';
    }
    if (parts.any((part) => part.length < 2)) {
      return 'يجب أن يحتوي كل جزء من الاسم على حرفين على الأقل';
    }
    return null;
  }

  /// التحقق من الرقم الوطني (11-12 رقم)
  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 11 || digitsOnly.length > 12) {
      return 'الرقم الوطني يجب أن يكون 11-12 رقم';
    }
    return null;
  }

  /// التحقق من رقم الهاتف العراقي
  static String? iraqiPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // أرقام الهواتف العراقية: 07xxxxxxxxx (11 رقم)
    if (digitsOnly.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }
    if (!digitsOnly.startsWith('07')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 07';
    }
    return null;
  }

  /// التحقق من الأرقام الموجبة
  static String? positiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون رقم صحيح';
    }
    if (number < 0) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون رقم موجب';
    }
    return null;
  }

  /// التحقق من الحد الأدنى والأقصى للرقم
  static String? numberRange(
    String? value, {
    int? min,
    int? max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون رقم صحيح';
    }
    if (min != null && number < min) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون $min على الأقل';
    }
    if (max != null && number > max) {
      return '${fieldName ?? 'الحقل'} يجب أن لا يتجاوز $max';
    }
    return null;
  }

  /// التحقق من طول النص
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    if (value.trim().length < minLength) {
      return '${fieldName ?? 'الحقل'} يجب أن يحتوي على $minLength حرف على الأقل';
    }
    return null;
  }

  /// التحقق من طول النص الأقصى
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // اختياري
    }
    if (value.trim().length > maxLength) {
      return '${fieldName ?? 'الحقل'} يجب أن لا يتجاوز $maxLength حرف';
    }
    return null;
  }

  /// دمج عدة validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
