import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// 🎨 رأس البطاقة مع gradient جذاب
class CardGradientHeader extends StatelessWidget {
  final String name;
  final String? shortName;
  final bool isActive;

  const CardGradientHeader({
    super.key,
    required this.name,
    this.shortName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? isDark
                  ? [
                      primaryColor.withOpacity(0.7),
                      primaryColor.withOpacity(0.5),
                    ]
                  : [
                      primaryColor.withOpacity(0.85),
                      primaryColor.withOpacity(0.65),
                    ]
              : isDark
                  ? [
                      Colors.grey.shade700,
                      Colors.grey.shade600,
                    ]
                  : [
                      Colors.grey.shade400,
                      Colors.grey.shade300,
                    ],
        ),
      ),
      child: Row(
        children: [
          // أيقونة الجمعية
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.account_balance,
              size: 20.sp,
              color: Colors.white,
            ),
          ),

          SizedBox(width: 10.w),

          // اسم الجمعية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (shortName != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    shortName!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isActive ? 'نشط' : 'معطل',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
