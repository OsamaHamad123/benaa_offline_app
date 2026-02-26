import 'package:benaa_offline_app/core/error_handling/result.dart';

import '../entities/taxonomy.dart';
import '../entities/taxonomy_group.dart';
import '../repositories/taxonomy_repository.dart';

/// 🔄 Sync Taxonomies Use Case
///
/// مزامنة التصنيفات من السيرفر
class SyncTaxonomiesUseCase {
  final TaxonomyRepository _repository;

  SyncTaxonomiesUseCase(this._repository);

  /// تنفيذ المزامنة الكاملة
  Future<Result<TaxonomySyncResult>> call() async {
    return await _repository.syncFromServer();
  }

  /// مزامنة مجموعة معينة
  Future<Result<TaxonomySyncResult>> syncGroup(TaxonomyGroup group) async {
    return await _repository.syncGroupFromServer(group);
  }

  /// إعادة تعيين ومزامنة
  Future<Result<TaxonomySyncResult>> resetAndSync() async {
    return await _repository.resetAndSync();
  }
}

/// 📖 Get Taxonomies Use Case
///
/// جلب التصنيفات
class GetTaxonomiesUseCase {
  final TaxonomyRepository _repository;

  GetTaxonomiesUseCase(this._repository);

  /// جلب جميع التصنيفات
  Future<Result<List<Taxonomy>>> call() async {
    return await _repository.getAllTaxonomies();
  }

  /// جلب حسب المجموعة
  Future<Result<List<Taxonomy>>> byGroup(TaxonomyGroup group) async {
    return await _repository.getTaxonomiesByGroup(group);
  }

  /// جلب تصنيف واحد
  Future<Result<Taxonomy>> byId(String id) async {
    return await _repository.getTaxonomyById(id);
  }

  /// جلب بالكود
  Future<Result<Taxonomy>> byCode(TaxonomyGroup group, String code) async {
    return await _repository.getTaxonomyByCode(group, code);
  }

  /// البحث
  Future<Result<List<Taxonomy>>> search(String query) async {
    return await _repository.searchTaxonomies(query);
  }

  /// جلب الأبناء
  Future<Result<List<Taxonomy>>> children(String parentId) async {
    return await _repository.getChildTaxonomies(parentId);
  }
}

/// ✏️ Create Taxonomy Use Case
///
/// إنشاء تصنيف جديد
class CreateTaxonomyUseCase {
  final TaxonomyRepository _repository;

  CreateTaxonomyUseCase(this._repository);

  Future<Result<Taxonomy>> call(Taxonomy taxonomy) async {
    // التحقق من صلاحية البيانات
    final validationResult = _validate(taxonomy);
    if (validationResult != null) {
      return Failure(validationResult);
    }

    // التحقق من عدم وجود كود مكرر
    final isUnique = await _repository.isCodeUnique(
      taxonomy.group,
      taxonomy.code,
    );
    if (!isUnique) {
      return Failure(ValidationFailure(
        'الكود "${taxonomy.code}" موجود مسبقاً في مجموعة ${taxonomy.group.arabicName}',
      ));
    }

    return await _repository.createTaxonomy(taxonomy);
  }

  ValidationFailure? _validate(Taxonomy taxonomy) {
    if (taxonomy.code.isEmpty) {
      return const ValidationFailure('كود التصنيف مطلوب');
    }

    if (taxonomy.label.isEmpty) {
      return const ValidationFailure('اسم التصنيف مطلوب');
    }

    if (taxonomy.code.length < 2) {
      return const ValidationFailure('كود التصنيف يجب أن يكون حرفين على الأقل');
    }

    return null;
  }
}

/// 🔄 Update Taxonomy Use Case
///
/// تحديث تصنيف
class UpdateTaxonomyUseCase {
  final TaxonomyRepository _repository;

  UpdateTaxonomyUseCase(this._repository);

  Future<Result<Taxonomy>> call(Taxonomy taxonomy) async {
    // التحقق من وجود التصنيف
    final exists = await _repository.exists(taxonomy.id);
    if (!exists) {
      return const Failure(NotFoundFailure('التصنيف غير موجود'));
    }

    // التحقق من عدم تكرار الكود
    final isUnique = await _repository.isCodeUnique(
      taxonomy.group,
      taxonomy.code,
      excludeId: taxonomy.id,
    );
    if (!isUnique) {
      return Failure(ValidationFailure(
        'الكود "${taxonomy.code}" موجود مسبقاً',
      ));
    }

    return await _repository.updateTaxonomy(taxonomy);
  }
}

/// 🗑️ Delete Taxonomy Use Case
///
/// حذف تصنيف
class DeleteTaxonomyUseCase {
  final TaxonomyRepository _repository;

  DeleteTaxonomyUseCase(this._repository);

  /// حذف soft (يمكن استعادته)
  Future<Result<void>> call(String id) async {
    // التحقق من وجود التصنيف
    final exists = await _repository.exists(id);
    if (!exists) {
      return const Failure(NotFoundFailure('التصنيف غير موجود'));
    }

    // التحقق من عدم وجود أبناء
    final childrenResult = await _repository.getChildTaxonomies(id);
    if (childrenResult is Success<List<Taxonomy>>) {
      final children = childrenResult.value;
      if (children.isNotEmpty) {
        return const Failure(ValidationFailure(
          'لا يمكن حذف التصنيف لأنه يحتوي على تصنيفات فرعية',
        ));
      }
    }

    return await _repository.deleteTaxonomy(id);
  }

  /// حذف نهائي (لا يمكن استعادته)
  Future<Result<void>> permanently(String id) async {
    return await _repository.permanentlyDeleteTaxonomy(id);
  }

  /// استعادة تصنيف محذوف
  Future<Result<Taxonomy>> restore(String id) async {
    return await _repository.restoreTaxonomy(id);
  }
}

/// 📊 Get Taxonomy Statistics Use Case
///
/// الحصول على إحصائيات
class GetTaxonomyStatisticsUseCase {
  final TaxonomyRepository _repository;

  GetTaxonomyStatisticsUseCase(this._repository);

  Future<Result<TaxonomyStatistics>> call() async {
    return await _repository.getStatistics();
  }
}

/// 📦 Batch Taxonomy Mutation Use Case
///
/// تنفيذ عمليات الإنشاء/التحديث/الحذف الدفعي للتصنيفات
class BatchTaxonomyMutationUseCase {
  final TaxonomyRepository _repository;

  BatchTaxonomyMutationUseCase(this._repository);

  Future<Result<List<Taxonomy>>> create(
    TaxonomyGroup group,
    List<String> names,
  ) async {
    final cleaned = names.map((name) => name.trim()).where((name) => name.isNotEmpty).toList(growable: false);
    if (cleaned.isEmpty) {
      return const Failure(ValidationFailure('قائمة الأسماء فارغة'));
    }

    return await _repository.createTaxonomiesBatch(group, cleaned);
  }

  Future<Result<List<Taxonomy>>> update(
    TaxonomyGroup group,
    Map<String, String> updates,
  ) async {
    final cleaned = <String, String>{};
    for (final entry in updates.entries) {
      final id = entry.key.trim();
      final name = entry.value.trim();
      if (id.isEmpty || name.isEmpty) {
        continue;
      }
      cleaned[id] = name;
    }

    if (cleaned.isEmpty) {
      return const Failure(ValidationFailure('لا توجد عناصر صالحة للتحديث'));
    }

    return await _repository.updateTaxonomiesBatch(group, cleaned);
  }

  Future<Result<List<String>>> delete(
    TaxonomyGroup group,
    List<String> ids,
  ) async {
    final cleaned = ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toList(growable: false);
    if (cleaned.isEmpty) {
      return const Failure(ValidationFailure('لا توجد معرفات صالحة للحذف'));
    }

    return await _repository.deleteTaxonomiesBatch(group, cleaned);
  }
}
