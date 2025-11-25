import 'package:flutter/material.dart';

/// ✅ Form Validation Helper
///
/// Field validators for beneficiary form
class BeneficiaryFormValidationHelper {
  /// Validate required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validate national ID (must be 11 digits)
  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم الوطني مطلوب';
    }
    if (value.length != 9) {
      return 'الرقم الوطني يجب أن يكون 9 رقماً';
    }
    if (!RegExp(r'^\d{9}$').hasMatch(value)) {
      return 'الرقم الوطني يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  /// Validate phone number (Gaza/Palestine format)
  /// يدعم: 056XXXXXXX و 059XXXXXXX مع مفاتيح +972 و +970
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    String phoneDigits = cleaned;

    // إزالة مفتاح الدولة
    if (cleaned.startsWith('+972') || cleaned.startsWith('+970')) {
      phoneDigits = '0${cleaned.substring(4)}';
    } else if (cleaned.startsWith('00972') || cleaned.startsWith('00970')) {
      phoneDigits = '0${cleaned.substring(5)}';
    }

    phoneDigits = phoneDigits.replaceAll('+', '');

    if (!RegExp(r'^(056|059)\d{7}$').hasMatch(phoneDigits)) {
      return 'رقم الهاتف غير صحيح\nمثال: 0595735352 أو +970595735352';
    }
    return null;
  }

  /// Validate positive integer (family members, chronic diseases)
  static String? validatePositiveInt(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final intValue = int.tryParse(value);
    if (intValue == null || intValue < 0) {
      return '$fieldName يجب أن يكون رقماً صحيحاً موجباً';
    }
    return null;
  }

  /// Scroll to first error field
  static void scrollToError({
    required GlobalKey<FormState> formKey,
    required Map<String, GlobalKey> fieldKeys,
  }) {
    // Wait for validation to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Find first field with error
      for (final entry in fieldKeys.entries) {
        final context = entry.value.currentContext;
        if (context != null) {
          // Check if field has error
          final formFieldState = context
              .findAncestorStateOfType<FormFieldState>();
          if (formFieldState?.hasError == true) {
            // Scroll to this field
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.2, // Position field near top
            );
            break;
          }
        }
      }
    });
  }
}
