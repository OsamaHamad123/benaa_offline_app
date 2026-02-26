import '../../domain/entities/taxonomy.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../../../data/db/drift_database.dart' show TaxonomiesCompanion;
import 'package:drift/drift.dart' as drift;

/// 📦 Taxonomy DTO
///
/// Data Transfer Object لتصنيف من API
class TaxonomyDTO {
  final String id;
  final String groupValue;
  final String code;
  final String label;
  final String? labelEn;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final String? description;
  final String? color;
  final String? icon;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const TaxonomyDTO({
    required this.id,
    required this.groupValue,
    required this.code,
    required this.label,
    this.labelEn,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.description,
    this.color,
    this.icon,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TaxonomyDTO.fromJson(Map<String, dynamic> json) {
    final rawGroup = json['group']?.toString() ?? '';
    final normalizedGroup = TaxonomyGroup.normalizeValue(rawGroup) ?? rawGroup;

    return TaxonomyDTO(
      id: json['id']?.toString() ?? '',
      groupValue: normalizedGroup,
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString(),
      parentId: json['parent_id']?.toString(),
      sortOrder: _parseInt(json['sort_order']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic> ? json['metadata'] as Map<String, dynamic> : const {},
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupValue,
      'code': code,
      'label': label,
      if (labelEn != null) 'label_en': labelEn,
      if (parentId != null) 'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (metadata.isNotEmpty) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  TaxonomiesCompanion toDbCompanion() {
    final localId = buildLocalId(
      groupValue: groupValue,
      rawId: id,
      code: code,
    );

    return TaxonomiesCompanion.insert(
      id: localId,
      group: groupValue,
      code: code,
      label: label,
      updatedAt: updatedAt ?? DateTime.now(),
      parentId: drift.Value(parentId),
      sortOrder: drift.Value(sortOrder),
      isActive: drift.Value(isActive && deletedAt == null),
    );
  }

  static String buildLocalId({
    required String groupValue,
    required String rawId,
    String? code,
  }) {
    final normalizedGroup = TaxonomyGroup.normalizeValue(groupValue) ?? groupValue;
    final normalizedId = rawId.trim();
    if (normalizedId.contains('::')) {
      return normalizedId;
    }

    final fallback = (code ?? '').trim();
    final resolvedRemoteId = normalizedId.isNotEmpty ? normalizedId : fallback;
    if (resolvedRemoteId.isEmpty) {
      return '${normalizedGroup}::unknown';
    }

    return '$normalizedGroup::$resolvedRemoteId';
  }

  static String extractRemoteId(String localId) {
    final value = localId.trim();
    if (value.isEmpty) {
      return value;
    }

    final separatorIndex = value.indexOf('::');
    if (separatorIndex < 0 || separatorIndex + 2 >= value.length) {
      return value;
    }

    return value.substring(separatorIndex + 2);
  }

  /// تحويل إلى Entity
  Taxonomy toEntity() {
    return Taxonomy(
      id: id,
      group: TaxonomyGroup.fromString(groupValue) ?? TaxonomyGroup.category,
      code: code,
      label: label,
      labelEn: labelEn,
      parentId: parentId,
      sortOrder: sortOrder,
      isActive: isActive,
      description: description,
      color: color,
      icon: icon,
      metadata: metadata,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt,
    );
  }

  /// إنشاء من Entity
  static TaxonomyDTO fromEntity(Taxonomy entity) {
    return TaxonomyDTO(
      id: entity.id,
      groupValue: entity.group.value,
      code: entity.code,
      label: entity.label,
      labelEn: entity.labelEn,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      metadata: entity.metadata ?? const {},
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  TaxonomyDTO copyWith({
    String? id,
    String? groupValue,
    String? code,
    String? label,
    String? labelEn,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    String? description,
    String? color,
    String? icon,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaxonomyDTO(
      id: id ?? this.id,
      groupValue: groupValue ?? this.groupValue,
      code: code ?? this.code,
      label: label ?? this.label,
      labelEn: labelEn ?? this.labelEn,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Helper methods
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// 📋 API Response DTOs

/// رد جلب التصنيفات
class TaxonomiesResponseDTO {
  final bool success;
  final List<TaxonomyDTO> data;
  final String? message;
  final TaxonomyMetaDTO? meta;
  final DateTime? syncTimestamp;

  const TaxonomiesResponseDTO({
    required this.success,
    required this.data,
    this.message,
    this.meta,
    this.syncTimestamp,
  });

  factory TaxonomiesResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomiesResponseDTO(
      success: json['success'] == true,
      data:
          (json['data'] as List<dynamic>?)?.map((e) => TaxonomyDTO.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      message: json['message']?.toString(),
      meta: json['meta'] != null ? TaxonomyMetaDTO.fromJson(json['meta'] as Map<String, dynamic>) : null,
    );
  }

  /// ✅ Parse single-group endpoint responses with resilient shapes.
  /// Supports:
  /// - {data: [ ... ]}
  /// - {data: {items: [...]}}
  /// - {data: {values: [...]}}
  /// - {data: {<slug>: {items:[...]}}}
  factory TaxonomiesResponseDTO.fromGroupJson(
    Map<String, dynamic> json, {
    required String fallbackGroup,
  }) {
    final normalizedGroup = TaxonomyGroup.normalizeValue(fallbackGroup) ?? fallbackGroup;
    final taxonomies = <TaxonomyDTO>[];

    List<Map<String, dynamic>> extractItems(dynamic node) {
      if (node is List) {
        return node.whereType<Map<String, dynamic>>().toList();
      }

      if (node is Map<String, dynamic>) {
        for (final key in const ['items', 'values', 'options', 'records', 'data', 'children']) {
          final candidate = node[key];
          if (candidate is List) {
            final out = candidate.whereType<Map<String, dynamic>>().toList();
            if (out.isNotEmpty) return out;
          }
        }

        for (final entry in node.entries) {
          if (entry.value is Map<String, dynamic>) {
            final out = extractItems(entry.value);
            if (out.isNotEmpty) return out;
          }
        }
      }

      return const [];
    }

    final dataNode = json['data'];
    final items = extractItems(dataNode);
    for (final item in items) {
      final label =
          (item['name'] ?? item['label'] ?? item['title'] ?? item['name_ar'] ?? item['label_ar'] ?? '').toString();
      if (label.isEmpty) continue;

      final id = (item['id'] ?? item['value'] ?? item['code'])?.toString() ?? '';
      if (id.isEmpty) continue;

      taxonomies.add(TaxonomyDTO(
        id: id,
        groupValue: normalizedGroup,
        code: item['code']?.toString() ?? item['slug']?.toString() ?? id,
        label: label,
        labelEn: (item['name_en'] ?? item['label_en'] ?? item['title_en'])?.toString(),
        parentId: item['parent_id']?.toString(),
        sortOrder: _parseInt(item['sort_order'] ?? item['sort'] ?? item['order']),
        isActive: _parseBool(item['is_active'] ?? item['active'] ?? item['enabled'], defaultValue: true),
        createdAt: _parseDateTime(item['created_at']),
        updatedAt: _parseDateTime(item['updated_at']),
        deletedAt: _parseDateTime(item['deleted_at']),
      ));
    }

    return TaxonomiesResponseDTO(
      success: json['success'] == true,
      data: taxonomies,
      message: json['message']?.toString(),
      meta: json['meta'] != null ? TaxonomyMetaDTO.fromJson(json['meta'] as Map<String, dynamic>) : null,
    );
  }

  /// ✅ Parse sync-all API response format
  /// Format: { "success": true, "data": { "categories": { "slug": { items: [...] } } } }
  factory TaxonomiesResponseDTO.fromSyncAllJson(Map<String, dynamic> json) {
    final List<TaxonomyDTO> taxonomies = [];

    final data = json['data'];
    var categoryEntries = _extractCategoryEntries(data);
    if (categoryEntries.isEmpty) {
      categoryEntries = _extractCategoryEntries(json);
    }

    for (final entry in categoryEntries) {
      final slug = entry.slug;
      final categoryData = entry.category;
      final items = _extractCategoryItems(categoryData);

      final labelAr = (categoryData['label_ar'] ??
              categoryData['name_ar'] ??
              categoryData['title_ar'] ??
              categoryData['label'] ??
              categoryData['name'] ??
              categoryData['title'] ??
              slug)
          .toString();
      final labelEn = (categoryData['label_en'] ??
              categoryData['name_en'] ??
              categoryData['title_en'] ??
              categoryData['english_name'] ??
              categoryData['slug'])
          ?.toString();
      final resolvedGroup = _resolveGroupValue(slug, labelAr, labelEn);
      final resolvedOuterGroup = TaxonomyGroup.fromString(resolvedGroup);

      for (final item in items) {
        final itemGroupRaw = (item['group'] ??
                item['group_value'] ??
                item['group_slug'] ??
                item['category_group'] ??
                item['category_slug'] ??
                item['category'] ??
                item['taxonomy_group'] ??
                item['taxonomy_type'] ??
                item['type'] ??
                item['bucket'] ??
                item['table'] ??
                slug)
            .toString();

        final itemLabelAr =
            (item['name_ar'] ?? item['label_ar'] ?? item['name'] ?? item['label'] ?? item['title'] ?? labelAr)
                .toString();
        final itemLabelEn =
            (item['name_en'] ?? item['label_en'] ?? item['title_en'] ?? item['english_name'] ?? labelEn)?.toString();

        final resolvedItemGroup = _resolveGroupValue(itemGroupRaw, itemLabelAr, itemLabelEn);
        final resolvedInnerGroup = TaxonomyGroup.fromString(resolvedItemGroup);
        final effectiveGroup = resolvedOuterGroup?.value ?? resolvedInnerGroup?.value ?? resolvedGroup;

        taxonomies.add(TaxonomyDTO(
          id: item['id']?.toString() ??
              item['value']?.toString() ??
              item['code']?.toString() ??
              item['slug']?.toString() ??
              '',
          groupValue: effectiveGroup,
          code: item['code']?.toString() ??
              item['slug']?.toString() ??
              item['value']?.toString() ??
              item['id']?.toString() ??
              '',
          label:
              (item['name'] ?? item['label'] ?? item['title'] ?? item['name_ar'] ?? item['label_ar'] ?? '').toString(),
          labelEn: (item['name_en'] ?? item['label_en'] ?? item['title_en'])?.toString() ?? labelEn,
          parentId: item['parent_id']?.toString(),
          sortOrder: _parseInt(item['sort_order'] ?? item['sort'] ?? item['order']),
          isActive: _parseBool(item['is_active'] ?? item['active'] ?? item['enabled'], defaultValue: true),
          createdAt: _parseDateTime(item['created_at']),
          updatedAt: _parseDateTime(item['updated_at']),
          deletedAt: _parseDateTime(item['deleted_at']),
        ));
      }
    }

    if (taxonomies.isEmpty) {
      taxonomies.addAll(_extractFlatTaxonomies(json));
    }

    // Parse sync timestamp
    DateTime? syncTime;
    final dataNode = json['data'];
    final syncTimestampStr = dataNode is Map<String, dynamic> ? dataNode['sync_timestamp']?.toString() : null;
    if (syncTimestampStr != null) {
      syncTime = DateTime.tryParse(syncTimestampStr);
    }

    return TaxonomiesResponseDTO(
      success: json['success'] == true,
      data: taxonomies,
      message: json['message']?.toString(),
      syncTimestamp: syncTime,
    );
  }

  static List<({String slug, Map<String, dynamic> category})> _extractCategoryEntries(dynamic dataNode) {
    final normalizedDataNode = _asStringDynamicMap(dataNode);
    if (normalizedDataNode == null) {
      return const [];
    }

    final categoriesNode = normalizedDataNode['categories'];
    final entries = <({String slug, Map<String, dynamic> category})>[];

    final categoriesMap = _asStringDynamicMap(categoriesNode);
    if (categoriesMap != null) {
      categoriesMap.forEach((slug, value) {
        final valueMap = _asStringDynamicMap(value);
        if (valueMap != null) {
          entries.add((slug: slug.toString(), category: valueMap));
          return;
        }

        final valueList = _asMapList(value);
        if (valueList.isNotEmpty) {
          entries.add((slug: slug.toString(), category: {'items': valueList}));
          return;
        }

        final scalarValueList = _coerceScalarListToItems(value);
        if (scalarValueList.isNotEmpty) {
          entries.add((slug: slug.toString(), category: {'items': scalarValueList}));
        }
      });
      return entries;
    }

    if (categoriesNode is List) {
      for (final raw in categoriesNode) {
        final rawMap = _asStringDynamicMap(raw);
        if (rawMap != null) {
          final slug = (raw['slug'] ??
                  raw['group'] ??
                  raw['group_slug'] ??
                  raw['taxonomy_group'] ??
                  raw['category_slug'] ??
                  raw['type'] ??
                  raw['key'] ??
                  raw['code'] ??
                  raw['name_en'] ??
                  raw['name'] ??
                  '')
              .toString();
          if (slug.isNotEmpty) {
            entries.add((slug: slug, category: rawMap));
          }
        }
      }
      return entries;
    }

    final entriesFromDataMap = <({String slug, Map<String, dynamic> category})>[];
    for (final entry in normalizedDataNode.entries) {
      final value = entry.value;
      final valueMap = _asStringDynamicMap(value);
      if (valueMap != null && _extractCategoryItems(valueMap).isNotEmpty) {
        entriesFromDataMap.add((slug: entry.key, category: valueMap));
        continue;
      }

      final valueList = _asMapList(value);
      if (valueList.isNotEmpty) {
        entriesFromDataMap.add((slug: entry.key, category: {'items': valueList}));
        continue;
      }

      final scalarValueList = _coerceScalarListToItems(value);
      if (scalarValueList.isNotEmpty) {
        entriesFromDataMap.add((slug: entry.key, category: {'items': scalarValueList}));
      }
    }

    if (entriesFromDataMap.isNotEmpty) {
      return entriesFromDataMap;
    }

    return const [];
  }

  static List<Map<String, dynamic>> _extractCategoryItems(Map<String, dynamic> categoryData) {
    const metadataKeys = {
      'label_ar',
      'label_en',
      'label',
      'name',
      'name_ar',
      'name_en',
      'title',
      'title_ar',
      'title_en',
      'slug',
      'endpoint',
      'count',
      'total',
      'pagination',
      'category',
      'sync_timestamp',
      'meta',
      'message',
      'success',
    };

    for (final key in const ['items', 'values', 'options', 'records', 'data', 'children']) {
      final candidate = categoryData[key];
      if (candidate is List) {
        final mapped = _asMapList(candidate);
        if (mapped.isNotEmpty) return mapped;

        final scalarMapped = _coerceScalarListToItems(candidate);
        if (scalarMapped.isNotEmpty) return scalarMapped;
      }
      final candidateMap = _asStringDynamicMap(candidate);
      if (candidateMap != null) {
        for (final nestedKey in const ['items', 'data', 'values']) {
          final nested = candidateMap[nestedKey];
          if (nested is List) {
            final mapped = _asMapList(nested);
            if (mapped.isNotEmpty) return mapped;

            final scalarMapped = _coerceScalarListToItems(nested);
            if (scalarMapped.isNotEmpty) return scalarMapped;
          }

          final nestedMap = _asStringDynamicMap(nested);
          if (nestedMap != null) {
            final nestedKeyedMapped = _coerceKeyedMapToItems(nestedMap, excludedKeys: metadataKeys);
            if (nestedKeyedMapped.isNotEmpty) return nestedKeyedMapped;

            final nestedScalarMapped = _coerceScalarMapToItems(nestedMap, excludedKeys: metadataKeys);
            if (nestedScalarMapped.isNotEmpty) return nestedScalarMapped;
          }
        }

        final mapValues = candidateMap.values.map(_asStringDynamicMap).whereType<Map<String, dynamic>>().where((item) {
          return item['id'] != null ||
              item['value'] != null ||
              item['code'] != null ||
              item['label'] != null ||
              item['name'] != null ||
              item['title'] != null ||
              item['name_arabic'] != null ||
              item['name_english'] != null ||
              item['text'] != null ||
              item['display_name'] != null ||
              item['label_ar'] != null ||
              item['name_ar'] != null;
        }).toList();
        if (mapValues.isNotEmpty) return mapValues;

        final fromKeyedMap = _coerceKeyedMapToItems(candidateMap, excludedKeys: metadataKeys);
        if (fromKeyedMap.isNotEmpty) return fromKeyedMap;

        final scalarMapValues = _coerceScalarMapToItems(candidateMap, excludedKeys: metadataKeys);
        if (scalarMapValues.isNotEmpty) return scalarMapValues;
      }
    }

    final directMapValues =
        categoryData.values.map(_asStringDynamicMap).whereType<Map<String, dynamic>>().where((item) {
      return item['id'] != null ||
          item['value'] != null ||
          item['code'] != null ||
          item['label'] != null ||
          item['name'] != null ||
          item['title'] != null ||
          item['name_arabic'] != null ||
          item['name_english'] != null ||
          item['text'] != null ||
          item['display_name'] != null ||
          item['label_ar'] != null ||
          item['name_ar'] != null;
    }).toList();
    if (directMapValues.isNotEmpty) return directMapValues;

    final fromDirectKeyedMap = _coerceKeyedMapToItems(categoryData, excludedKeys: metadataKeys);
    if (fromDirectKeyedMap.isNotEmpty) return fromDirectKeyedMap;

    final directScalarMapValues = _coerceScalarMapToItems(categoryData, excludedKeys: metadataKeys);
    if (directScalarMapValues.isNotEmpty) return directScalarMapValues;

    final deepItems = _extractDeepCandidateItems(categoryData);
    if (deepItems.isNotEmpty) return deepItems;

    return const [];
  }

  static List<Map<String, dynamic>> _extractDeepCandidateItems(dynamic node, {int depth = 0}) {
    if (depth > 5) {
      return const [];
    }

    if (node is List) {
      final out = <Map<String, dynamic>>[];
      for (final item in node) {
        out.addAll(_extractDeepCandidateItems(item, depth: depth + 1));
      }
      return out;
    }

    final mapNode = _asStringDynamicMap(node);
    if (mapNode == null) {
      return const [];
    }

    bool looksLikeItem(Map<String, dynamic> map) {
      final hasIdentity = map['id'] != null || map['value'] != null || map['code'] != null || map['slug'] != null;
      final hasDisplay = map['name'] != null ||
          map['label'] != null ||
          map['title'] != null ||
          map['name_ar'] != null ||
          map['label_ar'] != null ||
          map['name_arabic'] != null ||
          map['display_name'] != null ||
          map['text'] != null;
      final looksLikeWrapper = map.containsKey('items') || map.containsKey('data') || map.containsKey('values');
      return hasIdentity || (hasDisplay && !looksLikeWrapper);
    }

    if (looksLikeItem(mapNode)) {
      return [mapNode];
    }

    final out = <Map<String, dynamic>>[];
    for (final value in mapNode.values) {
      out.addAll(_extractDeepCandidateItems(value, depth: depth + 1));
    }
    return out;
  }

  static List<Map<String, dynamic>> _coerceScalarListToItems(dynamic value) {
    if (value is! List) return const [];

    final out = <Map<String, dynamic>>[];
    for (var index = 0; index < value.length; index++) {
      final item = value[index];
      if (item == null) continue;

      final mapItem = _asStringDynamicMap(item);
      if (mapItem != null) {
        out.add(mapItem);
        continue;
      }

      final text = item.toString().trim();
      if (text.isEmpty) continue;
      out.add({
        'id': (index + 1).toString(),
        'name': text,
      });
    }

    return out;
  }

  static List<Map<String, dynamic>> _coerceScalarMapToItems(
    Map<String, dynamic> map, {
    Set<String> excludedKeys = const {},
  }) {
    final out = <Map<String, dynamic>>[];

    for (final entry in map.entries) {
      final key = entry.key.trim();
      if (key.isEmpty || excludedKeys.contains(key)) {
        continue;
      }

      final value = entry.value;
      if (value == null || value is Map || value is List) {
        continue;
      }

      final label = value.toString().trim();
      if (label.isEmpty) continue;

      out.add({
        'id': key,
        'name': label,
      });
    }

    return out;
  }

  static List<Map<String, dynamic>> _coerceKeyedMapToItems(
    Map<String, dynamic> map, {
    Set<String> excludedKeys = const {},
  }) {
    final out = <Map<String, dynamic>>[];

    for (final entry in map.entries) {
      final key = entry.key.trim();
      if (key.isEmpty || excludedKeys.contains(key)) {
        continue;
      }

      final valueMap = _asStringDynamicMap(entry.value);
      if (valueMap == null) {
        continue;
      }

      final label = (valueMap['name'] ??
              valueMap['label'] ??
              valueMap['title'] ??
              valueMap['name_ar'] ??
              valueMap['label_ar'] ??
              valueMap['name_arabic'] ??
              valueMap['display_name'] ??
              valueMap['text'])
          ?.toString();

      if (label == null || label.trim().isEmpty) {
        continue;
      }

      out.add({
        'id': (valueMap['id'] ?? valueMap['value'] ?? valueMap['code'] ?? key).toString(),
        'code': (valueMap['code'] ?? valueMap['slug'] ?? valueMap['id'] ?? key).toString(),
        'name': label,
        'name_en': (valueMap['name_en'] ?? valueMap['label_en'] ?? valueMap['name_english'])?.toString(),
        'is_active': valueMap['is_active'] ?? valueMap['active'] ?? valueMap['enabled'],
        'sort_order': valueMap['sort_order'] ?? valueMap['sort'] ?? valueMap['order'],
        'created_at': valueMap['created_at'],
        'updated_at': valueMap['updated_at'],
        'deleted_at': valueMap['deleted_at'],
      });
    }

    return out;
  }

  static List<TaxonomyDTO> _extractFlatTaxonomies(Map<String, dynamic> json) {
    final output = <TaxonomyDTO>[];

    final flatCandidates = <dynamic>[
      json['data'],
      json['taxonomies'],
      json['categories'],
      json['items'],
    ];

    for (final candidate in flatCandidates) {
      if (candidate is List) {
        for (final item in _asMapList(candidate)) {
          final dto = _flatItemToDto(item);
          if (dto != null) {
            output.add(dto);
          }
        }
      }
    }

    if (output.isNotEmpty) {
      return output;
    }

    final dataNode = json['data'];
    final dataMap = _asStringDynamicMap(dataNode);
    if (dataMap != null) {
      for (final entry in dataMap.entries) {
        if (entry.value is List) {
          for (final item in _asMapList(entry.value)) {
            final dto = _flatItemToDto(item, fallbackGroupSlug: entry.key);
            if (dto != null) {
              output.add(dto);
            }
          }
          continue;
        }

        final mapNode = _asStringDynamicMap(entry.value);
        if (mapNode != null) {
          final mapValues = mapNode.values.map(_asStringDynamicMap).whereType<Map<String, dynamic>>();
          for (final item in mapValues) {
            final dto = _flatItemToDto(item, fallbackGroupSlug: entry.key);
            if (dto != null) {
              output.add(dto);
            }
          }
        }
      }
    }

    return output;
  }

  static TaxonomyDTO? _flatItemToDto(
    Map<String, dynamic> item, {
    String? fallbackGroupSlug,
  }) {
    final groupRaw = (item['group'] ??
            item['group_value'] ??
            item['group_slug'] ??
            item['category_group'] ??
            item['category_slug'] ??
            item['taxonomy_group'] ??
            item['taxonomy_type'] ??
            item['type'] ??
            item['bucket'] ??
            item['table'] ??
            fallbackGroupSlug)
        ?.toString();
    final label = (item['label'] ?? item['name'] ?? item['title'] ?? item['name_ar'] ?? item['label_ar'])?.toString();
    final id = (item['id'] ?? item['value'] ?? item['code'])?.toString();

    if ((groupRaw == null || groupRaw.isEmpty) || (label == null || label.isEmpty) || (id == null || id.isEmpty)) {
      return null;
    }

    final labelEn = (item['label_en'] ?? item['name_en'] ?? item['title_en'])?.toString();
    final resolvedGroup = _resolveGroupValue(groupRaw, label, labelEn);

    return TaxonomyDTO(
      id: id,
      groupValue: resolvedGroup,
      code: item['code']?.toString() ?? item['slug']?.toString() ?? id,
      label: label,
      labelEn: labelEn,
      parentId: item['parent_id']?.toString(),
      sortOrder: _parseInt(item['sort_order'] ?? item['sort'] ?? item['order']),
      isActive: _parseBool(item['is_active'] ?? item['active'] ?? item['enabled'], defaultValue: true),
      createdAt: _parseDateTime(item['created_at']),
      updatedAt: _parseDateTime(item['updated_at']),
      deletedAt: _parseDateTime(item['deleted_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static Map<String, dynamic>? _asStringDynamicMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = entry.value;
      }
      return result;
    }
    return null;
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];

    final out = <Map<String, dynamic>>[];
    for (final item in value) {
      final map = _asStringDynamicMap(item);
      if (map != null) {
        out.add(map);
      }
    }
    return out;
  }

  static String _resolveGroupValue(String slug, String labelAr, String? labelEn) {
    final documentedCanonical = resolveBackendDocumentedCategoryCanonicalGroup(slug);
    if (documentedCanonical != null && TaxonomyGroup.isValidGroup(documentedCanonical)) {
      return documentedCanonical;
    }

    final resolvedGroup = resolveTaxonomyGroupFromCandidates([
      slug,
      labelAr,
      labelEn,
    ]);
    if (resolvedGroup != null) {
      return resolvedGroup.value;
    }

    final normalizedFromGroup = TaxonomyGroup.normalizeValue(slug);
    if (normalizedFromGroup != null && TaxonomyGroup.isValidGroup(normalizedFromGroup)) {
      return normalizedFromGroup;
    }

    final normalizedSlug = slug.toLowerCase().replaceAll('_', '-').trim();

    // If this is a documented slug and it wasn't resolved by the explicit policy,
    // avoid heuristic remapping to prevent accidental semantic collapsing.
    if (isBackendDocumentedCategorySlug(normalizedSlug)) {
      final normalizedFromSlug = TaxonomyGroup.normalizeValue(normalizedSlug);
      return normalizedFromSlug ?? normalizedSlug;
    }

    final normalizedAr = labelAr.trim();
    final normalizedEn = (labelEn ?? '').toLowerCase().trim();

    const mapBySlug = <String, String>{
      'categories': 'category',
      'category': 'category',
      'beneficiary-categories': 'category',
      'provinces': 'governorate',
      'province': 'governorate',
      'governorates': 'governorate',
      'governorate': 'governorate',
      'relations': 'relationship',
      'genders': 'gender',
      'gender': 'gender',
      'sex': 'gender',
      'sexes': 'gender',
      'visit': 'visit_type',
      'visits': 'visit_type',
      'association': 'association_type',
      'associations': 'association_type',
      'income_source': 'income_source',
      'income_sources': 'income_source',
      'social-status': 'marital_status',
      'social-statuses': 'marital_status',
      'marital-statuses': 'marital_status',
      'marital-status': 'marital_status',
      'displacement-statuses': 'displacement_status',
      'displacement-status': 'displacement_status',
      'displacement-cases': 'displacement_status',
      'job-status': 'employment_status',
      'job-statuses': 'employment_status',
      'employment-statuses': 'employment_status',
      'employment-status': 'employment_status',
      'academic-degrees': 'education_level',
      'academic-degree': 'education_level',
      'educational-levels': 'education_level',
      'education-levels': 'education_level',
      'education-level': 'education_level',
      'health-condition': 'health_status',
      'health-conditions': 'health_status',
      'health-statuses': 'health_status',
      'health-status': 'health_status',
      'residence-types': 'housing_type',
      'housing-types': 'housing_type',
      'housing-type': 'housing_type',
      'accommodation-types': 'housing_type',
      'accommodation-type': 'housing_type',
      'residence-status': 'housing_status',
      'housing-conditions': 'housing_status',
      'housing-condition': 'housing_status',
      'housing-statuses': 'housing_status',
      'housing-status': 'housing_status',
      'special-needs-types': 'disability_type',
      'disability-types': 'disability_type',
      'disability-type': 'disability_type',
      'income': 'income_source',
      'income-sources': 'income_source',
      'income-source': 'income_source',
      'associations-types': 'association_type',
      'association-types': 'association_type',
      'association-type': 'association_type',
      'cities': 'city',
      'city': 'city',
      'sponsorship': 'sponsorship_type',
      'sponsorship-categories': 'sponsorship_type',
      'sponsorship-types': 'sponsorship_type',
      'sponsorship-type': 'sponsorship_type',
      'document-types': 'document_type',
      'document-type': 'document_type',
      'bank-names': 'bank_name',
      'bank-name': 'bank_name',
      'currencies': 'currency',
      'currency': 'currency',
      'death-reasons': 'death_reason',
      'death-reason': 'death_reason',
      'visits-types': 'visit_type',
      'visit-types': 'visit_type',
      'visit-type': 'visit_type',
      'aid-types': 'assistance_type',
      'assistance-types': 'assistance_type',
      'assistance-type': 'assistance_type',
      'aid-statuses': 'assistance_type',
      'request-statuses': 'beneficiary_status',
      'request-status': 'beneficiary_status',
      'sponsorship-statuses': 'beneficiary_status',
      'beneficiary-state': 'beneficiary_status',
      'beneficiary-condition': 'beneficiary_status',
      'beneficiary-statuses': 'beneficiary_status',
      'beneficiary-status': 'beneficiary_status',
      'kinship': 'relationship',
      'relative-relationship': 'relationship',
      'relationships': 'relationship',
      'guarantee-types': 'guarantee_type',
      'guarantee-type': 'guarantee_type',
      'department': 'section',
      'departments': 'section',
      'sections': 'section',
    };

    final mapped = mapBySlug[normalizedSlug];
    if (mapped != null) return mapped;

    if (normalizedSlug.contains('marital') || normalizedSlug.contains('social-status')) return 'marital_status';
    if (normalizedSlug.contains('displacement')) return 'displacement_status';
    if (normalizedSlug.contains('employment') || normalizedSlug.contains('job-status')) return 'employment_status';
    if (normalizedSlug.contains('education') || normalizedSlug.contains('academic-degree')) return 'education_level';
    if (normalizedSlug.contains('health')) return 'health_status';
    if (normalizedSlug.contains('housing-type') || normalizedSlug.contains('residence-type')) return 'housing_type';
    if (normalizedSlug.contains('housing-status') || normalizedSlug.contains('housing-condition')) {
      return 'housing_status';
    }
    if (normalizedSlug.contains('disability') || normalizedSlug.contains('special-needs')) return 'disability_type';
    if (normalizedSlug.contains('income')) return 'income_source';
    if (normalizedSlug.contains('association')) return 'association_type';
    if (normalizedSlug.contains('city') || normalizedSlug.contains('cities')) return 'city';
    if (normalizedSlug.contains('guarantee')) return 'guarantee_type';
    if (normalizedSlug.contains('sponsorship')) return 'sponsorship_type';
    if (normalizedSlug.contains('document')) return 'document_type';
    if (normalizedSlug.contains('bank')) return 'bank_name';
    if (normalizedSlug.contains('currency')) return 'currency';
    if (normalizedSlug.contains('death-reason') || normalizedSlug.contains('death')) return 'death_reason';
    if (normalizedSlug.contains('visit')) return 'visit_type';
    if (normalizedSlug.contains('assistance') ||
        normalizedSlug.contains('aid-type') ||
        normalizedSlug.contains('aid-status')) {
      return 'assistance_type';
    }
    if (normalizedSlug.contains('beneficiary-status') || normalizedSlug.contains('beneficiary-state')) {
      return 'beneficiary_status';
    }
    if (normalizedSlug.contains('relationship') || normalizedSlug.contains('kinship')) return 'relationship';
    if (normalizedSlug.contains('section') || normalizedSlug.contains('department')) return 'section';
    if (normalizedSlug.contains('gender') || normalizedSlug.contains('sex')) return 'gender';

    if (normalizedAr.contains('محافظ')) return 'governorate';
    if (normalizedAr.contains('فئ')) return 'category';
    if (normalizedAr.contains('الحالة الاجتماعية')) return 'marital_status';
    if (normalizedAr.contains('النزوح')) return 'displacement_status';
    if (normalizedAr.contains('التوظيف') || normalizedAr.contains('العمل')) return 'employment_status';
    if (normalizedAr.contains('المستوى التعليمي')) return 'education_level';
    if (normalizedAr.contains('الحالة الصحية')) return 'health_status';
    if (normalizedAr.contains('نوع السكن')) return 'housing_type';
    if (normalizedAr.contains('حالة السكن')) return 'housing_status';
    if (normalizedAr.contains('الإعاقة')) return 'disability_type';
    if (normalizedAr.contains('مصدر الدخل')) return 'income_source';
    if (normalizedAr.contains('نوع الجمعية')) return 'association_type';
    if (normalizedAr.contains('نوع الكفالة')) return 'sponsorship_type';
    if (normalizedAr.contains('الوثائ')) return 'document_type';
    if (normalizedAr.contains('البنك') || normalizedAr.contains('البنوك')) return 'bank_name';
    if (normalizedAr.contains('العملات') || normalizedAr.contains('عملة')) return 'currency';
    if (normalizedAr.contains('الوفاة')) return 'death_reason';
    if (normalizedAr.contains('نوع الزيارة')) return 'visit_type';
    if (normalizedAr.contains('نوع المساعدة')) return 'assistance_type';
    if (normalizedAr.contains('حالة المستفيد') || normalizedAr.contains('حالة الطلب')) return 'beneficiary_status';
    if (normalizedAr.contains('صلة القرابة')) return 'relationship';
    if (normalizedAr.contains('القسم')) return 'section';
    if (normalizedAr.contains('الجنس')) return 'gender';

    if (normalizedEn.contains('governorate') || normalizedEn.contains('province')) return 'governorate';
    if (normalizedEn.contains('category')) return 'category';
    if (normalizedEn.contains('marital')) return 'marital_status';
    if (normalizedEn.contains('displacement')) return 'displacement_status';
    if (normalizedEn.contains('employment') || normalizedEn.contains('job')) return 'employment_status';
    if (normalizedEn.contains('education')) return 'education_level';
    if (normalizedEn.contains('health')) return 'health_status';
    if (normalizedEn.contains('housing type')) return 'housing_type';
    if (normalizedEn.contains('housing status')) return 'housing_status';
    if (normalizedEn.contains('disability')) return 'disability_type';
    if (normalizedEn.contains('income source')) return 'income_source';
    if (normalizedEn.contains('association type')) return 'association_type';
    if (normalizedEn.contains('sponsorship type')) return 'sponsorship_type';
    if (normalizedEn.contains('document type')) return 'document_type';
    if (normalizedEn.contains('bank')) return 'bank_name';
    if (normalizedEn.contains('currency')) return 'currency';
    if (normalizedEn.contains('death reason') || normalizedEn.contains('death')) return 'death_reason';
    if (normalizedEn.contains('visit type')) return 'visit_type';
    if (normalizedEn.contains('assistance type')) return 'assistance_type';
    if (normalizedEn.contains('beneficiary status') || normalizedEn.contains('request status')) {
      return 'beneficiary_status';
    }
    if (normalizedEn.contains('relationship')) return 'relationship';
    if (normalizedEn.contains('section')) return 'section';
    if (normalizedEn.contains('gender')) return 'gender';

    return TaxonomyGroup.normalizeValue(normalizedSlug) ?? normalizedSlug.replaceAll('-', '_');
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

/// رد تصنيف واحد
class TaxonomyResponseDTO {
  final bool success;
  final TaxonomyDTO data;
  final String? message;

  const TaxonomyResponseDTO({
    required this.success,
    required this.data,
    this.message,
  });

  factory TaxonomyResponseDTO.fromJson(Map<String, dynamic> json) {
    final dataNode = json['data'];
    Map<String, dynamic>? itemNode;

    if (dataNode is Map<String, dynamic>) {
      if (dataNode['item'] is Map<String, dynamic>) {
        itemNode = Map<String, dynamic>.from(dataNode['item'] as Map);

        final categoryNode = dataNode['category'];
        if (categoryNode is Map<String, dynamic> && categoryNode['slug'] != null && itemNode['group'] == null) {
          itemNode['group'] = categoryNode['slug']?.toString();
        }

        if (itemNode['label'] == null && itemNode['name'] != null) {
          itemNode['label'] = itemNode['name'];
        }
        if (itemNode['label_en'] == null && itemNode['name_en'] != null) {
          itemNode['label_en'] = itemNode['name_en'];
        }
      } else {
        itemNode = Map<String, dynamic>.from(dataNode);
      }
    }

    itemNode ??= json['item'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['item'] as Map) : null;

    return TaxonomyResponseDTO(
      success: json['success'] == true,
      data: TaxonomyDTO.fromJson(itemNode ?? const <String, dynamic>{}),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      if (message != null) 'message': message,
    };
  }
}

/// رد المجموعات
class TaxonomyGroupsResponseDTO {
  final bool success;
  final List<TaxonomyGroupInfoDTO> data;
  final String? message;

  const TaxonomyGroupsResponseDTO({
    required this.success,
    required this.data,
    this.message,
  });

  factory TaxonomyGroupsResponseDTO.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final listNode = switch (rawData) {
      Map<String, dynamic>() => rawData['categories'],
      _ => rawData,
    };

    final groups = <TaxonomyGroupInfoDTO>[];

    if (listNode is List) {
      groups.addAll(
        listNode.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).map(TaxonomyGroupInfoDTO.fromJson),
      );
    } else if (listNode is Map) {
      final mapNode = Map<String, dynamic>.from(listNode);
      for (final entry in mapNode.entries) {
        final value = entry.value;
        if (value is Map) {
          final item = Map<String, dynamic>.from(value);
          item.putIfAbsent('slug', () => entry.key);
          item.putIfAbsent('name', () => entry.key);
          groups.add(TaxonomyGroupInfoDTO.fromJson(item));
          continue;
        }

        groups.add(
          TaxonomyGroupInfoDTO.fromJson({
            'slug': entry.key,
            'name': entry.key,
          }),
        );
      }
    }

    return TaxonomyGroupsResponseDTO(
      success: json['success'] == true,
      data: groups,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      if (message != null) 'message': message,
    };
  }
}

/// معلومات المجموعة
class TaxonomyGroupInfoDTO {
  final String name;
  final String arabicName;
  final String? englishName;
  final String? endpoint;
  final int count;
  final bool isEditable;

  const TaxonomyGroupInfoDTO({
    required this.name,
    required this.arabicName,
    this.englishName,
    this.endpoint,
    this.count = 0,
    this.isEditable = true,
  });

  factory TaxonomyGroupInfoDTO.fromJson(Map<String, dynamic> json) {
    final rawName =
        (json['name'] ?? json['slug'] ?? json['group'] ?? json['group_slug'] ?? json['category'] ?? json['key'])
            ?.toString();

    final rawArabic = (json['arabic_name'] ??
            json['label_ar'] ??
            json['name_ar'] ??
            json['title_ar'] ??
            json['label'] ??
            json['name'])
        ?.toString();

    final countValue = json['count'];
    final parsedCount = countValue is int ? countValue : int.tryParse(countValue?.toString() ?? '') ?? 0;

    return TaxonomyGroupInfoDTO(
      name: (rawName ?? '').trim(),
      arabicName: (rawArabic ?? '').trim(),
      englishName: (json['label_en'] ?? json['name_en'] ?? json['title_en'])?.toString(),
      endpoint: (json['endpoint'] ?? json['url'] ?? json['path'])?.toString(),
      count: parsedCount,
      isEditable: json['is_editable'] != false,
    );
  }

  String get slug => name;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'arabic_name': arabicName,
      if (englishName != null) 'label_en': englishName,
      if (endpoint != null) 'endpoint': endpoint,
      'count': count,
      'is_editable': isEditable,
    };
  }
}

/// بيانات الميتا
class TaxonomyMetaDTO {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final DateTime? lastSync;

  const TaxonomyMetaDTO({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.lastSync,
  });

  factory TaxonomyMetaDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyMetaDTO(
      currentPage: json['current_page'] as int?,
      lastPage: json['last_page'] as int?,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      lastSync: json['last_sync'] != null ? DateTime.tryParse(json['last_sync'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (currentPage != null) 'current_page': currentPage,
      if (lastPage != null) 'last_page': lastPage,
      if (perPage != null) 'per_page': perPage,
      if (total != null) 'total': total,
      if (lastSync != null) 'last_sync': lastSync!.toIso8601String(),
    };
  }
}

/// رد المزامنة
class TaxonomySyncResponseDTO {
  final bool success;
  final int added;
  final int updated;
  final int deleted;
  final String? message;
  final DateTime? syncTime;
  final List<TaxonomyDTO>? taxonomies;

  const TaxonomySyncResponseDTO({
    required this.success,
    this.added = 0,
    this.updated = 0,
    this.deleted = 0,
    this.message,
    this.syncTime,
    this.taxonomies,
  });

  factory TaxonomySyncResponseDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomySyncResponseDTO(
      success: json['success'] == true,
      added: (json['added'] as int?) ?? 0,
      updated: (json['updated'] as int?) ?? 0,
      deleted: (json['deleted'] as int?) ?? 0,
      message: json['message']?.toString(),
      syncTime: json['sync_time'] != null ? DateTime.tryParse(json['sync_time'].toString()) : null,
      taxonomies:
          (json['taxonomies'] as List<dynamic>?)?.map((e) => TaxonomyDTO.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'added': added,
      'updated': updated,
      'deleted': deleted,
      if (message != null) 'message': message,
      if (syncTime != null) 'sync_time': syncTime!.toIso8601String(),
      if (taxonomies != null) 'taxonomies': taxonomies!.map((e) => e.toJson()).toList(),
    };
  }

  /// تحويل إلى نتيجة المزامنة
  TaxonomySyncResult toSyncResult() {
    return TaxonomySyncResult(
      addedCount: added,
      updatedCount: updated,
      deletedCount: deleted,
      syncTime: syncTime ?? DateTime.now(),
      success: success,
      message: message,
    );
  }
}

/// طلب إنشاء/تحديث تصنيف
class TaxonomyRequestDTO {
  final String? id;
  final String group;
  final String code;
  final String label;
  final String? labelEn;
  final String? parentId;
  final int? sortOrder;
  final bool? isActive;
  final String? description;
  final String? color;
  final String? icon;
  final Map<String, dynamic>? metadata;

  const TaxonomyRequestDTO({
    required this.group,
    required this.code,
    required this.label,
    this.id,
    this.labelEn,
    this.parentId,
    this.sortOrder,
    this.isActive,
    this.description,
    this.color,
    this.icon,
    this.metadata,
  });

  factory TaxonomyRequestDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomyRequestDTO(
      id: json['id']?.toString(),
      group: json['group']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString(),
      parentId: json['parent_id']?.toString(),
      sortOrder: json['sort_order'] as int?,
      isActive: json['is_active'] as bool?,
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'group': group,
      'code': code,
      'label': label,
      if (labelEn != null) 'label_en': labelEn,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// إنشاء من Entity
  static TaxonomyRequestDTO fromEntity(Taxonomy entity) {
    return TaxonomyRequestDTO(
      id: entity.id,
      group: entity.group.value,
      code: entity.code,
      label: entity.label,
      labelEn: entity.labelEn,
      parentId: entity.parentId,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      metadata: entity.metadata,
    );
  }
}

/// طلب المزامنة
class TaxonomySyncRequestDTO {
  final DateTime? lastSync;
  final String? group;
  final bool includeDeleted;

  const TaxonomySyncRequestDTO({
    this.lastSync,
    this.group,
    this.includeDeleted = true,
  });

  factory TaxonomySyncRequestDTO.fromJson(Map<String, dynamic> json) {
    return TaxonomySyncRequestDTO(
      lastSync: json['last_sync'] != null ? DateTime.tryParse(json['last_sync'].toString()) : null,
      group: json['group']?.toString(),
      includeDeleted: json['include_deleted'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lastSync != null) 'last_sync': lastSync!.toIso8601String(),
      if (group != null) 'group': group,
      'include_deleted': includeDeleted,
    };
  }
}
