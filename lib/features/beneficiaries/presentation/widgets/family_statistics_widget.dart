import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/family_providers.dart';

/// ويدجت عرض إحصائيات أفراد العائلة
class FamilyStatisticsWidget extends ConsumerWidget {
  final int beneficiaryId;

  const FamilyStatisticsWidget({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'إحصائيات العائلة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      _buildOverallStats(stats),
                      const SizedBox(height: 24),
                      _buildHealthStats(stats),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'خطأ في تحميل الإحصائيات: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
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
                  data: (deceased) => _buildDeceasedStats(deceased.length),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(FamilyStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإحصائيات الإجمالية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي الأفراد',
                stats.totalMembers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'ذكور',
                stats.malesCount.toString(),
                Icons.man,
                Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'إناث',
                stats.femalesCount.toString(),
                Icons.woman,
                Colors.pink,
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
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthStats(FamilyStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الحالة الصحية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'سليم وآمن',
                stats.healthySafe.toString(),
                Icons.health_and_safety,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'مريض',
                stats.sick.toString(),
                Icons.sick,
                Colors.yellow.shade700,
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
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'معاق',
                stats.disabled.toString(),
                Icons.accessible,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeceasedStats(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأموات',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'عدد الأموات المسجلين',
          count.toString(),
          Icons.local_hospital,
          Colors.grey,
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
