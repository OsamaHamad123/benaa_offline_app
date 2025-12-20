import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_colors.dart';

/// Dashboard Text Styles - أنماط نصوص موحدة للداشبورد
class DashboardTextStyles {
  // Prevent instantiation
  DashboardTextStyles._();

  // Section Title
  static TextStyle sectionTitle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Stat Value (الرقم الكبير)
  static TextStyle statValue = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Stat Label (التسمية)
  static TextStyle statLabel = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Card Title
  static TextStyle cardTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Card Subtitle
  static TextStyle cardSubtitle = TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Badge Text
  static TextStyle badge = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Action Button
  static TextStyle actionButton = TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Empty State Title
  static TextStyle emptyStateTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Empty State Message
  static TextStyle emptyStateMessage = TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Trend Positive
  static TextStyle trendPositive = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  // Trend Negative
  static TextStyle trendNegative = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  // Time Stamp
  static TextStyle timestamp = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
