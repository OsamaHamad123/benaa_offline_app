import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../domain/entities/association.dart';

/// 🏢 بطاقة جمعية حديثة - تصميم Material 3 فاخر
class ModernAssociationCard extends StatelessWidget {
  final Association association;
  final String? representativeName;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ModernAssociationCard({
    super.key,
    required this.association,
    this.representativeName,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = association.isActive;

    // اختيار لون ديناميكي بناءً على اسم الجمعية
    final primaryColor = _getAssociationColor(association.name);
    final statusColor = isActive ? Colors.green : Colors.orange;

    return Semantics(
      label: 'جمعية ${association.name}, ${isActive ? 'نشطة' : 'معطلة'}',
      button: true,
      child: Card(
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                primaryColor.withOpacity(0.03),
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - الأيقونة والاسم والحالة
                  Row(
                    children: [
                      // أيقونة مع gradient
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getAssociationIcon(association.name),
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      // الاسم والاسم المختصر
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              association.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (association.shortName != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                association.shortName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // شارة الحالة
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              isActive ? 'نشط' : 'معطل',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveUtils.smallSpace),

                  // معلومات الاتصال - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 320;

                      if (isNarrow || association.email == null) {
                        // عمودي: ضيق أو بدون بريد
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ModernInfoBox(
                              icon: Icons.phone_outlined,
                              label: 'الهاتف',
                              value: association.phone,
                              color: Colors.blue,
                            ),
                            if (association.email != null) ...[
                              SizedBox(height: ResponsiveUtils.smallSpace),
                              _ModernInfoBox(
                                icon: Icons.email_outlined,
                                label: 'البريد',
                                value: association.email!,
                                color: Colors.purple,
                              ),
                            ],
                          ],
                        );
                      }

                      // أفقي: عادي
                      return Row(
                        children: [
                          Expanded(
                            child: _ModernInfoBox(
                              icon: Icons.phone_outlined,
                              label: 'الهاتف',
                              value: association.phone,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.smallSpace),
                          Expanded(
                            child: _ModernInfoBox(
                              icon: Icons.email_outlined,
                              label: 'البريد',
                              value: association.email!,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: ResponsiveUtils.xSmallSpace),

                  // معلومات البنك - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 320;

                      if (isNarrow) {
                        // عمودي
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ModernInfoBox(
                              icon: Icons.account_balance_outlined,
                              label: association.bankName,
                              value: association.accountNumber,
                              color: Colors.teal,
                            ),
                            SizedBox(height: ResponsiveUtils.smallSpace),
                            _ModernInfoBox(
                              icon: Icons.monetization_on_outlined,
                              label: 'العملة',
                              value: association.accountCurrency ?? 'غير محددة',
                              color: Colors.amber,
                            ),
                          ],
                        );
                      }

                      // أفقي
                      return Row(
                        children: [
                          Expanded(
                            child: _ModernInfoBox(
                              icon: Icons.account_balance_outlined,
                              label: association.bankName,
                              value: association.accountNumber,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.smallSpace),
                          Expanded(
                            child: _ModernInfoBox(
                              icon: Icons.monetization_on_outlined,
                              label: 'العملة',
                              value: association.accountCurrency ?? 'غير محددة',
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  if (representativeName != null) ...[
                    SizedBox(height: ResponsiveUtils.xSmallSpace),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18.sp,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'المندوب: $representativeName',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: ResponsiveUtils.smallSpace),

                  // أزرار الإجراءات - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 300;

                      if (isNarrow) {
                        // موبايل ضيق: أزرار عمودية
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: Icon(Icons.edit_outlined, size: ResponsiveUtils.getIconSize(context) * 0.7),
                              label: const Text('تعديل'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace * 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                                ),
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.smallSpace),
                            OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: Icon(Icons.delete_outline, size: ResponsiveUtils.getIconSize(context) * 0.7),
                              label: const Text('حذف'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // عادي: أزرار جنب بعض
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: Icon(Icons.edit_outlined, size: ResponsiveUtils.getIconSize(context) * 0.7),
                              label: const Text('تعديل'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.smallSpace),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: Icon(Icons.delete_outline, size: ResponsiveUtils.getIconSize(context) * 0.7),
                              label: const Text('حذف'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// اختيار لون ديناميكي بناءً على اسم الجمعية
  Color _getAssociationColor(String name) {
    final hash = name.hashCode.abs();
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.deepOrange,
    ];
    return colors[hash % colors.length];
  }

  /// اختيار أيقونة ديناميكية
  IconData _getAssociationIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('خيرية')) return Icons.volunteer_activism_rounded;
    if (lowerName.contains('صحة')) return Icons.local_hospital_rounded;
    if (lowerName.contains('تعليم')) return Icons.school_rounded;
    if (lowerName.contains('بنك')) return Icons.account_balance_rounded;
    return Icons.business_rounded;
  }
}

/// صندوق معلومات حديث
class _ModernInfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ModernInfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
