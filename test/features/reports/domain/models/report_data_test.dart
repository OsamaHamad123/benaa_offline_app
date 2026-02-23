import 'package:flutter_test/flutter_test.dart';
import 'package:benaa_offline_app/features/reports/domain/models/report_data.dart';

void main() {
  group('ReportFilters', () {
    test('should create initial filters with default values', () {
      final filters = ReportFilters.initial();

      expect(filters.governorate, 'الكل');
      expect(filters.status, 'الكل');
      expect(filters.startDate, null);
      expect(filters.endDate, null);
      expect(filters.category, null);
    });

    test('should create filters with custom values', () {
      const filters = ReportFilters(
        startDate: '2024-01-01',
        endDate: '2024-12-31',
        governorate: 'دمشق',
        status: 'نشط',
        category: 'عائلات',
      );

      expect(filters.startDate, '2024-01-01');
      expect(filters.endDate, '2024-12-31');
      expect(filters.governorate, 'دمشق');
      expect(filters.status, 'نشط');
      expect(filters.category, 'عائلات');
    });

    test('copyWith should update only specified fields', () {
      final original = ReportFilters.initial();
      final updated = original.copyWith(
        startDate: '2024-01-01',
        governorate: 'حلب',
      );

      expect(updated.startDate, '2024-01-01');
      expect(updated.governorate, 'حلب');
      expect(updated.status, 'الكل'); // Unchanged
      expect(updated.endDate, null); // Unchanged
    });

    test('toJson should convert to map correctly', () {
      const filters = ReportFilters(
        startDate: '2024-01-01',
        endDate: '2024-12-31',
        governorate: 'دمشق',
        status: 'نشط',
        category: 'عائلات',
      );

      final json = filters.toJson();

      expect(json['startDate'], '2024-01-01');
      expect(json['endDate'], '2024-12-31');
      expect(json['governorate'], 'دمشق');
      expect(json['status'], 'نشط');
      expect(json['category'], 'عائلات');
    });
  });

  group('ReportData', () {
    test('should create empty report data', () {
      final data = ReportData.empty();

      expect(data.title, 'تقرير جديد');
      expect(data.totalCount, 0);
      expect(data.activeCount, 0);
      expect(data.suspendedCount, 0);
      expect(data.categoryDistribution, isEmpty);
      expect(data.geographicDistribution, isEmpty);
      expect(data.rows, isEmpty);
    });

    test('should create report data with custom values', () {
      final rows = [
        const ReportRow(
          id: '1',
          name: 'محمد أحمد',
          nationalId: '123456789',
          governorate: 'دمشق',
          status: 'نشط',
          registrationDate: '2024-01-01',
        ),
      ];

      final data = ReportData(
        title: 'تقرير المستفيدين',
        totalCount: 100,
        activeCount: 80,
        suspendedCount: 20,
        categoryDistribution: {'عائلات': 50, 'أطفال': 30},
        geographicDistribution: {'دمشق': 60, 'حلب': 40},
        rows: rows,
      );

      expect(data.title, 'تقرير المستفيدين');
      expect(data.totalCount, 100);
      expect(data.activeCount, 80);
      expect(data.suspendedCount, 20);
      expect(data.categoryDistribution['عائلات'], 50);
      expect(data.geographicDistribution['دمشق'], 60);
      expect(data.rows.length, 1);
    });
  });

  group('ReportRow', () {
    test('should create report row with all fields', () {
      const row = ReportRow(
        id: '1',
        name: 'محمد أحمد',
        nationalId: '123456789',
        governorate: 'دمشق',
        status: 'نشط',
        registrationDate: '2024-01-01',
      );

      expect(row.id, '1');
      expect(row.name, 'محمد أحمد');
      expect(row.nationalId, '123456789');
      expect(row.governorate, 'دمشق');
      expect(row.status, 'نشط');
      expect(row.registrationDate, '2024-01-01');
    });

    test('toJson should convert to map correctly', () {
      const row = ReportRow(
        id: '1',
        name: 'محمد أحمد',
        nationalId: '123456789',
        governorate: 'دمشق',
        status: 'نشط',
        registrationDate: '2024-01-01',
      );

      final json = row.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'محمد أحمد');
      expect(json['nationalId'], '123456789');
      expect(json['governorate'], 'دمشق');
      expect(json['status'], 'نشط');
      expect(json['registrationDate'], '2024-01-01');
    });

    test('should handle Arabic text correctly', () {
      const row = ReportRow(
        id: '1',
        name: 'فاطمة الزهراء',
        nationalId: '987654321',
        governorate: 'اللاذقية',
        status: 'معلق',
        registrationDate: '2024-06-15',
      );

      expect(row.name, 'فاطمة الزهراء');
      expect(row.governorate, 'اللاذقية');
      expect(row.status, 'معلق');
    });

    test('multiple rows should maintain independence', () {
      const row1 = ReportRow(
        id: '1',
        name: 'محمد',
        nationalId: '111',
        governorate: 'دمشق',
        status: 'نشط',
        registrationDate: '2024-01-01',
      );

      const row2 = ReportRow(
        id: '2',
        name: 'أحمد',
        nationalId: '222',
        governorate: 'حلب',
        status: 'معلق',
        registrationDate: '2024-02-01',
      );

      expect(row1.id, '1');
      expect(row2.id, '2');
      expect(row1.name, 'محمد');
      expect(row2.name, 'أحمد');
    });
  });
}
