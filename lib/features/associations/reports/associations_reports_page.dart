import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'providers/associations_reports_provider.dart';
import 'widgets/stats_dashboard_widget.dart';
import 'widgets/currency_chart_widget.dart';
import 'widgets/bank_chart_widget.dart';
import 'widgets/representative_chart_widget.dart';
import 'widgets/export_report_section.dart';

/// 📊 صفحة تقارير الجمعيات
class AssociationsReportsPage extends ConsumerWidget {
  const AssociationsReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(associationsStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'تقارير الجمعيات',
        showGradient: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(associationsStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📊 لوحة الإحصائيات الرئيسية
              StatsDashboardWidget(stats: stats),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // 💰 تقرير العملات
              CurrencyChartWidget(data: stats.byCurrency),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // 🏦 تقرير البنوك
              BankChartWidget(data: stats.byBank),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // 👥 تقرير المندوبين
              RepresentativeChartWidget(data: stats.byRepresentative),

              SizedBox(height: ResponsiveUtils.mediumSpace),

              // 📤 تصدير التقرير
              ExportReportSection(stats: stats),

              SizedBox(height: ResponsiveUtils.largeSpace),
            ],
          ),
        ),
      ),
    );
  }
}
