import '../../../../taxonomies/domain/entities/taxonomy.dart';
import '../../../../taxonomies/domain/entities/taxonomy_group.dart';
import 'form_controllers.dart';
import 'taxonomy_selection_normalizer.dart';

class FormTaxonomyBulkNormalizer {
  static Future<void> normalizeAll({
    required BeneficiaryFormControllers controllers,
    required Map<TaxonomyGroup, List<Taxonomy>> taxonomyIndex,
  }) async {
    _normalizeAndSet(
      rawValue: controllers.selectedGender,
      taxonomies: taxonomyIndex[TaxonomyGroup.gender] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedGender = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedCategory,
      taxonomies: taxonomyIndex[TaxonomyGroup.category] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedCategory = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedMaritalStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.maritalStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedMaritalStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedEducationLevel,
      taxonomies: taxonomyIndex[TaxonomyGroup.educationLevel] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedEducationLevel = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedEmploymentStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.employmentStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedEmploymentStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedRelationship,
      taxonomies: taxonomyIndex[TaxonomyGroup.relationship] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedRelationship = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedSection,
      taxonomies: taxonomyIndex[TaxonomyGroup.section] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedSection = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedProvince,
      taxonomies: taxonomyIndex[TaxonomyGroup.governorate] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedProvince = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedCity,
      taxonomies: taxonomyIndex[TaxonomyGroup.city] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedCity = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedDisplacementStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.displacementStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedDisplacementStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedHealthStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.healthStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedHealthStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedHousingStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.housingStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedHousingStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedHousingType,
      taxonomies: taxonomyIndex[TaxonomyGroup.housingType] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedHousingType = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedAssistanceType,
      taxonomies: taxonomyIndex[TaxonomyGroup.assistanceType] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedAssistanceType = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedRequestStatus,
      taxonomies: taxonomyIndex[TaxonomyGroup.beneficiaryStatus] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedRequestStatus = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedDisabilityType,
      taxonomies: taxonomyIndex[TaxonomyGroup.disabilityType] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedDisabilityType = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedIncomeSource,
      taxonomies: taxonomyIndex[TaxonomyGroup.incomeSource] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedIncomeSource = value,
    );
    _normalizeAndSet(
      rawValue: controllers.selectedGuaranteeType,
      taxonomies: taxonomyIndex[TaxonomyGroup.guaranteeType] ?? const <Taxonomy>[],
      setter: (value) => controllers.selectedGuaranteeType = value,
    );
  }

  static void _normalizeAndSet({
    required String? rawValue,
    required List<Taxonomy> taxonomies,
    required void Function(String?) setter,
  }) {
    final normalized = TaxonomySelectionNormalizer.resolveTaxonomyCode(
      rawValue: rawValue,
      taxonomies: taxonomies,
    );
    if (normalized != null && normalized != rawValue) {
      setter(normalized);
    }
  }
}
