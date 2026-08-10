import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💀 Sponsorship Card Shimmer Loader
class SponsorshipCardShimmer extends StatefulWidget {
  const SponsorshipCardShimmer({super.key});

  @override
  State<SponsorshipCardShimmer> createState() => _SponsorshipCardShimmerState();
}

class _SponsorshipCardShimmerState extends State<SponsorshipCardShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
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
    final theme = Theme.of(context);
    final shimmerColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  shimmerColor,
                  highlightColor,
                  shimmerColor,
                ],
                stops: [
                  _animation.value - 1,
                  _animation.value,
                  _animation.value + 1,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      _buildShimmerBox(48.w, 48.w, isCircle: true),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerBox(120.w, 16.h),
                            SizedBox(height: 8.h),
                            _buildShimmerBox(80.w, 14.h),
                          ],
                        ),
                      ),
                      _buildShimmerBox(60.w, 24.h),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Info Boxes
                  Row(
                    children: [
                      Expanded(child: _buildShimmerBox(double.infinity, 60.h)),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildShimmerBox(double.infinity, 60.h)),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(child: _buildShimmerBox(double.infinity, 60.h)),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildShimmerBox(double.infinity, 60.h)),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Type Badge
                  _buildShimmerBox(100.w, 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    bool isCircle = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: isCircle ? BorderRadius.circular(width / 2) : BorderRadius.circular(12.r),
      ),
    );
  }
}

/// 💀 Sponsorship List Shimmer Loader
class SponsorshipListShimmer extends StatelessWidget {
  final int itemCount;

  const SponsorshipListShimmer({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => const SponsorshipCardShimmer(),
    );
  }
}
