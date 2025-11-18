/// Category Pie Chart Widget
/// Reusable widget for displaying category distribution as pie chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../domain/entities/report_data.dart';
import '../../../core/constants/category_colors.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryCount> data;
  final int total;

  const CategoryPieChart({super.key, required this.data, required this.total});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Responsive aspect ratio based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final aspectRatio = isTablet ? 1.4 : 1.1;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Row(
        children: [
          Expanded(
            flex: isTablet ? 2 : 3,
            child: PieChart(
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
                sectionsSpace: 1,
                centerSpaceRadius: isTablet ? 50.r : 30.r,
                sections: _getSections(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
          SizedBox(width: isTablet ? 16.w : 8.w),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.asMap().entries.map((entry) {
                final item = entry.value;
                final color = _getColor(item.category);
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isTablet ? 14.w : 10.w,
                        height: isTablet ? 14.w : 10.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          item.category,
                          style: TextStyle(fontSize: isTablet ? 11.sp : 9.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
          ? (isTablet ? 16.0.sp : 11.0.sp)
          : (isTablet ? 12.0.sp : 9.0.sp);
      final radius = isTouched
          ? (isTablet ? 90.0.r : 65.0.r)
          : (isTablet ? 80.0.r : 60.0.r);
      final widgetSize = isTouched
          ? (isTablet ? 45.0.r : 32.0.r)
          : (isTablet ? 35.0.r : 26.0.r);

      final percentage = widget.total == 0
          ? 0.0
          : (item.count / widget.total) * 100;

      return PieChartSectionData(
        color: _getColor(item.category),
        value: item.count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _Badge(
          item.count.toString(),
          size: widgetSize,
          borderColor: _getColor(item.category),
          isTablet: isTablet,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  Color _getColor(String category) {
    return CategoryColors.getColorByName(category);
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;
  final bool isTablet;

  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isTablet ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            offset: Offset(isTablet ? 2 : 1.5, isTablet ? 2 : 1.5),
            blurRadius: isTablet ? 3 : 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 4.r : 2.r),
      child: Center(
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
