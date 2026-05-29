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
                  data: (stats) => _buildResponsiveStatsGrid(context, stats),
                  loading: () => const BeneficiaryAsyncStateView.loading(
                    message: 'جاري تحميل إحصائيات العائلة...',
                  ),
                  error: (error, stack) => BeneficiaryAsyncStateView.error(
                    message: 'تعذر تحميل إحصائيات العائلة',
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

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

  Widget _buildResponsiveStatsGrid(BuildContext context, FamilyStatistics stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = <({String title, String value, IconData icon, Color color})>[
      (title: 'أفراد الأسرة', value: stats.totalMembers.toString(), icon: Icons.people, color: colorScheme.primary),
      (title: 'الأطفال', value: stats.childrenCount.toString(), icon: Icons.child_care, color: colorScheme.secondary),
      (title: 'كبار السن', value: stats.elderlyCount.toString(), icon: Icons.elderly, color: colorScheme.tertiary),
      (title: 'ذوي الإعاقة', value: stats.disabled.toString(), icon: Icons.accessible, color: colorScheme.error),
      (title: 'المرضى', value: stats.sickTotal.toString(), icon: Icons.monitor_heart, color: colorScheme.primary),
      (title: 'مصدر الدخل', value: 'غير محدد', icon: Icons.work_outline, color: colorScheme.onSurfaceVariant),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 520 ? 3 : 2;
        final spacing = 10.0;
        final itemWidth = (width - ((columns - 1) * spacing)) / columns;
        const itemHeight = 110.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: _buildStatCard(
                    context,
                    card.title,
                    card.value,
                    card.icon,
                    card.color,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
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
        SizedBox(
          width: double.infinity,
          child: _buildStatCard(
            context,
            'عدد الأموات المسجلين',
            count.toString(),
            Icons.local_hospital,
            colorScheme.onSurfaceVariant,
          ),
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
