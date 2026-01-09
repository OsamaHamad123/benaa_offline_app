/// 🌉 Taxonomy Bridge Widgets
///
/// Widgets تستخدم Bridge Providers للتوافق مع Drift Database
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../providers/taxonomy_bridge_providers.dart';

/// 📝 Taxonomy Bridge Dropdown
///
/// Dropdown يستخدم Drift Database للبيانات
/// متوافق مع باقي نظام التطبيق
class TaxonomyBridgeDropdown extends ConsumerWidget {
  /// المجموعة (category, gender, etc.)
  final TaxonomyGroup group;

  /// القيمة المختارة (code)
  final String? selectedCode;

  /// القيمة المختارة (id)
  final String? selectedId;

  /// Callback عند التغيير - يُرجع الكود
  final ValueChanged<String?>? onCodeChanged;

  /// Callback عند التغيير - يُرجع الـ Taxonomy كامل
  final ValueChanged<Taxonomy?>? onTaxonomyChanged;

  /// النص التوضيحي
  final String? labelText;

  /// Hint
  final String? hintText;

  /// هل مطلوب
  final bool isRequired;

  /// Prefix Icon
  final IconData? prefixIcon;

  /// مفعل؟
  final bool enabled;

  /// رسالة الخطأ
  final String? errorText;

  /// التزيين
  final InputDecoration? decoration;

  const TaxonomyBridgeDropdown({
    super.key,
    required this.group,
    this.selectedCode,
    this.selectedId,
    this.onCodeChanged,
    this.onTaxonomyChanged,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.prefixIcon,
    this.enabled = true,
    this.errorText,
    this.decoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomiesAsync = ref.watch(bridgeTaxonomiesByGroupProvider(group));

    return taxonomiesAsync.when(
      data: (taxonomies) => _buildDropdown(context, taxonomies),
      loading: () => _buildLoadingDropdown(context),
      error: (error, _) => _buildErrorDropdown(context, error.toString()),
    );
  }

  Widget _buildDropdown(BuildContext context, List<Taxonomy> taxonomies) {
    final theme = Theme.of(context);

    // Find selected taxonomy
    Taxonomy? selectedTaxonomy;
    if (selectedCode != null) {
      selectedTaxonomy = taxonomies.where((t) => t.code == selectedCode).firstOrNull;
    } else if (selectedId != null) {
      selectedTaxonomy = taxonomies.where((t) => t.id == selectedId).firstOrNull;
    }

    return DropdownButtonFormField<String>(
      value: selectedTaxonomy?.code,
      decoration: decoration ??
          InputDecoration(
            labelText: labelText ?? group.arabicName,
            hintText: hintText ?? 'اختر ${group.arabicName}',
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22.sp) : Icon(_getDefaultIcon(), size: 22.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
      items: taxonomies.map((taxonomy) {
        return DropdownMenuItem<String>(
          value: taxonomy.code,
          child: Row(
            children: [
              if (taxonomy.color != null) ...[
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _parseColor(taxonomy.color!),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  taxonomy.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: enabled
          ? (code) {
              if (onCodeChanged != null) {
                onCodeChanged!(code);
              }
              if (onTaxonomyChanged != null) {
                final taxonomy = taxonomies.where((t) => t.code == code).firstOrNull;
                onTaxonomyChanged!(taxonomy);
              }
            }
          : null,
      validator: isRequired ? (value) => value == null || value.isEmpty ? '${group.arabicName} مطلوب' : null : null,
      isExpanded: true,
      style: theme.textTheme.bodyLarge,
      dropdownColor: theme.cardColor,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  Widget _buildLoadingDropdown(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText ?? group.arabicName,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22.sp) : Icon(_getDefaultIcon(), size: 22.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(strokeWidth: 2.w),
          ),
          SizedBox(width: 12.w),
          Text(
            'جاري التحميل...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown(BuildContext context, String error) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText ?? group.arabicName,
        prefixIcon: Icon(Icons.error_outline, color: Colors.red, size: 22.sp),
        errorText: 'فشل تحميل البيانات',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        'حاول مرة أخرى',
        style: TextStyle(color: Colors.red[400]),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (group) {
      case TaxonomyGroup.governorate:
        return Icons.location_city_rounded;
      case TaxonomyGroup.category:
        return Icons.category_rounded;
      case TaxonomyGroup.maritalStatus:
        return Icons.family_restroom_rounded;
      case TaxonomyGroup.educationLevel:
        return Icons.school_rounded;
      case TaxonomyGroup.healthStatus:
        return Icons.health_and_safety_rounded;
      case TaxonomyGroup.housingType:
        return Icons.home_rounded;
      case TaxonomyGroup.housingStatus:
        return Icons.house_siding_rounded;
      case TaxonomyGroup.disabilityType:
        return Icons.accessible_rounded;
      case TaxonomyGroup.incomeSource:
        return Icons.attach_money_rounded;
      case TaxonomyGroup.associationType:
        return Icons.business_rounded;
      case TaxonomyGroup.sponsorshipType:
        return Icons.volunteer_activism_rounded;
      case TaxonomyGroup.gender:
        return Icons.wc_rounded;
      case TaxonomyGroup.visitType:
        return Icons.directions_walk_rounded;
      case TaxonomyGroup.assistanceType:
        return Icons.handshake_rounded;
      case TaxonomyGroup.beneficiaryStatus:
        return Icons.verified_user_rounded;
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
      return Colors.grey;
    } catch (_) {
      return Colors.grey;
    }
  }
}

/// 🏷️ Taxonomy Label Widget
///
/// يعرض اسم التصنيف بناءً على الكود
class TaxonomyLabel extends ConsumerWidget {
  final TaxonomyGroup group;
  final String code;
  final TextStyle? style;
  final String? placeholder;

  const TaxonomyLabel({
    super.key,
    required this.group,
    required this.code,
    this.style,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomyAsync = ref.watch(
      bridgeTaxonomyByCodeProvider((group: group, code: code)),
    );

    return taxonomyAsync.when(
      data: (taxonomy) => Text(
        taxonomy?.label ?? placeholder ?? code,
        style: style,
      ),
      loading: () => SizedBox(
        width: 60.w,
        child: LinearProgressIndicator(minHeight: 2.h),
      ),
      error: (_, __) => Text(
        placeholder ?? code,
        style: style,
      ),
    );
  }
}

/// 🎯 Taxonomy Chip Widget
///
/// يعرض التصنيف كـ Chip
class TaxonomyBridgeChip extends ConsumerWidget {
  final TaxonomyGroup group;
  final String code;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;

  const TaxonomyBridgeChip({
    super.key,
    required this.group,
    required this.code,
    this.onDeleted,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomyAsync = ref.watch(
      bridgeTaxonomyByCodeProvider((group: group, code: code)),
    );

    return taxonomyAsync.when(
      data: (taxonomy) {
        if (taxonomy == null) {
          return Chip(label: Text(code));
        }

        return Chip(
          label: Text(taxonomy.label),
          backgroundColor:
              backgroundColor ?? (taxonomy.color != null ? _parseColor(taxonomy.color!).withOpacity(0.2) : null),
          deleteIcon: onDeleted != null ? Icon(Icons.close, size: 16.sp) : null,
          onDeleted: onDeleted,
        );
      },
      loading: () => Chip(
        label: SizedBox(
          width: 40.w,
          child: LinearProgressIndicator(minHeight: 2.h),
        ),
      ),
      error: (_, __) => Chip(label: Text(code)),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
      return Colors.grey;
    } catch (_) {
      return Colors.grey;
    }
  }
}
