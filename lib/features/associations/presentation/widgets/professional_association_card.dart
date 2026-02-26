import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card_gradient_header.dart';
import 'card_info_section.dart';
import 'card_action_buttons.dart';

/// 🎨 بطاقة احترافية جديدة للجمعيات
///
/// ✨ الميزات:
/// - تصميم gradient حديث وجذاب
/// - أقسام منظمة ومنفصلة (header, info, actions)
/// - shadows ناعمة لعمق بصري
/// - responsive تماماً
/// - dark mode support
/// - انتقالات سلسة
class ProfessionalAssociationCard extends StatelessWidget {
  final String id;
  final String name;
  final String? shortName;
  final String phone;
  final String? email;
  final String bankName;
  final String? accountNumber;
  final String currency;
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
    required this.currency,
    required this.isActive,
    super.key,
    this.shortName,
    this.email,
    this.accountNumber,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.22) : Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header مع gradient
              CardGradientHeader(
                name: name,
                shortName: shortName,
                isActive: isActive,
              ),

              // معلومات الجمعية
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: CardInfoSection(
                  phone: phone,
                  email: email,
                  bankName: bankName,
                  accountNumber: accountNumber,
                  currency: currency,
                  associationTypeLabel: associationTypeLabel,
                  representativeName: representativeName,
                ),
              ),

              // Status Indicator & Action Buttons
              Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  bottom: 8.h,
                ),
                child: Row(
                  children: [
                    // Action buttons
                    const Spacer(),
                    CardActionButtons(
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
