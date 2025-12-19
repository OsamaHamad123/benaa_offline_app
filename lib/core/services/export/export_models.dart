/// 📊 Export Models - Unified data models for export operations
///
/// هذه الـ Models تُستخدم لتوحيد البيانات المُراد تصديرها
/// بحيث تكون متوافقة مع PDF و Excel و CSV

/// نوع التصدير
enum ExportType { pdf, excel, csv }

/// نوع المحتوى المُراد تصديره
enum ExportContentType {
  beneficiaries, // قائمة المستفيدين
  visits, // قائمة الزيارات
  activities, // سجل الأنشطة
  report, // تقرير
  custom, // محتوى مخصص
}

/// بيانات التصدير الأساسية
class ExportData {
  final ExportContentType contentType;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ExportData({
    required this.contentType,
    required this.title,
    this.subtitle,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedDate {
    return '${timestamp.year}/${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// جدول بيانات للتصدير
class ExportTable {
  final List<String> headers;
  final List<List<String>> rows;
  final String? title;

  const ExportTable({required this.headers, required this.rows, this.title});

  int get columnCount => headers.length;
  int get rowCount => rows.length;
  bool get isEmpty => rows.isEmpty;
  bool get isNotEmpty => rows.isNotEmpty;
}

/// إحصائية للتصدير
class ExportStatistic {
  final String label;
  final String value;
  final String? icon;
  final String? color;

  const ExportStatistic({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}

/// بيانات تصدير المستفيدين
class BeneficiariesExportData extends ExportData {
  final List<BeneficiaryExportRow> beneficiaries;
  final List<ExportStatistic>? statistics;

  BeneficiariesExportData({
    required this.beneficiaries,
    this.statistics,
    String? subtitle,
    DateTime? timestamp,
  }) : super(
          contentType: ExportContentType.beneficiaries,
          title: 'قائمة المستفيدين',
          subtitle: subtitle,
          timestamp: timestamp,
        );

  ExportTable toTable() {
    return ExportTable(
      headers: const [
        'الرقم',
        'الاسم الكامل',
        'الرقم الوطني',
        'الجنس',
        'الفئة',
        'المحافظة',
        'رقم الهاتف',
        'تاريخ الإضافة',
      ],
      rows: beneficiaries.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final b = entry.value;
        return [
          index.toString(),
          b.fullName,
          b.nationalId,
          b.gender,
          b.category,
          b.governorate ?? '-',
          b.phoneNumber ?? '-',
          b.createdAt ?? '-',
        ];
      }).toList(),
    );
  }
}

/// صف واحد من بيانات المستفيد للتصدير
class BeneficiaryExportRow {
  final String fullName;
  final String nationalId;
  final String gender;
  final String category;
  final String? governorate;
  final String? phoneNumber;
  final String? createdAt;

  const BeneficiaryExportRow({
    required this.fullName,
    required this.nationalId,
    required this.gender,
    required this.category,
    this.governorate,
    this.phoneNumber,
    this.createdAt,
  });
}

/// بيانات تصدير الزيارات
class VisitsExportData extends ExportData {
  final List<VisitExportRow> visits;
  final List<ExportStatistic>? statistics;

  VisitsExportData({
    required this.visits,
    this.statistics,
    String? subtitle,
    DateTime? timestamp,
  }) : super(
          contentType: ExportContentType.visits,
          title: 'قائمة الزيارات',
          subtitle: subtitle,
          timestamp: timestamp,
        );

  ExportTable toTable() {
    return ExportTable(
      headers: const [
        'الرقم',
        'اسم المستفيد',
        'تاريخ الزيارة',
        'نوع الزيارة',
        'الموظف',
        'الملاحظات',
      ],
      rows: visits.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final v = entry.value;
        return [
          index.toString(),
          v.beneficiaryName,
          v.visitDate,
          v.visitType,
          v.staffName ?? '-',
          v.notes?.isNotEmpty == true ? 'موجود' : '-',
        ];
      }).toList(),
    );
  }
}

/// صف واحد من بيانات الزيارة للتصدير
class VisitExportRow {
  final String beneficiaryName;
  final String visitDate;
  final String visitType;
  final String? staffName;
  final String? notes;

  const VisitExportRow({
    required this.beneficiaryName,
    required this.visitDate,
    required this.visitType,
    this.staffName,
    this.notes,
  });
}

/// بيانات تصدير التقرير
class ReportExportData extends ExportData {
  final List<ExportTable> tables;
  final List<ExportStatistic>? statistics;
  final Map<String, dynamic>? charts;

  ReportExportData({
    required this.tables,
    required String title,
    this.statistics,
    this.charts,
    String? subtitle,
    DateTime? timestamp,
  }) : super(
          contentType: ExportContentType.report,
          title: title,
          subtitle: subtitle,
          timestamp: timestamp,
        );
}

/// بيانات تصدير الأنشطة
class ActivitiesExportData extends ExportData {
  final List<ActivityExportRow> activities;
  final List<ExportStatistic>? statistics;

  ActivitiesExportData({
    required this.activities,
    this.statistics,
    String? subtitle,
    DateTime? timestamp,
  }) : super(
          contentType: ExportContentType.visits, // Using visits type for now
          title: 'سجل الأنشطة',
          subtitle: subtitle,
          timestamp: timestamp,
        );

  ExportTable toTable() {
    return ExportTable(
      headers: const [
        'الرقم',
        'نوع النشاط',
        'الوصف',
        'المستخدم',
        'التاريخ',
        'الحالة',
      ],
      rows: activities.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final a = entry.value;
        return [
          index.toString(),
          a.activityType,
          a.description,
          a.userName ?? '-',
          a.createdAt,
          a.syncState ?? '-',
        ];
      }).toList(),
    );
  }
}

/// صف واحد من بيانات النشاط للتصدير
class ActivityExportRow {
  final String activityType;
  final String description;
  final String? userName;
  final String createdAt;
  final String? syncState;

  const ActivityExportRow({
    required this.activityType,
    required this.description,
    this.userName,
    required this.createdAt,
    this.syncState,
  });
}

/// بيانات تصدير شامل للمستفيدين (مع كل التفاصيل)
class ComprehensiveBeneficiariesExportData extends ExportData {
  final List<ComprehensiveBeneficiaryData> beneficiaries;
  final List<ExportStatistic>? statistics;
  final bool includeAttachments;
  final bool includeVisits;
  final bool includeActivities;

  ComprehensiveBeneficiariesExportData({
    required this.beneficiaries,
    this.statistics,
    this.includeAttachments = true,
    this.includeVisits = true,
    this.includeActivities = true,
    String? subtitle,
    DateTime? timestamp,
  }) : super(
          contentType: ExportContentType.beneficiaries,
          title: 'تقرير شامل للمستفيدين',
          subtitle: subtitle,
          timestamp: timestamp,
        );

  /// جدول المعلومات الأساسية
  ExportTable get basicInfoTable {
    return ExportTable(
      title: 'المعلومات الأساسية',
      headers: const [
        'الرقم',
        'الاسم الكامل',
        'الرقم الوطني',
        'الجنس',
        'تاريخ الميلاد',
        'العمر',
        'الفئة',
        'المحافظة',
        'رقم الهاتف',
        'البريد الإلكتروني',
        'العنوان',
      ],
      rows: beneficiaries.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final b = entry.value;
        return [
          index.toString(),
          b.fullName,
          b.nationalId,
          b.gender,
          b.birthDate ?? '-',
          b.age ?? '-',
          b.category,
          b.governorate ?? '-',
          b.phoneNumber ?? '-',
          b.email ?? '-',
          b.address ?? '-',
        ];
      }).toList(),
    );
  }

  /// جدول الوضع الاقتصادي والاجتماعي
  ExportTable get socialEconomicTable {
    return ExportTable(
      title: 'الوضع الاقتصادي والاجتماعي',
      headers: const [
        'الاسم',
        'الحالة الاجتماعية',
        'عدد الأطفال',
        'الدخل الشهري',
        'نوع السكن',
        'المستوى التعليمي',
        'الحالة الصحية',
        'ملاحظات',
      ],
      rows: beneficiaries.map((b) {
        return [
          b.fullName,
          b.maritalStatus ?? '-',
          b.numberOfChildren ?? '-',
          b.monthlyIncome ?? '-',
          b.housingType ?? '-',
          b.educationLevel ?? '-',
          b.healthStatus ?? '-',
          b.notes ?? '-',
        ];
      }).toList(),
    );
  }

  /// جدول الزيارات (إذا كانت مفعلة)
  ExportTable? get visitsTable {
    if (!includeVisits) return null;

    final allVisits = <Map<String, String>>[];
    for (final b in beneficiaries) {
      for (final visit in b.visits ?? []) {
        allVisits.add({
          'name': b.fullName,
          'date': visit['date'] ?? '-',
          'type': visit['type'] ?? '-',
          'staff': visit['staff'] ?? '-',
          'notes': visit['notes'] ?? '-',
        });
      }
    }

    if (allVisits.isEmpty) return null;

    return ExportTable(
      title: 'سجل الزيارات',
      headers: const [
        'اسم المستفيد',
        'تاريخ الزيارة',
        'نوع الزيارة',
        'الموظف',
        'الملاحظات',
      ],
      rows: allVisits.map((v) {
        return [v['name']!, v['date']!, v['type']!, v['staff']!, v['notes']!];
      }).toList(),
    );
  }

  /// جدول المرفقات
  ExportTable? get attachmentsTable {
    if (!includeAttachments) return null;

    final allAttachments = <Map<String, String>>[];
    for (final b in beneficiaries) {
      for (final attachment in b.attachments ?? []) {
        allAttachments.add({
          'name': b.fullName,
          'nationalId': b.nationalId,
          'type': attachment['type'] ?? '-',
          'fileName': attachment['fileName'] ?? '-',
          'uploadDate': attachment['uploadDate'] ?? '-',
        });
      }
    }

    if (allAttachments.isEmpty) return null;

    return ExportTable(
      title: 'المرفقات',
      headers: const [
        'اسم المستفيد',
        'الرقم الوطني',
        'نوع المرفق',
        'اسم الملف',
        'تاريخ الرفع',
      ],
      rows: allAttachments.map((a) {
        return [
          a['name']!,
          a['nationalId']!,
          a['type']!,
          a['fileName']!,
          a['uploadDate']!,
        ];
      }).toList(),
    );
  }

  /// الحصول على جميع الجداول
  List<ExportTable> getAllTables() {
    final tables = <ExportTable>[basicInfoTable, socialEconomicTable];

    if (visitsTable != null) tables.add(visitsTable!);
    if (attachmentsTable != null) tables.add(attachmentsTable!);

    return tables;
  }
}

/// بيانات مستفيد شاملة للتصدير
class ComprehensiveBeneficiaryData {
  // المعلومات الأساسية
  final String fullName;
  final String nationalId;
  final String gender;
  final String? birthDate;
  final String? age;
  final String category;
  final String? governorate;
  final String? phoneNumber;
  final String? email;
  final String? address;

  // المعلومات الاجتماعية والاقتصادية
  final String? maritalStatus;
  final String? numberOfChildren;
  final String? monthlyIncome;
  final String? housingType;
  final String? educationLevel;
  final String? healthStatus;
  final String? notes;

  // الزيارات
  final List<Map<String, String>>? visits;

  // المرفقات
  final List<Map<String, String>>? attachments;

  // الأنشطة
  final List<Map<String, String>>? activities;

  const ComprehensiveBeneficiaryData({
    required this.fullName,
    required this.nationalId,
    required this.gender,
    this.birthDate,
    this.age,
    required this.category,
    this.governorate,
    this.phoneNumber,
    this.email,
    this.address,
    this.maritalStatus,
    this.numberOfChildren,
    this.monthlyIncome,
    this.housingType,
    this.educationLevel,
    this.healthStatus,
    this.notes,
    this.visits,
    this.attachments,
    this.activities,
  });
}

/// نتيجة عملية التصدير
class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final ExportType type;

  const ExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    required this.type,
  });

  factory ExportResult.success({
    required String filePath,
    required ExportType type,
  }) {
    return ExportResult(success: true, filePath: filePath, type: type);
  }

  factory ExportResult.failure({
    required String errorMessage,
    required ExportType type,
  }) {
    return ExportResult(success: false, errorMessage: errorMessage, type: type);
  }

  String get fileName {
    if (filePath == null) return '';
    return filePath!.split('/').last;
  }
}
