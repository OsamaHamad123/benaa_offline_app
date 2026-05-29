import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/usecases/taxonomy_usecases.dart';
import '../providers/taxonomy_providers.dart';
import 'taxonomy_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🌳  TaxonomyHierarchyList
//
// قائمة هرمية (tree) للتصنيفات داخل مجموعة واحدة.
// تعرض التصنيفات الجذرية (parentId = null/'') أولاً،
// وتحت كل منها تصنيفاتها الفرعية قابلة للتوسيع.
// ─────────────────────────────────────────────────────────────────────────────
class TaxonomyHierarchyList extends ConsumerStatefulWidget {
  final TaxonomyGroup group;

  const TaxonomyHierarchyList({required this.group, super.key});

  @override
  ConsumerState<TaxonomyHierarchyList> createState() => _TaxonomyHierarchyListState();
}

class _TaxonomyHierarchyListState extends ConsumerState<TaxonomyHierarchyList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showActiveOnly = false;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  /// بناء خريطة الشجرة: id → أبناء
  Map<String?, List<Taxonomy>> _buildTree(List<Taxonomy> all) {
    final map = <String?, List<Taxonomy>>{};
    for (final t in all) {
      final key = (t.parentId == null || t.parentId!.isEmpty) ? null : t.parentId;
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  /// فلترة القائمة (بحث + نشط فقط) مع إضافة آباء التصنيفات المطابقة
  /// حتى تظهر التصنيفات الفرعية تحت أبيها في الشجرة عند البحث
  List<Taxonomy> _filterForTree(List<Taxonomy> all) {
    final matched = all.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.label.toLowerCase().contains(_searchQuery) ||
          t.code.toLowerCase().contains(_searchQuery);
      final matchesActive = !_showActiveOnly || t.isActive;
      return matchesSearch && matchesActive;
    }).toSet();

    // عند البحث: أضف أباء التصنيفات المطابقة لكي تظهر تحتهم في الشجرة
    if (_searchQuery.isNotEmpty) {
      final allById = {for (final t in all) t.id: t};
      final toAdd = <Taxonomy>{};
      for (final t in matched) {
        final pid = t.parentId;
        if (pid != null && pid.isNotEmpty) {
          final parent = allById[pid];
          if (parent != null) toAdd.add(parent);
        }
      }
      matched.addAll(toAdd);
    }

    return matched.toList();
  }

  @override
  Widget build(BuildContext context) {
    final taxonomiesAsync = ref.watch(taxonomiesByGroupProvider(widget.group));

    return taxonomiesAsync.when(
      skipLoadingOnRefresh: true,
      data: (allTaxonomies) {
        final filtered = _filterForTree(allTaxonomies);
        final tree = _buildTree(filtered);
        final roots = (tree[null] ?? [])..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return Column(
          children: [
            _buildSearchBar(context),
            if (allTaxonomies.isEmpty)
              _buildEmptyState(context)
            else if (filtered.isEmpty)
              _buildNoResults()
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(taxonomySyncNotifierProvider.notifier).syncGroup(widget.group);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemCount: roots.length,
                    itemBuilder: (context, i) {
                      final root = roots[i];
                      final children = (tree[root.id] ?? [])..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                      return _TaxonomyTreeItem(
                        taxonomy: root,
                        children: children,
                        group: widget.group,
                        onMutated: () => ref.invalidate(taxonomiesByGroupProvider(widget.group)),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('خطأ: $e'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(taxonomiesByGroupProvider(widget.group)),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث في ${widget.group.arabicName}...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('نشط فقط'),
            selected: _showActiveOnly,
            onSelected: (v) => setState(() => _showActiveOnly = v),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('لا توجد تصنيفات في ${widget.group.arabicName}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.read(taxonomySyncNotifierProvider.notifier).syncGroup(widget.group),
              icon: const Icon(Icons.sync),
              label: const Text('مزامنة من السيرفر'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد نتائج مطابقة'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🌿  _TaxonomyTreeItem  — عنصر التصنيف مع أبنائه
// ─────────────────────────────────────────────────────────────────────────────
class _TaxonomyTreeItem extends ConsumerWidget {
  final Taxonomy taxonomy;
  final List<Taxonomy> children;
  final TaxonomyGroup group;
  final VoidCallback onMutated;

  const _TaxonomyTreeItem({
    required this.taxonomy,
    required this.children,
    required this.group,
    required this.onMutated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChildren = children.isNotEmpty;
    final isEditable = group.isEditable;

    if (hasChildren) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: EdgeInsets.zero,
          leading: _statusDot(taxonomy),
          title: _titleRow(context, taxonomy, hasChildren: true),
          subtitle: Text(taxonomy.code, style: const TextStyle(fontSize: 11)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _childCountBadge(context, children.length),
              if (isEditable) _actionsMenu(context, ref, taxonomy),
            ],
          ),
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...children.map((child) => _ChildTile(
                  child: child,
                  group: group,
                  onMutated: onMutated,
                )),
          ],
        ),
      );
    }

    // تصنيف بلا أبناء
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: _statusDot(taxonomy),
        title: _titleRow(context, taxonomy),
        subtitle: Text(taxonomy.code, style: const TextStyle(fontSize: 11)),
        trailing: isEditable ? _actionsMenu(context, ref, taxonomy) : null,
        onTap: () => _showDetails(context, taxonomy),
      ),
    );
  }

  Widget _statusDot(Taxonomy t) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.isActive ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _titleRow(BuildContext context, Taxonomy t, {bool hasChildren = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            t.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: hasChildren ? FontWeight.w600 : FontWeight.normal,
              color: t.isActive ? null : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _childCountBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _actionsMenu(BuildContext context, WidgetRef ref, Taxonomy t) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      tooltip: 'خيارات',
      onSelected: (v) => _handleAction(context, ref, t, v),
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: 'details',
            child: Row(children: [Icon(Icons.info_outline, size: 18), SizedBox(width: 8), Text('تفاصيل')])),
        const PopupMenuItem(
            value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('تعديل')])),
        const PopupMenuItem(
            value: 'add_child',
            child: Row(children: [Icon(Icons.account_tree, size: 18), SizedBox(width: 8), Text('إضافة فرعي')])),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'toggle',
          child: Row(children: [
            Icon(t.isActive ? Icons.visibility_off : Icons.visibility, size: 18),
            const SizedBox(width: 8),
            Text(t.isActive ? 'تعطيل' : 'تفعيل'),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف', style: TextStyle(color: Colors.red))
          ]),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, Taxonomy t, String action) {
    switch (action) {
      case 'details':
        _showDetails(context, t);
      case 'edit':
        _showEditDialog(context, ref, t);
      case 'add_child':
        _showAddChildDialog(context, ref, t);
      case 'toggle':
        _toggleActive(context, ref, t);
      case 'delete':
        _confirmDelete(context, ref, t);
    }
  }

  void _showDetails(BuildContext context, Taxonomy t) {
    showDialog(context: context, builder: (_) => TaxonomyDetailsDialog(taxonomy: t));
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Taxonomy t) {
    showDialog(
      context: context,
      builder: (_) => TaxonomyFormDialog(
        group: group,
        taxonomy: t,
        onSaved: onMutated,
      ),
    );
  }

  void _showAddChildDialog(BuildContext context, WidgetRef ref, Taxonomy parent) {
    showDialog(
      context: context,
      builder: (_) => TaxonomyFormDialog(
        group: group,
        parentId: parent.id,
        onSaved: onMutated,
      ),
    );
  }

  void _toggleActive(BuildContext context, WidgetRef ref, Taxonomy t) async {
    final useCase = ref.read(deleteTaxonomyUseCaseProvider);
    final bool success;
    if (t.isActive) {
      final result = await useCase.deactivate(t.id);
      success = result.isSuccess;
    } else {
      final result = await useCase.restore(t.id);
      success = result.isSuccess;
    }
    if (!context.mounted) return;
    if (success) onMutated();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? (t.isActive ? 'تم تعطيل التصنيف' : 'تم تفعيل التصنيف') : 'فشلت العملية'),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }

  /// ─── حذف مع Dialog خيارات لو يوجد أبناء ───
  void _confirmDelete(BuildContext context, WidgetRef ref, Taxonomy t) async {
    final useCase = ref.read(deleteTaxonomyUseCaseProvider);

    if (children.isNotEmpty) {
      // عرض bottom sheet بخيارات
      _showDeleteOptionsSheet(context, ref, t, useCase);
    } else {
      // تصنيف بلا أبناء — حوار تأكيد بسيط
      _showSimpleDeleteDialog(context, ref, t, useCase);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// حوار الحذف البسيط (تصنيف بلا أبناء)
// ─────────────────────────────────────────────────────────────────────────────
void _showSimpleDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  Taxonomy taxonomy,
  DeleteTaxonomyUseCase useCase,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل تريد حذف "${taxonomy.label}"؟\nسيتم تعطيله وليس حذفه نهائياً.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(dialogContext);
            final result = await useCase.call(taxonomy.id);
            if (!context.mounted) return;
            ref.invalidate(taxonomiesByGroupProvider(taxonomy.group));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.isSuccess ? 'تم حذف "${taxonomy.label}" بنجاح' : 'فشل الحذف'),
                backgroundColor: result.isSuccess ? null : Colors.red,
              ),
            );
          },
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet خيارات حذف تصنيف يحتوي أبناء
// ─────────────────────────────────────────────────────────────────────────────
void _showDeleteOptionsSheet(
  BuildContext context,
  WidgetRef ref,
  Taxonomy taxonomy,
  DeleteTaxonomyUseCase useCase,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _DeleteOptionsSheet(
      taxonomy: taxonomy,
      useCase: useCase,
      onDone: () {
        ref.invalidate(taxonomiesByGroupProvider(taxonomy.group));
      },
    ),
  );
}

class _DeleteOptionsSheet extends ConsumerStatefulWidget {
  final Taxonomy taxonomy;
  final DeleteTaxonomyUseCase useCase;
  final VoidCallback onDone;

  const _DeleteOptionsSheet({
    required this.taxonomy,
    required this.useCase,
    required this.onDone,
  });

  @override
  ConsumerState<_DeleteOptionsSheet> createState() => _DeleteOptionsSheetState();
}

class _DeleteOptionsSheetState extends ConsumerState<_DeleteOptionsSheet> {
  bool _loading = false;

  Future<void> _execute(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.pop(context);
      widget.onDone();
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'حدث خطأ غير متوقع'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.taxonomy;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('لا يمكن الحذف المباشر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '"${t.label}" يحتوي على تصنيفات فرعية',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 8),
          const Text('اختر إجراءً:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else ...[
            // Option 1: Cascade delete
            _OptionTile(
              icon: Icons.delete_sweep,
              iconColor: Colors.red,
              title: 'حذف التصنيف مع كل الفرعيين',
              subtitle: 'سيتم تعطيل هذا التصنيف وكل الفرعيين نهائياً',
              onTap: () => _execute(() async {
                final result = await widget.useCase.cascade(t.id);
                if (!result.isSuccess) throw Exception('فشل الحذف المتتالي');
              }),
            ),
            const SizedBox(height: 8),

            // Option 2: Promote children to root
            _OptionTile(
              icon: Icons.account_tree_outlined,
              iconColor: Colors.blue,
              title: 'رفع الفرعيين لمستوى رئيسي',
              subtitle: 'ستصبح التصنيفات الفرعية مستقلة، ثم يُحذف الأب',
              onTap: () => _execute(() async {
                final result = await widget.useCase.promoteChildren(t.id);
                if (!result.isSuccess) throw Exception('فشل ترقية الفرعيين');
              }),
            ),
            const SizedBox(height: 8),

            // Option 3: Deactivate instead
            _OptionTile(
              icon: Icons.visibility_off_outlined,
              iconColor: Colors.orange,
              title: 'تعطيل بدلاً من الحذف',
              subtitle: 'الأفضل إذا كان التصنيف مستخدماً في بيانات سابقة',
              onTap: () => _execute(() async {
                final result = await widget.useCase.deactivate(t.id);
                if (!result.isSuccess) throw Exception('فشل التعطيل');
              }),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🌱  _ChildTile — عنصر التصنيف الفرعي (داخل ExpansionTile)
// ─────────────────────────────────────────────────────────────────────────────
class _ChildTile extends ConsumerWidget {
  final Taxonomy child;
  final TaxonomyGroup group;
  final VoidCallback onMutated;

  const _ChildTile({required this.child, required this.group, required this.onMutated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 8),
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: child.isActive ? Colors.green.shade400 : Colors.grey.shade400,
        ),
      ),
      title: Text(
        child.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: child.isActive ? null : Colors.grey,
        ),
      ),
      subtitle: Text(child.code, style: const TextStyle(fontSize: 11)),
      trailing: group.isEditable
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              onSelected: (v) => _handleAction(context, ref, v),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('تعديل')])),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(child.isActive ? Icons.visibility_off : Icons.visibility, size: 16),
                    const SizedBox(width: 8),
                    Text(child.isActive ? 'تعطيل' : 'تفعيل'),
                  ]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red))
                  ]),
                ),
              ],
            )
          : null,
      onTap: () => showDialog(context: context, builder: (_) => TaxonomyDetailsDialog(taxonomy: child)),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final useCase = ref.read(deleteTaxonomyUseCaseProvider);
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (_) => TaxonomyFormDialog(group: group, taxonomy: child, onSaved: onMutated),
        );
      case 'toggle':
        _toggle(context, ref, useCase);
      case 'delete':
        _showSimpleDeleteDialog(context, ref, child, useCase);
    }
  }

  void _toggle(BuildContext context, WidgetRef ref, DeleteTaxonomyUseCase useCase) async {
    final bool success;
    if (child.isActive) {
      final result = await useCase.deactivate(child.id);
      success = result.isSuccess;
    } else {
      final result = await useCase.restore(child.id);
      success = result.isSuccess;
    }
    if (!context.mounted) return;
    if (success) onMutated();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? (child.isActive ? 'تم تعطيل التصنيف الفرعي' : 'تم تفعيل التصنيف الفرعي') : 'فشلت العملية'),
        backgroundColor: success ? null : Colors.red,
      ),
    );
  }
}
