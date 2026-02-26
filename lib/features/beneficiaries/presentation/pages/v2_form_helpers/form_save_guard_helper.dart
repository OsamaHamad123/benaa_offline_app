import '../../../../taxonomies/domain/entities/taxonomy_group.dart';

class FormSaveGuardHelper {
  static Future<bool> ensureTaxonomyCoverage({
    required List<TaxonomyGroup> currentMissingGroups,
    required Future<void> Function() refreshCoverage,
    required void Function(String message) onWarning,
  }) async {
    var missingGroups = currentMissingGroups;

    if (missingGroups.isEmpty) {
      await refreshCoverage();
      missingGroups = currentMissingGroups;
    }

    if (missingGroups.isEmpty) {
      return true;
    }

    final missingNames = missingGroups.map((group) => group.arabicName).join('، ');
    onWarning('تعذّر إكمال الحفظ قبل مزامنة التصنيفات الناقصة: $missingNames');
    return false;
  }
}
