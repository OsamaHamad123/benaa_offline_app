import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers.dart'; // ✅ Dashboard Provider (providers.dart exports dashboardProvider)
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_spacing.dart';

/// Dashboard Search Delegate - البحث في بيانات الداشبورد
class DashboardSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  DashboardSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'ابحث في الداشبورد...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: DashboardColors.totalBeneficiaries,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: DashboardTextStyles.cardSubtitle.copyWith(color: Colors.white70),
      ),
      textTheme: TextTheme(
        titleLarge: DashboardTextStyles.sectionTitle.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSuggestionsList();
    }
    return _buildSearchResults();
  }

  Widget _buildSuggestionsList() {
    final suggestions = [
      'أيتام',
      'أرامل',
      'فقراء',
      'ذوي الإعاقة',
      'حالات طارئة',
      'التوزيع الجغرافي',
      'الإحصائيات',
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search, color: DashboardColors.totalBeneficiaries),
          title: Text(suggestion, style: DashboardTextStyles.cardSubtitle),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(dashboardProvider);
        final dashboard = dashboardState.statistics;

        if (dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = _filterResults(dashboard, query);

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: DashboardSpacing.medium),
                Text(
                  'لا توجد نتائج',
                  style: DashboardTextStyles.emptyStateTitle,
                ),
                SizedBox(height: DashboardSpacing.tiny),
                Text(
                  'جرب كلمات بحث أخرى',
                  style: DashboardTextStyles.emptyStateMessage,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => Divider(height: 1.h),
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              leading: Icon(
                result['icon'] as IconData,
                color: result['color'] as Color,
              ),
              title: Text(
                result['title'] as String,
                style: DashboardTextStyles.cardTitle,
              ),
              subtitle: Text(
                result['subtitle'] as String,
                style: DashboardTextStyles.cardSubtitle,
              ),
              trailing: Text(
                result['value'] as String,
                style: DashboardTextStyles.statValue.copyWith(
                  color: result['color'] as Color,
                ),
              ),
              onTap: () => close(context, result['title'] as String),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterResults(dynamic dashboard, String searchQuery) {
    if (searchQuery.isEmpty) return [];

    final query = searchQuery.trim().toLowerCase();
    final results = <Map<String, dynamic>>[];

    // Search in statistics using categoryCounts

    if ('أيتام'.contains(query) || 'orphans'.contains(query)) {
      results.add({
        'icon': Icons.child_care,
        'color': DashboardColors.orphans,
        'title': 'أيتام',
        'subtitle': 'إجمالي الأيتام المسجلين',
        'value': '${dashboard.categoryCounts['يتيم'] ?? 0}',
      });
    }

    if ('أرامل'.contains(query) || 'widows'.contains(query)) {
      results.add({
        'icon': Icons.person,
        'color': DashboardColors.widows,
        'title': 'أرامل',
        'subtitle': 'إجمالي الأرامل المسجلات',
        'value': '${dashboard.categoryCounts['أرملة'] ?? 0}',
      });
    }

    if ('فقراء'.contains(query) || 'poor'.contains(query)) {
      results.add({
        'icon': Icons.volunteer_activism,
        'color': DashboardColors.poor,
        'title': 'فقراء',
        'subtitle': 'إجمالي الفقراء المسجلين',
        'value': '${dashboard.categoryCounts['فقير'] ?? 0}',
      });
    }

    if ('ذوي الإعاقة'.contains(query) || 'disabled'.contains(query) || 'إعاقة'.contains(query)) {
      results.add({
        'icon': Icons.accessible,
        'color': DashboardColors.disabled,
        'title': 'ذوي الإعاقة',
        'subtitle': 'إجمالي ذوي الإعاقة المسجلين',
        'value': '${dashboard.categoryCounts['معاق'] ?? 0}',
      });
    }

    if ('مجموع'.contains(query) || 'total'.contains(query) || 'إجمالي'.contains(query)) {
      results.add({
        'icon': Icons.people,
        'color': DashboardColors.totalBeneficiaries,
        'title': 'إجمالي المستفيدين',
        'subtitle': 'مجموع جميع المستفيدين',
        'value': '${dashboard.totalBeneficiaries}',
      });
    }

    return results;
  }
}
