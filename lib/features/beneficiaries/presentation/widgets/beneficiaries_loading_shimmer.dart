import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ⏳ Loading shimmer widget - Reusable component
///
/// يعرض skeleton loader أثناء تحميل البيانات
class BeneficiariesLoadingShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const BeneficiariesLoadingShimmer({
    super.key,
    this.itemCount = 5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final skeletonBase = colorScheme.surfaceContainerHighest;
    final skeletonHighlight = colorScheme.surface;
    final skeletonBlock = colorScheme.surface;

    return ListView.builder(
      itemCount: itemCount,
      padding: padding ?? const EdgeInsets.all(16),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: skeletonBase,
        highlightColor: skeletonHighlight,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: skeletonBlock,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 150,
                            height: 14,
                            decoration: BoxDecoration(
                              color: skeletonBlock,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 10,
                            decoration: BoxDecoration(
                              color: skeletonBlock,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 60 + (i * 8).toDouble(),
                        height: 24,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: skeletonBlock,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
