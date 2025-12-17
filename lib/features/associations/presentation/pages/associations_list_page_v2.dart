import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../providers/associations_provider.dart';
import '../widgets/association_card_v2.dart';
import '../widgets/associations_skeleton_loader.dart';
import '../widgets/associations_search_bar.dart';
import '../widgets/associations_filter_button.dart';
import '../widgets/associations_result_counter.dart';
import '../widgets/associations_empty_state.dart';
import '../widgets/associations_filter_sheet.dart';
import 'association_form_bottom_sheet.dart';

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
  bool _showOnlyActive = true;
  String? _selectedRepresentativeId;
  String? _selectedCurrency; // ✨ فلتر العملة

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
        onApply: (showActive, repId, currency) {
          setState(() {
            _showOnlyActive = showActive;
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
          child: const AssociationFormBottomSheet(),
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

    // تطبيق الفلاتر والبحث المتقدم
    var filteredAssociations = state.associations;

    if (_searchQuery.isNotEmpty) {
      filteredAssociations = filteredAssociations.where((a) {
        // البحث في الاسم
        final nameMatch = a.name.toLowerCase().contains(_searchQuery);

        // البحث في الاسم المختصر
        final shortNameMatch = a.shortName?.toLowerCase().contains(_searchQuery) ?? false;

        // البحث في الهاتف
        final phoneMatch = a.phone.toLowerCase().contains(_searchQuery);

        // البحث في اسم المندوب
        final representative = state.representatives.where((r) => r.id == a.representativeId).firstOrNull;
        final repMatch = representative?.name.toLowerCase().contains(_searchQuery) ?? false;

        // البحث في اسم البنك
        final bankMatch = a.bankName.toLowerCase().contains(_searchQuery);

        // البحث في رقم الحساب
        final accountMatch = a.accountNumber.toLowerCase().contains(_searchQuery);

        return nameMatch || shortNameMatch || phoneMatch || repMatch || bankMatch || accountMatch;
      }).toList();
    }

    if (_showOnlyActive) {
      filteredAssociations = filteredAssociations.where((a) => a.isActive).toList();
    }

    if (_selectedRepresentativeId != null) {
      filteredAssociations =
          filteredAssociations.where((a) => a.representativeId == _selectedRepresentativeId).toList();
    }

    if (_selectedCurrency != null) {
      filteredAssociations = filteredAssociations.where((a) => a.accountCurrency == _selectedCurrency).toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'إدارة الجمعيات',
        showGradient: true,
        actions: [
          AssociationsFilterButton(
            onPressed: _showFilterSheet,
            hasActiveFilters: !_showOnlyActive || _selectedRepresentativeId != null || _selectedCurrency != null,
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
            onClearAll: () {
              setState(() {
                _searchQuery = '';
                _showOnlyActive = true;
                _selectedRepresentativeId = null;
                _selectedCurrency = null;
              });
            },
          ),

          // ✨ عداد النتائج
          if (filteredAssociations.isNotEmpty && !state.isLoading)
            AssociationsResultCounter(
              count: filteredAssociations.length,
              hasActiveFilters:
                  _searchQuery.isNotEmpty || _selectedRepresentativeId != null || _selectedCurrency != null,
            ),

          // المحتوى الرئيسي
          Expanded(
            child: state.isLoading
                ? _buildSkeletonLoader()
                : filteredAssociations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(associationsProvider.notifier).loadAssociations();
                        },
                        color: colorScheme.primary,
                        backgroundColor: Colors.white,
                        child: _buildAssociationsList(filteredAssociations),
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

  /// قائمة الجمعيات
  Widget _buildAssociationsList(List associations) {
    final responsive = ResponsiveUtils.getValues(context);

    return ListView.separated(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      itemCount: associations.length,
      separatorBuilder: (_, __) => SizedBox(height: responsive.spacing),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final association = associations[index];
        final representative = ref
            .read(associationsProvider)
            .representatives
            .where((r) => r.id == association.representativeId)
            .firstOrNull;

        return AssociationCardV2(
          association: association,
          representativeName: representative?.name,
          onTap: () => _showEditAssociationSheet(association),
          onDelete: () => _confirmDelete(association.id, association.name),
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
      builder: (context) => AssociationFormBottomSheet(association: association),
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
