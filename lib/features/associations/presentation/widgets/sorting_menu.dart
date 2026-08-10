import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔄 قائمة الترتيب - PopupMenuButton
enum SortOption {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
}

class SortingMenu extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortingMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: Icon(
        Icons.sort,
        size: 24.sp,
        color: Theme.of(context).colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      offset: Offset(0, 48.h),
      itemBuilder: (context) => [
        _buildMenuItem(
          option: SortOption.nameAsc,
          icon: Icons.sort_by_alpha,
          title: 'الاسم (أ - ي)',
          context: context,
        ),
        _buildMenuItem(
          option: SortOption.nameDesc,
          icon: Icons.sort_by_alpha,
          title: 'الاسم (ي - أ)',
          context: context,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          option: SortOption.dateNewest,
          icon: Icons.arrow_downward,
          title: 'الأحدث أولاً',
          context: context,
        ),
        _buildMenuItem(
          option: SortOption.dateOldest,
          icon: Icons.arrow_upward,
          title: 'الأقدم أولاً',
          context: context,
        ),
      ],
      onSelected: onSortChanged,
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem({
    required SortOption option,
    required IconData icon,
    required String title,
    required BuildContext context,
  }) {
    final isSelected = currentSort == option;
    final color = Theme.of(context).colorScheme.primary;

    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: isSelected ? color : Colors.grey.shade600,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade800,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18.sp,
              color: color,
            ),
        ],
      ),
    );
  }

  /// الحصول على النص الوصفي للترتيب الحالي
  static String getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.nameAsc:
        return 'الاسم (أ - ي)';
      case SortOption.nameDesc:
        return 'الاسم (ي - أ)';
      case SortOption.dateNewest:
        return 'الأحدث أولاً';
      case SortOption.dateOldest:
        return 'الأقدم أولاً';
    }
  }
}
