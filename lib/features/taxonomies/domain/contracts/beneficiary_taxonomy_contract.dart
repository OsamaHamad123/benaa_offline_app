import '../entities/taxonomy_group.dart';

class BeneficiaryTaxonomyCoverageReport {
  final Set<TaxonomyGroup> resolvedGroups;
  final List<String> unknownGroups;
  final List<TaxonomyGroup> missingGroups;

  const BeneficiaryTaxonomyCoverageReport({
    required this.resolvedGroups,
    required this.unknownGroups,
    required this.missingGroups,
  });
}

const requiredBeneficiaryTaxonomyGroups = <TaxonomyGroup>[
  TaxonomyGroup.relationship,
  TaxonomyGroup.maritalStatus,
  TaxonomyGroup.governorate,
  TaxonomyGroup.city,
  TaxonomyGroup.displacementStatus,
  TaxonomyGroup.educationLevel,
  TaxonomyGroup.employmentStatus,
  TaxonomyGroup.healthStatus,
  TaxonomyGroup.housingStatus,
  TaxonomyGroup.housingType,
  TaxonomyGroup.assistanceType,
  TaxonomyGroup.beneficiaryStatus,
  TaxonomyGroup.guaranteeType,
];

/// مجموعات التصنيفات التي يجب أن تكون جاهزة لتجربة فورم المستفيد بالكامل
/// (الأساسي + العائلة + المرفقات).
const essentialBeneficiaryFormTaxonomyGroups = <TaxonomyGroup>[
  TaxonomyGroup.gender,
  TaxonomyGroup.category,
  TaxonomyGroup.section,
  TaxonomyGroup.relationship,
  TaxonomyGroup.maritalStatus,
  TaxonomyGroup.governorate,
  TaxonomyGroup.city,
  TaxonomyGroup.displacementStatus,
  TaxonomyGroup.educationLevel,
  TaxonomyGroup.employmentStatus,
  TaxonomyGroup.healthStatus,
  TaxonomyGroup.housingStatus,
  TaxonomyGroup.housingType,
  TaxonomyGroup.assistanceType,
  TaxonomyGroup.beneficiaryStatus,
  TaxonomyGroup.disabilityType,
  TaxonomyGroup.incomeSource,
  TaxonomyGroup.sponsorshipType,
  TaxonomyGroup.documentType,
  TaxonomyGroup.deathReason,
  TaxonomyGroup.guaranteeType,
];

/// المجموعة القياسية لفئة المستفيد داخل الفورم.
/// نعتمد `category` كمرجع canonical مع قبول `section` كمكافئ قديم.
const TaxonomyGroup canonicalBeneficiaryCategoryGroup = TaxonomyGroup.category;

/// مجموعات مكافئة دلالياً لبيانات المستفيد.
/// تستخدم في preflight حتى لا تُعتبر البيانات ناقصة إذا وصلت بأحد البدائل الرسمية.
const equivalentBeneficiaryTaxonomyGroups = <TaxonomyGroup, List<TaxonomyGroup>>{
  TaxonomyGroup.section: [TaxonomyGroup.category],
  TaxonomyGroup.category: [TaxonomyGroup.section],
  TaxonomyGroup.sponsorshipType: [TaxonomyGroup.beneficiaryStatus],
  TaxonomyGroup.beneficiaryStatus: [TaxonomyGroup.sponsorshipType],
};

/// Alias mapping الرسمي بين مجموعة التصنيف وslugs السيرفر المحتملة.
/// يستخدم كعقد domain موحّد بدل بعثرة الـ aliases داخل الطبقات المختلفة.
const beneficiaryTaxonomyServerAliases = <TaxonomyGroup, List<String>>{
  TaxonomyGroup.category: ['categories', 'beneficiary-categories'],
  TaxonomyGroup.governorate: ['governorates', 'provinces'],
  TaxonomyGroup.city: ['cities', 'city'],
  TaxonomyGroup.maritalStatus: ['marital-statuses', 'social-statuses', 'social-status'],
  TaxonomyGroup.displacementStatus: ['displacement-statuses', 'displacement-status'],
  TaxonomyGroup.employmentStatus: ['employment-statuses', 'job-statuses', 'job-status'],
  TaxonomyGroup.educationLevel: ['education-levels', 'educational-levels', 'academic-degrees'],
  TaxonomyGroup.healthStatus: ['health-statuses', 'health-conditions'],
  TaxonomyGroup.housingType: ['housing-types', 'residence-types', 'accommodation-types'],
  TaxonomyGroup.housingStatus: ['housing-statuses', 'housing-conditions', 'residence-status'],
  TaxonomyGroup.disabilityType: ['disability-types', 'special-needs-types'],
  TaxonomyGroup.incomeSource: ['income-sources', 'income'],
  TaxonomyGroup.bankName: ['bank-names', 'bank-name', 'banks'],
  TaxonomyGroup.currency: ['currencies', 'currency'],
  TaxonomyGroup.associationType: ['association-types', 'associations-types'],
  TaxonomyGroup.sponsorshipType: ['sponsorship-types', 'sponsorship-categories', 'sponsorship'],
  TaxonomyGroup.guaranteeType: ['guarantee-types', 'guarantee-type'],
  TaxonomyGroup.gender: ['sex', 'genders', 'sexes'],
  TaxonomyGroup.visitType: ['visit-types', 'visits-types'],
  TaxonomyGroup.assistanceType: ['assistance-types', 'aid-types', 'aid-statuses'],
  TaxonomyGroup.beneficiaryStatus: [
    'beneficiary-statuses',
    'beneficiary-state',
    'sponsorship-statuses',
    'request-statuses',
  ],
  TaxonomyGroup.relationship: ['relationships', 'kinship', 'relations'],
  TaxonomyGroup.section: ['sections', 'departments', 'department'],
  TaxonomyGroup.documentType: ['document-types', 'documents-types', 'attachment-types'],
  TaxonomyGroup.deathReason: ['death-reasons', 'death-causes'],
};

/// Slugs الموثقة في API server داخل todo.md (قسم Categories).
const backendDocumentedCategorySlugs = <String>[
  'categories',
  'genders',
  'academic-degrees',
  'relations',
  'aid-statuses',
  'bank-names',
  'cities',
  'currencies',
  'death-reasons',
  'displacement-statuses',
  'document-types',
  'employment-statuses',
  'health-statuses',
  'housing-statuses',
  'marital-statuses',
  'provinces',
  'request-statuses',
  'sponsorship-statuses',
  'accommodation-types',
  'guarantee-types',
];

/// Policy map (documented backend slug -> canonical app group value).
///
/// الهدف: منع الاعتماد على heuristics العامة في slugs الموثقة،
/// وتثبيت قرار التطبيع بشكل صريح وقابل للمراجعة.
const backendDocumentedSlugCanonicalGroup = <String, String>{
  'categories': 'category',
  'genders': 'gender',
  'academic-degrees': 'education_level',
  'relations': 'relationship',
  'aid-statuses': 'assistance_type',
  'bank-names': 'bank_name',
  'cities': 'city',
  'currencies': 'currency',
  'death-reasons': 'death_reason',
  'displacement-statuses': 'displacement_status',
  'document-types': 'document_type',
  'employment-statuses': 'employment_status',
  'health-statuses': 'health_status',
  'housing-statuses': 'housing_status',
  'marital-statuses': 'marital_status',
  'provinces': 'governorate',
  'request-statuses': 'beneficiary_status',
  'sponsorship-statuses': 'beneficiary_status',
  'accommodation-types': 'housing_type',
  'guarantee-types': 'guarantee_type',
};

String normalizeBackendCategorySlug(String value) {
  return value.trim().toLowerCase().replaceAll('_', '-');
}

bool isBackendDocumentedCategorySlug(String value) {
  final normalized = normalizeBackendCategorySlug(value);
  return backendDocumentedCategorySlugs.any((slug) => slug == normalized);
}

String? resolveBackendDocumentedCategoryCanonicalGroup(String value) {
  final normalized = normalizeBackendCategorySlug(value);
  return backendDocumentedSlugCanonicalGroup[normalized];
}

List<String> serverCategorySlugCandidatesForGroup(TaxonomyGroup group) {
  final candidates = <String>[];

  void addCandidate(String? value) {
    if (value == null) return;
    final normalized = normalizeBackendCategorySlug(value);
    if (normalized.isEmpty) return;
    if (!candidates.contains(normalized)) {
      candidates.add(normalized);
    }
  }

  final aliases = beneficiaryTaxonomyServerAliases[group] ?? const <String>[];
  final normalizedAliases = aliases.map(normalizeBackendCategorySlug).toList(growable: false);

  for (final slug in backendDocumentedCategorySlugs) {
    if (normalizedAliases.contains(slug)) {
      addCandidate(slug);
    }
  }

  for (final alias in aliases) {
    addCandidate(alias);
  }

  addCandidate(group.value);
  return candidates;
}

List<String> unresolvedDocumentedCategorySlugs([Iterable<String>? slugs]) {
  final source = slugs ?? backendDocumentedCategorySlugs;
  return source.where((slug) => TaxonomyGroup.fromString(slug) == null).toList(growable: false);
}

const ignoredUnusedServerTaxonomySlugs = <String>{
  'fird',
};

TaxonomyGroup? resolveTaxonomyGroupFromCandidates(Iterable<String?> candidates) {
  for (final candidate in candidates) {
    final group = TaxonomyGroup.fromString(candidate);
    if (group != null) {
      return group;
    }
  }
  return null;
}

List<TaxonomyGroup> missingRequiredTaxonomyGroups(Iterable<TaxonomyGroup> availableGroups) {
  return missingTaxonomyGroups(
    availableGroups: availableGroups,
    requiredGroups: requiredBeneficiaryTaxonomyGroups,
  );
}

List<TaxonomyGroup> missingTaxonomyGroups({
  required Iterable<TaxonomyGroup> availableGroups,
  required Iterable<TaxonomyGroup> requiredGroups,
}) {
  final available = availableGroups.toSet();
  return requiredGroups.where((group) {
    if (available.contains(group)) {
      return false;
    }

    final equivalents = equivalentBeneficiaryTaxonomyGroups[group] ?? const <TaxonomyGroup>[];
    return !equivalents.any(available.contains);
  }).toList(growable: false);
}

List<TaxonomyGroup> missingEssentialBeneficiaryFormTaxonomyGroups(Iterable<TaxonomyGroup> availableGroups) {
  return missingTaxonomyGroups(
    availableGroups: availableGroups,
    requiredGroups: essentialBeneficiaryFormTaxonomyGroups,
  );
}

List<TaxonomyGroup> missingRequiredTaxonomyGroupsFromValues(Iterable<String> availableGroupValues) {
  return analyzeBeneficiaryTaxonomyCoverage(availableGroupValues).missingGroups;
}

BeneficiaryTaxonomyCoverageReport analyzeBeneficiaryTaxonomyCoverage(Iterable<String> availableGroupValues) {
  final available = <TaxonomyGroup>{};
  final unknownGroups = <String>[];
  for (final raw in availableGroupValues) {
    final normalized = TaxonomyGroup.normalizeValue(raw);
    final resolved = TaxonomyGroup.fromString(normalized);
    if (resolved != null) {
      available.add(resolved);
    } else {
      final candidate = raw.trim();
      if (candidate.isNotEmpty && !unknownGroups.contains(candidate)) {
        unknownGroups.add(candidate);
      }
    }
  }

  return BeneficiaryTaxonomyCoverageReport(
    resolvedGroups: available,
    unknownGroups: unknownGroups,
    missingGroups: missingRequiredTaxonomyGroups(available),
  );
}
