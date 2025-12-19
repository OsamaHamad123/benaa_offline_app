import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🔽 قائمة منسدلة مع تصميم موحد
class ModernDropdown<T> extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool required;

  const ModernDropdown({
    super.key,
    required this.labelText,
    this.hintText,
    required this.icon,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
          size: ResponsiveUtils.getIconSize(context) * 0.8,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
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
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.mediumSpace,
          vertical: ResponsiveUtils.smallSpace * 1.5,
        ),
      ),
      dropdownColor: theme.colorScheme.surface,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
