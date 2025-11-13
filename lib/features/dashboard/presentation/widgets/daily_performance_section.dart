import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/providers.dart';

/// Daily Performance Section - مؤشر الأداء اليومي
class DailyPerformanceSection extends ConsumerWidget {
  const DailyPerformanceSection({super.key});

  // Daily target for visits (can be made configurable)
  static const int dailyTarget = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadPerformanceData(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final visitsToday = data['visitsToday'] as int;
        final newBeneficiariesToday = data['newBeneficiariesToday'] as int;
        final avgVisitsPerDay = data['avgVisitsPerDay'] as double;

        final percentage = (visitsToday / dailyTarget).clamp(0.0, 1.0);
        final isTargetMet = visitsToday >= dailyTarget;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isTargetMet
                  ? Colors.green.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isTargetMet
                    ? [
                        Colors.green.withOpacity(0.05),
                        Colors.lightGreen.withOpacity(0.05),
                      ]
                    : [
                        Colors.blue.withOpacity(0.05),
                        Colors.cyan.withOpacity(0.05),
                      ],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: isTargetMet
                                ? Colors.green.withOpacity(0.15)
                                : Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            isTargetMet
                                ? Icons.check_circle
                                : Icons.trending_up,
                            color: isTargetMet ? Colors.green : Colors.blue,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الأداء اليومي',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              isTargetMet ? 'تم تحقيق الهدف! 🎉' : 'في التقدم',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isTargetMet
                                    ? Colors.green[600]
                                    : Colors.grey[600],
                                fontWeight: isTargetMet
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Circular Progress Indicator
                SizedBox(
                  height: 160.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Circle
                      SizedBox(
                        width: 140.w,
                        height: 140.w,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 12.w,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.withOpacity(0.15),
                          ),
                        ),
                      ),
                      // Progress Circle
                      SizedBox(
                        width: 140.w,
                        height: 140.w,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(begin: 0, end: percentage),
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12.w,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isTargetMet ? Colors.green : Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                      // Center Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$visitsToday',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: isTargetMet ? Colors.green : Colors.blue,
                            ),
                          ),
                          Text(
                            'من $dailyTarget',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'زيارة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Additional Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.person_add,
                        label: 'مستفيدين جدد',
                        value: '$newBeneficiariesToday',
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.show_chart,
                        label: 'المتوسط (7 أيام)',
                        value: avgVisitsPerDay.toStringAsFixed(1),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                if (visitsToday < dailyTarget) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18.sp,
                          color: Colors.amber[700],
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'باقي ${dailyTarget - visitsToday} زيارة لتحقيق الهدف اليومي',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadPerformanceData(database) async {
    final visitsToday = await database.countVisitsToday();
    final newBeneficiariesToday = await database.countNewBeneficiariesToday();
    final avgVisitsPerDay = await database.getAverageVisitsPerDay(7);

    return {
      'visitsToday': visitsToday,
      'newBeneficiariesToday': newBeneficiariesToday,
      'avgVisitsPerDay': avgVisitsPerDay,
    };
  }
}

/// Stat Item Widget for Additional Stats
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
