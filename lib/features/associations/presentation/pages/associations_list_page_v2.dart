import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../providers/associations_provider.dart';
import '../widgets/association_card_v2.dart';
import '../widgets/associations_skeleton_loader.dart';
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _FilterSheet(
        showOnlyActive: _showOnlyActive,
        selectedRepresentativeId: _selectedRepresentativeId,
        onApply: (showActive, repId) {
          setState(() {
            _showOnlyActive = showActive;
            _selectedRepresentativeId = repId;
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
      builder: (context) => const AssociationFormBottomSheet(),
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

    // تطبيق الفلاتر
    var filteredAssociations = state.associations;

    if (_searchQuery.isNotEmpty) {
      filteredAssociations = filteredAssociations
          .where((a) =>
              a.name.toLowerCase().contains(_searchQuery) ||
              (a.phone.toLowerCase().contains(_searchQuery)) ||
              (a.shortName?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }

    if (_showOnlyActive) {
      filteredAssociations = filteredAssociations.where((a) => a.isActive).toList();
    }

    if (_selectedRepresentativeId != null) {
      filteredAssociations =
          filteredAssociations.where((a) => a.representativeId == _selectedRepresentativeId).toList();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'إدارة الجمعيات',
        showGradient: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white, size: 24.r),
            onPressed: _showFilterSheet,
            tooltip: 'الفلاتر',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(colorScheme),

          // المحتوى الرئيسي
          Expanded(
            child: state.isLoading
                ? _buildSkeletonLoader()
                : filteredAssociations.isEmpty
                    ? _buildEmptyState()
                    : _buildAssociationsList(filteredAssociations),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAssociationSheet,
        icon: Icon(Icons.add, size: 24.r),
        label: Text('إضافة جمعية', style: TextStyle(fontSize: 14.sp)),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  /// شريط البحث
  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث عن جمعية...',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: colorScheme.primary, size: 24.r),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty || !_showOnlyActive || _selectedRepresentativeId != null)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                icon: Icon(Icons.clear, size: 24.r),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _showOnlyActive = true;
                    _selectedRepresentativeId = null;
                  });
                },
                tooltip: 'مسح البحث',
              ),
            ),
        ],
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
        message: 'لم يتم العثور على جمعيات تطابق "فيلتر $_searchQuery"',
        actionLabel: 'مسح البحث',
        onAction: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      );
    }

    return CustomEmptyState(
      icon: Icons.business_outlined,
      title: 'لا توجد جمعيات',
      message: 'قم بإضافة جمعية جديدة للبدء',
      actionLabel: 'إضافة جمعية',
      onAction: _showAddAssociationSheet,
    );
  }

  /// قائمة الجمعيات
  Widget _buildAssociationsList(List associations) {
    final responsive = ResponsiveUtils.getValues(context);

    return ListView.separated(
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      itemCount: associations.length,
      separatorBuilder: (_, __) => SizedBox(height: responsive.spacing),
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

/// ورقة الفلاتر - محسّنة بـ ValueNotifier بدلاً من setState
class _FilterSheet extends ConsumerWidget {
  final bool showOnlyActive;
  final String? selectedRepresentativeId;
  final Function(bool, String?) onApply;

  const _FilterSheet({
    required this.showOnlyActive,
    required this.selectedRepresentativeId,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final representatives = ref.watch(associationsProvider).representatives;
    final colorScheme = Theme.of(context).colorScheme;

    final showActiveNotifier = ValueNotifier<bool>(showOnlyActive);
    final selectedRepNotifier = ValueNotifier<String?>(selectedRepresentativeId);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'الفلاتر',
                style: TextStyle(
                  fontSize: ResponsiveUtils.titleFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          SizedBox(height: ResponsiveUtils.largeSpace),

          // فلتر النشطة فقط
          ValueListenableBuilder<bool>(
            valueListenable: showActiveNotifier,
            builder: (context, showActive, _) => SwitchListTile(
              value: showActive,
              onChanged: (value) => showActiveNotifier.value = value,
              title: const Text('عرض الجمعيات النشطة فقط', textAlign: TextAlign.right),
              activeColor: colorScheme.primary,
            ),
          ),

          SizedBox(height: ResponsiveUtils.mediumSpace),

          // فلتر المندوب
          Text(
            'تصفية حسب المندوب',
            style: TextStyle(
              fontSize: ResponsiveUtils.bodyFont,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),

          SizedBox(height: ResponsiveUtils.smallSpace),

          ValueListenableBuilder<String?>(
            valueListenable: selectedRepNotifier,
            builder: (context, selectedRep, _) => DropdownButtonFormField<String?>(
              value: selectedRep,
              decoration: InputDecoration(
                hintText: 'اختر المندوب',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.mediumSpace,
                  vertical: 12.h,
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...representatives.map(
                  (rep) => DropdownMenuItem(
                    value: rep.id,
                    child: Text(rep.name, textAlign: TextAlign.right),
                  ),
                ),
              ],
              onChanged: (value) => selectedRepNotifier.value = value,
            ),
          ),

          SizedBox(height: ResponsiveUtils.largeSpace),

          // زر التطبيق
          ElevatedButton(
            onPressed: () => onApply(showActiveNotifier.value, selectedRepNotifier.value),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
            ),
            child: Text(
              'تطبيق الفلاتر',
              style: TextStyle(
                fontSize: ResponsiveUtils.mediumFont,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
