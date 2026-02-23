import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'smart_auto_save_indicator.dart';
import 'form_page_widgets.dart';

/// 📱 Form AppBar Widget (Separated for performance)
///
/// Prevents rebuilding when form changes
class FormAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? beneficiaryId;
  final bool isSaving;
  final DateTime? lastSaved;
  final bool hasUnsavedChanges;
  final bool showStatistics;
  final bool showFieldHelpers;
  // onToggleSearch removed - search is local to FormContentWidget
  final VoidCallback onToggleStatistics;
  final VoidCallback onToggleFieldHelpers;
  final VoidCallback onViewDrafts;
  final VoidCallback? onSaveDraft;
  final VoidCallback onShowHelp;
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final PreferredSizeWidget? bottom;

  const FormAppBarWidget({
    required this.beneficiaryId, required this.isSaving, required this.lastSaved, required this.hasUnsavedChanges, required this.showStatistics, required this.showFieldHelpers, required this.onToggleStatistics, required this.onToggleFieldHelpers, required this.onViewDrafts, required this.onSaveDraft, required this.onShowHelp, required this.onDelete, super.key,
    this.onUndo,
    this.onRedo,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          bottom: bottom,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  beneficiaryId == null ? 'إضافة مستفيد' : 'تعديل مستفيد',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SmartAutoSaveIndicator(
                isSaving: isSaving,
                lastSaved: lastSaved,
                hasUnsavedChanges: hasUnsavedChanges,
              ),
            ],
          ),
          actions: [
            FormAppBarActions(
              showStatistics: showStatistics,
              showFieldHelpers: showFieldHelpers,
              // onToggleSearch removed - search is local to FormContentWidget
              onToggleStatistics: onToggleStatistics,
              onToggleFieldHelpers: onToggleFieldHelpers,
              onViewDrafts: onViewDrafts,
              onSaveDraft: onSaveDraft,
              onShowHelp: onShowHelp,
              onDelete: onDelete,
              onUndo: onUndo,
              onRedo: onRedo,
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
