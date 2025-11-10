import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ✨ Reusable Form Field Builders
/// Widgets مشتركة لبناء الحقول بشكل موحد

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
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    readOnly: readOnly,
    onTap: onTap,
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
  return DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    items: items,
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
