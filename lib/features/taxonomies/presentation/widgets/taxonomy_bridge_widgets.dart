/// 🌉 Taxonomy Bridge Widgets
///
/// Widgets تستخدم Bridge Providers للتوافق مع Drift Database
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/sync/presentation/providers/sync_providers.dart' as sync_providers;
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../providers/taxonomy_providers.dart';
import '../providers/taxonomy_bridge_providers.dart';

/// 📝 Taxonomy Bridge Dropdown
///
/// Dropdown يستخدم Drift Database للبيانات
/// متوافق مع باقي نظام التطبيق
class TaxonomyBridgeDropdown extends ConsumerStatefulWidget {
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

  /// خيارات جاهزة مسبقاً لتقليل الأحمال (عند توفرها لا يتم الاشتراك في provider)
  final List<Taxonomy>? preloadedOptions;

  /// إظهار زر مزامنة التصنيفات في حالات الفراغ/الخطأ.
  final bool showSyncAction;

  /// تنفيذ مزامنة تلقائية مرة واحدة عند ظهور حالة الفراغ.
  final bool autoSyncOnEmpty;

  const TaxonomyBridgeDropdown({
    required this.group,
    super.key,
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
    this.preloadedOptions,
    this.showSyncAction = true,
    this.autoSyncOnEmpty = false,
  });

  @override
  ConsumerState<TaxonomyBridgeDropdown> createState() => _TaxonomyBridgeDropdownState();
}

class _TaxonomyBridgeDropdownState extends ConsumerState<TaxonomyBridgeDropdown> {
  bool _realtimeSyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleRealtimeGroupSync();
  }

  @override
  void didUpdateWidget(covariant TaxonomyBridgeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      _realtimeSyncScheduled = false;
      _scheduleRealtimeGroupSync();
    }
  }

  void _scheduleRealtimeGroupSync() {
    if (_realtimeSyncScheduled) {
      return;
    }

    _realtimeSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(taxonomyFirestoreHydratorProvider).ensureRealtimeGroupSync(widget.group);
    });
  }

  @override
  Widget build(BuildContext context) {
    final preloaded = widget.preloadedOptions;
    if (preloaded != null) {
      return _buildDropdown(context, ref, preloaded);
    }

    final taxonomiesAsync = ref.watch(bridgeTaxonomiesByGroupResolvedOnceProvider(widget.group));

    return taxonomiesAsync.when(
      data: (taxonomies) => _buildDropdown(context, ref, taxonomies),
      loading: () => _buildLoadingDropdown(context),
      error: (error, _) => _buildErrorDropdown(context, ref, error.toString()),
    );
  }

  void _invalidateTaxonomyCache(WidgetRef ref) {
    if (!_isRefUsable(ref)) {
      return;
    }

    ref.read(bridgeGroupAutoSyncAttemptedProvider(widget.group).notifier).state = false;
    ref.invalidate(bridgeTaxonomiesIndexOnceProvider);
    ref.invalidate(bridgeTaxonomiesByGroupOnceProvider(widget.group));
    ref.invalidate(bridgeTaxonomiesByGroupResolvedOnceProvider(widget.group));
  }

  bool _isRefUsable(WidgetRef ref) {
    try {
      ref.read(sync_providers.syncControllerProvider);
      return true;
    } on StateError {
      return false;
    }
  }

  Future<void> _syncTaxonomiesAndRefresh(WidgetRef ref) async {
    if (!_isRefUsable(ref)) {
      return;
    }

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return;
    }

    final hydratedCount = await ref.read(taxonomyFirestoreHydratorProvider).hydrateGroup(widget.group);

    if (!mounted) {
      return;
    }

    if (!_isRefUsable(ref)) {
      return;
    }

    if (hydratedCount > 0) {
      _invalidateTaxonomyCache(ref);
      return;
    }

    final legacyRestEnabled = ref.read(legacyTaxonomyRestSyncEnabledProvider);
    if (!legacyRestEnabled) {
      _invalidateTaxonomyCache(ref);
      return;
    }

    await ref.read(sync_providers.syncControllerProvider.notifier).deltaSync('taxonomies');

    if (!_isRefUsable(ref)) {
      return;
    }

    _invalidateTaxonomyCache(ref);
  }

  String _normalizeErrorForDisplay(String error) {
    final normalized = error.toLowerCase();
    if (normalized.contains('permission-denied') || normalized.contains('permission denied')) {
      return 'Firestore taxonomy permission denied. Check Firestore rules for taxonomy_categories and confirm the app is connected to the correct Firebase project.';
    }
    return error;
  }

  Widget _buildDropdown(BuildContext context, WidgetRef ref, List<Taxonomy> taxonomies) {
    final theme = Theme.of(context);

    final uniqueTaxonomies = <Taxonomy>[];
    final seenCodes = <String>{};
    for (final taxonomy in taxonomies) {
      final code = taxonomy.code.trim();
      if (code.isEmpty) continue;
      if (seenCodes.add(code)) {
        uniqueTaxonomies.add(taxonomy);
      }
    }

    if (uniqueTaxonomies.isEmpty) {
      return _buildEmptyDropdown(context, ref);
    }

    // Find selected taxonomy
    Taxonomy? selectedTaxonomy;
    if (widget.selectedCode != null) {
      selectedTaxonomy = uniqueTaxonomies.where((t) => t.code == widget.selectedCode).firstOrNull;
    } else if (widget.selectedId != null) {
      selectedTaxonomy = uniqueTaxonomies.where((t) => t.id == widget.selectedId).firstOrNull;
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedTaxonomy?.code,
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.labelText ?? widget.group.arabicName,
            hintText: widget.hintText ?? 'اختر ${widget.group.arabicName}',
            errorText: widget.errorText,
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 22.sp) : Icon(_getDefaultIcon(), size: 22.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
      items: uniqueTaxonomies.map((taxonomy) {
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
      onChanged: widget.enabled
          ? (code) {
              if (widget.onCodeChanged != null) {
                widget.onCodeChanged!(code);
              }
              if (widget.onTaxonomyChanged != null) {
                final taxonomy = uniqueTaxonomies.where((t) => t.code == code).firstOrNull;
                widget.onTaxonomyChanged!(taxonomy);
              }
            }
          : null,
      validator: widget.isRequired
          ? (value) => value == null || value.isEmpty ? '${widget.group.arabicName} مطلوب' : null
          : null,
      isExpanded: true,
      style: theme.textTheme.bodyLarge,
      dropdownColor: theme.cardColor,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  Widget _buildLoadingDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.labelText ?? widget.group.arabicName,
        prefixIcon:
            widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 22.sp) : Icon(_getDefaultIcon(), size: 22.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'جاري تحميل التصنيف...',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    final normalizedError = _normalizeErrorForDisplay(error);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.labelText ?? widget.group.arabicName,
        prefixIcon: Icon(Icons.error_outline, color: theme.colorScheme.error, size: 22.sp),
        errorText: 'فشل تحميل البيانات',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعذر تحميل بيانات ${widget.group.arabicName}.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
          SizedBox(height: 6.h),
          Text(
            normalizedError,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 8.w,
            children: [
              OutlinedButton.icon(
                onPressed: () => _invalidateTaxonomyCache(ref),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
              if (widget.showSyncAction)
                FilledButton.tonalIcon(
                  onPressed: () => _syncTaxonomiesAndRefresh(ref),
                  icon: const Icon(Icons.sync),
                  label: const Text('مزامنة التصنيفات'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropdown(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final autoSyncAttempted = ref.watch(bridgeGroupAutoSyncAttemptedProvider(widget.group));

    if (widget.showSyncAction && widget.autoSyncOnEmpty && !autoSyncAttempted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || !_isRefUsable(ref)) {
          return;
        }
        ref.read(bridgeGroupAutoSyncAttemptedProvider(widget.group).notifier).state = true;
        await _syncTaxonomiesAndRefresh(ref);
      });
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.labelText ?? widget.group.arabicName,
        prefixIcon:
            widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 22.sp) : Icon(_getDefaultIcon(), size: 22.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لا توجد بيانات لهذا التصنيف',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 8.w,
            children: [
              OutlinedButton.icon(
                onPressed: () => _invalidateTaxonomyCache(ref),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
              if (widget.showSyncAction)
                FilledButton.tonalIcon(
                  onPressed: () => _syncTaxonomiesAndRefresh(ref),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('مزامنة التصنيفات'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (widget.group) {
      case TaxonomyGroup.governorate:
        return Icons.location_city_rounded;
      case TaxonomyGroup.city:
        return Icons.location_on_rounded;
      case TaxonomyGroup.category:
        return Icons.category_rounded;
      case TaxonomyGroup.maritalStatus:
        return Icons.family_restroom_rounded;
      case TaxonomyGroup.displacementStatus:
        return Icons.alt_route_rounded;
      case TaxonomyGroup.employmentStatus:
        return Icons.work_outline_rounded;
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
      case TaxonomyGroup.guaranteeType:
        return Icons.verified_rounded;
      case TaxonomyGroup.documentType:
        return Icons.description_rounded;
      case TaxonomyGroup.bankName:
        return Icons.account_balance_rounded;
      case TaxonomyGroup.currency:
        return Icons.currency_exchange_rounded;
      case TaxonomyGroup.deathReason:
        return Icons.heart_broken_rounded;
      case TaxonomyGroup.gender:
        return Icons.wc_rounded;
      case TaxonomyGroup.visitType:
        return Icons.directions_walk_rounded;
      case TaxonomyGroup.assistanceType:
        return Icons.handshake_rounded;
      case TaxonomyGroup.beneficiaryStatus:
        return Icons.verified_user_rounded;
      case TaxonomyGroup.relationship:
        return Icons.family_restroom_rounded;
      case TaxonomyGroup.section:
        return Icons.account_tree_rounded;
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
    required this.group,
    required this.code,
    super.key,
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
    required this.group,
    required this.code,
    super.key,
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
              backgroundColor ?? (taxonomy.color != null ? _parseColor(taxonomy.color!).withValues(alpha: 0.2) : null),
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
