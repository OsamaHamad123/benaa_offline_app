import '../entities/civil_db_status.dart';
import '../repositories/civil_db_repository.dart';

/// 🔍 Check Database Status Use Case
///
/// Use case to check if civil registry database is downloaded and ready
class CheckDbStatusUseCase {
  final CivilDbRepository repository;

  const CheckDbStatusUseCase(this.repository);

  /// Execute the use case
  Future<CivilDbStatus> call() async {
    return await repository.checkStatus();
  }
}
