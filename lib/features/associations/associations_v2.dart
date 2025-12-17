/// 🏢 Associations Feature - إدارة الجمعيات
///
/// نظام كامل لإدارة الجمعيات الخارجية مع Clean Architecture
///
/// ## الاستخدام:
///
/// ### 1. إضافة المسار في الراوتر:
/// ```dart
/// GoRoute(
///   path: '/associations',
///   builder: (context, state) => const AssociationsListPageV2(),
/// ),
/// ```
///
/// ### 2. عرض القائمة:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const AssociationsListPageV2()),
/// );
/// ```
///
/// ## المميزات:
/// ✅ ResponsiveUtils - دعم كامل للموبايل والتابلت
/// ✅ Skeleton Loader - تحميل احترافي
/// ✅ بحث متقدم مع فلاتر
/// ✅ Empty State مع Animation
/// ✅ ResponsiveBottomSheet لكل النماذج
/// ✅ Theme موحد مع التطبيق
/// ✅ Clean Architecture كامل

library associations;

// Domain Layer
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

// Data Layer
export 'data/repositories/association_repository_impl.dart';

// Presentation Layer - Providers
export 'presentation/providers/associations_provider.dart';

// Presentation Layer - Pages (V2 - محسّن)
export 'presentation/pages/associations_list_page_v2.dart';
export 'presentation/pages/association_form_bottom_sheet.dart';

// Presentation Layer - Widgets (V2 - محسّن)
export 'presentation/widgets/association_card_v2.dart';
export 'presentation/widgets/representative_dropdown_v2.dart';
export 'presentation/widgets/associations_skeleton_loader.dart';
