import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/form_widgets.dart';
import '../utils/field_configs.dart';

/// ✨ Reusable Form Field Builders
/// Wrapper functions for form_widgets with beneficiary-specific configs

/// بناء TextField موحد
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? hint,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  Widget? suffix,
  ValueChanged<String>? onChanged,
  TextInputAction? textInputAction,
  VoidCallback? onEditingComplete,
}) {
  return CustomTextField(
    controller: controller,
    label: label,
    prefixIcon: icon,
    hint: hint,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    readOnly: readOnly,
    onTap: onTap,
    suffixIcon: suffix,
    onChanged: onChanged,
    textInputAction: textInputAction,
    onEditingComplete: onEditingComplete,
  );
}

/// بناء TextField من FieldConfig ✨ جديد
Widget buildTextFieldFromConfig({
  required TextEditingController controller,
  required FieldConfig config,
  VoidCallback? onTap,
  Widget? suffix,
  ValueChanged<String>? onChanged,
}) {
  return buildTextField(
    controller: controller,
    label: config.displayLabel,
    icon: config.icon,
    hint: config.hint,
    keyboardType: config.keyboardType,
    inputFormatters: config.inputFormatters,
    maxLines: config.maxLines,
    readOnly: config.readOnly,
    onTap: onTap ?? config.onTap,
    suffix: suffix ?? config.suffix,
    onChanged: onChanged ?? config.onChanged,
    textInputAction: config.textInputAction,
  );
}

/// بناء Dropdown موحد
Widget buildDropdown<T>({
  required T? value,
  required String label,
  required IconData icon,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return CustomDropdown<T>(
    value: value,
    label: label,
    prefixIcon: icon,
    items: items,
    onChanged: onChanged,
  );
}

/// بناء Dropdown من DropdownConfig ✨ جديد
Widget buildDropdownFromConfig<T>({
  required T? value,
  required DropdownConfig<T> config,
  required ValueChanged<T?> onChanged,
}) {
  return CustomDropdown<T>(
    value: value,
    label: config.displayLabel,
    prefixIcon: config.icon,
    items: config.items,
    onChanged: onChanged,
  );
}

/// بناء Section Card موحد
Widget buildSectionCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}
