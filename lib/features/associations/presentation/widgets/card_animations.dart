import 'package:flutter/material.dart';

/// 🎬 Card Animations - دخول تدريجي للبطاقات
class CardAnimationWrapper extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const CardAnimationWrapper({
    required this.child, required this.index, super.key,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * delay.inMilliseconds)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 🎭 Update Animation - عند تحديث البطاقة
class UpdateAnimationWrapper extends StatefulWidget {
  final Widget child;
  final String itemId;

  const UpdateAnimationWrapper({
    required this.child, required this.itemId, super.key,
  });

  @override
  State<UpdateAnimationWrapper> createState() => _UpdateAnimationWrapperState();
}

class _UpdateAnimationWrapperState extends State<UpdateAnimationWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String? _lastId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _lastId = widget.itemId;
  }

  @override
  void didUpdateWidget(UpdateAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغير الـ ID، نفذ الأنيميشن
    if (widget.itemId != _lastId) {
      _lastId = widget.itemId;
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
