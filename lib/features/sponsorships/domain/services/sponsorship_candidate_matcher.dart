import '../../../../data/db/drift_database.dart';

class CandidateMatchResult {
  final String matchStatus;
  final int? beneficiaryLocalId;
  final double score;
  final String reason;

  const CandidateMatchResult({
    required this.matchStatus,
    required this.score,
    required this.reason,
    this.beneficiaryLocalId,
  });
}

class SponsorshipCandidateMatcher {
  SponsorshipCandidateMatcher(this._db);

  final AppDatabase _db;

  Future<CandidateMatchResult> matchCandidate({
    String? nationalId,
    String? phone,
    required String rawName,
    String? city,
  }) async {
    final normalizedName = _normalizeArabic(rawName);
    final normalizedCity = _normalizeArabic(city ?? '');

    final national = nationalId?.trim();
    if (national != null && national.isNotEmpty) {
      final idInt = int.tryParse(national);
      if (idInt != null) {
        final byNationalId =
            await (_db.select(_db.beneficiaries)..where((b) => b.idNumber.equals(idInt))).getSingleOrNull();
        if (byNationalId != null) {
          return CandidateMatchResult(
            matchStatus: 'matched_existing',
            beneficiaryLocalId: byNationalId.id,
            score: 1,
            reason: 'national_id_exact_match',
          );
        }
      }
    }

    final phoneInt = int.tryParse(phone?.trim() ?? '');
    if (phoneInt != null) {
      final byPhone = await (_db.select(_db.beneficiaries)..where((b) => b.phoneNumber.equals(phoneInt))).get();
      for (final candidate in byPhone) {
        final score = _nameSimilarity(normalizedName, _normalizeArabic(candidate.fullName));
        if (score >= 0.75) {
          return CandidateMatchResult(
            matchStatus: 'matched_existing',
            beneficiaryLocalId: candidate.id,
            score: score,
            reason: 'phone_exact_plus_name_similarity',
          );
        }
      }
    }

    final byName = await (_db.select(_db.beneficiaries)..where((b) => b.fullNameNorm.equals(normalizedName))).get();
    for (final candidate in byName) {
      final cityScore = _cityScore(normalizedCity, candidate.city?.toString() ?? '');
      if (cityScore >= 0.5) {
        return CandidateMatchResult(
          matchStatus: 'matched_existing',
          beneficiaryLocalId: candidate.id,
          score: 0.7,
          reason: 'normalized_name_plus_city',
        );
      }
    }

    return const CandidateMatchResult(
      matchStatus: 'needs_review',
      beneficiaryLocalId: null,
      score: 0,
      reason: 'manual_review_required',
    );
  }

  String _normalizeArabic(String input) {
    var value = input.trim().toLowerCase();
    value = value
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');
    value = value.replaceAll(RegExp(r'[^\u0600-\u06FF\s0-9a-z]'), ' ');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return value;
  }

  double _nameSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;

    final aTokens = a.split(' ').where((e) => e.isNotEmpty).toSet();
    final bTokens = b.split(' ').where((e) => e.isNotEmpty).toSet();
    if (aTokens.isEmpty || bTokens.isEmpty) return 0;

    final intersection = aTokens.intersection(bTokens).length.toDouble();
    final union = aTokens.union(bTokens).length.toDouble();
    return union == 0 ? 0 : intersection / union;
  }

  double _cityScore(String candidateCity, String beneficiaryCityRaw) {
    if (candidateCity.isEmpty) return 0.5;
    final normalizedBeneficiaryCity = _normalizeArabic(beneficiaryCityRaw);
    if (normalizedBeneficiaryCity.isEmpty) return 0.3;
    if (candidateCity == normalizedBeneficiaryCity) return 1;
    if (candidateCity.contains(normalizedBeneficiaryCity) || normalizedBeneficiaryCity.contains(candidateCity)) {
      return 0.7;
    }
    return 0;
  }
}
