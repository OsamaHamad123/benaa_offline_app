// Visits Feature Exports

// Domain
export 'domain/entities/visit_entity.dart';
export 'domain/repositories/visit_repository.dart';
export 'domain/usecases/create_visit.dart';
export 'domain/usecases/create_visit_with_activity.dart'; // 🔥 NEW
export 'domain/usecases/get_beneficiary_visits.dart';

// Data
export 'data/models/visit_model.dart';
export 'data/datasources/visit_local_datasource.dart';
export 'data/repositories/visit_repository_impl.dart';

// Presentation
export 'presentation/state/visit_state.dart';
export 'presentation/state/visit_notifier.dart';
export 'presentation/providers/visit_providers.dart';
export 'presentation/pages/record_visit_page_clean.dart';
export 'presentation/pages/record_visit_page_enhanced.dart'; // 🔥 NEW
export 'presentation/pages/visits_list_page_m3.dart'; // 🔥 NEW
