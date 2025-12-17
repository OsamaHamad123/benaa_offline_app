import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 📊 عداد النتائج مع علامة الفلاتر النشطة
///
/// Widget لعرض عدد النتائج الحالية وحالة الفلاتر
class AssociationsResultCounter extends StatelessWidget {
  final int count;
  final bool hasActiveFilters;

  const AssociationsResultCounter({
    super.key,
    required this.count,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.mediumSpace,
        vertical: ResponsiveUtils.smallSpace,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عدد الجمعيات: $count',
            style: TextStyle(
              fontSize: ResponsiveUtils.bodyFont,
              color: colorScheme.onSurface.withAlpha(153),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasActiveFilters)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.smallSpace,
                vertical: ResponsiveUtils.xSmallSpace,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              child: Text(
                'فلاتر نشطة',
                style: TextStyle(
                  fontSize: ResponsiveUtils.smallFont,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
