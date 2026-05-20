import '../../../features/beneficiaries/domain/entities/beneficiary.dart';
import '../remote_backend.dart';
import 'firestore_mapper_utils.dart';

class BeneficiaryFirestoreMapper {
  const BeneficiaryFirestoreMapper._();

  static JsonMap toFirestore(
    Beneficiary entity, {
    required String userId,
    required String deviceId,
    DateTime? syncedAt,
  }) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'full_name': entity.fullName,
      'national_id': entity.nationalId,
      'gender': entity.gender.englishValue,
      'category': entity.category.englishValue,
      'category_code': entity.category.code,
      'birth_date': entity.birthDate,
      'mother_name': entity.motherName,
      'father_name': entity.fatherName,
      'grand_father_name': entity.grandFatherName,
      'family_name': entity.familyName,
      'relationship': entity.relationship,
      'section_id': entity.sectionId,
      'phone_number': entity.phoneNumber,
      'alt_phone_number': entity.altPhoneNumber,
      'governorate': entity.governorate,
      'district': entity.district,
      'address': entity.address,
      'current_address': entity.currentAddress,
      'address_before_displacement': entity.addressBeforeDisplacement,
      'file_no': entity.fileNo,
      'file_id_number': entity.fileIdNumber,
      'association_name': entity.associationName,
      'marital_status': entity.maritalStatus?.name,
      'education_level': entity.educationLevel?.name,
      'health_status': entity.healthStatus.name,
      'has_disability': entity.hasDisability,
      'family_size': entity.familySize,
      'number_of_males': entity.numberOfMales,
      'number_of_females': entity.numberOfFemales,
      'chronic_diseases_count': entity.chronicDiseasesCount,
      'special_needs_count': entity.specialNeedsCount,
      'displacement_status': entity.displacementStatus?.code,
      'employment_status': entity.employmentStatus?.code,
      'housing_status': entity.housingStatus?.code,
      'housing_type': entity.housingType?.code,
      'request_status': entity.requestStatus?.code,
      'assistance_type_code': entity.assistanceTypeCode,
      'disability_type_code': entity.disabilityTypeCode,
      'income_source_code': entity.incomeSourceCode,
      'guarantee_type_code': entity.guaranteeTypeCode,
      'notes': entity.notes,
      'created_by_user': entity.createdByUser,
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

  static Beneficiary fromFirestore(String beneficiaryId, JsonMap doc) {
    final createdAt = FirestoreMapperUtils.asDateTime(doc['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = FirestoreMapperUtils.asDateTime(doc['updated_at']) ?? createdAt;

    return Beneficiary(
      id: beneficiaryId,
      fullName: (doc['full_name'] ?? '').toString(),
      nationalId: (doc['national_id'] ?? '').toString(),
      gender: Gender.fromString((doc['gender'] ?? 'unknown').toString()),
      category: BeneficiaryCategory.fromString((doc['category'] ?? 'other').toString()),
      birthDate: FirestoreMapperUtils.asDateTime(doc['birth_date']),
      motherName: doc['mother_name']?.toString(),
      fatherName: doc['father_name']?.toString(),
      grandFatherName: doc['grand_father_name']?.toString(),
      familyName: doc['family_name']?.toString(),
      relationship: doc['relationship'] as int?,
      sectionId: doc['section_id'] as int?,
      phoneNumber: doc['phone_number']?.toString(),
      altPhoneNumber: doc['alt_phone_number']?.toString(),
      governorate: doc['governorate']?.toString(),
      district: doc['district']?.toString(),
      address: doc['address']?.toString(),
      currentAddress: doc['current_address']?.toString(),
      addressBeforeDisplacement: doc['address_before_displacement']?.toString(),
      fileNo: doc['file_no']?.toString(),
      fileIdNumber: doc['file_id_number']?.toString(),
      associationName: doc['association_name']?.toString(),
      maritalStatus: _enumByName<MaritalStatus>(MaritalStatus.values, doc['marital_status']),
      educationLevel: _enumByName<EducationLevel>(EducationLevel.values, doc['education_level']),
      healthStatus: HealthStatus.fromString((doc['health_status'] ?? 'good').toString()),
      hasDisability: (doc['has_disability'] as bool?) ?? false,
      familySize: doc['family_size'] as int?,
      numberOfMales: doc['number_of_males'] as int?,
      numberOfFemales: doc['number_of_females'] as int?,
      chronicDiseasesCount: doc['chronic_diseases_count'] as int?,
      specialNeedsCount: doc['special_needs_count'] as int?,
      displacementStatus: DisplacementStatus.fromCode(doc['displacement_status'] as int?),
      employmentStatus: EmploymentStatus.fromCode(doc['employment_status'] as int?),
      housingStatus: HousingStatus.fromCode(doc['housing_status'] as int?),
      housingType: HousingType.fromCode(doc['housing_type'] as int?),
      requestStatus: RequestStatus.fromCode(doc['request_status'] as int?),
      assistanceTypeCode: doc['assistance_type_code']?.toString(),
      disabilityTypeCode: doc['disability_type_code']?.toString(),
      incomeSourceCode: doc['income_source_code']?.toString(),
      guaranteeTypeCode: doc['guarantee_type_code']?.toString(),
      notes: doc['notes']?.toString(),
      createdByUser: doc['created_by_user']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      needsSync: false,
    );
  }

  static JsonMap markDeleted(
    JsonMap localPayload, {
    required String userId,
    required String deviceId,
  }) {
    return FirestoreMapperUtils.markSoftDeleted(
      localPayload,
      userId: userId,
      deviceId: deviceId,
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString();
    for (final item in values) {
      if (item.name == value) return item;
    }
    return null;
  }
}
