import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/kafalat_providers.dart';
import '../widgets/sponsorship_form_sheet.dart';

class KafalatPage extends ConsumerWidget {
  const KafalatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الكفالات'),
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
        body: TabBarView(
          children: [
            _UnsponsoredTab(),
            _SponsoredTab(),
          ],
        ),
      ),
    );
  }
}

class _UnsponsoredTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kafalatUnsponsoredBeneficiariesProvider);
    final theme = Theme.of(context);

    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 44.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'لا يوجد مستفيدون غير مكفولين حالياً',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final b = items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(
                  b.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('الرقم الوطني: ${b.idNumber}'),
                onTap: () {
                  HapticPatterns.selection();
                  context.push('/beneficiaries/${b.id}');
                },
                trailing: FilledButton.tonalIcon(
                  onPressed: () {
                    HapticPatterns.submit();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ResponsiveBottomSheet(
                        title: 'تنفيذ كفالة',
                        icon: Icons.handshake_outlined,
                        initialChildSize: 0.75,
                        child: SponsorshipFormSheet(beneficiaryId: b.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text('تنفيذ'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _SponsoredTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kafalatSponsoredBeneficiariesProvider);
    final theme = Theme.of(context);

    return state.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 44.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'لا يوجد مستفيدون مكفولون حالياً',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final row = items[index];
            final b = row.beneficiary;
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(
                  b.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'كفالات نشطة: ${row.activeSponsorshipsCount} • آخر رقم ملف: ${row.lastFileNo ?? '-'}',
                ),
                onTap: () {
                  HapticPatterns.selection();
                  context.push('/beneficiaries/${b.id}');
                },
                trailing: IconButton(
                  tooltip: 'إضافة كفالة',
                  onPressed: () {
                    HapticPatterns.submit();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ResponsiveBottomSheet(
                        title: 'إضافة كفالة',
                        icon: Icons.handshake_outlined,
                        initialChildSize: 0.75,
                        child: SponsorshipFormSheet(beneficiaryId: b.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}
