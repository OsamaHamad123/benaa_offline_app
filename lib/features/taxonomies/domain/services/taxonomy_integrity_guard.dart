import '../contracts/beneficiary_taxonomy_contract.dart';
import '../entities/taxonomy.dart';
import '../entities/taxonomy_group.dart';

enum TaxonomyGapSource {
  none,
  localMapping,
  backendPayload,
  partialPayloadOrData,
}

class TaxonomyIntegrityReport {
  final List<String> unresolvedDocumentedSlugs;
  final List<TaxonomyGroup> missingEssentialGroups;
  final List<TaxonomyGroup> missingDocumentedGroups;
  final TaxonomyGapSource likelySource;

  const TaxonomyIntegrityReport({
    required this.unresolvedDocumentedSlugs,
    required this.missingEssentialGroups,
    required this.missingDocumentedGroups,
    required this.likelySource,
  });
}

class TaxonomyIntegrityGuard {
  const TaxonomyIntegrityGuard();

  static const criticalFallbackGroups = <TaxonomyGroup>{
    TaxonomyGroup.category,
    TaxonomyGroup.gender,
    TaxonomyGroup.section,
    TaxonomyGroup.assistanceType,
    TaxonomyGroup.beneficiaryStatus,
    TaxonomyGroup.documentType,
    TaxonomyGroup.deathReason,
    TaxonomyGroup.disabilityType,
    TaxonomyGroup.incomeSource,
  };

  static const _fallbackOptions = <TaxonomyGroup, List<({String code, String label})>>{
    TaxonomyGroup.category: [
      (code: 'general', label: 'فئة عامة'),
    ],
    TaxonomyGroup.gender: [
      (code: 'male', label: 'ذكر'),
      (code: 'female', label: 'أنثى'),
    ],
    TaxonomyGroup.section: [
      (code: 'general', label: 'عام'),
    ],
    TaxonomyGroup.assistanceType: [
      (code: 'general_assistance', label: 'مساعدة عامة'),
    ],
    TaxonomyGroup.beneficiaryStatus: [
      (code: 'pending', label: 'قيد الدراسة'),
      (code: 'approved', label: 'مقبول'),
    ],
    TaxonomyGroup.documentType: [
      (code: 'id_card', label: 'هوية شخصية'),
    ],
    TaxonomyGroup.deathReason: [
      (code: 'other', label: 'أخرى'),
    ],
    TaxonomyGroup.disabilityType: [
      (code: 'other', label: 'إعاقة أخرى'),
    ],
    TaxonomyGroup.incomeSource: [
      (code: 'none', label: 'بدون دخل'),
    ],
  };

  TaxonomyIntegrityReport assess(TaxonomyStatistics stats) {
    final unresolved = unresolvedDocumentedCategorySlugs();
    final missingEssential = missingEssentialBeneficiaryFormTaxonomyGroups(_availableGroups(stats));
    final missingDocumented = _missingDocumentedBackendGroups(stats);

    final source = _resolveLikelySource(
      unresolvedDocumentedSlugs: unresolved,
      missingEssentialGroups: missingEssential,
      missingDocumentedGroups: missingDocumented,
    );

    return TaxonomyIntegrityReport(
      unresolvedDocumentedSlugs: unresolved,
      missingEssentialGroups: missingEssential,
      missingDocumentedGroups: missingDocumented,
      likelySource: source,
    );
  }

  List<TaxonomyGroup> missingCriticalFallbackGroups(TaxonomyStatistics stats) {
    final available = _availableGroups(stats);
    final missing = <TaxonomyGroup>[];
    for (final group in criticalFallbackGroups) {
      if (!available.contains(group)) {
        missing.add(group);
      }
    }
    return missing;
  }

  List<Taxonomy> buildFallbackTaxonomies({
    required TaxonomyStatistics stats,
    required Map<TaxonomyGroup, List<Taxonomy>> existingByGroup,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final missingCritical = missingCriticalFallbackGroups(stats);
    if (missingCritical.isEmpty) {
      return const <Taxonomy>[];
    }

    final out = <Taxonomy>[];

    for (final group in missingCritical) {
      final existing = existingByGroup[group] ?? const <Taxonomy>[];
      if (existing.isNotEmpty) {
        continue;
      }

      final options = _fallbackOptions[group] ?? const <({String code, String label})>[];
      if (options.isEmpty) {
        continue;
      }

      for (var index = 0; index < options.length; index++) {
        final option = options[index];
        out.add(
          Taxonomy(
            id: '__fallback_${group.value}_${option.code}',
            group: group,
            code: option.code,
            label: option.label,
            sortOrder: index,
            isActive: true,
            metadata: const {
              'source': 'fallback_local',
              'is_fallback': true,
            },
            createdAt: clock,
            updatedAt: clock,
          ),
        );
      }
    }

    return out;
  }

  TaxonomyGapSource _resolveLikelySource({
    required List<String> unresolvedDocumentedSlugs,
    required List<TaxonomyGroup> missingEssentialGroups,
    required List<TaxonomyGroup> missingDocumentedGroups,
  }) {
    if (unresolvedDocumentedSlugs.isNotEmpty) {
      return TaxonomyGapSource.localMapping;
    }

    if (missingEssentialGroups.isNotEmpty && missingDocumentedGroups.isNotEmpty) {
      return TaxonomyGapSource.backendPayload;
    }

    if (missingEssentialGroups.isNotEmpty) {
      return TaxonomyGapSource.partialPayloadOrData;
    }

    return TaxonomyGapSource.none;
  }

  List<TaxonomyGroup> _availableGroups(TaxonomyStatistics stats) {
    return stats.countByGroup.entries.where((entry) => entry.value > 0).map((entry) => entry.key).toList();
  }

  List<TaxonomyGroup> _missingDocumentedBackendGroups(TaxonomyStatistics stats) {
    final expectedGroups =
        backendDocumentedCategorySlugs.map(TaxonomyGroup.fromString).whereType<TaxonomyGroup>().toSet();

    final missing = <TaxonomyGroup>[];
    for (final group in expectedGroups) {
      if ((stats.countByGroup[group] ?? 0) <= 0) {
        missing.add(group);
      }
    }

    missing.sort((a, b) => a.value.compareTo(b.value));
    return missing;
  }
}
