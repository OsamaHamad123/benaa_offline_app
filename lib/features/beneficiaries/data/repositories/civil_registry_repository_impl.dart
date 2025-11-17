import '../../domain/entities/civil_registry_person.dart';
import '../../domain/repositories/civil_registry_repository.dart';
import '../datasources/civil_registry_local_datasource.dart';

/// 🏗️ Civil Registry Repository Implementation
///
/// Implements the domain repository interface with caching and error handling.
class CivilRegistryRepositoryImpl implements CivilRegistryRepository {
  final CivilRegistryLocalDataSource localDataSource;

  // Cache for quick lookups (expires after 5 minutes)
  final Map<String, _CachedPerson> _cache = {};
  static const _cacheExpiry = Duration(minutes: 5);

  CivilRegistryRepositoryImpl(this.localDataSource);

  @override
  Future<CivilRegistryPerson?> getByNationalId(String nationalId) async {
    // Check cache first
    final cached = _cache[nationalId];
    if (cached != null && !cached.isExpired) {
      return cached.person;
    }

    try {
      final model = await localDataSource.getByNationalId(nationalId);

      if (model == null) {
        return null;
      }

      final person = model.toEntity();

      // Cache the result
      _cache[nationalId] = _CachedPerson(person);

      return person;
    } on CivilRegistryException {
      rethrow;
    } catch (e) {
      throw CivilRegistryException(
        'فشل في جلب البيانات: ${e.toString()}',
        CivilRegistryErrorType.unknown,
      );
    }
  }

  @override
  Future<List<CivilRegistryPerson>> search({
    String? firstName,
    String? lastName,
    String? motherName,
    DateTime? birthDate,
  }) async {
    try {
      // Build search query
      final searchName = _buildSearchQuery(
        firstName: firstName,
        lastName: lastName,
      );

      if (searchName.isEmpty) {
        return [];
      }

      final models = await localDataSource.searchByName(
        name: searchName,
        limit: 50,
      );

      return models.map((m) => m.toEntity()).toList();
    } on CivilRegistryException {
      rethrow;
    } catch (e) {
      throw CivilRegistryException(
        'فشل البحث: ${e.toString()}',
        CivilRegistryErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> exists(String nationalId) async {
    // Check cache first
    final cached = _cache[nationalId];
    if (cached != null && !cached.isExpired) {
      return true;
    }

    try {
      return await localDataSource.exists(nationalId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }

  /// Build search query from multiple name parts
  String _buildSearchQuery({String? firstName, String? lastName}) {
    final parts = <String>[];

    if (firstName != null && firstName.isNotEmpty) {
      parts.add(firstName);
    }
    if (lastName != null && lastName.isNotEmpty) {
      parts.add(lastName);
    }

    return parts.join(' ');
  }
}

/// Internal cached person with expiry
class _CachedPerson {
  final CivilRegistryPerson person;
  final DateTime cachedAt;

  _CachedPerson(this.person) : cachedAt = DateTime.now();

  bool get isExpired {
    return DateTime.now().difference(cachedAt) >
        CivilRegistryRepositoryImpl._cacheExpiry;
  }
}
