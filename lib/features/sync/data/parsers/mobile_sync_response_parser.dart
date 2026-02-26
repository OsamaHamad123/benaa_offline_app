class MobileSyncResponseParser {
  Map<String, dynamic>? toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = entry.value;
      }
      return result;
    }
    return null;
  }

  List<Map<String, dynamic>> toMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    final out = <Map<String, dynamic>>[];
    for (final item in value) {
      final map = toMap(item);
      if (map != null) {
        out.add(map);
      }
    }
    return out;
  }

  ({List<Map<String, dynamic>> rows, bool hasMore}) parseRelatedRowsResponse({
    required dynamic raw,
    required int page,
    required int pageSize,
    required List<String> listKeys,
  }) {
    final data = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final rows = _extractRowsFromPayload(data, preferredKeys: listKeys);
    final pagination = _extractPaginationMap(data);

    bool hasMore;
    if (pagination != null) {
      final currentPage = _asInt(pagination['current_page']) ?? _asInt(pagination['page']) ?? page;
      final lastPage = _asInt(pagination['last_page']) ?? _asInt(pagination['total_pages']);
      final nextPageUrl = pagination['next_page_url']?.toString();
      final hasNextUrl = nextPageUrl != null && nextPageUrl.isNotEmpty;
      hasMore = lastPage != null ? currentPage < lastPage : (hasNextUrl || rows.length >= pageSize);
    } else {
      hasMore = rows.length >= pageSize;
    }

    return (rows: rows, hasMore: hasMore);
  }

  ({
    List<dynamic> records,
    bool hasMore,
    List<Map<String, dynamic>> attachments,
    List<Map<String, dynamic>> familyMembers,
    List<Map<String, dynamic>> familyDeceased,
  }) parseBeneficiariesResponse(
    dynamic raw,
    int page,
    int pageSize,
  ) {
    final data = toMap(raw) ?? <String, dynamic>{};
    final entities = data['entities'];
    final rawData = data['data'];

    List<dynamic> records = const [];
    final attachments = <Map<String, dynamic>>[];
    final familyMembers = <Map<String, dynamic>>[];
    final familyDeceased = <Map<String, dynamic>>[];

    if (entities is List) {
      final normalized = <dynamic>[];
      for (final item in entities) {
        final entityMap = toMap(item);
        if (entityMap == null) continue;

        final entityType = (entityMap['entity_type'] ?? entityMap['entityType'])?.toString().toLowerCase().trim();
        final payload = entityMap['data'];
        final row = toMap(payload) ?? entityMap;

        if (entityType == null || entityType == 'beneficiary' || entityType == 'beneficiaries') {
          normalized.add(row);
        } else if (entityType.contains('attach')) {
          attachments.add(row);
        } else if (entityType.contains('dead') || entityType.contains('deceased')) {
          familyDeceased.add(row);
        } else if (entityType.contains('family_member') ||
            entityType.contains('member') ||
            entityType.contains('orphan') ||
            entityType.contains('re_people')) {
          familyMembers.add(row);
        }
      }
      records = normalized;
    } else if (rawData is List) {
      records = rawData;
    } else if (toMap(rawData) != null) {
      final rawDataMap = toMap(rawData)!;
      final fromKey = rawDataMap['beneficiaries'] ??
          rawDataMap['re_people'] ??
          rawDataMap['people'] ??
          rawDataMap['records'] ??
          rawDataMap['items'] ??
          rawDataMap['data'];
      if (fromKey is List) {
        records = fromKey;
      }

      attachments.addAll(extractRelatedList(rawDataMap, const ['attachments', 'documents', 'files']));
      familyMembers.addAll(extractRelatedList(rawDataMap, const ['family_members', 'members', 'orphans', 're_people']));
      familyDeceased.addAll(extractRelatedList(
        rawDataMap,
        const ['dead_people', 'family_deceased', 'deceased', 'deceased_parents'],
        normalizeDeceased: true,
      ));
    } else if (data['re_people'] is List) {
      records = data['re_people'] as List<dynamic>;
    } else if (data['beneficiaries'] is List) {
      records = data['beneficiaries'] as List<dynamic>;
    }

    attachments.addAll(extractRelatedList(data, const ['attachments', 'documents', 'files']));
    familyMembers.addAll(extractRelatedList(data, const ['family_members', 'members', 'orphans', 're_people']));
    familyDeceased.addAll(extractRelatedList(
      data,
      const ['dead_people', 'family_deceased', 'deceased', 'deceased_parents'],
      normalizeDeceased: true,
    ));

    final pagination = data['pagination'];
    bool hasMore = false;
    if (pagination is Map<String, dynamic>) {
      final currentPage = _asInt(pagination['current_page']) ?? _asInt(pagination['page']) ?? page;
      final lastPage = _asInt(pagination['last_page']) ?? _asInt(pagination['total_pages']);
      if (lastPage != null) {
        hasMore = currentPage < lastPage;
      }
    } else {
      hasMore = records.length >= pageSize;
    }

    return (
      records: records,
      hasMore: hasMore,
      attachments: attachments,
      familyMembers: familyMembers,
      familyDeceased: familyDeceased,
    );
  }

  List<Map<String, dynamic>> extractRelatedList(
    Map<String, dynamic> source,
    List<String> keys, {
    bool normalizeDeceased = false,
  }) {
    final results = <Map<String, dynamic>>[];

    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;

      if (value is List) {
        results.addAll(toMapList(value));
        continue;
      }

      final valueMap = toMap(value);
      if (valueMap == null) continue;

      if (normalizeDeceased &&
          (key == 'deceased_parents' || valueMap.containsKey('father') || valueMap.containsKey('mother'))) {
        results.addAll(_extractDeceasedParents(valueMap));
        continue;
      }

      final flattened = _extractRowsFromValue(valueMap);
      if (flattened.isNotEmpty) {
        results.addAll(flattened);
      } else {
        results.add(valueMap);
      }
    }

    return results;
  }

  List<Map<String, dynamic>> _extractDeceasedParents(Map<String, dynamic> container) {
    final out = <Map<String, dynamic>>[];

    Map<String, dynamic>? father = toMap(container['father']);
    Map<String, dynamic>? mother = toMap(container['mother']);

    father ??= _extractFromPrefixed(container, 'father_');
    mother ??= _extractFromPrefixed(container, 'mother_');

    if (father != null && _mapHasMeaningfulValue(father)) {
      out.add(_normalizeParent(parent: father, type: 'father'));
    }
    if (mother != null && _mapHasMeaningfulValue(mother)) {
      out.add(_normalizeParent(parent: mother, type: 'mother'));
    }

    return out;
  }

  Map<String, dynamic>? _extractFromPrefixed(Map<String, dynamic> source, String prefix) {
    final mapped = <String, dynamic>{};
    for (final entry in source.entries) {
      if (entry.key.startsWith(prefix)) {
        if (_hasMeaningfulValue(entry.value)) {
          mapped[entry.key.substring(prefix.length)] = entry.value;
        }
      }
    }
    return mapped.isEmpty ? null : mapped;
  }

  bool _mapHasMeaningfulValue(Map<String, dynamic> map) {
    for (final entry in map.entries) {
      if (_hasMeaningfulValue(entry.value)) {
        return true;
      }
    }
    return false;
  }

  bool _hasMeaningfulValue(dynamic value) {
    if (value == null) return false;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return false;
    if (raw == 'null' || raw == 'false') return false;
    return true;
  }

  Map<String, dynamic> _normalizeParent({
    required Map<String, dynamic> parent,
    required String type,
  }) {
    final prefixed = type == 'father' ? 'father_' : 'mother_';

    final firstName = _pickParentValue(parent, prefixed, const ['first_name', 'name']);
    final secondName = _pickParentValue(parent, prefixed, const ['second_name']);
    final thirdName = _pickParentValue(parent, prefixed, const ['third_name']);
    final familyName = _pickParentValue(parent, prefixed, const ['last_name', 'family_name']);
    final nationalId = _pickParentValue(parent, prefixed, const ['id', 'national_id', 'person_id', 'id_number']);
    final deathDate = _pickParentValue(parent, prefixed, const ['death_date', 'deceased_at']);
    final deathReason = _pickParentValue(parent, prefixed, const ['death_reason', 'death_reason_id']);

    return {
      ...parent,
      'deceased_type': type,
      'first_name': firstName,
      'second_name': secondName,
      'third_name': thirdName,
      'family_name': familyName,
      'national_id': nationalId,
      'death_date': deathDate,
      'death_cause': deathReason,
    };
  }

  dynamic _pickParentValue(
    Map<String, dynamic> parent,
    String prefixed,
    List<String> keys,
  ) {
    for (final key in keys) {
      final direct = parent[key];
      if (direct != null) return direct;

      final prefixedValue = parent['$prefixed$key'];
      if (prefixedValue != null) return prefixedValue;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractRowsFromPayload(
    Map<String, dynamic> root, {
    required List<String> preferredKeys,
  }) {
    final directData = _extractRowsFromValue(root['data']);
    if (directData.isNotEmpty) return directData;

    final fromPreferred = _extractRowsFromMapByKeys(root, preferredKeys);
    if (fromPreferred.isNotEmpty) return fromPreferred;

    final dataNode = root['data'];
    if (dataNode is Map<String, dynamic>) {
      final nestedPreferred = _extractRowsFromMapByKeys(dataNode, preferredKeys);
      if (nestedPreferred.isNotEmpty) return nestedPreferred;
    }

    final commonKeys = <String>['rows', 'records', 'items', 'results', 'entities'];
    final fromCommon = _extractRowsFromMapByKeys(root, commonKeys);
    if (fromCommon.isNotEmpty) return fromCommon;

    if (dataNode is Map<String, dynamic>) {
      final nestedCommon = _extractRowsFromMapByKeys(dataNode, commonKeys);
      if (nestedCommon.isNotEmpty) return nestedCommon;
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractRowsFromMapByKeys(
    Map<String, dynamic> root,
    List<String> keys,
  ) {
    for (final key in keys) {
      final directRows = _extractRowsFromValue(root[key]);
      if (directRows.isNotEmpty) return directRows;

      for (final value in _findValuesByKeyRecursive(root, key)) {
        final nestedRows = _extractRowsFromValue(value);
        if (nestedRows.isNotEmpty) return nestedRows;
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Iterable<dynamic> _findValuesByKeyRecursive(dynamic node, String targetKey) sync* {
    final nodeMap = toMap(node);
    if (nodeMap != null) {
      for (final entry in nodeMap.entries) {
        if (entry.key == targetKey) {
          yield entry.value;
        }
        yield* _findValuesByKeyRecursive(entry.value, targetKey);
      }
    } else if (node is List) {
      for (final item in node) {
        yield* _findValuesByKeyRecursive(item, targetKey);
      }
    }
  }

  List<Map<String, dynamic>> _extractRowsFromValue(dynamic value) {
    if (value is List) {
      return toMapList(value);
    }

    if (value is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'records', 'rows', 'results', 'entities']) {
        final nested = value[key];
        if (nested is List) {
          final rows = toMapList(nested);
          if (rows.isNotEmpty) return rows;
        }
      }

      final listRows = <Map<String, dynamic>>[];
      for (final entry in value.entries) {
        if (entry.value is List) {
          listRows.addAll(toMapList(entry.value));
        }
      }
      if (listRows.isNotEmpty) return listRows;
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractPaginationMap(Map<String, dynamic> root) {
    final candidates = <dynamic>[
      root['pagination'],
      root['meta'],
      root['data'] is Map<String, dynamic> ? (root['data'] as Map<String, dynamic>)['pagination'] : null,
      root['data'] is Map<String, dynamic> ? (root['data'] as Map<String, dynamic>)['meta'] : null,
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
    }

    for (final key in const ['pagination', 'meta']) {
      for (final candidate in _findValuesByKeyRecursive(root, key)) {
        if (candidate is Map<String, dynamic>) {
          return candidate;
        }
      }
    }

    return null;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
