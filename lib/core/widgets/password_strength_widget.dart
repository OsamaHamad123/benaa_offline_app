import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../security/password_validator.dart';

/// 🔐 Password Strength Indicator Widget
///
/// مؤشر قوة كلمة المرور

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showFeedback;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidator.checkStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: strength.percentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrengthColor(strength.level),
                  ),
                  minHeight: 8.h,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              strength.level.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _getStrengthColor(strength.level),
              ),
            ),
          ],
        ),

        // Feedback
        if (showFeedback && password.isNotEmpty) ...[
          SizedBox(height: 8.h),
          ...strength.feedback.map((feedback) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(
                      strength.level.index >= PasswordLevel.medium.index
                          ? Icons.check_circle
                          : Icons.info_outline,
                      size: 14.sp,
                      color: strength.level.index >= PasswordLevel.medium.index
                          ? Colors.green
                          : Colors.orange,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Color _getStrengthColor(PasswordLevel level) {
    switch (level) {
      case PasswordLevel.veryWeak:
        return Colors.red;
      case PasswordLevel.weak:
        return Colors.orange;
      case PasswordLevel.medium:
        return Colors.yellow.shade700;
      case PasswordLevel.strong:
        return Colors.lightGreen;
      case PasswordLevel.veryStrong:
        return Colors.green;
    }
  }
}

/// 🔑 Secure Password Field
class SecurePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool showStrengthIndicator;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const SecurePasswordField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.showStrengthIndicator = true,
    this.onChanged,
    this.validator,
  });

  @override
  State<SecurePasswordField> createState() => _SecurePasswordFieldState();
}

class _SecurePasswordFieldState extends State<SecurePasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: (value) {
            setState(() {}); // Rebuild for strength indicator
            widget.onChanged?.call(value);
          },
          validator: widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'كلمة المرور مطلوبة';
                }
                if (!PasswordValidator.isValid(value)) {
                  return 'كلمة المرور ضعيفة';
                }
                return null;
              },
          decoration: InputDecoration(
            labelText: widget.labelText ?? 'كلمة المرور',
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        if (widget.showStrengthIndicator &&
            widget.controller.text.isNotEmpty) ...[
          SizedBox(height: 8.h),
          PasswordStrengthIndicator(password: widget.controller.text),
        ],
      ],
    );
  }
}
