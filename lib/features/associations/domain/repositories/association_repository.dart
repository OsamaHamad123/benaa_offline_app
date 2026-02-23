import '../../../../core/error_handling/result.dart';
import '../entities/association.dart';
import '../entities/representative.dart';

/// 🏢 Association Repository Interface - Domain Layer
///
/// يحدد العقد (Contract) لعمليات البيانات الخاصة بالجمعيات
abstract class AssociationRepository {
  // ============================================================================
  // ASSOCIATIONS
  // ============================================================================

  /// الحصول على جميع الجمعيات النشطة
  Future<Result<List<Association>>> getAllActiveAssociations();

  /// الحصول على جميع الجمعيات
  Future<Result<List<Association>>> getAllAssociations();

  /// الحصول على جمعية بواسطة ID
  Future<Result<Association>> getAssociationById(String id);

  /// البحث عن جمعيات
  Future<Result<List<Association>>> searchAssociations(String query);

  /// إضافة جمعية جديدة
  Future<Result<Association>> createAssociation(AssociationParams params);

  /// تحديث جمعية
  Future<Result<Association>> updateAssociation(Association association);

  /// تعطيل جمعية (Soft Delete)
  Future<Result<void>> deactivateAssociation(String id);

  /// حذف جمعية نهائياً
  Future<Result<void>> deleteAssociation(String id);

  /// عدد الجمعيات النشطة
  Future<Result<int>> getActiveAssociationsCount();

  // ============================================================================
  // REPRESENTATIVES
  // ============================================================================

  /// الحصول على جميع المندوبين
  Future<Result<List<Representative>>> getAllRepresentatives();

  /// الحصول على مندوب بواسطة ID
  Future<Result<Representative>> getRepresentativeById(String id);

  /// البحث عن مندوبين
  Future<Result<List<Representative>>> searchRepresentatives(String query);

  /// إضافة مندوب جديد
  Future<Result<Representative>> createRepresentative(String name);

  /// تحديث مندوب
  Future<Result<Representative>> updateRepresentative(Representative rep);

  /// حذف مندوب
  Future<Result<void>> deleteRepresentative(String id);
}

// ============================================================================
// PARAMS CLASSES
// ============================================================================

/// معاملات إنشاء/تحديث جمعية
class AssociationParams {
  final String? id; // null for create, populated for update
  final String name;
  final String? shortName;
  final String phone;
  final String? email;
  final String bankName;
  final String accountNumber;
  final String? swiftCode;
  final String? bankPhone;
  final String? accountCurrency;
  final String? representativeId;
  final bool isActive;

  const AssociationParams({
    required this.name, required this.phone, required this.bankName, required this.accountNumber, this.id,
    this.shortName,
    this.email,
    this.swiftCode,
    this.bankPhone,
    this.accountCurrency,
    this.representativeId,
    this.isActive = true,
  });

  /// Validation
  bool get isValid =>
      name.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      bankName.trim().isNotEmpty &&
      accountNumber.trim().isNotEmpty;

  String? get validationError {
    if (name.trim().isEmpty) return 'اسم الجمعية مطلوب';
    if (phone.trim().isEmpty) return 'رقم الهاتف مطلوب';
    if (bankName.trim().isEmpty) return 'اسم البنك مطلوب';
    if (accountNumber.trim().isEmpty) return 'رقم الحساب مطلوب';
    return null;
  }
}
