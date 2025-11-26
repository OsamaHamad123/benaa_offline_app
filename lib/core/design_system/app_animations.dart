/// 🎬 نظام الحركات والانتقالات المتقدم
/// Advanced Animation System with performance optimization
library;

import 'package:flutter/material.dart';

/// ⚡ **Durations - مدد الحركات**
class AppDurations {
  AppDurations._();

  // Fast animations for micro-interactions
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration dialogTransition = Duration(milliseconds: 250);
  static const Duration bottomSheetTransition = Duration(milliseconds: 300);

  // Loading states
  static const Duration shimmer = Duration(milliseconds: 1200);
  static const Duration skeleton = Duration(milliseconds: 800);
}

/// 🎨 **Curves - منحنيات الحركة**
class AppCurves {
  AppCurves._();

  // Material Design curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;

  // Custom curves for better UX
  static const Curve bounce = Curves.easeOutBack;
  static const Curve elastic = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutQuart;

  // Page transitions
  static const Curve pageEnter = Curves.easeOutCubic;
  static const Curve pageExit = Curves.easeInCubic;
}

/// 📐 **Scale Transitions**
class ScaleTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool reverse;

  const ScaleTransitionWidget({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.smooth,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reverse ? 1.0 : 0.0, end: reverse ? 0.0 : 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }
}

/// 💫 **Fade Transition**
class FadeTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool reverse;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reverse ? 1.0 : 0.0, end: reverse ? 0.0 : 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// ↔️ **Slide Transition**
class SlideTransitionWidget extends StatelessWidget {
  final Widget child;
  final Offset begin;
  final Offset end;
  final Duration duration;
  final Curve curve;

  const SlideTransitionWidget({
    super.key,
    required this.child,
    this.begin = const Offset(0, 1),
    this.end = Offset.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.standard,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FractionalTranslation(translation: value, child: child);
      },
      child: child,
    );
  }
}

/// ✨ **Combined Fade & Slide**
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset slideOffset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.slideOffset = const Offset(0, 0.3),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AppCurves.smooth,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              slideOffset.dx * (1 - value),
              slideOffset.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 🔄 **Shimmer Loading Effect**
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = AppDurations.shimmer,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 📄 **Page Route Transitions**
class AppPageRoute {
  AppPageRoute._();

  /// Fade transition
  static PageRoute<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: AppDurations.pageTransition,
    );
  }

  /// Slide from bottom
  static PageRoute<T> slideBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
              ),
          child: child,
        );
      },
      transitionDuration: AppDurations.pageTransition,
    );
  }

  /// Slide from right (default Material)
  static PageRoute<T> slideRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
              ),
          child: child,
        );
      },
      transitionDuration: AppDurations.pageTransition,
    );
  }

  /// Scale transition
  static PageRoute<T> scale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: AppCurves.smooth),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: AppDurations.pageTransition,
    );
  }
}

/// 🎯 **Micro-interactions - تفاعلات صغيرة**
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale =
            widget.minScale +
            (widget.maxScale - widget.minScale) * _controller.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// 🎨 **Ripple Effect for Cards**
class RippleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? splashColor;
  final BorderRadius? borderRadius;

  const RippleCard({
    super.key,
    required this.child,
    this.onTap,
    this.splashColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor:
            splashColor ?? Theme.of(context).primaryColor.withAlpha(51),
        highlightColor:
            splashColor ?? Theme.of(context).primaryColor.withAlpha(26),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}
