/// 🔐 Password Validator
///
/// التحقق من قوة كلمة المرور

class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 128;

  /// التحقق من قوة كلمة المرور
  static PasswordStrength checkStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        score: 0,
        level: PasswordLevel.veryWeak,
        feedback: ['كلمة المرور فارغة'],
      );
    }

    int score = 0;
    final List<String> feedback = [];

    // الطول
    if (password.length >= minLength) {
      score += 1;
    } else {
      feedback.add('كلمة المرور قصيرة جداً (الحد الأدنى $minLength أحرف)');
    }

    if (password.length >= 12) {
      score += 1;
    }

    // الأحرف الكبيرة
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    } else {
      feedback.add('أضف حرفاً كبيراً (A-Z)');
    }

    // الأحرف الصغيرة
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    } else {
      feedback.add('أضف حرفاً صغيراً (a-z)');
    }

    // الأرقام
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    } else {
      feedback.add('أضف رقماً (0-9)');
    }

    // الرموز الخاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    } else {
      feedback.add('أضف رمزاً خاصاً (!@#\$%^&*)');
    }

    // التنوع
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= password.length * 0.6) {
      score += 1;
    }

    // الأنماط الشائعة
    if (_hasCommonPatterns(password)) {
      score -= 2;
      feedback.add('تجنب الأنماط الشائعة (123, abc, qwerty)');
    }

    // الكلمات الشائعة
    if (_isCommonPassword(password)) {
      score = 0;
      feedback.add('كلمة المرور شائعة جداً، استخدم كلمة أكثر تعقيداً');
    }

    score = score.clamp(0, 5);

    final level = _getPasswordLevel(score);

    return PasswordStrength(
      score: score,
      level: level,
      feedback: feedback.isEmpty ? ['كلمة مرور قوية!'] : feedback,
    );
  }

  /// التحقق من الأنماط الشائعة
  static bool _hasCommonPatterns(String password) {
    final patterns = [
      RegExp(r'(012|123|234|345|456|567|678|789)'),
      RegExp(r'(abc|bcd|cde|def|efg|fgh|ghi)'),
      RegExp(r'(qwer|wert|erty|asdf|sdfg|zxcv)'),
      RegExp(r'(\d)\1{2,}'), // تكرار نفس الرقم
      RegExp(r'([a-zA-Z])\1{2,}'), // تكرار نفس الحرف
    ];

    return patterns.any((pattern) => password.contains(pattern));
  }

  /// التحقق من كلمات المرور الشائعة
  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      '12345678',
      'password',
      '123456789',
      '12345',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      'letmein',
      'welcome',
      '1234567890',
      'admin123',
    ];

    return commonPasswords
        .any((common) => password.toLowerCase() == common.toLowerCase());
  }

  /// تحديد مستوى قوة كلمة المرور
  static PasswordLevel _getPasswordLevel(int score) {
    if (score <= 1) return PasswordLevel.veryWeak;
    if (score == 2) return PasswordLevel.weak;
    if (score == 3) return PasswordLevel.medium;
    if (score == 4) return PasswordLevel.strong;
    return PasswordLevel.veryStrong;
  }

  /// التحقق من صحة كلمة المرور
  static bool isValid(String password) {
    final strength = checkStrength(password);
    return strength.level.index >= PasswordLevel.medium.index;
  }

  /// توليد كلمة مرور قوية
  static String generateStrongPassword({int length = 16}) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    final all = uppercase + lowercase + numbers + symbols;
    final random = DateTime.now().millisecondsSinceEpoch;

    String password = '';

    // ضمان وجود حرف من كل نوع
    password += uppercase[random % uppercase.length];
    password += lowercase[random % lowercase.length];
    password += numbers[random % numbers.length];
    password += symbols[random % symbols.length];

    // إكمال باقي الطول
    for (int i = password.length; i < length; i++) {
      password += all[(random * i) % all.length];
    }

    // خلط الأحرف
    final chars = password.split('');
    chars.shuffle();
    return chars.join();
  }
}

/// قوة كلمة المرور
class PasswordStrength {
  final int score;
  final PasswordLevel level;
  final List<String> feedback;

  PasswordStrength({
    required this.score,
    required this.level,
    required this.feedback,
  });

  double get percentage => (score / 5) * 100;

  @override
  String toString() {
    return 'PasswordStrength(level: ${level.name}, score: $score/5, feedback: $feedback)';
  }
}

/// مستويات قوة كلمة المرور
enum PasswordLevel {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong;

  String get label {
    switch (this) {
      case PasswordLevel.veryWeak:
        return 'ضعيفة جداً';
      case PasswordLevel.weak:
        return 'ضعيفة';
      case PasswordLevel.medium:
        return 'متوسطة';
      case PasswordLevel.strong:
        return 'قوية';
      case PasswordLevel.veryStrong:
        return 'قوية جداً';
    }
  }
}
