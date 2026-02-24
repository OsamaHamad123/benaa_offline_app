import 'dart:developer' as developer;

import '../../../taxonomies/domain/entities/taxonomy_group.dart';

class TaxonomyValueResolver {
  const TaxonomyValueResolver._();

  static bool looksLikeMachineCode(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;

    return RegExp(r'^\d+$').hasMatch(normalized) || normalized.contains('::') || normalized.contains('_');
  }

  static String displayLabel({
    required String? rawValue,
    required String? resolvedLabel,
    String fallback = 'غير محدد',
  }) {
    final resolved = resolvedLabel?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return resolved;
    }

    final raw = rawValue?.trim();
    if (raw == null || raw.isEmpty) {
      return fallback;
    }

    if (looksLikeMachineCode(raw)) {
      return fallback;
    }

    return raw;
  }

  static int? resolveToInt({
    required String code,
    required String id,
    TaxonomyGroup? group,
    String source = 'unknown',
  }) {
    final fromCode = _extractInt(code);
    if (fromCode != null) return fromCode;

    final fromId = _extractInt(id);
    if (fromId == null && group != null) {
      _logParseFailure(group: group, source: source, code: code, id: id);
    }
    return fromId;
  }

  static String? resolveCanonicalToken({required String code, required String id}) {
    final normalizedCode = code.trim();
    if (normalizedCode.isNotEmpty) return normalizedCode;

    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    if (normalizedId.contains('::')) {
      final tail = normalizedId.split('::').last.trim();
      if (tail.isNotEmpty) return tail;
    }

    return normalizedId;
  }

  static void logSummary({
    required TaxonomyGroup group,
    required String source,
    required int total,
    required int resolved,
  }) {
    final parseFailures = total - resolved;
    if (parseFailures <= 0) return;

    developer.log(
      'taxonomy parsing summary | group=${group.value} source=$source total=$total resolved=$resolved parseFailures=$parseFailures',
      name: 'BeneficiaryTaxonomyParsing',
    );
  }

  static int? _extractInt(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final direct = int.tryParse(value);
    if (direct != null) return direct;

    final parts = value.split('::');
    if (parts.length > 1) {
      final trailing = int.tryParse(parts.last.trim());
      if (trailing != null) return trailing;
    }

    final match = RegExp(r'(\d+)$').firstMatch(value);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static void _logParseFailure({
    required TaxonomyGroup group,
    required String source,
    required String code,
    required String id,
  }) {
    developer.log(
      'taxonomy parse failure | group=${group.value} source=$source code=$code id=$id',
      name: 'BeneficiaryTaxonomyParsing',
    );
  }
}
