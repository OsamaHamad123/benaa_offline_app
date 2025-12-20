import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/dashboard_providers.dart';
import '../providers.dart'; // ✅ Import topGovernoratesProvider

/// Provider for geographic distribution
final geographicDistributionMapProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final rawData = await ref.watch(geographicDistributionProvider.future);
  // Convert Map<int, int> to Map<String, int> with province names
  return rawData.map((key, value) => MapEntry(_getProvinceName(key), value));
});

String _getProvinceName(int provinceId) {
  const provinceNames = {
    1: 'بغداد',
    2: 'نينوى',
    3: 'البصرة',
    4: 'ذي قار',
    5: 'ميسان',
    6: 'واسط',
    7: 'القادسية',
    8: 'المثنى',
    9: 'بابل',
    10: 'كربلاء',
    11: 'النجف',
    12: 'الأنبار',
    13: 'ديالى',
    14: 'صلاح الدين',
    15: 'كركوك',
    16: 'أربيل',
    17: 'السليمانية',
    18: 'دهوك',
  };
  return provinceNames[provinceId] ?? 'غير محدد';
}

/// Geographic Distribution Section - توزيع المستفيدين حسب المحافظة
class GeographicDistributionSection extends ConsumerWidget {
  const GeographicDistributionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributionAsync = ref.watch(geographicDistributionMapProvider);

    return distributionAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return _buildEmptyState();
        }

        // ✅ استخدام Provider للحسابات
        final topGovernorates = ref.watch(topGovernoratesProvider(data));
        final maxCount = topGovernorates.isNotEmpty ? topGovernorates.first.value : 0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: AppColors.info.withOpacity(0.3), width: 1),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.info.withOpacity(0.05),
                  AppColors.infoLight.withOpacity(0.05),
                ],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        color: AppColors.info,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التوزيع الجغرافي',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${data.length} محافظة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.length > 5)
                      TextButton(
                        onPressed: () => _showAllGovernorates(context, data.entries.toList()),
                        child: Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Top Governorates Bars
                ...topGovernorates.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _GovernorateBar(
                      governorate: entry.key,
                      count: entry.value,
                      maxCount: maxCount,
                      color: _getGovernorateColor(entry.key),
                    ),
                  ),
                ),

                if (data.length > 5) ...[
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'و ${data.length - 5} محافظات أخرى',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => _buildSkeletonLoader(),
      error: (error, stack) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text('خطأ: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.divider.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.map_outlined,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد بيانات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'لم يتم إضافة مستفيدين بعد',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGovernorateColor(String governorate) {
    // Assign colors based on governorate name hash for consistency
    final colors = [
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.orphan,
      AppColors.secondary,
      AppColors.widow,
      AppColors.primaryDark,
      AppColors.warningLight,
      AppColors.infoLight,
      AppColors.poor,
    ];

    final index = governorate.hashCode.abs() % colors.length;
    return colors[index];
  }

  void _showAllGovernorates(
    BuildContext context,
    List<MapEntry<String, int>> entries,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: 'جميع المحافظات (عدد ${entries.length})',
        icon: Icons.location_city,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (scrollController) {
          final maxCount = entries.first.value;

          return ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: entries.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _GovernorateBar(
                governorate: entry.key,
                count: entry.value,
                maxCount: maxCount,
                color: _getGovernorateColor(entry.key),
                showPercentage: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
              5,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Governorate Bar Widget - شريط المحافظة
class _GovernorateBar extends StatelessWidget {
  final String governorate;
  final int count;
  final int maxCount;
  final Color color;
  final bool showPercentage;

  const _GovernorateBar({
    required this.governorate,
    required this.count,
    required this.maxCount,
    required this.color,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxCount > 0 ? (count / maxCount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                governorate,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Row(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (showPercentage) ...[
                  SizedBox(width: 4.w),
                  Text(
                    '(${(percentage * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 6.h),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8.h,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
