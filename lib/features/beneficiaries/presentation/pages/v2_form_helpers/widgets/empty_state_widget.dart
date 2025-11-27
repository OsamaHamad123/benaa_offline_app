import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../beneficiary_form_colors.dart';

/// 📭 Empty State Widget - Enhanced with Animations
///
/// Beautiful empty states for different scenarios with smooth animations

class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final String? emoji;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.emoji,
  });

  /// 👥 Empty Family Members
  factory EmptyStateWidget.noFamilyMembers({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.family_restroom_rounded,
      title: 'لا يوجد أفراد عائلة',
      subtitle: 'ابدأ بإضافة أفراد العائلة\nلإكمال بيانات المستفيد',
      actionText: onAdd != null ? 'إضافة فرد من العائلة' : null,
      onAction: onAdd,
      emoji: '👨‍👩‍👧‍👦',
    );
  }

  /// 📎 Empty Attachments
  factory EmptyStateWidget.noAttachments({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.cloud_upload_rounded,
      title: 'لا توجد مرفقات',
      subtitle: 'أضف المستندات والصور المطلوبة\nمثل الهوية الوطنية، شهادات، صور',
      actionText: onAdd != null ? 'إضافة مرفق' : null,
      onAction: onAdd,
      emoji: '📎',
      iconColor: BeneficiaryFormColors.info,
    );
  }

  /// 🔍 No Search Results
  factory EmptyStateWidget.noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      subtitle: 'جرب استخدام كلمات بحث مختلفة\nأو تحقق من الإملاء',
      iconColor: BeneficiaryFormColors.warning,
      emoji: '🔍',
    );
  }

  /// ⚠️ Error State
  factory EmptyStateWidget.error({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: 'حدث خطأ ما',
      subtitle: message ?? 'عذراً، حدث خطأ غير متوقع\nيرجى المحاولة مرة أخرى',
      actionText: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
      iconColor: BeneficiaryFormColors.error,
      emoji: '⚠️',
    );
  }

  /// 📝 No Notes
  factory EmptyStateWidget.noNotes() {
    return const EmptyStateWidget(
      icon: Icons.sticky_note_2_outlined,
      title: 'لا توجد ملاحظات',
      subtitle: 'يمكنك إضافة ملاحظات إضافية\nأو معلومات خاصة بالمستفيد',
      emoji: '📝',
    );
  }

  /// 💾 No Drafts
  factory EmptyStateWidget.noDrafts() {
    return const EmptyStateWidget(
      icon: Icons.drafts_outlined,
      title: 'لا توجد مسودات محفوظة',
      subtitle: 'المسودات التي تحفظها ستظهر هنا',
      emoji: '💾',
    );
  }

  /// 🎯 Getting Started
  factory EmptyStateWidget.gettingStarted({VoidCallback? onStart}) {
    return EmptyStateWidget(
      icon: Icons.rocket_launch_rounded,
      title: 'مرحباً بك!',
      subtitle: 'ابدأ بإضافة أول مستفيد\nوملء البيانات المطلوبة',
      actionText: onStart != null ? 'البدء الآن' : null,
      onAction: onStart,
      emoji: '🚀',
      iconColor: BeneficiaryFormColors.success,
    );
  }

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with Scale Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          (widget.iconColor ?? theme.colorScheme.primary).withOpacity(0.15),
                          (widget.iconColor ?? theme.colorScheme.primary).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.iconColor ?? theme.colorScheme.primary).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 72.sp,
                      color: widget.iconColor ?? theme.colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Emoji (if provided)
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: TextStyle(fontSize: 48.sp)),
                  SizedBox(height: 16.h),
                ],

                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Subtitle
                if (widget.subtitle != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Action Button with Animation
                if (widget.actionText != null && widget.onAction != null) ...[
                  SizedBox(height: 32.h),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FilledButton.icon(
                      onPressed: widget.onAction,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        widget.actionText!,
                        style: TextStyle(fontSize: 15.sp),
                      ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 16.h,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
