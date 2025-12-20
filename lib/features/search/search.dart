/// 🔍 Search Feature - Clean Architecture
///
/// Entry point for the search feature.
/// Exports all public APIs following Clean Architecture layers.
library;

// Domain Layer - Entities
export 'domain/entities/civil_person.dart';
export 'domain/entities/search_entities.dart';
export 'domain/entities/search_filter.dart';
export 'domain/entities/saved_filter.dart';

// Domain Layer - Use Cases
export 'domain/usecases/search_by_national_id.dart';
export 'domain/usecases/search_by_name.dart';
export 'domain/usecases/get_statistics.dart';

// Presentation Layer - Providers
export 'presentation/providers/search_provider.dart';
export 'presentation/providers/search_dependencies.dart';
export 'presentation/providers/search_filter_provider.dart';

// Presentation Layer - Pages
export 'presentation/pages/civil_search_page.dart';
export 'presentation/pages/advanced_search_demo_page.dart';

// Presentation Layer - Widgets
export 'presentation/widgets/advanced_search_bar.dart';
export 'presentation/widgets/advanced_filters_panel.dart';
export 'presentation/widgets/saved_filters_list.dart';

// Note: Repository and Data Source are internal implementation details
// and should not be exported from the feature module.
