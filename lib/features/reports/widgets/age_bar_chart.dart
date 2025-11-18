/// Age Bar Chart Widget
/// Reusable widget for displaying age bracket distribution as bar chart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/entities/report_data.dart';
import '../../../core/constants/category_colors.dart';

class AgeBarChart extends StatefulWidget {
  final List<AgeCount> data;

  const AgeBarChart({super.key, required this.data});

  @override
  State<AgeBarChart> createState() => _AgeBarChartState();
}

class _AgeBarChartState extends State<AgeBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = widget.data[groupIndex];
                  return BarTooltipItem(
                    '${item.ageBracket} سنة\n${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                });
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
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= widget.data.length) {
                      return const SizedBox();
                    }
                    final item = widget.data[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        item.ageBracket,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _getBarGroups(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 600),
          swapAnimationCurve: Curves.easeInOutCubic,
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.count.toDouble(),
            gradient: _getGradient(item.ageBracket, isTouched),
            width: isTouched ? 24 : 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue().toDouble(),
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }

  LinearGradient _getGradient(String ageBracket, bool isTouched) {
    final baseColor = _getColor(ageBracket);
    final intensity = isTouched ? 1.0 : 0.8;

    return LinearGradient(
      colors: [
        baseColor.withOpacity(intensity),
        baseColor.withOpacity(intensity * 0.7),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  Color _getColor(String ageBracket) {
    return AgeBracketColors.getColor(ageBracket);
  }

  int _getMaxValue() {
    if (widget.data.isEmpty) return 100;
    return widget.data.map((e) => e.count).reduce((a, b) => a > b ? a : b);
  }

  double _calculateInterval() {
    final maxValue = _getMaxValue();
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    return 200;
  }
}
