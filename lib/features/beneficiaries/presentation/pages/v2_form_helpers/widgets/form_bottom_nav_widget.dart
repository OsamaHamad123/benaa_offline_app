import 'package:flutter/material.dart';

import '../form_constants.dart';
import 'material3_components.dart';
import 'bottom_navigation_buttons.dart';

/// 🎯 Form Bottom Navigation Widget (Separated for performance)
///
/// Only rebuilds when tab changes
class FormBottomNavWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final VoidCallback onSaveDraft;
  final bool isLoading;

  const FormBottomNavWidget({
    required this.tabController,
    required this.onPrevious,
    required this.onNext,
    required this.onSave,
    required this.onSaveDraft,
    required this.isLoading,
    super.key,
  });

  static const Map<int, List<String>> _tabFieldOrder = {
    0: [
      'الرقم الوطني',
      'الاسم الأول',
      'اسم الأب',
      'اسم الجد',
      'اللقب',
      'اسم الأم',
      'تاريخ الميلاد',
      'الأمراض المزمنة',
      'عدد ذوي الاحتياجات الخاصة',
    ],
    1: [
      'الحالة الاجتماعية',
      'عدد المعالين',
      'عدد الذكور',
      'عدد الإناث',
      'صلة القرابة بالمستفيد',
    ],
    2: [
      'رقم الهاتف',
      'رقم هاتف بديل',
      'المحافظة',
      'المدينة',
      'الحي',
      'العنوان التفصيلي',
      'حالة النزوح',
      'العنوان قبل النزوح',
      'ملاحظات عامة',
    ],
  };

  String _resolveLiveNextHint({
    required int currentTab,
    required String defaultNextHint,
    required String? focusedLabel,
  }) {
    if (focusedLabel == null || focusedLabel.trim().isEmpty) {
      return defaultNextHint;
    }

    final orderedLabels = _tabFieldOrder[currentTab];
    if (orderedLabels == null || orderedLabels.isEmpty) {
      return defaultNextHint;
    }

    final currentIndex = orderedLabels.indexOf(focusedLabel);
    if (currentIndex < 0 || currentIndex >= orderedLabels.length - 1) {
      return defaultNextHint;
    }

    final nextLabel = orderedLabels[currentIndex + 1];
    return 'التالي: $nextLabel';
  }

  String? _resolveNextFieldLabel({
    required int currentTab,
    required String? focusedLabel,
  }) {
    if (focusedLabel == null || focusedLabel.trim().isEmpty) {
      return null;
    }

    final orderedLabels = _tabFieldOrder[currentTab];
    if (orderedLabels == null || orderedLabels.isEmpty) {
      return null;
    }

    final currentIndex = orderedLabels.indexOf(focusedLabel);
    if (currentIndex < 0 || currentIndex >= orderedLabels.length - 1) {
      return null;
    }

    return orderedLabels[currentIndex + 1];
  }

  void _advanceFocusOrTab({
    required BuildContext context,
    required int currentTab,
    required bool isLastTab,
    required VoidCallback onNext,
    required VoidCallback onSave,
  }) {
    if (isLastTab) {
      onSave();
      return;
    }

    final currentLabel = FormFieldFocusTracker.focusedFieldLabel.value;
    final expectedNextLabel = _resolveNextFieldLabel(currentTab: currentTab, focusedLabel: currentLabel);

    var movedToAnotherFocus = false;
    for (var i = 0; i < 5; i++) {
      final moved = FocusScope.of(context).nextFocus();
      if (!moved) {
        break;
      }

      movedToAnotherFocus = true;
      final updatedLabel = FormFieldFocusTracker.focusedFieldLabel.value;
      if (updatedLabel != null && updatedLabel != currentLabel) {
        if (expectedNextLabel == null || updatedLabel == expectedNextLabel) {
          return;
        }
      }
    }

    if (!movedToAnotherFocus) {
      onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;
    final isCompactMobile = mediaQuery.size.width < 360;
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: tabController,
      builder: (context, _) {
        final currentTab = tabController.index;
        final isLastTab = currentTab >= FormConstants.totalTabs - 1;
        final defaultNextHint = switch (currentTab) {
          0 => 'التالي: العائلة',
          1 => 'التالي: التواصل',
          2 => 'التالي: المرفقات',
          3 => 'التالي: المراجعة',
          _ => 'التالي: حفظ نهائي',
        };

        if (isMobile && isKeyboardOpen) {
          return SafeArea(
            top: false,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: ExcludeFocus(
                excluding: true,
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              final moved = FocusScope.of(context).previousFocus();
                              if (!moved && currentTab > 0) {
                                onPrevious();
                              }
                            },
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      label: Text(isCompactMobile ? '' : 'السابق'),
                    ),
                    if (!isCompactMobile) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<String?>(
                          valueListenable: FormFieldFocusTracker.focusedFieldLabel,
                          builder: (context, focusedLabel, _) {
                            final nextHint = _resolveLiveNextHint(
                              currentTab: currentTab,
                              defaultNextHint: defaultNextHint,
                              focusedLabel: focusedLabel,
                            );
                            return Text(
                              nextHint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else
                      const Spacer(),
                    TextButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _advanceFocusOrTab(
                                context: context,
                                currentTab: currentTab,
                                isLastTab: isLastTab,
                                onNext: onNext,
                                onSave: onSave,
                              ),
                      icon: Icon(isLastTab ? Icons.check_circle_rounded : Icons.arrow_back_ios_rounded, size: 16),
                      label: Text(isCompactMobile ? '' : (isLastTab ? 'حفظ' : 'التالي')),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.tonal(
                      onPressed: isLoading ? null : () => FocusScope.of(context).unfocus(),
                      child: const Text('تم'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RepaintBoundary(
          child: BottomNavigationButtons(
            currentTab: tabController.index,
            totalTabs: FormConstants.totalTabs,
            onPrevious: onPrevious,
            onNext: onNext,
            onSave: onSave,
            onSaveDraft: onSaveDraft,
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}
