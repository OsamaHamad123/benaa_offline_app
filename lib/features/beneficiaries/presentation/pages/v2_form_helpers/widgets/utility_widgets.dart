import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 🔄 Loading Overlay
///
/// Shows loading indicator with optional message
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color:
                  backgroundColor ?? theme.colorScheme.surface.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: indicatorColor ?? theme.colorScheme.primary,
                    ),
                    if (message != null) ...[
                      SizedBox(height: ResponsiveUtils.mediumSpace),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 📅 Date Range Picker Button
///
/// Button to select date range
class DateRangePickerButton extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final void Function(DateTimeRange?) onRangeSelected;
  final String label;
  final IconData icon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateRangePickerButton({
    required this.onRangeSelected, super.key,
    this.selectedRange,
    this.label = 'اختر الفترة',
    this.icon = Icons.date_range,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDateRangePicker(context),
      icon: Icon(icon, size: 18),
      label: Text(
        selectedRange != null
            ? '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}'
            : label,
        style: TextStyle(fontSize: 13.sp),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      initialDateRange: selectedRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (range != null) {
      onRangeSelected(range);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

/// 🎨 Color Picker Button
///
/// Button to select color
class ColorPickerButton extends StatelessWidget {
  final Color selectedColor;
  final void Function(Color) onColorSelected;
  final String label;
  final List<Color>? colors;

  const ColorPickerButton({
    required this.selectedColor, required this.onColorSelected, super.key,
    this.label = 'اختر اللون',
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showColorPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
          SizedBox(width: 8.w),
          Text(label),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final defaultColors = colors ??
        [
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.deepPurple,
          Colors.indigo,
          Colors.blue,
          Colors.lightBlue,
          Colors.cyan,
          Colors.teal,
          Colors.green,
          Colors.lightGreen,
          Colors.lime,
          Colors.yellow,
          Colors.amber,
          Colors.orange,
          Colors.deepOrange,
          Colors.brown,
          Colors.grey,
          Colors.blueGrey,
        ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللون'),
        content: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: defaultColors.map((color) {
            final isSelected = color.value == selectedColor.value;
            return InkWell(
              onTap: () {
                onColorSelected(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

/// 📱 QR Code Display
///
/// Displays QR code (simplified version - requires qr_flutter package)
class QRCodeDisplay extends StatelessWidget {
  final String data;
  final double size;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const QRCodeDisplay({
    required this.data, super.key,
    this.size = 200,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder - would use QrImageView from qr_flutter package
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: size.w * 0.6,
              color: foregroundColor ?? Colors.black,
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                data,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎭 Empty State Widget
///
/// Shows when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    required this.title, super.key,
    this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.outline),
            SizedBox(height: ResponsiveUtils.mediumSpace),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: ResponsiveUtils.smallSpace),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              SizedBox(height: ResponsiveUtils.largeSpace),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel ?? 'إضافة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ⚠️ Error Display Widget
///
/// Shows error with retry option
class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  const ErrorDisplayWidget({
    super.key,
    this.title = 'حدث خطأ',
    this.message,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.error),
            SizedBox(height: ResponsiveUtils.mediumSpace),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: ResponsiveUtils.smallSpace),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: ResponsiveUtils.largeSpace),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'إعادة المحاولة'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🔔 Notification Badge
///
/// Shows notification count
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    required this.count, required this.child, super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: count > 0 ? 'لديك $count إشعار' : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (count > 0)
            Positioned(
              top: -4.h,
              left: -4.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: count > 9 ? 6.w : 4.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(10.r),
                  border:
                      Border.all(color: theme.colorScheme.surface, width: 2),
                ),
                constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🎯 Skeleton Loader
///
/// Shows loading placeholder
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    required this.width, required this.height, super.key,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
            gradient: LinearGradient(
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 📋 List Tile Skeleton
///
/// Skeleton for list items
class ListTileSkeleton extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;

  const ListTileSkeleton({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.mediumSpace,
        vertical: ResponsiveUtils.smallSpace,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            SkeletonLoader(
              width: 40.w,
              height: 40.h,
              borderRadius: BorderRadius.circular(20.r),
            ),
            SizedBox(width: ResponsiveUtils.mediumSpace),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 16.h),
                ...List.generate(
                  subtitleLines,
                  (index) => Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: SkeletonLoader(
                      width: (200 - (index * 50)).w,
                      height: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            SizedBox(width: ResponsiveUtils.mediumSpace),
            SkeletonLoader(width: 60.w, height: 30.h),
          ],
        ],
      ),
    );
  }
}
