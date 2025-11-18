import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom Pull to Refresh Indicator with enhanced design
class CustomPullToRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;

  const CustomPullToRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Colors.blue,
      backgroundColor: backgroundColor ?? Colors.white,
      displacement: displacement,
      strokeWidth: 3.0,
      child: child,
    );
  }
}

/// Animated Refresh Header
class AnimatedRefreshHeader extends StatefulWidget {
  final bool isRefreshing;
  final String? message;

  const AnimatedRefreshHeader({
    super.key,
    required this.isRefreshing,
    this.message,
  });

  @override
  State<AnimatedRefreshHeader> createState() => _AnimatedRefreshHeaderState();
}

class _AnimatedRefreshHeaderState extends State<AnimatedRefreshHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRefreshing) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: Icon(Icons.refresh, color: Colors.blue, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            widget.message ?? 'جاري التحديث...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
