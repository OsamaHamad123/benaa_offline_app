import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔘 Settings Switch Tile
/// عنصر تبديل (switch) مخصص

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData icon;
  final Color color;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onChanged != null;

    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      secondary: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isEnabled ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isEnabled ? color : Colors.grey,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isEnabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isEnabled
              ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: color,
    );
  }
}

/// ➡️ Settings Navigation Tile
/// عنصر للانتقال إلى صفحة أو dialog

class SettingsNavigationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsNavigationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
      onTap: onTap,
    );
  }
}

/// 🎨 Settings Color Scheme Tile
/// عنصر خاص لعرض نظام الألوان

class SettingsColorSchemeTile extends StatelessWidget {
  final String currentScheme;
  final VoidCallback onTap;

  const SettingsColorSchemeTile({
    super.key,
    required this.currentScheme,
    required this.onTap,
  });

  Color _getColorFromScheme(String scheme) {
    switch (scheme) {
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _getColorLabel(String scheme) {
    const labels = {
      'blue': 'أزرق',
      'green': 'أخضر',
      'purple': 'بنفسجي',
      'orange': 'برتقالي',
      'red': 'أحمر',
      'teal': 'تركواز',
    };
    return labels[scheme] ?? 'أزرق';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorFromScheme(currentScheme);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.palette_rounded,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      title: Text(
        'لون التطبيق',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _getColorLabel(currentScheme),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}
