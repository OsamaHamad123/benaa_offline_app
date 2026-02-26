import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_controllers.dart';
import '../form_constants.dart';
import '../beneficiary_form_colors.dart'; // 🎨 Material 3 Colors
import 'tab_completion_badge.dart'; // 🏆 Tab Completion Badges
import 'tab_completion_celebration.dart'; // 🎉 Success Celebrations

// Import redesigned tabs
import '../../../widgets/v2/tabs/v2_personal_info_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_family_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_contact_notes_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_unified_attachments_tab.dart';
import '../../../widgets/v2/tabs/v2_review_tab.dart'; // 🆕 Review Tab

/// 📋 New 5-Tab Form Structure (Merged from 7 tabs + Review)
///
/// التبويبات الجديدة:
/// 1. معلومات شخصية (أساسي + إضافي)
/// 2. العائلة (العائلة + أفراد)
/// 3. التواصل والملاحظات (التواصل + ملاحظات)
/// 4. المرفقات
/// 5. المراجعة النهائية 🆕
class BeneficiaryFormTabs4Merged extends StatefulWidget {
  final TabController controller;
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onBirthDateTap;
  final FocusNode firstFieldFocusNode;
  final String? beneficiaryId;
  final VoidCallback? onFinalSave; // 🆕 Callback for final save

  const BeneficiaryFormTabs4Merged({
    required this.controller,
    required this.formControllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
    super.key,
    this.onFinalSave,
  });

  @override
  State<BeneficiaryFormTabs4Merged> createState() => _BeneficiaryFormTabs4MergedState();
}

class _BeneficiaryFormTabs4MergedState extends State<BeneficiaryFormTabs4Merged> {
  final Set<int> _loadedTabs = {0};
  int _activeTabIndex = 0;
  int _previousTabIndex = 0;
  bool _isNavigatingForward = true;
  Timer? _preloadNextTabTimer;
  late final FocusNode _familyFirstFieldFocusNode;
  late final FocusNode _contactFirstFieldFocusNode;
  final Map<int, FocusNode> _lastFocusedNodeByTab = <int, FocusNode>{};

  @override
  void initState() {
    super.initState();
    _familyFirstFieldFocusNode = FocusNode();
    _contactFirstFieldFocusNode = FocusNode();
    _activeTabIndex = widget.controller.index;
    widget.controller.addListener(_onTabChanged);
    FocusManager.instance.addListener(_onGlobalFocusChanged);
    _schedulePreloadNextTab(_activeTabIndex);
  }

  @override
  void dispose() {
    _preloadNextTabTimer?.cancel();
    _familyFirstFieldFocusNode.dispose();
    _contactFirstFieldFocusNode.dispose();
    FocusManager.instance.removeListener(_onGlobalFocusChanged);
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onGlobalFocusChanged() {
    final focused = FocusManager.instance.primaryFocus;
    if (focused == null || !mounted) return;
    if (focused.context == null) return;
    _lastFocusedNodeByTab[_activeTabIndex] = focused;
  }

  void _onTabChanged() {
    if (!mounted) return;

    // Ignore intermediate animation ticks and rebuild only on settled index.
    if (widget.controller.indexIsChanging) {
      return;
    }

    final currentTab = widget.controller.index;
    var shouldRebuild = false;

    // Load immediately if tab hasn't been loaded
    if (!_loadedTabs.contains(currentTab)) {
      _loadedTabs.add(currentTab);
      shouldRebuild = true;
    }

    if (_activeTabIndex != currentTab) {
      _previousTabIndex = _activeTabIndex;
      _isNavigatingForward = currentTab >= _activeTabIndex;
      _activeTabIndex = currentTab;
      shouldRebuild = true;

      final lastFocused = _lastFocusedNodeByTab[currentTab];
      if (lastFocused != null) {
        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted) return;
          if (lastFocused.canRequestFocus) {
            FocusScope.of(context).requestFocus(lastFocused);
          }
        });
      }
    }

    if (shouldRebuild && mounted) {
      setState(() {});
    }

    _schedulePreloadNextTab(currentTab);
  }

  void _schedulePreloadNextTab(int currentTab) {
    _preloadNextTabTimer?.cancel();
    final nextTab = (currentTab + 1).clamp(0, FormConstants.totalTabs - 1);
    if (nextTab == currentTab || _loadedTabs.contains(nextTab)) {
      return;
    }

    _preloadNextTabTimer = Timer(const Duration(milliseconds: 380), () {
      if (!mounted || _loadedTabs.contains(nextTab)) {
        return;
      }
      setState(() {
        _loadedTabs.add(nextTab);
      });
    });
  }

  /// 🎉 Check and celebrate tab completion
  void checkAndCelebrateCompletion(int tabIndex, TabCompletionStats stats) {
    if (stats.percentage == 100 && !TabCompletionCelebration.hasCelebrated(tabIndex)) {
      TabCompletionCelebration.show(
        context,
        tabIndex: tabIndex,
        tabTitle: FormTabs.tabs[tabIndex].title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final transitionDuration = Duration(milliseconds: isMobile ? 180 : 220);
    final hiddenSlideX = isMobile ? 0.020 : 0.014;
    final transitionCurve = _isNavigatingForward ? Curves.easeOutCubic : Curves.easeOutQuad;
    final hiddenOffset = _isNavigatingForward ? Offset(hiddenSlideX, 0) : Offset(-hiddenSlideX, 0);

    return Stack(
      fit: StackFit.expand,
      children: List.generate(FormConstants.totalTabs, (index) {
        if (!_loadedTabs.contains(index)) {
          return const SizedBox.shrink();
        }

        final isActive = index == _activeTabIndex;

        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            key: ValueKey('tab_fade_$index'),
            opacity: isActive ? 1 : 0,
            duration: transitionDuration,
            curve: transitionCurve,
            child: AnimatedSlide(
              offset: isActive ? Offset.zero : hiddenOffset,
              duration: transitionDuration,
              curve: transitionCurve,
              child: TickerMode(
                enabled: isActive,
                child: RepaintBoundary(
                  key: ValueKey('tab_$index'),
                  child: _buildTabAtIndex(index),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabAtIndex(int index) {
    switch (index) {
      case 0:
        return _buildPersonalInfoMergedTab();
      case 1:
        return _buildFamilyMergedTab();
      case 2:
        return _buildContactNotesMergedTab();
      case 3:
        return _buildAttachmentsTab();
      case 4:
        return _buildReviewTab(); // 🆕 Review Tab
      default:
        return const SizedBox.shrink();
    }
  }

  void _goToTab(int tabIndex) {
    final safeIndex = tabIndex.clamp(0, FormConstants.totalTabs - 1);
    if (safeIndex == widget.controller.index) return;
    final isForward = safeIndex > widget.controller.index;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final duration = Duration(milliseconds: isMobile ? 180 : 220);
    final curve = isForward ? Curves.easeOutCubic : Curves.easeOutQuad;

    widget.controller.animateTo(
      safeIndex,
      duration: duration,
      curve: curve,
    );
  }

  void _goToNextTabFrom(int currentIndex) {
    final nextIndex = (currentIndex + 1).clamp(0, FormConstants.totalTabs - 1);
    if (nextIndex == currentIndex) return;
    _goToTab(nextIndex);

    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      final targetFocusNode = switch (nextIndex) {
        0 => widget.firstFieldFocusNode,
        1 => _familyFirstFieldFocusNode,
        2 => _contactFirstFieldFocusNode,
        _ => null,
      };

      if (targetFocusNode != null && targetFocusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(targetFocusNode);
      }
    });
  }

  /// 👤 Tab 1: معلومات شخصية (Basic + Additional)
  Widget _buildPersonalInfoMergedTab() {
    return V2PersonalInfoMergedTab(
      key: const ValueKey('personal_info_merged_tab'),
      formControllers: widget.formControllers,
      onBirthDateTap: widget.onBirthDateTap,
      firstFieldFocusNode: widget.firstFieldFocusNode,
      onRequestNextTab: () => _goToNextTabFrom(0),
    );
  }

  /// 👨‍👩‍👧 Tab 2: العائلة (Family Info + Family Members)
  Widget _buildFamilyMergedTab() {
    return V2FamilyMergedTab(
      key: const ValueKey('family_merged_tab'),
      formControllers: widget.formControllers,
      onRequestNextTab: () => _goToNextTabFrom(1),
      firstFieldFocusNode: _familyFirstFieldFocusNode,
    );
  }

  /// 📞 Tab 3: التواصل والملاحظات (Contact + Notes)
  Widget _buildContactNotesMergedTab() {
    return V2ContactNotesMergedTab(
      key: const ValueKey('contact_notes_merged_tab'),
      formControllers: widget.formControllers,
      onRequestNextTab: () => _goToNextTabFrom(2),
      onRequestReviewTab: () => _goToTab(4),
      firstFieldFocusNode: _contactFirstFieldFocusNode,
    );
  }

  /// 📎 Tab 4: المرفقات
  Widget _buildAttachmentsTab() {
    return V2UnifiedAttachmentsTab(
      key: const ValueKey('attachments_tab'),
      beneficiaryId: widget.beneficiaryId,
      pendingFiles: widget.formControllers.pendingAttachmentFiles,
      onPendingFilesChanged: (files) {
        widget.formControllers.updatePendingFiles(files);
      },
      formControllers: widget.formControllers,
    );
  }

  /// 📋 Tab 5: المراجعة النهائية 🆕
  Widget _buildReviewTab() {
    return V2ReviewTab(
      key: const ValueKey('review_tab'),
      formControllers: widget.formControllers,
      onFinalSave: widget.onFinalSave ?? () {},
      onJumpToTab: (index) {
        _goToTab(index);
      },
      onEditSection: () {
        _goToTab(0);
      },
    );
  }
}

/// 🎨 New Tab Bar with 4 Tabs
class BeneficiaryFormTabBar4 extends StatelessWidget {
  final TabController controller;
  final int currentIndex;
  final Map<int, TabCompletionStats>? tabStats;

  static const Map<int, String> _mobileTabTitles = {
    0: 'الأساس',
    1: 'العائلة',
    2: 'التواصل',
    3: 'المرفقات',
    4: 'المراجعة',
  };

  const BeneficiaryFormTabBar4({
    required this.controller,
    required this.currentIndex,
    super.key,
    this.tabStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final tabHeight = isMobile ? 56.0 : 60.0;
    final tabIconSize = isMobile ? 19.0 : 20.0;
    final activeLabelSize = isMobile ? 11.sp : 12.sp;
    final inactiveLabelSize = isMobile ? 10.sp : 11.sp;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: (targetIndex) {
          if (targetIndex == currentIndex) return;
          final isForward = targetIndex > currentIndex;
          final duration = Duration(milliseconds: isMobile ? 180 : 220);
          final curve = isForward ? Curves.easeOutCubic : Curves.easeOutQuad;
          controller.animateTo(targetIndex, duration: duration, curve: curve);
        },
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: isMobile ? 4 : 3,
        labelStyle: TextStyle(fontSize: activeLabelSize, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: inactiveLabelSize,
          fontWeight: FontWeight.w500,
        ),
        tabs: FormTabs.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final stats = tabStats?[index];
          final isActive = currentIndex == index;
          final title = isMobile ? (_mobileTabTitles[index] ?? tab.title) : tab.title;
          final percent = stats?.percentage ?? 0;
          final isComplete = percent == 100;
          final needsAttention = index < currentIndex && !isComplete;
          final showBadge = stats != null && (isComplete || needsAttention);

          final statusColor = isComplete
              ? BeneficiaryFormColors.success
              : needsAttention
                  ? Theme.of(context).colorScheme.error
                  : theme.colorScheme.primary;

          final statusIcon = isComplete
              ? Icons.check
              : needsAttention
                  ? Icons.priority_high_rounded
                  : Icons.check;

          return Tab(
            height: tabHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with checkmark badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      tab.icon,
                      size: tabIconSize,
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    if (showBadge)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            statusIcon,
                            color: Colors.white,
                            size: 9,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: isMobile ? 4 : 6),

                // Tab Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isActive ? activeLabelSize : inactiveLabelSize,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                if (!isMobile && stats != null) ...[
                  const SizedBox(height: 4),

                  // Simple Progress Bar
                  SizedBox(
                    width: 50,
                    height: 3,
                    child: LinearProgressIndicator(
                      value: stats.percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        BeneficiaryFormColors.getProgressColor(
                          context,
                          stats.percentage,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 📊 Enhanced Progress Indicator for 4 Tabs
class FormProgress4Tabs extends StatelessWidget {
  final int currentStep;

  const FormProgress4Tabs({required this.currentStep, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentStep + 1) / FormConstants.totalTabs;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50.w,
                height: 50.h,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    FormColors.tabGradients[currentStep]![0],
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(width: 16.w),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FormTabs.tabs[currentStep].fullTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'الخطوة ${currentStep + 1} من ${FormConstants.totalTabs}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Hint
          if (currentStep < FormConstants.totalTabs - 1)
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 18.sp,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
