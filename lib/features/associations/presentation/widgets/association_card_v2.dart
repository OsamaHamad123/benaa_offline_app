import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../domain/entities/association.dart';

/// 🏢 Association Card - إصدار محسّن V2
///
/// ✅ استخدام ResponsiveUtils
/// ✅ Theme موحد
/// ✅ تصميم أنيق
class AssociationCardV2 extends StatelessWidget {
  final Association association;
  final String? representativeName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AssociationCardV2({
    super.key,
    required this.association,
    this.representativeName,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Name + Status
              Row(
                children: [
                  // أيقونة الجمعية
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(ResponsiveUtils.mediumRadius),
                    ),
                    child: Icon(
                      Icons.business,
                      color: colorScheme.primary,
                      size: 24.r,
                    ),
                  ),

                  SizedBox(width: ResponsiveUtils.smallSpace),

                  // الاسم والاسم المختصر
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          association.name,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.mediumFont,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (association.shortName != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            association.shortName!,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.smallFont,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: ResponsiveUtils.smallSpace),

                  // حالة الجمعية
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: association.isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(ResponsiveUtils.smallRadius),
                    ),
                    child: Text(
                      association.isActive ? 'نشط' : 'معطل',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.xSmallFont,
                        color: association.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // زر الحذف
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20.r),
                    color: Colors.red,
                    onPressed: onDelete,
                    tooltip: 'حذف',
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // معلومات الاتصال
              Row(
                children: [
                  // الهاتف
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.phone,
                      label: 'الهاتف',
                      value: association.phone,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.smallSpace),
                  // البريد الإلكتروني
                  if (association.email != null)
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.email,
                        label: 'البريد',
                        value: association.email!,
                        color: colorScheme.secondary,
                      ),
                    ),
                ],
              ),

              SizedBox(height: ResponsiveUtils.smallSpace),

              // معلومات البنك
              Row(
                children: [
                  // البنك
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.account_balance,
                      label: 'البنك',
                      value: association.bankName,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.smallSpace),
                  // رقم الحساب
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.credit_card,
                      label: 'الحساب',
                      value: association.accountNumber,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              // المندوب
              if (representativeName != null) ...[
                SizedBox(height: ResponsiveUtils.smallSpace),
                _InfoRow(
                  icon: Icons.person,
                  label: 'المندوب',
                  value: representativeName!,
                  color: Colors.purple,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// صف معلومات
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.xSmallFont,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.smallFont,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
