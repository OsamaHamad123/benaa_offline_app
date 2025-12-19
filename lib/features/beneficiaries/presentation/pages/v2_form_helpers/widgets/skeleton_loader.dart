import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// 💀 Skeleton Loader Widgets
///
/// Reusable skeleton loading states for different UI components

class SkeletonLoader {
  /// Form Field Skeleton
  static Widget formField({double? width, double height = 48}) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  /// Text Line Skeleton
  static Widget textLine({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  /// Card Skeleton
  static Widget card({double? height = 120}) {
    return Container(
      height: height?.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  /// Avatar/Circle Skeleton
  static Widget circle({double size = 40}) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  /// List Item Skeleton
  static Widget listItem() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          circle(size: 48),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textLine(width: double.infinity, height: 16),
                SizedBox(height: 8.h),
                textLine(width: 200.w, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Form Tab Skeleton (للتبويبات)
  static Widget formTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          textLine(width: 150.w, height: 20),
          SizedBox(height: 20.h),

          // Form Fields
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textLine(width: 100.w, height: 14),
                  SizedBox(height: 8.h),
                  formField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Attachment Grid Skeleton
  static Widget attachmentGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return card(height: 100);
      },
    );
  }
}

/// 🌟 Shimmer Wrapper Widget
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: baseColor ??
          theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      highlightColor:
          highlightColor ?? theme.colorScheme.surface.withOpacity(0.8),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// 📦 Prebuilt Skeleton Screens
class SkeletonFormScreen extends StatelessWidget {
  const SkeletonFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(child: SkeletonLoader.formTab());
  }
}

class SkeletonListScreen extends StatelessWidget {
  final int itemCount;

  const SkeletonListScreen({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: itemCount,
        itemBuilder: (context, index) => SkeletonLoader.listItem(),
      ),
    );
  }
}

class SkeletonAttachmentGrid extends StatelessWidget {
  const SkeletonAttachmentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(child: SkeletonLoader.attachmentGrid());
  }
}
