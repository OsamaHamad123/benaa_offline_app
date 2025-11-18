/// Gender Donut Chart Widget
/// Reusable widget for displaying gender distribution as donut chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
    return AspectRatio(
      aspectRatio: 1.3,
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
              sectionsSpace: 4,
              centerSpaceRadius: 60,
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
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'إجمالي',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 22.0 : 16.0;
      final radius = isTouched ? 80.0 : 70.0;

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
