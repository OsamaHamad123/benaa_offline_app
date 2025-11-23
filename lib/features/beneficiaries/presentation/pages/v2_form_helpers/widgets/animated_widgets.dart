import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 🎨 Animated Counter Widget
///
/// Displays animated number counting
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? suffix;
  final String? prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.suffix,
    this.prefix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation =
          Tween<double>(
            begin: _previousValue.toDouble(),
            end: widget.value.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.reset();
      _controller.forward();
    }
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
        return Text(
          '${widget.prefix ?? ''}${_animation.value.toInt()}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// 📊 Progress Ring Widget
///
/// Circular progress indicator with percentage
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.child,
  });

  Color _getProgressColor() {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? _getProgressColor();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                backgroundColor ??
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: progress),
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          ),
          // Center content
          if (child != null)
            child!
          else
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: (size * 0.2).sp,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// 🏷️ Status Badge Widget
///
/// Displays status with icon and color
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final BadgeSize size;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;

    double getFontSize() {
      switch (size) {
        case BadgeSize.small:
          return 10.sp;
        case BadgeSize.medium:
          return 12.sp;
        case BadgeSize.large:
          return 14.sp;
      }
    }

    double getIconSize() {
      switch (size) {
        case BadgeSize.small:
          return 12;
        case BadgeSize.medium:
          return 14;
        case BadgeSize.large:
          return 16;
      }
    }

    EdgeInsets getPadding() {
      switch (size) {
        case BadgeSize.small:
          return EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);
        case BadgeSize.medium:
          return EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h);
        case BadgeSize.large:
          return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
      }
    }

    return Container(
      padding: getPadding(),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: getIconSize(), color: badgeColor),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: getFontSize(),
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeSize { small, medium, large }

/// 📌 Action Chip Widget
///
/// Interactive chip with tap action
class ActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? color;
  final bool selected;

  const ActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = selected
        ? (color ?? theme.colorScheme.primary)
        : theme.colorScheme.surfaceContainerHighest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(selected ? 0.2 : 1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected
                  ? chipColor
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? chipColor
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? chipColor
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              if (onDelete != null) ...[
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: selected
                        ? chipColor
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 💡 Tooltip Helper Widget
///
/// Shows helpful tooltips on long press
class TooltipHelper extends StatelessWidget {
  final String message;
  final Widget child;
  final Duration? waitDuration;

  const TooltipHelper({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      waitDuration: waitDuration ?? const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.r),
      ),
      textStyle: TextStyle(fontSize: 12.sp, color: Colors.white),
      child: child,
    );
  }
}

/// 🎯 Expandable Section Widget
///
/// Collapsible section with header
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: ResponsiveUtils.getHorizontalPadding(
        context,
      ).add(EdgeInsets.symmetric(vertical: ResponsiveUtils.xSmallSpace)),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(12.r),
              bottom: _isExpanded ? Radius.zero : Radius.circular(12.r),
            ),
            child: Container(
              padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: ResponsiveUtils.smallSpace),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
