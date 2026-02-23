import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📋 قسم معلومات الجمعية في البطاقة
class CardInfoSection extends StatelessWidget {
  final String phone;
  final String? email;
  final String bankName;
  final String? accountNumber;
  final String currency;
  final String? representativeName;

  const CardInfoSection({
    required this.phone, required this.bankName, required this.currency, super.key,
    this.email,
    this.accountNumber,
    this.representativeName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // رقم الهاتف
        _InfoRow(
          icon: Icons.phone,
          iconColor: Colors.blue,
          text: phone,
        ),

        SizedBox(height: 6.h),

        // البنك والعملة
        Row(
          children: [
            Expanded(
              child: _InfoRow(
                icon: Icons.account_balance,
                iconColor: Colors.green,
                text: bankName,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                currency,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        // المندوب (إذا موجود)
        if (representativeName != null) ...[
          SizedBox(height: 6.h),
          _InfoRow(
            icon: Icons.person,
            iconColor: Colors.orange,
            text: representativeName!,
            fontSize: 11.sp,
          ),
        ],
      ],
    );
  }
}

/// سطر معلومات واحد
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final double? fontSize;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: iconColor,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
