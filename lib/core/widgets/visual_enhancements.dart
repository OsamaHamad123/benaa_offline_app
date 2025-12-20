import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 Visual Enhancements - Subtle UI Improvements
///
/// مجموعة من التحسينات البصرية الدقيقة لتحسين UX

/// ✨ Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 💫 Fade In Animation
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// 🎯 Ripple Card - Card with ripple effect
class RippleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const RippleCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);

    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: effectiveBorderRadius,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

///  Gradient Background
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ??
        [
          Theme.of(context).primaryColor.withOpacity(0.8),
          Theme.of(context).primaryColor,
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveColors,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}

/// ✅ Success Checkmark Animation
class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;

  const SuccessCheckmark({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.green;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circle background
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
            ),
            // Checkmark
            FadeTransition(
              opacity: _checkAnimation,
              child: Icon(
                Icons.check,
                color: color,
                size: widget.size * 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📊 Progress Bar with Animation
class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(4.r);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: effectiveBorderRadius,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
