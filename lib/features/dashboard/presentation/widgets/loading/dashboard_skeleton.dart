import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/shimmer_loading.dart';
import '../../utils/dashboard_spacing.dart'; // ✅ Dashboard Spacing

/// Dashboard Skeleton - شاشة تحميل متطابقة مع المحتوى الفعلي
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters skeleton
          _buildFiltersRow(),
          SizedBox(height: DashboardSpacing.large),

          // Summary widget skeleton
          _buildSummaryCard(),
          SizedBox(height: DashboardSpacing.large),

          // Quick actions skeleton
          _buildQuickActionsGrid(),
          SizedBox(height: DashboardSpacing.large),

          // Charts skeleton
          _buildChartsSection(),
          SizedBox(height: DashboardSpacing.large),

          // Activities skeleton
          _buildActivitiesList(),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: SkeletonCard(width: 100.w, height: 36.h),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return SkeletonCard(height: 120.h);
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.0,
      children: List.generate(6, (index) => SkeletonCard(height: 100.h)),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        SkeletonCard(height: 200.h),
        SizedBox(height: 12.h),
        SkeletonCard(height: 150.h),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SkeletonCard(width: double.infinity, height: 70.h),
        ),
      ),
    );
  }
}
