import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../providers/associations_provider.dart';
import '../widgets/associations_skeleton_loader.dart';
import '../widgets/associations_search_bar.dart';
import '../widgets/associations_filter_button.dart';
import '../widgets/associations_result_counter.dart';
import '../widgets/associations_empty_state.dart';
import '../widgets/associations_filter_sheet.dart';
import '../widgets/enhanced_associations_stats_card.dart';
import '../widgets/professional_association_card.dart'; // 🎨 البطاقة الاحترافية الجديدة
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

  // Sorting
  SortOption _currentSort = SortOption.nameAsc;

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
        showOnlyActive: true,
        selectedRepresentativeId: _selectedRepresentativeId,
        selectedCurrency: _selectedCurrency,
        onApply: (showActive, repId, currency) {
          setState(() {
            _selectedRepresentativeId = repId;
            _selectedCurrency = currency;
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
      builder: (context) => Hero(
        tag: 'association_new',
        child: Material(
          type: MaterialType.transparency,
          child: const AssociationFormBottomSheetModern(),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveUtils.isTablet(context);

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

        return nameMatch || shortNameMatch || phoneMatch || repMatch || bankMatch || accountMatch;
      }).toList();
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
    if (_selectedRepresentativeId != null) {
      filteredAssociations =
          filteredAssociations.where((a) => a.representativeId == _selectedRepresentativeId).toList();
    }

    // Advanced Filter - Currency
    if (_selectedCurrency != null) {
      filteredAssociations = filteredAssociations.where((a) => a.accountCurrency == _selectedCurrency).toList();
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
        showGradient: true,
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
            hasActiveFilters: _selectedRepresentativeId != null || _selectedCurrency != null,
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
            showOnlyActive: true,
            onClearAll: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _selectedFilterStatus = null;
                _selectedBank = null;
                _selectedRepresentativeId = null;
                _selectedCurrency = null;
              });
            },
          ),

          // Quick Filters Bar
          AssociationsFiltersBar(
            selectedStatus: _selectedFilterStatus,
            selectedBank: _selectedBank,
            availableBanks: _getUniqueBanks(state.associations),
            onStatusChanged: (status) {
              setState(() => _selectedFilterStatus = status);
            },
            onBankChanged: (bank) {
              setState(() => _selectedBank = bank);
            },
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
                        child: _buildAssociationsList(sortedAssociations),
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
  List<String> _getUniqueBanks(List associations) {
    final banks = associations.map<String>((a) => a.bankName as String).toSet().toList();
    banks.sort();
    return banks;
  }

  /// قائمة الجمعيات مع تصميم Responsive Grid
  Widget _buildAssociationsList(List associations) {
    final state = ref.read(associationsProvider);
    // حساب الإحصائيات
    final totalCount = associations.length;
    final activeCount = associations.where((a) => a.isActive).length;
    final inactiveCount = totalCount - activeCount;

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
            // 📊 بطاقة الإحصائيات المحسّنة في الأعلى
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.mediumSpace,
                ResponsiveUtils.mediumSpace,
                ResponsiveUtils.mediumSpace,
                ResponsiveUtils.smallSpace,
              ),
              sliver: SliverToBoxAdapter(
                child: EnhancedAssociationsStatsCard(
                  totalCount: totalCount,
                  activeCount: activeCount,
                  inactiveCount: inactiveCount,
                ),
              ),
            ),

            // 🎯 عداد النتائج (إن وجد فلتر)
            if (_searchQuery.isNotEmpty || _selectedRepresentativeId != null || _selectedCurrency != null)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.mediumSpace,
                  vertical: ResponsiveUtils.smallSpace,
                ),
                sliver: SliverToBoxAdapter(
                  child: AssociationsResultCounter(
                    count: totalCount,
                    hasActiveFilters: true,
                  ),
                ),
              ),

            // 🏢 Grid بطاقات الجمعيات
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: 0, // إزالة المسافة العمودية
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
                          representativeName: representative?.name,
                          isActive: association.isActive,
                          createdAt: association.createdAt,
                          updatedAt: association.updatedAt,
                          onTap: () => _showEditAssociationSheet(association),
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
