import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔀 Sorting Menu - قائمة الترتيب
enum SortOption {
  dateNewest('التاريخ (الأحدث)', Icons.calendar_today, true),
  dateOldest('التاريخ (الأقدم)', Icons.calendar_today, false),
  amountHighest('المبلغ (الأعلى)', Icons.arrow_upward, true),
  amountLowest('المبلغ (الأدنى)', Icons.arrow_downward, true),
  nameAZ('الاسم (أ-ي)', Icons.sort_by_alpha, true),
  nameZA('الاسم (ي-أ)', Icons.sort_by_alpha, false),
  fileNoAsc('رقم الملف (تصاعدي)', Icons.numbers, true),
  fileNoDesc('رقم الملف (تنازلي)', Icons.numbers, false);

  final String label;
  final IconData icon;
  final bool isAscending;

  const SortOption(this.label, this.icon, this.isAscending);
}

class SortingMenu extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const SortingMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<SortOption>(
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'ترتيب',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      tooltip: 'خيارات الترتيب',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 8,
      offset: Offset(0, 12.h),
      itemBuilder: (context) => [
        // Header
        PopupMenuItem<SortOption>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    color: theme.colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ترتيب حسب',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
            ],
          ),
        ),

        // Date Options
        _buildGroupHeader(context, 'التاريخ'),
        _buildMenuItem(context, SortOption.dateNewest),
        _buildMenuItem(context, SortOption.dateOldest),

        // Amount Options
        _buildGroupHeader(context, 'المبلغ'),
        _buildMenuItem(context, SortOption.amountHighest),
        _buildMenuItem(context, SortOption.amountLowest),

        // Name Options
        _buildGroupHeader(context, 'الاسم'),
        _buildMenuItem(context, SortOption.nameAZ),
        _buildMenuItem(context, SortOption.nameZA),

        // File Number Options
        _buildGroupHeader(context, 'رقم الملف'),
        _buildMenuItem(context, SortOption.fileNoAsc),
        _buildMenuItem(context, SortOption.fileNoDesc),
      ],
      onSelected: onSortChanged,
    );
  }

  PopupMenuItem<SortOption> _buildGroupHeader(
    BuildContext context,
    String title,
  ) {
    final theme = Theme.of(context);
    return PopupMenuItem<SortOption>(
      enabled: false,
      child: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(
    BuildContext context,
    SortOption option,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentSort == option;

    return PopupMenuItem<SortOption>(
      value: option,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 18.sp,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
