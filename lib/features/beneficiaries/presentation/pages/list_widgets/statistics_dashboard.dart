import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/list/beneficiaries_list_provider.dart';
import '../../../../../../core/design_system/app_animations.dart';

/// 📊 Statistics Dashboard Widget
class StatisticsDashboard extends ConsumerWidget {
  const StatisticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(beneficiariesListProvider);

    // Return simplified version for list page (better performance)
    return _buildCompactStats(context, state);
  }

  Widget _buildCompactStats(BuildContext context, state) {
    return FadeSlideTransition(
      child: Column(
        children: [
          // الإحصائيات الرئيسية
          Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ScaleTransitionWidget(
                    duration: AppDurations.fast,
                    child: _StatCard(
                      icon: Icons.people,
                      label: 'الإجمالي',
                      value: state.totalCount.toString(),
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(width: 1.w, height: 50.h, color: Colors.grey[300]),
                Expanded(
                  child: ScaleTransitionWidget(
                    duration: AppDurations.fast,
                    child: _StatCard(
                      icon: Icons.filter_list,
                      label: 'المعروضة',
                      value: state.items.length.toString(),
                      color: Colors.green,
                    ),
                  ),
                ),
                Container(width: 1.w, height: 50.h, color: Colors.grey[300]),
                Expanded(
                  child: ScaleTransitionWidget(
                    duration: AppDurations.fast,
                    child: _StatCard(
                      icon: Icons.cloud_upload,
                      label: 'قيد المزامنة',
                      value: state.pendingSyncCount.toString(),
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Charts removed for performance - available in dedicated stats page
          // Tap card to view full statistics
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    'اضغط للمزيد من الإحصائيات',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
