import 'package:flutter/material.dart';

/// ⚡ Skeleton Loader - Modern loading animation
///
/// Shows animated shimmer effect while loading search results
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final double? spacing;

  const SkeletonLoader({super.key, this.itemCount = 3, this.spacing});

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
    final spacing = widget.spacing ?? 16.0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: _SkeletonCard(animation: _animation),
        );
      },
    );
  }
}

/// Skeleton Card with shimmer animation
class _SkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _SkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Row(
                  children: [
                    _ShimmerBox(
                      width: 40,
                      height: 40,
                      borderRadius: 20,
                      gradientPosition: animation.value,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerBox(
                            width: double.infinity,
                            height: 16,
                            gradientPosition: animation.value,
                          ),
                          const SizedBox(height: 8),
                          _ShimmerBox(
                            width: 150,
                            height: 14,
                            gradientPosition: animation.value,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Details skeleton
                _ShimmerBox(
                  width: double.infinity,
                  height: 12,
                  gradientPosition: animation.value,
                ),
                const SizedBox(height: 8),
                _ShimmerBox(
                  width: 200,
                  height: 12,
                  gradientPosition: animation.value,
                ),
                const SizedBox(height: 8),
                _ShimmerBox(
                  width: 180,
                  height: 12,
                  gradientPosition: animation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer box with gradient animation
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;
  final double gradientPosition;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
    required this.gradientPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          stops: [
            (gradientPosition - 0.3).clamp(0.0, 1.0),
            (gradientPosition).clamp(0.0, 1.0),
            (gradientPosition + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

/// Inline skeleton loader for "Load More" button area
class InlineSkeletonLoader extends StatelessWidget {
  const InlineSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'جاري تحميل المزيد...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
