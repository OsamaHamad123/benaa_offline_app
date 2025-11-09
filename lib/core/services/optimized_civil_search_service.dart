import '../utils/arabic_normalizer.dart';
import '../../data/db/drift_database.dart';
import '../../data/models/civil_record.dart';

/// نتيجة بحث مع درجة التطابق
class SearchResult {
  final CivilRecord record;
  final double matchScore; // 0.0 - 1.0
  final String matchReason; // لماذا ظهرت هذه النتيجة

  SearchResult({
    required this.record,
    required this.matchScore,
    required this.matchReason,
  });
}

/// خدمة البحث المحسّنة في السجل المدني
/// ✨ Features:
/// - Database Indexing للبحث السريع
/// - Fuzzy Matching للأخطاء الإملائية
/// - Arabic Normalization لتوحيد الأحرف العربية
/// - Ranked Results حسب درجة التطابق
class OptimizedCivilSearchService {
  // Database instance
  static AppDatabase? _db;

  // Cache
  static List<CivilRecord>? _cachedRecords;
  static Map<String, CivilRecord>? _nationalIdIndex;
  static Map<String, List<CivilRecord>>? _nameIndex;
  static Map<String, List<CivilRecord>>? _governorateIndex;

  /// تحميل وفهرسة جميع السجلات من قاعدة البيانات
  static Future<void> initialize([AppDatabase? database]) async {
    if (_cachedRecords != null) return;

    try {
      // استخدام database instance الموجودة أو إنشاء واحدة جديدة
      _db = database ?? AppDatabase(openEncryptedDb());

      // قراءة جميع السجلات من قاعدة البيانات
      final driftRecords = await _db!.select(_db!.civilRegistry).get();

      // تحويل إلى CivilRecord models
      _cachedRecords = driftRecords
          .map((r) => CivilRecord.fromDrift(r))
          .toList();

      // بناء الفهارس
      _buildIndexes();
    } catch (e) {
      throw Exception('فشل تحميل السجل المدني: $e');
    }
  }

  /// بناء الفهارس للبحث السريع
  static void _buildIndexes() {
    if (_cachedRecords == null) return;

    // فهرس الرقم الوطني - O(1) lookup
    _nationalIdIndex = {};
    for (final record in _cachedRecords!) {
      _nationalIdIndex![record.nationalId] = record;
    }

    // فهرس الأسماء - للبحث السريع مع Normalization
    _nameIndex = {};
    for (final record in _cachedRecords!) {
      // فهرسة كل كلمة في الاسم بعد التطبيع
      final words = ArabicNormalizer.extractWords(record.fullName);
      for (final word in words) {
        final normalizedWord = ArabicNormalizer.normalize(word);
        _nameIndex![normalizedWord] = (_nameIndex![normalizedWord] ?? [])
          ..add(record);
      }

      // إضافة الاسم الكامل أيضاً
      final fullNameNorm = ArabicNormalizer.normalize(record.fullName);
      _nameIndex![fullNameNorm] = (_nameIndex![fullNameNorm] ?? [])
        ..add(record);
    }

    // فهرس المحافظات
    _governorateIndex = {};
    for (final record in _cachedRecords!) {
      final gov = record.governorate;
      if (gov != null && gov.isNotEmpty) {
        _governorateIndex![gov] = (_governorateIndex![gov] ?? [])..add(record);
      }
    }
  }

  /// البحث الذكي - يدعم جميع أنواع البحث
  static Future<List<SearchResult>> smartSearch(
    String query, {
    String? governorate,
    String? gender,
    int limit = 50,
  }) async {
    await initialize();

    if (query.trim().isEmpty) return [];

    final normalizedQuery = ArabicNormalizer.normalize(query);
    final results = <SearchResult>[];

    // 1. بحث دقيق بالرقم الوطني - أعلى أولوية
    if (_nationalIdIndex!.containsKey(query.trim())) {
      results.add(
        SearchResult(
          record: _nationalIdIndex![query.trim()]!,
          matchScore: 1.0,
          matchReason: 'تطابق كامل - الرقم الوطني',
        ),
      );
      return results; // إرجاع فوري
    }

    // 2. بحث بالاسم الكامل
    final exactNameMatches = _cachedRecords!.where((r) {
      return r.fullNameNormalized == normalizedQuery;
    }).toList();

    for (final record in exactNameMatches) {
      results.add(
        SearchResult(
          record: record,
          matchScore: 1.0,
          matchReason: 'تطابق كامل - الاسم',
        ),
      );
    }

    // 3. بحث جزئي - استخدام الفهرس
    final words = ArabicNormalizer.extractWords(query);
    final candidates = <CivilRecord>{};

    for (final word in words) {
      final normalizedWord = ArabicNormalizer.normalize(word);
      if (_nameIndex!.containsKey(normalizedWord)) {
        candidates.addAll(_nameIndex![normalizedWord]!);
      }
    }

    // 4. Fuzzy Matching للأخطاء الإملائية
    for (final record in candidates) {
      if (results.any((r) => r.record.nationalId == record.nationalId)) {
        continue; // تخطي المكررات
      }

      final similarity = ArabicNormalizer.similarity(record.fullName, query);

      if (similarity >= 0.6) {
        // 60% تشابه على الأقل
        results.add(
          SearchResult(
            record: record,
            matchScore: similarity,
            matchReason: similarity >= 0.9
                ? 'تطابق قوي'
                : similarity >= 0.75
                ? 'تطابق جيد'
                : 'تطابق جزئي',
          ),
        );
      }
    }

    // 5. بحث في باقي الحقول (اسم الأب، الأم، المحافظة)
    if (results.length < limit) {
      for (final record in _cachedRecords!) {
        if (results.any((r) => r.record.nationalId == record.nationalId)) {
          continue;
        }

        if (ArabicNormalizer.contains(record.fatherName, query)) {
          results.add(
            SearchResult(
              record: record,
              matchScore: 0.7,
              matchReason: 'تطابق في اسم الأب',
            ),
          );
        } else if (record.motherName != null &&
            ArabicNormalizer.contains(record.motherName!, query)) {
          results.add(
            SearchResult(
              record: record,
              matchScore: 0.7,
              matchReason: 'تطابق في اسم الأم',
            ),
          );
        }
      }
    }

    // فلترة حسب المحافظة والجنس
    var filtered = results;
    if (governorate != null && governorate.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.record.governorate == governorate;
      }).toList();
    }
    if (gender != null && gender.isNotEmpty) {
      filtered = filtered.where((r) {
        // gender هو 'male' أو 'female'
        // sexCode هو 1 = ذكر, 2 = أنثى
        if (gender == 'male') {
          return r.record.sexCode == 1;
        } else if (gender == 'female') {
          return r.record.sexCode == 2;
        }
        return true;
      }).toList();
    }

    // ترتيب حسب درجة التطابق
    filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    // الحد الأقصى للنتائج
    return filtered.take(limit).toList();
  }

  /// البحث بالرقم الوطني - O(1)
  static Future<CivilRecord?> searchByNationalId(String nationalId) async {
    await initialize();
    return _nationalIdIndex![nationalId.trim()];
  }

  /// البحث بالمحافظة
  static Future<List<CivilRecord>> searchByGovernorate(
    String governorate,
  ) async {
    await initialize();
    return _governorateIndex![governorate] ?? [];
  }

  /// إحصائيات السجل المدني
  static Future<Map<String, dynamic>> getStatistics() async {
    await initialize();

    final stats = <String, dynamic>{
      'totalRecords': _cachedRecords!.length,
      'males': _cachedRecords!.where((r) => r.gender == 'male').length,
      'females': _cachedRecords!.where((r) => r.gender == 'female').length,
      'governorates': _governorateIndex!.keys.toList(),
    };

    return stats;
  }

  /// مسح الـ cache
  static void clearCache() {
    _cachedRecords = null;
    _nationalIdIndex = null;
    _nameIndex = null;
    _governorateIndex = null;
  }

  /// الحصول على جميع السجلات (للاختبار فقط)
  static Future<List<CivilRecord>> getAllRecords() async {
    await initialize();
    return _cachedRecords ?? [];
  }
}
