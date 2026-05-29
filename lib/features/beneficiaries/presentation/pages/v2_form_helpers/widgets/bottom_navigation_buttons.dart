import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    // ⚡ صف واحد دائماً - تصميم مدمج لكل أحجام الشاشات
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
          child: Row(
            children: [
              // ← زر السابق (يختفي في التبويب الأول)
              if (!isFirstTab) ...[
                isCompact
                    ? IconButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                HapticPatterns.selection();
                                onPrevious();
                              },
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                        padding: EdgeInsets.all(8.w),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      )
                    : Semantics(
                        label: 'الرجوع إلى الخطوة السابقة',
                        button: true,
                        enabled: !isLoading,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  HapticPatterns.selection();
                                  onPrevious();
                                },
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          label: const Text('السابق'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                SizedBox(width: 8.w),
              ],

              // زر التالي / الحفظ (الأهم - يأخذ المساحة المتبقية)
              Expanded(
                child: Semantics(
                  label: isLastTab ? 'حفظ النموذج' : 'الانتقال إلى الخطوة التالية',
                  button: true,
                  enabled: !isLoading,
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
                        : Icon(isLastTab ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded, size: 18),
                    label: Text(
                      isLoading ? 'جاري الحفظ...' : (isLastTab ? 'حفظ' : 'التالي'),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      backgroundColor: isLastTab ? colorScheme.tertiary : colorScheme.primary,
                    ),
                  ),
                ),
              ),

              // ··· قائمة مسودة (صغيرة دائماً)
              SizedBox(width: 6.w),
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
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: const Icon(Icons.more_horiz_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
