import 'package:drift/drift.dart';

/// Beneficiaries table - متطابق مع جدول `data` في قاعدة البيانات الرئيسية
@DataClassName('Beneficiary')
class Beneficiaries extends Table {
  // Primary Key
  IntColumn get id => integer().autoIncrement()();

  // File Information
  TextColumn get fileIdNumber => text().nullable()(); // file_id_number
  TextColumn get originalFileIdFromExcel => text().nullable()(); // original_file_id_from_excel

  // Classification & Status
  IntColumn get sectionId => integer().nullable()(); // data_section_id
  IntColumn get requestStatus => integer().withDefault(const Constant(1))(); // data_request_status

  // Personal Information
  IntColumn get idNumber => integer()(); // data_id_number (الرقم الوطني)
  TextColumn get firstName => text().nullable()(); // data_first_name
  TextColumn get fatherName => text().nullable()(); // data_father_name
  TextColumn get grandFatherName => text().nullable()(); // data_grand_father_name
  TextColumn get familyName => text().nullable()(); // data_family_name
  IntColumn get relationship => integer().nullable()(); // data_relationship
  DateTimeColumn get birthDate => dateTime().nullable()(); // data_birth_date
  IntColumn get gender => integer().nullable()(); // data_gender (1=ذكر، 2=أنثى)

  // Contact Information
  IntColumn get phoneNumber => integer()(); // data_phone_number
  IntColumn get altPhoneNumber => integer()(); // data_alt_phone_number

  // Family Information
  IntColumn get numberOfIndividuals => integer().nullable()(); // data_number_of_individuals
  IntColumn get maritalStatus => integer().nullable()(); // data_marital_status
  IntColumn get numberOfMales => integer().nullable()(); // data_number_mail
  IntColumn get numberOfFemales => integer().nullable()(); // data_number_female

  // Education & Employment
  IntColumn get academicQualification => integer().nullable()(); // data_academic_qualification
  IntColumn get employmentStatusBreadwinner => integer().nullable()(); // data_employment_status_breadwinner

  // Displacement & Location
  IntColumn get displacementStatus => integer().nullable()(); // data_displacement_status
  TextColumn get addressBeforeDisplacement => text().nullable()(); // data_address_before_displacement
  TextColumn get currentAddress => text().nullable()(); // data_current_address
  IntColumn get city => integer().nullable()(); // data_city
  IntColumn get province => integer().nullable()(); // data_province

  // Health & Special Needs
  IntColumn get healthStatus => integer().nullable()(); // data_health_status
  IntColumn get numberOfIndividualsWithChronicDiseases =>
      integer().nullable()(); // data_number_of_individuals_with_chronic_diseases
  IntColumn get numberOfPeopleWithSpecialNeeds => integer().nullable()(); // data_number_of_people_with_special_needs

  // Housing
  IntColumn get housingStatus => integer().nullable()(); // data_housing_status
  IntColumn get currentHousingType => integer().nullable()(); // data_current_housing_type

  // Extended taxonomy fields (stored as canonical taxonomy code)
  TextColumn get assistanceTypeCode => text().nullable()();
  TextColumn get disabilityTypeCode => text().nullable()();
  TextColumn get incomeSourceCode => text().nullable()();
  TextColumn get guaranteeTypeCode => text().nullable()();

  // Needs & Notes
  TextColumn get descriptionNeeds => text().nullable()(); // data_description_needs

  // System Fields
  TextColumn get userInsertData => text().nullable()(); // data_user_insert_data
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Local Sync Fields
  TextColumn get syncState => text().withDefault(
        const Constant('pending'),
      )(); // 'pending', 'synced', 'failed', 'syncing'
  IntColumn get serverId => integer().nullable()(); // ID من السيرفر
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  // Computed/Helper Fields for Local Use
  TextColumn get fullName => text().generatedAs(
        firstName +
            const Constant(' ') +
            fatherName +
            const Constant(' ') +
            grandFatherName +
            const Constant(' ') +
            familyName,
        stored: true,
      )(); // حقل محسوب تلقائياً

  TextColumn get fullNameNorm => text().nullable()(); // للبحث (يتم تحديثه عبر trigger)

  @override
  List<Set<Column>> get uniqueKeys => [
        {idNumber}, // الرقم الوطني فريد
      ];
}

/// ملاحظات مهمة:
/// 1. phoneNumber و altPhoneNumber يُخزنان كـ Integer لأن Backend يستخدم bigint
/// 2. جميع الـ enums (gender, maritalStatus, etc) تُخزن كـ Integer مع الأكواد:
///    - gender: 1=ذكر، 2=أنثى
///    - maritalStatus: 1=أعزب، 2=متزوج، 3=مطلق، 4=أرمل
///    - educationLevel: 1=لا يوجد، 2=ابتدائي، 3=إعدادي، 4=ثانوي، 5=بكالوريوس، 6=ماجستير
///    - healthStatus: 1=جيد، 2=متوسط، 3=مزمن، 4=إعاقة، 5=سيء
///    - relationship: 2=أرملة
/// 3. fullName حقل محسوب تلقائياً (generated column)
/// 4. Sync fields (syncState, serverId, lastSyncedAt) للمزامنة المحلية فقط
