/// 🔤 Arabic Text Normalizer
/// معالج تطبيع النصوص العربية لتحسين نتائج البحث
///
/// يعالج:
/// - الهمزات (أ، إ، آ → ا)
/// - التاء المربوطة (ة → ه)
/// - الألف المقصورة (ى → ي)
/// - التشكيل والحركات
/// - المسافات الزائدة

class ArabicNormalizer {
  /// تطبيع النص العربي للبحث الأمثل
  static String normalize(String text) {
    try {
      if (text.isEmpty) return '';

      String normalized = text;

      // تحويل إلى lowercase
      normalized = normalized.toLowerCase();

      // إزالة التشكيل
      normalized = _removeDiacritics(normalized);

      // توحيد الهمزات
      normalized = _normalizeHamza(normalized);

      // توحيد الألفات
      normalized = _normalizeAlef(normalized);

      // توحيد التاء
      normalized = _normalizeTa(normalized);

      // توحيد الياء
      normalized = _normalizeYa(normalized);

      // إزالة المسافات الزائدة
      normalized = normalized.trim().replaceAll(RegExp(r'\s+'), ' ');

      return normalized;
    } catch (e) {
      print('⚠️ خطأ في تطبيع النص: $e');
      return text.trim();
    }
  }

  /// إزالة التشكيل والحركات
  static String _removeDiacritics(String text) {
    const diacritics = [
      '\u064B', // فتحتان
      '\u064C', // ضمتان
      '\u064D', // كسرتان
      '\u064E', // فتحة
      '\u064F', // ضمة
      '\u0650', // كسرة
      '\u0651', // شدة
      '\u0652', // سكون
      '\u0653', // مدة
      '\u0654', // همزة فوق
      '\u0655', // همزة تحت
      '\u0656', // ألف صغيرة
      '\u0657', // فتحة معكوسة
      '\u0658', // علامة نون غنة
      '\u0670', // ألف صغيرة مستديرة
    ];

    String result = text;
    for (final diacritic in diacritics) {
      result = result.replaceAll(diacritic, '');
    }
    return result;
  }

  /// توحيد جميع أشكال الهمزة إلى ألف عادي
  static String _normalizeHamza(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ء', 'ا');
  }

  /// توحيد جميع أشكال الألف
  static String _normalizeAlef(String text) {
    return text.replaceAll(RegExp(r'[أإآ]'), 'ا');
  }

  /// توحيد التاء المربوطة والهاء
  static String _normalizeTa(String text) {
    return text.replaceAll('ة', 'ه');
  }

  /// توحيد الألف المقصورة والياء
  static String _normalizeYa(String text) {
    return text.replaceAll('ى', 'ي');
  }

  /// مقارنة نصين بعد التطبيع
  static bool areEqual(String text1, String text2) {
    return normalize(text1) == normalize(text2);
  }

  /// فحص إذا كان النص الأول يحتوي على الثاني (بعد التطبيع)
  static bool contains(String text, String search) {
    return normalize(text).contains(normalize(search));
  }

  /// حساب نسبة التشابه بين نصين (0.0 - 1.0)
  /// استخدام Levenshtein Distance للـ Fuzzy Matching
  static double similarity(String text1, String text2) {
    final norm1 = normalize(text1);
    final norm2 = normalize(text2);

    if (norm1 == norm2) return 1.0;
    if (norm1.isEmpty || norm2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(norm1, norm2);
    final maxLen = norm1.length > norm2.length ? norm1.length : norm2.length;

    return 1.0 - (distance / maxLen);
  }

  /// حساب Levenshtein Distance للـ Fuzzy Matching
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Matrix للـ dynamic programming
    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    // Initialize first row and column
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Fill matrix
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// استخراج الكلمات من النص (بعد التطبيع)
  static List<String> extractWords(String text) {
    final normalized = normalize(text);
    return normalized.split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// إنشاء جميع الاحتمالات للبحث (للـ autocomplete)
  static List<String> generateSearchVariants(String text) {
    final words = extractWords(text);
    final variants = <String>[];

    // الكلمة كاملة
    variants.add(normalize(text));

    // كل كلمة لوحدها
    variants.addAll(words);

    // أول كلمتين
    if (words.length >= 2) {
      variants.add('${words[0]} ${words[1]}');
    }

    // آخر كلمتين
    if (words.length >= 2) {
      variants.add('${words[words.length - 2]} ${words[words.length - 1]}');
    }

    return variants.toSet().toList(); // إزالة التكرار
  }
}
