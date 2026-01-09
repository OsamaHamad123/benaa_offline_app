import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../providers/taxonomy_providers.dart';

/// 📝 Taxonomy Dropdown Widget
///
/// Widget لاختيار تصنيف من قائمة منسدلة
class TaxonomyDropdown extends ConsumerWidget {
  final TaxonomyGroup group;
  final String? selectedId;
  final String? selectedCode;
  final ValueChanged<Taxonomy?>? onChanged;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final bool enabled;
  final String? errorText;
  final InputDecoration? decoration;

  const TaxonomyDropdown({
    super.key,
    required this.group,
    this.selectedId,
    this.selectedCode,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.isRequired = false,
    this.enabled = true,
    this.errorText,
    this.decoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomiesAsync = ref.watch(taxonomiesByGroupProvider(group));

    return taxonomiesAsync.when(
      data: (taxonomies) {
        final selectedTaxonomy = _findSelected(taxonomies);

        return DropdownButtonFormField<Taxonomy>(
          value: selectedTaxonomy,
          decoration: decoration ??
              InputDecoration(
                labelText: labelText ?? group.arabicName,
                hintText: hintText ?? 'اختر ${group.arabicName}',
                errorText: errorText,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_getIconForGroup(group)),
              ),
          items: taxonomies.map((taxonomy) {
            return DropdownMenuItem<Taxonomy>(
              value: taxonomy,
              child: Text(taxonomy.label),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: isRequired ? (value) => value == null ? '${group.arabicName} مطلوب' : null : null,
          isExpanded: true,
        );
      },
      loading: () => _buildLoadingDropdown(),
      error: (error, _) => _buildErrorDropdown(error.toString()),
    );
  }

  Taxonomy? _findSelected(List<Taxonomy> taxonomies) {
    if (selectedId != null) {
      try {
        return taxonomies.firstWhere((t) => t.id == selectedId);
      } catch (_) {
        return null;
      }
    }
    if (selectedCode != null) {
      try {
        return taxonomies.firstWhere((t) => t.code == selectedCode);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Widget _buildLoadingDropdown() {
    return DropdownButtonFormField<Taxonomy>(
      value: null,
      decoration: InputDecoration(
        labelText: labelText ?? group.arabicName,
        border: const OutlineInputBorder(),
        suffixIcon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      items: const [],
      onChanged: null,
    );
  }

  Widget _buildErrorDropdown(String error) {
    return DropdownButtonFormField<Taxonomy>(
      value: null,
      decoration: InputDecoration(
        labelText: labelText ?? group.arabicName,
        border: const OutlineInputBorder(),
        errorText: 'فشل تحميل البيانات',
        suffixIcon: const Icon(Icons.error_outline, color: Colors.red),
      ),
      items: const [],
      onChanged: null,
    );
  }

  IconData _getIconForGroup(TaxonomyGroup group) {
    switch (group) {
      case TaxonomyGroup.governorate:
        return Icons.location_city;
      case TaxonomyGroup.category:
        return Icons.category;
      case TaxonomyGroup.maritalStatus:
        return Icons.family_restroom;
      case TaxonomyGroup.educationLevel:
        return Icons.school;
      case TaxonomyGroup.healthStatus:
        return Icons.health_and_safety;
      case TaxonomyGroup.housingType:
        return Icons.home;
      case TaxonomyGroup.housingStatus:
        return Icons.house_siding;
      case TaxonomyGroup.disabilityType:
        return Icons.accessible;
      case TaxonomyGroup.incomeSource:
        return Icons.attach_money;
      case TaxonomyGroup.associationType:
        return Icons.business;
      case TaxonomyGroup.sponsorshipType:
        return Icons.volunteer_activism;
      case TaxonomyGroup.gender:
        return Icons.person;
      case TaxonomyGroup.visitType:
        return Icons.directions_walk;
      case TaxonomyGroup.assistanceType:
        return Icons.handshake;
      case TaxonomyGroup.beneficiaryStatus:
        return Icons.verified_user;
    }
  }
}

/// 🏷️ Taxonomy Chip Widget
///
/// عرض تصنيف كـ Chip
class TaxonomyChip extends ConsumerWidget {
  final String taxonomyId;
  final TaxonomyGroup? group;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;

  const TaxonomyChip({
    super.key,
    required this.taxonomyId,
    this.group,
    this.onDeleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomyAsync = ref.watch(taxonomyByIdProvider(taxonomyId));

    return taxonomyAsync.when(
      data: (taxonomy) {
        if (taxonomy == null) {
          return const SizedBox.shrink();
        }

        return Chip(
          label: Text(taxonomy.label),
          avatar: taxonomy.color != null
              ? CircleAvatar(
                  backgroundColor: _parseColor(taxonomy.color!),
                  radius: 10,
                )
              : null,
          deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 18) : null,
          onDeleted: onDeleted,
          backgroundColor: Colors.grey.shade100,
        );
      },
      loading: () => const Chip(
        label: SizedBox(
          width: 60,
          child: LinearProgressIndicator(),
        ),
      ),
      error: (_, __) => Chip(
        label: const Text('خطأ'),
        backgroundColor: Colors.red.shade100,
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

/// 📋 Taxonomy List Tile Widget
///
/// عرض تصنيف كـ ListTile
class TaxonomyListTile extends StatelessWidget {
  final Taxonomy taxonomy;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaxonomyListTile({
    super.key,
    required this.taxonomy,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeading(),
      title: Text(taxonomy.label),
      subtitle: Text('${taxonomy.group.arabicName} • ${taxonomy.code}'),
      trailing: showActions ? _buildActions() : _buildStatusIcon(),
      onTap: onTap,
    );
  }

  Widget _buildLeading() {
    if (taxonomy.color != null) {
      return CircleAvatar(
        backgroundColor: _parseColor(taxonomy.color!),
        child: Text(
          taxonomy.code.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    return CircleAvatar(
      child: Text(taxonomy.code.substring(0, 1).toUpperCase()),
    );
  }

  Widget? _buildStatusIcon() {
    if (!taxonomy.isActive) {
      return const Icon(Icons.visibility_off, color: Colors.grey);
    }
    if (taxonomy.isDeleted) {
      return const Icon(Icons.delete_outline, color: Colors.red);
    }
    return null;
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
      ],
    );
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

/// 🔄 Sync Status Widget
///
/// عرض حالة المزامنة
class TaxonomySyncStatusWidget extends ConsumerWidget {
  const TaxonomySyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(taxonomySyncStatusProvider);
    final errorMessage = ref.watch(taxonomyErrorMessageProvider);
    final lastSync = ref.watch(lastSyncTimeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildStatusIcon(syncStatus),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(syncStatus),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (syncStatus != TaxonomySyncStatus.syncing)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(taxonomySyncNotifierProvider.notifier).sync();
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('مزامنة'),
                  ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            lastSync.when(
              data: (time) => time != null
                  ? Text(
                      'آخر مزامنة: ${_formatDateTime(time)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : const Text('لم تتم المزامنة بعد'),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(TaxonomySyncStatus status) {
    switch (status) {
      case TaxonomySyncStatus.idle:
        return const Icon(Icons.sync, color: Colors.grey);
      case TaxonomySyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TaxonomySyncStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaxonomySyncStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  String _getStatusText(TaxonomySyncStatus status) {
    switch (status) {
      case TaxonomySyncStatus.idle:
        return 'جاهز للمزامنة';
      case TaxonomySyncStatus.syncing:
        return 'جاري المزامنة...';
      case TaxonomySyncStatus.success:
        return 'تمت المزامنة بنجاح';
      case TaxonomySyncStatus.error:
        return 'فشلت المزامنة';
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
