import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/daos/family_members_dao.dart';
import '../providers/beneficiary_dependencies.dart';

/// ويدجت عرض إحصائيات أفراد العائلة
class FamilyStatisticsWidget extends ConsumerWidget {
  final int beneficiaryId;

  const FamilyStatisticsWidget({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);

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

            // الإحصائيات الإجمالية
            FutureBuilder<FamilyStatistics>(
              future: database.familyMembersDao.getStatistics(beneficiaryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('خطأ: ${snapshot.error}');
                }

                final stats = snapshot.data;
                if (stats == null) {
                  return const Text('لا توجد بيانات');
                }

                return Column(
                  children: [
                    _buildOverallStats(stats),
                    const SizedBox(height: 24),
                    _buildHealthStats(stats),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // إحصائيات حسب صلة القرابة
            FutureBuilder<Map<String, int>>(
              future: database.familyMembersDao.getMembersByRelationshipStats(
                beneficiaryId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final relationshipStats = snapshot.data ?? {};
                if (relationshipStats.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _buildRelationshipStats(relationshipStats);
              },
            ),

            const SizedBox(height: 24),

            // عدد الأموات
            FutureBuilder<int>(
              future: database.familyDeceasedDao.getDeceasedCount(
                beneficiaryId,
              ),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return _buildDeceasedStats(count);
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
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'يعيشون معاً',
                stats.livingTogether.toString(),
                Icons.home,
                Colors.green,
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
                'ذوو إعاقة',
                stats.withDisability.toString(),
                Icons.accessible,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'أمراض مزمنة',
                stats.withChronicDisease.toString(),
                Icons.medical_services,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelationshipStats(Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التوزيع حسب صلة القرابة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stats.entries.map((entry) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              label: Text(entry.key),
            );
          }).toList(),
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
