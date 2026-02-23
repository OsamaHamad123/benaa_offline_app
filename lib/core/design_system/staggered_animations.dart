import 'package:flutter/material.dart';
import 'app_animations.dart';

/// Staggered Animation Group - يطبق تأخير بسيط بين animations لتحسين الأداء والمظهر
class StaggeredAnimationGroup extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration animationDuration;
  final Offset slideOffset;

  const StaggeredAnimationGroup({
    required this.children, super.key,
    this.delay = const Duration(milliseconds: 50),
    this.animationDuration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        children.length,
        (index) {
          // ✅ Stagger Animations: تأخير تدريجي لكل عنصر
          final itemDelay = delay * index;

          return FadeSlideTransition(
            duration: animationDuration,
            delay: itemDelay,
            slideOffset: slideOffset,
            child: children[index],
          );
        },
      ),
    );
  }
}

/// Staggered List Animation - للقوائم مع تأخير تدريجي
class StaggeredListAnimation extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration delay;
  final Duration animationDuration;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const StaggeredListAnimation({
    required this.itemCount, required this.itemBuilder, super.key,
    this.delay = const Duration(milliseconds: 50),
    this.animationDuration = const Duration(milliseconds: 400),
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final itemDelay = delay * index;

        return FadeSlideTransition(
          duration: animationDuration,
          delay: itemDelay,
          slideOffset: const Offset(0, 0.1),
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
