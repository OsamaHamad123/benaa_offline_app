import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 📊 Bar Chart Widget
/// رسم بياني بالأعمدة

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                _buildChartData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _getMaxY(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final value = rod.toY.toInt();
            final label = data[groupIndex]['label'] ?? '';
            return BarTooltipItem(
              '$label\n$value',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data[value.toInt()]['label'] ?? '',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
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
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      barGroups: _buildBarGroups(context),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getMaxY() / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = (entry.value['value'] ?? 0) as num;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: colorScheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (data.isEmpty) return 10;

    final maxValue = data.map((e) => (e['value'] ?? 0) as num).reduce((a, b) => a > b ? a : b).toDouble();

    // Round up to nearest 10
    return ((maxValue / 10).ceil() * 10).toDouble() + 10;
  }
}
