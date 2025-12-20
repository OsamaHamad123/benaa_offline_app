import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 Selectable Chip Widget
///
/// رقاقة قابلة للاختيار - يستخدم في الحالة الصحية وسبب الوفاة
class SelectableChip extends StatelessWidget {
  final String label;
  final int value;
  final int? groupValue;
  final ValueChanged<int> onTap;
  final Color? color;

  const SelectableChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final chipColor = color ?? Colors.blue;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? chipColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
