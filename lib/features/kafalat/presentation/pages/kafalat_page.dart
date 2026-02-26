import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../widgets/tabs/unsponsored_tab.dart';
import '../widgets/tabs/sponsored_tab.dart';

///  Kafalat Main Page - صفحة الكفالات الرئيسية
/// Clean architecture - الويدجيتات في ملفات منفصلة
class KafalatPage extends ConsumerWidget {
  final int initialTabIndex;
  final String initialSponsoredStatus;
  final String initialSponsoredType;
  final String initialSponsoredQuery;
  final bool initialSponsoredShowFilters;

  const KafalatPage({
    super.key,
    this.initialTabIndex = 0,
    this.initialSponsoredStatus = 'all',
    this.initialSponsoredType = 'all',
    this.initialSponsoredQuery = '',
    this.initialSponsoredShowFilters = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex.clamp(0, 1),
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'الكفالات',
          actions: [
            IconButton(
              tooltip: 'لوحة الأوامر',
              onPressed: () => _showCommandPalette(context),
              icon: const Icon(Icons.space_dashboard_rounded),
            ),
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
        body: TabBarView(
          children: [
            const UnsponsoredTab(),
            SponsoredTab(
              initialStatus: initialSponsoredStatus,
              initialType: initialSponsoredType,
              initialQuery: initialSponsoredQuery,
              initiallyShowQuickFilters: initialSponsoredShowFilters,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticPatterns.submit();
            final tabController = DefaultTabController.maybeOf(context);
            if (tabController != null && tabController.index != 0) {
              tabController.animateTo(0);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('اختر مستفيدًا من تبويب "غير مكفول" ثم أنشئ الكفالة')),
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

  void _showCommandPalette(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('استيراد ملف Excel'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/kafalat/import');
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_alt_rounded),
                title: const Text('فلاتر متقدمة'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/kafalat/filters');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
