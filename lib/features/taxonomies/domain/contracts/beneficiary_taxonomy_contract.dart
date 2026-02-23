import '../entities/taxonomy_group.dart';

const requiredBeneficiaryTaxonomyGroups = <TaxonomyGroup>[
  TaxonomyGroup.gender,
  TaxonomyGroup.category,
  TaxonomyGroup.relationship,
  TaxonomyGroup.section,
  TaxonomyGroup.maritalStatus,
  TaxonomyGroup.governorate,
  TaxonomyGroup.displacementStatus,
  TaxonomyGroup.educationLevel,
  TaxonomyGroup.employmentStatus,
  TaxonomyGroup.healthStatus,
  TaxonomyGroup.housingStatus,
  TaxonomyGroup.housingType,
  TaxonomyGroup.disabilityType,
  TaxonomyGroup.incomeSource,
  TaxonomyGroup.assistanceType,
  TaxonomyGroup.beneficiaryStatus,
];

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
  final available = availableGroups.toSet();
  return requiredBeneficiaryTaxonomyGroups.where((group) => !available.contains(group)).toList(growable: false);
}
