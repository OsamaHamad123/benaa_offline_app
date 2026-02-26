import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../features/taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../features/taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// Urgent Cases Section - عرض الحالات التي تحتاج متابعة عاجلة
class UrgentCasesSection extends ConsumerWidget {
  const UrgentCasesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    final taxonomyIndexAsync = ref.watch(bridgeTaxonomiesIndexOnceProvider);

    final categoryColorsById = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final sectionOptions = index[TaxonomyGroup.section] ?? const <taxonomy_domain.Taxonomy>[];
        final categoryOptions = index[TaxonomyGroup.category] ?? const <taxonomy_domain.Taxonomy>[];
        return _buildTaxonomyColorMap([...categoryOptions, ...sectionOptions]);
      },
      orElse: () => const <int, Color>{},
    );

    final governorateLabelsById = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final options = index[TaxonomyGroup.governorate] ?? const <taxonomy_domain.Taxonomy>[];
        return _buildTaxonomyLabelMap(options);
      },
      orElse: () => const <int, String>{},
    );

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUrgentCasesData(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSkeletonLoader();
        }

        final data = snapshot.data!;
        final noVisitsCount = data['noVisitsCount'] as int;
        final poorHealthCount = data['poorHealthCount'] as int;
        final disabilitiesCount = data['disabilitiesCount'] as int;
        final totalUrgent = noVisitsCount + poorHealthCount + disabilitiesCount;

        if (totalUrgent == 0) {
          return _buildEmptyState();
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withValues(alpha: 0.05),
                  Colors.orange.withValues(alpha: 0.05),
                ],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالات تحتاج متابعة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            '$totalUrgent حالة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showUrgentCasesDialog(
                        context,
                        database,
                        noVisitsCount,
                        poorHealthCount,
                        disabilitiesCount,
                        categoryColorsById: categoryColorsById,
                        governorateLabelsById: governorateLabelsById,
                      ),
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Urgent Cases List
                if (noVisitsCount > 0)
                  _UrgentCaseItem(
                    icon: Icons.event_busy,
                    title: 'بدون زيارات منذ 30+ يوم',
                    count: noVisitsCount,
                    color: Colors.orange,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'بدون زيارات منذ 30+ يوم',
                      database.beneficiariesDao.getBeneficiariesWithNoRecentVisits(30),
                      categoryColorsById: categoryColorsById,
                      governorateLabelsById: governorateLabelsById,
                    ),
                  ),

                if (poorHealthCount > 0) ...[
                  SizedBox(height: 8.h),
                  _UrgentCaseItem(
                    icon: Icons.health_and_safety,
                    title: 'حالة صحية سيئة',
                    count: poorHealthCount,
                    color: Colors.red,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'حالة صحية سيئة',
                      database.beneficiariesDao.getBeneficiariesWithPoorHealth(),
                      categoryColorsById: categoryColorsById,
                      governorateLabelsById: governorateLabelsById,
                    ),
                  ),
                ],

                if (disabilitiesCount > 0) ...[
                  SizedBox(height: 8.h),
                  _UrgentCaseItem(
                    icon: Icons.accessible,
                    title: 'ذوو إعاقة',
                    count: disabilitiesCount,
                    color: Colors.purple,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'ذوو إعاقة',
                      database.beneficiariesDao.getBeneficiariesWithDisabilities(),
                      categoryColorsById: categoryColorsById,
                      governorateLabelsById: governorateLabelsById,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadUrgentCasesData(
    AppDatabase database,
  ) async {
    final results = await Future.wait([
      database.beneficiariesDao.countBeneficiariesWithNoRecentVisits(30),
      database.beneficiariesDao.countBeneficiariesWithPoorHealth(),
      database.beneficiariesDao.countBeneficiariesWithDisabilities(),
    ]);

    return {
      'noVisitsCount': results[0],
      'poorHealthCount': results[1],
      'disabilitiesCount': results[2],
    };
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48.sp, color: Colors.green),
            SizedBox(height: 12.h),
            Text(
              'لا توجد حالات طارئة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'جميع المستفيدين يتلقون المتابعة المطلوبة',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUrgentCasesDialog(
    BuildContext context,
    AppDatabase database,
    int noVisitsCount,
    int poorHealthCount,
    int disabilitiesCount, {
    required Map<int, Color> categoryColorsById,
    required Map<int, String> governorateLabelsById,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الحالات التي تحتاج متابعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (noVisitsCount > 0)
              ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.orange),
                title: const Text('بدون زيارات منذ 30+ يوم'),
                trailing: Text(
                  '$noVisitsCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'بدون زيارات منذ 30+ يوم',
                    database.beneficiariesDao.getBeneficiariesWithNoRecentVisits(30),
                    categoryColorsById: categoryColorsById,
                    governorateLabelsById: governorateLabelsById,
                  );
                },
              ),
            if (poorHealthCount > 0)
              ListTile(
                leading: const Icon(Icons.health_and_safety, color: Colors.red),
                title: const Text('حالة صحية سيئة'),
                trailing: Text(
                  '$poorHealthCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'حالة صحية سيئة',
                    database.beneficiariesDao.getBeneficiariesWithPoorHealth(),
                    categoryColorsById: categoryColorsById,
                    governorateLabelsById: governorateLabelsById,
                  );
                },
              ),
            if (disabilitiesCount > 0)
              ListTile(
                leading: const Icon(Icons.accessible, color: Colors.purple),
                title: const Text('ذوو إعاقة'),
                trailing: Text(
                  '$disabilitiesCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'ذوو إعاقة',
                    database.beneficiariesDao.getBeneficiariesWithDisabilities(),
                    categoryColorsById: categoryColorsById,
                    governorateLabelsById: governorateLabelsById,
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showCasesList(
    BuildContext context,
    AppDatabase database,
    String title,
    Future<List<Beneficiary>> future, {
    required Map<int, Color> categoryColorsById,
    required Map<int, String> governorateLabelsById,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: title,
        icon: Icons.priority_high,
        maxChildSize: 0.9,
        builder: (scrollController) => FutureBuilder<List<Beneficiary>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final beneficiaries = snapshot.data!;
            if (beneficiaries.isEmpty) {
              return const Center(child: Text('لا توجد حالات'));
            }

            return ListView.separated(
              controller: scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: beneficiaries.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final beneficiary = beneficiaries[index];
                return _BeneficiaryCard(
                  beneficiary: beneficiary,
                  categoryColorsById: categoryColorsById,
                  governorateLabelsById: governorateLabelsById,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/beneficiaries/${beneficiary.id}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SkeletonCard(height: 200.h, padding: EdgeInsets.all(16.w));
  }

  Map<int, String> _buildTaxonomyLabelMap(List<taxonomy_domain.Taxonomy> options) {
    final labels = <int, String>{};
    for (final taxonomy in options) {
      final value = _parseTaxonomyKey(taxonomy);
      if (value == null) continue;
      labels.putIfAbsent(value, () => taxonomy.label);
    }
    return labels;
  }

  Map<int, Color> _buildTaxonomyColorMap(List<taxonomy_domain.Taxonomy> options) {
    final colors = <int, Color>{};
    for (final taxonomy in options) {
      final value = _parseTaxonomyKey(taxonomy);
      if (value == null) continue;
      final parsed = _parseTaxonomyColor(taxonomy.color);
      if (parsed != null) {
        colors.putIfAbsent(value, () => parsed);
      }
    }
    return colors;
  }

  int? _parseTaxonomyKey(taxonomy_domain.Taxonomy taxonomy) {
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

/// Urgent Case Item Widget
class _UrgentCaseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _UrgentCaseItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: color),
          ],
        ),
      ),
    );
  }
}

/// Beneficiary Card Widget for List
class _BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;
  final Map<int, Color> categoryColorsById;
  final Map<int, String> governorateLabelsById;

  const _BeneficiaryCard({
    required this.beneficiary,
    required this.onTap,
    required this.categoryColorsById,
    required this.governorateLabelsById,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: _getCategoryColor(
                  beneficiary.sectionId,
                ).withValues(alpha: 0.2),
                child: Text(
                  beneficiary.fullName.substring(0, 1),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(beneficiary.sectionId),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiary.fullName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 12.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          beneficiary.fileIdNumber ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _getGovernorateLabel(beneficiary.province),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int? sectionId) {
    if (sectionId != null) {
      final resolved = categoryColorsById[sectionId];
      if (resolved != null) {
        return resolved;
      }
    }

    switch (sectionId) {
      case 1: // orphan
        return Colors.blue;
      case 3: // widow
        return Colors.purple;
      case 2: // poor
        return Colors.orange;
      case 4: // disabled
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getGovernorateLabel(int? provinceId) {
    if (provinceId == null) {
      return '';
    }
    return governorateLabelsById[provinceId] ?? provinceId.toString();
  }
}
