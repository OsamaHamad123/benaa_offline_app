import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../data/models/taxonomy_dto.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../providers/taxonomy_bridge_providers.dart';
import '../providers/taxonomy_providers.dart';
import '../widgets/taxonomy_bridge_widgets.dart';

class _ScreenTaxonomyBinding {
  final String screenName;
  final Map<TaxonomyGroup, List<String>> groupToFields;

  const _ScreenTaxonomyBinding({
    required this.screenName,
    required this.groupToFields,
  });
}

const _screenBindingMatrix = <_ScreenTaxonomyBinding>[
  _ScreenTaxonomyBinding(
    screenName: 'إضافة مستفيد',
    groupToFields: {
      TaxonomyGroup.gender: ['genderCode'],
      TaxonomyGroup.category: ['categoryCode'],
      TaxonomyGroup.relationship: ['relationshipCode'],
      TaxonomyGroup.section: ['sectionCode'],
      TaxonomyGroup.maritalStatus: ['maritalStatusCode'],
      TaxonomyGroup.governorate: ['governorateCode'],
      TaxonomyGroup.displacementStatus: ['displacementStatusCode'],
      TaxonomyGroup.educationLevel: ['educationLevelCode'],
      TaxonomyGroup.employmentStatus: ['employmentStatusCode'],
      TaxonomyGroup.healthStatus: ['healthStatusCode'],
      TaxonomyGroup.housingStatus: ['housingStatusCode'],
      TaxonomyGroup.housingType: ['housingTypeCode'],
      TaxonomyGroup.assistanceType: ['assistanceTypeCode'],
      TaxonomyGroup.beneficiaryStatus: ['beneficiaryStatusCode'],
    },
  ),
  _ScreenTaxonomyBinding(
    screenName: 'تعديل مستفيد',
    groupToFields: {
      TaxonomyGroup.gender: ['genderCode'],
      TaxonomyGroup.category: ['categoryCode'],
      TaxonomyGroup.relationship: ['relationshipCode'],
      TaxonomyGroup.section: ['sectionCode'],
      TaxonomyGroup.maritalStatus: ['maritalStatusCode'],
      TaxonomyGroup.governorate: ['governorateCode'],
      TaxonomyGroup.displacementStatus: ['displacementStatusCode'],
      TaxonomyGroup.educationLevel: ['educationLevelCode'],
      TaxonomyGroup.employmentStatus: ['employmentStatusCode'],
      TaxonomyGroup.healthStatus: ['healthStatusCode'],
      TaxonomyGroup.housingStatus: ['housingStatusCode'],
      TaxonomyGroup.housingType: ['housingTypeCode'],
      TaxonomyGroup.assistanceType: ['assistanceTypeCode'],
      TaxonomyGroup.beneficiaryStatus: ['beneficiaryStatusCode'],
    },
  ),
  _ScreenTaxonomyBinding(
    screenName: 'مراجعة/تفاصيل مستفيد',
    groupToFields: {
      TaxonomyGroup.gender: ['displayGender'],
      TaxonomyGroup.category: ['displayCategory'],
      TaxonomyGroup.relationship: ['displayRelationship'],
      TaxonomyGroup.section: ['displaySection'],
      TaxonomyGroup.maritalStatus: ['displayMaritalStatus'],
      TaxonomyGroup.governorate: ['displayGovernorate'],
      TaxonomyGroup.displacementStatus: ['displayDisplacementStatus'],
      TaxonomyGroup.educationLevel: ['displayEducationLevel'],
      TaxonomyGroup.employmentStatus: ['displayEmploymentStatus'],
      TaxonomyGroup.healthStatus: ['displayHealthStatus'],
      TaxonomyGroup.housingStatus: ['displayHousingStatus'],
      TaxonomyGroup.housingType: ['displayHousingType'],
      TaxonomyGroup.assistanceType: ['displayAssistanceType'],
      TaxonomyGroup.beneficiaryStatus: ['displayBeneficiaryStatus'],
    },
  ),
];

String _buildScreenBindingMatrixReport() {
  final lines = <String>['مطابقة group -> form fields'];

  for (final binding in _screenBindingMatrix) {
    lines.add('');
    lines.add('${binding.screenName}:');

    final orderedGroups = binding.groupToFields.keys.toList()..sort((a, b) => a.value.compareTo(b.value));
    for (final group in orderedGroups) {
      final fields = binding.groupToFields[group] ?? const <String>[];
      lines.add('  - ${group.value} -> ${fields.join(', ')}');
    }
  }

  return lines.join('\n');
}

final _rawTaxonomyGroupsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.read(databaseProvider);
  final rows = await db.taxonomiesDao.getAllTaxonomies();

  final counts = <String, int>{};
  for (final row in rows) {
    final key = row.group.trim();
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final sorted = counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return {for (final entry in sorted) entry.key: entry.value};
});

final _taxonomyCoverageDiagnosticsProvider = FutureProvider<_TaxonomyCoverageDiagnostics>((ref) async {
  final remoteDataSource = ref.read(taxonomyRemoteDataSourceProvider);
  final rawGroups = await ref.read(_rawTaxonomyGroupsProvider.future);

  final remoteGroupsResponse = await remoteDataSource.getGroups();
  final remoteInfos = remoteGroupsResponse.data;

  final serverMappedGroups = <TaxonomyGroup>{};
  final serverUnknownSlugs = <String>{};
  for (final info in remoteInfos) {
    final resolved = _resolveGroupFromInfo(info);
    if (resolved != null) {
      serverMappedGroups.add(resolved);
    } else {
      final slug = info.slug.trim();
      if (slug.isNotEmpty) {
        serverUnknownSlugs.add(slug);
      }
    }
  }

  final localMappedGroups = <TaxonomyGroup>{};
  final localUnknownGroups = <String>{};
  for (final raw in rawGroups.keys) {
    final normalized = TaxonomyGroup.normalizeValue(raw);
    final resolved = TaxonomyGroup.fromString(raw) ?? TaxonomyGroup.fromString(normalized);
    if (resolved != null) {
      localMappedGroups.add(resolved);
    } else {
      localUnknownGroups.add(raw);
    }
  }

  final expectedGroups = TaxonomyGroup.values.toSet();
  final unavailableFromServer = expectedGroups.where((group) => !serverMappedGroups.contains(group)).toList()
    ..sort((a, b) => a.value.compareTo(b.value));
  final missingInLocal = serverMappedGroups.where((group) => !localMappedGroups.contains(group)).toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  final mappedToExistingField = <String>[];
  final newFieldRequiredSlugs = <String>[];
  final ignoredNotUsed = <String>[];

  final orderedUnknown = serverUnknownSlugs.toList()..sort();
  for (final slug in orderedUnknown) {
    final normalized = TaxonomyGroup.normalizeValue(slug);
    final mappedGroup = TaxonomyGroup.fromString(slug) ?? TaxonomyGroup.fromString(normalized);
    if (mappedGroup != null) {
      mappedToExistingField.add('$slug -> ${mappedGroup.value}');
      continue;
    }

    if (ignoredUnusedServerTaxonomySlugs.contains(slug)) {
      ignoredNotUsed.add(slug);
      continue;
    }

    newFieldRequiredSlugs.add(slug);
  }

  return _TaxonomyCoverageDiagnostics(
    serverTotalGroups: remoteInfos.length,
    serverMappedGroups: serverMappedGroups,
    localMappedGroups: localMappedGroups,
    unavailableFromServer: unavailableFromServer,
    missingInLocal: missingInLocal,
    serverUnknownSlugs: serverUnknownSlugs.toList()..sort(),
    localUnknownRawGroups: localUnknownGroups.toList()..sort(),
    mappedToExistingField: mappedToExistingField,
    newFieldRequiredSlugs: newFieldRequiredSlugs,
    ignoredNotUsedSlugs: ignoredNotUsed,
  );
});

TaxonomyGroup? _resolveGroupFromInfo(TaxonomyGroupInfoDTO info) {
  return resolveTaxonomyGroupFromCandidates([
    info.slug,
    info.name,
    info.endpoint,
    info.arabicName,
    info.englishName,
  ]);
}

class _TaxonomyCoverageDiagnostics {
  final int serverTotalGroups;
  final Set<TaxonomyGroup> serverMappedGroups;
  final Set<TaxonomyGroup> localMappedGroups;
  final List<TaxonomyGroup> unavailableFromServer;
  final List<TaxonomyGroup> missingInLocal;
  final List<String> serverUnknownSlugs;
  final List<String> localUnknownRawGroups;
  final List<String> mappedToExistingField;
  final List<String> newFieldRequiredSlugs;
  final List<String> ignoredNotUsedSlugs;

  const _TaxonomyCoverageDiagnostics({
    required this.serverTotalGroups,
    required this.serverMappedGroups,
    required this.localMappedGroups,
    required this.unavailableFromServer,
    required this.missingInLocal,
    required this.serverUnknownSlugs,
    required this.localUnknownRawGroups,
    required this.mappedToExistingField,
    required this.newFieldRequiredSlugs,
    required this.ignoredNotUsedSlugs,
  });
}

/// صفحة اختبار ربط جميع حقول التصنيفات.
///
/// الهدف: التحقق بسرعة أن كل مجموعة لديها بيانات وأن الـ dropdown مرتبط فعليًا.
class TaxonomyBindingTestPage extends ConsumerStatefulWidget {
  const TaxonomyBindingTestPage({super.key});

  @override
  ConsumerState<TaxonomyBindingTestPage> createState() => _TaxonomyBindingTestPageState();
}

class _TaxonomyBindingTestPageState extends ConsumerState<TaxonomyBindingTestPage> {
  final Map<TaxonomyGroup, String?> _selectedCodes = {
    for (final group in TaxonomyGroup.values) group: null,
  };

  Future<void> _syncAndRefresh() async {
    await ref.read(taxonomySyncNotifierProvider.notifier).sync();
    if (!mounted) return;

    ref.invalidate(allTaxonomiesProvider);
    ref.invalidate(taxonomyStatisticsProvider);
    ref.invalidate(lastSyncTimeProvider);

    for (final group in TaxonomyGroup.values) {
      ref.invalidate(taxonomiesByGroupProvider(group));
      ref.invalidate(bridgeTaxonomiesByGroupProvider(group));
      ref.invalidate(bridgeTaxonomiesByGroupOnceProvider(group));
    }
  }

  String _buildCoverageReport(_TaxonomyCoverageDiagnostics diagnostics) {
    final lines = <String>[
      'تقرير تشخيص التصنيفات',
      'مجموعات السيرفر: ${diagnostics.serverTotalGroups}',
      'مجموعات السيرفر المربوطة: ${diagnostics.serverMappedGroups.length}',
      'مجموعات المحلي المربوطة: ${diagnostics.localMappedGroups.length}',
      'ناقص محليًا من مجموعات السيرفر (${diagnostics.missingInLocal.length}): '
          '${diagnostics.missingInLocal.map((e) => e.value).join(', ')}',
      'غير متاح من السيرفر للتطبيق (${diagnostics.unavailableFromServer.length}): '
          '${diagnostics.unavailableFromServer.map((e) => e.value).join(', ')}',
    ];

    if (diagnostics.serverUnknownSlugs.isNotEmpty) {
      lines.add('Slugs سيرفر غير معروفة (${diagnostics.serverUnknownSlugs.length}): '
          '${diagnostics.serverUnknownSlugs.join(', ')}');
    }

    if (diagnostics.localUnknownRawGroups.isNotEmpty) {
      lines.add('Groups محلية غير معروفة (${diagnostics.localUnknownRawGroups.length}): '
          '${diagnostics.localUnknownRawGroups.join(', ')}');
    }

    lines
      ..add('')
      ..add('تصنيف Dynamic Taxonomies:')
      ..add('mapped-to-existing-field (${diagnostics.mappedToExistingField.length}): '
          '${diagnostics.mappedToExistingField.join(', ')}')
      ..add('new-field-required (${diagnostics.newFieldRequiredSlugs.length}): '
          '${diagnostics.newFieldRequiredSlugs.join(', ')}')
      ..add('ignored-not-used (${diagnostics.ignoredNotUsedSlugs.length}): '
          '${diagnostics.ignoredNotUsedSlugs.join(', ')}');

    lines
      ..add('')
      ..add(_buildScreenBindingMatrixReport());

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(taxonomyStatisticsProvider);
    final syncStatus = ref.watch(taxonomySyncStatusProvider);
    final rawGroupsAsync = ref.watch(_rawTaxonomyGroupsProvider);
    final coverageAsync = ref.watch(_taxonomyCoverageDiagnosticsProvider);
    final displayedGroups = coverageAsync.maybeWhen(
      data: (diagnostics) {
        final groups = diagnostics.serverMappedGroups.toList()..sort((a, b) => a.value.compareTo(b.value));
        return groups;
      },
      orElse: () => TaxonomyGroup.values,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار ربط التصنيفات'),
        actions: [
          IconButton(
            onPressed: _syncAndRefresh,
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'مزامنة وإعادة تحميل',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                for (final group in TaxonomyGroup.values) {
                  _selectedCodes[group] = null;
                }
              });
            },
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'مسح الاختيارات',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fact_check_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'حالة الربط العامة',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  statsAsync.when(
                    data: (stats) {
                      final nonEmpty = stats.countByGroup.values.where((count) => count > 0).length;
                      return Text(
                          'المجموعات المعبأة: $nonEmpty/${TaxonomyGroup.values.length} • إجمالي العناصر: ${stats.totalCount}');
                    },
                    loading: () => const Text('جاري تحميل إحصائيات التصنيفات...'),
                    error: (e, _) => Text('فشل تحميل الإحصائيات: $e'),
                  ),
                  const SizedBox(height: 6),
                  Text('حالة المزامنة: ${syncStatus.name}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storage_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'المجموعات الخام في قاعدة البيانات',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  rawGroupsAsync.when(
                    data: (groups) {
                      if (groups.isEmpty) {
                        return const Text('لا توجد بيانات تصنيفات محلية');
                      }

                      final lines = groups.entries.map((entry) {
                        final normalized = TaxonomyGroup.normalizeValue(entry.key);
                        final mapped = TaxonomyGroup.fromString(entry.key) != null ||
                                (normalized != null && TaxonomyGroup.fromString(normalized) != null)
                            ? '✅'
                            : '❌';
                        return '$mapped ${entry.key}: ${entry.value}';
                      }).join('\n');

                      return SelectableText(lines);
                    },
                    loading: () => const Text('جاري قراءة البيانات المحلية...'),
                    error: (e, _) => Text('فشل قراءة البيانات المحلية: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'تشخيص التغطية (سيرفر ↔ محلي)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  coverageAsync.when(
                    data: (diagnostics) {
                      final lines = <String>[
                        'مجموعات السيرفر: ${diagnostics.serverTotalGroups}',
                        'مجموعات السيرفر المربوطة: ${diagnostics.serverMappedGroups.length}/${TaxonomyGroup.values.length}',
                        'مجموعات المحلي المربوطة: ${diagnostics.localMappedGroups.length}/${diagnostics.serverMappedGroups.length}',
                        '',
                        '❗ ناقص محليًا من مجموعات السيرفر (${diagnostics.missingInLocal.length}): '
                            '${diagnostics.missingInLocal.map((e) => e.value).join(', ')}',
                        'ℹ️ غير متاح من السيرفر للتطبيق (${diagnostics.unavailableFromServer.length}): '
                            '${diagnostics.unavailableFromServer.map((e) => e.value).join(', ')}',
                      ];

                      if (diagnostics.serverUnknownSlugs.isNotEmpty) {
                        lines
                          ..add('')
                          ..add('⚠️ Slugs سيرفر غير معروفة للتطبيق (${diagnostics.serverUnknownSlugs.length}):')
                          ..add(diagnostics.serverUnknownSlugs.join(', '));
                      }

                      if (diagnostics.localUnknownRawGroups.isNotEmpty) {
                        lines
                          ..add('')
                          ..add('⚠️ Groups محلية غير معروفة (${diagnostics.localUnknownRawGroups.length}):')
                          ..add(diagnostics.localUnknownRawGroups.join(', '));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () async {
                                final report = _buildCoverageReport(diagnostics);
                                await Clipboard.setData(ClipboardData(text: report));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم نسخ تقرير التشخيص')),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded),
                              label: const Text('نسخ تقرير التشخيص'),
                            ),
                          ),
                          SelectableText(lines.join('\n')),
                        ],
                      );
                    },
                    loading: () => const Text('جاري تحليل تغطية التصنيفات...'),
                    error: (e, _) => Text('فشل تحليل التغطية: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rule_folder_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Dynamic Categories Policy',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  coverageAsync.when(
                    data: (diagnostics) {
                      final lines = <String>[
                        'mapped-to-existing-field (${diagnostics.mappedToExistingField.length}): '
                            '${diagnostics.mappedToExistingField.join(', ')}',
                        'new-field-required (${diagnostics.newFieldRequiredSlugs.length}): '
                            '${diagnostics.newFieldRequiredSlugs.join(', ')}',
                        'ignored-not-used (${diagnostics.ignoredNotUsedSlugs.length}): '
                            '${diagnostics.ignoredNotUsedSlugs.join(', ')}',
                      ];
                      return SelectableText(lines.join('\n'));
                    },
                    loading: () => const Text('جاري تصنيف dynamic groups...'),
                    error: (e, _) => Text('فشل تصنيف dynamic groups: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schema_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'تقرير مطابقة group -> form fields',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(_buildScreenBindingMatrixReport()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final group in displayedGroups) ...[
            _TaxonomyGroupTestCard(
              group: group,
              selectedCode: _selectedCodes[group],
              onChanged: (code) {
                setState(() {
                  _selectedCodes[group] = code;
                });
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TaxonomyGroupTestCard extends ConsumerWidget {
  final TaxonomyGroup group;
  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  const _TaxonomyGroupTestCard({
    required this.group,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanAsync = ref.watch(taxonomiesByGroupProvider(group));
    final bridgeAsync = ref.watch(bridgeTaxonomiesByGroupOnceProvider(group));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.arabicName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: cleanAsync.when(
                    data: (items) => Text('Clean: ${items.length}'),
                    loading: () => const Text('Clean: ...'),
                    error: (e, _) => Text('Clean: خطأ'),
                  ),
                ),
                Expanded(
                  child: bridgeAsync.when(
                    data: (items) => Text('Bridge: ${items.length}'),
                    loading: () => const Text('Bridge: ...'),
                    error: (e, _) => Text('Bridge: خطأ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TaxonomyBridgeDropdown(
              group: group,
              selectedCode: selectedCode,
              onCodeChanged: onChanged,
              labelText: group.arabicName,
              hintText: 'اختر ${group.arabicName}',
            ),
            const SizedBox(height: 8),
            Text(
              selectedCode == null || selectedCode!.isEmpty ? 'غير مختار' : 'المختار: $selectedCode',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
