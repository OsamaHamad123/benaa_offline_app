import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/family_providers.dart';
import 'shared/beneficiary_async_state_view.dart';

/// ويدجت عرض إحصائيات أفراد العائلة
class FamilyStatisticsWidget extends ConsumerWidget {
  final int beneficiaryId;

  const FamilyStatisticsWidget({required this.beneficiaryId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'إحصائيات العائلة',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),

            // الإحصائيات الإجمالية - استخدام Provider
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(
                  familyStatisticsProvider(beneficiaryId),
                );

                return statsAsync.when(
                  data: (stats) => Column(
                    children: [
                      _buildOverallStats(context, stats),
                      const SizedBox(height: 24),
                      _buildHealthStats(context, stats),
                    ],
                  ),
                  loading: () => const BeneficiaryAsyncStateView.loading(
                    message: 'جاري تحميل إحصائيات العائلة...',
                  ),
                  error: (error, stack) => BeneficiaryAsyncStateView.error(
                    message: 'تعذر تحميل إحصائيات العائلة',
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // عدد الأموات - استخدام Provider
            Consumer(
              builder: (context, ref, child) {
                final deceasedAsync = ref.watch(
                  familyDeceasedProvider(beneficiaryId),
                );

                return deceasedAsync.when(
                  data: (deceased) => _buildDeceasedStats(context, deceased.length),
                  loading: () => const BeneficiaryAsyncStateView.loading(
                    message: 'جاري تحميل بيانات الأموات...',
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  error: (_, __) => const BeneficiaryAsyncStateView.error(
                    message: 'تعذر تحميل بيانات الأموات',
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, FamilyStatistics stats) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات الإجمالية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatCard(
              context,
              'إجمالي الأفراد',
              stats.totalMembers.toString(),
              Icons.people,
              colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'ذكور',
              stats.malesCount.toString(),
              Icons.man,
              colorScheme.secondary,
            ),
            _buildStatCard(
              context,
              'إناث',
              stats.femalesCount.toString(),
              Icons.woman,
              colorScheme.tertiary,
            ),
            _buildStatCard(
              context,
              'الأطفال (<18)',
              stats.childrenCount.toString(),
              Icons.child_care,
              colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthStats(BuildContext context, FamilyStatistics stats) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة الصحية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatCard(
              context,
              'سليم وآمن',
              stats.healthySafe.toString(),
              Icons.health_and_safety,
              colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'مريض',
              stats.sick.toString(),
              Icons.sick,
              colorScheme.secondary,
            ),
            _buildStatCard(
              context,
              'مريض مزمن',
              stats.chronicSick.toString(),
              Icons.medical_services,
              colorScheme.error,
            ),
            _buildStatCard(
              context,
              'معاق',
              stats.disabled.toString(),
              Icons.accessible,
              colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeceasedStats(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأموات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          'عدد الأموات المسجلين',
          count.toString(),
          Icons.local_hospital,
          colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
