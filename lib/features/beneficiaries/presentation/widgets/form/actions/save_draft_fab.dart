import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 FAB عائم لحفظ كمسودة مع قائمة إجراءات سريعة
///
/// يعرض:
/// - زر عائم رئيسي (حفظ كمسودة)
/// - قائمة إجراءات منبثقة (عند الضغط المطول)
class SaveDraftFAB extends StatefulWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback? onQuickSave;
  final VoidCallback? onViewDrafts;
  final VoidCallback? onShowStatistics;
  final bool hasUnsavedChanges;

  const SaveDraftFAB({
    super.key,
    required this.onSaveDraft,
    this.onQuickSave,
    this.onViewDrafts,
    this.onShowStatistics,
    required this.hasUnsavedChanges,
  });

  @override
  State<SaveDraftFAB> createState() => _SaveDraftFABState();
}

class _SaveDraftFABState extends State<SaveDraftFAB> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // قائمة الإجراءات المنبثقة
        if (_isExpanded) ...[
          _buildQuickActionButton(
            icon: Icons.flash_on,
            label: 'حفظ سريع',
            onPressed: () {
              _toggle();
              widget.onQuickSave?.call();
            },
          ),
          SizedBox(height: 12.h),
          _buildQuickActionButton(
            icon: Icons.folder_outlined,
            label: 'المسودات',
            onPressed: () {
              _toggle();
              widget.onViewDrafts?.call();
            },
          ),
          SizedBox(height: 12.h),
          _buildQuickActionButton(
            icon: Icons.bar_chart,
            label: 'الإحصائيات',
            onPressed: () {
              _toggle();
              widget.onShowStatistics?.call();
            },
          ),
          SizedBox(height: 12.h),
        ],

        // الزر الرئيسي
        GestureDetector(
          onLongPress: _toggle,
          child: FloatingActionButton.extended(
            onPressed: () {
              if (_isExpanded) {
                _toggle();
              } else {
                widget.onSaveDraft();
              }
            },
            icon: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.close : Icons.save,
                size: 24.sp,
              ),
            ),
            label: Text(
              _isExpanded ? 'إغلاق' : 'مسودة',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: widget.hasUnsavedChanges ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FloatingActionButton.extended(
        heroTag: null,
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp),
        label: Text(label, style: TextStyle(fontSize: 13.sp)),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}
