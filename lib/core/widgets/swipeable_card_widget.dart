import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 👆 Swipeable Card Widget - بطاقة قابلة للسحب
///
/// Features:
/// - Swipe right: Primary action (edit/view)
/// - Swipe left: Danger action (delete/archive)
/// - Smooth animations with haptic feedback
/// - Customizable actions and colors
class SwipeableCardWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final String? leftActionLabel;
  final String? rightActionLabel;
  final IconData? leftActionIcon;
  final IconData? rightActionIcon;
  final Color leftActionColor;
  final Color rightActionColor;
  final double swipeThreshold;
  final bool enabled;

  const SwipeableCardWidget({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionLabel = 'حذف',
    this.rightActionLabel = 'تعديل',
    this.leftActionIcon = Icons.delete,
    this.rightActionIcon = Icons.edit,
    this.leftActionColor = Colors.red,
    this.rightActionColor = Colors.blue,
    this.swipeThreshold = 0.4,
    this.enabled = true,
  });

  @override
  State<SwipeableCardWidget> createState() => _SwipeableCardWidgetState();
}

class _SwipeableCardWidgetState extends State<SwipeableCardWidget>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  bool _hasTriggeredHaptic = false;

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _hasTriggeredHaptic = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _dragExtent = _dragExtent.clamp(-200.0, 200.0);
    });

    // Haptic feedback عند الوصول للـ threshold
    final threshold = MediaQuery.of(context).size.width * widget.swipeThreshold;
    if (_dragExtent.abs() > threshold && !_hasTriggeredHaptic) {
      HapticFeedback.mediumImpact();
      _hasTriggeredHaptic = true;
    } else if (_dragExtent.abs() <= threshold) {
      _hasTriggeredHaptic = false;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;

    final threshold = MediaQuery.of(context).size.width * widget.swipeThreshold;

    if (_dragExtent > threshold && widget.onSwipeRight != null) {
      // Swipe Right (تعديل)
      HapticFeedback.lightImpact();
      widget.onSwipeRight!();
      _resetPosition();
    } else if (_dragExtent < -threshold && widget.onSwipeLeft != null) {
      // Swipe Left (حذف)
      HapticFeedback.mediumImpact();
      widget.onSwipeLeft!();
      _resetPosition();
    } else {
      // لم يصل للـ threshold - عودة للمكان
      _resetPosition();
    }
  }

  void _resetPosition() {
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final threshold = MediaQuery.of(context).size.width * widget.swipeThreshold;
    final progress = (_dragExtent.abs() / threshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background Actions
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: _dragExtent > 0
                    ? widget.rightActionColor.withOpacity(0.2)
                    : _dragExtent < 0
                    ? widget.leftActionColor.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: _dragExtent > 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  if (_dragExtent > 0)
                    _buildAction(
                      icon: widget.rightActionIcon!,
                      label: widget.rightActionLabel!,
                      color: widget.rightActionColor,
                      progress: progress,
                      isLeft: false,
                    ),
                  if (_dragExtent < 0)
                    _buildAction(
                      icon: widget.leftActionIcon!,
                      label: widget.leftActionLabel!,
                      color: widget.leftActionColor,
                      progress: progress,
                      isLeft: true,
                    ),
                ],
              ),
            ),
          ),

          // Card
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Transform.scale(
              scale: 1.0 - (progress * 0.05),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required double progress,
    required bool isLeft,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Opacity(
        opacity: progress,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: (24 + (progress * 8)).sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: (12 + (progress * 2)).sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
