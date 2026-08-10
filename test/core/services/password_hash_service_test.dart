import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/core/services/password_hash_service.dart';

void main() {
  group('PasswordHashService Tests', () {
    test('hashPassword should use a random salt (different hash each call)', () {
      // Arrange
      const password = 'test_password_123';

      // Act
      final hash1 = PasswordHashService.hashPassword(password);
      final hash2 = PasswordHashService.hashPassword(password);

      // Assert - salt عشوائي لكل تجزئة، لكن كلاهما يتحقق بنجاح
      expect(hash1, isNot(equals(hash2)));
      expect(PasswordHashService.verifyPassword(password, hash1), isTrue);
      expect(PasswordHashService.verifyPassword(password, hash2), isTrue);
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

    test('verifyPassword should return false for malformed hash', () {
      expect(PasswordHashService.verifyPassword('password', ''), isFalse);
      expect(PasswordHashService.verifyPassword('password', 'not-a-hash'), isFalse);
      expect(
        PasswordHashService.verifyPassword('password', 'pbkdf2\$abc\$def\$ghi'),
        isFalse,
      );
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

    test('hashPassword should produce a well-formed PBKDF2 hash', () {
      // Arrange
      const password = 'test';

      // Act
      final hash = PasswordHashService.hashPassword(password);

      // Assert - format: pbkdf2$<iterations>$<base64 salt>$<base64 key>
      final parts = hash.split(r'$');
      expect(parts.length, equals(4));
      expect(parts[0], equals('pbkdf2'));
      expect(int.parse(parts[1]), greaterThanOrEqualTo(10000));
    });

    test(
      'generateSalt should return different values on multiple calls',
      () {
        // Act
        final salt1 = PasswordHashService.generateSalt();
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
      final hashUpper = PasswordHashService.hashPassword(upperCase);

      // Assert
      expect(PasswordHashService.verifyPassword(lowerCase, hashUpper), isFalse);
      expect(PasswordHashService.verifyPassword(upperCase, hashUpper), isTrue);
    });

    test('Whitespace handling test', () {
      // Arrange
      const passwordWithSpace = 'password ';
      const passwordWithoutSpace = 'password';

      // Act
      final hash = PasswordHashService.hashPassword(passwordWithSpace);

      // Assert
      expect(
        PasswordHashService.verifyPassword(passwordWithoutSpace, hash),
        isFalse,
      );
      expect(
        PasswordHashService.verifyPassword(passwordWithSpace, hash),
        isTrue,
      );
    });

    test('Long password handling', () {
      // Arrange
      final longPassword = 'a' * 1000; // 1000 characters

      // Act
      final hash = PasswordHashService.hashPassword(longPassword);

      // Assert
      expect(hash, isNotEmpty);
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
