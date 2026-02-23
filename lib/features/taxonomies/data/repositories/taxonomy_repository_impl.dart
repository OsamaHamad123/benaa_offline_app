import 'dart:developer' as developer;

import '../../../../core/error_handling/result.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../domain/repositories/taxonomy_repository.dart';
import '../datasources/taxonomy_local_datasource.dart';
import '../datasources/taxonomy_local_drift_datasource.dart';
import '../datasources/taxonomy_remote_datasource.dart';
import '../models/taxonomy_dto.dart';

/// 🔧 Taxonomy Repository Implementation
///
/// تنفيذ مستودع التصنيفات - يربط بين Remote و Local Datasources
class TaxonomyRepositoryImpl implements TaxonomyRepository {
  final TaxonomyRemoteDataSource _remoteDataSource;
  final TaxonomyLocalDataSource _localDataSource;

  TaxonomyRepositoryImpl({
    required TaxonomyRemoteDataSource remoteDataSource,
    required TaxonomyLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // ═══════════════════════════════════════════════════════════════
  // 📖 READ Operations
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Result<List<Taxonomy>>> getAllTaxonomies() async {
    try {
      final taxonomies = await _localDataSource.getAllTaxonomies();
      return Success(taxonomies);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب التصنيفات: $e', st));
    }
  }

  @override
  Future<Result<List<Taxonomy>>> getTaxonomiesByGroup(TaxonomyGroup group) async {
    try {
      final taxonomies = await _localDataSource.getTaxonomiesByGroup(group);
      return Success(taxonomies);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب تصنيفات ${group.arabicName}: $e', st));
    }
  }

  @override
  Future<Result<Taxonomy>> getTaxonomyById(String id) async {
    try {
      final taxonomy = await _localDataSource.getTaxonomyById(id);
      if (taxonomy == null) {
        return Failure(NotFoundFailure('التصنيف غير موجود: $id'));
      }
      return Success(taxonomy);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب التصنيف: $e', st));
    }
  }

  @override
  Future<Result<Taxonomy>> getTaxonomyByCode(TaxonomyGroup group, String code) async {
    try {
      final taxonomy = await _localDataSource.getTaxonomyByCode(group, code);
      if (taxonomy == null) {
        return Failure(NotFoundFailure('التصنيف غير موجود: ${group.value}/$code'));
      }
      return Success(taxonomy);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب التصنيف بالكود: $e', st));
    }
  }

  @override
  Future<Result<List<Taxonomy>>> searchTaxonomies(String query) async {
    try {
      final taxonomies = await _localDataSource.searchTaxonomies(query);
      return Success(taxonomies);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل البحث: $e', st));
    }
  }

  @override
  Future<Result<List<Taxonomy>>> getChildTaxonomies(String parentId) async {
    try {
      final children = await _localDataSource.getChildTaxonomies(parentId);
      return Success(children);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب الأبناء: $e', st));
    }
  }

  @override
  Future<Result<TaxonomyStatistics>> getStatistics() async {
    try {
      final stats = await _localDataSource.getStatistics();
      return Success(stats);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل جلب الإحصائيات: $e', st));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✏️ WRITE Operations
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Result<Taxonomy>> createTaxonomy(Taxonomy taxonomy) async {
    try {
      // إنشاء على السيرفر أولاً
      final request = TaxonomyRequestDTO.fromEntity(taxonomy);
      final response = await _remoteDataSource.createTaxonomy(request);
      final createdTaxonomy = response.data.toEntity();

      // حفظ محلياً
      await _localDataSource.saveTaxonomy(createdTaxonomy);

      return Success(createdTaxonomy);
    } on TaxonomyApiException catch (e) {
      return Failure(ServerFailure(e.message, e.statusCode));
    } catch (e, st) {
      return Failure(UnknownFailure('فشل إنشاء التصنيف: $e', st));
    }
  }

  @override
  Future<Result<Taxonomy>> updateTaxonomy(Taxonomy taxonomy) async {
    try {
      // تحديث على السيرفر
      final request = TaxonomyRequestDTO.fromEntity(taxonomy);
      final response = await _remoteDataSource.updateTaxonomy(
        taxonomy.id,
        request,
      );
      final updatedTaxonomy = response.data.toEntity();

      // حفظ محلياً
      await _localDataSource.saveTaxonomy(updatedTaxonomy);

      return Success(updatedTaxonomy);
    } on TaxonomyApiException catch (e) {
      return Failure(ServerFailure(e.message, e.statusCode));
    } catch (e, st) {
      return Failure(UnknownFailure('فشل تحديث التصنيف: $e', st));
    }
  }

  @override
  Future<Result<void>> deleteTaxonomy(String id) async {
    try {
      // حذف على السيرفر
      await _remoteDataSource.deleteTaxonomy(id);

      // حذف محلياً
      await _localDataSource.deleteTaxonomy(id);

      return const Success(null);
    } on TaxonomyApiException catch (e) {
      return Failure(ServerFailure(e.message, e.statusCode));
    } catch (e, st) {
      return Failure(UnknownFailure('فشل حذف التصنيف: $e', st));
    }
  }

  @override
  Future<Result<void>> permanentlyDeleteTaxonomy(String id) async {
    try {
      await _localDataSource.permanentlyDeleteTaxonomy(id);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل الحذف النهائي: $e', st));
    }
  }

  @override
  Future<Result<Taxonomy>> restoreTaxonomy(String id) async {
    try {
      await _localDataSource.restoreTaxonomy(id);
      final restored = await _localDataSource.getTaxonomyById(id);
      if (restored == null) {
        return const Failure(NotFoundFailure('التصنيف غير موجود'));
      }
      return Success(restored);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل استعادة التصنيف: $e', st));
    }
  }

  @override
  Future<Result<int>> upsertTaxonomies(List<Taxonomy> taxonomies) async {
    try {
      await _localDataSource.saveTaxonomies(taxonomies);
      return Success(taxonomies.length);
    } catch (e, st) {
      return Failure(DatabaseFailure('فشل حفظ التصنيفات: $e', st));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 SYNC Operations
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Result<TaxonomySyncResult>> syncFromServer() async {
    try {
      final lastSync = await _localDataSource.getLastSyncTime();

      var response = await _remoteDataSource.getAllTaxonomies(since: lastSync);

      if (response.data.isNotEmpty) {
        await _saveCanonicalDtos(response.data);
      }

      // Fallback: if incremental sync leaves most groups empty, force a full sync once.
      final statsAfterIncremental = await _localDataSource.getStatistics();
      var nonEmptyGroups = statsAfterIncremental.countByGroup.values.where((count) => count > 0).length;
      final totalGroups = TaxonomyGroup.values.length;
      final coverageTooLow = nonEmptyGroups <= 2 || nonEmptyGroups < (totalGroups ~/ 3);

      if (coverageTooLow) {
        final fullResponse = await _remoteDataSource.getAllTaxonomies();
        if (fullResponse.data.isNotEmpty) {
          await _saveCanonicalDtos(fullResponse.data);
          response = fullResponse;
        }

        await _backfillMissingGroups();

        final statsAfterBackfill = await _localDataSource.getStatistics();
        nonEmptyGroups = statsAfterBackfill.countByGroup.values.where((count) => count > 0).length;
      }

      final shouldRunCatalogSweep = nonEmptyGroups < (totalGroups * 2 ~/ 3);
      if (shouldRunCatalogSweep) {
        await _syncAllServerCatalogGroups();
      }

      await _materializeMissingGroups();

      final syncTime = response.syncTimestamp ?? DateTime.now();
      await _localDataSource.updateLastSyncTime(syncTime);
      await _logCoverageSummary('syncFromServer');

      final result = TaxonomySyncResult(
        addedCount: response.data.length,
        updatedCount: 0,
        deletedCount: response.data.where((t) => t.deletedAt != null).length,
        syncTime: syncTime,
        success: response.success,
        message: response.message,
      );

      return Success(result);
    } on TaxonomyApiException catch (e) {
      return Failure(SyncFailure(e.message));
    } catch (e, st) {
      return Failure(SyncFailure('فشل المزامنة: $e', st));
    }
  }

  @override
  Future<Result<TaxonomySyncResult>> syncGroupFromServer(TaxonomyGroup group) async {
    try {
      final response = await _remoteDataSource.getTaxonomiesByGroup(group);

      if (response.data.isNotEmpty) {
        await _saveCanonicalDtos(response.data);
      }

      await _localDataSource.updateLastSyncTime(DateTime.now());
      await _logCoverageSummary('syncGroup:${group.value}');

      final result = TaxonomySyncResult(
        addedCount: response.data.length,
        updatedCount: 0,
        deletedCount: response.data.where((t) => t.deletedAt != null).length,
        syncTime: DateTime.now(),
        success: response.success,
        message: response.message,
      );

      return Success(result);
    } on TaxonomyApiException catch (e) {
      return Failure(SyncFailure(e.message));
    } catch (e, st) {
      return Failure(SyncFailure('فشل مزامنة ${group.arabicName}: $e', st));
    }
  }

  @override
  Future<Result<DateTime?>> getLastSyncTime() async {
    try {
      final time = await _localDataSource.getLastSyncTime();
      return Success(time);
    } catch (e, st) {
      return Failure(CacheFailure('فشل جلب وقت المزامنة: $e', st));
    }
  }

  @override
  Future<Result<void>> updateLastSyncTime(DateTime time) async {
    try {
      await _localDataSource.updateLastSyncTime(time);
      return const Success(null);
    } catch (e, st) {
      return Failure(CacheFailure('فشل تحديث وقت المزامنة: $e', st));
    }
  }

  @override
  Future<Result<TaxonomySyncResult>> resetAndSync() async {
    try {
      // مسح كل البيانات المحلية
      await _localDataSource.clearAll();

      // جلب كل التصنيفات من السيرفر
      final response = await _remoteDataSource.getAllTaxonomies();

      if (response.data.isNotEmpty) {
        await _saveCanonicalDtos(response.data);
      }

      await _backfillMissingGroups();
      await _syncAllServerCatalogGroups();
      await _materializeMissingGroups();

      await _localDataSource.updateLastSyncTime(DateTime.now());

      return Success(TaxonomySyncResult(
        addedCount: response.data.length,
        updatedCount: 0,
        deletedCount: 0,
        syncTime: DateTime.now(),
        success: true,
        message: 'تمت إعادة المزامنة بنجاح',
      ));
    } on TaxonomyApiException catch (e) {
      return Failure(SyncFailure(e.message));
    } catch (e, st) {
      return Failure(SyncFailure('فشل إعادة المزامنة: $e', st));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ VALIDATION Operations
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<bool> exists(String id) async {
    return await _localDataSource.exists(id);
  }

  @override
  Future<bool> isCodeUnique(TaxonomyGroup group, String code, {String? excludeId}) async {
    return await _localDataSource.isCodeUnique(group, code, excludeId: excludeId);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ CACHE Operations
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Result<void>> clearLocalCache() async {
    try {
      await _localDataSource.clearAll();
      return const Success(null);
    } catch (e, st) {
      return Failure(CacheFailure('فشل مسح الكاش: $e', st));
    }
  }

  @override
  Future<Result<void>> refreshCache() async {
    // Same as resetAndSync
    final result = await resetAndSync();
    return result.isSuccess ? const Success(null) : Failure((result as Failure).error);
  }

  Future<void> _saveCanonicalDtos(List<TaxonomyDTO> dtos) async {
    if (dtos.isEmpty) {
      return;
    }

    final local = _localDataSource;
    if (local is! TaxonomyLocalDriftDataSource) {
      final taxonomies = dtos
          .where((dto) {
            final normalizedGroup = TaxonomyGroup.normalizeValue(dto.groupValue) ?? dto.groupValue;
            return TaxonomyGroup.isValidGroup(normalizedGroup);
          })
          .map((dto) => dto.toEntity())
          .toList();

      if (taxonomies.isEmpty) {
        return;
      }

      await _localDataSource.saveTaxonomies(taxonomies);
      return;
    }

    final companions = dtos.map((dto) {
      final normalizedGroup = TaxonomyGroup.normalizeValue(dto.groupValue);
      final storedGroup = normalizedGroup ?? dto.groupValue;
      return dto.copyWith(groupValue: storedGroup).toDbCompanion();
    }).toList();

    await local.upsertCompanions(companions);
  }

  Future<void> _syncAllServerCatalogGroups() async {
    TaxonomyGroupsResponseDTO catalog;
    try {
      catalog = await _remoteDataSource.getGroups();
    } catch (_) {
      return;
    }

    for (final info in catalog.data) {
      final slugCandidates = _slugCandidates(info);
      if (slugCandidates.isEmpty) {
        continue;
      }

      for (final slug in slugCandidates) {
        try {
          final response = await _remoteDataSource.getTaxonomiesBySlug(slug);
          if (response.data.isEmpty) {
            continue;
          }
          await _saveCanonicalDtos(response.data);
          break;
        } catch (_) {
          continue;
        }
      }
    }
  }

  Future<void> _backfillMissingGroups() async {
    final stats = await _localDataSource.getStatistics();
    final missingGroups = {
      for (final entry in stats.countByGroup.entries)
        if (entry.value <= 0) entry.key,
    };

    if (missingGroups.isEmpty) {
      return;
    }

    TaxonomyGroupsResponseDTO? remoteGroups;
    try {
      remoteGroups = await _remoteDataSource.getGroups();
    } catch (_) {
      remoteGroups = null;
    }

    final slugCandidatesByGroup = <TaxonomyGroup, List<String>>{};

    if (remoteGroups != null) {
      for (final info in remoteGroups.data) {
        final resolvedGroup = _resolveCatalogGroup(info);
        if (resolvedGroup == null || !missingGroups.contains(resolvedGroup)) {
          continue;
        }

        final candidates = _slugCandidates(info);
        if (candidates.isEmpty) {
          continue;
        }

        final existing = slugCandidatesByGroup.putIfAbsent(resolvedGroup, () => <String>[]);
        for (final candidate in candidates) {
          if (!existing.contains(candidate)) {
            existing.add(candidate);
          }
        }
      }
    }

    for (final group in missingGroups) {
      final slugCandidates = slugCandidatesByGroup[group] ?? const <String>[];
      var filled = false;

      for (final slug in slugCandidates) {
        try {
          final response = await _remoteDataSource.getTaxonomiesBySlug(slug);
          if (response.data.isEmpty) {
            continue;
          }

          await _saveCanonicalDtos(response.data);
          filled = true;
          break;
        } catch (_) {
          continue;
        }
      }

      if (filled) {
        continue;
      }

      // Safety fallback for legacy servers that don't expose a catalog.
      try {
        final fallbackResponse = await _remoteDataSource.getTaxonomiesByGroup(group);
        if (fallbackResponse.data.isNotEmpty) {
          await _saveCanonicalDtos(fallbackResponse.data);
        }
      } catch (_) {
        continue;
      }
    }
  }

  Future<void> _materializeMissingGroups() async {
    final stats = await _localDataSource.getStatistics();
    final missingGroups = <TaxonomyGroup>[];

    for (final entry in stats.countByGroup.entries) {
      if (entry.value <= 0) {
        missingGroups.add(entry.key);
      }
    }

    if (missingGroups.isEmpty) {
      return;
    }

    final placeholders = missingGroups
        .map(
          (group) => TaxonomyDTO(
            id: '__placeholder__${group.value}',
            groupValue: group.value,
            code: '__placeholder__${group.value}',
            label: '${group.arabicName} (تحتاج مزامنة)',
            sortOrder: 999999,
            isActive: true,
            updatedAt: DateTime.now(),
          ),
        )
        .toList(growable: false);

    await _saveCanonicalDtos(placeholders);

    developer.log(
      'materialized missing taxonomy groups with placeholders: '
      '[${missingGroups.map((g) => g.value).join(', ')}]',
      name: 'TaxonomySync',
    );
  }

  TaxonomyGroup? _resolveCatalogGroup(TaxonomyGroupInfoDTO info) {
    return resolveTaxonomyGroupFromCandidates([
      info.slug,
      info.endpoint,
      info.name,
      info.arabicName,
      info.englishName,
    ]);
  }

  List<String> _slugCandidates(TaxonomyGroupInfoDTO info) {
    final raw = <String?>[
      info.slug,
      info.name,
      info.endpoint,
    ];

    final out = <String>[];
    for (final item in raw) {
      if (item == null) continue;
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;

      final fromEndpoint = _extractSlugFromEndpoint(trimmed);
      if (fromEndpoint != null) {
        if (!out.contains(fromEndpoint)) {
          out.add(fromEndpoint);
        }
        continue;
      }

      if (!out.contains(trimmed)) {
        out.add(trimmed);
      }
    }
    return out;
  }

  String? _extractSlugFromEndpoint(String endpoint) {
    final value = endpoint.trim();
    if (value.isEmpty) return null;

    var candidate = value;
    if (candidate.contains('/')) {
      final uri = Uri.tryParse(candidate);
      if (uri != null && uri.path.isNotEmpty) {
        final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          candidate = segments.last;
        }
      } else {
        candidate = candidate.split('/').where((segment) => segment.isNotEmpty).last;
      }
    }

    if (candidate.contains('?')) {
      candidate = candidate.split('?').first;
    }

    final normalized = candidate.trim();
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> _logCoverageSummary(String source) async {
    try {
      final stats = await _localDataSource.getStatistics();
      final missing = <String>[];
      for (final entry in stats.countByGroup.entries) {
        if (entry.value <= 0) {
          missing.add(entry.key.value);
        }
      }

      developer.log(
        'taxonomy coverage after $source: '
        'filled=${TaxonomyGroup.values.length - missing.length}/${TaxonomyGroup.values.length}, '
        'totalItems=${stats.totalCount}, '
        'missing=[${missing.join(', ')}]',
        name: 'TaxonomySync',
      );
    } catch (_) {
      // no-op logging helper
    }
  }
}
