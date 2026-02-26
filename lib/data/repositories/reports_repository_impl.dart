/// Reports Repository Implementation
/// Clean Architecture - Data Layer
/// Converts database query results to domain entities
library;

import '../db/daos/beneficiaries_dao.dart';
import '../db/daos/taxonomies_dao.dart';
import '../db/drift_database.dart';
import '../../features/reports/domain/entities/report_data.dart';
import '../../features/reports/domain/entities/summary_statistics.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/beneficiaries/domain/entities/beneficiary.dart' as entity;
import '../../features/beneficiaries/data/models/beneficiary_data_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final BeneficiariesDao beneficiariesDao;
  final TaxonomiesDao taxonomiesDao;

  ReportsRepositoryImpl({
    required this.beneficiariesDao,
    required this.taxonomiesDao,
  });

  @override
  Future<SummaryStatistics> getSummaryStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await beneficiariesDao.getSummaryStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      return SummaryStatistics(
        total: result.total,
        orphans: result.orphans,
        poor: result.poor,
        pending: result.pending,
      );
    } catch (e) {
      throw Exception('Failed to get summary statistics: $e');
    }
  }

  @override
  Future<List<GenderCount>> getGenderReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await beneficiariesDao.getGenderCounts(
        startDate: startDate,
        endDate: endDate,
      );

      return results.map((result) {
        final genderName = _getGenderName(result.gender);
        return GenderCount(gender: genderName, count: result.count);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get gender report: $e');
    }
  }

  @override
  Future<List<GovernorateCount>> getGovernorateReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await beneficiariesDao.getGovernorateCounts(
        startDate: startDate,
        endDate: endDate,
      );

      // Get all region taxonomies for mapping
      var governorates = await taxonomiesDao.getByGroup('governorate');
      if (governorates.isEmpty) {
        governorates = await taxonomiesDao.getByGroup('province');
      }

      final governorateMap = _buildTaxonomyLabelIndex(governorates);

      return results.map((result) {
        final governorateName = governorateMap[result.governorate] ?? 'غير محدد';
        return GovernorateCount(
          governorate: governorateName,
          count: result.count,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get governorate report: $e');
    }
  }

  @override
  Future<List<CategoryCount>> getCategoryReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await beneficiariesDao.getCategoryCounts(
        startDate: startDate,
        endDate: endDate,
      );

      final categoryMap = await _buildCategoryLabelMap();

      return results.map((result) {
        final categoryName = categoryMap[result.sectionId] ?? _getCategoryName(result.sectionId);
        return CategoryCount(category: categoryName, count: result.count);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get category report: $e');
    }
  }

  @override
  Future<List<AgeCount>> getAgeReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await beneficiariesDao.getAgeCounts(
        startDate: startDate,
        endDate: endDate,
      );

      return results
          .map(
            (result) => AgeCount(ageBracket: result.ageBracket, count: result.count),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get age report: $e');
    }
  }

  @override
  Future<List<SyncStatusCount>> getSyncStatusReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final results = await beneficiariesDao.getSyncStatusCounts(
        startDate: startDate,
        endDate: endDate,
      );

      return results.map((result) {
        final statusName = _getSyncStatusName(result.syncState);
        return SyncStatusCount(status: statusName, count: result.count);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sync status report: $e');
    }
  }

  @override
  Future<List<entity.Beneficiary>> getAllBeneficiaries() async {
    try {
      // Get all beneficiaries from database (Drift entities)
      final driftBeneficiaries = await beneficiariesDao.getAllBeneficiaries();

      // Convert each Drift beneficiary to Domain entity using BeneficiaryDataModel
      return driftBeneficiaries.map((driftBen) {
        final dataModel = BeneficiaryDataModel.fromDrift(driftBen);
        return dataModel.toEntity();
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all beneficiaries: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS - مساعدات خاصة
  // ============================================================================

  /// Convert gender code to Arabic name
  String _getGenderName(int gender) {
    return switch (gender) {
      1 => 'ذكور',
      2 => 'إناث',
      _ => 'غير محدد',
    };
  }

  /// Convert category (section_id) to Arabic name
  String _getCategoryName(int sectionId) {
    return switch (sectionId) {
      1 => 'أيتام',
      2 => 'أرامل',
      3 => 'فقراء',
      4 => 'معاقين',
      _ => 'غير محدد',
    };
  }

  /// Convert sync state to Arabic name
  String _getSyncStatusName(String syncState) {
    return switch (syncState) {
      'synced' => 'تمت المزامنة',
      'pending' => 'بانتظار المزامنة',
      'failed' => 'فشلت المزامنة',
      _ => 'غير محدد',
    };
  }

  Future<Map<int, String>> _buildCategoryLabelMap() async {
    final categoryGroups = await taxonomiesDao.getByGroup('category');
    final sectionGroups = await taxonomiesDao.getByGroup('section');

    final result = <int, String>{};
    _mergeTaxonomyLabels(result, categoryGroups);
    _mergeTaxonomyLabels(result, sectionGroups);

    return result;
  }

  Map<int, String> _buildTaxonomyLabelIndex(List<Taxonomy> items) {
    final result = <int, String>{};
    _mergeTaxonomyLabels(result, items);
    return result;
  }

  void _mergeTaxonomyLabels(Map<int, String> target, List<Taxonomy> items) {
    for (final item in items) {
      final key = _parseTaxonomyNumericKey(item);
      if (key == null) {
        continue;
      }
      target.putIfAbsent(key, () => item.label);
    }
  }

  int? _parseTaxonomyNumericKey(Taxonomy taxonomy) {
    final code = int.tryParse(taxonomy.code.trim());
    if (code != null) {
      return code;
    }

    final rawId = taxonomy.id.trim();
    if (rawId.isEmpty) {
      return null;
    }

    final separatorIndex = rawId.indexOf('::');
    final suffix = separatorIndex >= 0 ? rawId.substring(separatorIndex + 2) : rawId;
    return int.tryParse(suffix.trim());
  }
}
