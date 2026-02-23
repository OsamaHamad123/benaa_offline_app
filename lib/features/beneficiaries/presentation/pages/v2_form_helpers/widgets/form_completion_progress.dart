import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📋 Form Completion Progress Widget
class FormCompletionProgress extends StatelessWidget {
  final int totalFields;
  final int filledFields;
  final List<String> requiredFieldsEmpty;

  const FormCompletionProgress({
    required this.totalFields, required this.filledFields, super.key,
    this.requiredFieldsEmpty = const [],
  });

  double get completionPercentage =>
      totalFields > 0 ? (filledFields / totalFields) * 100 : 0;

  Color _getProgressColor() {
    if (completionPercentage < 30) return Colors.red;
    if (completionPercentage < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor();

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: progressColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 20.sp,
                    color: progressColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'تقدم إكمال النموذج',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${completionPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8.h,
            ),
          ),

          SizedBox(height: 8.h),

          // Field Count
          Text(
            '$filledFields من $totalFields حقل مكتمل',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // Required Fields Empty
          if (requiredFieldsEmpty.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, size: 16.sp, color: Colors.red),
                      SizedBox(width: 6.w),
                      Text(
                        'حقول مطلوبة فارغة:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ...requiredFieldsEmpty.take(3).map((field) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h, right: 22.w),
                      child: Text(
                        '• $field',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    );
                  }),
                  if (requiredFieldsEmpty.length > 3)
                    Padding(
                      padding: EdgeInsets.only(right: 22.w),
                      child: Text(
                        'و ${requiredFieldsEmpty.length - 3} حقول أخرى...',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.red.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 📊 Field Statistics
class FormFieldStatistics {
  final int totalFields;
  final int filledFields;
  final int requiredFields;
  final int filledRequiredFields;
  final List<String> emptyRequiredFields;

  FormFieldStatistics({
    required this.totalFields,
    required this.filledFields,
    required this.requiredFields,
    required this.filledRequiredFields,
    this.emptyRequiredFields = const [],
  });

  double get completionRate =>
      totalFields > 0 ? (filledFields / totalFields) * 100 : 0;

  double get requiredFieldsRate =>
      requiredFields > 0 ? (filledRequiredFields / requiredFields) * 100 : 0;

  bool get isComplete => emptyRequiredFields.isEmpty;
}
