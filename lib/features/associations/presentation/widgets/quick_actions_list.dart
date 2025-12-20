import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// ⚡ قائمة الإجراءات السريعة
class QuickActionsList extends StatelessWidget {
  final VoidCallback onAddAssociation;
  final VoidCallback? onExport;
  final VoidCallback? onImport;
  final VoidCallback onRefresh;

  const QuickActionsList({
    super.key,
    required this.onAddAssociation,
    this.onExport,
    this.onImport,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.mediumSpace,
        vertical: ResponsiveUtils.smallSpace,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // إضافة
            _QuickActionButton(
              icon: Icons.add_business,
              label: 'إضافة',
              color: theme.colorScheme.primary,
              onTap: onAddAssociation,
            ),
            // تصدير
            if (onExport != null)
              _QuickActionButton(
                icon: Icons.upload_file,
                label: 'تصدير',
                color: Colors.green,
                onTap: onExport,
              ),
            // استيراد
            if (onImport != null)
              _QuickActionButton(
                icon: Icons.download,
                label: 'استيراد',
                color: Colors.orange,
                onTap: onImport,
              ),
            // تحديث
            _QuickActionButton(
              icon: Icons.refresh,
              label: 'تحديث',
              color: Colors.blue,
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(ResponsiveUtils.smallRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.smallSpace,
          vertical: ResponsiveUtils.xSmallSpace,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveUtils.getIconSize(context),
              ),
            ),
            SizedBox(height: ResponsiveUtils.xSmallSpace),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
