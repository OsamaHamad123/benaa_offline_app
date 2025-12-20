import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/association.dart';
import '../../presentation/providers/associations_provider.dart';

/// 📊 تقارير الجمعيات - Providers

// ============================================================================
// STATISTICS PROVIDERS
// ============================================================================

/// إحصائيات الجمعيات
final associationsStatsProvider = Provider<AssociationsStats>((ref) {
  final state = ref.watch(associationsProvider);
  final associations = state.associations;

  return AssociationsStats(
    total: associations.length,
    active: associations.where((a) => a.isActive).length,
    inactive: associations.where((a) => !a.isActive).length,
    byCurrency: _groupByCurrency(associations),
    byBank: _groupByBank(associations),
    byRepresentative: _groupByRepresentative(associations, state.representatives),
    recentlyAdded: associations.where((a) {
      final diff = DateTime.now().difference(a.createdAt);
      return diff.inDays <= 30; // آخر 30 يوم
    }).length,
  );
});

/// تجميع حسب العملة
Map<String, int> _groupByCurrency(List<Association> associations) {
  final map = <String, int>{};
  for (final a in associations) {
    final currency = a.accountCurrency ?? 'غير محدد';
    map[currency] = (map[currency] ?? 0) + 1;
  }
  return map;
}

/// تجميع حسب البنك
Map<String, int> _groupByBank(List<Association> associations) {
  final map = <String, int>{};
  for (final a in associations) {
    map[a.bankName] = (map[a.bankName] ?? 0) + 1;
  }
  return map;
}

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
