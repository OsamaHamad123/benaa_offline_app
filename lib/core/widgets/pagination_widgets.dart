import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pagination/pagination_service.dart';

/// 📄 Pagination Widget
/// عنصر التنقل بين الصفحات

class PaginationControls extends StatelessWidget {
  final PaginationResult paginationResult;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.paginationResult,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (paginationResult.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          _buildNavigationButton(
            context: context,
            icon: Icons.arrow_back_ios,
            label: 'السابق',
            enabled: paginationResult.hasPreviousPage,
            onPressed: () => onPageChanged(paginationResult.currentPage - 1),
          ),

          // Page info
          Expanded(
            child: Center(
              child: Text(
                'صفحة ${paginationResult.currentPage} من ${paginationResult.totalPages}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),

          // Next button
          _buildNavigationButton(
            context: context,
            icon: Icons.arrow_forward_ios,
            label: 'التالي',
            enabled: paginationResult.hasNextPage,
            onPressed: () => onPageChanged(paginationResult.currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18.sp),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: enabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
      ),
    );
  }
}

/// 📄 Pagination Info Widget
/// معلومات الصفحات والعناصر

class PaginationInfo extends StatelessWidget {
  final PaginationResult paginationResult;

  const PaginationInfo({
    super.key,
    required this.paginationResult,
  });

  @override
  Widget build(BuildContext context) {
    final startItem = paginationResult.isEmpty
        ? 0
        : (paginationResult.currentPage - 1) * paginationResult.pageSize + 1;
    final endItem = paginationResult.isEmpty
        ? 0
        : startItem + paginationResult.items.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16.sp,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: 8.w),
          Text(
            'عرض $startItem - $endItem من ${paginationResult.totalItems}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

/// 📄 Page Size Selector
/// اختيار عدد العناصر في الصفحة

class PageSizeSelector extends StatelessWidget {
  final int currentPageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageSizeChanged;

  const PageSizeSelector({
    super.key,
    required this.currentPageSize,
    this.pageSizeOptions = const [10, 20, 50, 100],
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'عدد العناصر:',
          style: Theme.of(context).textTheme.bodySmall,
          textDirection: TextDirection.rtl,
        ),
        SizedBox(width: 8.w),
        DropdownButton<int>(
          value: currentPageSize,
          items: pageSizeOptions
              .map((size) => DropdownMenuItem(
                    value: size,
                    child: Text('$size'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onPageSizeChanged(value);
            }
          },
          underline: const SizedBox.shrink(),
          isDense: true,
        ),
      ],
    );
  }
}
