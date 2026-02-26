import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../domain/entities/dashboard_statistics.dart';
import '../../../../theme/app_colors.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// Growth Chart - Clean Architecture Version
/// Takes GrowthDataPoint list from domain entity
class GrowthChart extends StatelessWidget {
  final List<GrowthDataPoint> growthData;

  const GrowthChart({required this.growthData, super.key});

  @override
  Widget build(BuildContext context) {
    if (growthData.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نمو المستفيدين (آخر 7 أيام)',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: 200.h,
                  tablet: 250.h,
                  desktop: 300.h,
                ),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => AppColors.infoDark.withOpacity(0.8),
                        tooltipPadding: EdgeInsets.all(8.w),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = growthData[spot.x.toInt()].date;
                            return LineTooltipItem(
                              '${spot.y.toInt()} مستفيد\n${date.day}/${date.month}/${date.year}',
                              TextStyle(
                                color: AppColors.surface,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.divider.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < growthData.length) {
                              final date = growthData[value.toInt()].date;
                              return Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.textSecondary,
                                  ),
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (growthData.length - 1).toDouble(),
                    minY: 0,
                    maxY: _getMaxY(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: growthData
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(
                                e.key.toDouble(),
                                e.value.count.toDouble(),
                              ),
                            )
                            .toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: AppColors.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (growthData.isEmpty) return 10;
    final maxCount = growthData.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    return (maxCount + 2).toDouble();
  }
}

/// Category Distribution Chart - Clean Architecture Version
/// Takes categoryCounts map from domain entity
class CategoryDistributionChart extends ConsumerWidget {
  final Map<String, int> categoryCounts;

  const CategoryDistributionChart({required this.categoryCounts, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categoryCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sectionTaxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final categoryTaxonomiesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category),
    );
    final sectionTaxonomies = sectionTaxonomiesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );
    final categoryTaxonomies = categoryTaxonomiesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );
    final mergedTaxonomies = <String, taxonomy_domain.Taxonomy>{
      for (final item in sectionTaxonomies) item.id: item,
      for (final item in categoryTaxonomies) item.id: item,
    };
    final normalizedCounts = _normalizeCategoryCounts(categoryCounts);
    final total = normalizedCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox.shrink();
    }
    final metaByKey = _buildCategoryMetaMap(mergedTaxonomies.values.toList());

    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'توزيع الفئات',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final availableWidth = constraints.maxWidth;
                  final isVertical = availableWidth < 360.w || availableHeight < 220.h;

                  final base = math.min(
                    availableHeight,
                    availableWidth / (isVertical ? 1 : 2),
                  );
                  final pieRadius = (base * 0.28).clamp(30.r, 120.r);

                  final pie = SizedBox(
                    height: isVertical ? pieRadius * 2 : double.infinity,
                    child: Center(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _buildPieSections(
                            normalizedCounts,
                            metaByKey,
                            total,
                            radius: pieRadius,
                          ),
                        ),
                      ),
                    ),
                  );

                  final legend = Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildLegendForCounts(
                        normalizedCounts,
                        metaByKey,
                      ),
                    ),
                  );

                  if (isVertical) {
                    return Column(
                      children: [
                        pie,
                        SizedBox(height: 12.h),
                        ..._buildLegendForCounts(
                          normalizedCounts,
                          metaByKey,
                        ),
                      ],
                    );
                  }

                  return SizedBox(
                    height: ResponsiveUtils.getResponsiveValue(
                      context,
                      mobile: 200.h,
                      tablet: 250.h,
                      desktop: 300.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: pie),
                        SizedBox(width: 16.w),
                        legend,
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, int> counts,
    Map<String, _CategoryMeta> metaByKey,
    int total, {
    double? radius,
  }) {
    return counts.entries.map((entry) {
      final percentage = entry.value / total * 100;
      final color = _resolveCategoryColor(entry.key, metaByKey);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: radius ?? 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.surface,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegendForCounts(
    Map<String, int> counts,
    Map<String, _CategoryMeta> metaByKey,
  ) {
    return counts.entries.map((entry) {
      final label = _resolveCategoryLabel(entry.key, metaByKey);
      final color = _resolveCategoryColor(entry.key, metaByKey);
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '$label: ${entry.value}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Map<String, int> _normalizeCategoryCounts(Map<String, int> rawCounts) {
    final normalized = <String, int>{};
    rawCounts.forEach((key, value) {
      final canonical = _canonicalizeCategoryKey(key);
      if (canonical == null) {
        normalized[key] = (normalized[key] ?? 0) + value;
        return;
      }
      normalized[canonical] = (normalized[canonical] ?? 0) + value;
    });
    return normalized;
  }

  String? _canonicalizeCategoryKey(String? raw) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    switch (normalized) {
      case '1':
        return 'orphan';
      case '2':
        return 'poor';
      case '3':
        return 'widow';
      case '4':
        return 'disabled';
      case 'orphan':
      case 'orphans':
      case 'يتيم':
      case 'أيتام':
        return 'orphan';
      case 'widow':
      case 'widows':
      case 'أرملة':
      case 'أرامل':
        return 'widow';
      case 'poor':
      case 'فقير':
      case 'فقراء':
        return 'poor';
      case 'disabled':
      case 'معاق':
      case 'ذوي الإعاقة':
      case 'ذوي إعاقة':
        return 'disabled';
    }

    return null;
  }

  Map<String, _CategoryMeta> _buildCategoryMetaMap(
    List<taxonomy_domain.Taxonomy> items,
  ) {
    final metaByKey = <String, _CategoryMeta>{};
    for (final item in items) {
      final candidates = <String?>[
        _canonicalizeCategoryKey(item.code),
        _canonicalizeCategoryKey(item.label),
        _canonicalizeCategoryKey(_parseTaxonomyNumericKey(item)?.toString()),
      ];
      for (final candidate in candidates) {
        if (candidate == null || metaByKey.containsKey(candidate)) {
          continue;
        }
        final color = _parseTaxonomyColor(item.color) ?? _fallbackColorForKey(candidate);
        metaByKey[candidate] = _CategoryMeta(label: item.label, color: color);
      }
    }

    return metaByKey;
  }

  String _resolveCategoryLabel(
    String key,
    Map<String, _CategoryMeta> metaByKey,
  ) {
    final canonical = _canonicalizeCategoryKey(key) ?? key;
    final meta = metaByKey[canonical];
    if (meta != null && meta.label.trim().isNotEmpty) {
      return meta.label;
    }
    return _fallbackLabelForKey(canonical) ?? canonical;
  }

  Color _resolveCategoryColor(
    String key,
    Map<String, _CategoryMeta> metaByKey,
  ) {
    final canonical = _canonicalizeCategoryKey(key) ?? key;
    final meta = metaByKey[canonical];
    return meta?.color ?? _fallbackColorForKey(canonical);
  }

  Color _fallbackColorForKey(String key) {
    switch (key) {
      case 'orphan':
        return AppColors.orphan;
      case 'widow':
        return AppColors.widow;
      case 'poor':
        return AppColors.poor;
      case 'disabled':
        return AppColors.disabled;
      default:
        return AppColors.textSecondary;
    }
  }

  String? _fallbackLabelForKey(String key) {
    switch (key) {
      case 'orphan':
        return 'أيتام';
      case 'widow':
        return 'أرامل';
      case 'poor':
        return 'فقراء';
      case 'disabled':
        return 'ذوي إعاقة';
      default:
        return null;
    }
  }

  int? _parseTaxonomyNumericKey(taxonomy_domain.Taxonomy taxonomy) {
    final code = int.tryParse(taxonomy.code.trim());
    if (code != null) {
      return code;
    }

    final rawId = taxonomy.id.trim();
    if (rawId.isEmpty) {
      return null;
    }

    final separatorIndex = rawId.indexOf('::');
    final suffix = separatorIndex >= 0 ? rawId.substring(separatorIndex + 2) : rawId;
    return int.tryParse(suffix.trim());
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

class _CategoryMeta {
  final String label;
  final Color color;

  const _CategoryMeta({
    required this.label,
    required this.color,
  });
}
