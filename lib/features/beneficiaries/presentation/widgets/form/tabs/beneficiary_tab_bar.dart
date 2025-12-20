import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'tab_progress_indicator.dart';

/// 📑 TabBar مخصص لنموذج المستفيدين
///
/// يعرض 4 تبويبات مع:
/// - مؤشر التقدم لكل تبويب
/// - أيقونات مخصصة
/// - عداد للأخطاء
class BeneficiaryTabBar extends StatelessWidget {
  final TabController controller;
  final Map<int, int> tabErrorCounts;
  final Map<int, double> tabCompletionPercentages;

  const BeneficiaryTabBar({
    super.key,
    required this.controller,
    required this.tabErrorCounts,
    required this.tabCompletionPercentages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _getTabs().asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final errorCount = tabErrorCounts[index] ?? 0;
              final completionPercentage = tabCompletionPercentages[index] ?? 0.0;

              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة التبويب
                    Icon(tab.icon, size: 20.sp),

                    SizedBox(width: 8.w),

                    // عنوان التبويب
                    Text(
                      tab.label,
                      style: TextStyle(fontSize: 14.sp),
                    ),

                    // عداد الأخطاء
                    if (errorCount > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$errorCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // أيقونة الاكتمال
                    if (errorCount == 0 && completionPercentage >= 100) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.check_circle,
                        size: 16.sp,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          // مؤشر التقدم لكل تبويب
          TabProgressIndicator(
            controller: controller,
            tabCompletionPercentages: tabCompletionPercentages,
          ),
        ],
      ),
    );
  }

  List<({IconData icon, String label})> _getTabs() {
    return [
      (icon: Icons.person, label: 'البيانات الأساسية'),
      (icon: Icons.family_restroom, label: 'أفراد الأسرة'),
      (icon: Icons.attach_file, label: 'المرفقات'),
      (icon: Icons.assessment, label: 'التقييم'),
    ];
  }
}
