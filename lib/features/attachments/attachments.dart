// Domain Layer Exports
export 'domain/entities/attachment.dart';
export 'domain/repositories/attachment_repository.dart';
export 'domain/usecases/get_beneficiary_attachments_usecase.dart';
export 'domain/usecases/add_attachment_usecase.dart';
export 'domain/usecases/delete_attachment_usecase.dart';

// Data Layer Exports
export 'data/models/attachment_model.dart';
export 'data/datasources/attachment_datasource.dart';
export 'data/repositories/attachment_repository_impl.dart';

// Presentation Layer Exports
export 'presentation/providers/attachments_provider.dart';
export 'presentation/widgets/attachments_section_clean.dart';
