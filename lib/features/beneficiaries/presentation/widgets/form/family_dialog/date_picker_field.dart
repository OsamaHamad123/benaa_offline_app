import 'package:flutter/material.dart';

/// 📅 Date Picker Field
///
/// حقل اختيار التاريخ
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const DatePickerField({
    required this.selectedDate, required this.onDateSelected, required this.label, super.key,
    this.icon = Icons.calendar_today,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) onDateSelected(date);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(icon, size: 20, color: iconColor),
        ),
        child: Text(
          selectedDate != null ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : 'اضغط للاختيار',
          style: const TextStyle(fontSize: 14.0),
        ),
      ),
    );
  }
}
