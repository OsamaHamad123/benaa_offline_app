import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/providers/providers.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import '../../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../../../../data/db/daos/sponsorships_dao.dart';
import '../../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../providers/kafalat_providers.dart';
import '../sponsorship_form_sheet.dart';
import '../cards/professional_sponsorship_card.dart';
import '../stats/stats_dashboard_widget.dart';
import '../filters/quick_filters_bar.dart';
import '../filters/enhanced_search_bar.dart';
import '../filters/sorting_menu.dart';
import '../actions/swipe_action_wrapper.dart';
import '../animations/card_entrance_animation.dart';
import '../empty_states/empty_states.dart';
import '../loaders/sponsorship_card_shimmer.dart';

/// 📋 Tab "مكفول" - قائمة الكفالات
class SponsoredTab extends ConsumerStatefulWidget {
  const SponsoredTab({super.key});

  @override
  ConsumerState<SponsoredTab> createState() => _SponsoredTabState();
}

class _SponsoredTabState extends ConsumerState<SponsoredTab> {
  final TextEditingController _searchController = TextEditingController();
  static const Map<String, String> _typeFallbackLabels = {
    'monthly': 'شهرية',
    'one_time': 'مرة واحدة',
    'other': 'أخرى',
  };
  static const Map<String, String> _statusFallbackLabels = {
    'active': 'نشطة',
    'paused': 'موقوفة',
    'ended': 'منتهية',
  };

  String? _associationId;
  String _status = 'all';
  String _type = 'all';
  String _query = '';
  SortOption _sortOption = SortOption.dateNewest;

  // حالة إظهار الإحصائيات والفلاتر
  bool _showStats = false;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v);
  }

  void _clearFilters() {
    setState(() {
      _associationId = null;
      _status = 'all';
      _type = 'all';
      _query = '';
      _searchController.clear();
    });
  }

  bool get _hasActiveFilters => _status != 'all' || _type != 'all' || _associationId != null || _query.isNotEmpty;

  Future<void> _confirmDelete(BuildContext context, int fileNo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: Text('هل تريد حذف الكفالة رقم ملف $fileNo؟', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final db = ref.read(databaseProvider);
      await db.sponsorshipsDao.deleteSponsorship(fileNo: fileNo);
      if (!mounted) return;
      HapticPatterns.success();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الكفالة')));
    } catch (e) {
      if (!mounted) return;
      HapticPatterns.error();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل حذف الكفالة: $e')));
    }
  }

  void _openEditSheet(BuildContext context, SponsorshipWithDetails row) {
    HapticPatterns.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: 'تعديل كفالة (رقم الملف: ${row.sponsorship.fileNo})',
        icon: Icons.edit_outlined,
        initialChildSize: 0.85,
        child: SponsorshipFormSheet(
          beneficiaryId: row.beneficiary.id,
          initialSponsorship: row.sponsorship,
        ),
      ),
    );
  }

  String _resolveTaxonomyLabel(
    String code,
    List<taxonomy_domain.Taxonomy> taxonomyItems,
    Map<String, String> fallbackLabels,
  ) {
    for (final taxonomy in taxonomyItems) {
      if (taxonomy.code == code) return taxonomy.label;
    }
    return fallbackLabels[code] ?? 'قيمة قديمة/غير معروفة';
  }

  bool _isLegacyFallbackUsed(
    String code,
    List<taxonomy_domain.Taxonomy> taxonomyItems,
    Map<String, String> fallbackLabels,
  ) {
    final existsInTaxonomy = taxonomyItems.any((item) => item.code == code);
    if (existsInTaxonomy) return false;
    return fallbackLabels.containsKey(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sponsorshipTypeTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.sponsorshipType),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );
    final beneficiaryStatusTaxonomies = ref
        .watch(
          bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.beneficiaryStatus),
        )
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );

    final hasTaxonomyGap = sponsorshipTypeTaxonomies.isEmpty || beneficiaryStatusTaxonomies.isEmpty;

    final resolveTypeLabel = (String value) => _resolveTaxonomyLabel(
          value,
          sponsorshipTypeTaxonomies,
          _typeFallbackLabels,
        );
    final resolveStatusLabel = (String value) => _resolveTaxonomyLabel(
          value,
          beneficiaryStatusTaxonomies,
          _statusFallbackLabels,
        );

    // تمرير الفلاتر للـ provider
    final sponsorshipsAsync = ref.watch(
      kafalatSponsorshipsProvider((
        associationId: _associationId,
        status: _status,
        type: _type,
        query: _query,
      )),
    );

    final associationsAsync = ref.watch(kafalatActiveAssociationsProvider);

    return Column(
      children: [
        if (hasTaxonomyGap)
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18.sp, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'لا توجد بيانات تصنيفات مكتملة بعد، يتم عرض قيم متوافقة مؤقتاً.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        // شريط مبسط للإحصائيات مع زر الإظهار/الإخفاء
        sponsorshipsAsync.when(
          data: (allRows) {
            final total = allRows.length;
            final active = allRows.where((r) => r.sponsorship.status == 'active').length;

            return Column(
              children: [
                // شريط مختصر
                Container(
                  margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.handshake_rounded, color: theme.colorScheme.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'الإجمالي: $total',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${resolveStatusLabel('active')}: $active',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // زر إظهار الإحصائيات الكاملة
                      IconButton(
                        icon: Icon(
                          _showStats ? Icons.expand_less : Icons.expand_more,
                          size: 20.sp,
                        ),
                        onPressed: () => setState(() => _showStats = !_showStats),
                        tooltip: _showStats ? 'إخفاء التفاصيل' : 'عرض التفاصيل',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                // الإحصائيات الكاملة (قابلة للطي)
                if (_showStats) SizedBox(height: 8.h),
                if (_showStats)
                  StatsDashboardWidget(
                    total: total,
                    active: active,
                    paused: allRows.where((r) => r.sponsorship.status == 'paused').length,
                    ended: allRows.where((r) => r.sponsorship.status == 'ended').length,
                    totalAmount: allRows
                        .where((r) => r.sponsorship.status == 'active' && r.sponsorship.amount != null)
                        .fold<double>(0, (sum, r) => sum + r.sponsorship.amount!),
                  ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // الفلاتر المدمجة (صف واحد مبسط)
        associationsAsync.when(
          data: (associations) {
            return Container(
              margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Row(
                children: [
                  // زر الفلاتر
                  InkWell(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: _showFilters || _hasActiveFilters
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _hasActiveFilters ? theme.colorScheme.primary : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18.sp,
                            color: _hasActiveFilters ? theme.colorScheme.primary : null,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'فلاتر',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: _hasActiveFilters ? FontWeight.w600 : null,
                              color: _hasActiveFilters ? theme.colorScheme.primary : null,
                            ),
                          ),
                          if (_hasActiveFilters) SizedBox(width: 4.w),
                          if (_hasActiveFilters)
                            Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(color: Colors.white, fontSize: 8.sp),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_hasActiveFilters) SizedBox(width: 8.w),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('مسح'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // لوحة الفلاتر الكاملة (قابلة للطي)
        if (_showFilters)
          associationsAsync.when(
            data: (associations) {
              return QuickFiltersBar(
                selectedStatus: _status,
                selectedType: _type,
                selectedAssociationId: _associationId,
                associations: associations.map((a) => (id: a.id, name: a.name)).toList(),
                onStatusChanged: (v) => setState(() => _status = v),
                onTypeChanged: (v) => setState(() => _type = v),
                onAssociationChanged: (v) => setState(() => _associationId = v),
                onClearFilters: _clearFilters,
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

        // Search & Sorting Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: EnhancedSearchBar(
                  controller: _searchController,
                  onSearch: _onSearchChanged,
                  hintText: 'ابحث برقم الملف، الاسم، الهوية...',
                ),
              ),
              SizedBox(width: 12.w),
              SortingMenu(
                currentSort: _sortOption,
                onSortChanged: (v) => setState(() => _sortOption = v),
              ),
            ],
          ),
        ),

        // Content with Responsive Layout
        Expanded(
          child: sponsorshipsAsync.when(
            data: (rows) {
              if (rows.isEmpty) {
                return EmptySponsorshipsState(
                  hasFilters: _hasActiveFilters,
                  onClearFilters: _hasActiveFilters ? _clearFilters : null,
                );
              }

              // ترتيب النتائج
              final sortedRows = _sortSponsorships(rows);

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(kafalatSponsorshipsProvider);
                  ref.invalidate(kafalatActiveAssociationsProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive: حساب عدد الأعمدة
                    final crossAxisCount = constraints.maxWidth >= 1200
                        ? 2
                        : constraints.maxWidth >= 700
                            ? 2
                            : 1;

                    if (crossAxisCount == 1) {
                      // Mobile - قائمة عادية
                      return ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: sortedRows.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, i) {
                          final r = sortedRows[i];
                          return CardEntranceAnimation(
                            index: i,
                            child: SwipeActionWrapper(
                              onEdit: () => _openEditSheet(context, r),
                              onDelete: () => _confirmDelete(context, r.sponsorship.fileNo),
                              child: ProfessionalSponsorshipCard(
                                row: r,
                                onEdit: () => _openEditSheet(context, r),
                                onDelete: () => _confirmDelete(context, r.sponsorship.fileNo),
                                typeLabel: resolveTypeLabel,
                                statusLabel: resolveStatusLabel,
                                showLegacyTypeBadge: _isLegacyFallbackUsed(
                                  r.sponsorship.sponsorshipType,
                                  sponsorshipTypeTaxonomies,
                                  _typeFallbackLabels,
                                ),
                                showLegacyStatusBadge: _isLegacyFallbackUsed(
                                  r.sponsorship.status,
                                  beneficiaryStatusTaxonomies,
                                  _statusFallbackLabels,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    // Tablet/Desktop - Grid
                    return GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: sortedRows.length,
                      itemBuilder: (context, i) {
                        final r = sortedRows[i];
                        return CardEntranceAnimation(
                          index: i,
                          child: ProfessionalSponsorshipCard(
                            row: r,
                            onEdit: () => _openEditSheet(context, r),
                            onDelete: () => _confirmDelete(context, r.sponsorship.fileNo),
                            typeLabel: resolveTypeLabel,
                            statusLabel: resolveStatusLabel,
                            showLegacyTypeBadge: _isLegacyFallbackUsed(
                              r.sponsorship.sponsorshipType,
                              sponsorshipTypeTaxonomies,
                              _typeFallbackLabels,
                            ),
                            showLegacyStatusBadge: _isLegacyFallbackUsed(
                              r.sponsorship.status,
                              beneficiaryStatusTaxonomies,
                              _statusFallbackLabels,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const SponsorshipListShimmer(itemCount: 6),
            error: (e, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 56.sp, color: theme.colorScheme.error),
                    SizedBox(height: 16.h),
                    Text('خطأ في تحميل البيانات', style: theme.textTheme.titleLarge),
                    SizedBox(height: 8.h),
                    Text('$e', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // دالة الترتيب
  List<SponsorshipWithDetails> _sortSponsorships(List<SponsorshipWithDetails> rows) {
    final sorted = List<SponsorshipWithDetails>.from(rows);

    sorted.sort((a, b) {
      switch (_sortOption) {
        case SortOption.dateNewest:
          return b.sponsorship.createdAt.compareTo(a.sponsorship.createdAt);
        case SortOption.dateOldest:
          return a.sponsorship.createdAt.compareTo(b.sponsorship.createdAt);
        case SortOption.amountHighest:
          final amountA = a.sponsorship.amount ?? 0;
          final amountB = b.sponsorship.amount ?? 0;
          return amountB.compareTo(amountA);
        case SortOption.amountLowest:
          final amountA = a.sponsorship.amount ?? 0;
          final amountB = b.sponsorship.amount ?? 0;
          return amountA.compareTo(amountB);
        case SortOption.nameAZ:
          return a.beneficiary.fullName.compareTo(b.beneficiary.fullName);
        case SortOption.nameZA:
          return b.beneficiary.fullName.compareTo(a.beneficiary.fullName);
        case SortOption.fileNoAsc:
          return a.sponsorship.fileNo.compareTo(b.sponsorship.fileNo);
        case SortOption.fileNoDesc:
          return b.sponsorship.fileNo.compareTo(a.sponsorship.fileNo);
      }
    });

    return sorted;
  }
}
