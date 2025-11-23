import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// ✅ Real-time Validation Indicator
///
/// Shows validation status with icon and message
class ValidationIndicator extends StatelessWidget {
  final bool? isValid;
  final String? message;
  final ValidationSeverity severity;
  final bool showIcon;
  final bool compact;

  const ValidationIndicator({
    super.key,
    this.isValid,
    this.message,
    this.severity = ValidationSeverity.error,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isValid == null && message == null) {
      return const SizedBox.shrink();
    }

    final effectiveSeverity = isValid == true
        ? ValidationSeverity.success
        : isValid == false
        ? ValidationSeverity.error
        : severity;

    final config = _getConfig(effectiveSeverity);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(top: compact ? 4.h : 8.h),
      padding: compact
          ? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)
          : EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 6.r : 8.r),
        border: Border.all(color: config.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, color: config.color, size: compact ? 14 : 16),
            SizedBox(width: compact ? 6.w : 8.w),
          ],
          Flexible(
            child: Text(
              message ?? config.defaultMessage,
              style: TextStyle(
                fontSize: compact ? 11.sp : 12.sp,
                color: config.color,
                fontWeight: compact ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ValidationConfig _getConfig(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.success:
        return _ValidationConfig(
          color: Colors.green,
          icon: Icons.check_circle,
          defaultMessage: 'صحيح',
        );
      case ValidationSeverity.warning:
        return _ValidationConfig(
          color: Colors.orange,
          icon: Icons.warning_amber,
          defaultMessage: 'تحذير',
        );
      case ValidationSeverity.error:
        return _ValidationConfig(
          color: Colors.red,
          icon: Icons.error,
          defaultMessage: 'خطأ',
        );
      case ValidationSeverity.info:
        return _ValidationConfig(
          color: Colors.blue,
          icon: Icons.info,
          defaultMessage: 'معلومة',
        );
    }
  }
}

class _ValidationConfig {
  final Color color;
  final IconData icon;
  final String defaultMessage;

  _ValidationConfig({
    required this.color,
    required this.icon,
    required this.defaultMessage,
  });
}

enum ValidationSeverity { success, warning, error, info }

/// 📋 Form Validation Summary
///
/// Shows all validation errors in a summary card
class ValidationSummary extends StatelessWidget {
  final List<ValidationError> errors;
  final VoidCallback? onFix;
  final bool collapsible;

  const ValidationSummary({
    super.key,
    required this.errors,
    this.onFix,
    this.collapsible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
              SizedBox(width: ResponsiveUtils.smallSpace),
              Expanded(
                child: Text(
                  'يوجد ${errors.length} ${errors.length == 1 ? 'خطأ' : 'أخطاء'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              if (onFix != null)
                FilledButton.icon(
                  onPressed: onFix,
                  icon: const Icon(Icons.build, size: 18),
                  label: const Text('إصلاح'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.mediumSpace),

          // Errors list
          ...errors.map(
            (error) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _ValidationErrorItem(error: error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationErrorItem extends StatelessWidget {
  final ValidationError error;

  const _ValidationErrorItem({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: error.onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: _getSeverityColor(error.severity),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error.fieldName != null)
                    Text(
                      error.fieldName!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    error.message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (error.onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.error:
        return Colors.red;
      case ValidationSeverity.warning:
        return Colors.orange;
      case ValidationSeverity.info:
        return Colors.blue;
      case ValidationSeverity.success:
        return Colors.green;
    }
  }
}

class ValidationError {
  final String message;
  final String? fieldName;
  final ValidationSeverity severity;
  final VoidCallback? onTap;

  const ValidationError({
    required this.message,
    this.fieldName,
    this.severity = ValidationSeverity.error,
    this.onTap,
  });
}

/// 🎯 Field Validation Builder
///
/// Wraps a form field with validation logic
class FieldValidationBuilder extends StatefulWidget {
  final String? initialValue;
  final List<String? Function(String?)> validators;
  final Widget Function(
    BuildContext context,
    String? value,
    String? error,
    void Function(String?) onChanged,
  )
  builder;
  final void Function(bool isValid)? onValidationChanged;
  final bool validateOnInit;
  final bool validateOnChange;

  const FieldValidationBuilder({
    super.key,
    this.initialValue,
    required this.validators,
    required this.builder,
    this.onValidationChanged,
    this.validateOnInit = false,
    this.validateOnChange = true,
  });

  @override
  State<FieldValidationBuilder> createState() => _FieldValidationBuilderState();
}

class _FieldValidationBuilderState extends State<FieldValidationBuilder> {
  String? _value;
  String? _error;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    if (widget.validateOnInit) {
      _validate(_value);
    }
  }

  void _validate(String? value) {
    String? error;
    for (final validator in widget.validators) {
      error = validator(value);
      if (error != null) break;
    }

    if (_error != error) {
      setState(() {
        _error = error;
      });
      widget.onValidationChanged?.call(error == null);
    }
  }

  void _handleChange(String? value) {
    setState(() {
      _value = value;
    });

    if (widget.validateOnChange) {
      _validate(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, _error, _handleChange);
  }
}

/// 🔒 Password Strength Indicator
///
/// Shows password strength with visual feedback
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showLabel;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
    this.showRequirements = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _calculateStrength();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: strength.score / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: strength.color,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
            if (showLabel) ...[
              SizedBox(width: 12.w),
              Text(
                strength.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: strength.color,
                ),
              ),
            ],
          ],
        ),

        // Requirements
        if (showRequirements && password.isNotEmpty) ...[
          SizedBox(height: 8.h),
          _RequirementItem(met: password.length >= 8, text: 'على الأقل 8 أحرف'),
          _RequirementItem(
            met: password.contains(RegExp(r'[A-Z]')),
            text: 'حرف كبير واحد على الأقل',
          ),
          _RequirementItem(
            met: password.contains(RegExp(r'[a-z]')),
            text: 'حرف صغير واحد على الأقل',
          ),
          _RequirementItem(
            met: password.contains(RegExp(r'[0-9]')),
            text: 'رقم واحد على الأقل',
          ),
          _RequirementItem(
            met: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
            text: 'رمز خاص واحد على الأقل',
          ),
        ],
      ],
    );
  }

  _PasswordStrength _calculateStrength() {
    if (password.isEmpty) {
      return _PasswordStrength(score: 0, label: 'ضعيف جداً', color: Colors.red);
    }

    int score = 0;

    // Length
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Normalize to 0-4
    final normalizedScore = (score / 1.5).clamp(0, 4).round();

    switch (normalizedScore) {
      case 0:
      case 1:
        return _PasswordStrength(score: 1, label: 'ضعيف', color: Colors.red);
      case 2:
        return _PasswordStrength(
          score: 2,
          label: 'متوسط',
          color: Colors.orange,
        );
      case 3:
        return _PasswordStrength(score: 3, label: 'جيد', color: Colors.blue);
      case 4:
      default:
        return _PasswordStrength(score: 4, label: 'قوي', color: Colors.green);
    }
  }
}

class _PasswordStrength {
  final int score;
  final String label;
  final Color color;

  _PasswordStrength({
    required this.score,
    required this.label,
    required this.color,
  });
}

class _RequirementItem extends StatelessWidget {
  final bool met;
  final String text;

  const _RequirementItem({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: met ? Colors.green : Colors.red.withOpacity(0.4),
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: met
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              decoration: met ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 Input Character Counter
///
/// Shows character count with limit
class CharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;
  final bool showPercentage;

  const CharacterCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (currentLength / maxLength * 100).clamp(0, 100);
    final isNearLimit = percentage >= 80;
    final isOverLimit = currentLength > maxLength;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currentLength / $maxLength',
          style: TextStyle(
            fontSize: 11.sp,
            color: isOverLimit
                ? Colors.red
                : isNearLimit
                ? Colors.orange
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isNearLimit ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (showPercentage) ...[
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: (percentage / 100).clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  color: isOverLimit
                      ? Colors.red
                      : isNearLimit
                      ? Colors.orange
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
