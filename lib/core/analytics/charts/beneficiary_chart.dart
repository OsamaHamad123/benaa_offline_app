import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 📊 Beneficiary Chart Widget
/// رسم بياني للمستفيدين

class BeneficiaryChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;
  final bool showVisits;

  const BeneficiaryChart({
    required this.monthlyData, super.key,
    this.showVisits = false,
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
              showVisits ? 'الزيارات الشهرية' : 'المستفيدون الجدد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                _buildChartData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spots = monthlyData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              (showVisits ? entry.value['visits'] : entry.value['beneficiaries']).toDouble(),
            ))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                final monthName = monthlyData[value.toInt()]['monthName'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    monthName.toString().substring(0, 3),
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
            interval: 10,
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
          
        ),
        rightTitles: const AxisTitles(
          
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: showVisits ? colorScheme.tertiary : colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: showVisits ? colorScheme.tertiary : colorScheme.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: (showVisits ? colorScheme.tertiary : colorScheme.primary).withOpacity(0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final monthName = monthlyData[spot.x.toInt()]['monthName'];
              return LineTooltipItem(
                '$monthName\n${spot.y.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
