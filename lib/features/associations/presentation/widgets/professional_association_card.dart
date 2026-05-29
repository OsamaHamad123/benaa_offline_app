import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🏢 بطاقة جمعية compact — تصميم كثيف وسهل القراءة
///
/// - بدون gradient header (توفير مساحة رأسية)
/// - PopupMenuButton بدل أزرار ظاهرة
/// - auto-height: يتمدد حسب المحتوى الفعلي فقط
/// - RTL-safe مع ellipsis لكل النصوص الطويلة
/// - يعرض: اسم + حالة + هاتف + إيميل + بنك + عملة + مندوب + نوع
class ProfessionalAssociationCard extends StatelessWidget {
  final String id;
  final String name;
  final String? shortName;
  final String phone;
  final String? email;
  final String bankName;
  final String? accountNumber;
  final String? currency;
  final String? associationTypeLabel;
  final String? representativeName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfessionalAssociationCard({
    required this.id,
    required this.name,
    required this.phone,
    required this.bankName,
    required this.isActive,
    super.key,
    this.shortName,
    this.email,
    this.accountNumber,
    this.currency,
    this.representativeName,
    this.associationTypeLabel,
    this.createdAt,
    this.updatedAt,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _accentColor(name);

    final displayName = (shortName?.isNotEmpty == true) ? shortName! : name;

    final statusBg = isActive ? Colors.green.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.12);
    final statusFg = isActive ? Colors.green.shade700 : Colors.orange.shade700;

    final infoStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      color: cs.onSurface.withValues(alpha: isDark ? 0.75 : 0.70),
      height: 1.3,
    );

    final hasSecondary =
        representativeName != null || (associationTypeLabel != null && associationTypeLabel!.trim().isNotEmpty);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      elevation: isDark ? 0 : 1,
      shadowColor: accentColor.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: isDark ? BorderSide(color: cs.outline.withValues(alpha: 0.18)) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 4.w, 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── صف 1: أيقونة + اسم + حالة + قائمة ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: Icon(Icons.account_balance, size: 15.sp, color: accentColor),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // badge الحالة
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      isActive ? 'نشط' : 'معطل',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ),
                  // قائمة الأفعال
                  SizedBox(
                    width: 28.w,
                    height: 28.h,
                    child: PopupMenuButton<_AssocCardAction>(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 18.sp),
                      tooltip: 'الخيارات',
                      onSelected: (_AssocCardAction action) {
                        switch (action) {
                          case _AssocCardAction.details:
                            onTap?.call();
                          case _AssocCardAction.edit:
                            onEdit?.call();
                          case _AssocCardAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: _AssocCardAction.details,
                          child: Row(children: [
                            Icon(Icons.info_outline, size: 16.sp, color: cs.primary),
                            SizedBox(width: 8.w),
                            const Text('التفاصيل'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: _AssocCardAction.edit,
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 16.sp, color: cs.primary),
                            SizedBox(width: 8.w),
                            const Text('تعديل'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: _AssocCardAction.delete,
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 16.sp, color: cs.error),
                            SizedBox(width: 8.w),
                            Text('حذف', style: TextStyle(color: cs.error)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // ── صف 2: هاتف + إيميل (اختياري) ──
              Row(
                children: [
                  Icon(Icons.phone, size: 12.sp, color: cs.primary.withValues(alpha: 0.65)),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(phone, style: infoStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (email != null && email!.trim().isNotEmpty) ...[
                    SizedBox(width: 12.w),
                    Icon(Icons.email_outlined, size: 12.sp, color: Colors.indigo.withValues(alpha: 0.65)),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(email!, style: infoStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 4.h),

              // ── صف 3: البنك + العملة ──
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 12.sp, color: Colors.teal.withValues(alpha: 0.75)),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(bankName, style: infoStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (currency != null && currency!.trim().isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        currency!,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ── صف 4: المندوب + نوع الجمعية (اختياري) ──
              if (hasSecondary) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (representativeName != null) ...[
                      Icon(Icons.person_outline, size: 12.sp, color: Colors.deepOrange.withValues(alpha: 0.7)),
                      SizedBox(width: 4.w),
                      Flexible(
                        child:
                            Text(representativeName!, style: infoStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    if (associationTypeLabel != null && associationTypeLabel!.trim().isNotEmpty) ...[
                      if (representativeName != null) SizedBox(width: 10.w),
                      Icon(Icons.category_outlined, size: 12.sp, color: Colors.purple.withValues(alpha: 0.7)),
                      SizedBox(width: 4.w),
                      Flexible(
                        child:
                            Text(associationTypeLabel!, style: infoStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// لون accent ديناميكي بناءً على اسم الجمعية
  Color _accentColor(String name) {
    const colors = [
      Colors.blue,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.green,
      Colors.deepPurple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

enum _AssocCardAction { details, edit, delete }
