import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../providers/associations_provider.dart';
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
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
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

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredAssociations = filteredAssociations.where((a) {
        final nameMatch = a.name.toLowerCase().contains(_searchQuery);
        final shortNameMatch = a.shortName?.toLowerCase().contains(_searchQuery) ?? false;
        final phoneMatch = a.phone.toLowerCase().contains(_searchQuery);
        final representative = state.representatives.where((r) => r.id == a.representativeId).firstOrNull;
        final repMatch = representative?.name.toLowerCase().contains(_searchQuery) ?? false;
        final bankMatch = a.bankName.toLowerCase().contains(_searchQuery);
        final accountMatch = a.accountNumber.toLowerCase().contains(_searchQuery);
        final associationTypeLabel = associationTypeLabelByCode[a.associationTypeCode?.trim() ?? ''];
        final associationTypeMatch = associationTypeLabel?.toLowerCase().contains(_searchQuery) ?? false;

        return nameMatch ||
            shortNameMatch ||
            phoneMatch ||
            repMatch ||
            bankMatch ||
            accountMatch ||
            associationTypeMatch;
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
            firstChild: AssociationsFiltersBar(
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

  /// قائمة الجمعيات مع تصميم Responsive Grid
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
                : 1; // Mobile: عمود واحد

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🏢 Grid بطاقات الجمعيات
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.mediumSpace,
                ResponsiveUtils.smallSpace,
                ResponsiveUtils.mediumSpace,
                ResponsiveUtils.mediumSpace,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 2.h, // مسافة صغيرة جداً بين البطاقات
                  crossAxisSpacing: ResponsiveUtils.getListSpacing(context),
                  childAspectRatio: crossAxisCount == 1
                      ? 1.1 // Mobile: compact وعرض أكثر
                      : crossAxisCount == 2
                          ? 1.15 // Tablet: compact
                          : 1.2, // Desktop: compact
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final association = associations[index];
                    final representative =
                        state.representatives.where((r) => r.id == association.representativeId).firstOrNull;

                    // استخدام البطاقة الاحترافية الجديدة مع Swipe Actions و Animations
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
                          associationTypeLabel: associationTypeLabelByCode[
                              _normalizeNullableFilter(association.associationTypeCode) ?? ''],
                          representativeName: representative?.name,
                          isActive: association.isActive,
                          createdAt: association.createdAt,
                          updatedAt: association.updatedAt,
                          onTap: () => _showAssociationDetailsSheet(
                            association,
                            representativeName: representative?.name,
                            associationTypeLabel: associationTypeLabelByCode[
                                _normalizeNullableFilter(association.associationTypeCode) ?? ''],
                          ),
                          onEdit: () => _showEditAssociationSheet(association),
                          onDelete: () => _confirmDelete(association.id, association.name),
                        ),
                      ),
                    );
                  },
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
