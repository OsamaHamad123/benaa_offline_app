import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 📊 Report Chart Section with interactive charts
class ReportChartSection extends StatefulWidget {
  const ReportChartSection({super.key});

  @override
  State<ReportChartSection> createState() => _ReportChartSectionState();
}

class _ReportChartSectionState extends State<ReportChartSection> {
  int _selectedCategoryIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التوزيع حسب الفئات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Pie Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildPieChartSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (response?.touchedSection != null) {
                                _selectedCategoryIndex = response!
                                    .touchedSection!
                                    .touchedSectionIndex;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _buildLegend()),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Bar Chart for Geographic Distribution
        const Text(
          'التوزيع الجغرافي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 500,
                  barGroups: _buildBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const governorates = [
                            'دمشق',
                            'حلب',
                            'حمص',
                            'اللاذقية',
                          ];
                          if (value.toInt() < governorates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                governorates[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final categories = [
      ('عائلات', 450, Colors.blue),
      ('أطفال', 320, Colors.green),
      ('مسنين', 180, Colors.orange),
      ('ذوي احتياجات', 284, Colors.purple),
    ];

    return List.generate(categories.length, (index) {
      final isSelected = index == _selectedCategoryIndex;
      final category = categories[index];

      return PieChartSectionData(
        value: category.$2.toDouble(),
        title: '${category.$2}',
        color: category.$3,
        radius: isSelected ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    final categories = [
      ('عائلات', Colors.blue),
      ('أطفال', Colors.green),
      ('مسنين', Colors.orange),
      ('ذوي احتياجات', Colors.purple),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cat.$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(cat.$1, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final data = [450.0, 320.0, 280.0, 184.0];

    return List.generate(
      data.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: Colors.blue.shade700,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}
