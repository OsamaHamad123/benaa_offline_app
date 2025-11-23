import 'package:benaa_offline_app/core/widgets/animated_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 Form Page Widgets - Extracted from beneficiary_form_page_v3
///
/// هذه الـ widgets تم استخراجها لتقليل حجم الملف الرئيسي
/// وتحسين الأداء وإمكانية إعادة الاستخدام

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Quick Stat Widget
// ═══════════════════════════════════════════════════════════════════════════

class QuickStatWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const QuickStatWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(height: 4.h),
        AnimatedCounter(
          value: value,
          duration: const Duration(milliseconds: 600),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 Quick Stats Panel
// ═══════════════════════════════════════════════════════════════════════════

class QuickStatsPanel extends StatelessWidget {
  final int completed;
  final int total;
  final bool showFieldHelpers;
  final VoidCallback onToggleHelpers;

  const QuickStatsPanel({
    super.key,
    required this.completed,
    required this.total,
    required this.showFieldHelpers,
    required this.onToggleHelpers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              QuickStatWidget(
                icon: Icons.checklist_rtl,
                label: 'مُكتمل',
                value: completed,
                color: Colors.green,
              ),
              Container(
                width: 1,
                height: 30.h,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              QuickStatWidget(
                icon: Icons.pending_outlined,
                label: 'متبقي',
                value: total - completed,
                color: Colors.orange,
              ),
              Container(
                width: 1,
                height: 30.h,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              QuickStatWidget(
                icon: Icons.analytics_outlined,
                label: 'إجمالي',
                value: total,
                color: theme.colorScheme.primary,
              ),
            ],
          ),

          // Toggle Field Helpers
          SizedBox(height: 8.h),
          InkWell(
            onTap: onToggleHelpers,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showFieldHelpers
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  showFieldHelpers ? 'إخفاء المساعدات' : 'عرض المساعدات',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Draft List Item
// ═══════════════════════════════════════════════════════════════════════════

class DraftListItem extends StatelessWidget {
  final Map<String, dynamic> draft;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DraftListItem({
    super.key,
    required this.draft,
    required this.formattedDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final draftName = draft['name'] ?? 'مسودة';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.description,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          draftName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'حُفظت: $formattedDate',
          style: TextStyle(fontSize: 12.sp),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'حذف',
            ),
            Icon(Icons.arrow_back_ios, size: 16.sp),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚠️ Unsaved Changes Dialog
// ═══════════════════════════════════════════════════════════════════════════

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحذير'),
      content: const Text('لديك تغييرات غير محفوظة. هل تريد المغادرة؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('البقاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('المغادرة'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ❌ Delete Confirmation Dialog Data
// ═══════════════════════════════════════════════════════════════════════════

class DeleteDraftDialog extends StatelessWidget {
  final String draftName;

  const DeleteDraftDialog({super.key, required this.draftName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
          SizedBox(width: 12.w),
          const Text('تأكيد الحذف'),
        ],
      ),
      content: Text('هل أنت متأكد من حذف المسودة "$draftName"؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 App Bar Title
// ═══════════════════════════════════════════════════════════════════════════

class FormPageTitle extends StatelessWidget {
  final bool isEditMode;
  final String? beneficiaryName;

  const FormPageTitle({
    super.key,
    required this.isEditMode,
    this.beneficiaryName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditMode ? 'تعديل مستفيد' : 'إضافة مستفيد',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        if (isEditMode && beneficiaryName != null)
          Text(
            beneficiaryName!,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 App Bar Actions Row - Simplified (3 buttons + Menu)
// ═══════════════════════════════════════════════════════════════════════════

class FormAppBarActions extends StatelessWidget {
  final bool showStatistics;
  final bool showFieldHelpers;
  // onToggleSearch removed - search is local to FormContentWidget
  final VoidCallback onToggleStatistics;
  final VoidCallback onToggleFieldHelpers;
  final VoidCallback onViewDrafts;
  final VoidCallback? onSaveDraft;
  final VoidCallback onShowHelp;
  final VoidCallback? onDelete;

  const FormAppBarActions({
    super.key,
    required this.showStatistics,
    required this.showFieldHelpers,
    required this.onToggleStatistics,
    required this.onToggleFieldHelpers,
    required this.onViewDrafts,
    required this.onSaveDraft,
    required this.onShowHelp,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save Draft (Primary action)
        if (onSaveDraft != null)
          IconButton(
            icon: Icon(Icons.save_outlined, size: 22.sp),
            onPressed: onSaveDraft,
            tooltip: 'حفظ كمسودة',
            color: theme.colorScheme.primary,
          ),

        // Help (Important)
        IconButton(
          icon: Icon(Icons.help_outline_rounded, size: 22.sp),
          onPressed: onShowHelp,
          tooltip: 'مساعدة',
        ),

        // Delete (if editing)
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 22.sp),
            onPressed: onDelete,
            tooltip: 'حذف',
            color: Colors.red.shade400,
          ),

        // More Menu (Secondary actions)
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 22.sp),
          tooltip: 'المزيد',
          onSelected: (value) {
            switch (value) {
              // search removed - local to FormContentWidget
              case 'statistics':
                onToggleStatistics();
                break;
              case 'drafts':
                onViewDrafts();
                break;
              case 'helpers':
                onToggleFieldHelpers();
                break;
              case 'shortcuts':
                onShowHelp();
                break;
            }
          },
          itemBuilder: (context) => [
            // Search menu item removed - search is local to FormContentWidget
            PopupMenuItem(
              value: 'drafts',
              child: Row(
                children: [
                  Icon(Icons.drafts_outlined, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('المسودات'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'helpers',
              child: Row(
                children: [
                  Icon(
                    showFieldHelpers ? Icons.visibility_off : Icons.visibility,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(showFieldHelpers ? 'إخفاء المساعدات' : 'عرض المساعدات'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'statistics',
              child: Row(
                children: [
                  Icon(
                    showStatistics ? Icons.analytics : Icons.analytics_outlined,
                    size: 20.sp,
                    color: showStatistics ? theme.colorScheme.primary : null,
                  ),
                  SizedBox(width: 12.w),
                  const Text('الإحصائيات'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'shortcuts',
              child: Row(
                children: [
                  Icon(Icons.keyboard_outlined, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('اختصارات لوحة المفاتيح'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
