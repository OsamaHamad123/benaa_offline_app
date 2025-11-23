import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ✅ Field Validation Indicator
///
/// Shows validation status for form fields:
/// - ✓ Green checkmark for valid/completed fields
/// - ❌ Red X for error fields
/// - ○ Gray circle for untouched fields
/// - Animated transitions between states
class FieldValidationIndicator extends StatelessWidget {
  final FieldValidationState state;
  final String? errorMessage;

  const FieldValidationIndicator({
    super.key,
    required this.state,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildIndicator(),
    );
  }

  Widget _buildIndicator() {
    switch (state) {
      case FieldValidationState.valid:
        return _buildValidIndicator();
      case FieldValidationState.error:
        return _buildErrorIndicator();
      case FieldValidationState.untouched:
        return _buildUntouchedIndicator();
    }
  }

  Widget _buildValidIndicator() {
    return Container(
      key: const ValueKey('valid'),
      width: 24.w,
      height: 24.w,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: Colors.white, size: 16.sp),
    );
  }

  Widget _buildErrorIndicator() {
    return Tooltip(
      message: errorMessage ?? 'خطأ في الحقل',
      child: Container(
        key: const ValueKey('error'),
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, color: Colors.white, size: 16.sp),
      ),
    );
  }

  Widget _buildUntouchedIndicator() {
    return Container(
      key: const ValueKey('untouched'),
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Validation state enum
enum FieldValidationState { valid, error, untouched }

/// 📝 Enhanced Text Field with Validation Indicator
class ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool showValidation;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool required;
  final void Function(String)? onChanged;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.showValidation = true,
    this.keyboardType,
    this.maxLines,
    this.required = false,
    this.onChanged,
  });

  FieldValidationState _getValidationState() {
    final value = controller.text;

    // If field is empty and not required, show untouched
    if (value.isEmpty && !required) {
      return FieldValidationState.untouched;
    }

    // If no validator provided, check only if required field is filled
    if (validator == null) {
      return value.isEmpty && required
          ? FieldValidationState.error
          : value.isNotEmpty
          ? FieldValidationState.valid
          : FieldValidationState.untouched;
    }

    // Use validator
    final error = validator!(value);
    if (error != null) {
      return FieldValidationState.error;
    }

    return value.isNotEmpty
        ? FieldValidationState.valid
        : FieldValidationState.untouched;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            validator: validator,
            onChanged: onChanged,
          ),
        ),
        if (showValidation) ...[
          SizedBox(width: 8.w),
          FieldValidationIndicator(
            state: _getValidationState(),
            errorMessage: validator?.call(controller.text),
          ),
        ],
      ],
    );
  }
}
