import 'package:flutter/material.dart';

/// ⚡ Dropdown field optimized for performance
/// NO ScreenUtil - direct sizes for instant response
class V2DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String? hint;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool isRequired;
  final bool enabled;

  const V2DropdownField({
    required this.value, required this.items, required this.label, required this.onChanged, super.key,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dropdownColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.arrow_drop_down_rounded, size: 24),
      style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
    );
  }
}
