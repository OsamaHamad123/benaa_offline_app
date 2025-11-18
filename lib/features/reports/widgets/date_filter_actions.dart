import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Date Filter Actions - أزرار التصفية والتحديث في AppBar
class DateFilterActions extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onFilterTap;
  final VoidCallback onClearFilter;
  final VoidCallback onRefresh;

  const DateFilterActions({
    super.key,
    this.startDate,
    this.endDate,
    required this.onFilterTap,
    required this.onClearFilter,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Date Range Chip
        if (startDate != null && endDate != null) _buildDateChip(),
        // Filter Button
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: onFilterTap,
          tooltip: 'تصفية حسب التاريخ',
        ),
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'تحديث البيانات',
        ),
      ],
    );
  }

  Widget _buildDateChip() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Chip(
        avatar: Icon(Icons.date_range, size: 16.sp),
        label: Text(
          '${startDate!.day}/${startDate!.month} - ${endDate!.day}/${endDate!.month}',
          style: TextStyle(fontSize: 11.sp),
        ),
        deleteIcon: Icon(Icons.close, size: 16.sp),
        onDeleted: onClearFilter,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
