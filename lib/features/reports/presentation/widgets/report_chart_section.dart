import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// 📊 Report Chart Section with interactive charts
class ReportChartSection extends ConsumerStatefulWidget {
  const ReportChartSection({super.key});

  @override
  ConsumerState<ReportChartSection> createState() => _ReportChartSectionState();
}

class _ReportChartSectionState extends ConsumerState<ReportChartSection> {
  int _selectedCategoryIndex = -1;

  @override
  Widget build(BuildContext context) {
    final governoratesAsync = ref.watch(bridgeGovernoratesProvider);
    final governorateLabels = governoratesAsync.maybeWhen(
      data: (items) => items.map((item) => item.label).toList(growable: false),
      orElse: () => const <String>[],
    );
    final categoryTaxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final categoryTaxonomies = categoryTaxonomiesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );
    final chartCategories = _buildCategoryItems(categoryTaxonomies);

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
                        sections: _buildPieChartSections(chartCategories),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (response?.touchedSection != null) {
                                _selectedCategoryIndex = response!.touchedSection!.touchedSectionIndex;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _buildLegend(chartCategories)),
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final governorates = governorateLabels.isEmpty
                              ? const ['منطقة 1', 'منطقة 2', 'منطقة 3', 'منطقة 4']
                              : governorateLabels.take(4).toList(growable: false);

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
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<_CategoryChartItem> categories) {
    return List.generate(categories.length, (index) {
      final isSelected = index == _selectedCategoryIndex;
      final category = categories[index];

      return PieChartSectionData(
        value: category.count.toDouble(),
        title: '${category.count}',
        color: category.color,
        radius: isSelected ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isSelected ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(List<_CategoryChartItem> categories) {
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
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(cat.label, style: const TextStyle(fontSize: 12)),
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

  List<_CategoryChartItem> _buildCategoryItems(
    List<taxonomy_domain.Taxonomy> taxonomies,
  ) {
    final fallback = <_CategoryChartItem>[
      _CategoryChartItem(label: 'عائلات', count: 450, color: Colors.blue),
      _CategoryChartItem(label: 'أطفال', count: 320, color: Colors.green),
      _CategoryChartItem(label: 'مسنين', count: 180, color: Colors.orange),
      _CategoryChartItem(label: 'ذوي احتياجات', count: 284, color: Colors.purple),
    ];

    if (taxonomies.isEmpty) {
      return fallback;
    }

    final fallbackCounts = fallback.map((item) => item.count).toList(growable: false);
    final fallbackColors = fallback.map((item) => item.color).toList(growable: false);
    final items = <_CategoryChartItem>[];
    final length = taxonomies.length < fallbackCounts.length ? taxonomies.length : fallbackCounts.length;

    for (var i = 0; i < length; i++) {
      final taxonomy = taxonomies[i];
      final label = taxonomy.label.trim().isNotEmpty ? taxonomy.label : fallback[i].label;
      final color = _parseTaxonomyColor(taxonomy.color) ?? fallbackColors[i];
      items.add(_CategoryChartItem(label: label, count: fallbackCounts[i], color: color));
    }

    return items;
  }

  Color? _parseTaxonomyColor(String? colorString) {
    if (colorString == null) {
      return null;
    }

    final trimmed = colorString.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      if (trimmed.startsWith('#')) {
        return Color(int.parse('0xFF${trimmed.substring(1)}'));
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

class _CategoryChartItem {
  final String label;
  final int count;
  final Color color;

  const _CategoryChartItem({
    required this.label,
    required this.count,
    required this.color,
  });
}
