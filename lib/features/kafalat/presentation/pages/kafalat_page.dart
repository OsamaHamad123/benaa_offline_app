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
  const KafalatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
        body: const TabBarView(
          children: [
            UnsponsoredTab(),
            SponsoredTab(),
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
