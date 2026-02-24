import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../providers/kafalat_providers.dart';
import '../widgets/tabs/unsponsored_tab.dart';
import '../widgets/tabs/sponsored_tab.dart';

///  Kafalat Main Page - صفحة الكفالات الرئيسية
/// Clean architecture - الويدجيتات في ملفات منفصلة
class KafalatPage extends ConsumerWidget {
  const KafalatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sponsoredAsync = ref.watch(kafalatSponsoredBeneficiariesProvider);
    final unsponsoredAsync = ref.watch(kafalatUnsponsoredBeneficiariesProvider);
    final sponsorshipsAsync = ref.watch(
      kafalatSponsorshipsProvider((associationId: null, status: 'all', type: 'all', query: '')),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'الكفالات',
          actions: [
            IconButton(
              tooltip: 'استيراد Excel',
              onPressed: () {
                HapticPatterns.selection();
                context.push('/kafalat/import');
              },
              icon: const Icon(Icons.upload_file_outlined),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'غير مكفول'),
              Tab(text: 'مكفول'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _Metric(
                    icon: Icons.groups_2_outlined,
                    label: 'مكفولين',
                    value: sponsoredAsync.maybeWhen(data: (rows) => '${rows.length}', orElse: () => '...'),
                  ),
                  const SizedBox(width: 12),
                  _Metric(
                    icon: Icons.priority_high_rounded,
                    label: 'غير مكفولين',
                    value: unsponsoredAsync.maybeWhen(data: (rows) => '${rows.length}', orElse: () => '...'),
                  ),
                  const SizedBox(width: 12),
                  _Metric(
                    icon: Icons.warning_amber_rounded,
                    label: 'تنتهي قريبًا',
                    value: sponsorshipsAsync.maybeWhen(
                      data: (rows) {
                        final now = DateTime.now();
                        final soon = now.add(const Duration(days: 30));
                        final count = rows
                            .where((r) =>
                                r.sponsorship.status == 'active' &&
                                r.sponsorship.endDate != null &&
                                r.sponsorship.endDate!.isAfter(now) &&
                                r.sponsorship.endDate!.isBefore(soon))
                            .length;
                        return '$count';
                      },
                      orElse: () => '...',
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  UnsponsoredTab(),
                  SponsoredTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticPatterns.submit();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('إضافة كفالة', textAlign: TextAlign.right),
                content: const Text(
                  'يجب اختيار مستفيد من تبويب "غير مكفول" لإضافة كفالة له',
                  textAlign: TextAlign.right,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('كفالة جديدة'),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Metric({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
