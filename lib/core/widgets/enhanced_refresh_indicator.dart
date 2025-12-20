import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

/// 🔄 Enhanced Refresh Indicator - مؤشر تحديث محسّن مع رسوم متحركة
class EnhancedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: 3.0,
      // Custom refresh indicator builder
      child: child,
    );
  }
}

/// 🎨 Custom Pull to Refresh Widget مع تأثيرات مخصصة
class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;

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

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    final secondaryColor =
        widget.secondaryColor ?? primaryColor.withOpacity(0.5);

    return RefreshIndicator.adaptive(
      onRefresh: _handleRefresh,
      color: primaryColor,
      backgroundColor: secondaryColor.withOpacity(0.1),
      displacement: 60,
      strokeWidth: 3.0,
      child: widget.child,
    );
  }
}

/// 📊 Loading Indicator مخصص مع نص
class LoadingIndicatorWithText extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const LoadingIndicatorWithText({
    super.key,
    this.text = 'جاري التحميل...',
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.w,
          height: size.h,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 🎯 Pull to Refresh Header مخصص
class CustomRefreshHeader extends StatelessWidget {
  final double pullDistance;
  final double refreshTriggerDistance;
  final bool isRefreshing;

  const CustomRefreshHeader({
    super.key,
    required this.pullDistance,
    required this.refreshTriggerDistance,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (pullDistance / refreshTriggerDistance).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: progress,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRefreshing)
              SizedBox(
                width: 32.w,
                height: 32.h,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Transform.rotate(
                angle: progress * math.pi,
                child: Icon(
                  Icons.refresh,
                  size: 32.sp,
                  color: theme.colorScheme.primary.withOpacity(progress),
                ),
              ),
            SizedBox(height: 8.h),
            Text(
              isRefreshing
                  ? 'جاري التحديث...'
                  : progress >= 1.0
                      ? 'اترك للتحديث'
                      : 'اسحب للتحديث',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
