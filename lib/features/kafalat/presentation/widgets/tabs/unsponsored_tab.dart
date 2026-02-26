import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:benaa_offline_app/features/kafalat/presentation/providers/kafalat_providers.dart';
import 'package:benaa_offline_app/features/kafalat/presentation/widgets/cards/unsponsored_beneficiary_card.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/providers.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import '../../../../../core/widgets/shimmer_loaders.dart';
import '../../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../filters/enhanced_search_bar.dart';

/// 📋 Tab "غير مكفول" - قائمة المستفيدين غير المكفولين
class UnsponsoredTab extends ConsumerStatefulWidget {
  const UnsponsoredTab({super.key});

  @override
  ConsumerState<UnsponsoredTab> createState() => _UnsponsoredTabState();
}

class _UnsponsoredTabState extends ConsumerState<UnsponsoredTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showTools = false;
  bool _selectionMode = false;
  final Set<int> _selectedBeneficiaryIds = <int>{};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() => _query = value.trim());
  }

  int _priorityScore(Beneficiary beneficiary) {
    var score = 0;
    final familySize = beneficiary.numberOfIndividuals ?? 0;
    final specialNeeds = beneficiary.numberOfPeopleWithSpecialNeeds ?? 0;
    final chronic = beneficiary.numberOfIndividualsWithChronicDiseases ?? 0;
    final createdAt = beneficiary.createdAt ?? DateTime.now();

    score += familySize.clamp(0, 20);
    score += specialNeeds * 5;
    score += chronic * 3;

    final waitingDays = DateTime.now().difference(createdAt).inDays;
    score += (waitingDays ~/ 30).clamp(0, 12);

    return score;
  }

  List<Beneficiary> _sortedByPriority(List<Beneficiary> items) {
    final beneficiaries = List<Beneficiary>.from(items);
    beneficiaries.sort((a, b) {
      final scoreDiff = _priorityScore(b).compareTo(_priorityScore(a));
      if (scoreDiff != 0) return scoreDiff;
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateA.compareTo(dateB);
    });
    return beneficiaries;
  }

  void _toggleSelection(int beneficiaryId) {
    setState(() {
      if (_selectedBeneficiaryIds.contains(beneficiaryId)) {
        _selectedBeneficiaryIds.remove(beneficiaryId);
      } else {
        _selectedBeneficiaryIds.add(beneficiaryId);
      }
    });
  }

  Future<void> _openBulkSponsorshipSheet() async {
    List<Association> associations;
    List<taxonomy_domain.Taxonomy> sponsorshipTypeTaxonomies;
    List<taxonomy_domain.Taxonomy> guaranteeTypeTaxonomies;
    List<taxonomy_domain.Taxonomy> sponsorshipStatusTaxonomies;
    List<taxonomy_domain.Taxonomy> currencyTaxonomies;
    try {
      associations = await ref.read(kafalatActiveAssociationsProvider.future);
      sponsorshipTypeTaxonomies =
          await ref.read(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.sponsorshipType).future);
      guaranteeTypeTaxonomies = await ref.read(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.guaranteeType).future);
      sponsorshipStatusTaxonomies =
          await ref.read(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.beneficiaryStatus).future);
      currencyTaxonomies = await ref.read(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.currency).future);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل الجمعيات: $e')),
      );
      return;
    }

    if (!mounted) return;
    if (associations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد جمعيات فعالة متاحة للتنفيذ الجماعي')),
      );
      return;
    }

    String? selectedAssociationId = associations.first.id;
    final typeEntries = {
      for (final taxonomy in sponsorshipTypeTaxonomies)
        if (taxonomy.code.trim().isNotEmpty && taxonomy.label.trim().isNotEmpty)
          taxonomy.code.trim(): taxonomy.label.trim(),
    };
    final statusEntries = {
      for (final taxonomy in sponsorshipStatusTaxonomies)
        if (taxonomy.code.trim().isNotEmpty && taxonomy.label.trim().isNotEmpty)
          taxonomy.code.trim(): taxonomy.label.trim(),
    };
    final guaranteeTypeEntries = {
      for (final taxonomy in guaranteeTypeTaxonomies)
        if (taxonomy.code.trim().isNotEmpty && taxonomy.label.trim().isNotEmpty)
          taxonomy.code.trim(): taxonomy.label.trim(),
    };
    final currencyEntries = {
      for (final taxonomy in currencyTaxonomies)
        if (taxonomy.code.trim().isNotEmpty) taxonomy.code.trim().toUpperCase(): taxonomy.label.trim(),
    };

    final mergedTypeEntries = {
      'monthly': 'شهرية',
      'one_time': 'مرة واحدة',
      'other': 'أخرى',
      ...typeEntries,
    };
    final mergedGuaranteeTypeEntries = {
      'monthly': 'شهرية',
      'one_time': 'مرة واحدة',
      'other': 'أخرى',
      ...guaranteeTypeEntries,
    };
    final mergedStatusEntries = {
      'active': 'نشطة',
      'paused': 'موقوفة',
      'ended': 'منتهية',
      ...statusEntries,
    };
    final mergedCurrencyEntries = {
      'IQD': currencyEntries['IQD'] ?? 'IQD',
      'USD': currencyEntries['USD'] ?? 'USD',
      'EUR': currencyEntries['EUR'] ?? 'EUR',
      ...currencyEntries,
    };

    String sponsorshipType = mergedTypeEntries.keys.first;
    String? guaranteeType;
    String status = mergedStatusEntries.keys.first;
    String? currency;
    final amountController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                MediaQuery.of(sheetContext).viewInsets.bottom + 16.h,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنفيذ كفالات جماعية (${_selectedBeneficiaryIds.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAssociationId,
                      decoration: const InputDecoration(
                        labelText: 'الجمعية *',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          associations.map((a) => DropdownMenuItem<String>(value: a.id, child: Text(a.name))).toList(),
                      onChanged: (value) => setSheetState(() => selectedAssociationId = value),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: sponsorshipType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الكفالة',
                        border: OutlineInputBorder(),
                      ),
                      items: mergedTypeEntries.entries
                          .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                          .toList(growable: false),
                      onChanged: (value) => setSheetState(() => sponsorshipType = value ?? sponsorshipType),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: guaranteeType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الضمان',
                        border: OutlineInputBorder(),
                      ),
                      items: mergedGuaranteeTypeEntries.entries
                          .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                          .toList(growable: false),
                      onChanged: (value) => setSheetState(() => guaranteeType = value),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'الحالة',
                        border: OutlineInputBorder(),
                      ),
                      items: mergedStatusEntries.entries
                          .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                          .toList(growable: false),
                      onChanged: (value) => setSheetState(() => status = value ?? status),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'المبلغ (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: currency,
                      decoration: const InputDecoration(
                        labelText: 'العملة (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                      items: mergedCurrencyEntries.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text('${entry.value} (${entry.key})'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setSheetState(() => currency = value),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: selectedAssociationId == null ? null : () => Navigator.pop(sheetContext, true),
                            child: const Text('تنفيذ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final amountText = amountController.text.trim();
    amountController.dispose();

    if (confirmed != true || selectedAssociationId == null || !mounted) return;

    final amount = double.tryParse(amountText);
    final db = ref.read(databaseProvider);

    var created = 0;
    var failed = 0;
    for (final beneficiaryId in _selectedBeneficiaryIds) {
      try {
        await db.sponsorshipsDao.createSponsorship(
          SponsorshipsCompanion.insert(
            beneficiaryId: beneficiaryId,
            associationId: selectedAssociationId!,
            sponsorshipType: drift.Value(sponsorshipType),
            guaranteeType: drift.Value(guaranteeType),
            status: drift.Value(status),
            startDate: drift.Value(DateTime.now()),
            amount: drift.Value(amount),
            currency: drift.Value(currency),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        created++;
      } catch (_) {
        failed++;
      }
    }

    if (!mounted) return;
    if (created > 0) {
      HapticPatterns.success();
      final message = failed > 0 ? 'تم إنشاء $created كفالة، وتعذر إنشاء $failed' : 'تم إنشاء $created كفالة بنجاح';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } else {
      HapticPatterns.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تنفيذ الكفالات الجماعية')),
      );
    }
    setState(() {
      _selectionMode = false;
      _selectedBeneficiaryIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(kafalatUnsponsoredBeneficiariesByQueryProvider(_query));
    final theme = Theme.of(context);
    final hasQuery = _query.isNotEmpty;
    final totalUnsponsored = state.valueOrNull?.length ?? 0;
    final hasToolState = _selectionMode || _selectedBeneficiaryIds.isNotEmpty;

    Widget buildList(List<Beneficiary> items) {
      final sortedItems = _sortedByPriority(items);
      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(28.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volunteer_activism_outlined,
                    size: 64.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  hasQuery ? 'لا توجد نتائج مطابقة' : 'جميع المستفيدين مكفولون! 🎉',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  hasQuery ? 'جرّب تغيير كلمة البحث أو مسح الفلاتر' : 'رائع! جميع المستفيدين لديهم كفالات نشطة',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                if (hasQuery)
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticPatterns.selection();
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('مسح البحث'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      HapticPatterns.selection();
                      context.push('/beneficiaries');
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('إضافة مستفيد جديد'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kafalatUnsponsoredBeneficiariesByQueryProvider(_query));
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // حساب عدد الأعمدة بناءً على عرض الشاشة
            final crossAxisCount = constraints.maxWidth >= 1200
                ? 3
                : constraints.maxWidth >= 700
                    ? 2
                    : 1;

            final childAspectRatio = constraints.maxWidth >= 700 ? 2.8 : 2.2;

            if (crossAxisCount == 1) {
              // Mobile view - قائمة عادية
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: sortedItems.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final b = sortedItems[index];
                  return UnsponsoredBeneficiaryCard(
                    beneficiary: b,
                    priorityScore: _priorityScore(b),
                    isSelected: _selectedBeneficiaryIds.contains(b.id),
                    onToggleSelection: _selectionMode ? () => _toggleSelection(b.id) : null,
                  );
                },
              );
            }

            // Tablet/Desktop view - Grid
            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final b = sortedItems[index];
                return UnsponsoredBeneficiaryCard(
                  beneficiary: b,
                  priorityScore: _priorityScore(b),
                  isSelected: _selectedBeneficiaryIds.contains(b.id),
                  onToggleSelection: _selectionMode ? () => _toggleSelection(b.id) : null,
                );
              },
            );
          },
        ),
      );
    }

    final items = state.valueOrNull ?? const <Beneficiary>[];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: EnhancedSearchBar(
                  controller: _searchController,
                  onSearch: _onSearchChanged,
                  hintText: 'ابحث في غير المكفولين بالاسم أو رقم الهوية...',
                ),
              ),
              SizedBox(width: 6.w),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _showTools = !_showTools),
                    tooltip: _showTools ? 'إخفاء الأدوات' : 'إظهار الأدوات',
                    icon: Icon(
                      _showTools ? Icons.tune_rounded : Icons.tune_outlined,
                      color: _showTools ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasToolState)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
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
          crossFadeState: _showTools ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.insights_outlined, size: 18.sp, color: theme.colorScheme.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'غير مكفولين حالياً: $totalUnsponsored',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectionMode = !_selectionMode;
                          if (!_selectionMode) _selectedBeneficiaryIds.clear();
                        });
                      },
                      icon: Icon(_selectionMode ? Icons.close : Icons.checklist_rtl),
                      label: Text(_selectionMode ? 'إلغاء التحديد' : 'تحديد متعدد'),
                    ),
                  ],
                ),
                if (_selectionMode)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'تم تحديد ${_selectedBeneficiaryIds.length} مستفيد',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _selectedBeneficiaryIds.isEmpty ? null : _openBulkSponsorshipSheet,
                          icon: const Icon(Icons.handshake_outlined),
                          label: const Text('تنفيذ جماعي'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
        Expanded(
          child: Stack(
            children: [
              if (state.isLoading && !state.hasValue)
                const Positioned.fill(child: ListShimmerLoader(itemHeight: 88))
              else
                Positioned.fill(child: buildList(items)),
              if (state.isLoading)
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  top: 0,
                  child: const LinearProgressIndicator(minHeight: 2),
                ),
              if (state.hasError && items.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 56.sp, color: theme.colorScheme.error),
                        SizedBox(height: 16.h),
                        Text('خطأ في تحميل البيانات', style: theme.textTheme.titleLarge),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.error}',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
