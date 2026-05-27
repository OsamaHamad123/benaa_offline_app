import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';

class FirestoreTaxonomyPermissionDeniedException implements Exception {
  final String collectionName;

  const FirestoreTaxonomyPermissionDeniedException(this.collectionName);

  @override
  String toString() {
    return 'Firestore taxonomy permission denied. Check Firestore rules for taxonomy_categories and confirm the app is connected to the correct Firebase project.';
  }
}

class FirestoreTaxonomyService {
  FirestoreTaxonomyService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String taxonomyCategoriesCollection = 'taxonomy_categories';

  static const String _collection = taxonomyCategoriesCollection;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _taxonomies => _firestore.collection(_collection);

  String get collectionName => _collection;

  Future<List<Taxonomy>> fetchByGroup(TaxonomyGroup group) async {
    try {
      final candidates = _groupQueryCandidates(group);
      final itemsById = <String, Taxonomy>{};

      for (final candidate in candidates) {
        final query = await _taxonomies.where('group', isEqualTo: candidate).where('isActive', isEqualTo: true).get();
        for (final doc in query.docs) {
          final taxonomy = _fromDocument(doc);
          itemsById[taxonomy.id] = taxonomy;
        }
      }

      final items = itemsById.values.toList(growable: false);
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    } catch (e) {
      throw _mapException(e);
    }
  }

  Stream<List<Taxonomy>> watchByGroup(TaxonomyGroup group) {
    try {
      final candidates = _groupQueryCandidates(group);
      final query = candidates.length == 1
          ? _taxonomies.where('group', isEqualTo: candidates.first).where('isActive', isEqualTo: true)
          : _taxonomies.where('group', whereIn: candidates).where('isActive', isEqualTo: true);

      return query.snapshots().map((snapshot) {
        final items = snapshot.docs.map((doc) => _fromDocument(doc)).toList(growable: false);
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }).handleError((error) {
        throw _mapException(error);
      });
    } catch (e) {
      return Stream<List<Taxonomy>>.error(_mapException(e));
    }
  }

  Future<List<Taxonomy>> fetchChildren(String parentId) async {
    final normalizedParentId = parentId.trim();
    if (normalizedParentId.isEmpty) {
      return const <Taxonomy>[];
    }

    try {
      final query =
          await _taxonomies.where('parentId', isEqualTo: normalizedParentId).where('isActive', isEqualTo: true).get();

      final items = query.docs.map((doc) => _fromDocument(doc)).toList(growable: false);
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    } catch (e) {
      throw _mapException(e);
    }
  }

  Stream<List<Taxonomy>> watchChildren(String parentId) {
    final normalizedParentId = parentId.trim();
    if (normalizedParentId.isEmpty) {
      return Stream<List<Taxonomy>>.value(<Taxonomy>[]);
    }

    try {
      return _taxonomies
          .where('parentId', isEqualTo: normalizedParentId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) => _fromDocument(doc)).toList(growable: false);
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }).handleError((error) {
        throw _mapException(error);
      });
    } catch (e) {
      return Stream<List<Taxonomy>>.error(_mapException(e));
    }
  }

  Future<List<Taxonomy>> fetchByJourneyType(String journeyType) async {
    final normalizedJourneyType = journeyType.trim();
    if (normalizedJourneyType.isEmpty) {
      return const <Taxonomy>[];
    }

    try {
      final query = await _taxonomies
          .where('journeyType', isEqualTo: normalizedJourneyType)
          .where('isActive', isEqualTo: true)
          .get();

      final items = query.docs.map((doc) => _fromDocument(doc)).toList(growable: false);
      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
    } catch (e) {
      throw _mapException(e);
    }
  }

  Stream<List<Taxonomy>> watchByJourneyType(String journeyType) {
    final normalizedJourneyType = journeyType.trim();
    if (normalizedJourneyType.isEmpty) {
      return Stream<List<Taxonomy>>.value(<Taxonomy>[]);
    }

    try {
      return _taxonomies
          .where('journeyType', isEqualTo: normalizedJourneyType)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) => _fromDocument(doc)).toList(growable: false);
        items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return items;
      }).handleError((error) {
        throw _mapException(error);
      });
    } catch (e) {
      return Stream<List<Taxonomy>>.error(_mapException(e));
    }
  }

  Future<int> seedGroupIfEmpty(
    TaxonomyGroup group,
    List<Taxonomy> taxonomies, {
    bool overwrite = false,
  }) async {
    if (taxonomies.isEmpty) {
      return 0;
    }

    try {
      final existing = await _taxonomies.where('group', isEqualTo: group.value).limit(1).get();
      if (existing.docs.isNotEmpty && !overwrite) {
        return 0;
      }

      final batch = _firestore.batch();
      var count = 0;
      for (final taxonomy in taxonomies) {
        final docRef = _taxonomies.doc(_buildDocId(group, taxonomy.id, taxonomy.code));
        batch.set(docRef, _toFirestoreMap(taxonomy), SetOptions(merge: true));
        count += 1;
      }

      await batch.commit();
      return count;
    } catch (e) {
      throw _mapException(e);
    }
  }

  String _buildDocId(TaxonomyGroup group, String id, String code) {
    final raw = id.trim().isNotEmpty ? id.trim() : code.trim();
    final safe = raw.replaceAll('/', '_');
    return '${group.value}__$safe';
  }

  Taxonomy _fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final group = TaxonomyGroup.fromString(data['group']?.toString()) ?? TaxonomyGroup.category;

    final slug = (data['slug'] ?? '').toString().trim();
    final code = (data['code'] ?? slug).toString();

    final idFromDoc = (data['id'] ?? '').toString();
    final fallbackId = doc.id.contains('__') ? doc.id.split('__').last : doc.id;

    final createdAt = _asDateTime(data['createdAt'] ?? data['created_at']) ?? DateTime.now();
    final updatedAt = _asDateTime(data['updatedAt'] ?? data['updated_at']) ?? createdAt;

    final label = (data['nameAr'] ?? data['name'] ?? data['label'] ?? '').toString();

    return Taxonomy(
      id: idFromDoc.isNotEmpty ? idFromDoc : fallbackId,
      group: group,
      code: code.isNotEmpty ? code : (idFromDoc.isNotEmpty ? idFromDoc : fallbackId),
      label: label,
      labelEn: (data['nameEn'] ?? data['label_en'])?.toString(),
      parentId: (data['parentId'] ?? data['parent_id'])?.toString(),
      sortOrder: _asInt(data['sortOrder'] ?? data['sort_order']),
      isActive: _asBool(data['isActive'] ?? data['is_active'], defaultValue: true),
      description: data['description']?.toString(),
      color: data['color']?.toString(),
      icon: (data['iconUrl'] ?? data['icon'])?.toString(),
      metadata: data['metadata'] is Map<String, dynamic> ? data['metadata'] as Map<String, dynamic> : const {},
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: _asDateTime(data['deletedAt'] ?? data['deleted_at']),
    );
  }

  Map<String, dynamic> _toFirestoreMap(Taxonomy taxonomy) {
    final slug = taxonomy.code.trim().isNotEmpty ? taxonomy.code.trim() : taxonomy.id.trim();

    return <String, dynamic>{
      'id': taxonomy.id,
      'group': taxonomy.group.value,
      'code': slug,
      'name': taxonomy.label,
      'nameAr': taxonomy.label,
      if (taxonomy.labelEn != null) 'nameEn': taxonomy.labelEn,
      if (slug.isNotEmpty) 'slug': slug,
      'parentId': taxonomy.parentId,
      'sortOrder': taxonomy.sortOrder,
      'isActive': taxonomy.isActive,
      if (taxonomy.description != null) 'description': taxonomy.description,
      if (taxonomy.icon != null) 'iconUrl': taxonomy.icon,
      'imageUrl': null,
      'journeyType': (taxonomy.metadata ?? const <String, dynamic>{})['journeyType'] ?? 'general',
      'metadata': taxonomy.metadata ?? const <String, dynamic>{},
      'createdAt': Timestamp.fromDate(taxonomy.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      if (taxonomy.deletedAt != null) 'deletedAt': Timestamp.fromDate(taxonomy.deletedAt!),
    };
  }

  List<String> _groupQueryCandidates(TaxonomyGroup group) {
    switch (group) {
      case TaxonomyGroup.governorate:
        return const ['governorate', 'governorates', 'province', 'provinces'];
      case TaxonomyGroup.category:
        return const ['category', 'categories'];
      default:
        return [group.value];
    }
  }

  Exception _mapException(Object error) {
    if (error is FirestoreTaxonomyPermissionDeniedException) {
      return error;
    }

    if (error is FirebaseException && error.code == 'permission-denied') {
      return FirestoreTaxonomyPermissionDeniedException(_collection);
    }

    if (error is Exception) {
      return error;
    }

    return Exception(error.toString());
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _asBool(dynamic value, {required bool defaultValue}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return defaultValue;
  }
}
