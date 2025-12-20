import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ❌ ويدجت ملخص الأخطاء والتحذيرات
///
/// يعرض:
/// - عدد الأخطاء والتحذيرات
/// - قائمة بالحقول التي تحتوي أخطاء
/// - زر للانتقال إلى الخطأ الأول
class ValidationSummaryWidget extends StatelessWidget {
  final Map<String, List<String>> validationErrors;
  final VoidCallback? onFixFirstError;
  final VoidCallback onDismiss;

  const ValidationSummaryWidget({
    super.key,
    required this.validationErrors,
    this.onFixFirstError,
    required this.onDismiss,
  });

  int get totalErrors => validationErrors.values.expand((errors) => errors).length;

  @override
  Widget build(BuildContext context) {
    if (validationErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الرأس
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[900],
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'يوجد $totalErrors خطأ في النموذج',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      Text(
                        'يرجى تصحيح الأخطاء قبل الحفظ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  color: Colors.red[900],
                  iconSize: 20.sp,
                ),
              ],
            ),
          ),

          // قائمة الأخطاء
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(12.w),
              children: validationErrors.entries.map((entry) {
                return _buildErrorItem(entry.key, entry.value);
              }).toList(),
            ),
          ),

          // زر الإصلاح
          if (onFixFirstError != null)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.red[200]!),
                ),
              ),
              child: FilledButton.icon(
                onPressed: onFixFirstError,
                icon: const Icon(Icons.build),
                label: const Text('إصلاح الخطأ الأول'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorItem(String fieldName, List<String> errors) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[700],
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  fieldName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...errors.map((error) => Padding(
                  padding: EdgeInsets.only(right: 26.w, top: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[700],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
