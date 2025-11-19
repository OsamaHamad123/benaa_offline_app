import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Quick Date Filter Buttons - أزرار الفلاتر السريعة
class QuickDateFilters extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime start, DateTime end) onFilterSelected;
  final VoidCallback onClearFilter;

  const QuickDateFilters({
    super.key,
    this.startDate,
    this.endDate,
    required this.onFilterSelected,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: 'اليوم',
              icon: Icons.today,
              onTap: () {
                final start = DateTime(now.year, now.month, now.day);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                onFilterSelected(start, end);
              },
              isSelected: _isToday(startDate, endDate),
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              context,
              label: 'هذا الأسبوع',
              icon: Icons.date_range,
              onTap: () {
                final start = now.subtract(Duration(days: now.weekday - 1));
                final startOfWeek = DateTime(
                  start.year,
                  start.month,
                  start.day,
                );
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                onFilterSelected(startOfWeek, end);
              },
              isSelected: _isThisWeek(startDate, endDate),
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              context,
              label: 'هذا الشهر',
              icon: Icons.calendar_month,
              onTap: () {
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                onFilterSelected(start, end);
              },
              isSelected: _isThisMonth(startDate, endDate),
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              context,
              label: 'هذه السنة',
              icon: Icons.calendar_today,
              onTap: () {
                final start = DateTime(now.year, 1, 1);
                final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
                onFilterSelected(start, end);
              },
              isSelected: _isThisYear(startDate, endDate),
            ),
            if (startDate != null || endDate != null) ...[
              SizedBox(width: 8.w),
              _buildClearChip(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Colors.grey[200],
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearChip(BuildContext context) {
    return Material(
      color: Colors.red[100],
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onClearFilter,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.clear, size: 18.sp, color: Colors.red[700]),
              SizedBox(width: 4.w),
              Text(
                'مسح',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    return startDay == today && end.day == now.day;
  }

  bool _isThisWeek(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final startDay = DateTime(start.year, start.month, start.day);
    return startDay == startOfWeek;
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final startDay = DateTime(start.year, start.month, start.day);
    return startDay == monthStart;
  }

  bool _isThisYear(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final startDay = DateTime(start.year, start.month, start.day);
    return startDay == yearStart;
  }
}
