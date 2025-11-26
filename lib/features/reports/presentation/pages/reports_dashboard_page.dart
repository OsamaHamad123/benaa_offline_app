import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';

/// 📊 Reports Dashboard - Hub for all reports
class ReportsDashboardPage extends ConsumerWidget {
  const ReportsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        backgroundColor: Colors.indigo.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر نوع التقرير',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Reports Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _ReportCard(
                  title: 'تقرير المستفيدين',
                  icon: Icons.people,
                  color: Colors.blue,
                  description: 'تقرير شامل عن المستفيدين',
                  onTap: () =>
                      Navigator.pushNamed(context, '/reports/beneficiaries'),
                ),
                _ReportCard(
                  title: 'تقرير الزيارات',
                  icon: Icons.assignment,
                  color: Colors.green,
                  description: 'تقرير الزيارات الميدانية',
                  onTap: () => _showComingSoon(context),
                ),
                _ReportCard(
                  title: 'التوزيع الجغرافي',
                  icon: Icons.map,
                  color: Colors.orange,
                  description: 'توزيع المستفيدين حسب المناطق',
                  onTap: () => _showComingSoon(context),
                ),
                _ReportCard(
                  title: 'تقرير الفئات',
                  icon: Icons.category,
                  color: Colors.purple,
                  description: 'توزيع حسب الفئات',
                  onTap: () => _showComingSoon(context),
                ),
                _ReportCard(
                  title: 'تقرير الأداء',
                  icon: Icons.trending_up,
                  color: Colors.teal,
                  description: 'تحليل الأداء والإنجازات',
                  onTap: () => _showComingSoon(context),
                ),
                _ReportCard(
                  title: 'تقرير مخصص',
                  icon: Icons.settings,
                  color: Colors.grey,
                  description: 'إنشاء تقرير مخصص',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Stats
            const Text(
              'إحصائيات سريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(
                  child: _StatCard(
                    title: 'إجمالي التقارير',
                    value: '24',
                    icon: Icons.description,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: _StatCard(
                    title: 'هذا الشهر',
                    value: '8',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    EnhancedSnackbar.showInfo(context, message: 'قريباً...');
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
