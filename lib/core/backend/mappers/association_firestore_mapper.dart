import '../../../features/associations/domain/entities/association.dart';
import '../../../features/associations/domain/entities/representative.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class AssociationFirestoreMapper {
  const AssociationFirestoreMapper._();

  static JsonMap toFirestore(
    Association entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
      'short_name': entity.shortName,
      'phone': entity.phone,
      'email': entity.email,
      'bank_name': entity.bankName,
      'account_number': entity.accountNumber,
      'swift_code': entity.swiftCode,
      'bank_phone': entity.bankPhone,
      'account_currency': entity.accountCurrency,
      'association_type_code': entity.associationTypeCode,
      'representative_id': entity.representativeId,
      'is_active': entity.isActive,
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        syncedAt: syncedAt,
      ),
    );
  }

  static Association fromFirestore(String associationId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;

    return Association(
      id: associationId,
      name: (doc['name'] ?? '').toString(),
      phone: (doc['phone'] ?? '').toString(),
      bankName: (doc['bank_name'] ?? '').toString(),
      accountNumber: (doc['account_number'] ?? '').toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      shortName: doc['short_name']?.toString(),
      email: doc['email']?.toString(),
      swiftCode: doc['swift_code']?.toString(),
      bankPhone: doc['bank_phone']?.toString(),
      accountCurrency: doc['account_currency']?.toString(),
      associationTypeCode: doc['association_type_code']?.toString(),
      representativeId: doc['representative_id']?.toString(),
      isActive: (doc['is_active'] as bool?) ?? true,
    );
  }
}

class RepresentativeFirestoreMapper {
  const RepresentativeFirestoreMapper._();

  static JsonMap toFirestore(
    Representative entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
    };

    return FirestoreMapperUtils.removeNulls(
      FirestoreMapperUtils.withAuditFields(
        payload,
        userId: userId,
        deviceId: deviceId,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        syncedAt: syncedAt,
      ),
    );
  }

  static Representative fromFirestore(String representativeId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;

    return Representative(
      id: representativeId,
      name: (doc['name'] ?? '').toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
