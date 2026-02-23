import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ✅ Visual Validation Indicator
///
/// Widget يظهر حالة التحقق بصرياً بجانب الحقل
class ValidationIndicator extends StatelessWidget {
  final bool? isValid;
  final String? successMessage;

  const ValidationIndicator({
    super.key,
    this.isValid,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isValid == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isValid!
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isValid!
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid! ? Icons.check_circle : Icons.error,
            color: isValid! ? Colors.green : Colors.red,
            size: 16.sp,
          ),
          if (successMessage != null && isValid!) ...[
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                successMessage!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 💡 Field Helper Text with Icon
///
/// Widget لعرض نص مساعد مع أيقونة
class FieldHelperText extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const FieldHelperText({
    required this.text, super.key,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.grey[600];

    return Padding(
      padding: EdgeInsets.only(top: 6.h, right: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: effectiveColor),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: effectiveColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⚡ Real-time Validation Wrapper
///
/// Wrapper يضيف real-time validation مع visual feedback
class RealTimeValidatedField extends StatefulWidget {
  final Widget child;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool showSuccessIndicator;
  final String? successMessage;

  const RealTimeValidatedField({
    required this.child, super.key,
    this.validator,
    this.controller,
    this.showSuccessIndicator = true,
    this.successMessage,
  });

  @override
  State<RealTimeValidatedField> createState() => _RealTimeValidatedFieldState();
}

class _RealTimeValidatedFieldState extends State<RealTimeValidatedField> {
  bool? _isValid;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_validateField);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    if (widget.validator == null) return;

    final error = widget.validator!(widget.controller?.text);
    setState(() {
      _isValid = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.child,
        if (widget.showSuccessIndicator && _isValid != null && _isValid!) ...[
          SizedBox(height: 8.h),
          ValidationIndicator(
            isValid: true,
            successMessage: widget.successMessage ?? 'صحيح ✓',
          ),
        ],
      ],
    );
  }
}
