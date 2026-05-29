import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/beneficiary_display_field_filter.dart';

void main() {
  group('BeneficiaryDisplayFieldFilter', () {
    // -------------------------------------------------------------------------
    // shouldDisplayBeneficiaryField
    // -------------------------------------------------------------------------
    group('shouldDisplayBeneficiaryField', () {
      test('hides "metadata" key', () {
        expect(shouldDisplayBeneficiaryField('metadata'), isFalse);
      });

      test('hides "raw" key', () {
        expect(shouldDisplayBeneficiaryField('raw'), isFalse);
      });

      test('hides "json" key', () {
        expect(shouldDisplayBeneficiaryField('json'), isFalse);
      });

      test('hides "payload" key', () {
        expect(shouldDisplayBeneficiaryField('payload'), isFalse);
      });

      test('hides "data" key', () {
        expect(shouldDisplayBeneficiaryField('data'), isFalse);
      });

      test('hides "data.json" key', () {
        expect(shouldDisplayBeneficiaryField('data.json'), isFalse);
      });

      test('hides "syncStatus" key (case-insensitive)', () {
        expect(shouldDisplayBeneficiaryField('syncStatus'), isFalse);
        expect(shouldDisplayBeneficiaryField('SyncStatus'), isFalse);
        expect(shouldDisplayBeneficiaryField('SYNCSTATUS'), isFalse);
      });

      test('hides underscore-prefixed keys', () {
        expect(shouldDisplayBeneficiaryField('_id'), isFalse);
        expect(shouldDisplayBeneficiaryField('_internal'), isFalse);
        expect(shouldDisplayBeneficiaryField('_rev'), isFalse);
      });

      test('hides "firestoreId" key', () {
        expect(shouldDisplayBeneficiaryField('firestoreId'), isFalse);
        expect(shouldDisplayBeneficiaryField('firestoreid'), isFalse);
      });

      test('hides "deviceId" key', () {
        expect(shouldDisplayBeneficiaryField('deviceId'), isFalse);
      });

      test('shows normal beneficiary field "fullName"', () {
        expect(shouldDisplayBeneficiaryField('fullName'), isTrue);
      });

      test('shows "nationalId"', () {
        expect(shouldDisplayBeneficiaryField('nationalId'), isTrue);
      });

      test('shows "phone"', () {
        expect(shouldDisplayBeneficiaryField('phone'), isTrue);
      });

      test('shows "notes"', () {
        expect(shouldDisplayBeneficiaryField('notes'), isTrue);
      });

      test('shows "needs"', () {
        expect(shouldDisplayBeneficiaryField('needs'), isTrue);
      });

      test('shows "createdAt" (user-visible timestamp)', () {
        expect(shouldDisplayBeneficiaryField('createdAt'), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // beneficiaryFieldLabel
    // -------------------------------------------------------------------------
    group('beneficiaryFieldLabel', () {
      test('maps "fullName" → "الاسم الكامل"', () {
        expect(beneficiaryFieldLabel('fullName'), equals('الاسم الكامل'));
      });

      test('maps "nationalId" → "رقم الهوية"', () {
        expect(beneficiaryFieldLabel('nationalId'), equals('رقم الهوية'));
      });

      test('maps "phone" → "رقم الجوال"', () {
        expect(beneficiaryFieldLabel('phone'), equals('رقم الجوال'));
      });

      test('maps "address" → "العنوان"', () {
        expect(beneficiaryFieldLabel('address'), equals('العنوان'));
      });

      test('maps "governorate" → "المحافظة"', () {
        expect(beneficiaryFieldLabel('governorate'), equals('المحافظة'));
      });

      test('maps "createdAt" → "تاريخ الإضافة"', () {
        expect(beneficiaryFieldLabel('createdAt'), equals('تاريخ الإضافة'));
      });

      test('maps "updatedAt" → "آخر تحديث"', () {
        expect(beneficiaryFieldLabel('updatedAt'), equals('آخر تحديث'));
      });

      test('returns original key when no mapping exists', () {
        expect(beneficiaryFieldLabel('unknownField'), equals('unknownField'));
      });

      test('is case-insensitive for lookup', () {
        expect(beneficiaryFieldLabel('FULLNAME'), equals('الاسم الكامل'));
        expect(beneficiaryFieldLabel('FullName'), equals('الاسم الكامل'));
      });
    });

    // -------------------------------------------------------------------------
    // normalizeBeneficiaryFieldValue
    // -------------------------------------------------------------------------
    group('normalizeBeneficiaryFieldValue', () {
      test('returns null for null value', () {
        expect(normalizeBeneficiaryFieldValue('notes', null), isNull);
      });

      test('returns null for empty string', () {
        expect(normalizeBeneficiaryFieldValue('notes', ''), isNull);
      });

      test('returns null for Map (raw nested object)', () {
        expect(normalizeBeneficiaryFieldValue('metadata', {'key': 'value'}), isNull);
      });

      test('returns null for value that looks like raw JSON object', () {
        expect(normalizeBeneficiaryFieldValue('notes', '{"key":"value"}'), isNull);
      });

      test('returns null for value containing "metadata" JSON key', () {
        expect(normalizeBeneficiaryFieldValue('notes', '{"metadata":{"x":1}}'), isNull);
      });

      test('returns null for value containing #meta: marker', () {
        expect(normalizeBeneficiaryFieldValue('notes', 'test\n\n#meta:{"x":"y"}'), isNull);
      });

      test('returns Arabic yes/no for booleans', () {
        expect(normalizeBeneficiaryFieldValue('hasdisability', true), equals('نعم'));
        expect(normalizeBeneficiaryFieldValue('hasdisability', false), equals('لا'));
      });

      test('returns joined string for simple string list', () {
        expect(normalizeBeneficiaryFieldValue('needs', ['طعام', 'دواء']), equals('طعام، دواء'));
      });

      test('returns null for list containing nested maps', () {
        expect(
            normalizeBeneficiaryFieldValue('needs', [
              <String, dynamic>{'x': 1}
            ]),
            isNull);
      });

      test('returns plain string for normal text', () {
        expect(normalizeBeneficiaryFieldValue('notes', 'ملاحظة عادية'), equals('ملاحظة عادية'));
      });

      test('does not mutate input list', () {
        final input = ['طعام', 'دواء'];
        normalizeBeneficiaryFieldValue('needs', input);
        expect(input, equals(['طعام', 'دواء']));
      });

      test('does not mutate input map', () {
        final input = <String, dynamic>{'key': 'value'};
        normalizeBeneficiaryFieldValue('metadata', input);
        expect(input, equals({'key': 'value'}));
      });
    });
  });
}
