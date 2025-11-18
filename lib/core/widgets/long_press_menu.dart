import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Context Menu Item
class ContextMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isDangerous;

  const ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isDangerous = false,
  });
}

/// Long Press Context Menu
class LongPressContextMenu {
  /// Show context menu at position
  static Future<void> show(
    BuildContext context, {
    required List<ContextMenuItem> items,
    Offset? position,
  }) async {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final pos =
        position ??
        (context.findRenderObject() as RenderBox?)?.localToGlobal(
          Offset.zero,
        ) ??
        Offset.zero;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: items.map((item) {
        return PopupMenuItem(
          onTap: item.onTap,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20.sp,
                color: item.isDangerous
                    ? Colors.red
                    : (item.color ?? Colors.grey[700]),
              ),
              SizedBox(width: 12.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: item.isDangerous
                      ? Colors.red
                      : (item.color ?? Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 8,
    );
  }

  /// Show bottom sheet menu
  static Future<void> showBottomSheet(
    BuildContext context, {
    required List<ContextMenuItem> items,
    String? title,
  }) async {
    HapticFeedback.mediumImpact();

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
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Divider(height: 24.h),
              ],
              // Menu Items
              ...items.map((item) {
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: item.isDangerous
                        ? Colors.red
                        : (item.color ?? Colors.grey[700]),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: item.isDangerous
                          ? Colors.red
                          : (item.color ?? Colors.black87),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.selectionClick();
                    item.onTap();
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

/// Widget with Long Press Menu
class LongPressMenuWidget extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> menuItems;
  final String? menuTitle;
  final bool useBottomSheet;

  const LongPressMenuWidget({
    super.key,
    required this.child,
    required this.menuItems,
    this.menuTitle,
    this.useBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (useBottomSheet) {
          LongPressContextMenu.showBottomSheet(
            context,
            items: menuItems,
            title: menuTitle,
          );
        } else {
          LongPressContextMenu.show(context, items: menuItems);
        }
      },
      child: child,
    );
  }
}
