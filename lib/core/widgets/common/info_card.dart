import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// بطاقة معلومات قابلة لإعادة الاستخدام
///
/// استخدامات:
/// - عرض الإحصائيات
/// - البطاقات في Dashboard
/// - معلومات المستفيدين
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isCompact;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    return Card(
      elevation: isCompact ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((isCompact ? 12 : 16).r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular((isCompact ? 12 : 16).r),
        child: Container(
          padding: EdgeInsets.all((isCompact ? 12 : 16).r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((isCompact ? 12 : 16).r),
            gradient: LinearGradient(
              colors: [cardColor.withOpacity(0.1), cardColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all((isCompact ? 8 : 12).r),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        (isCompact ? 8 : 12).r,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: (isCompact ? 20 : 24).sp,
                    ),
                  ),
                  if (!isCompact) const Spacer(),
                  if (!isCompact && onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                ],
              ),
              SizedBox(height: (isCompact ? 8 : 12).h),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (isCompact ? 20 : (isMobile ? 22 : 28)).sp,
                  color: cardColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: (isCompact ? 12 : 14).sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// نسخة مصغرة من InfoCard (horizontal)
class InfoCardCompact extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const InfoCardCompact({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: cardColor),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              color: cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
