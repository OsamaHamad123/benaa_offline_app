import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../beneficiary_form_colors.dart';

/// 🎯 Inline Validation Message
///
/// Displays real-time validation feedback with smooth animations
///
/// Usage:
/// ```dart
/// InlineValidationMessage(
///   message: 'الرقم الوطني يجب أن يكون 18 رقم',
///   level: ValidationLevel.error,
/// )
/// ```

enum ValidationLevel {
  success, // ✅ Valid input
  info, // ℹ️ Helpful hint
  warning, // ⚠️ Potential issue
  error, // ❌ Invalid input
}

class InlineValidationMessage extends StatefulWidget {
  final String message;
  final ValidationLevel level;
  final bool show;
  final Duration animationDuration;

  const InlineValidationMessage({
    super.key,
    required this.message,
    required this.level,
    this.show = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<InlineValidationMessage> createState() =>
      _InlineValidationMessageState();
}

class _InlineValidationMessageState extends State<InlineValidationMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(InlineValidationMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.level) {
      case ValidationLevel.success:
        return BeneficiaryFormColors.success;
      case ValidationLevel.info:
        return BeneficiaryFormColors.info;
      case ValidationLevel.warning:
        return BeneficiaryFormColors.warning;
      case ValidationLevel.error:
        return BeneficiaryFormColors.error;
    }
  }

  IconData _getIcon() {
    switch (widget.level) {
      case ValidationLevel.success:
        return Icons.check_circle_rounded;
      case ValidationLevel.info:
        return Icons.info_rounded;
      case ValidationLevel.warning:
        return Icons.warning_rounded;
      case ValidationLevel.error:
        return Icons.error_rounded;
    }
  }

  String _getAccessibilityLabel() {
    switch (widget.level) {
      case ValidationLevel.success:
        return 'صحيح';
      case ValidationLevel.info:
        return 'معلومة';
      case ValidationLevel.warning:
        return 'تحذير';
      case ValidationLevel.error:
        return 'خطأ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox.shrink();
    }

    final color = _getColor();
    final icon = _getIcon();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Semantics(
            label: '${_getAccessibilityLabel()}: ${widget.message}',
            liveRegion: true,
            child: Container(
              margin: EdgeInsets.only(top: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Icon(icon, color: color, size: 16.sp),
                  SizedBox(width: 8.w),

                  // Message text
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: color,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 Validation Message Builder
///
/// Helper for common validation scenarios
class ValidationMessages {
  ValidationMessages._();

  // National ID validations
  static InlineValidationMessage nationalIdLength() {
    return const InlineValidationMessage(
      message: 'الرقم الوطني يجب أن يكون 18 رقماً',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage nationalIdInvalid() {
    return const InlineValidationMessage(
      message: 'الرقم الوطني غير صحيح',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage nationalIdValid() {
    return const InlineValidationMessage(
      message: 'الرقم الوطني صحيح ✓',
      level: ValidationLevel.success,
    );
  }

  // Phone number validations
  static InlineValidationMessage phoneRequired() {
    return const InlineValidationMessage(
      message: 'رقم الهاتف مطلوب',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage phoneInvalid() {
    return const InlineValidationMessage(
      message: 'رقم الهاتف يجب أن يكون 11 رقماً (07XXXXXXXXX)',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage phoneValid() {
    return const InlineValidationMessage(
      message: 'رقم الهاتف صحيح ✓',
      level: ValidationLevel.success,
    );
  }

  // Name validations
  static InlineValidationMessage nameRequired(String fieldName) {
    return InlineValidationMessage(
      message: '$fieldName مطلوب',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage nameTooShort(String fieldName) {
    return InlineValidationMessage(
      message: '$fieldName يجب أن يكون على الأقل حرفين',
      level: ValidationLevel.warning,
    );
  }

  static InlineValidationMessage nameValid(String fieldName) {
    return InlineValidationMessage(
      message: '$fieldName صحيح ✓',
      level: ValidationLevel.success,
    );
  }

  // Age validations
  static InlineValidationMessage ageRequired() {
    return const InlineValidationMessage(
      message: 'العمر مطلوب',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage ageInvalid() {
    return const InlineValidationMessage(
      message: 'العمر يجب أن يكون بين 0 و 120 سنة',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage ageUnder18() {
    return const InlineValidationMessage(
      message: 'المستفيد قاصر (أقل من 18 سنة)',
      level: ValidationLevel.info,
    );
  }

  static InlineValidationMessage ageValid() {
    return const InlineValidationMessage(
      message: 'العمر صحيح ✓',
      level: ValidationLevel.success,
    );
  }

  // Address validations
  static InlineValidationMessage addressRequired() {
    return const InlineValidationMessage(
      message: 'العنوان مطلوب',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage addressTooShort() {
    return const InlineValidationMessage(
      message: 'العنوان يجب أن يكون على الأقل 10 أحرف',
      level: ValidationLevel.warning,
    );
  }

  static InlineValidationMessage addressValid() {
    return const InlineValidationMessage(
      message: 'العنوان صحيح ✓',
      level: ValidationLevel.success,
    );
  }

  // General validations
  static InlineValidationMessage required(String fieldName) {
    return InlineValidationMessage(
      message: '$fieldName مطلوب',
      level: ValidationLevel.error,
    );
  }

  static InlineValidationMessage custom({
    required String message,
    ValidationLevel level = ValidationLevel.error,
  }) {
    return InlineValidationMessage(message: message, level: level);
  }

  // Helpful hints (not errors)
  static InlineValidationMessage hint(String message) {
    return InlineValidationMessage(
      message: message,
      level: ValidationLevel.info,
    );
  }
}
