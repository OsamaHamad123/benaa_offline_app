import 'package:flutter/material.dart';

/// Custom Page Transitions for Enhanced UX
class PageTransitions {
  /// Slide transition from right
  static Route<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition with scale
  static Route<T> fadeScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var fadeAnimation = CurvedAnimation(parent: animation, curve: curve);

        var scaleAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide from bottom (for modals)
  static Route<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Rotation with fade (creative transition)
  static Route<T> rotationFade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var rotationAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        var fadeAnimation = CurvedAnimation(parent: animation, curve: curve);

        return FadeTransition(
          opacity: fadeAnimation,
          child: RotationTransition(
            turns: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(rotationAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Shared axis transition (Material Design 3)
  static Route<T> sharedAxis<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: curve),
          ),
        );

        var slideAnimation = Tween<Offset>(
          begin: const Offset(0.05, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(
          opacity: fadeInAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Hero-like expansion transition
  static Route<T> expansion<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var scaleAnimation = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        var fadeAnimation = CurvedAnimation(parent: animation, curve: curve);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

/// Extension for easy navigation with custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with slide from right transition
  Future<T?> slideToPage<T>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.slideFromRight(page));
  }

  /// Navigate with fade scale transition
  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.fadeScale(page));
  }

  /// Navigate with slide from bottom transition
  Future<T?> modalToPage<T>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.slideFromBottom(page));
  }

  /// Navigate with shared axis transition
  Future<T?> sharedAxisToPage<T>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.sharedAxis(page));
  }

  /// Navigate with expansion transition
  Future<T?> expandToPage<T>(Widget page) {
    return Navigator.of(this).push<T>(PageTransitions.expansion(page));
  }
}
