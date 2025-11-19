import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/services/password_hash_service.dart';

void main() {
  group('PasswordHashService Tests', () {
    test('hashPassword should return consistent hash for same input', () {
      // Arrange
      const password = 'test_password_123';

      // Act
      final hash1 = PasswordHashService.hashPassword(password);
      final hash2 = PasswordHashService.hashPassword(password);

      // Assert
      expect(hash1, equals(hash2));
      expect(hash1, isNotEmpty);
    });

    test(
      'hashPassword should return different hashes for different inputs',
      () {
        // Arrange
        const password1 = 'password123';
        const password2 = 'different_password';

        // Act
        final hash1 = PasswordHashService.hashPassword(password1);
        final hash2 = PasswordHashService.hashPassword(password2);

        // Assert
        expect(hash1, isNot(equals(hash2)));
      },
    );

    test('verifyPassword should return true for correct password', () {
      // Arrange
      const password = 'my_secure_password';
      final hash = PasswordHashService.hashPassword(password);

      // Act
      final result = PasswordHashService.verifyPassword(password, hash);

      // Assert
      expect(result, isTrue);
    });

    test('verifyPassword should return false for incorrect password', () {
      // Arrange
      const correctPassword = 'correct_password';
      const wrongPassword = 'wrong_password';
      final hash = PasswordHashService.hashPassword(correctPassword);

      // Act
      final result = PasswordHashService.verifyPassword(wrongPassword, hash);

      // Assert
      expect(result, isFalse);
    });

    test('hashPassword should handle empty strings', () {
      // Arrange
      const emptyPassword = '';

      // Act
      final hash = PasswordHashService.hashPassword(emptyPassword);

      // Assert
      expect(hash, isNotEmpty);
      expect(PasswordHashService.verifyPassword(emptyPassword, hash), isTrue);
    });

    test('hashPassword should handle Arabic text', () {
      // Arrange
      const arabicPassword = 'كلمة_المرور_العربية';

      // Act
      final hash = PasswordHashService.hashPassword(arabicPassword);

      // Assert
      expect(hash, isNotEmpty);
      expect(PasswordHashService.verifyPassword(arabicPassword, hash), isTrue);
    });

    test('hashPassword should handle special characters', () {
      // Arrange
      const specialPassword = '!@#\$%^&*()_+-={}[]|:;<>?,./~`';

      // Act
      final hash = PasswordHashService.hashPassword(specialPassword);

      // Assert
      expect(hash, isNotEmpty);
      expect(PasswordHashService.verifyPassword(specialPassword, hash), isTrue);
    });

    test('hashPassword should produce SHA-256 length hash (64 hex chars)', () {
      // Arrange
      const password = 'test';

      // Act
      final hash = PasswordHashService.hashPassword(password);

      // Assert
      // SHA-256 produces 64 hex characters
      expect(hash.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
    });

    test(
      'generateSalt should return different values on multiple calls',
      () async {
        // Act
        final salt1 = PasswordHashService.generateSalt();
        await Future.delayed(const Duration(milliseconds: 2)); // تأخير بسيط
        final salt2 = PasswordHashService.generateSalt();

        // Assert
        expect(salt1, isNot(equals(salt2)));
        expect(salt1, isNotEmpty);
        expect(salt2, isNotEmpty);
      },
    );

    test('Case sensitivity test', () {
      // Arrange
      const lowerCase = 'password';
      const upperCase = 'PASSWORD';

      // Act
      final hashLower = PasswordHashService.hashPassword(lowerCase);
      final hashUpper = PasswordHashService.hashPassword(upperCase);

      // Assert
      expect(hashLower, isNot(equals(hashUpper)));
      expect(PasswordHashService.verifyPassword(lowerCase, hashUpper), isFalse);
    });

    test('Whitespace handling test', () {
      // Arrange
      const passwordWithSpace = 'password ';
      const passwordWithoutSpace = 'password';

      // Act
      final hash1 = PasswordHashService.hashPassword(passwordWithSpace);
      final hash2 = PasswordHashService.hashPassword(passwordWithoutSpace);

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });

    test('Long password handling', () {
      // Arrange
      final longPassword = 'a' * 1000; // 1000 characters

      // Act
      final hash = PasswordHashService.hashPassword(longPassword);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64)); // Still 64 chars for SHA-256
      expect(PasswordHashService.verifyPassword(longPassword, hash), isTrue);
    });

    test('Unicode emoji handling', () {
      // Arrange
      const emojiPassword = '🔒🔑🛡️';

      // Act
      final hash = PasswordHashService.hashPassword(emojiPassword);

      // Assert
      expect(hash, isNotEmpty);
      expect(PasswordHashService.verifyPassword(emojiPassword, hash), isTrue);
    });
  });
}
