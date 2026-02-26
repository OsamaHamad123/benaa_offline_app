class SponsorshipDto {
  final int? id;
  final int? sponsorId;
  final List<int>? sponsorIds;
  final String? sponsorName;
  final String? internalFileNumber;
  final String? relationIdNumber;
  final String? externalFileNumber;
  final String? identityNumber;
  final String? orphanName;
  final DateTime? sponsoredBirthDate;
  final String? guardianName;
  final String? guardianIdentityNumber;
  final int? sponsorshipDurationMonths;
  final DateTime? sponsorshipStartDate;
  final DateTime? sponsorshipEndDate;
  final int? sponsorshipTypeId;
  final String? sponsorshipTypeName;
  final int? guaranteeTypeId;
  final String? guaranteeTypeName;
  final int? sponsorshipStatusId;
  final String? sponsorshipStatusName;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorshipDto({
    this.id,
    this.sponsorId,
    this.sponsorIds,
    this.sponsorName,
    this.internalFileNumber,
    this.relationIdNumber,
    this.externalFileNumber,
    this.identityNumber,
    this.orphanName,
    this.sponsoredBirthDate,
    this.guardianName,
    this.guardianIdentityNumber,
    this.sponsorshipDurationMonths,
    this.sponsorshipStartDate,
    this.sponsorshipEndDate,
    this.sponsorshipTypeId,
    this.sponsorshipTypeName,
    this.guaranteeTypeId,
    this.guaranteeTypeName,
    this.sponsorshipStatusId,
    this.sponsorshipStatusName,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory SponsorshipDto.fromJson(Map<String, dynamic> json) {
    return SponsorshipDto(
      id: _asInt(json['id']),
      sponsorId: _asInt(json['sponsor_id']),
      sponsorIds: _asIntList(json['sponsor_ids']) ?? _extractSponsorsIds(json['sponsors']),
      sponsorName: _asString(json['sponsor_name']) ?? _asString(json['sponsoring_organization']),
      internalFileNumber: _asString(json['internal_file_number']),
      relationIdNumber: _asString(json['relation_id_number']),
      externalFileNumber: _asString(json['external_file_number']),
      identityNumber: _asString(json['identity_number']),
      orphanName: _asString(json['orphan_name']),
      sponsoredBirthDate: _asDateTime(json['sponsored_birth_date']),
      guardianName: _asString(json['guardian_name']),
      guardianIdentityNumber: _asString(json['guardian_identity_number']),
      sponsorshipDurationMonths: _asInt(json['sponsorship_duration_months']),
      sponsorshipStartDate: _asDateTime(json['sponsorship_start_date']),
      sponsorshipEndDate: _asDateTime(json['sponsorship_end_date']),
      sponsorshipTypeId: _asInt(json['sponsorship_type_id']),
      sponsorshipTypeName: _asString(json['sponsorship_type_name']),
      guaranteeTypeId: _asInt(json['guarantee_type_id']) ?? _asInt(json['person_type_of_guarantee_id']),
      guaranteeTypeName: _asString(json['guarantee_type_name']) ?? _asString(json['person_type_of_guarantee']),
      sponsorshipStatusId: _asInt(json['sponsorship_status_id']),
      sponsorshipStatusName: _asString(json['sponsorship_status_name']),
      notes: _asString(json['notes']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreatePayload({
    required int sponsorId,
    required String identityNumber,
    required String orphanName,
  }) {
    return {
      'sponsor_id': sponsorId,
      'sponsor_ids': (sponsorIds != null && sponsorIds!.isNotEmpty) ? sponsorIds : [sponsorId],
      'internal_file_number': internalFileNumber,
      'relation_id_number': relationIdNumber,
      'external_file_number': externalFileNumber,
      'identity_number': identityNumber,
      'orphan_name': orphanName,
      'sponsored_birth_date': _toIsoDate(sponsoredBirthDate),
      'guardian_name': guardianName,
      'guardian_identity_number': guardianIdentityNumber,
      'sponsorship_duration_months': sponsorshipDurationMonths,
      'sponsorship_start_date': _toIsoDate(sponsorshipStartDate),
      'sponsorship_end_date': _toIsoDate(sponsorshipEndDate),
      'sponsorship_type_id': sponsorshipTypeId,
      'guarantee_type_id': guaranteeTypeId,
      'sponsorship_status_id': sponsorshipStatusId,
      'person_type_of_guarantee': guaranteeTypeName,
      'notes': notes,
    }..removeWhere((_, value) => value == null);
  }

  Map<String, dynamic> toUpdatePayload({
    required int sponsorId,
    required String identityNumber,
    required String orphanName,
  }) =>
      toCreatePayload(
        sponsorId: sponsorId,
        identityNumber: identityNumber,
        orphanName: orphanName,
      );
}

class SponsorshipsListResponseDto {
  final List<SponsorshipDto> records;
  final bool hasMore;
  final DateTime? syncTimestamp;

  const SponsorshipsListResponseDto({
    required this.records,
    required this.hasMore,
    this.syncTimestamp,
  });

  factory SponsorshipsListResponseDto.fromJson(
    Map<String, dynamic> json, {
    required int page,
    required int perPage,
  }) {
    final rootData = _asMap(json['data']) ?? json;
    final rows = _extractRows(rootData);
    final pagination = _extractPagination(rootData);

    final currentPage = _asInt(pagination?['current_page']) ?? _asInt(rootData['current_page']) ?? page;
    final lastPage = _asInt(pagination?['last_page']) ?? _asInt(rootData['last_page']);
    final nextPageUrl = pagination?['next_page_url']?.toString() ?? rootData['next_page_url']?.toString();

    final hasMore = lastPage != null
        ? currentPage < lastPage
        : ((nextPageUrl != null && nextPageUrl.isNotEmpty) || rows.length >= perPage);

    return SponsorshipsListResponseDto(
      records: rows.map(SponsorshipDto.fromJson).toList(growable: false),
      hasMore: hasMore,
      syncTimestamp: _asDateTime(rootData['sync_timestamp']) ?? _asDateTime(json['sync_timestamp']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

List<int>? _asIntList(dynamic value) {
  if (value is! List) return null;
  final parsed = value.map(_asInt).whereType<int>().toList(growable: false);
  if (parsed.isEmpty) return null;
  return parsed;
}

List<int>? _extractSponsorsIds(dynamic value) {
  if (value is! List) return null;
  final parsed = value
      .map((item) {
        if (item is Map<String, dynamic>) return _asInt(item['id']);
        if (item is Map) return _asInt(item['id']);
        return null;
      })
      .whereType<int>()
      .toList(growable: false);
  if (parsed.isEmpty) return null;
  return parsed;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}

String? _toIsoDate(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String().split('T').first;
}

Map<String, dynamic>? _extractPagination(Map<String, dynamic> root) {
  final pagination = _asMap(root['pagination']);
  if (pagination != null) return pagination;

  final nested = _asMap(root['data']);
  if (nested == null) return null;

  return _asMap(nested['pagination']) ?? _asMap(nested['meta']);
}

List<Map<String, dynamic>> _extractRows(Map<String, dynamic> root) {
  for (final key in const ['records', 'items', 'data', 'sponsorships']) {
    final value = root[key];
    if (value is List) {
      return value.map(_asMap).whereType<Map<String, dynamic>>().toList(growable: false);
    }
  }

  final nested = _asMap(root['data']);
  if (nested != null) {
    for (final key in const ['records', 'items', 'data', 'sponsorships']) {
      final value = nested[key];
      if (value is List) {
        return value.map(_asMap).whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }
  }

  return const <Map<String, dynamic>>[];
}
