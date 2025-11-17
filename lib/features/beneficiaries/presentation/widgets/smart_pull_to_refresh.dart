import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/list/beneficiaries_list_provider.dart';

/// 🔄 Smart Pull to Refresh Widget
///
/// Enhanced pull-to-refresh with:
/// - Custom animations
/// - Loading progress
/// - Success/error feedback
class SmartPullToRefresh extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onRefresh;

  const SmartPullToRefresh({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        } else {
          await ref.read(beneficiariesListProvider.notifier).refresh();
        }
      },
      // 🎨 Enhanced styling
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      strokeWidth: 3.0,
      displacement: 60.0,
      // 🎯 Custom trigger distance
      edgeOffset: 0.0,
      child: child,
    );
  }
}

/// 💫 Animated Success Indicator
class SuccessIndicator extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;

  const SuccessIndicator({super.key, required this.message, this.onDismiss});

  @override
  State<SuccessIndicator> createState() => _SuccessIndicatorState();
}

class _SuccessIndicatorState extends State<SuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
