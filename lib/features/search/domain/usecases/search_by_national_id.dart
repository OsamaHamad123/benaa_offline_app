import '../entities/civil_person.dart';
import '../repositories/civil_search_repository.dart';

/// 🔍 Search By National ID Use Case
///
/// Business logic for searching a person by their national ID.
/// Handles validation and error cases.
class SearchByNationalIdUseCase {
  final CivilSearchRepository repository;

  const SearchByNationalIdUseCase(this.repository);

  /// Execute search by national ID
  ///
  /// Accepts various formats:
  /// - With or without spaces
  /// - Different lengths (flexible)
  Future<CivilPerson?> call(String nationalId) async {
    // Validate input
    final cleaned = _cleanNationalId(nationalId);
    if (cleaned.isEmpty) {
      return null;
    }

    // Perform search
    return await repository.searchByNationalId(cleaned);
  }

  /// Clean and normalize national ID
  String _cleanNationalId(String nationalId) {
    // Remove all spaces and special characters
    return nationalId.trim().replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Check if string could be a national ID
  static bool isNationalIdFormat(String query) {
    final cleaned = query.replaceAll(RegExp(r'[^\d]'), '');
    // Accept IDs between 6-15 digits (more flexible for partial IDs)
    return cleaned.length >= 6 && cleaned.length <= 15;
  }
}
