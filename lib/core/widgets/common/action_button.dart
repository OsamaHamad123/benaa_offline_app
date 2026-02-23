import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// زر إجراء قابل لإعادة الاستخدام
///
/// استخدامات:
/// - أزرار الحفظ
/// - أزرار الإضافة
/// - أي زر رئيسي
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ButtonType type;

  const ActionButton({
    required this.label, super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.type = ButtonType.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    final buttonStyle = _getButtonStyle(context, isMobile);
    final buttonChild = _buildChild(isMobile);

    Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = icon != null
            ? ElevatedButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: buttonChild,
                style: buttonStyle,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonChild,
              );
        break;
      case ButtonType.outlined:
        button = icon != null
            ? OutlinedButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: buttonChild,
                style: buttonStyle,
              )
            : OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonChild,
              );
        break;
      case ButtonType.text:
        button = icon != null
            ? TextButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: Icon(icon),
                label: buttonChild,
                style: buttonStyle,
              )
            : TextButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonChild,
              );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isMobile) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: (isMobile ? 20 : 24).w,
        vertical: (isMobile ? 12 : 14).h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((isMobile ? 10 : 12).r),
      ),
    );
  }

  Widget _buildChild(bool isMobile) {
    if (isLoading) {
      return SizedBox(
        height: (isMobile ? 18 : 20).h,
        width: (isMobile ? 18 : 20).w,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Text(label, style: TextStyle(fontSize: (isMobile ? 14 : 16).sp));
  }
}

/// نوع الزر
enum ButtonType { elevated, outlined, text }

/// أزرار متعددة في صف
class ActionButtonRow extends StatelessWidget {
  final List<ActionButton> buttons;
  final MainAxisAlignment alignment;
  final double spacing;

  const ActionButtonRow({
    required this.buttons, super.key,
    this.alignment = MainAxisAlignment.end,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    if (isMobile) {
      // على الموبايل: أزرار عمودية
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons
            .map(
              (btn) => Padding(
                padding: EdgeInsets.only(bottom: spacing.h),
                child: ActionButton(
                  label: btn.label,
                  onPressed: btn.onPressed,
                  icon: btn.icon,
                  isLoading: btn.isLoading,
                  isFullWidth: true,
                  backgroundColor: btn.backgroundColor,
                  type: btn.type,
                ),
              ),
            )
            .toList(),
      );
    }

    // على الديسكتوب: أزرار أفقية
    return Row(
      mainAxisAlignment: alignment,
      children: buttons
          .map(
            (btn) => Padding(
              padding: EdgeInsets.only(left: spacing.w),
              child: btn,
            ),
          )
          .toList(),
    );
  }
}
