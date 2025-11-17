import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⏳ Loading Overlay Widget
///
/// Shows loading indicator with message
class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(message, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
