import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../domain/entities/report_data.dart';
import '../providers/reports_providers.dart';
import 'gender_stat_card.dart';

/// Summary Statistics Widget - عرض ملخص الإحصائيات الرئيسية
class SummaryStatisticsWidget extends ConsumerWidget {
  const SummaryStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(summaryStatisticsProvider);
    final genderReportAsync = ref.watch(genderReportProvider);

    return statsAsync.when(
      data: (stats) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              Divider(height: 24.h, thickness: 1),

              // Main Statistics
              _StatRow(label: 'إجمالي المستفيدين', value: '${stats.total}'),
              SizedBox(height: 12.h),
              _StatRow(label: 'الأيتام', value: '${stats.orphans}'),
              SizedBox(height: 12.h),
              _StatRow(label: 'الفقراء', value: '${stats.poor}'),
              SizedBox(height: 12.h),
              _StatRow(
                label: 'بانتظار المزامنة',
                value: '${stats.pending}',
                valueColor: Colors.orange,
              ),

              // Gender Breakdown
              genderReportAsync.when(
                data: (genderCounts) =>
                    _buildGenderBreakdown(genderCounts, stats.total),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SkeletonCard(height: 200),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text('خطأ: $error')),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.assessment,
            color: Theme.of(context).colorScheme.primary,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'ملخص الإحصائيات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
        ),
      ],
    );
  }

  Widget _buildGenderBreakdown(List<GenderCount> genderCounts, int total) {
    final maleCount = genderCounts
        .firstWhere(
          (g) => g.gender == 'ذكر',
          orElse: () => GenderCount(gender: 'ذكر', count: 0),
        )
        .count;
    final femaleCount = genderCounts
        .firstWhere(
          (g) => g.gender == 'أنثى',
          orElse: () => GenderCount(gender: 'أنثى', count: 0),
        )
        .count;

    return Column(
      children: [
        Divider(height: 24.h, thickness: 1),
        Row(
          children: [
            Expanded(
              child: GenderStatCard(
                icon: Icons.male,
                label: 'ذكور',
                count: maleCount,
                total: total,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GenderStatCard(
                icon: Icons.female,
                label: 'إناث',
                count: femaleCount,
                total: total,
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Stat Row Widget - صف الإحصائيات
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final numericValue = int.tryParse(value) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        AnimatedCounter(
          value: numericValue,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
