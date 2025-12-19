import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.colorScheme.surface,
                  primaryColor.withOpacity(0.02),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header مدمج
                  Row(
                    children: [
                      // أيقونة صغيرة
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          _getAssociationIcon(association.name),
                          color: primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // الاسم
                      Expanded(
                        child: Text(
                          association.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // نقطة الحالة
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.4),
                              blurRadius: 3,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // معلومات في صفين
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14.sp, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          association.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  Row(
                    children: [
                      Icon(Icons.account_balance, size: 14.sp, color: Colors.teal),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${association.bankName} • ${association.accountNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (representativeName != null) ...[
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14.sp, color: Colors.deepPurple),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            representativeName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 8.h),

                  Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withOpacity(0.3)),

                  SizedBox(height: 6.h),

                  // أزرار صغيرة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MiniActionButton(
                        icon: Icons.edit,
                        label: 'تعديل',
                        color: theme.colorScheme.primary,
                        onPressed: onEdit,
                      ),
                      Container(
                        width: 1,
                        height: 20.h,
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                      _MiniActionButton(
                        icon: Icons.delete_outline,
                        label: 'حذف',
                        color: theme.colorScheme.error,
                        onPressed: onDelete,
                      ),
                    ],
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

/// زر إجراء صغير
class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
