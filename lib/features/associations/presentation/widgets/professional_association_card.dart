import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card_gradient_header.dart';
import 'card_info_section.dart';
import 'card_action_buttons.dart';
import 'card_status_indicator.dart';

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
  final String? representativeName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfessionalAssociationCard({
    required this.id, required this.name, required this.phone, required this.bankName, required this.currency, required this.isActive, super.key,
    this.shortName,
    this.email,
    this.accountNumber,
    this.representativeName,
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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
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
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                child: CardInfoSection(
                  phone: phone,
                  email: email,
                  bankName: bankName,
                  accountNumber: accountNumber,
                  currency: currency,
                  representativeName: representativeName,
                ),
              ),

              // Status Indicator & Action Buttons
              Padding(
                padding: EdgeInsets.only(
                  left: 14.w,
                  right: 14.w,
                  bottom: 10.h,
                ),
                child: Row(
                  children: [
                    // Status indicator
                    CardStatusIndicator(
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                    ),
                    const Spacer(),
                    // Action buttons
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
