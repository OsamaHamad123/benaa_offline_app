import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_controllers.dart';
import '../form_constants.dart';
import '../beneficiary_form_colors.dart'; // 🎨 Material 3 Colors
import 'tab_completion_badge.dart'; // 🏆 Tab Completion Badges
import 'tab_completion_celebration.dart'; // 🎉 Success Celebrations
import 'skeleton_loader.dart'; // 💀 Skeleton screens

// Import redesigned tabs
import '../../../widgets/v2/tabs/v2_personal_info_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_family_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_contact_notes_merged_tab.dart';
import '../../../widgets/v2/tabs/v2_unified_attachments_tab.dart';

/// 📋 New 4-Tab Form Structure (Merged from 7 tabs)
///
/// التبويبات الجديدة:
/// 1. معلومات شخصية (أساسي + إضافي)
/// 2. العائلة (العائلة + أفراد)
/// 3. التواصل والملاحظات (التواصل + ملاحظات)
/// 4. المرفقات
class BeneficiaryFormTabs4Merged extends StatefulWidget {
  final TabController controller;
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onBirthDateTap;
  final FocusNode firstFieldFocusNode;
  final String? beneficiaryId;

  const BeneficiaryFormTabs4Merged({
    super.key,
    required this.controller,
    required this.formControllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
  });

  @override
  State<BeneficiaryFormTabs4Merged> createState() =>
      _BeneficiaryFormTabs4MergedState();
}

class _BeneficiaryFormTabs4MergedState
    extends State<BeneficiaryFormTabs4Merged> {
  final Set<int> _loadedTabs = {0}; // Always load first tab
  final Map<int, bool> _tabsLoading = {}; // Track loading state per tab

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      final currentTab = widget.controller.index;
      if (!_loadedTabs.contains(currentTab)) {
        setState(() {
          _tabsLoading[currentTab] = true; // Show skeleton
        });

        // Simulate async loading (could be replaced with actual data loading)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _loadedTabs.add(currentTab);
              _tabsLoading[currentTab] = false;
            });
          }
        });
      } else {
        // Tab already loaded, just trigger rebuild
        setState(() {});
      }
    }
  }

  /// 🎉 Check and celebrate tab completion
  void checkAndCelebrateCompletion(int tabIndex, TabCompletionStats stats) {
    if (stats.percentage == 100 &&
        !TabCompletionCelebration.hasCelebrated(tabIndex)) {
      TabCompletionCelebration.show(
        context,
        tabIndex: tabIndex,
        tabTitle: FormTabs.tabs[tabIndex].title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.controller.index,
      sizing: StackFit.loose, // تحسين الأداء
      children: List.generate(FormConstants.totalTabs, (index) {
        // Show skeleton while loading
        if (_tabsLoading[index] == true) {
          return _buildSkeletonForTab(index);
        }

        // Lazy load: only build tabs that have been visited
        if (!_loadedTabs.contains(index)) {
          return const SizedBox.shrink();
        }

        // Wrap with RepaintBoundary for better performance
        return RepaintBoundary(
          key: ValueKey('tab_$index'),
          child: _buildTabAtIndex(index),
        );
      }),
    );
  }

  /// 💀 Skeleton screen based on tab type
  Widget _buildSkeletonForTab(int tabIndex) {
    switch (tabIndex) {
      case 3: // Attachments tab
        return const SkeletonAttachmentGrid();
      default: // Form tabs (0, 1, 2)
        return const SkeletonFormScreen();
    }
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
      default:
        return const SizedBox.shrink();
    }
  }

  /// 👤 Tab 1: معلومات شخصية (Basic + Additional)
  Widget _buildPersonalInfoMergedTab() {
    return V2PersonalInfoMergedTab(
      key: const ValueKey('personal_info_merged_tab'),
      formControllers: widget.formControllers,
      onBirthDateTap: widget.onBirthDateTap,
      firstFieldFocusNode: widget.firstFieldFocusNode,
    );
  }

  /// 👨‍👩‍👧 Tab 2: العائلة (Family Info + Family Members)
  Widget _buildFamilyMergedTab() {
    return V2FamilyMergedTab(
      key: const ValueKey('family_merged_tab'),
      formControllers: widget.formControllers,
    );
  }

  /// 📞 Tab 3: التواصل والملاحظات (Contact + Notes)
  Widget _buildContactNotesMergedTab() {
    return V2ContactNotesMergedTab(
      key: const ValueKey('contact_notes_merged_tab'),
      formControllers: widget.formControllers,
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
}

/// 🎨 New Tab Bar with 4 Tabs
class BeneficiaryFormTabBar4 extends StatelessWidget {
  final TabController controller;
  final int currentIndex;
  final Map<int, TabCompletionStats>? tabStats;

  const BeneficiaryFormTabBar4({
    super.key,
    required this.controller,
    required this.currentIndex,
    this.tabStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: FormTabs.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final stats = tabStats?[index];
          final isActive = currentIndex == index;

          return Tab(
            height: 60,
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
                      size: 20,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    // Checkmark for completed tabs
                    if (stats != null && stats.percentage == 100)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: BeneficiaryFormColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Tab Title
                Text(
                  tab.title,
                  style: TextStyle(
                    fontSize: isActive ? 12.sp : 11.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                if (stats != null) ...[
                  const SizedBox(height: 4),

                  // Simple Progress Bar
                  SizedBox(
                    width: 50,
                    height: 3,
                    child: LinearProgressIndicator(
                      value: stats.percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
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

  const FormProgress4Tabs({super.key, required this.currentStep});

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
                '${((progress * 100).toInt())}%',
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
