/// 🎬 نظام الحركات والانتقالات المتقدم
/// Advanced Animation System with performance optimization
library;

import 'package:flutter/material.dart';

/// ⚡ **Durations - مدد الحركات المحسّنة (60fps optimized)**
class AppDurations {
  AppDurations._();

  // ✨ Fine-tuned animations for micro-interactions (16.67ms per frame)
  static const Duration instant = Duration(milliseconds: 150); // Slightly slower for visibility
  static const Duration fast = Duration(milliseconds: 250); // Optimized for 60fps
  static const Duration normal = Duration(milliseconds: 350); // Premium feel
  static const Duration slow = Duration(milliseconds: 450); // Smooth & noticeable
  static const Duration verySlow = Duration(milliseconds: 600); // Cinematic

  // 📱 Page transitions (120Hz display optimized)
  static const Duration pageTransition = Duration(milliseconds: 400); // Buttery smooth
  static const Duration dialogTransition = Duration(milliseconds: 300); // Quick & smooth
  static const Duration bottomSheetTransition = Duration(milliseconds: 350); // Natural feel

  // ⏳ Loading states (optimized for perception)
  static const Duration shimmer = Duration(milliseconds: 1500); // Slower for premium feel
  static const Duration skeleton = Duration(milliseconds: 1000); // Balanced

  // 🎯 Interactive feedback
  static const Duration buttonPress = Duration(milliseconds: 100); // Instant feedback
  static const Duration hover = Duration(milliseconds: 200); // Smooth hover
}

/// 🎨 **Curves - منحنيات الحركة المحسّنة**
class AppCurves {
  AppCurves._();

  // ✨ Enhanced Material Design curves for smoother animations
  static const Curve standard = Curves.easeInOutCubicEmphasized; // أكثر سلاسة
  static const Curve decelerate = Curves.easeOutQuart; // تباطؤ طبيعي
  static const Curve accelerate = Curves.easeInQuart; // تسارع متوازن

  // 🎯 Fine-tuned Custom curves for premium UX
  static const Curve bounce = Curves.easeOutBack; // Gentle bounce
  static const Curve elastic = Curves.elasticOut; // Natural elastic
  static const Curve smooth = Curves.easeInOutQuint; // Ultra smooth (60fps optimized)
  static const Curve butter = Curves.easeInOutExpo; // Buttery smooth

  // 📱 Optimized Page transitions (120Hz ready)
  static const Curve pageEnter = Curves.easeOutCubic; // Smooth entry
  static const Curve pageExit = Curves.easeInCubic; // Quick exit

  // 🎬 Modal & Dialog transitions
  static const Curve modalEnter = Curves.easeOutQuart;
  static const Curve modalExit = Curves.easeInQuart;
}

/// 📐 **Scale Transitions**
class ScaleTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? delay; // ✅ Added for Stagger Animations
  final Curve curve;
  final bool reverse;

  const ScaleTransitionWidget({
    required this.child, super.key,
    this.duration = AppDurations.normal,
    this.delay,
    this.curve = AppCurves.smooth,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Support delayed animations
    if (delay != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 0.0),
        duration: delay!,
        builder: (context, delayValue, child) {
          return delayValue == 0.0 ? _buildAnimation() : const SizedBox.shrink();
        },
      );
    }

    return _buildAnimation();
  }

  Widget _buildAnimation() {
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
    required this.child, super.key,
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
    required this.child, super.key,
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
  final Duration? delay; // ✅ Added for Stagger Animations
  final Offset slideOffset;

  const FadeSlideTransition({
    required this.child, super.key,
    this.duration = AppDurations.normal,
    this.delay,
    this.slideOffset = const Offset(0, 0.3),
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Support delayed animations
    if (delay != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 0.0), // Start invisible
        duration: delay!,
        builder: (context, delayValue, child) {
          return delayValue == 0.0 ? _buildAnimation() : const SizedBox.shrink();
        },
      );
    }

    return _buildAnimation();
  }

  Widget _buildAnimation() {
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
    required this.child, super.key,
    this.duration = AppDurations.shimmer,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
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
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
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
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
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
    required this.child, super.key,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
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
        final scale = widget.minScale + (widget.maxScale - widget.minScale) * _controller.value;
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
    required this.child, super.key,
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
        splashColor: splashColor ?? Theme.of(context).primaryColor.withAlpha(51),
        highlightColor: splashColor ?? Theme.of(context).primaryColor.withAlpha(26),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}
