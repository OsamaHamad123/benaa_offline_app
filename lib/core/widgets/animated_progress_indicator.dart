import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated Progress Indicator with smooth transitions
class AnimatedProgressIndicator extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  final String? label;
  final bool showPercentage;
  final Duration duration;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 8.0,
    this.label,
    this.showPercentage = true,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.grey[200]!;
    final valueColor = widget.valueColor ?? Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text(
                      '${(_animation.value * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: LinearProgressIndicator(
                value: _animation.value,
                minHeight: widget.height,
                backgroundColor: bgColor,
                valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Circular Progress with percentage
class AnimatedCircularProgress extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? child;
  final Duration duration;

  const AnimatedCircularProgress({
    super.key,
    required this.value,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.backgroundColor,
    this.valueColor,
    this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.grey[200]!;
    final valueColor = widget.valueColor ?? Colors.blue;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: widget.strokeWidth,
                backgroundColor: bgColor,
                valueColor: AlwaysStoppedAnimation<Color>(valueColor),
              ),
              widget.child ??
                  Text(
                    '${(_animation.value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: (widget.size / 4).sp,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
