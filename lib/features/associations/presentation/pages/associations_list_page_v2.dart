import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../providers/associations_provider.dart';
import '../../../kafalat/presentation/providers/kafalat_providers.dart';
import '../widgets/associations_skeleton_loader.dart';
import '../widgets/associations_search_bar.dart';
import '../widgets/associations_filter_button.dart';
import '../widgets/associations_result_counter.dart';
import '../widgets/associations_empty_state.dart';
import '../widgets/associations_filter_sheet.dart';
import '../widgets/professional_association_card.dart'; // 🎨 البطاقة الاحترافية الجديدة
import '../widgets/association_details_sheet.dart';
import '../widgets/swipe_actions_wrapper.dart'; // 👆 Swipe Actions
import '../widgets/associations_filters_bar.dart'; // 🔍 Quick Filters
import '../widgets/sorting_menu.dart'; // 🔄 Sorting Menu
import '../widgets/card_animations.dart'; // 🎬 Animations
import 'association_form_bottom_sheet_modern.dart';

/// 🏢 صفحة قائمة الجمعيات - إصدار محسّن
///
/// ✅ استخدام ResponsiveUtils
/// ✅ Skeleton Loader عند التحميل
/// ✅ بحث متقدم مع فلاتر
/// ✅ Empty State مع Animation
/// ✅ Theme موحد مع التطبيق
class AssociationsListPageV2 extends ConsumerStatefulWidget {
  const AssociationsListPageV2({super.key});

  @override
  ConsumerState<AssociationsListPageV2> createState() => _AssociationsListPageV2State();
}

class _AssociationsListPageV2State extends ConsumerState<AssociationsListPageV2> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  // Quick Filters
  String? _selectedFilterStatus; // null='الكل', 'active'='النشطة', 'inactive'='المعطلة'
  String? _selectedBank;

  // Advanced Filters
  String? _selectedRepresentativeId;
  String? _selectedCurrency;
  String? _selectedAssociationTypeCode;
  bool _showOnlyActive = true;

  // Progressive disclosure: أدوات سريعة/إضافية مخفية افتراضيًا
  bool _showQuickTools = false;

  // Sorting
  SortOption _currentSort = SortOption.nameAsc;

  String? _normalizeNullableFilter(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _normalizeCurrencyCode(String? value) {
    final normalized = _normalizeNullableFilter(value);
    return normalized?.toUpperCase();
  }

  bool get _hasActiveFilters {
    return _selectedFilterStatus != null ||
        _selectedBank != null ||
        _normalizeNullableFilter(_selectedRepresentativeId) != null ||
        _normalizeNullableFilter(_selectedCurrency) != null ||
        _normalizeNullableFilter(_selectedAssociationTypeCode) != null;
  }

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(associationsProvider.notifier).loadAssociations();
      ref.read(associationsProvider.notifier).loadRepresentatives();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.isEmpty) {
      if (mounted) setState(() => _searchQuery = '');
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final normalized = ArabicNormalizer.normalize(value.trim());
      setState(() => _searchQuery = normalized);
    });
  }

  void _showFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.largeRadius),
        ),
      ),
      builder: (context) => AssociationsFilterSheet(
        showOnlyActive: _showOnlyActive,
        selectedRepresentativeId: _selectedRepresentativeId,
        selectedCurrency: _selectedCurrency,
        selectedAssociationTypeCode: _selectedAssociationTypeCode,
        onApply: (showActive, repId, currency, associationTypeCode) {
          setState(() {
            _showOnlyActive = showActive;
            _selectedRepresentativeId = _normalizeNullableFilter(repId);
            _selectedCurrency = _normalizeNullableFilter(currency);
            _selectedAssociationTypeCode = _normalizeNullableFilter(associationTypeCode);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddAssociationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const Hero(
        tag: 'association_new',
        child: Material(
          type: MaterialType.transparency,
          child: AssociationFormBottomSheetModern(),
        ),
      ),
    ).then((created) {
      if (created == true) {
        ref.read(associationsProvider.notifier).loadAssociations();
      }
    });
  }

  Future<void> _runCedarAssociationsSeed({bool force = false}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('جاري إضافة جمعيات Cedar...')),
          ],
        ),
      ),
    );

    final result = await ref.read(associationsProvider.notifier).seedCedarAssociations(force: force);
    ref.invalidate(kafalatActiveAssociationsProvider);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      final summary =
          'Cedar Associations Seed: created=${result.created} skipped=${result.skipped} updated=${result.updated} failed=${result.failed}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(summary)));
    }

    developer.log(
      '[CedarAssociations] created=${result.created} skipped=${result.skipped} updated=${result.updated} failed=${result.failed}',
      name: 'CedarAssociations',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(associationsProvider);
    final bankTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.bankName),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );
    final associationTypeTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupResolvedOnceProvider(TaxonomyGroup.associationType),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveUtils.isTablet(context);

    final bankNamesFromTaxonomy =
        bankTaxonomies.map((t) => t.label.trim()).where((label) => label.isNotEmpty).toList(growable: false);
    final associationTypeLabelByCode = <String, String>{
      for (final taxonomy in associationTypeTaxonomies)
        if (taxonomy.code.trim().isNotEmpty && taxonomy.label.trim().isNotEmpty)
          taxonomy.code.trim(): taxonomy.label.trim(),
    };

    // تطبيق الفلاتر والبحث
    var filteredAssociations = state.associations;

    // Search filter — normalized (Arabic + case-insensitive)
    if (_searchQuery.isNotEmpty) {
      filteredAssociations = filteredAssociations.where((a) {
        bool _contains(String? text) {
          if (text == null || text.isEmpty) return false;
          return ArabicNormalizer.normalize(text).contains(_searchQuery);
        }

        final representative = state.representatives.where((r) => r.id == a.representativeId).firstOrNull;
        final associationTypeLabel = associationTypeLabelByCode[a.associationTypeCode?.trim() ?? ''];

        return _contains(a.name) ||
            _contains(a.shortName) ||
            _contains(a.phone) ||
            _contains(representative?.name) ||
            _contains(a.bankName) ||
            _contains(a.accountNumber) ||
            _contains(associationTypeLabel);
      }).toList();
    }

    if (_showOnlyActive) {
      filteredAssociations = filteredAssociations.where((a) => a.isActive).toList();
    }

    // Quick Filter - Status
    if (_selectedFilterStatus == 'active') {
      filteredAssociations = filteredAssociations.where((a) => a.isActive).toList();
    } else if (_selectedFilterStatus == 'inactive') {
      filteredAssociations = filteredAssociations.where((a) => !a.isActive).toList();
    }

    // Quick Filter - Bank
    if (_selectedBank != null) {
      filteredAssociations = filteredAssociations.where((a) => a.bankName == _selectedBank).toList();
    }

    // Advanced Filter - Representative
    if (_normalizeNullableFilter(_selectedRepresentativeId) != null) {
      filteredAssociations =
          filteredAssociations.where((a) => a.representativeId == _selectedRepresentativeId).toList();
    }

    // Advanced Filter - Currency
    if (_normalizeNullableFilter(_selectedCurrency) != null) {
      final selectedCurrencyCode = _normalizeCurrencyCode(_selectedCurrency);
      filteredAssociations =
          filteredAssociations.where((a) => _normalizeCurrencyCode(a.accountCurrency) == selectedCurrencyCode).toList();
    }

    // Advanced Filter - Association Type
    if (_normalizeNullableFilter(_selectedAssociationTypeCode) != null) {
      filteredAssociations = filteredAssociations
          .where((a) =>
              _normalizeNullableFilter(a.associationTypeCode) == _normalizeNullableFilter(_selectedAssociationTypeCode))
          .toList();
    }

    // Sorting - إنشاء نسخة قابلة للتعديل قبل الترتيب
    final sortedAssociations = List.from(filteredAssociations)
      ..sort((a, b) {
        switch (_currentSort) {
          case SortOption.nameAsc:
            return a.name.compareTo(b.name);
          case SortOption.nameDesc:
            return b.name.compareTo(a.name);
          case SortOption.dateNewest:
            return b.createdAt.compareTo(a.createdAt);
          case SortOption.dateOldest:
            return a.createdAt.compareTo(b.createdAt);
        }
      });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'إدارة الجمعيات',
        actions: [
          // Sorting Menu
          SortingMenu(
            currentSort: _currentSort,
            onSortChanged: (newSort) {
              setState(() => _currentSort = newSort);
            },
          ),
          SizedBox(width: 8.w),
          // Advanced Filters Button
          AssociationsFilterButton(
            onPressed: _showFilterSheet,
            hasActiveFilters: _normalizeNullableFilter(_selectedRepresentativeId) != null ||
                _normalizeNullableFilter(_selectedCurrency) != null ||
                _normalizeNullableFilter(_selectedAssociationTypeCode) != null,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          AssociationsSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            searchQuery: _searchQuery,
            showOnlyActive: _showOnlyActive,
            selectedRepresentativeId: _selectedRepresentativeId,
            selectedCurrency: _selectedCurrency,
            selectedAssociationTypeCode: _selectedAssociationTypeCode,
            onClearAll: () {
              setState(() {
                _showOnlyActive = true;
                _searchQuery = '';
                _searchController.clear();
                _selectedFilterStatus = null;
                _selectedBank = null;
                _selectedRepresentativeId = null;
                _selectedCurrency = null;
                _selectedAssociationTypeCode = null;
                _showQuickTools = false;
              });
            },
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.mediumSpace,
              ResponsiveUtils.smallSpace,
              ResponsiveUtils.mediumSpace,
              ResponsiveUtils.smallSpace,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AssociationsResultCounter(
                    count: sortedAssociations.length,
                    hasActiveFilters: _hasActiveFilters,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _showQuickTools = !_showQuickTools),
                      tooltip: _showQuickTools ? 'إخفاء الأدوات' : 'إظهار الأدوات',
                      icon: Icon(
                        _showQuickTools ? Icons.tune_rounded : Icons.tune_outlined,
                        color: _showQuickTools ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _showQuickTools ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AssociationsFiltersBar(
                  selectedStatus: _selectedFilterStatus,
                  selectedBank: _selectedBank,
                  selectedAssociationTypeCode: _selectedAssociationTypeCode,
                  availableBanks: _getUniqueBanks(
                    state.associations,
                    taxonomyBanks: bankNamesFromTaxonomy,
                  ),
                  associationTypeOptions: associationTypeLabelByCode,
                  onStatusChanged: (status) {
                    setState(() => _selectedFilterStatus = status);
                  },
                  onBankChanged: (bank) {
                    setState(() => _selectedBank = bank);
                  },
                  onAssociationTypeChanged: (associationTypeCode) {
                    setState(() => _selectedAssociationTypeCode = _normalizeNullableFilter(associationTypeCode));
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveUtils.mediumSpace,
                    0,
                    ResponsiveUtils.mediumSpace,
                    ResponsiveUtils.smallSpace,
                  ),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (kDebugMode) ...[
                        OutlinedButton.icon(
                          onPressed: () => _runCedarAssociationsSeed(force: false),
                          icon: const Icon(Icons.playlist_add_check_circle_outlined),
                          label: const Text('إضافة جمعيات Cedar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _runCedarAssociationsSeed(force: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('رفع Seed الجمعيات (force)'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // المحتوى الرئيسي
          Expanded(
            child: state.isLoading
                ? _buildSkeletonLoader()
                : sortedAssociations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(associationsProvider.notifier).loadAssociations();
                        },
                        color: colorScheme.primary,
                        backgroundColor: Colors.white,
                        child: _buildAssociationsList(
                          sortedAssociations,
                          associationTypeLabelByCode: associationTypeLabelByCode,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddAssociationSheet();
        },
        icon: Icon(
          Icons.add_business,
          size: isTablet ? 24.r : 20.r,
        ),
        label: Text(
          'إضافة جمعية',
          style: TextStyle(
            fontSize: isTablet ? ResponsiveUtils.mediumFont : ResponsiveUtils.bodyFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUtils.largeRadius),
        ),
      ),
    );
  }

  /// Skeleton Loader
  Widget _buildSkeletonLoader() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      child: AssociationsSkeletonLoader(
        itemCount: ResponsiveUtils.isMobile(context) ? 4 : 6,
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return CustomEmptyState(
        icon: Icons.search_off,
        title: 'لم يتم العثور على نتائج',
        message: 'لم يتم العثور على جمعيات تطابق "$_searchQuery"',
        actionLabel: 'مسح البحث',
        onAction: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      );
    }

    return AssociationsEmptyState(
      onAddPressed: _showAddAssociationSheet,
    );
  }

  /// الحصول على قائمة البنوك الفريدة
  List<String> _getUniqueBanks(List associations, {List<String> taxonomyBanks = const []}) {
    final banks = <String>{
      ...taxonomyBanks.where((name) => name.trim().isNotEmpty),
      ...associations.map<String>((a) => (a.bankName as String).trim()).where((name) => name.isNotEmpty),
    }.toList();
    banks.sort();
    return banks;
  }

  /// قائمة الجمعيات مع تصميم Responsive
  Widget _buildAssociationsList(
    List associations, {
    required Map<String, String> associationTypeLabelByCode,
  }) {
    final state = ref.read(associationsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد عدد الأعمدة بناءً على عرض الشاشة
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3 // Desktop: 3 أعمدة
            : constraints.maxWidth > 720
                ? 2 // Tablet: عمودين
                : 1; // Mobile: عمود واحد — SliverList بدون aspect ratio

        // دالة بناء عنصر واحد (مشتركة بين List وGrid)
        Widget buildItem(BuildContext ctx, int index) {
          final association = associations[index];
          final representative = state.representatives.where((r) => r.id == association.representativeId).firstOrNull;

          return CardAnimationWrapper(
            index: index,
            child: SwipeActionsWrapper(
              itemName: association.name,
              onEdit: () => _showEditAssociationSheet(association),
              onDelete: () => _confirmDelete(association.id, association.name),
              child: ProfessionalAssociationCard(
                id: association.id,
                name: association.name,
                shortName: association.shortName,
                phone: association.phone,
                email: association.email,
                bankName: association.bankName,
                accountNumber: association.accountNumber,
                currency: association.accountCurrency,
                associationTypeLabel:
                    associationTypeLabelByCode[_normalizeNullableFilter(association.associationTypeCode) ?? ''],
                representativeName: representative?.name,
                isActive: association.isActive,
                createdAt: association.createdAt,
                updatedAt: association.updatedAt,
                onTap: () => _showAssociationDetailsSheet(
                  association,
                  representativeName: representative?.name,
                  associationTypeLabel:
                      associationTypeLabelByCode[_normalizeNullableFilter(association.associationTypeCode) ?? ''],
                ),
                onEdit: () => _showEditAssociationSheet(association),
                onDelete: () => _confirmDelete(association.id, association.name),
              ),
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 16.h),
              sliver: crossAxisCount == 1
                  // Mobile: SliverList — الكارد يتحدد حجمه من المحتوى، لا من aspect ratio
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        buildItem,
                        childCount: associations.length,
                      ),
                    )
                  // Tablet / Desktop: SliverGrid
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 6.h,
                        crossAxisSpacing: 8.w,
                        childAspectRatio: crossAxisCount == 2 ? 1.9 : 2.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        buildItem,
                        childCount: associations.length,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// تعديل جمعية
  void _showEditAssociationSheet(association) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssociationFormBottomSheetModern(association: association),
    ).then((updated) {
      if (updated == true) {
        ref.read(associationsProvider.notifier).loadAssociations();
      }
    });
  }

  void _showAssociationDetailsSheet(association, {String? representativeName, String? associationTypeLabel}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssociationDetailsSheet(
        association: association,
        representativeName: representativeName,
        associationTypeLabel: associationTypeLabel,
        onEdit: () => _showEditAssociationSheet(association),
      ),
    );
  }

  /// تأكيد الحذف
  Future<void> _confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: Text(
          'هل أنت متأكد من حذف الجمعية "$name"؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(associationsProvider.notifier).deleteAssociation(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الجمعية بنجاح')),
        );
      }
    }
  }
}
