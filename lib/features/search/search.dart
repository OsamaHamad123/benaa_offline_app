/// 🔍 Search Feature - Clean Architecture
///
/// Entry point for the search feature.
/// Exports all public APIs following Clean Architecture layers.
library;

// Domain Layer - Entities
export 'domain/entities/civil_person.dart';
export 'domain/entities/search_entities.dart';

// Domain Layer - Use Cases
export 'domain/usecases/search_by_national_id.dart';
export 'domain/usecases/search_by_name.dart';
export 'domain/usecases/get_statistics.dart';

// Presentation Layer - Providers
export 'presentation/providers/search_provider.dart';
export 'presentation/providers/search_dependencies.dart';

// Presentation Layer - Pages
export 'presentation/pages/civil_search_page.dart';

// Note: Repository and Data Source are internal implementation details
// and should not be exported from the feature module.
