import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/shimmer_loading.dart';

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
          SizedBox(height: 24.h),

          // Summary widget skeleton
          _buildSummaryCard(),
          SizedBox(height: 24.h),

          // Quick actions skeleton
          _buildQuickActionsGrid(),
          SizedBox(height: 24.h),

          // Charts skeleton
          _buildChartsSection(),
          SizedBox(height: 24.h),

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
            child: SkeletonCard(
              width: 100.w,
              height: 36.h,
              borderRadius: 18.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return SkeletonCard(
      width: double.infinity,
      height: 120.h,
      borderRadius: 16.r,
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.0,
      children: List.generate(
        6,
        (index) => SkeletonCard(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 16.r,
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        SkeletonCard(
          width: double.infinity,
          height: 200.h,
          borderRadius: 16.r,
        ),
        SizedBox(height: 12.h),
        SkeletonCard(
          width: double.infinity,
          height: 150.h,
          borderRadius: 16.r,
        ),
      ],
    );
  }

  Widget _buildActivitiesList() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: SkeletonCard(
            width: double.infinity,
            height: 70.h,
            borderRadius: 12.r,
          ),
        ),
      ),
    );
  }
}
