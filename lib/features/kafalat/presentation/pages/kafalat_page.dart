import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/providers/providers.dart';
import '../../../../data/db/daos/sponsorships_dao.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../../core/widgets/shimmer_loaders.dart';
import '../providers/kafalat_providers.dart';
import '../widgets/sponsorship_form_sheet.dart';

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
        body: TabBarView(
          children: [
            _UnsponsoredTab(),
            _SponsoredTab(),
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
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(28.w),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism_outlined,
                      size: 64.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'جميع المستفيدين مكفولون! 🎉',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'رائع! جميع المستفيدين لديهم كفالات نشطة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  FilledButton.icon(
                    onPressed: () {
                      HapticPatterns.selection();
                      context.push('/beneficiaries');
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('إضافة مستفيد جديد'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 14.h),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(kafalatUnsponsoredBeneficiariesProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // حساب عدد الأعمدة بناءً على عرض الشاشة
              final crossAxisCount = constraints.maxWidth >= 1200
                  ? 3
                  : constraints.maxWidth >= 700
                      ? 2
                      : 1;

              final childAspectRatio = constraints.maxWidth >= 700 ? 2.8 : 2.2;

              if (crossAxisCount == 1) {
                // Mobile view - قائمة عادية
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return _UnsponsoredBeneficiaryCard(beneficiary: b);
                  },
                );
              }

              // Tablet/Desktop view - Grid
              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final b = items[index];
                  return _UnsponsoredBeneficiaryCard(beneficiary: b);
                },
              );
            },
          ),
        );
      },
      loading: () => const ListShimmerLoader(itemCount: 5, itemHeight: 88),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 56.sp, color: theme.colorScheme.error),
              SizedBox(height: 16.h),
              Text('خطأ في تحميل البيانات', style: theme.textTheme.titleLarge),
              SizedBox(height: 8.h),
              Text('$e',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SponsoredTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SponsorshipsTab();
  }
}

class _SponsorshipsTab extends ConsumerStatefulWidget {
  const _SponsorshipsTab();

  @override
  ConsumerState<_SponsorshipsTab> createState() => _SponsorshipsTabState();
}

class _SponsorshipsTabState extends ConsumerState<_SponsorshipsTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String? _associationId;
  String _status = 'all';
  String _type = 'all';
  String _query = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = v.trim());
    });
  }

  Future<void> _confirmDelete(BuildContext context, int fileNo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: Text('هل تريد حذف الكفالة رقم ملف $fileNo؟',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final db = ref.read(databaseProvider);
      await db.sponsorshipsDao.deleteSponsorship(fileNo: fileNo);
      if (!mounted) return;
      HapticPatterns.success();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف الكفالة')));
    } catch (e) {
      if (!mounted) return;
      HapticPatterns.error();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل حذف الكفالة: $e')));
    }
  }

  void _openEditSheet(BuildContext context, SponsorshipWithDetails row) {
    HapticPatterns.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: 'تعديل كفالة (رقم الملف: ${row.sponsorship.fileNo})',
        icon: Icons.edit_outlined,
        initialChildSize: 0.85,
        child: SponsorshipFormSheet(
          beneficiaryId: row.beneficiary.id,
          initialSponsorship: row.sponsorship,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    String typeLabel(String t) {
      return switch (t) {
        'monthly' => 'شهرية',
        'one_time' => 'مرة واحدة',
        'other' => 'أخرى',
        _ => t,
      };
    }

    final associationsAsync = ref.watch(kafalatActiveAssociationsProvider);
    final sponsorshipsAsync = ref.watch(
      kafalatSponsorshipsProvider((
        associationId: _associationId,
        status: _status,
        type: _type,
        query: _query
      )),
    );

    return Column(
      children: [
        // إحصائيات سريعة
        sponsorshipsAsync.when(
          data: (allRows) {
            final total = allRows.length;
            final active =
                allRows.where((r) => r.sponsorship.status == 'active').length;
            final paused =
                allRows.where((r) => r.sponsorship.status == 'paused').length;
            final ended =
                allRows.where((r) => r.sponsorship.status == 'ended').length;

            return Container(
              margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
                    theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    icon: Icons.handshake_rounded,
                    label: 'إجمالي',
                    value: '$total',
                    color: theme.colorScheme.primary,
                  ),
                  Container(
                      width: 1,
                      height: 40.h,
                      color: theme.colorScheme.outline.withOpacity(0.3)),
                  _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'نشطة',
                    value: '$active',
                    color: Colors.green,
                  ),
                  Container(
                      width: 1,
                      height: 40.h,
                      color: theme.colorScheme.outline.withOpacity(0.3)),
                  _StatCard(
                    icon: Icons.pause_circle_outline,
                    label: 'موقوفة',
                    value: '$paused',
                    color: Colors.orange,
                  ),
                  Container(
                      width: 1,
                      height: 40.h,
                      color: theme.colorScheme.outline.withOpacity(0.3)),
                  _StatCard(
                    icon: Icons.cancel_outlined,
                    label: 'منتهية',
                    value: '$ended',
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  HapticPatterns.selection();
                  context.push('/kafalat/import');
                },
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('رفع ملف Excel'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'بحث في الكفالات... (اسم/رقم هوية/رقم ملف)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'مسح',
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final threeCols = constraints.maxWidth >= 820;

              final associationField = associationsAsync.when(
                data: (associations) {
                  return DropdownButtonFormField<String>(
                    value: _associationId,
                    decoration: const InputDecoration(
                      labelText: 'المؤسسة الكافلة',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('جميع المؤسسات')),
                      ...associations.map(
                        (a) => DropdownMenuItem<String>(
                            value: a.id, child: Text(a.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _associationId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('فشل تحميل المؤسسات: $e'),
              );

              final statusField = DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'حالة الكفالة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                  DropdownMenuItem(value: 'active', child: Text('نشطة')),
                  DropdownMenuItem(value: 'paused', child: Text('موقوفة')),
                  DropdownMenuItem(value: 'ended', child: Text('منتهية')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'all'),
              );

              final typeField = DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'نوع الكفالة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('جميع الأنواع')),
                  DropdownMenuItem(value: 'monthly', child: Text('شهرية')),
                  DropdownMenuItem(value: 'one_time', child: Text('مرة واحدة')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'all'),
              );

              if (threeCols) {
                return Row(
                  children: [
                    Expanded(child: associationField),
                    SizedBox(width: 12.w),
                    Expanded(child: statusField),
                    SizedBox(width: 12.w),
                    Expanded(child: typeField),
                  ],
                );
              }

              return Column(
                children: [
                  associationField,
                  SizedBox(height: 12.h),
                  statusField,
                  SizedBox(height: 12.h),
                  typeField,
                ],
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        const Divider(height: 1),
        Expanded(
          child: sponsorshipsAsync.when(
            data: (rows) {
              if (rows.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.handshake_outlined,
                            size: 56.sp,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'لا توجد كفالات مطابقة',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'جرب تغيير الفلاتر أو إضافة كفالة جديدة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.refresh, size: 18),
                              label: const Text('إعادة تعيين الفلاتر'),
                              onPressed: () {
                                setState(() {
                                  _associationId = null;
                                  _status = 'all';
                                  _type = 'all';
                                  _query = '';
                                  _searchController.clear();
                                });
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.person_add, size: 18),
                              label: const Text('إضافة مستفيد'),
                              onPressed: () => context.push('/beneficiaries'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!isWide) {
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(kafalatSponsorshipsProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      return _SponsorshipCard(
                        row: r,
                        onEdit: () => _openEditSheet(context, r),
                        onDelete: () =>
                            _confirmDelete(context, r.sponsorship.fileNo),
                        typeLabel: typeLabel,
                      );
                    },
                  ),
                );
              }

              return Card(
                margin: EdgeInsets.all(16.w),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        theme.colorScheme.surfaceContainerHighest),
                    headingRowHeight: 56,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 72,
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    columns: [
                      DataColumn(
                        label: Text('الإجراءات',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('اسم المكفول',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('رقم الهوية',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('المؤسسة',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('رقم الملف',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('الحالة',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('النوع',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('البداية',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('النهاية',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      DataColumn(
                        label: Text('القيمة',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                    rows: rows.map((r) {
                      final s = r.sponsorship;
                      final amount = s.amount == null
                          ? '-'
                          : '${s.amount!.toStringAsFixed(2)} ${s.currency ?? ''}'
                              .trim();
                      String fmt(DateTime? d) {
                        if (d == null) return '-';
                        return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                      }

                      String statusLabel(String st) {
                        return switch (st) {
                          'active' => 'نشطة',
                          'paused' => 'موقوفة',
                          'ended' => 'منتهية',
                          _ => st,
                        };
                      }

                      final statusColor = s.status == 'active'
                          ? theme.colorScheme.primary
                          : s.status == 'paused'
                              ? Colors.orange
                              : theme.colorScheme.error;

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'تعديل',
                                  onPressed: () => _openEditSheet(context, r),
                                  icon: Icon(Icons.edit_outlined,
                                      size: 20.sp,
                                      color: theme.colorScheme.primary),
                                ),
                                IconButton(
                                  tooltip: 'حذف',
                                  onPressed: () =>
                                      _confirmDelete(context, s.fileNo),
                                  icon: Icon(Icons.delete_outline,
                                      size: 20.sp,
                                      color: theme.colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              r.beneficiary.fullName,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(
                            Text('${r.beneficiary.idNumber}',
                                style: theme.textTheme.bodyMedium),
                          ),
                          DataCell(
                            Text(
                              r.associationName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '${s.fileNo}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                    color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                statusLabel(s.status),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              typeLabel(s.sponsorshipType),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          DataCell(Text(fmt(s.startDate),
                              style: theme.textTheme.bodyMedium)),
                          DataCell(Text(fmt(s.endDate),
                              style: theme.textTheme.bodyMedium)),
                          DataCell(
                            Text(
                              amount,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(growable: false),
                  ),
                ),
              );
            },
            loading: () =>
                const ListShimmerLoader(itemCount: 8, itemHeight: 100),
            error: (e, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56.sp, color: theme.colorScheme.error),
                    SizedBox(height: 16.h),
                    Text('خطأ في تحميل البيانات',
                        style: theme.textTheme.titleLarge),
                    SizedBox(height: 8.h),
                    Text('$e',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// بطاقة كفالة - تصميم جذاب واحترافي
class _SponsorshipCard extends ConsumerWidget {
  final SponsorshipWithDetails row;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) typeLabel;

  const _SponsorshipCard({
    required this.row,
    required this.onEdit,
    required this.onDelete,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = row.sponsorship;

    final statusColor = s.status == 'active'
        ? theme.colorScheme.primary
        : s.status == 'paused'
            ? Colors.orange
            : theme.colorScheme.error;

    String statusLabel(String st) {
      return switch (st) {
        'active' => 'نشطة',
        'paused' => 'موقوفة',
        'ended' => 'منتهية',
        _ => st,
      };
    }

    String fmt(DateTime? d) {
      if (d == null) return '-';
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    final amount = s.amount == null
        ? null
        : '${s.amount!.toStringAsFixed(0)} ${s.currency ?? 'IQD'}'.trim();

    return Semantics(
      label:
          'كفالة ${row.beneficiary.fullName}, رقم الملف ${s.fileNo}, الحالة ${statusLabel(s.status)}',
      button: true,
      child: Card(
        elevation: 3,
        shadowColor: statusColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                theme.colorScheme.surface,
                statusColor.withOpacity(0.03),
              ],
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticPatterns.selection();
              context.push('/beneficiaries/${row.beneficiary.id}');
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - الاسم والحالة والقائمة
                  Row(
                    children: [
                      // أيقونة مع gradient
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor, statusColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.handshake_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // الاسم
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.beneficiary.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              row.associationName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // شارة الحالة
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: statusColor.withOpacity(0.5), width: 1.5),
                        ),
                        child: Text(
                          statusLabel(s.status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // قائمة الإجراءات
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') onEdit();
                          if (v == 'delete') onDelete();
                        },
                        icon: Icon(Icons.more_vert, size: 20.sp),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 18.sp,
                                    color: theme.colorScheme.primary),
                                SizedBox(width: 8.w),
                                const Text('تعديل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18.sp,
                                    color: theme.colorScheme.error),
                                SizedBox(width: 8.w),
                                const Text('حذف'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // معلومات رئيسية في صناديق
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.folder_special_outlined,
                          label: 'رقم الملف',
                          value: '${s.fileNo}',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.badge_outlined,
                          label: 'رقم الهوية',
                          value: '${row.beneficiary.idNumber}',
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),

                  if (amount != null || s.startDate != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        if (amount != null)
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.payments_outlined,
                              label: 'القيمة',
                              value: amount,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        if (amount != null && s.startDate != null)
                          SizedBox(width: 12.w),
                        if (s.startDate != null)
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.calendar_today_outlined,
                              label: 'تاريخ البداية',
                              value: fmt(s.startDate),
                              color: Colors.teal,
                            ),
                          ),
                      ],
                    ),
                  ],

                  SizedBox(height: 12.h),

                  // نوع الكفالة مع ألوان مخصصة
                  _TypeBadge(type: s.sponsorshipType, typeLabel: typeLabel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// صندوق معلومات صغير
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// بطاقة مستفيد غير مكفول - تصميم جذاب
class _UnsponsoredBeneficiaryCard extends ConsumerWidget {
  final Beneficiary beneficiary;

  const _UnsponsoredBeneficiaryCard({required this.beneficiary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          'مستفيد غير مكفول: ${beneficiary.fullName}, رقم الهوية ${beneficiary.idNumber}',
      button: true,
      child: Card(
        elevation: 2,
        shadowColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.primaryContainer.withOpacity(0.05),
              ],
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticPatterns.selection();
              context.push('/beneficiaries/${beneficiary.id}');
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header مع الأيقونة
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              beneficiary.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'غير مكفول',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // معلومات المستفيد
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'رقم الهوية: ${beneficiary.idNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر تنفيذ كفالة
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
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
                            child: SponsorshipFormSheet(
                                beneficiaryId: beneficiary.id),
                          ),
                        );
                      },
                      icon: Icon(Icons.handshake_outlined, size: 20.sp),
                      label: const Text('تنفيذ كفالة'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// شارة نوع الكفالة مع ألوان مخصصة
class _TypeBadge extends StatelessWidget {
  final String type;
  final String Function(String) typeLabel;

  const _TypeBadge({
    required this.type,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ألوان مخصصة لكل نوع
    final typeConfig = switch (type) {
      'monthly' => (
          color: Colors.blue,
          icon: Icons.calendar_month_outlined,
        ),
      'one_time' => (
          color: Colors.purple,
          icon: Icons.bolt_outlined,
        ),
      _ => (
          color: theme.colorScheme.tertiary,
          icon: Icons.category_outlined,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeConfig.color.withOpacity(0.15),
            typeConfig.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: typeConfig.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeConfig.icon,
            size: 18.sp,
            color: typeConfig.color,
          ),
          SizedBox(width: 6.w),
          Text(
            typeLabel(type),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeConfig.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية صغيرة
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
