/// 📝 Text Normalization Service - Enhanced Arabic text processing
///
/// Single Responsibility: Normalize Arabic text for search with phonetic support
library;

/// Phonetic matching level for Arabic text
enum PhoneticLevel {
  none, // No phonetic normalization
  light, // Only obvious variations (ض↔ظ، ذ↔ز)
  moderate, // + (ث↔س، ط↔ت)
  aggressive, // All variations including (ح↔ه، ق↔ك)
}

/// Hamza normalization mode
enum HamzaMode {
  keep, // Keep all hamza variants
  remove, // Remove all hamzas
  smart, // Smart normalization based on context
}

class TextNormalizationService {
  // 🔧 Configuration - can be changed at runtime
  static PhoneticLevel phoneticLevel = PhoneticLevel.moderate;
  static bool normalizeNumbers = true;
  static HamzaMode hamzaMode = HamzaMode.smart;

  // 📚 Common Arabic typos dictionary
  static final Map<String, String> commonTypos = {
    'محمممد': 'محمد',
    'احممد': 'أحمد',
    'فاطمهه': 'فاطمة',
    'عليىى': 'علي',
    'حسنن': 'حسن',
    'ساره': 'سارة',
    'نوور': 'نور',
    'عمرر': 'عمر',
  };

  // 🔤 Compound name prefixes
  static final Set<String> compoundPrefixes = {
    'عبد',
    'أبو',
    'أبي',
    'أم',
    'بن',
    'بنت',
  };

  /// Normalize Arabic text for searching - ENHANCED VERSION
  ///
  /// Features:
  /// - Removes diacritics (tashkeel)
  /// - Normalizes alef variants
  /// - Handles hamza intelligently
  /// - Phonetic matching for similar sounds
  /// - Arabic/English number normalization
  /// - Typo correction
  static String normalize(
    String? text, {
    bool keepHamza = false, // Deprecated: use hamzaMode instead
    bool applyPhonetic = true,
    bool correctTypos = true,
  }) {
    if (text == null) return '';
    var s = text.trim();
    if (s.isEmpty) return '';

    // 1️⃣ Fix common typos first
    if (correctTypos) {
      s = _correctCommonTypos(s);
    }

    // 2️⃣ Normalize numbers (Arabic → English)
    if (normalizeNumbers) {
      s = _normalizeNumbers(s);
    }

    // 3️⃣ Convert to lowercase
    s = s.toLowerCase();

    // 4️⃣ Remove Arabic diacritics (tashkeel) and Quranic marks
    s = _removeDiacritics(s);

    // 5️⃣ Remove tatweel (ـ)
    s = s.replaceAll('ـ', '');

    // 6️⃣ Normalize alef variants: أ إ آ ٱ → ا
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 7️⃣ Normalize ya and ta
    s = s.replaceAll('ى', 'ي'); // Alef maksura → ya
    s = s.replaceAll('ة', 'ه'); // Ta marbuta → ha

    // 8️⃣ Normalize hamza
    s = _normalizeHamza(s, keepHamza ? HamzaMode.keep : hamzaMode);

    // 9️⃣ Apply phonetic normalization
    if (applyPhonetic && phoneticLevel != PhoneticLevel.none) {
      s = _applyPhoneticNormalization(s, phoneticLevel);
    }

    // 🔟 Handle compound names intelligently
    s = _normalizeCompoundNames(s);

    // 1️⃣1️⃣ Remove non-Arabic letters but keep spaces and numbers
    s = s.replaceAll(RegExp(r'[^\u0600-\u06FF\s0-9]'), ' ');

    // 1️⃣2️⃣ Collapse multiple spaces and trim
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  /// Remove diacritics (tashkeel)
  static String _removeDiacritics(String text) {
    return text.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
  }

  /// Normalize Arabic numbers to English
  static String _normalizeNumbers(String text) {
    const arabicNums = '٠١٢٣٤٥٦٧٨٩';
    const englishNums = '0123456789';

    for (var i = 0; i < arabicNums.length; i++) {
      text = text.replaceAll(arabicNums[i], englishNums[i]);
    }

    return text;
  }

  /// Normalize hamza variants intelligently - Enhanced for word-ending hamza
  static String _normalizeHamza(String text, HamzaMode mode) {
    switch (mode) {
      case HamzaMode.keep:
        // Keep distinct hamza forms
        text = text.replaceAll('ؤ', 'ء');
        text = text.replaceAll('ئ', 'ء');
        return text;

      case HamzaMode.remove:
        // Remove all hamzas completely
        text = text.replaceAll(RegExp(r'[ءؤئ]'), '');
        return text;

      case HamzaMode.smart:
        // ⚡ ENHANCED: Better handling for names ending with hamza (ولاء، دعاء، سناء)

        // Convert hamza variants to normalized form FIRST
        text = text.replaceAll('ؤ', 'وء');
        text = text.replaceAll('ئ', 'يء');

        // For search matching: Create variations to match both with/without hamza
        // This is handled in search query builder
        // Here we KEEP word-ending hamza but normalize word-beginning hamza

        // Remove standalone hamza ONLY at word start and after spaces
        text = text.replaceAll(RegExp(r'^ء'), ''); // Remove at start
        text = text.replaceAll(RegExp(r'\sء'), ' '); // Remove after space

        // Keep hamza at word end (crucial for ولاء، دعاء، etc.)
        // Already preserved by not removing it

        return text;
    }
  }

  /// Apply phonetic normalization for Arabic - Enhanced
  static String _applyPhoneticNormalization(String text, PhoneticLevel level) {
    if (level == PhoneticLevel.none) return text;

    // ⚡ Light level: Only obvious sound-alikes
    if (level.index >= PhoneticLevel.light.index) {
      text = text.replaceAll('ظ', 'ض'); // Emphatic D
      text = text.replaceAll('ذ', 'ز'); // Z-sound
    }

    // ⚡ Moderate level: Common confusions
    if (level.index >= PhoneticLevel.moderate.index) {
      text = text.replaceAll('ث', 'س'); // S-sound
      text = text.replaceAll('ط', 'ت'); // T-sound
    }

    // ⚡ Aggressive level: Maximum normalization
    if (level.index >= PhoneticLevel.aggressive.index) {
      // Commented: Can cause false matches
      // text = text.replaceAll('ح', 'ه'); // H-sound
      // text = text.replaceAll('ق', 'ك'); // K-sound (dialect specific)
    }

    return text;
  }

  /// Fix common Arabic typos
  static String _correctCommonTypos(String text) {
    var corrected = text.toLowerCase();

    // Check each typo and replace
    for (final entry in commonTypos.entries) {
      corrected = corrected.replaceAll(entry.key, entry.value);
    }

    // Handle repeated characters (محمممد → محمد)
    corrected = _removeRepeatedCharacters(corrected);

    return corrected;
  }

  /// Remove repeated characters (more than 2 consecutive)
  static String _removeRepeatedCharacters(String text) {
    // Replace 3+ repeated chars with 1 char
    return text.replaceAllMapped(
      RegExp(r'(.)\1{2,}'),
      (match) => match.group(1)!,
    );
  }

  /// Normalize compound names (عبد الرحمن ↔ عبدالرحمن) - Enhanced
  static String _normalizeCompoundNames(String text) {
    var result = text;

    // ⚡ IMPROVED: Better compound name handling
    // This function normalizes compound names to help search
    // The search query builder will create variations for matching

    for (final prefix in compoundPrefixes) {
      // Handle "ال" after prefix: "عبد ال" → "عبدال"
      result = result.replaceAll(RegExp('$prefix\\s+ال'), '$prefixال');

      // Keep space after compound prefix for word splitting
      // Search will handle both "عبد الله" and "عبدالله" variations
    }

    return result;
  }

  /// Generate compound name variations for search (NEW)
  /// "عبد الرحمن" → ["عبد الرحمن", "عبدالرحمن", "عبد", "الرحمن", "رحمن"]
  static List<String> generateCompoundVariations(String name) {
    final variations = <String>{name}; // Use Set to avoid duplicates

    // Check each compound prefix
    for (final prefix in compoundPrefixes) {
      if (name.startsWith('$prefix ')) {
        // "عبد الرحمن" → "عبدالرحمن"
        variations.add(name.replaceAll(' ', ''));

        // "عبد الرحمن" → "عبد" + "الرحمن"
        final parts = name.split(' ');
        variations.addAll(parts);

        // "عبد الرحمن" → "رحمن" (without ال)
        if (parts.length > 1 && parts[1].startsWith('ال')) {
          variations.add(parts[1].substring(2));
        }
      }
    }

    return variations.toList();
  }

  /// Calculate Levenshtein distance between two strings
  /// Used for fuzzy search (typo tolerance)
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;

    // Create matrix
    final matrix = List.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    // Initialize first row and column
    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Fill matrix
    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
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

  /// Check if two strings are similar (fuzzy match)
  /// Returns true if distance is within threshold
  static bool isSimilar(String s1, String s2, {int maxDistance = 2}) {
    final distance = levenshteinDistance(normalize(s1), normalize(s2));
    return distance <= maxDistance;
  }

  /// Get similarity score (0.0 to 1.0)
  /// 1.0 = identical, 0.0 = completely different
  static double getSimilarityScore(String s1, String s2) {
    final normalized1 = normalize(s1);
    final normalized2 = normalize(s2);

    if (normalized1 == normalized2) return 1.0;

    final maxLen = normalized1.length > normalized2.length
        ? normalized1.length
        : normalized2.length;

    if (maxLen == 0) return 1.0;

    final distance = levenshteinDistance(normalized1, normalized2);
    return 1.0 - (distance / maxLen);
  }

  /// Generate hamza variations for search (NEW)
  /// "ولاء" → ["ولاء", "ولا", "ولاا"]
  /// "دعاء" → ["دعاء", "دعا", "دعاا"]
  static List<String> generateHamzaVariations(String word) {
    final variations = <String>{word}; // Use Set to avoid duplicates

    // Check if word ends with hamza
    if (word.endsWith('ء')) {
      // Add variation without hamza: "ولاء" → "ولا"
      variations.add(word.substring(0, word.length - 1));

      // Add variation with alef: "ولاء" → "ولاا"
      variations.add(word.substring(0, word.length - 1) + 'ا');
    }

    // Check if word ends with alef + hamza-like chars
    if (word.endsWith('اء')) {
      // Already have both versions
      variations.add(word.substring(0, word.length - 1)); // Remove hamza
    }

    // Check for hamza on waw/ya at end: "نبوء" → "نبوء", "نبو"
    if (word.endsWith('وء') || word.endsWith('يء')) {
      variations.add(word.substring(0, word.length - 1)); // Remove hamza
    }

    return variations.toList();
  }

  /// Generate all search variations (compound + hamza) (NEW)
  /// Combines compound name variations with hamza variations
  static List<String> generateAllSearchVariations(String name) {
    final allVariations = <String>{};

    // Start with compound variations
    final compoundVars = generateCompoundVariations(name);

    // For each compound variation, generate hamza variations
    for (final compoundVar in compoundVars) {
      final hamzaVars = generateHamzaVariations(compoundVar);
      allVariations.addAll(hamzaVars);
    }

    return allVariations.toList();
  }

  /// Build normalized full name from database row
  static String buildNormalizedName(Map<String, Object?> row) {
    final parts = <String>[];
    final fields = [
      row['CI_FIRST_ARB'] as String?,
      row['CI_FATHER_ARB'] as String?,
      row['CI_GRAND_FATHER_ARB'] as String?,
      row['CI_FAMILY_ARB'] as String?,
    ];

    for (final value in fields) {
      if (value != null && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    if (parts.isEmpty) {
      return '';
    }

    return normalize(parts.join(' '), keepHamza: false);
  }

  /// Build FTS match query from normalized text
  ///
  /// Converts "محمد احمد" to "name_norm:محمد* name_norm:احمد*"
  static String? buildFtsMatchQuery(String normalized) {
    final tokens =
        normalized.split(' ').where((token) => token.isNotEmpty).toList();

    if (tokens.isEmpty) {
      return null;
    }

    return tokens.map((token) => 'name_norm:$token*').join(' ');
  }
}
