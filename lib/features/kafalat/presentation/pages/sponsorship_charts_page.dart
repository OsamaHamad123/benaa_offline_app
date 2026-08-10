import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/kafalat_providers.dart';
import '../widgets/charts/sponsorship_charts_widget.dart';

/// 📊 Sponsorship Charts Page - صفحة التحليلات البيانية
class SponsorshipChartsPage extends ConsumerWidget {
  const SponsorshipChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sponsorshipsAsync = ref.watch(
      kafalatSponsorshipsProvider((
        associationId: null,
        status: 'all',
        type: 'all',
        query: '',
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات البيانية'),
        elevation: 0,
      ),
      body: sponsorshipsAsync.when(
        data: (sponsorships) {
          if (sponsorships.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 80.sp,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد بيانات كافية للتحليل',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'قم بإضافة كفالات لعرض التحليلات',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 8.h),
                SponsorshipChartsWidget(sponsorships: sponsorships),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60.sp,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'حدث خطأ في تحميل البيانات',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
