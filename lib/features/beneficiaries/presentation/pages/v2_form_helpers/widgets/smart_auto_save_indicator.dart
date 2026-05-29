import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💾 Smart Auto-Save Indicator with Animations
class SmartAutoSaveIndicator extends StatefulWidget {
  final bool isSaving;
  final DateTime? lastSaved;
  final bool hasUnsavedChanges;

  const SmartAutoSaveIndicator({
    required this.isSaving,
    super.key,
    this.lastSaved,
    this.hasUnsavedChanges = false,
  });

  @override
  State<SmartAutoSaveIndicator> createState() => _SmartAutoSaveIndicatorState();
}

class _SmartAutoSaveIndicatorState extends State<SmartAutoSaveIndicator> with SingleTickerProviderStateMixin {
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
    if (widget.isSaving != oldWidget.isSaving || widget.lastSaved != oldWidget.lastSaved) {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12.w,
          height: 12.h,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          'حفظ...',
          style: TextStyle(
            fontSize: 11.sp,
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedIndicator(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_done_rounded,
          size: 13.sp,
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
        SizedBox(width: 4.w),
        Text(
          _getTimeSinceLastSave(widget.lastSaved!),
          style: TextStyle(
            fontSize: 11.sp,
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildUnsavedIndicator(ThemeData theme) {
    return Icon(
      Icons.edit_rounded,
      size: 14.sp,
      color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
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

  const AutoSaveProgressBar({required this.progress, super.key});

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
