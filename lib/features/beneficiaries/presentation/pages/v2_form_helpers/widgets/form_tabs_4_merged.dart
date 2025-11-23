import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../form_controllers.dart';
import '../form_constants.dart';

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
      setState(() {
        _loadedTabs.add(widget.controller.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.controller.index,
      sizing: StackFit.loose, // تحسين الأداء
      children: List.generate(FormConstants.totalTabs, (index) {
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

  const BeneficiaryFormTabBar4({
    super.key,
    required this.controller,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              FormColors.tabGradients[currentIndex] ??
              [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
        ),
      ),
      child: TabBar(
        controller: controller,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: FormTabs.tabs.map((tab) {
          return Tab(
            icon: Icon(tab.icon, size: FormConstants.tabIconSize.sp),
            text: tab.title,
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
