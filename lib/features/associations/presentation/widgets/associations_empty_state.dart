import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🎨 Empty State للجمعيات مع Animation
///
/// Widget لعرض حالة فارغة جميلة مع أنيميشن
class AssociationsEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const AssociationsEmptyState({
    required this.onAddPressed, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✨ أيقونة متحركة
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.8, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(26),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(51),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      size: 60.r,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.largeSpace),

            Text(
              'لا توجد جمعيات حتى الآن',
              style: TextStyle(
                fontSize: ResponsiveUtils.titleFont,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            SizedBox(height: ResponsiveUtils.smallSpace),

            Text(
              'ابدأ بإضافة أول جمعية لك\nوسنساعدك في إدارتها بسهولة 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.bodyFont,
                color: colorScheme.onSurface.withAlpha(153),
                height: 1.5,
              ),
            ),

            SizedBox(height: ResponsiveUtils.xLargeSpace),

            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: Icon(
                Icons.add_business,
                size: ResponsiveUtils.getIconSize(context),
              ),
              label: Text(
                'إضافة جمعية جديدة',
                style: TextStyle(
                  fontSize: ResponsiveUtils.mediumFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.largeSpace,
                  vertical: ResponsiveUtils.mediumSpace,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveUtils.largeRadius),
                ),
                elevation: 6,
                shadowColor: colorScheme.primary.withAlpha(102),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
