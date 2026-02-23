import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

/// Speed Dial FAB للإجراءات السريعة
class DashboardSpeedDial extends StatelessWidget {
  const DashboardSpeedDial({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add_rounded,
      activeIcon: Icons.close_rounded,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.red,
      activeForegroundColor: Colors.white,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.person_add_rounded, color: Colors.white),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'إضافة مستفيد',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelBackgroundColor: Colors.green[50],
          onTap: () => context.push('/beneficiaries/add'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.event_rounded, color: Colors.white),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'إضافة زيارة',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelBackgroundColor: Colors.orange[50],
          onTap: () {
            // TODO: Navigate to add visit
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('إضافة زيارة - قيد التطوير')),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.sync_rounded, color: Colors.white),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          label: 'مزامنة الآن',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelBackgroundColor: Colors.purple[50],
          onTap: () {
            // TODO: Trigger sync
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('جاري المزامنة...')));
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.search_rounded, color: Colors.white),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'بحث سريع',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelBackgroundColor: Colors.blue[50],
          onTap: () => context.push('/search'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.assessment_rounded, color: Colors.white),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          label: 'التقارير',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelBackgroundColor: Colors.indigo[50],
          onTap: () => context.push('/reports'),
        ),
      ],
    );
  }
}

/// Export Actions Row
class ExportActionsRow extends StatelessWidget {
  const ExportActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ExportButton(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF',
              color: Colors.red,
              onTap: () {
                // TODO: Export PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تصدير PDF - قيد التطوير')),
                );
              },
            ),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _ExportButton(
              icon: Icons.table_chart_rounded,
              label: 'Excel',
              color: Colors.green,
              onTap: () {
                // TODO: Export Excel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تصدير Excel - قيد التطوير')),
                );
              },
            ),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _ExportButton(
              icon: Icons.share_rounded,
              label: 'مشاركة',
              color: Colors.blue,
              onTap: () {
                // TODO: Share
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('مشاركة - قيد التطوير')),
                );
              },
            ),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _ExportButton(
              icon: Icons.print_rounded,
              label: 'طباعة',
              color: Colors.grey[700]!,
              onTap: () {
                // TODO: Print
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('طباعة - قيد التطوير')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
