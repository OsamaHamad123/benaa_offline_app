import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_constants.dart';
import 'package:flutter/services.dart';

/// 🎨 Material 3 Enhanced Text Field
class M3TextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isRequired;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool enabled;
  final String? helperText;
  final bool obscureText;
  final String? tooltip; // 🆕 New

  const M3TextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.isRequired = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
    this.helperText,
    this.obscureText = false,
    this.tooltip, // 🆕 New
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textField = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        // Label with required indicator
        label: label != null
            ? (isRequired
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label!),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.star,
                          size: 8.sp,
                          color: theme.colorScheme.error,
                        ),
                      ],
                    )
                  : Text(label!))
            : null,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),

        // Prefix Icon
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 22.sp, color: theme.colorScheme.primary)
            : null,

        // Suffix Icon
        suffixIcon: suffixIcon,

        // Borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),

        // Counter
        counterStyle: TextStyle(fontSize: 11.sp),

        // Content Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: maxLines! > 1 ? 16.h : 14.h,
        ),
      ),
    );

    // 🆕 Wrap with Tooltip if provided
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: textField);
    }

    return textField;
  }
}

/// 🎨 Material 3 Dropdown Field
class M3DropdownField<T> extends StatelessWidget {
  final T? value;
  final String? label;
  final IconData? prefixIcon;
  final bool isRequired;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final String? helperText;

  const M3DropdownField({
    super.key,
    this.value,
    this.label,
    this.prefixIcon,
    this.isRequired = false,
    required this.items,
    this.onChanged,
    this.validator,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔧 Fix crash: ensure value exists in items or set to null
    // This prevents "duplicate value" error
    final safeValue = items.any((item) => item.value == value) ? value : null;

    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        // Label with required indicator
        label: label != null
            ? (isRequired
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label!),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.star,
                          size: 8.sp,
                          color: theme.colorScheme.error,
                        ),
                      ],
                    )
                  : Text(label!))
            : null,
        helperText: helperText,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 22.sp, color: theme.colorScheme.primary)
            : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: theme.colorScheme.primary,
        size: 24.sp,
      ),
      dropdownColor: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(FormConstants.defaultBorderRadius.r),
    );
  }
}

/// 🎨 Material 3 Section Card
class M3SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Color? headerColor;

  const M3SectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.padding,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: FormConstants.sectionCardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: headerColor ?? theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(FormConstants.defaultBorderRadius.r),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 24.sp,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: padding ?? EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
