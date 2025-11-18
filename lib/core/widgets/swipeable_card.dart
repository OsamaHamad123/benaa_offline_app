import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Swipeable Card with left and right actions
class SwipeableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Color leftActionColor;
  final Color rightActionColor;
  final IconData leftActionIcon;
  final IconData rightActionIcon;
  final String? leftActionLabel;
  final String? rightActionLabel;
  final double dismissThreshold;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftActionColor = Colors.green,
    this.rightActionColor = Colors.red,
    this.leftActionIcon = Icons.check,
    this.rightActionIcon = Icons.delete,
    this.leftActionLabel,
    this.rightActionLabel,
    this.dismissThreshold = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.endToStart && onSwipeLeft != null) {
          onSwipeLeft!();
          return false;
        } else if (direction == DismissDirection.startToEnd &&
            onSwipeRight != null) {
          onSwipeRight!();
          return false;
        }
        return false;
      },
      dismissThresholds: {
        DismissDirection.endToStart: dismissThreshold,
        DismissDirection.startToEnd: dismissThreshold,
      },
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: rightActionColor,
        icon: rightActionIcon,
        label: rightActionLabel,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: leftActionColor,
        icon: leftActionIcon,
        label: leftActionLabel,
      ),
      child: child,
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    String? label,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28.sp),
          if (label != null) ...[
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Swipeable List Item with actions
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final List<SwipeAction> actions;
  final double actionWidth;

  const SwipeableListItem({
    super.key,
    required this.child,
    required this.actions,
    this.actionWidth = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return child;

    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart && actions.isNotEmpty) {
          HapticFeedback.mediumImpact();
          // Show actions menu
          await _showActionsBottomSheet(context);
        }
        return false;
      },
      background: Container(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: actions.map((a) => a.color).toList(),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.more_horiz, color: Colors.white, size: 28.sp),
      ),
      child: child,
    );
  }

  Future<void> _showActionsBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              ...actions.map((action) {
                return ListTile(
                  leading: Icon(action.icon, color: action.color),
                  title: Text(action.label),
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                    action.onTap();
                  },
                );
              }),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}

/// Swipe Action Model
class SwipeAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
