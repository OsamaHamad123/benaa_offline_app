import 'package:benaa_offline_app/data/db/daos/sponsorships_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import 'card_gradient_header.dart';
import 'card_info_section.dart';
import 'card_action_buttons.dart';
import 'card_status_indicator.dart';

/// 🎨 Professional Sponsorship Card - بطاقة الكفالة الاحترافية
class ProfessionalSponsorshipCard extends ConsumerWidget {
  final SponsorshipWithDetails row;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) typeLabel;
  final String Function(String)? statusLabel;
  final bool showLegacyTypeBadge;
  final bool showLegacyStatusBadge;

  const ProfessionalSponsorshipCard({
    required this.row,
    required this.onEdit,
    required this.onDelete,
    required this.typeLabel,
    this.statusLabel,
    this.showLegacyTypeBadge = false,
    this.showLegacyStatusBadge = false,
    super.key,
  });

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    return switch (status) {
      'active' => theme.colorScheme.primary,
      'paused' => Colors.orange,
      'ended' => theme.colorScheme.error,
      _ => theme.colorScheme.tertiary,
    };
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String? _getFormattedAmount() {
    final s = row.sponsorship;
    if (s.amount == null) return null;
    return '${s.amount!.toStringAsFixed(0)} ${s.currency ?? 'IQD'}'.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = row.sponsorship;
    final statusColor = _getStatusColor(context, s.status);

    return Semantics(
      label: 'كفالة ${row.beneficiary.fullName}, رقم الملف ${s.fileNo}',
      button: true,
      child: Stack(
        children: [
          Card(
            elevation: 2,
            shadowColor: statusColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: statusColor.withOpacity(0.1),
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticPatterns.selection();
                context.push('/beneficiaries/${row.beneficiary.id}');
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header مع Gradient
                  CardGradientHeader(
                    beneficiaryName: row.beneficiary.fullName,
                    associationName: row.associationName,
                    status: s.status,
                    statusLabel: statusLabel?.call(s.status),
                    showLegacyBadge: showLegacyStatusBadge,
                    statusColor: statusColor,
                  ),

                  // Info Section
                  CardInfoSection(
                    fileNo: s.fileNo,
                    idNumber: row.beneficiary.idNumber,
                    amount: _getFormattedAmount(),
                    startDate: _formatDate(s.startDate),
                    endDate: _formatDate(s.endDate),
                    sponsorshipType: s.sponsorshipType,
                    typeLabel: typeLabel,
                    showLegacyBadge: showLegacyTypeBadge,
                  ),

                  _SponsorshipTimeline(
                    startDate: s.startDate,
                    endDate: s.endDate,
                    status: s.status,
                  ),

                  // Action Buttons
                  CardActionButtons(
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onViewDetails: () {
                      HapticPatterns.selection();
                      context.push('/beneficiaries/${row.beneficiary.id}');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Status Indicator Badge
          CardStatusIndicator(
            createdAt: s.createdAt,
            endDate: s.endDate,
          ),
        ],
      ),
    );
  }
}

class _SponsorshipTimeline extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  const _SponsorshipTimeline({
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  String _fmt(DateTime? value) {
    if (value == null) return '-';
    return '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (status) {
      'active' => Colors.green,
      'paused' => Colors.orange,
      'ended' => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_outline, size: 16.sp, color: theme.colorScheme.primary),
            SizedBox(width: 6.w),
            Text('بدء: ${_fmt(startDate)}', style: theme.textTheme.labelSmall),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                height: 2,
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(Icons.flag_outlined, size: 16.sp, color: statusColor),
            SizedBox(width: 6.w),
            Text('نهاية: ${_fmt(endDate)}', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
