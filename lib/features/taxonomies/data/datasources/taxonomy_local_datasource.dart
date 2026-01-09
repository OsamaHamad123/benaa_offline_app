import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../models/taxonomy_dto.dart';

/// 💾 Taxonomy Local Data Source
///
/// مصدر البيانات المحلي للتصنيفات (قاعدة البيانات المحلية)
abstract class TaxonomyLocalDataSource {
  /// جلب جميع التصنيفات
  Future<List<Taxonomy>> getAllTaxonomies();

  /// جلب التصنيفات حسب المجموعة
  Future<List<Taxonomy>> getTaxonomiesByGroup(TaxonomyGroup group);

  /// جلب تصنيف بالـ ID
  Future<Taxonomy?> getTaxonomyById(String id);

  /// جلب تصنيف بالكود
  Future<Taxonomy?> getTaxonomyByCode(TaxonomyGroup group, String code);

  /// البحث في التصنيفات
  Future<List<Taxonomy>> searchTaxonomies(String query);

  /// جلب الأبناء
  Future<List<Taxonomy>> getChildTaxonomies(String parentId);

  /// حفظ/تحديث تصنيف
  Future<void> saveTaxonomy(Taxonomy taxonomy);

  /// حفظ/تحديث قائمة تصنيفات
  Future<void> saveTaxonomies(List<Taxonomy> taxonomies);

  /// حذف تصنيف (soft delete)
  Future<void> deleteTaxonomy(String id);

  /// حذف نهائي
  Future<void> permanentlyDeleteTaxonomy(String id);

  /// استعادة تصنيف
  Future<void> restoreTaxonomy(String id);

  /// مسح جميع التصنيفات
  Future<void> clearAll();

  /// مسح تصنيفات مجموعة
  Future<void> clearGroup(TaxonomyGroup group);

  /// جلب آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime();

  /// تحديث وقت المزامنة
  Future<void> updateLastSyncTime(DateTime time);

  /// جلب الإحصائيات
  Future<TaxonomyStatistics> getStatistics();

  /// التحقق من وجود تصنيف
  Future<bool> exists(String id);

  /// التحقق من تكرار الكود
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId});
}

/// 🔌 Implementation using SharedPreferences (Simple Storage)
///
/// ملاحظة: يمكن استبدالها بـ Drift للمشاريع الأكبر
class TaxonomyLocalDataSourceImpl implements TaxonomyLocalDataSource {
  final SharedPreferences _prefs;

  static const String _taxonomiesKey = 'taxonomies_data';
  static const String _lastSyncKey = 'taxonomies_last_sync';

  TaxonomyLocalDataSourceImpl(this._prefs);

  // Cache for performance
  List<Taxonomy>? _cachedTaxonomies;

  @override
  Future<List<Taxonomy>> getAllTaxonomies() async {
    return _getCachedTaxonomies();
  }

  @override
  Future<List<Taxonomy>> getTaxonomiesByGroup(TaxonomyGroup group) async {
    final all = await _getCachedTaxonomies();
    return all.where((t) => t.group == group && !t.isDeleted && t.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<Taxonomy?> getTaxonomyById(String id) async {
    final all = await _getCachedTaxonomies();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Taxonomy?> getTaxonomyByCode(TaxonomyGroup group, String code) async {
    final all = await _getCachedTaxonomies();
    try {
      return all.firstWhere(
        (t) => t.group == group && t.code == code && !t.isDeleted,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Taxonomy>> searchTaxonomies(String query) async {
    final all = await _getCachedTaxonomies();
    final lowerQuery = query.toLowerCase();
    return all
        .where((t) =>
            !t.isDeleted &&
            (t.label.toLowerCase().contains(lowerQuery) ||
                t.code.toLowerCase().contains(lowerQuery) ||
                (t.labelEn?.toLowerCase().contains(lowerQuery) ?? false)))
        .toList();
  }

  @override
  Future<List<Taxonomy>> getChildTaxonomies(String parentId) async {
    final all = await _getCachedTaxonomies();
    return all.where((t) => t.parentId == parentId && !t.isDeleted).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<void> saveTaxonomy(Taxonomy taxonomy) async {
    final all = await _getCachedTaxonomies();
    final index = all.indexWhere((t) => t.id == taxonomy.id);

    if (index >= 0) {
      all[index] = taxonomy;
    } else {
      all.add(taxonomy);
    }

    await _saveTaxonomies(all);
  }

  @override
  Future<void> saveTaxonomies(List<Taxonomy> taxonomies) async {
    final all = await _getCachedTaxonomies();
    final allMap = {for (var t in all) t.id: t};

    for (final taxonomy in taxonomies) {
      allMap[taxonomy.id] = taxonomy;
    }

    await _saveTaxonomies(allMap.values.toList());
  }

  @override
  Future<void> deleteTaxonomy(String id) async {
    final all = await _getCachedTaxonomies();
    final index = all.indexWhere((t) => t.id == id);

    if (index >= 0) {
      all[index] = all[index].copyWith(
        deletedAt: DateTime.now(),
      );
      await _saveTaxonomies(all);
    }
  }

  @override
  Future<void> permanentlyDeleteTaxonomy(String id) async {
    final all = await _getCachedTaxonomies();
    all.removeWhere((t) => t.id == id);
    await _saveTaxonomies(all);
  }

  @override
  Future<void> restoreTaxonomy(String id) async {
    final all = await _getCachedTaxonomies();
    final index = all.indexWhere((t) => t.id == id);

    if (index >= 0) {
      all[index] = all[index].copyWith(
        deletedAt: null,
      );
      await _saveTaxonomies(all);
    }
  }

  @override
  Future<void> clearAll() async {
    _cachedTaxonomies = [];
    await _prefs.remove(_taxonomiesKey);
  }

  @override
  Future<void> clearGroup(TaxonomyGroup group) async {
    final all = await _getCachedTaxonomies();
    all.removeWhere((t) => t.group == group);
    await _saveTaxonomies(all);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final timeStr = _prefs.getString(_lastSyncKey);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  @override
  Future<void> updateLastSyncTime(DateTime time) async {
    await _prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  @override
  Future<TaxonomyStatistics> getStatistics() async {
    final all = await _getCachedTaxonomies();
    final active = all.where((t) => t.isActive && !t.isDeleted).toList();
    final inactive = all.where((t) => !t.isActive && !t.isDeleted).toList();

    final countByGroup = <TaxonomyGroup, int>{};
    for (final group in TaxonomyGroup.values) {
      countByGroup[group] = active.where((t) => t.group == group).length;
    }

    return TaxonomyStatistics(
      totalCount: all.where((t) => !t.isDeleted).length,
      activeCount: active.length,
      inactiveCount: inactive.length,
      countByGroup: countByGroup,
      lastSyncTime: await getLastSyncTime(),
    );
  }

  @override
  Future<bool> exists(String id) async {
    final all = await _getCachedTaxonomies();
    return all.any((t) => t.id == id);
  }

  @override
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId}) async {
    final all = await _getCachedTaxonomies();
    return !all
        .any((t) => t.group == group && t.code == code && !t.isDeleted && (excludeId == null || t.id != excludeId));
  }

  // Private helpers

  Future<List<Taxonomy>> _getCachedTaxonomies() async {
    if (_cachedTaxonomies != null) return _cachedTaxonomies!;

    final jsonStr = _prefs.getString(_taxonomiesKey);
    if (jsonStr == null) {
      _cachedTaxonomies = [];
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      _cachedTaxonomies = jsonList.map((j) => TaxonomyDTO.fromJson(j as Map<String, dynamic>).toEntity()).toList();
      return _cachedTaxonomies!;
    } catch (e) {
      _cachedTaxonomies = [];
      return [];
    }
  }

  Future<void> _saveTaxonomies(List<Taxonomy> taxonomies) async {
    _cachedTaxonomies = taxonomies;
    final dtos = taxonomies.map((t) => TaxonomyDTO.fromEntity(t)).toList();
    final jsonStr = json.encode(dtos.map((d) => d.toJson()).toList());
    await _prefs.setString(_taxonomiesKey, jsonStr);
  }
}
