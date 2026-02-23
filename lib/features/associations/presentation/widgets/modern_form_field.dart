import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 📝 حقل نصي مع تصميم موحد (unified design)
class ModernFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onFieldSubmitted;
  final int maxLines;
  final bool enabled;
  final bool required;

  const ModernFormField({
    required this.controller, required this.labelText, required this.icon, super.key,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.right,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: required ? '$labelText *' : labelText,
            hintText: hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: ResponsiveUtils.getIconSize(context) * 0.8,
            ),
            suffixIcon: value.text.trim().isNotEmpty && enabled
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: ResponsiveUtils.getIconSize(context) * 0.7,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () {
                      controller.clear();
                      focusNode?.requestFocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: ResponsiveUtils.smallSpace * 1.5,
            ),
          ),
          validator: validator,
          onFieldSubmitted: (_) => onFieldSubmitted?.call(),
        );
      },
    );
  }
}
