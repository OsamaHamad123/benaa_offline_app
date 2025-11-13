import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/providers.dart';

/// Geographic Distribution Section - توزيع المستفيدين حسب المحافظة
class GeographicDistributionSection extends ConsumerWidget {
  const GeographicDistributionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<Map<String, int>>(
      future: database.beneficiariesDao.getBeneficiariesCountByGovernorate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return _buildEmptyState();
        }

        // Get top 5 governorates
        final entries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topGovernorates = entries.take(5).toList();
        final maxCount = topGovernorates.first.value;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.05),
                  Colors.cyan.withOpacity(0.05),
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
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        color: Colors.blue,
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
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${data.length} محافظة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.length > 5)
                      TextButton(
                        onPressed: () => _showAllGovernorates(context, entries),
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
                        color: Colors.grey[600],
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
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 12.h),
            Text(
              'لا توجد بيانات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'لم يتم إضافة مستفيدين بعد',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGovernorateColor(String governorate) {
    // Assign colors based on governorate name hash for consistency
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final maxCount = entries.first.value;

          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'جميع المحافظات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: ListView.separated(
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
                ),
              ),
            ],
          );
        },
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
