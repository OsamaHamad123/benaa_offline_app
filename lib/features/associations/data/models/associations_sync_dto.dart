class SponsorDto {
  final int id;
  final String? fileId;
  final String sponsorName;
  final String? sponsorShortName;
  final String? sponsorPhoneNumber;
  final String? sponsorEmail;
  final String? sponsorAddress;
  final String? contactPerson;
  final String? legacyPhone;
  final String? legacyEmail;
  final String? legacyAddress;
  final String? website;
  final String? description;
  final int? status;
  final bool? googleDriveEnabled;
  final String? googleDriveFolderName;
  final int? sponsorBankNameId;
  final String? sponsorBankName;
  final String? sponsorAccountBankNumber;
  final String? sponsorBankSwiftCode;
  final String? sponsorBankRelatedPhoneNumber;
  final String? sponsorBankAccountCurrency;
  final String? sponsorCurrencyName;
  final int? sponsorCategoryId;
  final String? countryCode;
  final String? countryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SponsorDto({
    required this.id,
    required this.sponsorName,
    this.fileId,
    this.sponsorShortName,
    this.sponsorPhoneNumber,
    this.sponsorEmail,
    this.sponsorAddress,
    this.contactPerson,
    this.legacyPhone,
    this.legacyEmail,
    this.legacyAddress,
    this.website,
    this.description,
    this.status,
    this.googleDriveEnabled,
    this.googleDriveFolderName,
    this.sponsorBankNameId,
    this.sponsorBankName,
    this.sponsorAccountBankNumber,
    this.sponsorBankSwiftCode,
    this.sponsorBankRelatedPhoneNumber,
    this.sponsorBankAccountCurrency,
    this.sponsorCurrencyName,
    this.sponsorCategoryId,
    this.countryCode,
    this.countryName,
    this.createdAt,
    this.updatedAt,
  });

  factory SponsorDto.fromJson(Map<String, dynamic> json) {
    return SponsorDto(
      id: _asInt(json['id']) ?? 0,
      fileId: _asString(json['file_id']),
      sponsorName: (json['sponsor_name'] ?? '').toString(),
      sponsorShortName: json['sponsor_short_name']?.toString(),
      sponsorPhoneNumber: json['sponsor_phone_number']?.toString(),
      sponsorEmail: json['sponsor_email']?.toString(),
      sponsorAddress: json['sponsor_address']?.toString(),
      contactPerson: json['contact_person']?.toString(),
      legacyPhone: json['phone']?.toString(),
      legacyEmail: json['email']?.toString(),
      legacyAddress: json['address']?.toString(),
      website: json['website']?.toString(),
      description: json['description']?.toString(),
      status: _asInt(json['status']),
      googleDriveEnabled: _asBool(json['google_drive_enabled']),
      googleDriveFolderName: json['google_drive_folder_name']?.toString(),
      sponsorBankNameId: _asInt(json['sponsor_bank_name_id']),
      sponsorBankName: json['sponsor_bank_name']?.toString(),
      sponsorAccountBankNumber: json['sponsor_account_bank_number']?.toString(),
      sponsorBankSwiftCode: json['sponsor_bank_swift_code']?.toString(),
      sponsorBankRelatedPhoneNumber: json['sponsor_bank_related_phone_number']?.toString(),
      sponsorBankAccountCurrency: json['sponsor_bank_account_currency']?.toString(),
      sponsorCurrencyName: json['sponsor_currency_name']?.toString(),
      sponsorCategoryId: _asInt(json['sponsor_category_id'] ?? json['association_type_id'] ?? json['category_id']),
      countryCode: json['country_code']?.toString(),
      countryName: json['country_name']?.toString(),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'sponsor_name': sponsorName,
      if (sponsorShortName != null && sponsorShortName!.trim().isNotEmpty) 'sponsor_short_name': sponsorShortName,
      if (sponsorPhoneNumber != null && sponsorPhoneNumber!.trim().isNotEmpty)
        'sponsor_phone_number': sponsorPhoneNumber,
      if (sponsorEmail != null && sponsorEmail!.trim().isNotEmpty) 'sponsor_email': sponsorEmail,
      if (sponsorAddress != null && sponsorAddress!.trim().isNotEmpty) 'sponsor_address': sponsorAddress,
      if (contactPerson != null && contactPerson!.trim().isNotEmpty) 'contact_person': contactPerson,
      if (legacyPhone != null && legacyPhone!.trim().isNotEmpty) 'phone': legacyPhone,
      if (legacyEmail != null && legacyEmail!.trim().isNotEmpty) 'email': legacyEmail,
      if (legacyAddress != null && legacyAddress!.trim().isNotEmpty) 'address': legacyAddress,
      if (website != null && website!.trim().isNotEmpty) 'website': website,
      if (description != null && description!.trim().isNotEmpty) 'description': description,
      if (status != null) 'status': status,
      if (googleDriveEnabled != null) 'google_drive_enabled': googleDriveEnabled,
      if (googleDriveFolderName != null && googleDriveFolderName!.trim().isNotEmpty)
        'google_drive_folder_name': googleDriveFolderName,
      if (sponsorBankNameId != null) 'sponsor_bank_name_id': sponsorBankNameId,
      if (sponsorCategoryId != null) 'sponsor_category_id': sponsorCategoryId,
      if (sponsorAccountBankNumber != null && sponsorAccountBankNumber!.trim().isNotEmpty)
        'sponsor_account_bank_number': sponsorAccountBankNumber,
      if (sponsorBankSwiftCode != null && sponsorBankSwiftCode!.trim().isNotEmpty)
        'sponsor_bank_swift_code': sponsorBankSwiftCode,
      if (sponsorBankRelatedPhoneNumber != null && sponsorBankRelatedPhoneNumber!.trim().isNotEmpty)
        'sponsor_bank_related_phone_number': sponsorBankRelatedPhoneNumber,
      if (sponsorBankAccountCurrency != null && sponsorBankAccountCurrency!.trim().isNotEmpty)
        'sponsor_bank_account_currency': sponsorBankAccountCurrency,
      if (countryCode != null && countryCode!.trim().isNotEmpty) 'country_code': countryCode,
    };
  }

  Map<String, dynamic> toUpdatePayload() => toCreatePayload();
}

class AssociationEmployeeDto {
  final int? id;
  final int sponsorId;
  final String? sponsorName;
  final String employeeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssociationEmployeeDto({
    required this.sponsorId,
    required this.employeeName,
    this.id,
    this.sponsorName,
    this.createdAt,
    this.updatedAt,
  });

  factory AssociationEmployeeDto.fromJson(Map<String, dynamic> json) {
    return AssociationEmployeeDto(
      id: _asInt(json['id']),
      sponsorId: _asInt(json['sponsor_id']) ?? 0,
      sponsorName: json['sponsor_name']?.toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'sponsor_id': sponsorId,
      'employee_name': employeeName,
    };
  }

  Map<String, dynamic> toUpdatePayload() => toCreatePayload();

  Map<String, dynamic> toBatchPayload() {
    return {
      if (id != null) 'id': id,
      'sponsor_id': sponsorId,
      'employee_name': employeeName,
    };
  }
}

class SponsorsListResponseDto {
  final List<SponsorDto> records;
  final bool hasMore;
  final DateTime? syncTimestamp;

  const SponsorsListResponseDto({
    required this.records,
    required this.hasMore,
    this.syncTimestamp,
  });

  factory SponsorsListResponseDto.fromJson(
    Map<String, dynamic> json, {
    required int page,
    required int perPage,
  }) {
    final rootData = _asMap(json['data']) ?? json;
    final rows = _extractRows(
      rootData,
      preferredKeys: const ['records', 'items', 'data', 'sponsors', 'associations'],
      markerKeys: const ['sponsor_name', 'sponsor_short_name', 'sponsor_phone_number'],
    );
    final pagination = _extractPagination(rootData);

    final currentPage = _asInt(pagination?['current_page']) ?? _asInt(rootData['current_page']) ?? page;
    final lastPage = _asInt(pagination?['last_page']) ?? _asInt(rootData['last_page']);
    final nextPageUrl = pagination?['next_page_url']?.toString() ?? rootData['next_page_url']?.toString();

    final hasMore = lastPage != null
        ? currentPage < lastPage
        : ((nextPageUrl != null && nextPageUrl.isNotEmpty) || rows.length >= perPage);

    return SponsorsListResponseDto(
      records: rows.map(SponsorDto.fromJson).toList(),
      hasMore: hasMore,
      syncTimestamp: _extractSyncTimestamp(rootData) ?? _extractSyncTimestamp(json),
    );
  }
}

class EmployeesListResponseDto {
  final List<AssociationEmployeeDto> records;
  final bool hasMore;
  final DateTime? syncTimestamp;

  const EmployeesListResponseDto({
    required this.records,
    required this.hasMore,
    this.syncTimestamp,
  });

  factory EmployeesListResponseDto.fromJson(
    Map<String, dynamic> json, {
    required int page,
    required int perPage,
  }) {
    final rootData = _asMap(json['data']) ?? json;
    final rows = _extractRows(
      rootData,
      preferredKeys: const ['records', 'items', 'data', 'employees', 'association_employees'],
      markerKeys: const ['employee_name', 'sponsor_id'],
    );
    final pagination = _extractPagination(rootData);

    final currentPage = _asInt(pagination?['current_page']) ?? _asInt(rootData['current_page']) ?? page;
    final lastPage = _asInt(pagination?['last_page']) ?? _asInt(rootData['last_page']);
    final nextPageUrl = pagination?['next_page_url']?.toString() ?? rootData['next_page_url']?.toString();

    final hasMore = lastPage != null
        ? currentPage < lastPage
        : ((nextPageUrl != null && nextPageUrl.isNotEmpty) || rows.length >= perPage);

    return EmployeesListResponseDto(
      records: rows.map(AssociationEmployeeDto.fromJson).toList(),
      hasMore: hasMore,
      syncTimestamp: _extractSyncTimestamp(rootData) ?? _extractSyncTimestamp(json),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final raw = value.toString().trim().toLowerCase();
  if (raw == '1' || raw == 'true' || raw == 'yes') return true;
  if (raw == '0' || raw == 'false' || raw == 'no') return false;
  return null;
}

Map<String, dynamic>? _extractPagination(Map<String, dynamic> root) {
  final pagination = _asMap(root['pagination']);
  if (pagination != null) return pagination;

  final meta = _asMap(root['meta']);
  if (meta != null) return meta;

  final nestedData = _asMap(root['data']);
  if (nestedData == null) return null;

  return _asMap(nestedData['pagination']) ?? _asMap(nestedData['meta']);
}

List<Map<String, dynamic>> _extractRows(
  Map<String, dynamic> root, {
  required List<String> preferredKeys,
  required List<String> markerKeys,
}) {
  for (final key in preferredKeys) {
    final value = root[key];
    if (value is List) {
      return value.map(_asMap).whereType<Map<String, dynamic>>().toList(growable: false);
    }
  }

  final nestedData = _asMap(root['data']);
  if (nestedData != null) {
    for (final key in preferredKeys) {
      final value = nestedData[key];
      if (value is List) {
        return value.map(_asMap).whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }
  }

  final deepRows = _findListOfMaps(root, markerKeys: markerKeys);
  if (deepRows != null) {
    return deepRows;
  }

  return const <Map<String, dynamic>>[];
}

DateTime? _extractSyncTimestamp(Map<String, dynamic> root) {
  return _asDateTime(root['sync_timestamp']) ??
      _asDateTime(root['timestamp']) ??
      _asDateTime(_asMap(root['meta'])?['sync_timestamp']);
}

List<Map<String, dynamic>>? _findListOfMaps(
  dynamic node, {
  required List<String> markerKeys,
  int depth = 0,
}) {
  if (depth > 8 || node == null) return null;

  if (node is List) {
    final asMaps = node.map(_asMap).whereType<Map<String, dynamic>>().toList(growable: false);
    if (asMaps.isNotEmpty) {
      final first = asMaps.first;
      final hasMarker = markerKeys.any(first.containsKey) || first.containsKey('id');
      if (hasMarker) return asMaps;
    }

    for (final item in node) {
      final nested = _findListOfMaps(item, markerKeys: markerKeys, depth: depth + 1);
      if (nested != null) return nested;
    }
    return null;
  }

  final map = _asMap(node);
  if (map == null) return null;

  for (final entry in map.entries) {
    final nested = _findListOfMaps(entry.value, markerKeys: markerKeys, depth: depth + 1);
    if (nested != null) return nested;
  }

  return null;
}
