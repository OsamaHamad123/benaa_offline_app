import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/associations/domain/entities/association.dart';
import 'package:benaa_offline_app/features/associations/domain/entities/representative.dart';

void main() {
  group('Association Entity Tests', () {
    final now = DateTime.now();

    test('should create Association with all required fields', () {
      // Arrange
      final association = Association(
        id: 'test-id-123',
        name: 'جمعية الخير',
        phone: '07901234567',
        bankName: 'بنك بغداد',
        accountNumber: '123456789',
        representativeId: 'rep-id-001',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(association.id, 'test-id-123');
      expect(association.name, 'جمعية الخير');
      expect(association.phone, '07901234567');
      expect(association.bankName, 'بنك بغداد');
      expect(association.accountNumber, '123456789');
      expect(association.representativeId, 'rep-id-001');
      expect(association.isActive, true);
    });

    test('should create Association with optional fields', () {
      // Arrange
      final association = Association(
        id: 'test-id-456',
        name: 'جمعية الرحمة',
        shortName: 'الرحمة',
        phone: '07709876543',
        email: 'info@charity.org',
        bankName: 'بنك الرشيد',
        accountNumber: '987654321',
        swiftCode: 'SWIFT123',
        bankPhone: '07801234567',
        accountCurrency: 'USD',
        representativeId: 'rep-id-002',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(association.shortName, 'الرحمة');
      expect(association.email, 'info@charity.org');
      expect(association.swiftCode, 'SWIFT123');
      expect(association.bankPhone, '07801234567');
      expect(association.accountCurrency, 'USD');
    });

    test('displayName should return shortName if available', () {
      // Arrange
      final associationWithShortName = Association(
        id: 'test-id-1',
        name: 'جمعية الخير للأعمال الخيرية',
        shortName: 'الخير',
        phone: '0790123456',
        bankName: 'Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final associationWithoutShortName = Association(
        id: 'test-id-2',
        name: 'جمعية الرحمة',
        phone: '0790123456',
        bankName: 'Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(associationWithShortName.displayName, 'الخير');
      expect(associationWithoutShortName.displayName, 'جمعية الرحمة');
    });

    test('isValid should return true when all required fields are present', () {
      // Arrange
      final validAssociation = Association(
        id: 'test-id',
        name: 'Test Association',
        phone: '0790123456',
        bankName: 'Test Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(validAssociation.isValid, true);
    });

    test('isValid should return false when required fields are empty', () {
      // Arrange
      final invalidAssociation1 = Association(
        id: 'test-id',
        name: '',
        phone: '0790123456',
        bankName: 'Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(invalidAssociation1.isValid, false);
    });

    test('Equatable should work correctly for equality comparison', () {
      // Arrange
      final association1 = Association(
        id: 'test-id',
        name: 'Test',
        phone: '0790123456',
        bankName: 'Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final association2 = Association(
        id: 'test-id',
        name: 'Test',
        phone: '0790123456',
        bankName: 'Bank',
        accountNumber: '12345',
        representativeId: 'rep-id',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(association1, equals(association2));
    });
  });

  group('Representative Entity Tests', () {
    final now = DateTime.now();

    test('should create Representative with required fields', () {
      // Arrange
      final representative = Representative(
        id: 'rep-id-001',
        name: 'أحمد محمد',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(representative.id, 'rep-id-001');
      expect(representative.name, 'أحمد محمد');
    });

    test('isValid should return true when name is not empty', () {
      // Arrange
      final validRepresentative = Representative(
        id: 'rep-id',
        name: 'Test Representative',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(validRepresentative.isValid, true);
    });

    test('isValid should return false when name is empty', () {
      // Arrange
      final invalidRepresentative = Representative(
        id: 'rep-id',
        name: '',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(invalidRepresentative.isValid, false);
    });
  });
}
