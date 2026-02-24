import 'package:benaa_offline_app/features/kafalat/presentation/widgets/sponsorship_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/haptic_patterns.dart';
import '../../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../../../../data/db/drift_database.dart';

/// 🎨 Unsponsored Beneficiary Card - بطاقة مستفيد غير مكفول
class UnsponsoredBeneficiaryCard extends ConsumerWidget {
  final Beneficiary beneficiary;
  final int? priorityScore;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  const UnsponsoredBeneficiaryCard({
    required this.beneficiary,
    this.priorityScore,
    this.isSelected = false,
    this.onToggleSelection,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'مستفيد غير مكفول: ${beneficiary.fullName}, رقم الهوية ${beneficiary.idNumber}',
      button: true,
      child: Card(
        elevation: isSelected ? 4 : 2,
        shadowColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide(color: Colors.transparent, width: 0),
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
                            if (priorityScore != null) ...[
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'أولوية: $priorityScore',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer.withOpacity(0.5),
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
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                            child: SponsorshipFormSheet(beneficiaryId: beneficiary.id),
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
                  if (onToggleSelection != null) ...[
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onToggleSelection,
                        icon: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked),
                        label: Text(isSelected ? 'محدد للتنفيذ الجماعي' : 'تحديد للتنفيذ الجماعي'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
