import 'package:flutter/material.dart';

/// 🎬 Page Transitions
///
/// Reusable page transition animations for consistent navigation UX.
/// Provides various transition effects for different navigation patterns.
///
/// Usage with GoRouter:
/// ```dart
/// GoRoute(
///   path: '/details',
///   pageBuilder: (context, state) => PageTransitions.fadeTransition(
///     child: DetailsPage(),
///   ),
/// )
/// ```
class PageTransitions {
  /// Default transition duration
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// ✨ Fade Transition
  ///
  /// Smooth fade in/out effect. Best for modal-like pages.
  static CustomTransitionPage fadeTransition({
    required Widget child,
    Duration duration = defaultDuration,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// 📱 Slide Transition (from right)
  ///
  /// Default iOS-style slide from right. Best for forward navigation.
  static CustomTransitionPage slideTransition({
    required Widget child,
    Duration duration = defaultDuration,
    SlideDirection direction = SlideDirection.right,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = _getSlideOffset(direction);

        return SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  /// 🎯 Scale Transition
  ///
  /// Zoom in/out effect. Best for detail views or modal dialogs.
  static CustomTransitionPage scaleTransition({
    required Widget child,
    Duration duration = defaultDuration,
    double beginScale = 0.8,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: beginScale,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 🌀 Rotation + Fade Transition
  ///
  /// Subtle rotation with fade. Best for playful interactions.
  static CustomTransitionPage rotationTransition({
    required Widget child,
    Duration duration = defaultDuration,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// 📲 Bottom Sheet Transition
  ///
  /// Slide up from bottom. Best for bottom sheets and modals.
  static CustomTransitionPage bottomSheetTransition({
    required Widget child,
    Duration duration = defaultDuration,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
    );
  }

  /// 🎨 Material Shared Axis Transition
  ///
  /// Material Design shared axis transition. Best for related content.
  static CustomTransitionPage sharedAxisTransition({
    required Widget child,
    Duration duration = defaultDuration,
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = direction == SharedAxisDirection.horizontal
            ? const Offset(0.3, 0)
            : const Offset(0, 0.3);

        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: offset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
    );
  }

  /// ⚡ No Transition
  ///
  /// Instant navigation without animation. Best for tab switches.
  static CustomTransitionPage noTransition({
    required Widget child,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// 🎭 Custom Transition
  ///
  /// Build your own custom transition.
  static CustomTransitionPage customTransition({
    required Widget child,
    required RouteTransitionsBuilder transitionsBuilder,
    Duration duration = defaultDuration,
    LocalKey? key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: transitionsBuilder,
    );
  }

  /// Helper: Get slide offset based on direction
  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-1, 0);
      case SlideDirection.right:
        return const Offset(1, 0);
      case SlideDirection.top:
        return const Offset(0, -1);
      case SlideDirection.bottom:
        return const Offset(0, 1);
    }
  }
}

/// 📐 Slide Direction
enum SlideDirection {
  left,
  right,
  top,
  bottom,
}

/// 🎨 Shared Axis Direction
enum SharedAxisDirection {
  horizontal,
  vertical,
}

/// 🎬 Custom Transition Page
///
/// Wrapper for GoRouter custom transitions.
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Duration transitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = PageTransitions.defaultDuration,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
    );
  }
}
