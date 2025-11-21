/// 🔍 Report Filters Model
class ReportFilters {
  final String? startDate;
  final String? endDate;
  final String? governorate;
  final String? status;
  final String? category;

  const ReportFilters({
    this.startDate,
    this.endDate,
    this.governorate,
    this.status,
    this.category,
  });

  factory ReportFilters.initial() {
    return const ReportFilters(governorate: 'الكل', status: 'الكل');
  }

  ReportFilters copyWith({
    String? startDate,
    String? endDate,
    String? governorate,
    String? status,
    String? category,
  }) {
    return ReportFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      governorate: governorate ?? this.governorate,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'governorate': governorate,
      'status': status,
      'category': category,
    };
  }
}

/// 📊 Report Data Model
class ReportData {
  final String title;
  final int totalCount;
  final int activeCount;
  final int suspendedCount;
  final Map<String, int> categoryDistribution;
  final Map<String, int> geographicDistribution;
  final List<ReportRow> rows;

  const ReportData({
    required this.title,
    required this.totalCount,
    required this.activeCount,
    required this.suspendedCount,
    required this.categoryDistribution,
    required this.geographicDistribution,
    required this.rows,
  });

  factory ReportData.empty() {
    return const ReportData(
      title: 'تقرير جديد',
      totalCount: 0,
      activeCount: 0,
      suspendedCount: 0,
      categoryDistribution: {},
      geographicDistribution: {},
      rows: [],
    );
  }
}

/// 📝 Report Row Model
class ReportRow {
  final String id;
  final String name;
  final String nationalId;
  final String governorate;
  final String status;
  final String registrationDate;

  const ReportRow({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.governorate,
    required this.status,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nationalId': nationalId,
      'governorate': governorate,
      'status': status,
      'registrationDate': registrationDate,
    };
  }
}
