import '../entities/civil_registry_person.dart';
import '../repositories/civil_registry_repository.dart';

/// 🔍 Use Case: Fetch Civil Registry Data
///
/// Fetches person data from civil registry by national ID.
/// Includes validation, caching, and error handling.
class FetchCivilRegistryDataUseCase {
  final CivilRegistryRepository repository;

  const FetchCivilRegistryDataUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns [CivilRegistryResult] with person data or error.
  Future<CivilRegistryResult> execute(String nationalId) async {
    // Validate national ID format
    if (!_isValidNationalId(nationalId)) {
      return CivilRegistryResult.error(
        'رقم الهوية غير صحيح (يجب أن يكون 9 أرقام)',
        CivilRegistryErrorType.invalidNationalId,
      );
    }

    try {
      final person = await repository.getByNationalId(nationalId);

      if (person == null) {
        return CivilRegistryResult.notFound(
          'لم يتم العثور على هذا الرقم في السجل المدني',
        );
      }

      // Check if person is active
      if (!person.isActive) {
        return CivilRegistryResult.error(
          'هذا السجل غير نشط في السجل المدني',
          CivilRegistryErrorType.unknown,
        );
      }

      return CivilRegistryResult.success(person);
    } on CivilRegistryException catch (e) {
      return CivilRegistryResult.error(_getErrorMessage(e.type), e.type);
    } catch (e) {
      return CivilRegistryResult.error(
        'حدث خطأ غير متوقع: ${e.toString()}',
        CivilRegistryErrorType.unknown,
      );
    }
  }

  /// Validate national ID format (9 digits)
  bool _isValidNationalId(String nationalId) {
    return nationalId.length == 9 && RegExp(r'^\d{9}$').hasMatch(nationalId);
  }

  /// Get user-friendly error message
  String _getErrorMessage(CivilRegistryErrorType type) {
    switch (type) {
      case CivilRegistryErrorType.notFound:
        return 'لم يتم العثور على هذا الرقم في السجل المدني';
      case CivilRegistryErrorType.connectionError:
        return 'فشل الاتصال بقاعدة البيانات';
      case CivilRegistryErrorType.invalidNationalId:
        return 'رقم الهوية غير صحيح';
      case CivilRegistryErrorType.serverError:
        return 'خطأ في الخادم';
      case CivilRegistryErrorType.timeout:
        return 'انتهت مهلة الاتصال';
      case CivilRegistryErrorType.databaseNotAvailable:
        return 'قاعدة بيانات السجل المدني غير متوفرة. يرجى تحميلها من الإعدادات.';
      case CivilRegistryErrorType.unknown:
        return 'حدث خطأ غير معروف';
    }
  }
}

/// 📊 Result wrapper for civil registry operations
class CivilRegistryResult {
  final CivilRegistryPerson? person;
  final String? errorMessage;
  final CivilRegistryErrorType? errorType;
  final CivilRegistryResultStatus status;

  const CivilRegistryResult._({
    this.person,
    this.errorMessage,
    this.errorType,
    required this.status,
  });

  factory CivilRegistryResult.success(CivilRegistryPerson person) {
    return CivilRegistryResult._(
      person: person,
      status: CivilRegistryResultStatus.success,
    );
  }

  factory CivilRegistryResult.notFound(String message) {
    return CivilRegistryResult._(
      errorMessage: message,
      errorType: CivilRegistryErrorType.notFound,
      status: CivilRegistryResultStatus.notFound,
    );
  }

  factory CivilRegistryResult.error(
    String message,
    CivilRegistryErrorType type,
  ) {
    return CivilRegistryResult._(
      errorMessage: message,
      errorType: type,
      status: CivilRegistryResultStatus.error,
    );
  }

  bool get isSuccess => status == CivilRegistryResultStatus.success;
  bool get isNotFound => status == CivilRegistryResultStatus.notFound;
  bool get isError => status == CivilRegistryResultStatus.error;
}

enum CivilRegistryResultStatus { success, notFound, error }
