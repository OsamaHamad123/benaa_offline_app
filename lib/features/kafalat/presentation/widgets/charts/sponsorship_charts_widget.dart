import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../data/db/daos/sponsorships_dao.dart';

/// 📊 Sponsorship Charts Widget - عرض الرسوم البيانية التفاعلية
///
/// يعرض 3 أنواع من الرسوم:
/// 1. Pie Chart - توزيع الحالات
/// 2. Bar Chart - مقارنة الأشهر
/// 3. Line Chart - الاتجاه الزمني
class SponsorshipChartsWidget extends ConsumerStatefulWidget {
  final List<SponsorshipWithDetails> sponsorships;

  const SponsorshipChartsWidget({
    required this.sponsorships, super.key,
  });

  @override
  ConsumerState<SponsorshipChartsWidget> createState() => _SponsorshipChartsWidgetState();
}

class _SponsorshipChartsWidgetState extends ConsumerState<SponsorshipChartsWidget> {
  int _selectedChartIndex = 0;

  // Cache للبيانات المحسوبة - تحسين الأداء
  Map<String, int>? _cachedStatusCounts;
  Map<int, int>? _cachedMonthlyCounts;
  List<MapEntry<DateTime, int>>? _cachedDailyCounts;
  List<SponsorshipWithDetails>? _lastProcessedData;

  // حساب البيانات مع caching
  Map<String, int> get _statusCounts {
    if (_cachedStatusCounts == null || _lastProcessedData != widget.sponsorships) {
      _cachedStatusCounts = {};
      for (final row in widget.sponsorships) {
        _cachedStatusCounts![row.sponsorship.status] = (_cachedStatusCounts![row.sponsorship.status] ?? 0) + 1;
      }
      _lastProcessedData = widget.sponsorships;
    }
    return _cachedStatusCounts!;
  }

  Map<int, int> get _monthlyCounts {
    if (_cachedMonthlyCounts == null || _lastProcessedData != widget.sponsorships) {
      _cachedMonthlyCounts = {};
      for (final row in widget.sponsorships) {
        final startDate = row.sponsorship.startDate;
        if (startDate != null) {
          final month = startDate.month;
          _cachedMonthlyCounts![month] = (_cachedMonthlyCounts![month] ?? 0) + 1;
        }
      }
      _lastProcessedData = widget.sponsorships;
    }
    return _cachedMonthlyCounts!;
  }

  List<MapEntry<DateTime, int>> get _dailyCounts {
    if (_cachedDailyCounts == null || _lastProcessedData != widget.sponsorships) {
      final dailyMap = <DateTime, int>{};
      for (final row in widget.sponsorships) {
        final startDate = row.sponsorship.startDate;
        if (startDate != null) {
          final date = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          dailyMap[date] = (dailyMap[date] ?? 0) + 1;
        }
      }
      _cachedDailyCounts = dailyMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      _lastProcessedData = widget.sponsorships;
    }
    return _cachedDailyCounts!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(isMobile ? 12.w : (isTablet ? 16.w : 20.w)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: theme.colorScheme.primary,
                size: isMobile ? 20.sp : 24.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'التحليلات البيانية',
                  style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12.h : 16.h),

          // Chart Type Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ChartTypeButton(
                  icon: Icons.pie_chart,
                  label: 'التوزيع',
                  isSelected: _selectedChartIndex == 0,
                  onTap: () => setState(() => _selectedChartIndex = 0),
                ),
                SizedBox(width: 8.w),
                _ChartTypeButton(
                  icon: Icons.bar_chart,
                  label: 'المقارنة',
                  isSelected: _selectedChartIndex == 1,
                  onTap: () => setState(() => _selectedChartIndex = 1),
                ),
                SizedBox(width: 8.w),
                _ChartTypeButton(
                  icon: Icons.show_chart,
                  label: 'الاتجاه',
                  isSelected: _selectedChartIndex == 2,
                  onTap: () => setState(() => _selectedChartIndex = 2),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16.h : 20.h),

          // Chart Display
          SizedBox(
            height: isMobile ? 250.h : (isTablet ? 320.h : 400.h),
            child: _buildSelectedChart(theme, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChart(ThemeData theme, bool isMobile) {
    return switch (_selectedChartIndex) {
      0 => _StatusPieChart(
          statusCounts: _statusCounts,
          theme: theme,
        ),
      1 => _MonthlyBarChart(
          monthlyCounts: _monthlyCounts,
          theme: theme,
        ),
      2 => _TrendLineChart(
          dailyCounts: _dailyCounts,
          theme: theme,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Chart Type Button
class _ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.w : 16.w,
          vertical: isMobile ? 8.h : 10.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
              size: isMobile ? 16.sp : 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: isMobile ? 12.sp : 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1. Pie Chart - توزيع الحالات
class _StatusPieChart extends StatefulWidget {
  final Map<String, int> statusCounts;
  final ThemeData theme;

  const _StatusPieChart({
    required this.statusCounts,
    required this.theme,
  });

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // استخدام البيانات المحسوبة مباشرة
    final sections = _buildPieChartSections(widget.statusCounts);

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50.r,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: Colors.green, label: 'نشطة', count: widget.statusCounts['active'] ?? 0),
              SizedBox(height: 8.h),
              _LegendItem(color: Colors.orange, label: 'متوقفة', count: widget.statusCounts['paused'] ?? 0),
              SizedBox(height: 8.h),
              _LegendItem(color: Colors.red, label: 'منتهية', count: widget.statusCounts['ended'] ?? 0),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> statusCounts) {
    final total = statusCounts.values.fold<int>(0, (sum, count) => sum + count);
    final sections = <PieChartSectionData>[];

    final statusData = [
      ('active', Colors.green, 'نشطة'),
      ('paused', Colors.orange, 'متوقفة'),
      ('ended', Colors.red, 'منتهية'),
    ];

    for (var i = 0; i < statusData.length; i++) {
      final (status, color, label) = statusData[i];
      final count = statusCounts[status] ?? 0;
      final percentage = total > 0 ? (count / total * 100) : 0;
      final isTouched = i == _touchedIndex;

      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: isTouched ? 70.r : 60.r,
          titleStyle: TextStyle(
            fontSize: isTouched ? 16.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}

/// Legend Item
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$label ($count)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

/// 2. Bar Chart - مقارنة الأشهر
class _MonthlyBarChart extends StatelessWidget {
  final Map<int, int> monthlyCounts;
  final ThemeData theme;

  const _MonthlyBarChart({
    required this.monthlyCounts,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyData.values.isEmpty ? 10 : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = monthlyData.keys.elementAt(groupIndex);
              return BarTooltipItem(
                '$month\n${rod.toY.toInt()}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  final month = monthlyData.keys.elementAt(index);
                  return Text(
                    month,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(monthlyData),
      ),
    );
  }

  Map<String, double> _getMonthlyData() {
    final monthlyData = <String, double>{};

    // تحويل البيانات الشهرية إلى أسماء الأشهر بالعربي
    for (final entry in monthlyCounts.entries) {
      final monthName = DateFormat('MMM', 'ar').format(DateTime(2024, entry.key));
      monthlyData[monthName] = entry.value.toDouble();
    }

    return monthlyData;
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> data) {
    return List.generate(data.length, (index) {
      final value = data.values.elementAt(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.blue,
            width: 16.w,
            borderRadius: BorderRadius.circular(4.r),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.values.reduce((a, b) => a > b ? a : b) * 1.2,
              color: theme.dividerColor.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }
}

/// 3. Line Chart - الاتجاه الزمني
class _TrendLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, int>> dailyCounts;
  final ThemeData theme;

  const _TrendLineChart({
    required this.dailyCounts,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final trendData = _getTrendData();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final month = trendData.keys.elementAt(spot.x.toInt());
                return LineTooltipItem(
                  '$month\n${spot.y.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trendData.length) {
                  final month = trendData.keys.elementAt(index);
                  return Text(
                    month,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _buildLineSpots(trendData),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4.r,
                  color: Colors.purple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getTrendData() {
    final trendData = <String, double>{};

    // تحويل البيانات اليومية إلى تنسيق عرض
    for (final entry in dailyCounts) {
      final dateKey = DateFormat('d/M', 'ar').format(entry.key);
      trendData[dateKey] = entry.value.toDouble();
    }

    return trendData;
  }

  List<FlSpot> _buildLineSpots(Map<String, double> data) {
    return List.generate(data.length, (index) {
      final value = data.values.elementAt(index);
      return FlSpot(index.toDouble(), value);
    });
  }
}
