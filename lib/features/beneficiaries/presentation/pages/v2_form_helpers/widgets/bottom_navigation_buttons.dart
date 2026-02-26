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
  final VoidCallback onSaveDraft;
  final bool isLoading;

  const BottomNavigationButtons({
    required this.currentTab,
    required this.totalTabs,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
    required this.onSaveDraft,
    super.key,
    this.isLoading = false,
  });

  bool get isFirstTab => currentTab == 0;
  bool get isLastTab => currentTab == totalTabs - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactMobile = screenWidth < 360;

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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: isCompactMobile
              ? Row(
                  children: [
                    if (!isFirstTab)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  HapticPatterns.selection();
                                  onPrevious();
                                },
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                          label: const Text('السابق'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    if (!isFirstTab) SizedBox(width: buttonSpacing),
                    Expanded(
                      flex: isFirstTab ? 1 : 2,
                      child: FilledButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isLastTab) {
                                  HapticPatterns.success();
                                  onSave();
                                } else {
                                  HapticPatterns.selection();
                                  onNext();
                                }
                              },
                        icon: isLoading
                            ? SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                                ),
                              )
                            : Icon(isLastTab ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded),
                        label: Text(isLoading ? 'جاري الحفظ...' : (isLastTab ? 'حفظ' : 'التالي')),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          backgroundColor: isLastTab ? colorScheme.tertiary : colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: buttonSpacing),
                    PopupMenuButton<String>(
                      tooltip: 'إجراءات إضافية',
                      enabled: !isLoading,
                      onSelected: (value) {
                        if (value == 'save_draft') {
                          HapticPatterns.selection();
                          onSaveDraft();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'save_draft',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.save_outlined),
                            title: Text('حفظ مسودة'),
                          ),
                        ),
                      ],
                      child: Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: const Icon(Icons.more_horiz_rounded),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    HapticPatterns.selection();
                                    onSaveDraft();
                                  },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('حفظ مسودة'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        // Next or Save Button (Left side in RTL)
                        Expanded(
                          flex: isFirstTab ? 1 : 2,
                          child: Semantics(
                            label: isLastTab ? 'حفظ النموذج' : 'الانتقال إلى التبويب التالي',
                            hint: isLastTab ? 'اضغط لحفظ جميع البيانات' : 'اضغط للمتابعة',
                            button: true,
                            enabled: !isLoading,
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
                                      isLastTab ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded,
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
                                backgroundColor: isLastTab ? colorScheme.tertiary : colorScheme.primary,
                              ),
                            ),
                          ),
                        ),

                        // Previous Button (Right side in RTL)
                        if (!isFirstTab) ...[
                          SizedBox(width: buttonSpacing),
                          Expanded(
                            child: Semantics(
                              label: 'الرجوع إلى التبويب السابق',
                              hint: 'اضغط للرجوع',
                              button: true,
                              child: OutlinedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        HapticPatterns.selection();
                                        onPrevious();
                                      },
                                icon: const Icon(Icons.arrow_forward_ios_rounded),
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
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
