import 'package:flutter/material.dart';
import '../utils/haptic_patterns.dart';

/// 🎯 Quick Actions Menu - قائمة إجراءات سريعة
///
/// Features:
/// - Floating speed dial menu
/// - Smooth animations
/// - Haptic feedback
/// - Customizable actions
class QuickActionsMenu extends StatefulWidget {
  final List<QuickAction> actions;
  final IconData mainIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  const QuickActionsMenu({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  State<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends State<QuickActionsMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.75, // 3/4 rotation (270 degrees)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticPatterns.selection();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleActionTap(QuickAction action) {
    HapticPatterns.light();
    _toggle(); // Close menu
    action.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final fgColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action Buttons
        ...List.generate(widget.actions.length, (index) {
          final action = widget.actions[widget.actions.length - 1 - index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildActionButton(action, theme),
                  ),
                ),
              );
            },
          );
        }),

        // Main FAB
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              tooltip: widget.tooltip,
              child: Icon(
                _isExpanded ? Icons.close : widget.mainIcon,
                size: 28,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(QuickAction action, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Label
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              action.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Button
        FloatingActionButton.small(
          onPressed: () => _handleActionTap(action),
          backgroundColor: action.backgroundColor ?? theme.colorScheme.secondary,
          foregroundColor: action.foregroundColor ?? theme.colorScheme.onSecondary,
          heroTag: action.label,
          child: Icon(action.icon, size: 20),
        ),
      ],
    );
  }
}

/// Quick Action Model
class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });
}
