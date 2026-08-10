import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';

/// ⚡ Skeleton Loader للجمعيات
///
/// يعرض تأثير تحميل (shimmer) لكروت الجمعيات
class AssociationsSkeletonLoader extends StatefulWidget {
  final int itemCount;

  const AssociationsSkeletonLoader({
    super.key,
    this.itemCount = 4,
  });

  @override
  State<AssociationsSkeletonLoader> createState() =>
      _AssociationsSkeletonLoaderState();
}

class _AssociationsSkeletonLoaderState extends State<AssociationsSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils.getValues(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => SizedBox(height: responsive.spacing),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _SkeletonCard(gradientPosition: _animation.value);
          },
        );
      },
    );
  }
}

/// Skeleton Card مع تأثير shimmer
class _SkeletonCard extends StatelessWidget {
  final double gradientPosition;

  const _SkeletonCard({required this.gradientPosition});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Name
            Row(
              children: [
                _ShimmerBox(
                  width: 48.w,
                  height: 48.h,
                  borderRadius: ResponsiveUtils.mediumRadius,
                  gradientPosition: gradientPosition,
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 150.w,
                        height: 18.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                      SizedBox(height: 6.h),
                      _ShimmerBox(
                        width: 100.w,
                        height: 14.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.mediumSpace),

            // Details: Phone + Bank
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 80.w,
                        height: 14.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                      SizedBox(height: 4.h),
                      _ShimmerBox(
                        width: 120.w,
                        height: 14.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.smallSpace),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 80.w,
                        height: 14.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                      SizedBox(height: 4.h),
                      _ShimmerBox(
                        width: 100.w,
                        height: 14.h,
                        borderRadius: 4.r,
                        gradientPosition: gradientPosition,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.mediumSpace),

            // Representative
            _ShimmerBox(
              width: 140.w,
              height: 14.h,
              borderRadius: 4.r,
              gradientPosition: gradientPosition,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Box - صندوق مع تأثير shimmer
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double gradientPosition;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.gradientPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [
            (gradientPosition - 1).clamp(0.0, 1.0),
            gradientPosition.clamp(0.0, 1.0),
            (gradientPosition + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
