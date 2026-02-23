import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ⬅️➡️ Previous/Next Navigation Buttons
///
/// Reusable bottom navigation for tabs with haptic feedback
class TabNavigationButtons extends StatelessWidget {
  final TabController controller;
  final int currentIndex;
  final int totalTabs;
  final VoidCallback? onFinalSave; // 🆕 Callback for save button

  const TabNavigationButtons({
    required this.controller, required this.currentIndex, required this.totalTabs, super.key,
    this.onFinalSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            Flexible(
              child: OutlinedButton.icon(
                onPressed: currentIndex > 0
                    ? () {
                        HapticFeedback.selectionClick();
                        controller.animateTo(currentIndex - 1);
                      }
                    : null,
                icon: Icon(Icons.arrow_back_rounded, size: 16.sp),
                label: const Text('السابق'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),

            // Tab indicator
            Flexible(
              child: Center(
                child: Text(
                  'التبويب ${currentIndex + 1} / $totalTabs',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Next/Save button
            Flexible(
              child: currentIndex == totalTabs - 1
                  ? FilledButton.icon(
                      onPressed: onFinalSave ??
                          () {
                            HapticFeedback.mediumImpact();
                            // Show message if no callback
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('استخدم زر الحفظ في الأعلى'),
                              ),
                            );
                          },
                      label: const Text('مراجعة وحفظ'),
                      icon: Icon(Icons.save_rounded, size: 16.sp),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        controller.animateTo(currentIndex + 1);
                      },
                      label: const Text('التالي'),
                      icon: Icon(Icons.arrow_forward_rounded, size: 16.sp),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
