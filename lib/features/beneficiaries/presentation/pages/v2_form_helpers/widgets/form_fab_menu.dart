import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎯 Floating Action Button Menu
///
/// Quick actions: Save Draft, Preview, Export
class FormFabMenu extends StatefulWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onPreview;
  final VoidCallback? onExport;
  final bool isDraftAvailable;

  const FormFabMenu({
    required this.onSaveDraft, required this.onPreview, super.key,
    this.onExport,
    this.isDraftAvailable = true,
  });

  @override
  State<FormFabMenu> createState() => _FormFabMenuState();
}

class _FormFabMenuState extends State<FormFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Backdrop
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(color: Colors.transparent),
          ),

        // Menu Items
        ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Preview Button
              _buildMenuItem(
                label: 'مراجعة',
                icon: Icons.preview_rounded,
                color: theme.colorScheme.secondary,
                onPressed: () {
                  _toggleMenu();
                  widget.onPreview();
                },
              ),

              SizedBox(height: 12.h),

              // Save Draft Button
              if (widget.isDraftAvailable)
                _buildMenuItem(
                  label: 'حفظ مسودة',
                  icon: Icons.drafts_rounded,
                  color: theme.colorScheme.tertiary,
                  onPressed: () {
                    _toggleMenu();
                    widget.onSaveDraft();
                  },
                ),

              if (widget.isDraftAvailable) SizedBox(height: 12.h),

              // Export Button (if available)
              if (widget.onExport != null)
                _buildMenuItem(
                  label: 'تصدير',
                  icon: Icons.upload_file_rounded,
                  color: Colors.orange,
                  onPressed: () {
                    _toggleMenu();
                    widget.onExport!();
                  },
                ),

              if (widget.onExport != null) SizedBox(height: 12.h),
            ],
          ),
        ),

        // Main FAB - 🔥 أكبر وأوضح
        FloatingActionButton.extended(
          onPressed: _toggleMenu,
          backgroundColor: _isExpanded
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _isExpanded ? Icons.close_rounded : Icons.menu_rounded,
              color: _isExpanded
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
              size: 24.sp,
            ),
          ),
          label: Text(
            _isExpanded ? 'إغلاق' : 'خيارات',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: _isExpanded
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // Button
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ],
    );
  }
}
