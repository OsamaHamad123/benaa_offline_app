import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📊 مؤشر التقدم لكل تبويب
///
/// يعرض شريط تقدم صغير تحت كل تبويب يوضح:
/// - نسبة إكمال الحقول المطلوبة
/// - تغيير اللون بناءً على النسبة (أحمر → أصفر → أخضر)
class TabProgressIndicator extends StatelessWidget {
  final TabController controller;
  final Map<int, double> tabCompletionPercentages;

  const TabProgressIndicator({
    super.key,
    required this.controller,
    required this.tabCompletionPercentages,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          height: 3.h,
          child: Row(
            children: List.generate(
              controller.length,
              (index) {
                final progress = tabCompletionPercentages[index] ?? 0.0;
                final isSelected = controller.index == index;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerRight,
                      widthFactor: progress / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getProgressColor(progress, isSelected),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress, bool isSelected) {
    Color baseColor;

    if (progress >= 100) {
      baseColor = Colors.green;
    } else if (progress >= 50) {
      baseColor = Colors.orange;
    } else {
      baseColor = Colors.red;
    }

    // جعل اللون أغمق إذا كان التبويب محدداً
    return isSelected ? baseColor : baseColor.withOpacity(0.6);
  }
}
