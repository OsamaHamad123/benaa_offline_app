import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// عنوان قسم قابل لإعادة الاستخدام
///
/// استخدامات:
/// - تقسيم الصفحات إلى أقسام
/// - عناوين الفورم
/// - عناوين القوائم
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final Color? color;
  final bool showDivider;

  const SectionHeader({
    required this.title, super.key,
    this.subtitle,
    this.icon,
    this.action,
    this.color,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: color ?? theme.colorScheme.primary,
                size: (isMobile ? 20 : 24).sp,
              ),
              SizedBox(width: (isMobile ? 8 : 12).w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: (isMobile ? 18 : 20).sp,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: (isMobile ? 12 : 13).sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        if (showDivider) ...[
          SizedBox(height: 12.h),
          Divider(
            color: (color ?? theme.colorScheme.primary).withOpacity(0.3),
            thickness: 2,
          ),
        ],
      ],
    );
  }
}

/// عنوان قسم مصغر
class SectionHeaderCompact extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeaderCompact({required this.title, super.key, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
