import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/list/beneficiaries_list_provider.dart';
import '../../../../../../core/widgets/charts.dart';
import '../../../../../../core/widgets/micro_interactions.dart';

/// 📊 Statistics Dashboard Widget
class StatisticsDashboard extends ConsumerWidget {
  const StatisticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(beneficiariesListProvider);

    return Column(
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
                child: MicroInteractions.bounceButton(
                  onTap: null,
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
                child: MicroInteractions.bounceButton(
                  onTap: null,
                  child: _StatCard(
                    icon: Icons.list,
                    label: 'المعروض',
                    value: state.items.length.toString(),
                    color: Colors.green,
                  ),
                ),
              ),
              Container(width: 1.w, height: 50.h, color: Colors.grey[300]),
              Expanded(
                child: MicroInteractions.bounceButton(
                  onTap: null,
                  child: _StatCard(
                    icon: Icons.cloud_off,
                    label: 'معلق',
                    value: state.pendingSyncCount.toString(),
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Mini Sparkline Charts
        if (state.items.length > 5)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Row(
              children: [
                Expanded(
                  child: MiniSparklineCard(
                    title: 'المعروض',
                    value: '${state.items.length}',
                    data: [
                      state.totalCount * 0.6,
                      state.totalCount * 0.7,
                      state.totalCount * 0.75,
                      state.totalCount * 0.85,
                      state.totalCount * 0.9,
                      state.items.length.toDouble(),
                    ],
                    color: Colors.green,
                    isPositive: true,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: MiniSparklineCard(
                    title: 'معلق',
                    value: '${state.pendingSyncCount}',
                    data: [
                      state.pendingSyncCount * 1.5,
                      state.pendingSyncCount * 1.3,
                      state.pendingSyncCount * 1.2,
                      state.pendingSyncCount * 1.1,
                      state.pendingSyncCount * 1.05,
                      state.pendingSyncCount.toDouble(),
                    ],
                    color: Colors.orange,
                    isPositive: state.pendingSyncCount < 10,
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 8.h),
      ],
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
