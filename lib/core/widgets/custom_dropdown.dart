import 'package:flutter/material.dart';

/// Custom reusable Dropdown component
class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final String labelText;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool required;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: required ? '$labelText *' : labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      items: items,
      onChanged: onChanged,
      validator: required
          ? (value) {
              if (value == null) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            }
          : null,
    );
  }
}
