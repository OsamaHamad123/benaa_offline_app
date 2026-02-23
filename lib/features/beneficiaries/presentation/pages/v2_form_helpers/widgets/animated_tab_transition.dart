import 'package:flutter/material.dart';

/// 🎬 Animated Tab Transition Widget
///
/// Provides smooth animations when switching between tabs
/// Supports fade, slide, and scale transitions
class AnimatedTabTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final TransitionType type;

  const AnimatedTabTransition({
    required this.child, required this.animation, super.key,
    this.type = TransitionType.fadeSlide,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: animation, child: child);

      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
              .animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );

      case TransitionType.fadeSlide:
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
    }
  }
}

/// Transition animation types
enum TransitionType {
  /// Simple fade in/out
  fade,

  /// Horizontal slide
  slide,

  /// Combined fade + slide (default)
  fadeSlide,

  /// Scale animation
  scale,
}

/// 📱 Responsive Tab View with Animations
///
/// Wraps TabBarView with animated transitions and better performance
class AnimatedResponsiveTabView extends StatelessWidget {
  final TabController controller;
  final List<Widget> children;
  final TransitionType transitionType;
  final Duration transitionDuration;

  const AnimatedResponsiveTabView({
    required this.controller, required this.children, super.key,
    this.transitionType = TransitionType.fadeSlide,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      children: children.map((child) {
        return AnimatedBuilder(
          animation: controller.animation!,
          builder: (context, _) {
            // Calculate opacity based on tab position
            final currentPage = controller.animation!.value;
            final tabIndex = children.indexOf(child);
            final delta = (currentPage - tabIndex).abs();
            final opacity = (1 - delta).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity.clamp(0.0, 1.0), // Double clamp for safety
              child: Transform.translate(
                offset: Offset(delta * 20, 0), // Subtle slide effect
                child: child,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
