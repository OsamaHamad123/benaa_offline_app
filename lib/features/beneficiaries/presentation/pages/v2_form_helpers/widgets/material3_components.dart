import 'package:flutter/material.dart';
import '../form_constants.dart';
import 'package:flutter/services.dart';

class FormFieldFocusTracker {
  FormFieldFocusTracker._();

  static final ValueNotifier<String?> focusedFieldLabel = ValueNotifier<String?>(null);

  static void update(String? label) {
    focusedFieldLabel.value = label;
  }
}

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
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

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
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldRadius = BorderRadius.circular(FormConstants.defaultBorderRadius + 2);
    const singleLineFieldMinHeight = 52.0;
    final resolvedTextInputAction =
        textInputAction ?? ((maxLines ?? 1) > 1 ? TextInputAction.newline : TextInputAction.next);

    final textField = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: resolvedTextInputAction,
      onFieldSubmitted: onFieldSubmitted ??
          (_) {
            if (readOnly || (maxLines ?? 1) > 1) {
              return;
            }

            final shouldUnfocus = resolvedTextInputAction == TextInputAction.done ||
                resolvedTextInputAction == TextInputAction.go ||
                resolvedTextInputAction == TextInputAction.search ||
                resolvedTextInputAction == TextInputAction.send;

            if (shouldUnfocus) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).nextFocus();
            }
          },
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.6),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label!,
                    style: const TextStyle(
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
        fillColor:
            enabled ? theme.colorScheme.surfaceContainerLow : theme.colorScheme.surfaceContainerLow.withOpacity(0.65),
        constraints: const BoxConstraints(minHeight: singleLineFieldMinHeight),

        // Prefix Icon with better styling
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  prefixIcon,
                  size: 20,
                  color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),

        // Suffix Icon
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),

        // Borders with elevation effect
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.8),
        ),

        // Counter
        counterStyle: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),

        // Content Padding
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: maxLines! > 1 ? 15 : 14,
        ),
      ),
    );

    final fieldWithElevation = Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          FormFieldFocusTracker.update(label);
        } else if (FormFieldFocusTracker.focusedFieldLabel.value == label) {
          FormFieldFocusTracker.update(null);
        }
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: fieldRadius,
        child: textField,
      ),
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
    required this.items,
    super.key,
    this.value,
    this.label,
    this.prefixIcon,
    this.isRequired = false,
    this.onChanged,
    this.validator,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldRadius = BorderRadius.circular(FormConstants.defaultBorderRadius + 2);
    const singleLineFieldMinHeight = 52.0;

    // 🔧 Fix crash: ensure value exists in items or set to null
    // This prevents "duplicate value" error
    final safeValue = items.any((item) => item.value == value) ? value : null;

    final dropdown = DropdownButtonFormField<T>(
      initialValue: safeValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        // Use labelText (String) instead of label (Widget) to let Flutter handle layout
        labelText: label != null ? (isRequired ? '${label!} *' : label!) : null,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isRequired ? theme.colorScheme.error : null,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        constraints: const BoxConstraints(minHeight: singleLineFieldMinHeight),

        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  prefixIcon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),

        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.6),
        ),

        // Reduced padding to fit label + icon in narrow test constraints (146.3px)
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      dropdownColor: theme.colorScheme.surface,
      borderRadius: fieldRadius,
    );

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          FormFieldFocusTracker.update(label);
        } else if (FormFieldFocusTracker.focusedFieldLabel.value == label) {
          FormFieldFocusTracker.update(null);
        }
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: fieldRadius,
        child: dropdown,
      ),
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
    required this.title,
    required this.children,
    super.key,
    this.icon,
    this.padding,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: headerColor ?? theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
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
                    const SizedBox(width: 12),
                  ],
                  Flexible(
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
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
