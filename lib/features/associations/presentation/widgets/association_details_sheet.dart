import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../domain/entities/association.dart';

class AssociationDetailsSheet extends StatelessWidget {
  final Association association;
  final String? representativeName;
  final String? associationTypeLabel;
  final VoidCallback onEdit;

  const AssociationDetailsSheet({
    required this.association,
    required this.onEdit,
    super.key,
    this.representativeName,
    this.associationTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String valueOrDash(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return '—';
      return trimmed;
    }

    return ResponsiveBottomSheet(
      title: 'تفاصيل الجمعية',
      icon: Icons.apartment_outlined,
      useDraggableScrollableSheet: false,
      maxChildSize: 0.85,
      builder: (scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
          children: [
            Text(
              association.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            if (association.shortName?.trim().isNotEmpty == true) ...[
              SizedBox(height: 4.h),
              Text(
                association.shortName!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.right,
              ),
            ],
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: association.isActive
                      ? Colors.green.withOpacity(0.12)
                      : theme.colorScheme.errorContainer.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  association.isActive ? 'نشطة' : 'معطلة',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: association.isActive ? Colors.green.shade800 : theme.colorScheme.error,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            _DetailRow(label: 'الهاتف', value: valueOrDash(association.phone)),
            _DetailRow(label: 'البريد', value: valueOrDash(association.email)),
            _DetailRow(label: 'المندوب', value: valueOrDash(representativeName)),
            _DetailRow(label: 'نوع الجمعية', value: valueOrDash(associationTypeLabel)),
            _DetailRow(label: 'اسم البنك', value: valueOrDash(association.bankName)),
            _DetailRow(label: 'رقم الحساب', value: valueOrDash(association.accountNumber)),
            _DetailRow(label: 'العملة', value: valueOrDash(association.accountCurrency)),
            _DetailRow(label: 'SWIFT', value: valueOrDash(association.swiftCode)),
            _DetailRow(label: 'هاتف البنك', value: valueOrDash(association.bankPhone)),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onEdit();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('تعديل الجمعية'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
