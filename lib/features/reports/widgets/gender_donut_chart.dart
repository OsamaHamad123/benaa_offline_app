/// Gender Donut Chart Widget
/// Reusable widget for displaying gender distribution as donut chart
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../domain/entities/report_data.dart';
import '../../../core/constants/category_colors.dart';

class GenderDonutChart extends StatefulWidget {
  final List<GenderCount> data;
  final int total;

  const GenderDonutChart({super.key, required this.data, required this.total});

  @override
  State<GenderDonutChart> createState() => _GenderDonutChartState();
}

class _GenderDonutChartState extends State<GenderDonutChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Responsive aspect ratio based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final aspectRatio = isTablet ? 1.5 : 1.2;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: isTablet ? 70.r : 45.r,
              sections: _getSections(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 600),
            swapAnimationCurve: Curves.easeInOutCubic,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.total.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 28.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'إجمالي',
                  style: TextStyle(
                    fontSize: isTablet ? 13.sp : 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;

      // Responsive sizes based on device type
      final fontSize = isTouched
          ? (isTablet ? 18.0.sp : 14.0.sp)
          : (isTablet ? 14.0.sp : 12.0.sp);
      final radius = isTouched
          ? (isTablet ? 70.0.r : 50.0.r)
          : (isTablet ? 60.0.r : 45.0.r);

      final percentage = widget.total == 0
          ? 0.0
          : (item.count / widget.total) * 100;

      final color = GenderColors.getColor(item.gender);

      return PieChartSectionData(
        color: color,
        value: item.count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
