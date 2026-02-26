import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/association.dart';
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../presentation/providers/associations_provider.dart';

/// 📊 تقارير الجمعيات - Providers

// ============================================================================
// STATISTICS PROVIDERS
// ============================================================================

/// إحصائيات الجمعيات
final associationsStatsProvider = Provider<AssociationsStats>((ref) {
  final state = ref.watch(associationsProvider);
  final associations = state.associations;
  final currencyTaxonomies = ref
      .watch(bridgeTaxonomiesByGroupResolvedOnceProvider(TaxonomyGroup.currency))
      .maybeWhen(data: (items) => items, orElse: () => const []);
  final bankTaxonomies = ref
      .watch(bridgeTaxonomiesByGroupResolvedOnceProvider(TaxonomyGroup.bankName))
      .maybeWhen(data: (items) => items, orElse: () => const []);

  final currencyLabelByKey = <String, String>{
    for (final item in currencyTaxonomies) ...{
      _normalize(item.code): item.label,
      _normalize(item.label): item.label,
    },
  };
  final bankLabelByKey = <String, String>{
    for (final item in bankTaxonomies) ...{
      _normalize(item.code): item.label,
      _normalize(item.label): item.label,
    },
  };

  return AssociationsStats(
    total: associations.length,
    active: associations.where((a) => a.isActive).length,
    inactive: associations.where((a) => !a.isActive).length,
    byCurrency: _groupByCurrency(associations, currencyLabelByKey),
    byBank: _groupByBank(associations, bankLabelByKey),
    byRepresentative: _groupByRepresentative(associations, state.representatives),
    recentlyAdded: associations.where((a) {
      final diff = DateTime.now().difference(a.createdAt);
      return diff.inDays <= 30; // آخر 30 يوم
    }).length,
  );
});

/// تجميع حسب العملة
Map<String, int> _groupByCurrency(List<Association> associations, Map<String, String> labelsByKey) {
  final map = <String, int>{};
  for (final a in associations) {
    final rawValue = (a.accountCurrency ?? '').trim();
    final currency = rawValue.isEmpty ? 'غير محدد' : (labelsByKey[_normalize(rawValue)] ?? rawValue);
    map[currency] = (map[currency] ?? 0) + 1;
  }
  return map;
}

/// تجميع حسب البنك
Map<String, int> _groupByBank(List<Association> associations, Map<String, String> labelsByKey) {
  final map = <String, int>{};
  for (final a in associations) {
    final rawValue = a.bankName.trim();
    final bank = rawValue.isEmpty ? 'غير محدد' : (labelsByKey[_normalize(rawValue)] ?? rawValue);
    map[bank] = (map[bank] ?? 0) + 1;
  }
  return map;
}

String _normalize(String input) => input.trim().toLowerCase();

/// تجميع حسب المندوب
Map<String, int> _groupByRepresentative(
  List<Association> associations,
  List representatives,
) {
  final map = <String, int>{};
  for (final a in associations) {
    final rep = representatives.where((r) => r.id == a.representativeId).firstOrNull;
    if (rep != null) {
      map[rep.name] = (map[rep.name] ?? 0) + 1;
    }
  }
  return map;
}

// ============================================================================
// STATISTICS DATA CLASS
// ============================================================================

/// بيانات إحصائيات الجمعيات
class AssociationsStats {
  final int total;
  final int active;
  final int inactive;
  final Map<String, int> byCurrency;
  final Map<String, int> byBank;
  final Map<String, int> byRepresentative;
  final int recentlyAdded;

  AssociationsStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.byCurrency,
    required this.byBank,
    required this.byRepresentative,
    required this.recentlyAdded,
  });

  double get activePercentage => total > 0 ? (active / total) * 100 : 0;
  double get inactivePercentage => total > 0 ? (inactive / total) * 100 : 0;
}
