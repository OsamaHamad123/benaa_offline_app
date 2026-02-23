import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Date Range Picker Widget for Reports
class DateRangePicker extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final VoidCallback onClear;
  final Function(DateTimeRange) onDateRangeSelected;

  const DateRangePicker({
    required this.onClear, required this.onDateRangeSelected, super.key,
    this.selectedRange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: selectedRange != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الفترة المحددة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'جميع الفترات',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
            if (selectedRange != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
                tooltip: 'إزالة التصفية',
                iconSize: 20.sp,
              ),
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () => _showDateRangePicker(context),
              tooltip: 'اختيار فترة',
              iconSize: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
      helpText: 'اختر الفترة الزمنية',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      saveText: 'حفظ',
      fieldStartLabelText: 'تاريخ البداية',
      fieldEndLabelText: 'تاريخ النهاية',
    );

    if (picked != null) {
      onDateRangeSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
