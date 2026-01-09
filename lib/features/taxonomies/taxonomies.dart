/// 🏷️ Taxonomies Feature
///
/// ميزة إدارة التصنيفات بنمط Clean Architecture
///
/// ## الهيكل:
/// - `domain/` - الطبقة الأساسية (Entities, Repository Interface, Use Cases)
/// - `data/` - طبقة البيانات (DTOs, Datasources, Repository Impl)
/// - `presentation/` - طبقة العرض (Providers, Pages, Widgets)
///
/// ## الاستخدام:
/// ```dart
/// // استيراد الميزة
/// import 'package:benaa_offline_app/features/taxonomies/taxonomies.dart';
///
/// // استخدام الـ Provider
/// final taxonomies = ref.watch(taxonomiesByGroupProvider(TaxonomyGroup.governorate));
///
/// // استخدام الـ Widget
/// TaxonomyDropdown(
///   group: TaxonomyGroup.governorate,
///   onChanged: (taxonomy) => print(taxonomy?.label),
/// )
/// ```

// Domain Layer
export 'domain/entities/taxonomy.dart';
export 'domain/entities/taxonomy_group.dart';
export 'domain/repositories/taxonomy_repository.dart';
export 'domain/usecases/taxonomy_usecases.dart';

// Data Layer
export 'data/models/taxonomy_dto.dart';
export 'data/datasources/taxonomy_remote_datasource.dart';
export 'data/datasources/taxonomy_local_datasource.dart';
export 'data/repositories/taxonomy_repository_impl.dart';

// Presentation Layer
export 'presentation/providers/taxonomy_providers.dart';
export 'presentation/providers/taxonomy_bridge_providers.dart';
export 'presentation/widgets/taxonomy_widgets.dart';
export 'presentation/widgets/taxonomy_bridge_widgets.dart';
export 'presentation/pages/taxonomy_management_page.dart';
