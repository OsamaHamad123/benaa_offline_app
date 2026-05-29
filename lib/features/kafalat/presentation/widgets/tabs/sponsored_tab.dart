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
import '../filters/enhanced_search_bar.dart';
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
  List<_SavedPreset> _savedPresets = const [];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _type = widget.initialType;
    _query = widget.initialQuery.trim();
    if (_query.isNotEmpty) {
      _searchController.text = _query;
    }

    Future.microtask(_restoreUiStateIfNeeded);
    Future.microtask(_loadSavedPresets);
  }

  bool get _hasDeepLinkOverrides =>
      widget.initialStatus != 'all' || widget.initialType != 'all' || widget.initialQuery.trim().isNotEmpty;

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
    setState(() {
      _status = savedStatus ?? _status;
      _type = savedType ?? _type;
      _query = savedQuery ?? _query;
      _associationId = (savedAssociation == null || savedAssociation.isEmpty) ? null : savedAssociation;
      _sortOption = _sortFromName(savedSort);
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

  void _applySavedPreset(_SavedPreset preset) {
    setState(() {
      _status = preset.status;
      _type = preset.type;
      _query = preset.query;
      _associationId = preset.associationId;
      _sortOption = _sortFromName(preset.sortName);
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
    });
    _persistUiState();
  }

  bool get _hasActiveFilters =>
      _status != 'all' || _type != 'all' || _associationId != null || _query.isNotEmpty || _hasAdvancedFilters;

  void _openFiltersSheet(BuildContext context) {
    var tempStatus = _status;
    var tempType = _type;
    var tempAssociationId = _associationId;
    var tempStartDate = _startDateFilter;
    var tempEndDate = _endDateFilter;
    var tempMinAmount = _minAmountFilter;
    var tempMaxAmount = _maxAmountFilter;
    var tempSort = _sortOption;

    final rawAssoc = ref.read(kafalatActiveAssociationsProvider).valueOrNull;
    final List<({String id, String name})> associations =
        rawAssoc?.map((a) => (id: a.id, name: a.name)).toList() ?? const <({String id, String name})>[];
    final minAmountCtrl = TextEditingController(text: _minAmountFilter?.toStringAsFixed(0) ?? '');
    final maxAmountCtrl = TextEditingController(text: _maxAmountFilter?.toStringAsFixed(0) ?? '');

    String fmtDate(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final theme = Theme.of(ctx);

            FilterChip buildChip(String label, bool selected, VoidCallback onTap, {IconData? icon}) => FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => onTap(),
                  avatar: icon != null ? Icon(icon, size: 16.sp) : null,
                );

            return SafeArea(
              child: DraggableScrollableSheet(
                initialChildSize: 0.72,
                maxChildSize: 0.95,
                minChildSize: 0.35,
                expand: false,
                builder: (_, ctrl) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 8.w, 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt_outlined, color: theme.colorScheme.primary),
                            SizedBox(width: 8.w),
                            Text(
                              'فلترة الكفالات',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => setSheet(() {
                                tempStatus = 'all';
                                tempType = 'all';
                                tempAssociationId = null;
                                tempStartDate = null;
                                tempEndDate = null;
                                tempMinAmount = null;
                                tempMaxAmount = null;
                                minAmountCtrl.clear();
                                maxAmountCtrl.clear();
                              }),
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('مسح الكل'),
                              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView(
                          controller: ctrl,
                          padding: EdgeInsets.all(16.w),
                          children: [
                            Text('الحالة',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                buildChip('الكل', tempStatus == 'all', () => setSheet(() => tempStatus = 'all'),
                                    icon: Icons.apps),
                                buildChip('نشطة', tempStatus == 'active', () => setSheet(() => tempStatus = 'active'),
                                    icon: Icons.check_circle),
                                buildChip('موقوفة', tempStatus == 'paused', () => setSheet(() => tempStatus = 'paused'),
                                    icon: Icons.pause_circle),
                                buildChip('منتهية', tempStatus == 'ended', () => setSheet(() => tempStatus = 'ended'),
                                    icon: Icons.cancel),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text('نوع الكفالة',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                buildChip('كل الأنواع', tempType == 'all', () => setSheet(() => tempType = 'all'),
                                    icon: Icons.category),
                                buildChip('شهرية', tempType == 'monthly', () => setSheet(() => tempType = 'monthly'),
                                    icon: Icons.calendar_month),
                                buildChip(
                                    'مرة واحدة', tempType == 'one_time', () => setSheet(() => tempType = 'one_time'),
                                    icon: Icons.bolt),
                                buildChip('أخرى', tempType == 'other', () => setSheet(() => tempType = 'other'),
                                    icon: Icons.more_horiz),
                              ],
                            ),
                            if (associations.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Text('الجمعية',
                                  style: theme.textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                              SizedBox(height: 8.h),
                              DropdownButtonFormField<String?>(
                                isExpanded: true,
                                initialValue: tempAssociationId,
                                decoration: InputDecoration(
                                  labelText: 'اختر الجمعية',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('كل الجمعيات', overflow: TextOverflow.ellipsis),
                                  ),
                                  ...associations.map(
                                    (a) => DropdownMenuItem<String?>(
                                      value: a.id,
                                      child: Text(a.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setSheet(() => tempAssociationId = v),
                              ),
                            ],
                            SizedBox(height: 16.h),
                            Text('نطاق التاريخ',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final d = await showDatePicker(
                                        context: ctx,
                                        initialDate: tempStartDate ?? DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate: DateTime.now(),
                                      );
                                      if (d != null) setSheet(() => tempStartDate = d);
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                                    label: Text(
                                      tempStartDate != null ? fmtDate(tempStartDate!) : 'من تاريخ',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final d = await showDatePicker(
                                        context: ctx,
                                        initialDate: tempEndDate ?? DateTime.now(),
                                        firstDate: DateTime(2010),
                                        lastDate: DateTime(2030),
                                      );
                                      if (d != null) setSheet(() => tempEndDate = d);
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                                    label: Text(
                                      tempEndDate != null ? fmtDate(tempEndDate!) : 'إلى تاريخ',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text('نطاق المبلغ',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: minAmountCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'الحد الأدنى',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                    ),
                                    onChanged: (v) => tempMinAmount = double.tryParse(v),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: maxAmountCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'الحد الأقصى',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                    ),
                                    onChanged: (v) => tempMaxAmount = double.tryParse(v),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text('الترتيب',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                            SizedBox(height: 8.h),
                            SortingMenu(
                              currentSort: tempSort,
                              onSortChanged: (v) => setSheet(() => tempSort = v),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(sheetCtx).pop(),
                                child: const Text('إلغاء'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _status = tempStatus;
                                    _type = tempType;
                                    _associationId = tempAssociationId;
                                    _startDateFilter = tempStartDate;
                                    _endDateFilter = tempEndDate;
                                    _minAmountFilter = tempMinAmount;
                                    _maxAmountFilter = tempMaxAmount;
                                    _sortOption = tempSort;
                                  });
                                  _persistUiState();
                                  Navigator.of(sheetCtx).pop();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('تطبيق الفلاتر'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      minAmountCtrl.dispose();
      maxAmountCtrl.dispose();
    });
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
              SizedBox(width: 4.w),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => _openFiltersSheet(context),
                    tooltip: 'فلترة',
                    icon: Icon(
                      _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                      color: _hasActiveFilters ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
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
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (_hasActiveFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
            child: Row(
              children: [
                if (_status != 'all')
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Chip(
                      label: Text(resolveStatusLabel(_status), style: theme.textTheme.labelSmall),
                      avatar: const Icon(Icons.radio_button_checked, size: 14),
                      onDeleted: () {
                        setState(() => _status = 'all');
                        _persistUiState();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                    ),
                  ),
                if (_type != 'all')
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Chip(
                      label: Text(resolveTypeLabel(_type), style: theme.textTheme.labelSmall),
                      avatar: const Icon(Icons.category_outlined, size: 14),
                      onDeleted: () {
                        setState(() => _type = 'all');
                        _persistUiState();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                    ),
                  ),
                if (_associationId != null)
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Chip(
                      label: Text('الجمعية', style: theme.textTheme.labelSmall),
                      avatar: const Icon(Icons.business_outlined, size: 14),
                      onDeleted: () {
                        setState(() => _associationId = null);
                        _persistUiState();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                    ),
                  ),
                if (_query.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Chip(
                      label: Text('بحث: $_query', style: theme.textTheme.labelSmall),
                      avatar: const Icon(Icons.search, size: 14),
                      onDeleted: () {
                        setState(() {
                          _query = '';
                          _searchController.clear();
                        });
                        _persistUiState();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                    ),
                  ),
                if (_hasAdvancedFilters)
                  Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Chip(
                      label: Text('فلاتر متقدمة', style: theme.textTheme.labelSmall),
                      avatar: const Icon(Icons.tune, size: 14),
                      onDeleted: () {
                        setState(() {
                          _startDateFilter = null;
                          _endDateFilter = null;
                          _minAmountFilter = null;
                          _maxAmountFilter = null;
                        });
                        _persistUiState();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                    ),
                  ),
                TextButton(
                  onPressed: _clearFilters,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('مسح الكل'),
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
