import 'package:benaa_offline_app/features/kafalat/presentation/providers/kafalat_providers.dart';
import 'package:benaa_offline_app/features/kafalat/presentation/widgets/cards/unsponsored_beneficiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/haptic_patterns.dart';
import '../../../../../core/widgets/shimmer_loaders.dart';

/// 📋 Tab "غير مكفول" - قائمة المستفيدين غير المكفولين
class UnsponsoredTab extends ConsumerWidget {
  const UnsponsoredTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kafalatUnsponsoredBeneficiariesProvider);
    final theme = Theme.of(context);

    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(28.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism_outlined,
                      size: 64.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'جميع المستفيدين مكفولون! 🎉',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'رائع! جميع المستفيدين لديهم كفالات نشطة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  FilledButton.icon(
                    onPressed: () {
                      HapticPatterns.selection();
                      context.push('/beneficiaries');
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('إضافة مستفيد جديد'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(kafalatUnsponsoredBeneficiariesProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // حساب عدد الأعمدة بناءً على عرض الشاشة
              final crossAxisCount = constraints.maxWidth >= 1200
                  ? 3
                  : constraints.maxWidth >= 700
                      ? 2
                      : 1;

              final childAspectRatio = constraints.maxWidth >= 700 ? 2.8 : 2.2;

              if (crossAxisCount == 1) {
                // Mobile view - قائمة عادية
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return UnsponsoredBeneficiaryCard(beneficiary: b);
                  },
                );
              }

              // Tablet/Desktop view - Grid
              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final b = items[index];
                  return UnsponsoredBeneficiaryCard(beneficiary: b);
                },
              );
            },
          ),
        );
      },
      loading: () => const ListShimmerLoader(itemCount: 5, itemHeight: 88),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56.sp, color: theme.colorScheme.error),
              SizedBox(height: 16.h),
              Text('خطأ في تحميل البيانات', style: theme.textTheme.titleLarge),
              SizedBox(height: 8.h),
              Text('$e', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
