import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';
import '../../../../../../core/utils/haptic_patterns.dart'; // 🎮 Haptic Patterns

/// Bottom navigation buttons for form tabs
///
/// Provides Previous/Next/Save buttons based on current tab position
/// Responsive design with adaptive layout for mobile/tablet/desktop
class BottomNavigationButtons extends StatelessWidget {
  final int currentTab;
  final int totalTabs;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final bool isLoading;

  const BottomNavigationButtons({
    super.key,
    required this.currentTab,
    required this.totalTabs,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
    this.isLoading = false,
  });

  bool get isFirstTab => currentTab == 0;
  bool get isLastTab => currentTab == totalTabs - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isTabletOrDesktop = ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);
    final buttonSpacing = isTabletOrDesktop ? 16.w : 12.w;
    final verticalPadding = isTabletOrDesktop ? 18.h : 16.h;

    return RepaintBoundary(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Next or Save Button (Left side in RTL)
              Expanded(
                flex: isFirstTab ? 1 : 2,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isLastTab) {
                            HapticPatterns.success(); // حفظ
                            onSave();
                          } else {
                            HapticPatterns.selection(); // التالي
                            onNext();
                          }
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          isLastTab ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded, // ← للأمام في RTL
                          size: isTabletOrDesktop ? 22 : 20,
                        ),
                  label: Text(
                    isLoading ? 'جاري الحفظ...' : (isLastTab ? 'حفظ' : 'التالي'),
                    style: TextStyle(
                      fontSize: isTabletOrDesktop ? 15.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: isLastTab ? Colors.green.shade600 : colorScheme.primary,
                  ),
                ),
              ),

              // Previous Button (Right side in RTL)
              if (!isFirstTab) ...[
                SizedBox(width: buttonSpacing),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticPatterns.selection();
                            onPrevious();
                          },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ), // → للخلف في RTL
                    label: Text(
                      'السابق',
                      style: TextStyle(
                        fontSize: isTabletOrDesktop ? 15.sp : 14.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
