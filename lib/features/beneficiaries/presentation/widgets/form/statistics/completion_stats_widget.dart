import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 ويدجت إحصائيات الإكمال
///
/// يعرض:
/// - نسبة الإكمال الكلية
/// - عدد الحقول المكتملة/الإجمالية
/// - تفصيل لكل تبويب
class CompletionStatsWidget extends StatelessWidget {
  final double overallCompletion;
  final int completedFields;
  final int totalFields;
  final Map<String, double> tabCompletions;
  final VoidCallback onTap;

  const CompletionStatsWidget({
    required this.overallCompletion, required this.completedFields, required this.totalFields, required this.tabCompletions, required this.onTap, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إحصائيات الإكمال',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 20.sp),
              ],
            ),

            SizedBox(height: 16.h),

            // النسبة الكلية
            Row(
              children: [
                // دائرة التقدم
                SizedBox(
                  width: 60.w,
                  height: 60.h,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: overallCompletion / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCompletionColor(overallCompletion),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${overallCompletion.toInt()}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // التفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إكمال النموذج',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$completedFields من $totalFields حقل مكتمل',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (tabCompletions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 8.h),

              // تفصيل التبويبات
              ...tabCompletions.entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 100.w,
                        child: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCompletionColor(entry.value),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          '${entry.value.toInt()}%',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 100) return Colors.green;
    if (percentage >= 75) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 25) return Colors.deepOrange;
    return Colors.red;
  }
}
