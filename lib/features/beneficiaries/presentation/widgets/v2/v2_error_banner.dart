import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Error banner with dismiss action
class V2ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const V2ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color.fromRGBO(
            colorScheme.error.red,
            colorScheme.error.green,
            colorScheme.error.blue,
            0.3,
          ),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              tooltip: 'إعادة المحاولة',
              color: colorScheme.error,
              style: IconButton.styleFrom(minimumSize: Size(36.w, 36.h)),
            ),
          ],
          if (onDismiss != null) ...[
            SizedBox(width: 4.w),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close_rounded, size: 20.sp),
              tooltip: 'إغلاق',
              color: colorScheme.error,
              style: IconButton.styleFrom(minimumSize: Size(36.w, 36.h)),
            ),
          ],
        ],
      ),
    );
  }
}
