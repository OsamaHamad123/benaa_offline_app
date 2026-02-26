import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../filters/quick_filters_bar.dart';
import '../filters/enhanced_search_bar.dart';
import '../filters/advanced_filters_sheet.dart';
import '../filters/sorting_menu.dart';
import '../actions/swipe_action_wrapper.dart';
import '../animations/card_entrance_animation.dart';
import '../empty_states/empty_states.dart';
import '../loaders/sponsorship_card_shimmer.dart';

class _SavedPreset {
  final String name;
  final String status;
  final String type;
  final String query;
  final String? associationId;
  final String sortName;
  final bool showQuickFilters;

  const _SavedPreset({
    required this.name,
    required this.status,
    required this.type,
    required this.query,
    required this.associationId,
    required this.sortName,
    required this.showQuickFilters,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
        'type': type,
        'query': query,
        'associationId': associationId,
        'sortName': sortName,
        'showQuickFilters': showQuickFilters,
      };

  factory _SavedPreset.fromJson(Map<String, dynamic> json) => _SavedPreset(
        name: (json['name'] as String?) ?? 'عرض محفوظ',
        status: (json['status'] as String?) ?? 'all',
        type: (json['type'] as String?) ?? 'all',
        query: (json['query'] as String?) ?? '',
        associationId: json['associationId'] as String?,
        sortName: (json['sortName'] as String?) ?? SortOption.dateNewest.name,
        showQuickFilters: (json['showQuickFilters'] as bool?) ?? true,
      );
}

/// 📋 Tab "مكفول" - قائمة الكفالات
class SponsoredTab extends ConsumerStatefulWidget {
  final String initialStatus;
  final String initialType;
  final String initialQuery;
  final bool initiallyShowQuickFilters;

  const SponsoredTab({
    super.key,
    this.initialStatus = 'all',
    this.initialType = 'all',
    this.initialQuery = '',
    this.initiallyShowQuickFilters = false,
  });

  @override
  ConsumerState<SponsoredTab> createState() => _SponsoredTabState();
}

class _SponsoredTabState extends ConsumerState<SponsoredTab> with AutomaticKeepAliveClientMixin {
  static const String _prefsPrefix = 'kafalat_sponsored_';
  static const String _prefsStatusKey = '${_prefsPrefix}status';
  static const String _prefsTypeKey = '${_prefsPrefix}type';
  static const String _prefsQueryKey = '${_prefsPrefix}query';
  static const String _prefsAssociationKey = '${_prefsPrefix}association';
  static const String _prefsSortKey = '${_prefsPrefix}sort';
  static const String _prefsShowFiltersKey = '${_prefsPrefix}show_quick_filters';
  static const String _prefsSavedPresetsKey = '${_prefsPrefix}saved_presets';

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
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  double? _minAmountFilter;
  double? _maxAmountFilter;
  SortOption _sortOption = SortOption.dateNewest;
  bool _showQuickFilters = false;
  List<_SavedPreset> _savedPresets = const [];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _type = widget.initialType;
    _query = widget.initialQuery.trim();
    _showQuickFilters = widget.initiallyShowQuickFilters || _status != 'all' || _type != 'all';
    if (_query.isNotEmpty) {
      _searchController.text = _query;
      _showQuickFilters = true;
    }

    Future.microtask(_restoreUiStateIfNeeded);
    Future.microtask(_loadSavedPresets);
  }

  bool get _hasDeepLinkOverrides =>
      widget.initialStatus != 'all' ||
      widget.initialType != 'all' ||
      widget.initialQuery.trim().isNotEmpty ||
      widget.initiallyShowQuickFilters;

  Future<void> _restoreUiStateIfNeeded() async {
    if (_hasDeepLinkOverrides || !mounted) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedStatus = prefs.getString(_prefsStatusKey);
    final savedType = prefs.getString(_prefsTypeKey);
    final savedQuery = prefs.getString(_prefsQueryKey);
    final savedAssociation = prefs.getString(_prefsAssociationKey);
    final savedSort = prefs.getString(_prefsSortKey);
    final savedShowFilters = prefs.getBool(_prefsShowFiltersKey);

    setState(() {
      _status = savedStatus ?? _status;
      _type = savedType ?? _type;
      _query = savedQuery ?? _query;
      _associationId = (savedAssociation == null || savedAssociation.isEmpty) ? null : savedAssociation;
      _sortOption = _sortFromName(savedSort);
      _showQuickFilters = savedShowFilters ?? _showQuickFilters;
      _searchController.text = _query;
    });
  }

  SortOption _sortFromName(String? name) {
    for (final value in SortOption.values) {
      if (value.name == name) return value;
    }
    return SortOption.dateNewest;
  }

  void _persistUiState() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_prefsStatusKey, _status);
      prefs.setString(_prefsTypeKey, _type);
      prefs.setString(_prefsQueryKey, _query);
      prefs.setString(_prefsAssociationKey, _associationId ?? '');
      prefs.setString(_prefsSortKey, _sortOption.name);
      prefs.setBool(_prefsShowFiltersKey, _showQuickFilters);
    });
  }

  Future<void> _loadSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsSavedPresetsKey);
    if (raw == null || raw.isEmpty || !mounted) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final items = decoded
          .whereType<Map>()
          .map((map) => _SavedPreset.fromJson(Map<String, dynamic>.from(map)))
          .toList(growable: false);
      if (!mounted) return;
      setState(() => _savedPresets = items);
    } catch (_) {}
  }

  Future<void> _persistSavedPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_savedPresets.map((p) => p.toJson()).toList(growable: false));
    await prefs.setString(_prefsSavedPresetsKey, encoded);
  }

  Future<void> _saveCurrentPreset() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حفظ عرض مخصص', textAlign: TextAlign.right),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'اسم العرض',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(nameController.text.trim()),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
    nameController.dispose();

    final normalizedName = (name ?? '').trim();
    if (normalizedName.isEmpty) return;

    final preset = _SavedPreset(
      name: normalizedName,
      status: _status,
      type: _type,
      query: _query,
      associationId: _associationId,
      sortName: _sortOption.name,
      showQuickFilters: true,
    );

    setState(() {
      _savedPresets = [
        preset,
        ..._savedPresets.where((p) => p.name != normalizedName),
      ];
    });
    await _persistSavedPresets();
  }

  void _applySavedPreset(_SavedPreset preset) {
    setState(() {
      _status = preset.status;
      _type = preset.type;
      _query = preset.query;
      _associationId = preset.associationId;
      _sortOption = _sortFromName(preset.sortName);
      _showQuickFilters = preset.showQuickFilters;
      _searchController.text = _query;
    });
    _persistUiState();
  }

  Future<void> _deleteSavedPreset(String presetName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العرض المحفوظ', textAlign: TextAlign.right),
        content: Text(
          'هل تريد حذف العرض "$presetName"؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _savedPresets = _savedPresets.where((preset) => preset.name != presetName).toList(growable: false);
    });
    await _persistSavedPresets();
  }

  void _onSavedPresetMenuSelected(String value) {
    if (value.startsWith('apply::')) {
      final name = value.substring('apply::'.length);
      final preset = _savedPresets.where((p) => p.name == name).firstOrNull;
      if (preset != null) {
        _applySavedPreset(preset);
      }
      return;
    }

    if (value.startsWith('delete::')) {
      final name = value.substring('delete::'.length);
      _deleteSavedPreset(name);
    }
  }

  bool get _hasAdvancedFilters =>
      _startDateFilter != null || _endDateFilter != null || _minAmountFilter != null || _maxAmountFilter != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v);
    _persistUiState();
  }

  void _clearFilters() {
    setState(() {
      _associationId = null;
      _status = 'all';
      _type = 'all';
      _query = '';
      _startDateFilter = null;
      _endDateFilter = null;
      _minAmountFilter = null;
      _maxAmountFilter = null;
      _searchController.clear();
      _showQuickFilters = false;
    });
    _persistUiState();
  }

  bool get _hasActiveFilters =>
      _status != 'all' || _type != 'all' || _associationId != null || _query.isNotEmpty || _hasAdvancedFilters;

  void _openAdvancedFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersSheet(
        startDate: _startDateFilter,
        endDate: _endDateFilter,
        minAmount: _minAmountFilter,
        maxAmount: _maxAmountFilter,
        onApplyFilters: ({startDate, endDate, minAmount, maxAmount}) {
          if (!mounted) return;
          setState(() {
            _startDateFilter = startDate;
            _endDateFilter = endDate;
            _minAmountFilter = minAmount;
            _maxAmountFilter = maxAmount;
            _showQuickFilters = true;
          });
          _persistUiState();
        },
      ),
    );
  }

  void _applyQuickPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'active':
          _status = 'active';
          break;
        case 'paused':
          _status = 'paused';
          break;
        case 'ended':
          _status = 'ended';
          break;
        default:
          _status = 'all';
      }
      _showQuickFilters = true;
    });
    _persistUiState();
  }

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
    return fallbackLabels[code] ?? 'قيمة قديمة أو غير معروفة';
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

  List<SponsorshipWithDetails> _applyAdvancedFilters(List<SponsorshipWithDetails> rows) {
    return rows.where((row) {
      final startDate = row.sponsorship.startDate ?? row.sponsorship.createdAt;
      if (_startDateFilter != null && startDate.isBefore(_startDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && startDate.isAfter(_endDateFilter!)) {
        return false;
      }

      final amount = row.sponsorship.amount;
      if (_minAmountFilter != null) {
        if (amount == null || amount < _minAmountFilter!) {
          return false;
        }
      }
      if (_maxAmountFilter != null) {
        if (amount == null || amount > _maxAmountFilter!) {
          return false;
        }
      }

      return true;
    }).toList(growable: false);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: EnhancedSearchBar(
                  controller: _searchController,
                  onSearch: _onSearchChanged,
                  hintText: 'ابحث برقم الملف، الاسم، الهوية...',
                ),
              ),
              SizedBox(width: 6.w),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() => _showQuickFilters = !_showQuickFilters);
                      _persistUiState();
                    },
                    tooltip: _showQuickFilters ? 'إخفاء الأدوات' : 'إظهار الأدوات',
                    icon: Icon(
                      _showQuickFilters ? Icons.tune_rounded : Icons.tune_outlined,
                      color: _showQuickFilters ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
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
          crossFadeState: _showQuickFilters ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTaxonomyGap)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'بعض التصنيفات غير مكتملة حاليًا.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('نشطة'),
                      onPressed: () => _applyQuickPreset('active'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.pause_circle_outline, size: 18),
                      label: const Text('موقوفة'),
                      onPressed: () => _applyQuickPreset('paused'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('منتهية'),
                      onPressed: () => _applyQuickPreset('ended'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.layers_clear_outlined, size: 18),
                      label: const Text('الكل'),
                      onPressed: () => _applyQuickPreset('all'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('حفظ العرض'),
                      onPressed: _saveCurrentPreset,
                    ),
                    if (_savedPresets.isNotEmpty)
                      PopupMenuButton<String>(
                        tooltip: 'العروض المحفوظة',
                        itemBuilder: (context) {
                          final items = <PopupMenuEntry<String>>[];
                          for (final preset in _savedPresets) {
                            items.add(
                              PopupMenuItem<String>(
                                value: 'apply::${preset.name}',
                                child: Row(
                                  children: [
                                    const Icon(Icons.playlist_add_check_rounded, size: 18),
                                    SizedBox(width: 8.w),
                                    Expanded(child: Text('تطبيق: ${preset.name}')),
                                  ],
                                ),
                              ),
                            );
                            items.add(
                              PopupMenuItem<String>(
                                value: 'delete::${preset.name}',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 18, color: Theme.of(context).colorScheme.error),
                                    SizedBox(width: 8.w),
                                    Expanded(child: Text('حذف: ${preset.name}')),
                                  ],
                                ),
                              ),
                            );
                            items.add(const PopupMenuDivider());
                          }
                          if (items.isNotEmpty) {
                            items.removeLast();
                          }
                          return items;
                        },
                        onSelected: _onSavedPresetMenuSelected,
                        child: const Chip(
                          avatar: Icon(Icons.bookmarks_outlined, size: 18),
                          label: Text('العروض المحفوظة'),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                associationsAsync.when(
                  data: (associations) => QuickFiltersBar(
                    selectedStatus: _status,
                    selectedType: _type,
                    selectedAssociationId: _associationId,
                    associations: associations.map((a) => (id: a.id, name: a.name)).toList(),
                    onStatusChanged: (v) {
                      setState(() => _status = v);
                      _persistUiState();
                    },
                    onTypeChanged: (v) {
                      setState(() => _type = v);
                      _persistUiState();
                    },
                    onAssociationChanged: (v) {
                      setState(() => _associationId = v);
                      _persistUiState();
                    },
                    onClearFilters: _clearFilters,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                if (_hasActiveFilters)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        if (_status != 'all') _ActiveChip(label: 'الحالة: ${resolveStatusLabel(_status)}'),
                        if (_type != 'all') _ActiveChip(label: 'النوع: ${resolveTypeLabel(_type)}'),
                        if (_query.isNotEmpty) _ActiveChip(label: 'بحث: $_query'),
                        if (_startDateFilter != null || _endDateFilter != null) const _ActiveChip(label: 'نطاق تاريخ'),
                        if (_minAmountFilter != null || _maxAmountFilter != null) const _ActiveChip(label: 'نطاق مبلغ'),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _openAdvancedFilters(context),
                      tooltip: 'فلاتر متقدمة',
                      icon: Icon(
                        Icons.tune_rounded,
                        color: _hasAdvancedFilters ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SortingMenu(
                      currentSort: _sortOption,
                      onSortChanged: (v) {
                        setState(() => _sortOption = v);
                        _persistUiState();
                      },
                    ),
                    if (_hasActiveFilters)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('مسح'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
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
              final filteredRows = _applyAdvancedFilters(sortedRows);

              if (filteredRows.isEmpty) {
                return EmptySponsorshipsState(
                  hasFilters: _hasActiveFilters,
                  onClearFilters: _hasActiveFilters ? _clearFilters : null,
                );
              }

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
                        itemCount: filteredRows.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, i) {
                          final r = filteredRows[i];
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
                      itemCount: filteredRows.length,
                      itemBuilder: (context, i) {
                        final r = filteredRows[i];
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

class _ActiveChip extends StatelessWidget {
  final String label;

  const _ActiveChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
