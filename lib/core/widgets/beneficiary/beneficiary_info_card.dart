import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/db/drift_database.dart' show Beneficiary;
import '../../design_system/app_animations.dart';
import '../../../features/taxonomies/domain/entities/taxonomy.dart';
import '../../../features/taxonomies/domain/entities/taxonomy_group.dart';
import '../../../features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// Reusable Beneficiary Info Card Widget
class BeneficiaryInfoCard extends ConsumerWidget {
  final Beneficiary beneficiary;
  final bool compact;

  const BeneficiaryInfoCard({
    required this.beneficiary,
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomyIndex = ref.watch(bridgeTaxonomiesIndexOnceProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <TaxonomyGroup, List<Taxonomy>>{},
        );

    final categoryColor = _resolveCategoryColor(
      beneficiary.sectionId,
      taxonomyIndex,
    );

    final provinceLabel = _resolveLocationLabel(
          beneficiary.province,
          TaxonomyGroup.governorate,
          taxonomyIndex,
        ) ??
        _getProvinceName(beneficiary.province);

    final cityLabel = beneficiary.city == null
        ? null
        : (_resolveLocationLabel(
              beneficiary.city,
              TaxonomyGroup.city,
              taxonomyIndex,
            ) ??
            _getCityName(beneficiary.city));

    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: compact ? 20.r : 24.r,
                    backgroundColor: categoryColor.withOpacity(0.1),
                    child: Text(
                      beneficiary.fullName.substring(0, 1),
                      style: TextStyle(
                        fontSize: compact ? 16.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
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
                            fontSize: compact ? 14.sp : 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'رقم الملف: ${beneficiary.fileIdNumber ?? "غير محدد"}',
                          style: TextStyle(
                            fontSize: compact ? 11.sp : 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      provinceLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (cityLabel != null) ...[
                      Text(
                        ' - $cityLabel',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveCategoryColor(
    int? sectionId,
    Map<TaxonomyGroup, List<Taxonomy>> taxonomyIndex,
  ) {
    final taxonomy = _resolveTaxonomyByNumericId(
      sectionId,
      taxonomyIndex,
      const [TaxonomyGroup.category, TaxonomyGroup.section],
    );

    final parsedColor = _parseColor(taxonomy?.color);
    if (parsedColor != null) {
      return parsedColor;
    }

    switch (sectionId) {
      case 1: // Orphan
        return Colors.blue;
      case 2: // Widow
        return Colors.purple;
      case 3: // Poor
        return Colors.orange;
      case 4: // Disabled
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String? _resolveLocationLabel(
    int? id,
    TaxonomyGroup group,
    Map<TaxonomyGroup, List<Taxonomy>> taxonomyIndex,
  ) {
    final taxonomy = _resolveTaxonomyByNumericId(
      id,
      taxonomyIndex,
      [group],
    );

    final label = taxonomy?.label.trim();
    if (label == null || label.isEmpty) {
      return null;
    }
    return label;
  }

  Taxonomy? _resolveTaxonomyByNumericId(
    int? id,
    Map<TaxonomyGroup, List<Taxonomy>> taxonomyIndex,
    List<TaxonomyGroup> groups,
  ) {
    if (id == null) {
      return null;
    }

    for (final group in groups) {
      final items = taxonomyIndex[group] ?? const <Taxonomy>[];
      for (final taxonomy in items) {
        final key = _parseTaxonomyNumericKey(taxonomy);
        if (key == id) {
          return taxonomy;
        }
      }
    }

    return null;
  }

  int? _parseTaxonomyNumericKey(Taxonomy taxonomy) {
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

  Color? _parseColor(String? colorString) {
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

  String _getProvinceName(int? province) {
    // Province names - requires taxonomy service integration
    // Returns ID for now; can be mapped when taxonomy data is available
    return province?.toString() ?? 'غير محدد';
  }

  String _getCityName(int? city) {
    return city?.toString() ?? 'غير محدد';
  }
}
