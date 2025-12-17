// 🏢 Associations Feature - Clean Architecture
// Domain Layer Exports
export 'domain/entities/association.dart';
export 'domain/entities/representative.dart';
export 'domain/repositories/association_repository.dart';
export 'domain/usecases/get_all_active_associations.dart';
export 'domain/usecases/get_association_by_id.dart';
export 'domain/usecases/create_association.dart';
export 'domain/usecases/update_association.dart';
export 'domain/usecases/delete_association.dart';
export 'domain/usecases/get_all_representatives.dart';
export 'domain/usecases/create_representative.dart';
export 'domain/usecases/search_associations.dart';

// Data Layer Exports
export 'data/repositories/association_repository_impl.dart';

// Presentation Layer Exports
export 'presentation/providers/associations_provider.dart';
export 'presentation/pages/associations_list_page_v2.dart';
export 'presentation/pages/association_form_bottom_sheet.dart';
export 'presentation/widgets/association_card_v2.dart';
export 'presentation/widgets/representative_dropdown_v2.dart';
export 'presentation/widgets/associations_skeleton_loader.dart';
