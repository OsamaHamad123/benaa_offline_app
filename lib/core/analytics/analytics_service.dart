import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/drift_database.dart';

/// 📊 Analytics Service
/// خدمة تحليل البيانات وإنشاء الإحصائيات

class AnalyticsService {
  final AppDatabase _database;

  AnalyticsService(this._database);

  /// احصاءات عامة
  Future<Map<String, dynamic>> getGeneralStats() async {
    final totalBeneficiaries = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM beneficiaries WHERE deleted_at IS NULL',
        )
        .getSingleOrNull();

    final totalFamilies = await _database
        .customSelect(
          'SELECT COUNT(DISTINCT family_id) as count FROM beneficiaries WHERE deleted_at IS NULL',
        )
        .getSingleOrNull();

    final totalVisits = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM visits',
        )
        .getSingleOrNull();

    final totalSponsorships = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM sponsorships WHERE status = \'active\'',
        )
        .getSingleOrNull();

    return {
      'totalBeneficiaries': (totalBeneficiaries?.data['count'] as int?) ?? 0,
      'totalFamilies': (totalFamilies?.data['count'] as int?) ?? 0,
      'totalVisits': (totalVisits?.data['count'] as int?) ?? 0,
      'totalSponsorships': (totalSponsorships?.data['count'] as int?) ?? 0,
    };
  }

  /// احصاءات شهرية
  Future<List<Map<String, dynamic>>> getMonthlyStats(int year) async {
    final List<Map<String, dynamic>> monthlyData = [];

    for (int month = 1; month <= 12; month++) {
      final startDate = DateTime(year, month).toIso8601String();
      final endDate = DateTime(year, month + 1, 0).toIso8601String();

      final beneficiaries = await _database
          .customSelect(
            'SELECT COUNT(*) as count FROM beneficiaries WHERE created_at >= \'$startDate\' AND created_at <= \'$endDate\' AND deleted_at IS NULL',
          )
          .getSingleOrNull();

      final visits = await _database
          .customSelect(
            'SELECT COUNT(*) as count FROM visits WHERE visit_date >= \'$startDate\' AND visit_date <= \'$endDate\'',
          )
          .getSingleOrNull();

      monthlyData.add({
        'month': month,
        'monthName': _getMonthName(month),
        'beneficiaries': (beneficiaries?.data['count'] as int?) ?? 0,
        'visits': (visits?.data['count'] as int?) ?? 0,
      });
    }

    return monthlyData;
  }

  /// احصاءات حسب الحالة الاجتماعية
  Future<Map<String, int>> getMaritalStatusStats() async {
    final result = await _database
        .customSelect(
          'SELECT marital_status, COUNT(*) as count FROM beneficiaries WHERE deleted_at IS NULL GROUP BY marital_status',
        )
        .get();

    return {
      for (var row in result)
        _translateMaritalStatus(row.data['marital_status'] as String?): (row.data['count'] as int?) ?? 0,
    };
  }

  /// احصاءات حسب الحالة الصحية
  Future<Map<String, int>> getHealthStatusStats() async {
    final result = await _database
        .customSelect(
          'SELECT health_condition, COUNT(*) as count FROM beneficiaries WHERE deleted_at IS NULL AND health_condition IS NOT NULL GROUP BY health_condition',
        )
        .get();

    return {
      for (var row in result) row.data['health_condition'] as String: (row.data['count'] as int?) ?? 0,
    };
  }

  /// احصاءات حسب الفئة العمرية
  Future<Map<String, int>> getAgeGroupStats() async {
    final beneficiaries = await _database
        .customSelect(
          'SELECT date_of_birth FROM beneficiaries WHERE deleted_at IS NULL AND date_of_birth IS NOT NULL',
        )
        .get();

    final Map<String, int> ageGroups = {
      '0-18': 0,
      '19-30': 0,
      '31-50': 0,
      '51-65': 0,
      '66+': 0,
    };

    for (var row in beneficiaries) {
      final dateOfBirth = row.data['date_of_birth'] as DateTime?;
      if (dateOfBirth == null) continue;

      final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;

      if (age <= 18) {
        ageGroups['0-18'] = (ageGroups['0-18'] ?? 0) + 1;
      } else if (age <= 30) {
        ageGroups['19-30'] = (ageGroups['19-30'] ?? 0) + 1;
      } else if (age <= 50) {
        ageGroups['31-50'] = (ageGroups['31-50'] ?? 0) + 1;
      } else if (age <= 65) {
        ageGroups['51-65'] = (ageGroups['51-65'] ?? 0) + 1;
      } else {
        ageGroups['66+'] = (ageGroups['66+'] ?? 0) + 1;
      }
    }

    return ageGroups;
  }

  /// احصاءات حسب الجنس
  Future<Map<String, int>> getGenderStats() async {
    final result = await _database
        .customSelect(
          'SELECT gender, COUNT(*) as count FROM beneficiaries WHERE deleted_at IS NULL GROUP BY gender',
        )
        .get();

    return {
      for (var row in result) _translateGender(row.data['gender'] as String?): (row.data['count'] as int?) ?? 0,
    };
  }

  /// احصاءات الكفالات النشطة
  Future<List<Map<String, dynamic>>> getSponsorshipStats() async {
    final result = await _database.customSelect('''
      SELECT 
        s.sponsorship_type,
        s.amount,
        COUNT(*) as count,
        SUM(s.amount) as total
      FROM sponsorships s
      WHERE s.status = 'active'
      GROUP BY s.sponsorship_type, s.amount
      ORDER BY total DESC
    ''').get();

    return result
        .map((row) => {
              'type': row.data['sponsorship_type'] as String,
              'amount': (row.data['amount'] as num?)?.toDouble() ?? 0.0,
              'count': (row.data['count'] as int?) ?? 0,
              'total': (row.data['total'] as num?)?.toDouble() ?? 0.0,
            })
        .toList();
  }

  /// احصاءات الزيارات حسب النوع
  Future<Map<String, int>> getVisitTypeStats() async {
    final result = await _database
        .customSelect(
          'SELECT visit_type, COUNT(*) as count FROM visits GROUP BY visit_type',
        )
        .get();

    return {
      for (var row in result) _translateVisitType(row.data['visit_type'] as String?): (row.data['count'] as int?) ?? 0,
    };
  }

  /// مقارنة بين سنتين
  Future<Map<String, dynamic>> compareYears(int year1, int year2) async {
    final stats1 = await getYearStats(year1);
    final stats2 = await getYearStats(year2);

    return {
      'year1': year1,
      'year2': year2,
      'stats1': stats1,
      'stats2': stats2,
      'growth': {
        'beneficiaries': _calculateGrowth(
          stats1['beneficiaries'] as int,
          stats2['beneficiaries'] as int,
        ),
        'visits': _calculateGrowth(
          stats1['visits'] as int,
          stats2['visits'] as int,
        ),
        'sponsorships': _calculateGrowth(
          stats1['sponsorships'] as int,
          stats2['sponsorships'] as int,
        ),
      },
    };
  }

  /// احصاءات سنوية
  Future<Map<String, int>> getYearStats(int year) async {
    final startDate = DateTime(year).toIso8601String();
    final endDate = DateTime(year, 12, 31).toIso8601String();

    final beneficiaries = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM beneficiaries WHERE created_at >= \'$startDate\' AND created_at <= \'$endDate\'',
        )
        .getSingleOrNull();

    final visits = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM visits WHERE visit_date >= \'$startDate\' AND visit_date <= \'$endDate\'',
        )
        .getSingleOrNull();

    final sponsorships = await _database
        .customSelect(
          'SELECT COUNT(*) as count FROM sponsorships WHERE created_at >= \'$startDate\' AND created_at <= \'$endDate\'',
        )
        .getSingleOrNull();

    return {
      'beneficiaries': (beneficiaries?.data['count'] as int?) ?? 0,
      'visits': (visits?.data['count'] as int?) ?? 0,
      'sponsorships': (sponsorships?.data['count'] as int?) ?? 0,
    };
  }

  // Helper methods
  double _calculateGrowth(int oldValue, int newValue) {
    if (oldValue == 0) return 100.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  String _translateMaritalStatus(String? status) {
    switch (status) {
      case 'single':
        return 'أعزب';
      case 'married':
        return 'متزوج';
      case 'divorced':
        return 'مطلق';
      case 'widowed':
        return 'أرمل';
      default:
        return 'غير محدد';
    }
  }

  String _translateGender(String? gender) {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  String _translateVisitType(String? type) {
    switch (type) {
      case 'home_visit':
        return 'زيارة منزلية';
      case 'office_visit':
        return 'زيارة مكتبية';
      case 'phone_call':
        return 'اتصال هاتفي';
      default:
        return type ?? 'غير محدد';
    }
  }
}

/// Database Provider (من التطبيق الرئيسي)
final databaseProviderForAnalytics = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

/// Provider للـ Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final database = ref.watch(databaseProviderForAnalytics);
  return AnalyticsService(database);
});
