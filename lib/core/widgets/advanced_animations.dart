import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎨 Advanced List Animations - رسوم متحركة متقدمة للقوائم

/// ✨ Staggered Grid Animation
class StaggeredGridAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final int columnCount;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const StaggeredGridAnimation({
    required this.child, required this.index, super.key,
    this.columnCount = 2,
    this.duration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final row = index ~/ columnCount;
    final column = index % columnCount;

    // تأخير بناءً على الصف والعمود
    final delayMs = (row * 100) + (column * 50);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: delayMs),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

/// 🌊 Wave Animation للقوائم
class WaveListAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const WaveListAnimation({
    required this.child, required this.index, super.key,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<WaveListAnimation> createState() => _WaveListAnimationState();
}

class _WaveListAnimationState extends State<WaveListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final delay = widget.index * 0.1;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.clamp(0.0, 1.0),
        (delay + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-100 * (1 - _animation.value), 0),
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// 🔄 Rotation + Scale Animation
class RotateScaleAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final int maxItems;

  const RotateScaleAnimation({
    required this.child, required this.index, super.key,
    this.duration = const Duration(milliseconds: 600),
    this.maxItems = 20,
  });

  @override
  State<RotateScaleAnimation> createState() => _RotateScaleAnimationState();
}

class _RotateScaleAnimationState extends State<RotateScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final delay = (widget.index / widget.maxItems).clamp(0.0, 0.8);

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay,
        (delay + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay,
        (delay + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: (1 - _rotationAnimation.value) * math.pi / 4,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 🎭 Flip Animation
class FlipAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const FlipAnimation({
    required this.child, required this.index, super.key,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final delay = widget.index * 0.08;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.clamp(0.0, 0.7),
        (delay + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = (1 - _animation.value) * math.pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// 💫 Shimmer Loading Animation
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    required this.child, super.key,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
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
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
              colors: [baseColor, highlightColor, baseColor],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 🎯 Hero Animation Helper
class HeroAnimationWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const HeroAnimationWrapper({
    required this.tag, required this.child, super.key,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        return ScaleTransition(
          scale: animation.drive(
            Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
