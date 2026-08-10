import 'package:flutter/material.dart';
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        // Label with required indicator
        label: label != null
            ? (isRequired
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        size: 8,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  )
                : Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ))
            : null,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        helperText: helperText,
        helperMaxLines: 2,
        helperStyle: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),

        // Prefix Icon with better styling
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  prefixIcon,
                  size: 22,
                  color: enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              )
            : null,

        // Suffix Icon
        suffixIcon: suffixIcon,

        // Borders with elevation effect
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
        ),

        // Counter
        counterStyle: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),

        // Content Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: maxLines! > 1 ? 16 : 14,
        ),
      ),
    );

    // Add subtle elevation with Material wrapper
    final fieldWithElevation = Material(
      elevation: enabled ? 1 : 0,
      borderRadius: BorderRadius.circular(FormConstants.defaultBorderRadius),
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: textField,
    );

    // 🆕 Wrap with Tooltip if provided
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: fieldWithElevation);
    }

    return fieldWithElevation;
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

    final dropdown = DropdownButtonFormField<T>(
      value: safeValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        // Use labelText (String) instead of label (Widget) to let Flutter handle layout
        labelText: label != null ? (isRequired ? '$label! *' : label!) : null,
        labelStyle: TextStyle(
          fontSize: 11, // Reduced from 13.sp to fit narrow test constraints
          fontWeight: FontWeight.w500,
          color: isRequired ? theme.colorScheme.error : null,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,

        prefixIcon: prefixIcon != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  prefixIcon,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),

        // Reduced padding to fit label + icon in narrow test constraints (146.3px)
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: theme.colorScheme.primary,
        size: 20, // Reduced from 26.sp to save space
      ),
      dropdownColor: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(FormConstants.defaultBorderRadius),
    );

    // Add subtle elevation with Material wrapper
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(FormConstants.defaultBorderRadius),
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      child: dropdown,
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
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: FormConstants.sectionCardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            FormConstants.defaultBorderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: headerColor ?? theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(FormConstants.defaultBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 24,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 12),
                  ],
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
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
              padding: padding ?? EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
