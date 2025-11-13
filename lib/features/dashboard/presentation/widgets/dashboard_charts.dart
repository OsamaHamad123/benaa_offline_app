import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/dashboard_statistics.dart';

/// Growth Chart - Clean Architecture Version
/// Takes GrowthDataPoint list from domain entity
class GrowthChart extends StatelessWidget {
  final List<GrowthDataPoint> growthData;

  const GrowthChart({super.key, required this.growthData});

  @override
  Widget build(BuildContext context) {
    if (growthData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نمو المستفيدين (آخر 7 أيام)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 200.h,
                tablet: 250.h,
                desktop: 300.h,
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < growthData.length) {
                            final date = growthData[value.toInt()].date;
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (growthData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: growthData
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.count.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
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

  double _getMaxY() {
    if (growthData.isEmpty) return 10;
    final maxCount = growthData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);
    return (maxCount + 2).toDouble();
  }
}

/// Category Distribution Chart - Clean Architecture Version
/// Takes categoryCounts map from domain entity
class CategoryDistributionChart extends StatelessWidget {
  final Map<String, int> categoryCounts;

  const CategoryDistributionChart({super.key, required this.categoryCounts});

  @override
  Widget build(BuildContext context) {
    if (categoryCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع الفئات',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: ResponsiveUtils.getResponsiveValue(
                context,
                mobile: 200.h,
                tablet: 250.h,
                desktop: 300.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(total),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40.r,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLegend(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(int total) {
    final colors = {
      'orphan': Colors.purple,
      'widow': Colors.pink,
      'poor': Colors.green,
      'disabled': Colors.orange,
    };

    return categoryCounts.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[entry.key] ?? Colors.grey,
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    final labels = {
      'orphan': 'أيتام',
      'widow': 'أرامل',
      'poor': 'فقراء',
      'disabled': 'ذوي إعاقة',
    };

    final colors = {
      'orphan': Colors.purple,
      'widow': Colors.pink,
      'poor': Colors.green,
      'disabled': Colors.orange,
    };

    return categoryCounts.entries.map((entry) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: colors[entry.key] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${labels[entry.key] ?? entry.key}: ${entry.value}',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
