import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/haptic_patterns.dart';

/// 🎯 Quick Actions Floating Action Button
class QuickActionsFab extends StatefulWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onQuickSearch;
  final VoidCallback? onVoiceInput;

  const QuickActionsFab({
    super.key,
    this.onCapture,
    this.onSaveDraft,
    this.onCopy,
    this.onPaste,
    this.onQuickSearch,
    this.onVoiceInput,
  });

  @override
  State<QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<QuickActionsFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        HapticPatterns.selection();
      } else {
        _controller.reverse();
        HapticPatterns.light();
      }
    });
  }

  void _handleAction(VoidCallback? action) {
    if (action != null) {
      HapticPatterns.light();
      action();
      _toggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Quick Actions
        if (_isExpanded) ...[
          _buildQuickAction(
            icon: Icons.camera_alt_rounded,
            label: 'التقاط صورة',
            color: Colors.blue,
            onTap: () => _handleAction(widget.onCapture),
          ),
          SizedBox(height: 12.h),
          _buildQuickAction(
            icon: Icons.drafts_rounded,
            label: 'حفظ كمسودة',
            color: Colors.orange,
            onTap: () => _handleAction(widget.onSaveDraft),
          ),
          SizedBox(height: 12.h),
          _buildQuickAction(
            icon: Icons.copy_rounded,
            label: 'نسخ معلومات',
            color: Colors.purple,
            onTap: () => _handleAction(widget.onCopy),
          ),
          SizedBox(height: 12.h),
          _buildQuickAction(
            icon: Icons.paste_rounded,
            label: 'لصق معلومات',
            color: Colors.teal,
            onTap: () => _handleAction(widget.onPaste),
          ),
          SizedBox(height: 12.h),
          _buildQuickAction(
            icon: Icons.search_rounded,
            label: 'بحث سريع',
            color: Colors.green,
            onTap: () => _handleAction(widget.onQuickSearch),
          ),
          SizedBox(height: 12.h),
          _buildQuickAction(
            icon: Icons.mic_rounded,
            label: 'إدخال صوتي',
            color: Colors.red,
            onTap: () => _handleAction(widget.onVoiceInput),
          ),
          SizedBox(height: 16.h),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: theme.colorScheme.primary,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Icon(
              _isExpanded ? Icons.close_rounded : Icons.more_horiz_rounded,
              size: 28.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            FloatingActionButton.small(
              heroTag: label,
              onPressed: onTap,
              backgroundColor: color,
              child: Icon(icon, size: 22.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📋 Quick Actions Bottom Sheet
class QuickActionsSheet extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsSheet({required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'الإجراءات السريعة',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionTile(context, action);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, QuickAction action) {
    return InkWell(
      onTap: () {
        HapticPatterns.light();
        Navigator.pop(context);
        action.onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 32.sp, color: action.color),
            SizedBox(height: 8.h),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
