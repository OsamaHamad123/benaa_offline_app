import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
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
    final suggestions = <String>{
      ..._buildCategorySuggestionLabels(),
      'حالات طارئة',
      'التوزيع الجغرافي',
      'الإحصائيات',
    }.toList(growable: false);

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
        final categoryTaxonomies = _mergeCategoryTaxonomies(ref);

        if (dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = _filterResults(dashboard, query, categoryTaxonomies);

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

  List<Map<String, dynamic>> _filterResults(
    dynamic dashboard,
    String searchQuery,
    List<taxonomy_domain.Taxonomy> categoryTaxonomies,
  ) {
    if (searchQuery.isEmpty) return [];

    final query = searchQuery.trim().toLowerCase();
    final results = <Map<String, dynamic>>[];

    results.addAll(
      _buildCategoryResults(
        dashboard.categoryCounts as Map<String, int>,
        categoryTaxonomies,
        query,
      ),
    );

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

  List<taxonomy_domain.Taxonomy> _mergeCategoryTaxonomies(WidgetRef ref) {
    final sectionAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.section),
    );
    final categoryAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category),
    );

    final sectionItems = sectionAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );
    final categoryItems = categoryAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <taxonomy_domain.Taxonomy>[],
    );

    final merged = <String, taxonomy_domain.Taxonomy>{
      for (final item in sectionItems) item.id: item,
      for (final item in categoryItems) item.id: item,
    };

    return merged.values.toList(growable: false);
  }

  List<String> _buildCategorySuggestionLabels() {
    final taxonomies = _mergeCategoryTaxonomies(ref);
    final labels =
        taxonomies.map((item) => item.label.trim()).where((label) => label.isNotEmpty).toList(growable: false);
    if (labels.isNotEmpty) {
      return labels;
    }
    return const ['أيتام', 'أرامل', 'فقراء', 'ذوي الإعاقة'];
  }

  List<Map<String, dynamic>> _buildCategoryResults(
    Map<String, int> rawCounts,
    List<taxonomy_domain.Taxonomy> taxonomies,
    String query,
  ) {
    final normalizedCounts = _normalizeCategoryCounts(rawCounts);
    final metaByKey = _buildCategoryMetaMap(taxonomies);
    final keys = metaByKey.isNotEmpty ? metaByKey.keys : normalizedCounts.keys;

    final results = <Map<String, dynamic>>[];
    for (final key in keys) {
      final canonical = _canonicalizeCategoryKey(key) ?? key;
      final label = _resolveCategoryLabel(canonical, metaByKey);
      final matches = _matchesQuery(query, [label, canonical, key]);
      if (!matches) {
        continue;
      }
      final count = normalizedCounts[canonical] ?? normalizedCounts[key] ?? 0;
      results.add({
        'icon': _resolveCategoryIcon(canonical),
        'color': _resolveCategoryColor(canonical, metaByKey),
        'title': label,
        'subtitle': 'إجمالي $label المسجلين',
        'value': '$count',
      });
    }

    return results;
  }

  bool _matchesQuery(String query, List<String> candidates) {
    for (final candidate in candidates) {
      if (candidate.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
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
    final meta = metaByKey[key];
    if (meta != null && meta.label.trim().isNotEmpty) {
      return meta.label;
    }
    return _fallbackLabelForKey(key) ?? key;
  }

  Color _resolveCategoryColor(
    String key,
    Map<String, _CategoryMeta> metaByKey,
  ) {
    final meta = metaByKey[key];
    return meta?.color ?? _fallbackColorForKey(key);
  }

  IconData _resolveCategoryIcon(String key) {
    switch (key) {
      case 'orphan':
        return Icons.child_care;
      case 'widow':
        return Icons.person;
      case 'poor':
        return Icons.volunteer_activism;
      case 'disabled':
        return Icons.accessible;
      default:
        return Icons.category;
    }
  }

  Color _fallbackColorForKey(String key) {
    switch (key) {
      case 'orphan':
        return DashboardColors.orphans;
      case 'widow':
        return DashboardColors.widows;
      case 'poor':
        return DashboardColors.poor;
      case 'disabled':
        return DashboardColors.disabled;
      default:
        return DashboardColors.totalBeneficiaries;
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
        return 'ذوي الإعاقة';
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
