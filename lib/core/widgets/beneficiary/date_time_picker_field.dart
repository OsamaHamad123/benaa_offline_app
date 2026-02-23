import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Date Time Picker Widget
class DateTimePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final String label;

  const DateTimePickerField({
    required this.selectedDate, required this.onTap, super.key,
    this.label = 'تاريخ ووقت الزيارة',
  });

  static String formatDateTime(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    formatDateTime(selectedDate),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 24.sp,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
