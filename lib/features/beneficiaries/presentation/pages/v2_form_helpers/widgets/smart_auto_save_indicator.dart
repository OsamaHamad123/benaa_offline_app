import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 Smart Auto-Save Indicator with Animations
class SmartAutoSaveIndicator extends StatefulWidget {
  final bool isSaving;
  final DateTime? lastSaved;
  final bool hasUnsavedChanges;

  const SmartAutoSaveIndicator({
    super.key,
    required this.isSaving,
    this.lastSaved,
    this.hasUnsavedChanges = false,
  });

  @override
  State<SmartAutoSaveIndicator> createState() => _SmartAutoSaveIndicatorState();
}

class _SmartAutoSaveIndicatorState extends State<SmartAutoSaveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(SmartAutoSaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSaving != oldWidget.isSaving ||
        widget.lastSaved != oldWidget.lastSaved) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildContent(theme),
          ),
        );
      },
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.isSaving) {
      return _buildSavingIndicator(theme);
    } else if (widget.lastSaved != null) {
      return _buildSavedIndicator(theme);
    } else if (widget.hasUnsavedChanges) {
      return _buildUnsavedIndicator(theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSavingIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'جاري الحفظ...',
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedIndicator(ThemeData theme) {
    final timeSince = _getTimeSinceLastSave(widget.lastSaved!);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14.sp,
            color: Colors.green.shade700,
          ),
          SizedBox(width: 6.w),
          Text(
            timeSince,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedIndicator(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded, size: 14.sp, color: Colors.orange.shade700),
          SizedBox(width: 6.w),
          Text(
            'تعديلات غير محفوظة',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeSinceLastSave(DateTime lastSaved) {
    final diff = DateTime.now().difference(lastSaved);
    if (diff.inSeconds < 10) return 'تم الحفظ الآن';
    if (diff.inSeconds < 60) return 'حُفظ منذ ${diff.inSeconds} ث';
    if (diff.inMinutes < 60) return 'حُفظ منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'حُفظ منذ ${diff.inHours} س';
    return 'حُفظ منذ ${diff.inDays} يوم';
  }
}

/// 📊 Progress Bar for Auto-Save
class AutoSaveProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const AutoSaveProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}
