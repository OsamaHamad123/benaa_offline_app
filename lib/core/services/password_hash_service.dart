import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Password Hashing Service
/// استخدام SHA-256 مع salt لتشفير كلمات المرور
class PasswordHashService {
  /// Salt ثابت للتطبيق (يمكن جعله dynamic في الإصدارات المستقبلية)
  static const String _salt = 'benaa_offline_app_2024_secure_salt';

  /// Hash password with SHA-256 and salt
  static String hashPassword(String password) {
    final saltedPassword = _salt + password;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String storedHash) {
    final hashedInput = hashPassword(password);
    return hashedInput == storedHash;
  }

  /// Generate a random salt (for future enhancements)
  /// ملاحظة: حالياً نستخدم salt ثابت للبساطة
  /// في الإصدارات المستقبلية يمكن استخدام salt مختلف لكل مستخدم
  static String generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return hashPassword(random);
  }
}
