import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error_handling/result.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';
import '../providers/taxonomy_providers.dart';
import '../widgets/taxonomy_widgets.dart';
import '../widgets/taxonomy_hierarchy_list.dart';

/// 📋 Taxonomy Management Page
///
/// صفحة إدارة التصنيفات
class TaxonomyManagementPage extends ConsumerStatefulWidget {
  const TaxonomyManagementPage({super.key});

  @override
  ConsumerState<TaxonomyManagementPage> createState() => _TaxonomyManagementPageState();
}

class _TaxonomyManagementPageState extends ConsumerState<TaxonomyManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaxonomyGroup _selectedGroup = TaxonomyGroup.category;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TaxonomyGroup.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedGroup = TaxonomyGroup.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.read(taxonomySyncNotifierProvider.notifier).sync();
            },
            tooltip: 'مزامنة',
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Seed Firestore (Debug)',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final seeded = await ref.read(taxonomyFirestoreHydratorProvider).seedFromLocalIfFirestoreEmpty(
                  groups: const [
                    TaxonomyGroup.gender,
                    TaxonomyGroup.category,
                    TaxonomyGroup.relationship,
                    TaxonomyGroup.section,
                  ],
                );

                if (!context.mounted) {
                  return;
                }

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      seeded > 0
                          ? 'تم Seed لـ $seeded عنصر إلى Firestore'
                          : 'لا توجد بيانات جديدة للـ Seed أو Firestore يحتوي بيانات مسبقاً',
                    ),
                  ),
                );
              },
            ),
          if (_selectedGroup.isEditable)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () => _showBatchCreateDialog(context),
              tooltip: 'إضافة دفعة',
            ),
          if (_selectedGroup.isEditable)
            IconButton(
              icon: const Icon(Icons.playlist_add_check),
              onPressed: () => _showBatchUpdateDialog(context),
              tooltip: 'تحديث دفعة',
            ),
          if (_selectedGroup.isEditable)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showBatchDeleteDialog(context),
              tooltip: 'حذف دفعة',
            ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatistics(context),
            tooltip: 'إحصائيات',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: TaxonomyGroup.values.map((group) {
            return Tab(text: group.arabicName);
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // حالة المزامنة
          const TaxonomySyncStatusWidget(),

          // قائمة التصنيفات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: TaxonomyGroup.values.map((group) {
                return TaxonomyHierarchyList(group: group);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedGroup.isEditable
          ? FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaxonomyFormDialog(
        group: _selectedGroup,
        onSaved: () {
          ref.invalidate(taxonomiesByGroupProvider(_selectedGroup));
        },
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _StatisticsSheet(),
    );
  }

  void _showBatchCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _BatchCreateDialog(group: _selectedGroup),
    );
  }

  void _showBatchUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _BatchUpdateDialog(group: _selectedGroup),
    );
  }

  void _showBatchDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _BatchDeleteDialog(group: _selectedGroup),
    );
  }
}

/// 📊 Statistics Sheet
class _StatisticsSheet extends ConsumerWidget {
  const _StatisticsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(taxonomyStatisticsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات التصنيفات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _StatRow('إجمالي التصنيفات', stats.totalCount.toString()),
                _StatRow('التصنيفات النشطة', stats.activeCount.toString()),
                _StatRow('التصنيفات غير النشطة', stats.inactiveCount.toString()),
                if (stats.lastSyncTime != null)
                  _StatRow(
                    'آخر مزامنة',
                    '${stats.lastSyncTime!.day}/${stats.lastSyncTime!.month}/${stats.lastSyncTime!.year}',
                  ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'التوزيع حسب المجموعة:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...stats.countByGroup.entries.map((entry) {
                  return _StatRow(entry.key.arabicName, entry.value.toString());
                }),
                const Divider(),
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'تشخيص سياسة mapping',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    '${backendDocumentedSlugCanonicalGroup.length} slug موثقة',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  children: [
                    const SizedBox(height: 4),
                    ...backendDocumentedCategorySlugs.map((slug) {
                      final canonical = resolveBackendDocumentedCategoryCanonicalGroup(slug);
                      final group = TaxonomyGroup.fromString(canonical);
                      final groupLabel = group?.arabicName ?? canonical ?? 'غير معروف';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                slug,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '← $groupLabel',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('خطأ: $error'),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// 📝 Taxonomy Form Dialog — مُعرَّف في taxonomy_widgets.dart
// تم نقله إلى lib/features/taxonomies/presentation/widgets/taxonomy_widgets.dart

class _BatchCreateDialog extends ConsumerStatefulWidget {
  final TaxonomyGroup group;

  const _BatchCreateDialog({required this.group});

  @override
  ConsumerState<_BatchCreateDialog> createState() => _BatchCreateDialogState();
}

class _BatchCreateDialogState extends ConsumerState<_BatchCreateDialog> {
  final TextEditingController _itemsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة تصنيفات دفعة واحدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'أدخل اسمًا في كل سطر (أو افصل بفاصلة).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _itemsController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'غزة\nخان يونس\nرفح',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تنفيذ'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final raw = _itemsController.text;
    final names =
        raw.split(RegExp(r'[,\n]')).map((item) => item.trim()).where((item) => item.isNotEmpty).toList(growable: false);

    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل عنصرًا واحدًا على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(taxonomyCrudNotifierProvider.notifier).createBatch(widget.group, names);
      if (result.isSuccess) {
        final createdCount = (result as Success<List<Taxonomy>>).value.length;
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة $createdCount عنصر بنجاح')),
          );
        }
      } else {
        final error = (result as Failure).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل: ${error.message}'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _BatchUpdateDialog extends ConsumerStatefulWidget {
  final TaxonomyGroup group;

  const _BatchUpdateDialog({required this.group});

  @override
  ConsumerState<_BatchUpdateDialog> createState() => _BatchUpdateDialogState();
}

class _BatchUpdateDialogState extends ConsumerState<_BatchUpdateDialog> {
  final TextEditingController _itemsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديث تصنيفات دفعة واحدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'أدخل كل عنصر كسطر بالشكل: id,name',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _itemsController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '12,قطاع غزة\n15,محافظة خان يونس',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تنفيذ'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final updates = <String, String>{};
    final lines = _itemsController.text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split(',');
      if (parts.length < 2) continue;
      final id = parts.first.trim();
      final name = parts.sublist(1).join(',').trim();
      if (id.isNotEmpty && name.isNotEmpty) {
        updates[id] = name;
      }
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل عناصر صالحة بصيغة id,name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(taxonomyCrudNotifierProvider.notifier).updateBatch(widget.group, updates);
      if (result.isSuccess) {
        final updatedCount = (result as Success<List<Taxonomy>>).value.length;
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث $updatedCount عنصر بنجاح')),
          );
        }
      } else {
        final error = (result as Failure).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل: ${error.message}'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _BatchDeleteDialog extends ConsumerStatefulWidget {
  final TaxonomyGroup group;

  const _BatchDeleteDialog({required this.group});

  @override
  ConsumerState<_BatchDeleteDialog> createState() => _BatchDeleteDialogState();
}

class _BatchDeleteDialogState extends ConsumerState<_BatchDeleteDialog> {
  final TextEditingController _idsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حذف تصنيفات دفعة واحدة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'أدخل المعرفات مفصولة بسطر جديد أو فاصلة.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _idsController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '12\n15\n18',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('حذف', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final ids = _idsController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل معرفًا واحدًا على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(taxonomyCrudNotifierProvider.notifier).deleteBatch(widget.group, ids);
      if (result.isSuccess) {
        final deletedCount = (result as Success<List<String>>).value.length;
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف $deletedCount عنصر بنجاح')),
          );
        }
      } else {
        final error = (result as Failure).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل: ${error.message}'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// 📄 Taxonomy Details Dialog — مُعرَّف في taxonomy_widgets.dart
// تم نقله إلى lib/features/taxonomies/presentation/widgets/taxonomy_widgets.dart
