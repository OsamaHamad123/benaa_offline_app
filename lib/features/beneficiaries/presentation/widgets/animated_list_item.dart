import 'package:flutter/material.dart';

/// 🎬 Animated list item wrapper - Reusable component
///
/// يدعم نوعين من الـ animations:
/// - SlideAnimation: للـ ListView (slide من الأسفل + fade)
/// - ScaleAnimation: للـ GridView (scale من 80% + fade)
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final AnimationType type;
  final int delay;
  final Duration duration;
  final Curve curve;

  const AnimatedListItem({
    required this.child, required this.index, super.key,
    this.type = AnimationType.slide,
    this.delay = 30,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    // حساب التأخير بناءً على الـ index (فقط أول 10 عناصر)
    final animDuration = Duration(
      milliseconds: duration.inMilliseconds + ((index % 10) * delay),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('animated_item_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: animDuration,
      curve: curve,
      builder: (context, value, child) {
        switch (type) {
          case AnimationType.slide:
            // Slide animation للـ ListView
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          case AnimationType.scale:
            // Scale animation للـ GridView
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(opacity: value, child: child),
            );
        }
      },
      child: child,
    );
  }
}

/// أنواع الـ animations المتاحة
enum AnimationType {
  /// Slide من الأسفل + fade (مناسب للـ ListView)
  slide,

  /// Scale من 80% + fade (مناسب للـ GridView)
  scale,
}
