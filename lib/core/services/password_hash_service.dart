import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Password Hashing Service
/// PBKDF2-HMAC-SHA256 مع salt عشوائي لكل كلمة مرور ومقارنة بزمن ثابت
class PasswordHashService {
  static const int _iterations = 10000;
  static const int _saltLength = 16;
  static const int _keyLength = 32;

  /// Hash password with PBKDF2 and a random per-password salt.
  /// Output format: pbkdf2$<iterations>$<base64 salt>$<base64 key>
  static String hashPassword(String password) {
    final salt = _generateSaltBytes();
    final key = _pbkdf2(password, salt, _iterations, _keyLength);
    return 'pbkdf2\$$_iterations\$${base64Encode(salt)}\$${base64Encode(key)}';
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String storedHash) {
    final parts = storedHash.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2') return false;

    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return false;

    final Uint8List salt;
    final Uint8List expected;
    try {
      salt = base64Decode(parts[2]);
      expected = base64Decode(parts[3]);
    } on FormatException {
      return false;
    }

    final actual = _pbkdf2(password, salt, iterations, expected.length);
    return _constantTimeEquals(actual, expected);
  }

  /// Generate a random salt (base64 encoded)
  static String generateSalt() {
    return base64Encode(_generateSaltBytes());
  }

  static Uint8List _generateSaltBytes() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_saltLength, (_) => random.nextInt(256)),
    );
  }

  static Uint8List _pbkdf2(
    String password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final blockCount = (keyLength / 32).ceil();
    final output = <int>[];

    for (var block = 1; block <= blockCount; block++) {
      final blockBytes = ByteData(4)..setUint32(0, block);
      var u = hmac.convert([...salt, ...blockBytes.buffer.asUint8List()]).bytes;
      final t = List<int>.from(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      output.addAll(t);
    }

    return Uint8List.fromList(output.sublist(0, keyLength));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
