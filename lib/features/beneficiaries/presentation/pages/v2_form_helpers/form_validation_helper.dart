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

  /// Validate phone number (Syrian format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    if (!RegExp(r'^059\d{8}$').hasMatch(value)) {
      return 'رقم الهاتف يجب أن يبدأ بـ 059 ويتكون من 10 أرقام';
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
