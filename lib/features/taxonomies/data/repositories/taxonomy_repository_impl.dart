import '../../../../core/error_handling/result.dart';
import '../../domain/entities/taxonomy.dart';
import '../../domain/entities/taxonomy_group.dart';
import '../../domain/repositories/taxonomy_repository.dart';
import '../datasources/taxonomy_local_datasource.dart';
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

      return Success(null);
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
      return Success(null);
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
        return Failure(NotFoundFailure('التصنيف غير موجود'));
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

      final response = await _remoteDataSource.getAllTaxonomies(since: lastSync);

      if (response.data.isNotEmpty) {
        final taxonomies = response.data.map((d) => d.toEntity()).toList();
        await _localDataSource.saveTaxonomies(taxonomies);
      }

      final syncTime = response.syncTimestamp ?? DateTime.now();
      await _localDataSource.updateLastSyncTime(syncTime);

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
        final taxonomies = response.data.map((d) => d.toEntity()).toList();
        await _localDataSource.saveTaxonomies(taxonomies);
      }

      await _localDataSource.updateLastSyncTime(DateTime.now());

      return Success(TaxonomySyncResult(
        addedCount: response.data.length,
        updatedCount: 0,
        deletedCount: response.data.where((t) => t.deletedAt != null).length,
        syncTime: DateTime.now(),
        success: response.success,
        message: response.message,
      ));
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
      return Success(null);
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
      final response = await _remoteDataSource.getAllTaxonomies(since: null);

      if (response.data.isNotEmpty) {
        final taxonomies = response.data.map((d) => d.toEntity()).toList();
        await _localDataSource.saveTaxonomies(taxonomies);
      }

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
      return Success(null);
    } catch (e, st) {
      return Failure(CacheFailure('فشل مسح الكاش: $e', st));
    }
  }

  @override
  Future<Result<void>> refreshCache() async {
    // Same as resetAndSync
    final result = await resetAndSync();
    return result.isSuccess ? Success(null) : Failure((result as Failure).error);
  }
}
