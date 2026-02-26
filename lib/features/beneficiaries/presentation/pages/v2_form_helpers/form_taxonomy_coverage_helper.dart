import '../../../../../data/db/drift_database.dart';
import '../../../../taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../../../taxonomies/domain/entities/taxonomy_group.dart';

class FormTaxonomyCoverageSnapshot {
  final List<TaxonomyGroup> missingGroups;
  final List<String> unknownGroups;

  const FormTaxonomyCoverageSnapshot({
    required this.missingGroups,
    required this.unknownGroups,
  });
}

class FormTaxonomyCoverageHelper {
  static Future<FormTaxonomyCoverageSnapshot> evaluate(AppDatabase db) async {
    final availableGroups =
        await db.taxonomiesDao.getAllGroups().timeout(const Duration(seconds: 2), onTimeout: () => const <String>[]);

    final coverage = analyzeBeneficiaryTaxonomyCoverage(availableGroups);
    final missingGroups = missingEssentialBeneficiaryFormTaxonomyGroups(coverage.resolvedGroups);

    return FormTaxonomyCoverageSnapshot(
      missingGroups: missingGroups,
      unknownGroups: coverage.unknownGroups,
    );
  }

  static String formatMissingGroupsMessage(List<TaxonomyGroup> missingGroups) {
    final names = missingGroups.map((group) => group.arabicName).join('، ');
    return '⚠️ تصنيفات غير متوفرة في الفورم: $names. يرجى مزامنة التصنيفات.';
  }
}
