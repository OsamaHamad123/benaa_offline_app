import '../../../../taxonomies/domain/entities/taxonomy.dart';

class TaxonomySelectionNormalizer {
  static String? resolveTaxonomyCode({
    required String? rawValue,
    required List<Taxonomy> taxonomies,
  }) {
    final raw = rawValue?.trim();
    if (raw == null || raw.isEmpty) return null;

    if (taxonomies.isEmpty) return raw;

    final normalizedRaw = _normalizeToken(raw);

    for (final taxonomy in taxonomies) {
      final codeNorm = _normalizeToken(taxonomy.code);
      final labelNorm = _normalizeToken(taxonomy.label);
      final idNorm = _normalizeToken(taxonomy.id);

      if (normalizedRaw == codeNorm || normalizedRaw == labelNorm || (idNorm.isNotEmpty && normalizedRaw == idNorm)) {
        return taxonomy.code;
      }
    }

    return raw;
  }

  static String _normalizeToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }
}
