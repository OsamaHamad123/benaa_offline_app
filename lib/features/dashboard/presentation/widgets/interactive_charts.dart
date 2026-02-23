import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../theme/app_colors.dart';
import '../utils/dashboard_colors.dart'; // ✅ Dashboard Colors
import '../../domain/entities/dashboard_statistics.dart';

/// 📊 Interactive Dashboard Charts - Enhanced with drill-down
class InteractiveDashboardCharts extends ConsumerStatefulWidget {
  final DashboardStatistics statistics;

  const InteractiveDashboardCharts({required this.statistics, super.key});

  @override
  ConsumerState<InteractiveDashboardCharts> createState() => _InteractiveDashboardChartsState();
}

class _InteractiveDashboardChartsState extends ConsumerState<InteractiveDashboardCharts> {
  int _selectedCategoryIndex = -1;
  int _selectedGrowthIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Distribution Pie Chart
        _buildCategoryChart(),
        const SizedBox(height: 24),

        // Growth Trend Line Chart
        _buildGrowthChart(),
        const SizedBox(height: 24),

        // Export Button
        _buildExportButton(context),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'توزيع المستفيدين حسب الفئة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  onPressed: () => _showChartInfo(context, 'اضغط على أي قطاع لعرض التفاصيل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.touchedSection != null) {
                          _selectedCategoryIndex = response!.touchedSection!.touchedSectionIndex;
                        } else {
                          _selectedCategoryIndex = -1;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            if (_selectedCategoryIndex >= 0) ...[
              const SizedBox(height: 16),
              _buildCategoryDetail(),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final categories = widget.statistics.categoryCounts;
    final total = categories.values.fold<int>(0, (sum, count) => sum + count);

    final colors = [
      DashboardColors.totalBeneficiaries,
      DashboardColors.success,
      DashboardColors.warning,
      DashboardColors.widows,
      DashboardColors.urgent,
      DashboardColors.disabled,
    ];

    return categories.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isSelected = index == _selectedCategoryIndex;

      return PieChartSectionData(
        value: category.value.toDouble(),
        title: '${((category.value / total) * 100).toStringAsFixed(1)}%',
        radius: isSelected ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: AppColors.surface,
        ),
        color: colors[index % colors.length],
      );
    }).toList();
  }

  Widget _buildCategoryDetail() {
    final categories = widget.statistics.categoryCounts.entries.toList();
    final selectedCategory = categories[_selectedCategoryIndex];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.totalBeneficiaries.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.totalBeneficiaries.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCategory.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${selectedCategory.value} مستفيد',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _drillDownToCategory(selectedCategory.key),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('عرض القائمة'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'منحنى النمو (آخر 7 أيام)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(drawVerticalLine: false),
                  titlesData: _buildGrowthTitles(),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildGrowthSpots(),
                      isCurved: true,
                      color: DashboardColors.totalBeneficiaries,
                      barWidth: 3,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: index == _selectedGrowthIndex ? 6 : 4,
                            color: DashboardColors.totalBeneficiaries,
                            strokeWidth: index == _selectedGrowthIndex ? 2 : 0,
                            strokeColor: DashboardColors.cardBg,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: DashboardColors.totalBeneficiaries.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.lineBarSpots?.isNotEmpty ?? false) {
                          _selectedGrowthIndex = response!.lineBarSpots!.first.spotIndex;
                        } else {
                          _selectedGrowthIndex = -1;
                        }
                      });
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = widget.statistics.growthData[spot.spotIndex].date;
                          return LineTooltipItem(
                            '${date.day}/${date.month}\n${spot.y.toInt()} مستفيد',
                            const TextStyle(
                              color: AppColors.surface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildGrowthSpots() {
    return widget.statistics.growthData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();
  }

  FlTitlesData _buildGrowthTitles() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= widget.statistics.growthData.length) {
              return const SizedBox.shrink();
            }
            final date = widget.statistics.growthData[value.toInt()].date;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${date.day}/${date.month}',
                style: const TextStyle(fontSize: 10),
              ),
            );
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
              style: const TextStyle(fontSize: 10),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _exportCharts(context),
      icon: const Icon(Icons.file_download),
      label: const Text('تصدير البيانات'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  void _showChartInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _drillDownToCategory(String category) {
    // TODO: Navigate to beneficiaries list filtered by category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('عرض قائمة $category'),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            // Navigate to filtered list
          },
        ),
      ),
    );
  }

  Future<void> _exportCharts(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Export to Excel
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Export to PDF
              },
            ),
          ],
        ),
      ),
    );
  }
}
