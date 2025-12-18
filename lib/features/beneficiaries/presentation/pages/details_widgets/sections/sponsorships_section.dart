import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/providers/providers.dart';
import '../../../../../../../data/db/daos/sponsorships_dao.dart';

final _beneficiarySponsorshipsProvider =
    StreamProvider.autoDispose.family<List<SponsorshipWithAssociation>, int>((ref, beneficiaryId) {
  final db = ref.watch(databaseProvider);
  return db.sponsorshipsDao.watchSponsorshipsForBeneficiary(beneficiaryId);
});

class SponsorshipsSection extends ConsumerWidget {
  final int beneficiaryId;

  const SponsorshipsSection({
    required this.beneficiaryId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_beneficiarySponsorshipsProvider(beneficiaryId));

    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.handshake_outlined, size: 20.sp, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 10.w),
                Text(
                  'الكفالات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            state.when(
              data: (items) {
                if (items.isEmpty) {
                  return Text(
                    'لا توجد كفالات لهذا المستفيد',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }

                return Column(
                  children: items.map((row) {
                    final s = row.sponsorship;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _SponsorshipTile(
                        fileNo: s.fileNo,
                        associationName: row.associationName,
                        status: s.status,
                        startDate: s.startDate,
                        endDate: s.endDate,
                        amount: s.amount,
                        currency: s.currency,
                        notes: s.notes,
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('فشل تحميل الكفالات: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SponsorshipTile extends StatelessWidget {
  final int fileNo;
  final String associationName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? amount;
  final String? currency;
  final String? notes;

  const _SponsorshipTile({
    required this.fileNo,
    required this.associationName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.currency,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: theme.dividerColor.withAlpha(102)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'رقم الملف: $fileNo',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            SizedBox(height: 8.h),
            Text('الجمعية: $associationName', style: theme.textTheme.bodyMedium),
            SizedBox(height: 6.h),
            Text(
              'البداية: ${_fmtDate(startDate)} • النهاية: ${_fmtDate(endDate)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (amount != null || (currency != null && currency!.isNotEmpty))
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  'القيمة: ${amount?.toStringAsFixed(2) ?? '-'} ${currency ?? ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            if (notes != null && notes!.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  'ملاحظات: ${notes!.trim()}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return 'غير محدد';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = switch (status) {
      'active' => 'نشطة',
      'paused' => 'موقوفة',
      'ended' => 'منتهية',
      _ => status,
    };

    final color = switch (status) {
      'active' => theme.colorScheme.primary,
      'paused' => theme.colorScheme.tertiary,
      'ended' => theme.colorScheme.onSurfaceVariant,
      _ => theme.colorScheme.primary,
    };

    return Chip(
      label: Text(label),
      labelStyle: theme.textTheme.labelMedium?.copyWith(color: color),
      backgroundColor: color.withAlpha(31),
      side: BorderSide(color: color.withAlpha(89)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
    );
  }
}
