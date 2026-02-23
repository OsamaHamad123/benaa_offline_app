import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../theme/app_colors.dart';

/// Growth Chart - Line Chart لنمو عدد المستفيدين
class BeneficiariesGrowthChart extends ConsumerWidget {
  const BeneficiariesGrowthChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'نمو عدد المستفيدين',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<int>(
              future: database.beneficiariesDao.countBeneficiaries(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final total = snapshot.data!;

                // Empty State
                if (total == 0) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد بيانات لعرضها',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بإضافة مستفيدين لعرض الإحصائيات',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          
                        ),
                        topTitles: const AxisTitles(
                          
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'يناير',
                                'فبراير',
                                'مارس',
                                'أبريل',
                                'مايو',
                                'يونيو',
                              ];
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: (total + 20).toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getGrowthData(total),
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: AppColors.primary,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.secondary.withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getGrowthData(int total) {
    // محاكاة بيانات النمو (في التطبيق الحقيقي يتم جلبها من قاعدة البيانات)
    final step = total / 6;
    return [
      FlSpot(0, step * 1),
      FlSpot(1, step * 2),
      FlSpot(2, step * 3.5),
      FlSpot(3, step * 4),
      FlSpot(4, step * 5),
      FlSpot(5, total.toDouble()),
    ];
  }
}

/// Category Distribution Pie Chart
class CategoryDistributionChart extends ConsumerWidget {
  const CategoryDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'توزيع المستفيدين حسب الفئة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<int>>(
              future: Future.wait([
                database.beneficiariesDao.countBeneficiariesByCategory(
                  1, // orphan
                ),
                database.beneficiariesDao.countBeneficiariesByCategory(
                  3,
                ), // widow
                database.beneficiariesDao.countBeneficiariesByCategory(
                  2,
                ), // poor
                database.beneficiariesDao.countBeneficiariesByCategory(
                  4, // disabled
                ),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = snapshot.data!;
                final total = data.reduce((a, b) => a + b);

                // Empty State
                if (total == 0) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد بيانات لعرضها',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بإضافة مستفيدين لعرض التوزيع',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: _getPieChartSections(data, total),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(data, total),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(List<int> data, int total) {
    final colors = [Colors.purple, Colors.pink, Colors.teal, Colors.amber];

    return List.generate(data.length, (index) {
      final percentage = (data[index] / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: colors[index],
        value: data[index].toDouble(),
        title: '$percentage%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(List<int> data, int total) {
    final items = [
      {'label': 'أيتام', 'color': Colors.purple, 'count': data[0]},
      {'label': 'أرامل', 'color': Colors.pink, 'count': data[1]},
      {'label': 'فقراء', 'color': Colors.teal, 'count': data[2]},
      {'label': 'معاقين', 'color': Colors.amber, 'count': data[3]},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item['label']}: ${item['count']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
