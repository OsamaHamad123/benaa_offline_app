import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/haptic_patterns.dart';

/// 🏜️ Empty Sponsorships State - حالة فارغة للكفالات
class EmptySponsorshipsState extends StatelessWidget {
  final VoidCallback? onAddSponsorship;
  final VoidCallback? onClearFilters;
  final bool hasFilters;

  const EmptySponsorshipsState({
    super.key,
    this.onAddSponsorship,
    this.onClearFilters,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                      theme.colorScheme.secondaryContainer.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFilters ? Icons.filter_alt_off : Icons.handshake_outlined,
                  size: 72.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Title
            Text(
              hasFilters ? 'لا توجد نتائج' : 'لا توجد كفالات بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              hasFilters
                  ? 'لا توجد كفالات مطابقة للفلاتر المحددة.\nجرب تعديل الفلاتر أو مسحها.'
                  : 'ابدأ بإضافة كفالة جديدة للمستفيدين\nغير المكفولين من تبويب "غير مكفول"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                if (hasFilters && onClearFilters != null)
                  FilledButton.icon(
                    onPressed: () {
                      HapticPatterns.selection();
                      onClearFilters!();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('مسح الفلاتر'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                if (onAddSponsorship != null)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      HapticPatterns.submit();
                      onAddSponsorship!();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مستفيد'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
              ],
            ),

            // Helpful Tips
            if (!hasFilters) ...[
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.tertiary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'نصيحة',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '• انتقل إلى تبويب "غير مكفول" لرؤية المستفيدين\n'
                      '• اضغط على "تنفيذ كفالة" لإضافة كفالة جديدة\n'
                      '• يمكنك إدارة الكفالات من هنا بعد إضافتها',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🏜️ Empty Beneficiaries State - حالة فارغة للمستفيدين
class EmptyBeneficiariesState extends StatelessWidget {
  final VoidCallback? onAddBeneficiary;

  const EmptyBeneficiariesState({
    super.key,
    this.onAddBeneficiary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.2),
                      Colors.teal.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volunteer_activism_outlined,
                  size: 72.sp,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Title
            Text(
              'جميع المستفيدين مكفولون! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              'رائع! جميع المستفيدين لديهم كفالات نشطة.\n'
              'يمكنك إضافة مستفيدين جدد إذا كنت تريد.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action Button
            FilledButton.icon(
              onPressed: () {
                HapticPatterns.selection();
                context.push('/beneficiaries');
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('إضافة مستفيد جديد'),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 14.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
