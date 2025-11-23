import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui'; // For blur effect
import 'smooth_animations.dart'; // For ShimmerLoading

/// ⏳ Loading Overlay Widget - Enhanced with blur & shimmer
///
/// Shows loading indicator with message, blur background, and smooth animations
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

    return SlideAndFade(
      show: isVisible,
      duration: const Duration(milliseconds: 300),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2), // 0.8 -> 1.0
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shimmer Circle with Progress Indicator
                      ShimmerLoading(
                        isLoading: true,
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      // Animated dots
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: 3),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, dots, child) {
                          return Text(
                            '.' * (dots % 4),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
