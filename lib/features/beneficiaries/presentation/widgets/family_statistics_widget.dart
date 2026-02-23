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

    return Card(
      margin: const EdgeInsets.all(16),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

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
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي الأفراد',
                stats.totalMembers.toString(),
                Icons.people,
                colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'ذكور',
                stats.malesCount.toString(),
                Icons.man,
                colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'إناث',
                stats.femalesCount.toString(),
                Icons.woman,
                colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'الأطفال (<18)',
                stats.childrenCount.toString(),
                Icons.child_care,
                colorScheme.error,
              ),
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
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'سليم وآمن',
                stats.healthySafe.toString(),
                Icons.health_and_safety,
                colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'مريض',
                stats.sick.toString(),
                Icons.sick,
                colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'مريض مزمن',
                stats.chronicSick.toString(),
                Icons.medical_services,
                colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'معاق',
                stats.disabled.toString(),
                Icons.accessible,
                colorScheme.tertiary,
              ),
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
          'عدد الأموات المسجلين',
          count.toString(),
          Icons.local_hospital,
          colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
