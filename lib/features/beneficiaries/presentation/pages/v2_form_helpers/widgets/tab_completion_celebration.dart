import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../beneficiary_form_colors.dart';

/// 🎉 Tab Completion Celebration
///
/// عرض احتفال عند إتمام التاب بنسبة 100%
class TabCompletionCelebration {
  static final Map<int, bool> _celebratedTabs = {};

  /// إظهار احتفال لإتمام التاب
  static void show(
    BuildContext context, {
    required int tabIndex,
    required String tabTitle,
  }) {
    // تحقق إذا تم الاحتفال بهذا التاب من قبل
    if (_celebratedTabs[tabIndex] == true) return;

    // سجل أن هذا التاب تم الاحتفال به
    _celebratedTabs[tabIndex] = true;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // عرض SnackBar احتفالي
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 رائع! تم إكمال "$tabTitle"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تم إدخال جميع البيانات المطلوبة ✓',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: BeneficiaryFormColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
        action: SnackBarAction(
          label: 'التالي',
          textColor: Colors.white,
          onPressed: () {
            // سيتم ربطه بالتاب التالي
          },
        ),
      ),
    );

    // تأثير بصري خفيف (اختياري)
    _showConfettiEffect(context);
  }

  /// إعادة تعيين حالة الاحتفالات (عند فتح نموذج جديد)
  static void reset() {
    _celebratedTabs.clear();
  }

  /// تحقق إذا تم الاحتفال بهذا التاب
  static bool hasCelebrated(int tabIndex) {
    return _celebratedTabs[tabIndex] == true;
  }

  /// تأثير confetti خفيف
  static void _showConfettiEffect(BuildContext context) {
    // يمكن إضافة confetti animation لاحقاً
    // الآن نستخدم dialog بسيط وسريع

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(builder: (context) => _ConfettiOverlay());

    overlay.insert(overlayEntry);

    // إزالة بعد 2 ثانية
    Future.delayed(const Duration(milliseconds: 2000), () {
      overlayEntry.remove();
    });
  }
}

/// 🎊 Confetti Overlay Widget
class _ConfettiOverlay extends StatefulWidget {
  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: BeneficiaryFormColors.success.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BeneficiaryFormColors.success.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Progress Celebration Dialog (عند إكمال جميع التابات)
class AllTabsCompleteCelebration {
  static void show(BuildContext context) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AllTabsCompleteDialog(),
    );
  }
}

class _AllTabsCompleteDialog extends StatefulWidget {
  @override
  State<_AllTabsCompleteDialog> createState() => _AllTabsCompleteDialogState();
}

class _AllTabsCompleteDialogState extends State<_AllTabsCompleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: BeneficiaryFormColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            SizedBox(height: 24.h),
            const Text(
              'تم إكمال جميع البيانات!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'تم إدخال جميع المعلومات المطلوبة بنجاح.\nيمكنك الآن حفظ النموذج.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('مراجعة'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // سيتم ربطه بزر الحفظ
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('حفظ الآن'),
                  style: FilledButton.styleFrom(
                    backgroundColor: BeneficiaryFormColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
