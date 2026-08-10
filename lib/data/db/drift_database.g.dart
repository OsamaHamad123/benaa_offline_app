// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $BeneficiariesTable extends Beneficiaries
    with TableInfo<$BeneficiariesTable, Beneficiary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeneficiariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fileIdNumberMeta =
      const VerificationMeta('fileIdNumber');
  @override
  late final GeneratedColumn<String> fileIdNumber = GeneratedColumn<String>(
      'file_id_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalFileIdFromExcelMeta =
      const VerificationMeta('originalFileIdFromExcel');
  @override
  late final GeneratedColumn<String> originalFileIdFromExcel =
      GeneratedColumn<String>('original_file_id_from_excel', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
      'section_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _requestStatusMeta =
      const VerificationMeta('requestStatus');
  @override
  late final GeneratedColumn<int> requestStatus = GeneratedColumn<int>(
      'request_status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _idNumberMeta =
      const VerificationMeta('idNumber');
  @override
  late final GeneratedColumn<int> idNumber = GeneratedColumn<int>(
      'id_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fatherNameMeta =
      const VerificationMeta('fatherName');
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
      'father_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _grandFatherNameMeta =
      const VerificationMeta('grandFatherName');
  @override
  late final GeneratedColumn<String> grandFatherName = GeneratedColumn<String>(
      'grand_father_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familyNameMeta =
      const VerificationMeta('familyName');
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
      'family_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relationshipMeta =
      const VerificationMeta('relationship');
  @override
  late final GeneratedColumn<int> relationship = GeneratedColumn<int>(
      'relationship', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<int> gender = GeneratedColumn<int>(
      'gender', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<int> phoneNumber = GeneratedColumn<int>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _altPhoneNumberMeta =
      const VerificationMeta('altPhoneNumber');
  @override
  late final GeneratedColumn<int> altPhoneNumber = GeneratedColumn<int>(
      'alt_phone_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _numberOfIndividualsMeta =
      const VerificationMeta('numberOfIndividuals');
  @override
  late final GeneratedColumn<int> numberOfIndividuals = GeneratedColumn<int>(
      'number_of_individuals', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maritalStatusMeta =
      const VerificationMeta('maritalStatus');
  @override
  late final GeneratedColumn<int> maritalStatus = GeneratedColumn<int>(
      'marital_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _numberOfMalesMeta =
      const VerificationMeta('numberOfMales');
  @override
  late final GeneratedColumn<int> numberOfMales = GeneratedColumn<int>(
      'number_of_males', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _numberOfFemalesMeta =
      const VerificationMeta('numberOfFemales');
  @override
  late final GeneratedColumn<int> numberOfFemales = GeneratedColumn<int>(
      'number_of_females', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _academicQualificationMeta =
      const VerificationMeta('academicQualification');
  @override
  late final GeneratedColumn<int> academicQualification = GeneratedColumn<int>(
      'academic_qualification', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _employmentStatusBreadwinnerMeta =
      const VerificationMeta('employmentStatusBreadwinner');
  @override
  late final GeneratedColumn<int> employmentStatusBreadwinner =
      GeneratedColumn<int>('employment_status_breadwinner', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _displacementStatusMeta =
      const VerificationMeta('displacementStatus');
  @override
  late final GeneratedColumn<int> displacementStatus = GeneratedColumn<int>(
      'displacement_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _addressBeforeDisplacementMeta =
      const VerificationMeta('addressBeforeDisplacement');
  @override
  late final GeneratedColumn<String> addressBeforeDisplacement =
      GeneratedColumn<String>('address_before_displacement', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentAddressMeta =
      const VerificationMeta('currentAddress');
  @override
  late final GeneratedColumn<String> currentAddress = GeneratedColumn<String>(
      'current_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<int> city = GeneratedColumn<int>(
      'city', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _provinceMeta =
      const VerificationMeta('province');
  @override
  late final GeneratedColumn<int> province = GeneratedColumn<int>(
      'province', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _healthStatusMeta =
      const VerificationMeta('healthStatus');
  @override
  late final GeneratedColumn<int> healthStatus = GeneratedColumn<int>(
      'health_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _numberOfIndividualsWithChronicDiseasesMeta =
      const VerificationMeta('numberOfIndividualsWithChronicDiseases');
  @override
  late final GeneratedColumn<int> numberOfIndividualsWithChronicDiseases =
      GeneratedColumn<int>(
          'number_of_individuals_with_chronic_diseases', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _numberOfPeopleWithSpecialNeedsMeta =
      const VerificationMeta('numberOfPeopleWithSpecialNeeds');
  @override
  late final GeneratedColumn<int> numberOfPeopleWithSpecialNeeds =
      GeneratedColumn<int>(
          'number_of_people_with_special_needs', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _housingStatusMeta =
      const VerificationMeta('housingStatus');
  @override
  late final GeneratedColumn<int> housingStatus = GeneratedColumn<int>(
      'housing_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentHousingTypeMeta =
      const VerificationMeta('currentHousingType');
  @override
  late final GeneratedColumn<int> currentHousingType = GeneratedColumn<int>(
      'current_housing_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionNeedsMeta =
      const VerificationMeta('descriptionNeeds');
  @override
  late final GeneratedColumn<String> descriptionNeeds = GeneratedColumn<String>(
      'description_needs', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userInsertDataMeta =
      const VerificationMeta('userInsertData');
  @override
  late final GeneratedColumn<String> userInsertData = GeneratedColumn<String>(
      'user_insert_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      generatedAs: GeneratedAs(
          firstName +
              const Constant(' ') +
              fatherName +
              const Constant(' ') +
              grandFatherName +
              const Constant(' ') +
              familyName,
          true),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _fullNameNormMeta =
      const VerificationMeta('fullNameNorm');
  @override
  late final GeneratedColumn<String> fullNameNorm = GeneratedColumn<String>(
      'full_name_norm', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fileIdNumber,
        originalFileIdFromExcel,
        sectionId,
        requestStatus,
        idNumber,
        firstName,
        fatherName,
        grandFatherName,
        familyName,
        relationship,
        birthDate,
        gender,
        phoneNumber,
        altPhoneNumber,
        numberOfIndividuals,
        maritalStatus,
        numberOfMales,
        numberOfFemales,
        academicQualification,
        employmentStatusBreadwinner,
        displacementStatus,
        addressBeforeDisplacement,
        currentAddress,
        city,
        province,
        healthStatus,
        numberOfIndividualsWithChronicDiseases,
        numberOfPeopleWithSpecialNeeds,
        housingStatus,
        currentHousingType,
        descriptionNeeds,
        userInsertData,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt,
        fullName,
        fullNameNorm
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beneficiaries';
  @override
  VerificationContext validateIntegrity(Insertable<Beneficiary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_id_number')) {
      context.handle(
          _fileIdNumberMeta,
          fileIdNumber.isAcceptableOrUnknown(
              data['file_id_number']!, _fileIdNumberMeta));
    }
    if (data.containsKey('original_file_id_from_excel')) {
      context.handle(
          _originalFileIdFromExcelMeta,
          originalFileIdFromExcel.isAcceptableOrUnknown(
              data['original_file_id_from_excel']!,
              _originalFileIdFromExcelMeta));
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    }
    if (data.containsKey('request_status')) {
      context.handle(
          _requestStatusMeta,
          requestStatus.isAcceptableOrUnknown(
              data['request_status']!, _requestStatusMeta));
    }
    if (data.containsKey('id_number')) {
      context.handle(_idNumberMeta,
          idNumber.isAcceptableOrUnknown(data['id_number']!, _idNumberMeta));
    } else if (isInserting) {
      context.missing(_idNumberMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('father_name')) {
      context.handle(
          _fatherNameMeta,
          fatherName.isAcceptableOrUnknown(
              data['father_name']!, _fatherNameMeta));
    }
    if (data.containsKey('grand_father_name')) {
      context.handle(
          _grandFatherNameMeta,
          grandFatherName.isAcceptableOrUnknown(
              data['grand_father_name']!, _grandFatherNameMeta));
    }
    if (data.containsKey('family_name')) {
      context.handle(
          _familyNameMeta,
          familyName.isAcceptableOrUnknown(
              data['family_name']!, _familyNameMeta));
    }
    if (data.containsKey('relationship')) {
      context.handle(
          _relationshipMeta,
          relationship.isAcceptableOrUnknown(
              data['relationship']!, _relationshipMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('alt_phone_number')) {
      context.handle(
          _altPhoneNumberMeta,
          altPhoneNumber.isAcceptableOrUnknown(
              data['alt_phone_number']!, _altPhoneNumberMeta));
    } else if (isInserting) {
      context.missing(_altPhoneNumberMeta);
    }
    if (data.containsKey('number_of_individuals')) {
      context.handle(
          _numberOfIndividualsMeta,
          numberOfIndividuals.isAcceptableOrUnknown(
              data['number_of_individuals']!, _numberOfIndividualsMeta));
    }
    if (data.containsKey('marital_status')) {
      context.handle(
          _maritalStatusMeta,
          maritalStatus.isAcceptableOrUnknown(
              data['marital_status']!, _maritalStatusMeta));
    }
    if (data.containsKey('number_of_males')) {
      context.handle(
          _numberOfMalesMeta,
          numberOfMales.isAcceptableOrUnknown(
              data['number_of_males']!, _numberOfMalesMeta));
    }
    if (data.containsKey('number_of_females')) {
      context.handle(
          _numberOfFemalesMeta,
          numberOfFemales.isAcceptableOrUnknown(
              data['number_of_females']!, _numberOfFemalesMeta));
    }
    if (data.containsKey('academic_qualification')) {
      context.handle(
          _academicQualificationMeta,
          academicQualification.isAcceptableOrUnknown(
              data['academic_qualification']!, _academicQualificationMeta));
    }
    if (data.containsKey('employment_status_breadwinner')) {
      context.handle(
          _employmentStatusBreadwinnerMeta,
          employmentStatusBreadwinner.isAcceptableOrUnknown(
              data['employment_status_breadwinner']!,
              _employmentStatusBreadwinnerMeta));
    }
    if (data.containsKey('displacement_status')) {
      context.handle(
          _displacementStatusMeta,
          displacementStatus.isAcceptableOrUnknown(
              data['displacement_status']!, _displacementStatusMeta));
    }
    if (data.containsKey('address_before_displacement')) {
      context.handle(
          _addressBeforeDisplacementMeta,
          addressBeforeDisplacement.isAcceptableOrUnknown(
              data['address_before_displacement']!,
              _addressBeforeDisplacementMeta));
    }
    if (data.containsKey('current_address')) {
      context.handle(
          _currentAddressMeta,
          currentAddress.isAcceptableOrUnknown(
              data['current_address']!, _currentAddressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('province')) {
      context.handle(_provinceMeta,
          province.isAcceptableOrUnknown(data['province']!, _provinceMeta));
    }
    if (data.containsKey('health_status')) {
      context.handle(
          _healthStatusMeta,
          healthStatus.isAcceptableOrUnknown(
              data['health_status']!, _healthStatusMeta));
    }
    if (data.containsKey('number_of_individuals_with_chronic_diseases')) {
      context.handle(
          _numberOfIndividualsWithChronicDiseasesMeta,
          numberOfIndividualsWithChronicDiseases.isAcceptableOrUnknown(
              data['number_of_individuals_with_chronic_diseases']!,
              _numberOfIndividualsWithChronicDiseasesMeta));
    }
    if (data.containsKey('number_of_people_with_special_needs')) {
      context.handle(
          _numberOfPeopleWithSpecialNeedsMeta,
          numberOfPeopleWithSpecialNeeds.isAcceptableOrUnknown(
              data['number_of_people_with_special_needs']!,
              _numberOfPeopleWithSpecialNeedsMeta));
    }
    if (data.containsKey('housing_status')) {
      context.handle(
          _housingStatusMeta,
          housingStatus.isAcceptableOrUnknown(
              data['housing_status']!, _housingStatusMeta));
    }
    if (data.containsKey('current_housing_type')) {
      context.handle(
          _currentHousingTypeMeta,
          currentHousingType.isAcceptableOrUnknown(
              data['current_housing_type']!, _currentHousingTypeMeta));
    }
    if (data.containsKey('description_needs')) {
      context.handle(
          _descriptionNeedsMeta,
          descriptionNeeds.isAcceptableOrUnknown(
              data['description_needs']!, _descriptionNeedsMeta));
    }
    if (data.containsKey('user_insert_data')) {
      context.handle(
          _userInsertDataMeta,
          userInsertData.isAcceptableOrUnknown(
              data['user_insert_data']!, _userInsertDataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    }
    if (data.containsKey('full_name_norm')) {
      context.handle(
          _fullNameNormMeta,
          fullNameNorm.isAcceptableOrUnknown(
              data['full_name_norm']!, _fullNameNormMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {idNumber},
      ];
  @override
  Beneficiary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Beneficiary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fileIdNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_id_number']),
      originalFileIdFromExcel: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_file_id_from_excel']),
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}section_id']),
      requestStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}request_status'])!,
      idNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id_number'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      fatherName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father_name']),
      grandFatherName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}grand_father_name']),
      familyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_name']),
      relationship: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}relationship']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gender']),
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phone_number'])!,
      altPhoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}alt_phone_number'])!,
      numberOfIndividuals: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}number_of_individuals']),
      maritalStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}marital_status']),
      numberOfMales: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_of_males']),
      numberOfFemales: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_of_females']),
      academicQualification: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}academic_qualification']),
      employmentStatusBreadwinner: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}employment_status_breadwinner']),
      displacementStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}displacement_status']),
      addressBeforeDisplacement: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}address_before_displacement']),
      currentAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}current_address']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}city']),
      province: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}province']),
      healthStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}health_status']),
      numberOfIndividualsWithChronicDiseases: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data[
              '${effectivePrefix}number_of_individuals_with_chronic_diseases']),
      numberOfPeopleWithSpecialNeeds: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}number_of_people_with_special_needs']),
      housingStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}housing_status']),
      currentHousingType: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_housing_type']),
      descriptionNeeds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}description_needs']),
      userInsertData: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}user_insert_data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      fullNameNorm: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name_norm']),
    );
  }

  @override
  $BeneficiariesTable createAlias(String alias) {
    return $BeneficiariesTable(attachedDatabase, alias);
  }
}

class Beneficiary extends DataClass implements Insertable<Beneficiary> {
  final int id;
  final String? fileIdNumber;
  final String? originalFileIdFromExcel;
  final int? sectionId;
  final int requestStatus;
  final int idNumber;
  final String? firstName;
  final String? fatherName;
  final String? grandFatherName;
  final String? familyName;
  final int? relationship;
  final DateTime? birthDate;
  final int? gender;
  final int phoneNumber;
  final int altPhoneNumber;
  final int? numberOfIndividuals;
  final int? maritalStatus;
  final int? numberOfMales;
  final int? numberOfFemales;
  final int? academicQualification;
  final int? employmentStatusBreadwinner;
  final int? displacementStatus;
  final String? addressBeforeDisplacement;
  final String? currentAddress;
  final int? city;
  final int? province;
  final int? healthStatus;
  final int? numberOfIndividualsWithChronicDiseases;
  final int? numberOfPeopleWithSpecialNeeds;
  final int? housingStatus;
  final int? currentHousingType;
  final String? descriptionNeeds;
  final String? userInsertData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncState;
  final int? serverId;
  final DateTime? lastSyncedAt;
  final String fullName;
  final String? fullNameNorm;
  const Beneficiary(
      {required this.id,
      this.fileIdNumber,
      this.originalFileIdFromExcel,
      this.sectionId,
      required this.requestStatus,
      required this.idNumber,
      this.firstName,
      this.fatherName,
      this.grandFatherName,
      this.familyName,
      this.relationship,
      this.birthDate,
      this.gender,
      required this.phoneNumber,
      required this.altPhoneNumber,
      this.numberOfIndividuals,
      this.maritalStatus,
      this.numberOfMales,
      this.numberOfFemales,
      this.academicQualification,
      this.employmentStatusBreadwinner,
      this.displacementStatus,
      this.addressBeforeDisplacement,
      this.currentAddress,
      this.city,
      this.province,
      this.healthStatus,
      this.numberOfIndividualsWithChronicDiseases,
      this.numberOfPeopleWithSpecialNeeds,
      this.housingStatus,
      this.currentHousingType,
      this.descriptionNeeds,
      this.userInsertData,
      this.createdAt,
      this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt,
      required this.fullName,
      this.fullNameNorm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || fileIdNumber != null) {
      map['file_id_number'] = Variable<String>(fileIdNumber);
    }
    if (!nullToAbsent || originalFileIdFromExcel != null) {
      map['original_file_id_from_excel'] =
          Variable<String>(originalFileIdFromExcel);
    }
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<int>(sectionId);
    }
    map['request_status'] = Variable<int>(requestStatus);
    map['id_number'] = Variable<int>(idNumber);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || fatherName != null) {
      map['father_name'] = Variable<String>(fatherName);
    }
    if (!nullToAbsent || grandFatherName != null) {
      map['grand_father_name'] = Variable<String>(grandFatherName);
    }
    if (!nullToAbsent || familyName != null) {
      map['family_name'] = Variable<String>(familyName);
    }
    if (!nullToAbsent || relationship != null) {
      map['relationship'] = Variable<int>(relationship);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<int>(gender);
    }
    map['phone_number'] = Variable<int>(phoneNumber);
    map['alt_phone_number'] = Variable<int>(altPhoneNumber);
    if (!nullToAbsent || numberOfIndividuals != null) {
      map['number_of_individuals'] = Variable<int>(numberOfIndividuals);
    }
    if (!nullToAbsent || maritalStatus != null) {
      map['marital_status'] = Variable<int>(maritalStatus);
    }
    if (!nullToAbsent || numberOfMales != null) {
      map['number_of_males'] = Variable<int>(numberOfMales);
    }
    if (!nullToAbsent || numberOfFemales != null) {
      map['number_of_females'] = Variable<int>(numberOfFemales);
    }
    if (!nullToAbsent || academicQualification != null) {
      map['academic_qualification'] = Variable<int>(academicQualification);
    }
    if (!nullToAbsent || employmentStatusBreadwinner != null) {
      map['employment_status_breadwinner'] =
          Variable<int>(employmentStatusBreadwinner);
    }
    if (!nullToAbsent || displacementStatus != null) {
      map['displacement_status'] = Variable<int>(displacementStatus);
    }
    if (!nullToAbsent || addressBeforeDisplacement != null) {
      map['address_before_displacement'] =
          Variable<String>(addressBeforeDisplacement);
    }
    if (!nullToAbsent || currentAddress != null) {
      map['current_address'] = Variable<String>(currentAddress);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<int>(city);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<int>(province);
    }
    if (!nullToAbsent || healthStatus != null) {
      map['health_status'] = Variable<int>(healthStatus);
    }
    if (!nullToAbsent || numberOfIndividualsWithChronicDiseases != null) {
      map['number_of_individuals_with_chronic_diseases'] =
          Variable<int>(numberOfIndividualsWithChronicDiseases);
    }
    if (!nullToAbsent || numberOfPeopleWithSpecialNeeds != null) {
      map['number_of_people_with_special_needs'] =
          Variable<int>(numberOfPeopleWithSpecialNeeds);
    }
    if (!nullToAbsent || housingStatus != null) {
      map['housing_status'] = Variable<int>(housingStatus);
    }
    if (!nullToAbsent || currentHousingType != null) {
      map['current_housing_type'] = Variable<int>(currentHousingType);
    }
    if (!nullToAbsent || descriptionNeeds != null) {
      map['description_needs'] = Variable<String>(descriptionNeeds);
    }
    if (!nullToAbsent || userInsertData != null) {
      map['user_insert_data'] = Variable<String>(userInsertData);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || fullNameNorm != null) {
      map['full_name_norm'] = Variable<String>(fullNameNorm);
    }
    return map;
  }

  BeneficiariesCompanion toCompanion(bool nullToAbsent) {
    return BeneficiariesCompanion(
      id: Value(id),
      fileIdNumber: fileIdNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(fileIdNumber),
      originalFileIdFromExcel: originalFileIdFromExcel == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFileIdFromExcel),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      requestStatus: Value(requestStatus),
      idNumber: Value(idNumber),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      fatherName: fatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherName),
      grandFatherName: grandFatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(grandFatherName),
      familyName: familyName == null && nullToAbsent
          ? const Value.absent()
          : Value(familyName),
      relationship: relationship == null && nullToAbsent
          ? const Value.absent()
          : Value(relationship),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      phoneNumber: Value(phoneNumber),
      altPhoneNumber: Value(altPhoneNumber),
      numberOfIndividuals: numberOfIndividuals == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfIndividuals),
      maritalStatus: maritalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(maritalStatus),
      numberOfMales: numberOfMales == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfMales),
      numberOfFemales: numberOfFemales == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfFemales),
      academicQualification: academicQualification == null && nullToAbsent
          ? const Value.absent()
          : Value(academicQualification),
      employmentStatusBreadwinner:
          employmentStatusBreadwinner == null && nullToAbsent
              ? const Value.absent()
              : Value(employmentStatusBreadwinner),
      displacementStatus: displacementStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(displacementStatus),
      addressBeforeDisplacement:
          addressBeforeDisplacement == null && nullToAbsent
              ? const Value.absent()
              : Value(addressBeforeDisplacement),
      currentAddress: currentAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(currentAddress),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      healthStatus: healthStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(healthStatus),
      numberOfIndividualsWithChronicDiseases:
          numberOfIndividualsWithChronicDiseases == null && nullToAbsent
              ? const Value.absent()
              : Value(numberOfIndividualsWithChronicDiseases),
      numberOfPeopleWithSpecialNeeds:
          numberOfPeopleWithSpecialNeeds == null && nullToAbsent
              ? const Value.absent()
              : Value(numberOfPeopleWithSpecialNeeds),
      housingStatus: housingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(housingStatus),
      currentHousingType: currentHousingType == null && nullToAbsent
          ? const Value.absent()
          : Value(currentHousingType),
      descriptionNeeds: descriptionNeeds == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionNeeds),
      userInsertData: userInsertData == null && nullToAbsent
          ? const Value.absent()
          : Value(userInsertData),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      fullNameNorm: fullNameNorm == null && nullToAbsent
          ? const Value.absent()
          : Value(fullNameNorm),
    );
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Beneficiary(
      id: serializer.fromJson<int>(json['id']),
      fileIdNumber: serializer.fromJson<String?>(json['fileIdNumber']),
      originalFileIdFromExcel:
          serializer.fromJson<String?>(json['originalFileIdFromExcel']),
      sectionId: serializer.fromJson<int?>(json['sectionId']),
      requestStatus: serializer.fromJson<int>(json['requestStatus']),
      idNumber: serializer.fromJson<int>(json['idNumber']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      fatherName: serializer.fromJson<String?>(json['fatherName']),
      grandFatherName: serializer.fromJson<String?>(json['grandFatherName']),
      familyName: serializer.fromJson<String?>(json['familyName']),
      relationship: serializer.fromJson<int?>(json['relationship']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: serializer.fromJson<int?>(json['gender']),
      phoneNumber: serializer.fromJson<int>(json['phoneNumber']),
      altPhoneNumber: serializer.fromJson<int>(json['altPhoneNumber']),
      numberOfIndividuals:
          serializer.fromJson<int?>(json['numberOfIndividuals']),
      maritalStatus: serializer.fromJson<int?>(json['maritalStatus']),
      numberOfMales: serializer.fromJson<int?>(json['numberOfMales']),
      numberOfFemales: serializer.fromJson<int?>(json['numberOfFemales']),
      academicQualification:
          serializer.fromJson<int?>(json['academicQualification']),
      employmentStatusBreadwinner:
          serializer.fromJson<int?>(json['employmentStatusBreadwinner']),
      displacementStatus: serializer.fromJson<int?>(json['displacementStatus']),
      addressBeforeDisplacement:
          serializer.fromJson<String?>(json['addressBeforeDisplacement']),
      currentAddress: serializer.fromJson<String?>(json['currentAddress']),
      city: serializer.fromJson<int?>(json['city']),
      province: serializer.fromJson<int?>(json['province']),
      healthStatus: serializer.fromJson<int?>(json['healthStatus']),
      numberOfIndividualsWithChronicDiseases: serializer
          .fromJson<int?>(json['numberOfIndividualsWithChronicDiseases']),
      numberOfPeopleWithSpecialNeeds:
          serializer.fromJson<int?>(json['numberOfPeopleWithSpecialNeeds']),
      housingStatus: serializer.fromJson<int?>(json['housingStatus']),
      currentHousingType: serializer.fromJson<int?>(json['currentHousingType']),
      descriptionNeeds: serializer.fromJson<String?>(json['descriptionNeeds']),
      userInsertData: serializer.fromJson<String?>(json['userInsertData']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      fullName: serializer.fromJson<String>(json['fullName']),
      fullNameNorm: serializer.fromJson<String?>(json['fullNameNorm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fileIdNumber': serializer.toJson<String?>(fileIdNumber),
      'originalFileIdFromExcel':
          serializer.toJson<String?>(originalFileIdFromExcel),
      'sectionId': serializer.toJson<int?>(sectionId),
      'requestStatus': serializer.toJson<int>(requestStatus),
      'idNumber': serializer.toJson<int>(idNumber),
      'firstName': serializer.toJson<String?>(firstName),
      'fatherName': serializer.toJson<String?>(fatherName),
      'grandFatherName': serializer.toJson<String?>(grandFatherName),
      'familyName': serializer.toJson<String?>(familyName),
      'relationship': serializer.toJson<int?>(relationship),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<int?>(gender),
      'phoneNumber': serializer.toJson<int>(phoneNumber),
      'altPhoneNumber': serializer.toJson<int>(altPhoneNumber),
      'numberOfIndividuals': serializer.toJson<int?>(numberOfIndividuals),
      'maritalStatus': serializer.toJson<int?>(maritalStatus),
      'numberOfMales': serializer.toJson<int?>(numberOfMales),
      'numberOfFemales': serializer.toJson<int?>(numberOfFemales),
      'academicQualification': serializer.toJson<int?>(academicQualification),
      'employmentStatusBreadwinner':
          serializer.toJson<int?>(employmentStatusBreadwinner),
      'displacementStatus': serializer.toJson<int?>(displacementStatus),
      'addressBeforeDisplacement':
          serializer.toJson<String?>(addressBeforeDisplacement),
      'currentAddress': serializer.toJson<String?>(currentAddress),
      'city': serializer.toJson<int?>(city),
      'province': serializer.toJson<int?>(province),
      'healthStatus': serializer.toJson<int?>(healthStatus),
      'numberOfIndividualsWithChronicDiseases':
          serializer.toJson<int?>(numberOfIndividualsWithChronicDiseases),
      'numberOfPeopleWithSpecialNeeds':
          serializer.toJson<int?>(numberOfPeopleWithSpecialNeeds),
      'housingStatus': serializer.toJson<int?>(housingStatus),
      'currentHousingType': serializer.toJson<int?>(currentHousingType),
      'descriptionNeeds': serializer.toJson<String?>(descriptionNeeds),
      'userInsertData': serializer.toJson<String?>(userInsertData),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'fullName': serializer.toJson<String>(fullName),
      'fullNameNorm': serializer.toJson<String?>(fullNameNorm),
    };
  }

  Beneficiary copyWith(
          {int? id,
          Value<String?> fileIdNumber = const Value.absent(),
          Value<String?> originalFileIdFromExcel = const Value.absent(),
          Value<int?> sectionId = const Value.absent(),
          int? requestStatus,
          int? idNumber,
          Value<String?> firstName = const Value.absent(),
          Value<String?> fatherName = const Value.absent(),
          Value<String?> grandFatherName = const Value.absent(),
          Value<String?> familyName = const Value.absent(),
          Value<int?> relationship = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<int?> gender = const Value.absent(),
          int? phoneNumber,
          int? altPhoneNumber,
          Value<int?> numberOfIndividuals = const Value.absent(),
          Value<int?> maritalStatus = const Value.absent(),
          Value<int?> numberOfMales = const Value.absent(),
          Value<int?> numberOfFemales = const Value.absent(),
          Value<int?> academicQualification = const Value.absent(),
          Value<int?> employmentStatusBreadwinner = const Value.absent(),
          Value<int?> displacementStatus = const Value.absent(),
          Value<String?> addressBeforeDisplacement = const Value.absent(),
          Value<String?> currentAddress = const Value.absent(),
          Value<int?> city = const Value.absent(),
          Value<int?> province = const Value.absent(),
          Value<int?> healthStatus = const Value.absent(),
          Value<int?> numberOfIndividualsWithChronicDiseases =
              const Value.absent(),
          Value<int?> numberOfPeopleWithSpecialNeeds = const Value.absent(),
          Value<int?> housingStatus = const Value.absent(),
          Value<int?> currentHousingType = const Value.absent(),
          Value<String?> descriptionNeeds = const Value.absent(),
          Value<String?> userInsertData = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          String? syncState,
          Value<int?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          String? fullName,
          Value<String?> fullNameNorm = const Value.absent()}) =>
      Beneficiary(
        id: id ?? this.id,
        fileIdNumber:
            fileIdNumber.present ? fileIdNumber.value : this.fileIdNumber,
        originalFileIdFromExcel: originalFileIdFromExcel.present
            ? originalFileIdFromExcel.value
            : this.originalFileIdFromExcel,
        sectionId: sectionId.present ? sectionId.value : this.sectionId,
        requestStatus: requestStatus ?? this.requestStatus,
        idNumber: idNumber ?? this.idNumber,
        firstName: firstName.present ? firstName.value : this.firstName,
        fatherName: fatherName.present ? fatherName.value : this.fatherName,
        grandFatherName: grandFatherName.present
            ? grandFatherName.value
            : this.grandFatherName,
        familyName: familyName.present ? familyName.value : this.familyName,
        relationship:
            relationship.present ? relationship.value : this.relationship,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        gender: gender.present ? gender.value : this.gender,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
        numberOfIndividuals: numberOfIndividuals.present
            ? numberOfIndividuals.value
            : this.numberOfIndividuals,
        maritalStatus:
            maritalStatus.present ? maritalStatus.value : this.maritalStatus,
        numberOfMales:
            numberOfMales.present ? numberOfMales.value : this.numberOfMales,
        numberOfFemales: numberOfFemales.present
            ? numberOfFemales.value
            : this.numberOfFemales,
        academicQualification: academicQualification.present
            ? academicQualification.value
            : this.academicQualification,
        employmentStatusBreadwinner: employmentStatusBreadwinner.present
            ? employmentStatusBreadwinner.value
            : this.employmentStatusBreadwinner,
        displacementStatus: displacementStatus.present
            ? displacementStatus.value
            : this.displacementStatus,
        addressBeforeDisplacement: addressBeforeDisplacement.present
            ? addressBeforeDisplacement.value
            : this.addressBeforeDisplacement,
        currentAddress:
            currentAddress.present ? currentAddress.value : this.currentAddress,
        city: city.present ? city.value : this.city,
        province: province.present ? province.value : this.province,
        healthStatus:
            healthStatus.present ? healthStatus.value : this.healthStatus,
        numberOfIndividualsWithChronicDiseases:
            numberOfIndividualsWithChronicDiseases.present
                ? numberOfIndividualsWithChronicDiseases.value
                : this.numberOfIndividualsWithChronicDiseases,
        numberOfPeopleWithSpecialNeeds: numberOfPeopleWithSpecialNeeds.present
            ? numberOfPeopleWithSpecialNeeds.value
            : this.numberOfPeopleWithSpecialNeeds,
        housingStatus:
            housingStatus.present ? housingStatus.value : this.housingStatus,
        currentHousingType: currentHousingType.present
            ? currentHousingType.value
            : this.currentHousingType,
        descriptionNeeds: descriptionNeeds.present
            ? descriptionNeeds.value
            : this.descriptionNeeds,
        userInsertData:
            userInsertData.present ? userInsertData.value : this.userInsertData,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        fullName: fullName ?? this.fullName,
        fullNameNorm:
            fullNameNorm.present ? fullNameNorm.value : this.fullNameNorm,
      );
  @override
  String toString() {
    return (StringBuffer('Beneficiary(')
          ..write('id: $id, ')
          ..write('fileIdNumber: $fileIdNumber, ')
          ..write('originalFileIdFromExcel: $originalFileIdFromExcel, ')
          ..write('sectionId: $sectionId, ')
          ..write('requestStatus: $requestStatus, ')
          ..write('idNumber: $idNumber, ')
          ..write('firstName: $firstName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('relationship: $relationship, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('altPhoneNumber: $altPhoneNumber, ')
          ..write('numberOfIndividuals: $numberOfIndividuals, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('numberOfMales: $numberOfMales, ')
          ..write('numberOfFemales: $numberOfFemales, ')
          ..write('academicQualification: $academicQualification, ')
          ..write('employmentStatusBreadwinner: $employmentStatusBreadwinner, ')
          ..write('displacementStatus: $displacementStatus, ')
          ..write('addressBeforeDisplacement: $addressBeforeDisplacement, ')
          ..write('currentAddress: $currentAddress, ')
          ..write('city: $city, ')
          ..write('province: $province, ')
          ..write('healthStatus: $healthStatus, ')
          ..write(
              'numberOfIndividualsWithChronicDiseases: $numberOfIndividualsWithChronicDiseases, ')
          ..write(
              'numberOfPeopleWithSpecialNeeds: $numberOfPeopleWithSpecialNeeds, ')
          ..write('housingStatus: $housingStatus, ')
          ..write('currentHousingType: $currentHousingType, ')
          ..write('descriptionNeeds: $descriptionNeeds, ')
          ..write('userInsertData: $userInsertData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNorm: $fullNameNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        fileIdNumber,
        originalFileIdFromExcel,
        sectionId,
        requestStatus,
        idNumber,
        firstName,
        fatherName,
        grandFatherName,
        familyName,
        relationship,
        birthDate,
        gender,
        phoneNumber,
        altPhoneNumber,
        numberOfIndividuals,
        maritalStatus,
        numberOfMales,
        numberOfFemales,
        academicQualification,
        employmentStatusBreadwinner,
        displacementStatus,
        addressBeforeDisplacement,
        currentAddress,
        city,
        province,
        healthStatus,
        numberOfIndividualsWithChronicDiseases,
        numberOfPeopleWithSpecialNeeds,
        housingStatus,
        currentHousingType,
        descriptionNeeds,
        userInsertData,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt,
        fullName,
        fullNameNorm
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Beneficiary &&
          other.id == this.id &&
          other.fileIdNumber == this.fileIdNumber &&
          other.originalFileIdFromExcel == this.originalFileIdFromExcel &&
          other.sectionId == this.sectionId &&
          other.requestStatus == this.requestStatus &&
          other.idNumber == this.idNumber &&
          other.firstName == this.firstName &&
          other.fatherName == this.fatherName &&
          other.grandFatherName == this.grandFatherName &&
          other.familyName == this.familyName &&
          other.relationship == this.relationship &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender &&
          other.phoneNumber == this.phoneNumber &&
          other.altPhoneNumber == this.altPhoneNumber &&
          other.numberOfIndividuals == this.numberOfIndividuals &&
          other.maritalStatus == this.maritalStatus &&
          other.numberOfMales == this.numberOfMales &&
          other.numberOfFemales == this.numberOfFemales &&
          other.academicQualification == this.academicQualification &&
          other.employmentStatusBreadwinner ==
              this.employmentStatusBreadwinner &&
          other.displacementStatus == this.displacementStatus &&
          other.addressBeforeDisplacement == this.addressBeforeDisplacement &&
          other.currentAddress == this.currentAddress &&
          other.city == this.city &&
          other.province == this.province &&
          other.healthStatus == this.healthStatus &&
          other.numberOfIndividualsWithChronicDiseases ==
              this.numberOfIndividualsWithChronicDiseases &&
          other.numberOfPeopleWithSpecialNeeds ==
              this.numberOfPeopleWithSpecialNeeds &&
          other.housingStatus == this.housingStatus &&
          other.currentHousingType == this.currentHousingType &&
          other.descriptionNeeds == this.descriptionNeeds &&
          other.userInsertData == this.userInsertData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.fullName == this.fullName &&
          other.fullNameNorm == this.fullNameNorm);
}

class BeneficiariesCompanion extends UpdateCompanion<Beneficiary> {
  final Value<int> id;
  final Value<String?> fileIdNumber;
  final Value<String?> originalFileIdFromExcel;
  final Value<int?> sectionId;
  final Value<int> requestStatus;
  final Value<int> idNumber;
  final Value<String?> firstName;
  final Value<String?> fatherName;
  final Value<String?> grandFatherName;
  final Value<String?> familyName;
  final Value<int?> relationship;
  final Value<DateTime?> birthDate;
  final Value<int?> gender;
  final Value<int> phoneNumber;
  final Value<int> altPhoneNumber;
  final Value<int?> numberOfIndividuals;
  final Value<int?> maritalStatus;
  final Value<int?> numberOfMales;
  final Value<int?> numberOfFemales;
  final Value<int?> academicQualification;
  final Value<int?> employmentStatusBreadwinner;
  final Value<int?> displacementStatus;
  final Value<String?> addressBeforeDisplacement;
  final Value<String?> currentAddress;
  final Value<int?> city;
  final Value<int?> province;
  final Value<int?> healthStatus;
  final Value<int?> numberOfIndividualsWithChronicDiseases;
  final Value<int?> numberOfPeopleWithSpecialNeeds;
  final Value<int?> housingStatus;
  final Value<int?> currentHousingType;
  final Value<String?> descriptionNeeds;
  final Value<String?> userInsertData;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> fullNameNorm;
  const BeneficiariesCompanion({
    this.id = const Value.absent(),
    this.fileIdNumber = const Value.absent(),
    this.originalFileIdFromExcel = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.requestStatus = const Value.absent(),
    this.idNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.altPhoneNumber = const Value.absent(),
    this.numberOfIndividuals = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.numberOfMales = const Value.absent(),
    this.numberOfFemales = const Value.absent(),
    this.academicQualification = const Value.absent(),
    this.employmentStatusBreadwinner = const Value.absent(),
    this.displacementStatus = const Value.absent(),
    this.addressBeforeDisplacement = const Value.absent(),
    this.currentAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.province = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.numberOfIndividualsWithChronicDiseases = const Value.absent(),
    this.numberOfPeopleWithSpecialNeeds = const Value.absent(),
    this.housingStatus = const Value.absent(),
    this.currentHousingType = const Value.absent(),
    this.descriptionNeeds = const Value.absent(),
    this.userInsertData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.fullNameNorm = const Value.absent(),
  });
  BeneficiariesCompanion.insert({
    this.id = const Value.absent(),
    this.fileIdNumber = const Value.absent(),
    this.originalFileIdFromExcel = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.requestStatus = const Value.absent(),
    required int idNumber,
    this.firstName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
    required int phoneNumber,
    required int altPhoneNumber,
    this.numberOfIndividuals = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.numberOfMales = const Value.absent(),
    this.numberOfFemales = const Value.absent(),
    this.academicQualification = const Value.absent(),
    this.employmentStatusBreadwinner = const Value.absent(),
    this.displacementStatus = const Value.absent(),
    this.addressBeforeDisplacement = const Value.absent(),
    this.currentAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.province = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.numberOfIndividualsWithChronicDiseases = const Value.absent(),
    this.numberOfPeopleWithSpecialNeeds = const Value.absent(),
    this.housingStatus = const Value.absent(),
    this.currentHousingType = const Value.absent(),
    this.descriptionNeeds = const Value.absent(),
    this.userInsertData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.fullNameNorm = const Value.absent(),
  })  : idNumber = Value(idNumber),
        phoneNumber = Value(phoneNumber),
        altPhoneNumber = Value(altPhoneNumber);
  static Insertable<Beneficiary> custom({
    Expression<int>? id,
    Expression<String>? fileIdNumber,
    Expression<String>? originalFileIdFromExcel,
    Expression<int>? sectionId,
    Expression<int>? requestStatus,
    Expression<int>? idNumber,
    Expression<String>? firstName,
    Expression<String>? fatherName,
    Expression<String>? grandFatherName,
    Expression<String>? familyName,
    Expression<int>? relationship,
    Expression<DateTime>? birthDate,
    Expression<int>? gender,
    Expression<int>? phoneNumber,
    Expression<int>? altPhoneNumber,
    Expression<int>? numberOfIndividuals,
    Expression<int>? maritalStatus,
    Expression<int>? numberOfMales,
    Expression<int>? numberOfFemales,
    Expression<int>? academicQualification,
    Expression<int>? employmentStatusBreadwinner,
    Expression<int>? displacementStatus,
    Expression<String>? addressBeforeDisplacement,
    Expression<String>? currentAddress,
    Expression<int>? city,
    Expression<int>? province,
    Expression<int>? healthStatus,
    Expression<int>? numberOfIndividualsWithChronicDiseases,
    Expression<int>? numberOfPeopleWithSpecialNeeds,
    Expression<int>? housingStatus,
    Expression<int>? currentHousingType,
    Expression<String>? descriptionNeeds,
    Expression<String>? userInsertData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? fullNameNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileIdNumber != null) 'file_id_number': fileIdNumber,
      if (originalFileIdFromExcel != null)
        'original_file_id_from_excel': originalFileIdFromExcel,
      if (sectionId != null) 'section_id': sectionId,
      if (requestStatus != null) 'request_status': requestStatus,
      if (idNumber != null) 'id_number': idNumber,
      if (firstName != null) 'first_name': firstName,
      if (fatherName != null) 'father_name': fatherName,
      if (grandFatherName != null) 'grand_father_name': grandFatherName,
      if (familyName != null) 'family_name': familyName,
      if (relationship != null) 'relationship': relationship,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (altPhoneNumber != null) 'alt_phone_number': altPhoneNumber,
      if (numberOfIndividuals != null)
        'number_of_individuals': numberOfIndividuals,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (numberOfMales != null) 'number_of_males': numberOfMales,
      if (numberOfFemales != null) 'number_of_females': numberOfFemales,
      if (academicQualification != null)
        'academic_qualification': academicQualification,
      if (employmentStatusBreadwinner != null)
        'employment_status_breadwinner': employmentStatusBreadwinner,
      if (displacementStatus != null) 'displacement_status': displacementStatus,
      if (addressBeforeDisplacement != null)
        'address_before_displacement': addressBeforeDisplacement,
      if (currentAddress != null) 'current_address': currentAddress,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      if (healthStatus != null) 'health_status': healthStatus,
      if (numberOfIndividualsWithChronicDiseases != null)
        'number_of_individuals_with_chronic_diseases':
            numberOfIndividualsWithChronicDiseases,
      if (numberOfPeopleWithSpecialNeeds != null)
        'number_of_people_with_special_needs': numberOfPeopleWithSpecialNeeds,
      if (housingStatus != null) 'housing_status': housingStatus,
      if (currentHousingType != null)
        'current_housing_type': currentHousingType,
      if (descriptionNeeds != null) 'description_needs': descriptionNeeds,
      if (userInsertData != null) 'user_insert_data': userInsertData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (fullNameNorm != null) 'full_name_norm': fullNameNorm,
    });
  }

  BeneficiariesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? fileIdNumber,
      Value<String?>? originalFileIdFromExcel,
      Value<int?>? sectionId,
      Value<int>? requestStatus,
      Value<int>? idNumber,
      Value<String?>? firstName,
      Value<String?>? fatherName,
      Value<String?>? grandFatherName,
      Value<String?>? familyName,
      Value<int?>? relationship,
      Value<DateTime?>? birthDate,
      Value<int?>? gender,
      Value<int>? phoneNumber,
      Value<int>? altPhoneNumber,
      Value<int?>? numberOfIndividuals,
      Value<int?>? maritalStatus,
      Value<int?>? numberOfMales,
      Value<int?>? numberOfFemales,
      Value<int?>? academicQualification,
      Value<int?>? employmentStatusBreadwinner,
      Value<int?>? displacementStatus,
      Value<String?>? addressBeforeDisplacement,
      Value<String?>? currentAddress,
      Value<int?>? city,
      Value<int?>? province,
      Value<int?>? healthStatus,
      Value<int?>? numberOfIndividualsWithChronicDiseases,
      Value<int?>? numberOfPeopleWithSpecialNeeds,
      Value<int?>? housingStatus,
      Value<int?>? currentHousingType,
      Value<String?>? descriptionNeeds,
      Value<String?>? userInsertData,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<String?>? fullNameNorm}) {
    return BeneficiariesCompanion(
      id: id ?? this.id,
      fileIdNumber: fileIdNumber ?? this.fileIdNumber,
      originalFileIdFromExcel:
          originalFileIdFromExcel ?? this.originalFileIdFromExcel,
      sectionId: sectionId ?? this.sectionId,
      requestStatus: requestStatus ?? this.requestStatus,
      idNumber: idNumber ?? this.idNumber,
      firstName: firstName ?? this.firstName,
      fatherName: fatherName ?? this.fatherName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      familyName: familyName ?? this.familyName,
      relationship: relationship ?? this.relationship,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      numberOfIndividuals: numberOfIndividuals ?? this.numberOfIndividuals,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      numberOfMales: numberOfMales ?? this.numberOfMales,
      numberOfFemales: numberOfFemales ?? this.numberOfFemales,
      academicQualification:
          academicQualification ?? this.academicQualification,
      employmentStatusBreadwinner:
          employmentStatusBreadwinner ?? this.employmentStatusBreadwinner,
      displacementStatus: displacementStatus ?? this.displacementStatus,
      addressBeforeDisplacement:
          addressBeforeDisplacement ?? this.addressBeforeDisplacement,
      currentAddress: currentAddress ?? this.currentAddress,
      city: city ?? this.city,
      province: province ?? this.province,
      healthStatus: healthStatus ?? this.healthStatus,
      numberOfIndividualsWithChronicDiseases:
          numberOfIndividualsWithChronicDiseases ??
              this.numberOfIndividualsWithChronicDiseases,
      numberOfPeopleWithSpecialNeeds:
          numberOfPeopleWithSpecialNeeds ?? this.numberOfPeopleWithSpecialNeeds,
      housingStatus: housingStatus ?? this.housingStatus,
      currentHousingType: currentHousingType ?? this.currentHousingType,
      descriptionNeeds: descriptionNeeds ?? this.descriptionNeeds,
      userInsertData: userInsertData ?? this.userInsertData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      fullNameNorm: fullNameNorm ?? this.fullNameNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fileIdNumber.present) {
      map['file_id_number'] = Variable<String>(fileIdNumber.value);
    }
    if (originalFileIdFromExcel.present) {
      map['original_file_id_from_excel'] =
          Variable<String>(originalFileIdFromExcel.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (requestStatus.present) {
      map['request_status'] = Variable<int>(requestStatus.value);
    }
    if (idNumber.present) {
      map['id_number'] = Variable<int>(idNumber.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (grandFatherName.present) {
      map['grand_father_name'] = Variable<String>(grandFatherName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<int>(relationship.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(gender.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<int>(phoneNumber.value);
    }
    if (altPhoneNumber.present) {
      map['alt_phone_number'] = Variable<int>(altPhoneNumber.value);
    }
    if (numberOfIndividuals.present) {
      map['number_of_individuals'] = Variable<int>(numberOfIndividuals.value);
    }
    if (maritalStatus.present) {
      map['marital_status'] = Variable<int>(maritalStatus.value);
    }
    if (numberOfMales.present) {
      map['number_of_males'] = Variable<int>(numberOfMales.value);
    }
    if (numberOfFemales.present) {
      map['number_of_females'] = Variable<int>(numberOfFemales.value);
    }
    if (academicQualification.present) {
      map['academic_qualification'] =
          Variable<int>(academicQualification.value);
    }
    if (employmentStatusBreadwinner.present) {
      map['employment_status_breadwinner'] =
          Variable<int>(employmentStatusBreadwinner.value);
    }
    if (displacementStatus.present) {
      map['displacement_status'] = Variable<int>(displacementStatus.value);
    }
    if (addressBeforeDisplacement.present) {
      map['address_before_displacement'] =
          Variable<String>(addressBeforeDisplacement.value);
    }
    if (currentAddress.present) {
      map['current_address'] = Variable<String>(currentAddress.value);
    }
    if (city.present) {
      map['city'] = Variable<int>(city.value);
    }
    if (province.present) {
      map['province'] = Variable<int>(province.value);
    }
    if (healthStatus.present) {
      map['health_status'] = Variable<int>(healthStatus.value);
    }
    if (numberOfIndividualsWithChronicDiseases.present) {
      map['number_of_individuals_with_chronic_diseases'] =
          Variable<int>(numberOfIndividualsWithChronicDiseases.value);
    }
    if (numberOfPeopleWithSpecialNeeds.present) {
      map['number_of_people_with_special_needs'] =
          Variable<int>(numberOfPeopleWithSpecialNeeds.value);
    }
    if (housingStatus.present) {
      map['housing_status'] = Variable<int>(housingStatus.value);
    }
    if (currentHousingType.present) {
      map['current_housing_type'] = Variable<int>(currentHousingType.value);
    }
    if (descriptionNeeds.present) {
      map['description_needs'] = Variable<String>(descriptionNeeds.value);
    }
    if (userInsertData.present) {
      map['user_insert_data'] = Variable<String>(userInsertData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (fullNameNorm.present) {
      map['full_name_norm'] = Variable<String>(fullNameNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeneficiariesCompanion(')
          ..write('id: $id, ')
          ..write('fileIdNumber: $fileIdNumber, ')
          ..write('originalFileIdFromExcel: $originalFileIdFromExcel, ')
          ..write('sectionId: $sectionId, ')
          ..write('requestStatus: $requestStatus, ')
          ..write('idNumber: $idNumber, ')
          ..write('firstName: $firstName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('relationship: $relationship, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('altPhoneNumber: $altPhoneNumber, ')
          ..write('numberOfIndividuals: $numberOfIndividuals, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('numberOfMales: $numberOfMales, ')
          ..write('numberOfFemales: $numberOfFemales, ')
          ..write('academicQualification: $academicQualification, ')
          ..write('employmentStatusBreadwinner: $employmentStatusBreadwinner, ')
          ..write('displacementStatus: $displacementStatus, ')
          ..write('addressBeforeDisplacement: $addressBeforeDisplacement, ')
          ..write('currentAddress: $currentAddress, ')
          ..write('city: $city, ')
          ..write('province: $province, ')
          ..write('healthStatus: $healthStatus, ')
          ..write(
              'numberOfIndividualsWithChronicDiseases: $numberOfIndividualsWithChronicDiseases, ')
          ..write(
              'numberOfPeopleWithSpecialNeeds: $numberOfPeopleWithSpecialNeeds, ')
          ..write('housingStatus: $housingStatus, ')
          ..write('currentHousingType: $currentHousingType, ')
          ..write('descriptionNeeds: $descriptionNeeds, ')
          ..write('userInsertData: $userInsertData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('fullNameNorm: $fullNameNorm')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _visitDateMeta =
      const VerificationMeta('visitDate');
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
      'visit_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _staffNameMeta =
      const VerificationMeta('staffName');
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
      'staff_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isSubmittedMeta =
      const VerificationMeta('isSubmitted');
  @override
  late final GeneratedColumn<bool> isSubmitted = GeneratedColumn<bool>(
      'is_submitted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_submitted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        visitDate,
        staffName,
        notes,
        isSubmitted,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(Insertable<Visit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(_visitDateMeta,
          visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta));
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(_staffNameMeta,
          staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta));
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_submitted')) {
      context.handle(
          _isSubmittedMeta,
          isSubmitted.isAcceptableOrUnknown(
              data['is_submitted']!, _isSubmittedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id'])!,
      visitDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}visit_date'])!,
      staffName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      isSubmitted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_submitted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }
}

class Visit extends DataClass implements Insertable<Visit> {
  final String id;
  final String beneficiaryId;
  final DateTime visitDate;
  final String staffName;
  final String notes;
  final bool isSubmitted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverId;
  final DateTime? lastSyncedAt;
  const Visit(
      {required this.id,
      required this.beneficiaryId,
      required this.visitDate,
      required this.staffName,
      required this.notes,
      required this.isSubmitted,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beneficiary_id'] = Variable<String>(beneficiaryId);
    map['visit_date'] = Variable<DateTime>(visitDate);
    map['staff_name'] = Variable<String>(staffName);
    map['notes'] = Variable<String>(notes);
    map['is_submitted'] = Variable<bool>(isSubmitted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      visitDate: Value(visitDate),
      staffName: Value(staffName),
      notes: Value(notes),
      isSubmitted: Value(isSubmitted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Visit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Visit(
      id: serializer.fromJson<String>(json['id']),
      beneficiaryId: serializer.fromJson<String>(json['beneficiaryId']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      staffName: serializer.fromJson<String>(json['staffName']),
      notes: serializer.fromJson<String>(json['notes']),
      isSubmitted: serializer.fromJson<bool>(json['isSubmitted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beneficiaryId': serializer.toJson<String>(beneficiaryId),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'staffName': serializer.toJson<String>(staffName),
      'notes': serializer.toJson<String>(notes),
      'isSubmitted': serializer.toJson<bool>(isSubmitted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Visit copyWith(
          {String? id,
          String? beneficiaryId,
          DateTime? visitDate,
          String? staffName,
          String? notes,
          bool? isSubmitted,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Visit(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        visitDate: visitDate ?? this.visitDate,
        staffName: staffName ?? this.staffName,
        notes: notes ?? this.notes,
        isSubmitted: isSubmitted ?? this.isSubmitted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Visit copyWithCompanion(VisitsCompanion data) {
    return Visit(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      staffName: data.staffName.present ? data.staffName.value : this.staffName,
      notes: data.notes.present ? data.notes.value : this.notes,
      isSubmitted:
          data.isSubmitted.present ? data.isSubmitted.value : this.isSubmitted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Visit(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('visitDate: $visitDate, ')
          ..write('staffName: $staffName, ')
          ..write('notes: $notes, ')
          ..write('isSubmitted: $isSubmitted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      beneficiaryId,
      visitDate,
      staffName,
      notes,
      isSubmitted,
      createdAt,
      updatedAt,
      syncState,
      serverId,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Visit &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.visitDate == this.visitDate &&
          other.staffName == this.staffName &&
          other.notes == this.notes &&
          other.isSubmitted == this.isSubmitted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class VisitsCompanion extends UpdateCompanion<Visit> {
  final Value<String> id;
  final Value<String> beneficiaryId;
  final Value<DateTime> visitDate;
  final Value<String> staffName;
  final Value<String> notes;
  final Value<bool> isSubmitted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.staffName = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSubmitted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String beneficiaryId,
    required DateTime visitDate,
    required String staffName,
    this.notes = const Value.absent(),
    this.isSubmitted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        beneficiaryId = Value(beneficiaryId),
        visitDate = Value(visitDate),
        staffName = Value(staffName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Visit> custom({
    Expression<String>? id,
    Expression<String>? beneficiaryId,
    Expression<DateTime>? visitDate,
    Expression<String>? staffName,
    Expression<String>? notes,
    Expression<bool>? isSubmitted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (visitDate != null) 'visit_date': visitDate,
      if (staffName != null) 'staff_name': staffName,
      if (notes != null) 'notes': notes,
      if (isSubmitted != null) 'is_submitted': isSubmitted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? beneficiaryId,
      Value<DateTime>? visitDate,
      Value<String>? staffName,
      Value<String>? notes,
      Value<bool>? isSubmitted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return VisitsCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitDate: visitDate ?? this.visitDate,
      staffName: staffName ?? this.staffName,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (staffName.present) {
      map['staff_name'] = Variable<String>(staffName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSubmitted.present) {
      map['is_submitted'] = Variable<bool>(isSubmitted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('visitDate: $visitDate, ')
          ..write('staffName: $staffName, ')
          ..write('notes: $notes, ')
          ..write('isSubmitted: $isSubmitted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _visitIdMeta =
      const VerificationMeta('visitId');
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
      'visit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _documentTypeMeta =
      const VerificationMeta('documentType');
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
      'document_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _personTypeMeta =
      const VerificationMeta('personType');
  @override
  late final GeneratedColumn<String> personType = GeneratedColumn<String>(
      'person_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverUrlMeta =
      const VerificationMeta('serverUrl');
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        visitId,
        fileName,
        filePath,
        type,
        fileSize,
        thumbnailPath,
        documentType,
        personType,
        personId,
        notes,
        createdAt,
        updatedAt,
        syncState,
        serverUrl,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(_visitIdMeta,
          visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('document_type')) {
      context.handle(
          _documentTypeMeta,
          documentType.isAcceptableOrUnknown(
              data['document_type']!, _documentTypeMeta));
    }
    if (data.containsKey('person_type')) {
      context.handle(
          _personTypeMeta,
          personType.isAcceptableOrUnknown(
              data['person_type']!, _personTypeMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_url')) {
      context.handle(_serverUrlMeta,
          serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id'])!,
      visitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_id']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      documentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_type']),
      personType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_type']),
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_url']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String beneficiaryId;
  final String? visitId;
  final String fileName;
  final String filePath;
  final String type;
  final int fileSize;
  final String? thumbnailPath;
  final String? documentType;
  final String? personType;
  final String? personId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverUrl;
  final DateTime? lastSyncedAt;
  const Attachment(
      {required this.id,
      required this.beneficiaryId,
      this.visitId,
      required this.fileName,
      required this.filePath,
      required this.type,
      required this.fileSize,
      this.thumbnailPath,
      this.documentType,
      this.personType,
      this.personId,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState,
      this.serverUrl,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beneficiary_id'] = Variable<String>(beneficiaryId);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['type'] = Variable<String>(type);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || documentType != null) {
      map['document_type'] = Variable<String>(documentType);
    }
    if (!nullToAbsent || personType != null) {
      map['person_type'] = Variable<String>(personType);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      visitId: visitId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitId),
      fileName: Value(fileName),
      filePath: Value(filePath),
      type: Value(type),
      fileSize: Value(fileSize),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      documentType: documentType == null && nullToAbsent
          ? const Value.absent()
          : Value(documentType),
      personType: personType == null && nullToAbsent
          ? const Value.absent()
          : Value(personType),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      beneficiaryId: serializer.fromJson<String>(json['beneficiaryId']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      type: serializer.fromJson<String>(json['type']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      documentType: serializer.fromJson<String?>(json['documentType']),
      personType: serializer.fromJson<String?>(json['personType']),
      personId: serializer.fromJson<String?>(json['personId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beneficiaryId': serializer.toJson<String>(beneficiaryId),
      'visitId': serializer.toJson<String?>(visitId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'type': serializer.toJson<String>(type),
      'fileSize': serializer.toJson<int>(fileSize),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'documentType': serializer.toJson<String?>(documentType),
      'personType': serializer.toJson<String?>(personType),
      'personId': serializer.toJson<String?>(personId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Attachment copyWith(
          {String? id,
          String? beneficiaryId,
          Value<String?> visitId = const Value.absent(),
          String? fileName,
          String? filePath,
          String? type,
          int? fileSize,
          Value<String?> thumbnailPath = const Value.absent(),
          Value<String?> documentType = const Value.absent(),
          Value<String?> personType = const Value.absent(),
          Value<String?> personId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState,
          Value<String?> serverUrl = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Attachment(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        visitId: visitId.present ? visitId.value : this.visitId,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        type: type ?? this.type,
        fileSize: fileSize ?? this.fileSize,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        documentType:
            documentType.present ? documentType.value : this.documentType,
        personType: personType.present ? personType.value : this.personType,
        personId: personId.present ? personId.value : this.personId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      type: data.type.present ? data.type.value : this.type,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      personType:
          data.personType.present ? data.personType.value : this.personType,
      personId: data.personId.present ? data.personId.value : this.personId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('visitId: $visitId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('type: $type, ')
          ..write('fileSize: $fileSize, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('documentType: $documentType, ')
          ..write('personType: $personType, ')
          ..write('personId: $personId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      beneficiaryId,
      visitId,
      fileName,
      filePath,
      type,
      fileSize,
      thumbnailPath,
      documentType,
      personType,
      personId,
      notes,
      createdAt,
      updatedAt,
      syncState,
      serverUrl,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.visitId == this.visitId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.type == this.type &&
          other.fileSize == this.fileSize &&
          other.thumbnailPath == this.thumbnailPath &&
          other.documentType == this.documentType &&
          other.personType == this.personType &&
          other.personId == this.personId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverUrl == this.serverUrl &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> beneficiaryId;
  final Value<String?> visitId;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> type;
  final Value<int> fileSize;
  final Value<String?> thumbnailPath;
  final Value<String?> documentType;
  final Value<String?> personType;
  final Value<String?> personId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<String?> serverUrl;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.visitId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.type = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.documentType = const Value.absent(),
    this.personType = const Value.absent(),
    this.personId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String beneficiaryId,
    this.visitId = const Value.absent(),
    required String fileName,
    required String filePath,
    required String type,
    required int fileSize,
    this.thumbnailPath = const Value.absent(),
    this.documentType = const Value.absent(),
    this.personType = const Value.absent(),
    this.personId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        beneficiaryId = Value(beneficiaryId),
        fileName = Value(fileName),
        filePath = Value(filePath),
        type = Value(type),
        fileSize = Value(fileSize),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? beneficiaryId,
    Expression<String>? visitId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? type,
    Expression<int>? fileSize,
    Expression<String>? thumbnailPath,
    Expression<String>? documentType,
    Expression<String>? personType,
    Expression<String>? personId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? serverUrl,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (visitId != null) 'visit_id': visitId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (type != null) 'type': type,
      if (fileSize != null) 'file_size': fileSize,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (documentType != null) 'document_type': documentType,
      if (personType != null) 'person_type': personType,
      if (personId != null) 'person_id': personId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverUrl != null) 'server_url': serverUrl,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? beneficiaryId,
      Value<String?>? visitId,
      Value<String>? fileName,
      Value<String>? filePath,
      Value<String>? type,
      Value<int>? fileSize,
      Value<String?>? thumbnailPath,
      Value<String?>? documentType,
      Value<String?>? personType,
      Value<String?>? personId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<String?>? serverUrl,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitId: visitId ?? this.visitId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      documentType: documentType ?? this.documentType,
      personType: personType ?? this.personType,
      personId: personId ?? this.personId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverUrl: serverUrl ?? this.serverUrl,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (personType.present) {
      map['person_type'] = Variable<String>(personType.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('visitId: $visitId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('type: $type, ')
          ..write('fileSize: $fileSize, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('documentType: $documentType, ')
          ..write('personType: $personType, ')
          ..write('personId: $personId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxonomiesTable extends Taxonomies
    with TableInfo<$TaxonomiesTable, Taxonomy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxonomiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
      'group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, group, code, label, parentId, sortOrder, isActive, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxonomies';
  @override
  VerificationContext validateIntegrity(Insertable<Taxonomy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
          _groupMeta, group.isAcceptableOrUnknown(data['group']!, _groupMeta));
    } else if (isInserting) {
      context.missing(_groupMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Taxonomy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Taxonomy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      group: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TaxonomiesTable createAlias(String alias) {
    return $TaxonomiesTable(attachedDatabase, alias);
  }
}

class Taxonomy extends DataClass implements Insertable<Taxonomy> {
  final String id;
  final String group;
  final String code;
  final String label;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;
  const Taxonomy(
      {required this.id,
      required this.group,
      required this.code,
      required this.label,
      this.parentId,
      required this.sortOrder,
      required this.isActive,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group'] = Variable<String>(group);
    map['code'] = Variable<String>(code);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TaxonomiesCompanion toCompanion(bool nullToAbsent) {
    return TaxonomiesCompanion(
      id: Value(id),
      group: Value(group),
      code: Value(code),
      label: Value(label),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory Taxonomy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Taxonomy(
      id: serializer.fromJson<String>(json['id']),
      group: serializer.fromJson<String>(json['group']),
      code: serializer.fromJson<String>(json['code']),
      label: serializer.fromJson<String>(json['label']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'group': serializer.toJson<String>(group),
      'code': serializer.toJson<String>(code),
      'label': serializer.toJson<String>(label),
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Taxonomy copyWith(
          {String? id,
          String? group,
          String? code,
          String? label,
          Value<String?> parentId = const Value.absent(),
          int? sortOrder,
          bool? isActive,
          DateTime? updatedAt}) =>
      Taxonomy(
        id: id ?? this.id,
        group: group ?? this.group,
        code: code ?? this.code,
        label: label ?? this.label,
        parentId: parentId.present ? parentId.value : this.parentId,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Taxonomy copyWithCompanion(TaxonomiesCompanion data) {
    return Taxonomy(
      id: data.id.present ? data.id.value : this.id,
      group: data.group.present ? data.group.value : this.group,
      code: data.code.present ? data.code.value : this.code,
      label: data.label.present ? data.label.value : this.label,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Taxonomy(')
          ..write('id: $id, ')
          ..write('group: $group, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, group, code, label, parentId, sortOrder, isActive, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Taxonomy &&
          other.id == this.id &&
          other.group == this.group &&
          other.code == this.code &&
          other.label == this.label &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class TaxonomiesCompanion extends UpdateCompanion<Taxonomy> {
  final Value<String> id;
  final Value<String> group;
  final Value<String> code;
  final Value<String> label;
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TaxonomiesCompanion({
    this.id = const Value.absent(),
    this.group = const Value.absent(),
    this.code = const Value.absent(),
    this.label = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxonomiesCompanion.insert({
    required String id,
    required String group,
    required String code,
    required String label,
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        group = Value(group),
        code = Value(code),
        label = Value(label),
        updatedAt = Value(updatedAt);
  static Insertable<Taxonomy> custom({
    Expression<String>? id,
    Expression<String>? group,
    Expression<String>? code,
    Expression<String>? label,
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (group != null) 'group': group,
      if (code != null) 'code': code,
      if (label != null) 'label': label,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxonomiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? group,
      Value<String>? code,
      Value<String>? label,
      Value<String?>? parentId,
      Value<int>? sortOrder,
      Value<bool>? isActive,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TaxonomiesCompanion(
      id: id ?? this.id,
      group: group ?? this.group,
      code: code ?? this.code,
      label: label ?? this.label,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxonomiesCompanion(')
          ..write('id: $id, ')
          ..write('group: $group, ')
          ..write('code: $code, ')
          ..write('label: $label, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entity,
        entityId,
        operation,
        payload,
        priority,
        attempts,
        lastError,
        createdAt,
        scheduledAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final String id;
  final String entity;
  final String entityId;
  final String operation;
  final String payload;
  final int priority;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  const SyncQueueItem(
      {required this.id,
      required this.entity,
      required this.entityId,
      required this.operation,
      required this.payload,
      required this.priority,
      required this.attempts,
      this.lastError,
      required this.createdAt,
      this.scheduledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['priority'] = Variable<int>(priority);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      priority: Value(priority),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<String>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      priority: serializer.fromJson<int>(json['priority']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'priority': serializer.toJson<int>(priority),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
    };
  }

  SyncQueueItem copyWith(
          {String? id,
          String? entity,
          String? entityId,
          String? operation,
          String? payload,
          int? priority,
          int? attempts,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> scheduledAt = const Value.absent()}) =>
      SyncQueueItem(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        priority: priority ?? this.priority,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
      );
  SyncQueueItem copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entity, entityId, operation, payload,
      priority, attempts, lastError, createdAt, scheduledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.priority == this.priority &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.scheduledAt == this.scheduledAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<String> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> priority;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> scheduledAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String entity,
    required String entityId,
    required String operation,
    required String payload,
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.scheduledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entity = Value(entity),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<String>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? priority,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? scheduledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (priority != null) 'priority': priority,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? entity,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? payload,
      Value<int>? priority,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<DateTime?>? scheduledAt,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTableTable extends SyncMetadataTable
    with TableInfo<$SyncMetadataTableTable, SyncMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncTimeMeta =
      const VerificationMeta('lastSyncTime');
  @override
  late final GeneratedColumn<DateTime> lastSyncTime = GeneratedColumn<DateTime>(
      'last_sync_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalSyncedMeta =
      const VerificationMeta('totalSynced');
  @override
  late final GeneratedColumn<int> totalSynced = GeneratedColumn<int>(
      'total_synced', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _failedSyncsMeta =
      const VerificationMeta('failedSyncs');
  @override
  late final GeneratedColumn<int> failedSyncs = GeneratedColumn<int>(
      'failed_syncs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorTimeMeta =
      const VerificationMeta('lastErrorTime');
  @override
  late final GeneratedColumn<DateTime> lastErrorTime =
      GeneratedColumn<DateTime>('last_error_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        entity,
        lastSyncTime,
        totalSynced,
        failedSyncs,
        lastError,
        lastErrorTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata_table';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetadata> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
          _lastSyncTimeMeta,
          lastSyncTime.isAcceptableOrUnknown(
              data['last_sync_time']!, _lastSyncTimeMeta));
    } else if (isInserting) {
      context.missing(_lastSyncTimeMeta);
    }
    if (data.containsKey('total_synced')) {
      context.handle(
          _totalSyncedMeta,
          totalSynced.isAcceptableOrUnknown(
              data['total_synced']!, _totalSyncedMeta));
    }
    if (data.containsKey('failed_syncs')) {
      context.handle(
          _failedSyncsMeta,
          failedSyncs.isAcceptableOrUnknown(
              data['failed_syncs']!, _failedSyncsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('last_error_time')) {
      context.handle(
          _lastErrorTimeMeta,
          lastErrorTime.isAcceptableOrUnknown(
              data['last_error_time']!, _lastErrorTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadata(
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      lastSyncTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sync_time'])!,
      totalSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_synced'])!,
      failedSyncs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_syncs'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      lastErrorTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_error_time']),
    );
  }

  @override
  $SyncMetadataTableTable createAlias(String alias) {
    return $SyncMetadataTableTable(attachedDatabase, alias);
  }
}

class SyncMetadata extends DataClass implements Insertable<SyncMetadata> {
  /// نوع البيانات: 'beneficiaries', 'visits', 'taxonomies', etc.
  final String entity;

  /// آخر وقت مزامنة ناجحة
  final DateTime lastSyncTime;

  /// عدد العناصر التي تمت مزامنتها
  final int totalSynced;

  /// عدد العناصر الفاشلة
  final int failedSyncs;

  /// آخر خطأ حصل
  final String? lastError;

  /// وقت آخر خطأ
  final DateTime? lastErrorTime;
  const SyncMetadata(
      {required this.entity,
      required this.lastSyncTime,
      required this.totalSynced,
      required this.failedSyncs,
      this.lastError,
      this.lastErrorTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['last_sync_time'] = Variable<DateTime>(lastSyncTime);
    map['total_synced'] = Variable<int>(totalSynced);
    map['failed_syncs'] = Variable<int>(failedSyncs);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || lastErrorTime != null) {
      map['last_error_time'] = Variable<DateTime>(lastErrorTime);
    }
    return map;
  }

  SyncMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataTableCompanion(
      entity: Value(entity),
      lastSyncTime: Value(lastSyncTime),
      totalSynced: Value(totalSynced),
      failedSyncs: Value(failedSyncs),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      lastErrorTime: lastErrorTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorTime),
    );
  }

  factory SyncMetadata.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadata(
      entity: serializer.fromJson<String>(json['entity']),
      lastSyncTime: serializer.fromJson<DateTime>(json['lastSyncTime']),
      totalSynced: serializer.fromJson<int>(json['totalSynced']),
      failedSyncs: serializer.fromJson<int>(json['failedSyncs']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      lastErrorTime: serializer.fromJson<DateTime?>(json['lastErrorTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'lastSyncTime': serializer.toJson<DateTime>(lastSyncTime),
      'totalSynced': serializer.toJson<int>(totalSynced),
      'failedSyncs': serializer.toJson<int>(failedSyncs),
      'lastError': serializer.toJson<String?>(lastError),
      'lastErrorTime': serializer.toJson<DateTime?>(lastErrorTime),
    };
  }

  SyncMetadata copyWith(
          {String? entity,
          DateTime? lastSyncTime,
          int? totalSynced,
          int? failedSyncs,
          Value<String?> lastError = const Value.absent(),
          Value<DateTime?> lastErrorTime = const Value.absent()}) =>
      SyncMetadata(
        entity: entity ?? this.entity,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
        totalSynced: totalSynced ?? this.totalSynced,
        failedSyncs: failedSyncs ?? this.failedSyncs,
        lastError: lastError.present ? lastError.value : this.lastError,
        lastErrorTime:
            lastErrorTime.present ? lastErrorTime.value : this.lastErrorTime,
      );
  SyncMetadata copyWithCompanion(SyncMetadataTableCompanion data) {
    return SyncMetadata(
      entity: data.entity.present ? data.entity.value : this.entity,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      totalSynced:
          data.totalSynced.present ? data.totalSynced.value : this.totalSynced,
      failedSyncs:
          data.failedSyncs.present ? data.failedSyncs.value : this.failedSyncs,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      lastErrorTime: data.lastErrorTime.present
          ? data.lastErrorTime.value
          : this.lastErrorTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadata(')
          ..write('entity: $entity, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('totalSynced: $totalSynced, ')
          ..write('failedSyncs: $failedSyncs, ')
          ..write('lastError: $lastError, ')
          ..write('lastErrorTime: $lastErrorTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      entity, lastSyncTime, totalSynced, failedSyncs, lastError, lastErrorTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadata &&
          other.entity == this.entity &&
          other.lastSyncTime == this.lastSyncTime &&
          other.totalSynced == this.totalSynced &&
          other.failedSyncs == this.failedSyncs &&
          other.lastError == this.lastError &&
          other.lastErrorTime == this.lastErrorTime);
}

class SyncMetadataTableCompanion extends UpdateCompanion<SyncMetadata> {
  final Value<String> entity;
  final Value<DateTime> lastSyncTime;
  final Value<int> totalSynced;
  final Value<int> failedSyncs;
  final Value<String?> lastError;
  final Value<DateTime?> lastErrorTime;
  final Value<int> rowid;
  const SyncMetadataTableCompanion({
    this.entity = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.totalSynced = const Value.absent(),
    this.failedSyncs = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastErrorTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataTableCompanion.insert({
    required String entity,
    required DateTime lastSyncTime,
    this.totalSynced = const Value.absent(),
    this.failedSyncs = const Value.absent(),
    this.lastError = const Value.absent(),
    this.lastErrorTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : entity = Value(entity),
        lastSyncTime = Value(lastSyncTime);
  static Insertable<SyncMetadata> custom({
    Expression<String>? entity,
    Expression<DateTime>? lastSyncTime,
    Expression<int>? totalSynced,
    Expression<int>? failedSyncs,
    Expression<String>? lastError,
    Expression<DateTime>? lastErrorTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (totalSynced != null) 'total_synced': totalSynced,
      if (failedSyncs != null) 'failed_syncs': failedSyncs,
      if (lastError != null) 'last_error': lastError,
      if (lastErrorTime != null) 'last_error_time': lastErrorTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataTableCompanion copyWith(
      {Value<String>? entity,
      Value<DateTime>? lastSyncTime,
      Value<int>? totalSynced,
      Value<int>? failedSyncs,
      Value<String?>? lastError,
      Value<DateTime?>? lastErrorTime,
      Value<int>? rowid}) {
    return SyncMetadataTableCompanion(
      entity: entity ?? this.entity,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      totalSynced: totalSynced ?? this.totalSynced,
      failedSyncs: failedSyncs ?? this.failedSyncs,
      lastError: lastError ?? this.lastError,
      lastErrorTime: lastErrorTime ?? this.lastErrorTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<DateTime>(lastSyncTime.value);
    }
    if (totalSynced.present) {
      map['total_synced'] = Variable<int>(totalSynced.value);
    }
    if (failedSyncs.present) {
      map['failed_syncs'] = Variable<int>(failedSyncs.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (lastErrorTime.present) {
      map['last_error_time'] = Variable<DateTime>(lastErrorTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableCompanion(')
          ..write('entity: $entity, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('totalSynced: $totalSynced, ')
          ..write('failedSyncs: $failedSyncs, ')
          ..write('lastError: $lastError, ')
          ..write('lastErrorTime: $lastErrorTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityTypeMeta =
      const VerificationMeta('activityType');
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
      'activity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changesMeta =
      const VerificationMeta('changes');
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        userId,
        activityType,
        description,
        changes,
        createdAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
          _activityTypeMeta,
          activityType.isAcceptableOrUnknown(
              data['activity_type']!, _activityTypeMeta));
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('changes')) {
      context.handle(_changesMeta,
          changes.isAcceptableOrUnknown(data['changes']!, _changesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}beneficiary_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      activityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      changes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String beneficiaryId;
  final String userId;
  final String activityType;
  final String description;
  final String? changes;
  final DateTime createdAt;
  final String syncState;
  const Activity(
      {required this.id,
      required this.beneficiaryId,
      required this.userId,
      required this.activityType,
      required this.description,
      this.changes,
      required this.createdAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beneficiary_id'] = Variable<String>(beneficiaryId);
    map['user_id'] = Variable<String>(userId);
    map['activity_type'] = Variable<String>(activityType);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || changes != null) {
      map['changes'] = Variable<String>(changes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      userId: Value(userId),
      activityType: Value(activityType),
      description: Value(description),
      changes: changes == null && nullToAbsent
          ? const Value.absent()
          : Value(changes),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      beneficiaryId: serializer.fromJson<String>(json['beneficiaryId']),
      userId: serializer.fromJson<String>(json['userId']),
      activityType: serializer.fromJson<String>(json['activityType']),
      description: serializer.fromJson<String>(json['description']),
      changes: serializer.fromJson<String?>(json['changes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beneficiaryId': serializer.toJson<String>(beneficiaryId),
      'userId': serializer.toJson<String>(userId),
      'activityType': serializer.toJson<String>(activityType),
      'description': serializer.toJson<String>(description),
      'changes': serializer.toJson<String?>(changes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  Activity copyWith(
          {String? id,
          String? beneficiaryId,
          String? userId,
          String? activityType,
          String? description,
          Value<String?> changes = const Value.absent(),
          DateTime? createdAt,
          String? syncState}) =>
      Activity(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        userId: userId ?? this.userId,
        activityType: activityType ?? this.activityType,
        description: description ?? this.description,
        changes: changes.present ? changes.value : this.changes,
        createdAt: createdAt ?? this.createdAt,
        syncState: syncState ?? this.syncState,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      userId: data.userId.present ? data.userId.value : this.userId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      description:
          data.description.present ? data.description.value : this.description,
      changes: data.changes.present ? data.changes.value : this.changes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('userId: $userId, ')
          ..write('activityType: $activityType, ')
          ..write('description: $description, ')
          ..write('changes: $changes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, beneficiaryId, userId, activityType,
      description, changes, createdAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.userId == this.userId &&
          other.activityType == this.activityType &&
          other.description == this.description &&
          other.changes == this.changes &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> beneficiaryId;
  final Value<String> userId;
  final Value<String> activityType;
  final Value<String> description;
  final Value<String?> changes;
  final Value<DateTime> createdAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.userId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.description = const Value.absent(),
    this.changes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String beneficiaryId,
    required String userId,
    required String activityType,
    required String description,
    this.changes = const Value.absent(),
    required DateTime createdAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        beneficiaryId = Value(beneficiaryId),
        userId = Value(userId),
        activityType = Value(activityType),
        description = Value(description),
        createdAt = Value(createdAt);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? beneficiaryId,
    Expression<String>? userId,
    Expression<String>? activityType,
    Expression<String>? description,
    Expression<String>? changes,
    Expression<DateTime>? createdAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (userId != null) 'user_id': userId,
      if (activityType != null) 'activity_type': activityType,
      if (description != null) 'description': description,
      if (changes != null) 'changes': changes,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? beneficiaryId,
      Value<String>? userId,
      Value<String>? activityType,
      Value<String>? description,
      Value<String?>? changes,
      Value<DateTime>? createdAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      changes: changes ?? this.changes,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(changes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('userId: $userId, ')
          ..write('activityType: $activityType, ')
          ..write('description: $description, ')
          ..write('changes: $changes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyDeceasedTableTable extends FamilyDeceasedTable
    with TableInfo<$FamilyDeceasedTableTable, FamilyDeceased> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyDeceasedTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<int> beneficiaryId = GeneratedColumn<int>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deceasedTypeMeta =
      const VerificationMeta('deceasedType');
  @override
  late final GeneratedColumn<int> deceasedType = GeneratedColumn<int>(
      'deceased_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secondNameMeta =
      const VerificationMeta('secondName');
  @override
  late final GeneratedColumn<String> secondName = GeneratedColumn<String>(
      'second_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thirdNameMeta =
      const VerificationMeta('thirdName');
  @override
  late final GeneratedColumn<String> thirdName = GeneratedColumn<String>(
      'third_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familyNameMeta =
      const VerificationMeta('familyName');
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
      'family_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<int> nationalId = GeneratedColumn<int>(
      'national_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deathDateMeta =
      const VerificationMeta('deathDate');
  @override
  late final GeneratedColumn<DateTime> deathDate = GeneratedColumn<DateTime>(
      'death_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deathCauseMeta =
      const VerificationMeta('deathCause');
  @override
  late final GeneratedColumn<int> deathCause = GeneratedColumn<int>(
      'death_cause', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _documentTypeMeta =
      const VerificationMeta('documentType');
  @override
  late final GeneratedColumn<int> documentType = GeneratedColumn<int>(
      'document_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _documentPathMeta =
      const VerificationMeta('documentPath');
  @override
  late final GeneratedColumn<String> documentPath = GeneratedColumn<String>(
      'document_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        deceasedType,
        firstName,
        secondName,
        thirdName,
        familyName,
        nationalId,
        deathDate,
        deathCause,
        documentType,
        documentPath,
        notes,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_deceased';
  @override
  VerificationContext validateIntegrity(Insertable<FamilyDeceased> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('deceased_type')) {
      context.handle(
          _deceasedTypeMeta,
          deceasedType.isAcceptableOrUnknown(
              data['deceased_type']!, _deceasedTypeMeta));
    } else if (isInserting) {
      context.missing(_deceasedTypeMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('second_name')) {
      context.handle(
          _secondNameMeta,
          secondName.isAcceptableOrUnknown(
              data['second_name']!, _secondNameMeta));
    }
    if (data.containsKey('third_name')) {
      context.handle(_thirdNameMeta,
          thirdName.isAcceptableOrUnknown(data['third_name']!, _thirdNameMeta));
    }
    if (data.containsKey('family_name')) {
      context.handle(
          _familyNameMeta,
          familyName.isAcceptableOrUnknown(
              data['family_name']!, _familyNameMeta));
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('death_date')) {
      context.handle(_deathDateMeta,
          deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta));
    } else if (isInserting) {
      context.missing(_deathDateMeta);
    }
    if (data.containsKey('death_cause')) {
      context.handle(
          _deathCauseMeta,
          deathCause.isAcceptableOrUnknown(
              data['death_cause']!, _deathCauseMeta));
    } else if (isInserting) {
      context.missing(_deathCauseMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
          _documentTypeMeta,
          documentType.isAcceptableOrUnknown(
              data['document_type']!, _documentTypeMeta));
    }
    if (data.containsKey('document_path')) {
      context.handle(
          _documentPathMeta,
          documentPath.isAcceptableOrUnknown(
              data['document_path']!, _documentPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyDeceased map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyDeceased(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}beneficiary_id'])!,
      deceasedType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deceased_type'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      secondName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}second_name']),
      thirdName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}third_name']),
      familyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_name'])!,
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}national_id'])!,
      deathDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}death_date'])!,
      deathCause: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}death_cause'])!,
      documentType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}document_type']),
      documentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $FamilyDeceasedTableTable createAlias(String alias) {
    return $FamilyDeceasedTableTable(attachedDatabase, alias);
  }
}

class FamilyDeceased extends DataClass implements Insertable<FamilyDeceased> {
  final int id;
  final int beneficiaryId;
  final int deceasedType;
  final String firstName;
  final String? secondName;
  final String? thirdName;
  final String familyName;
  final int nationalId;
  final DateTime deathDate;
  final int deathCause;
  final int? documentType;
  final String? documentPath;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncState;
  final int? serverId;
  final DateTime? lastSyncedAt;
  const FamilyDeceased(
      {required this.id,
      required this.beneficiaryId,
      required this.deceasedType,
      required this.firstName,
      this.secondName,
      this.thirdName,
      required this.familyName,
      required this.nationalId,
      required this.deathDate,
      required this.deathCause,
      this.documentType,
      this.documentPath,
      this.notes,
      this.createdAt,
      this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['beneficiary_id'] = Variable<int>(beneficiaryId);
    map['deceased_type'] = Variable<int>(deceasedType);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || secondName != null) {
      map['second_name'] = Variable<String>(secondName);
    }
    if (!nullToAbsent || thirdName != null) {
      map['third_name'] = Variable<String>(thirdName);
    }
    map['family_name'] = Variable<String>(familyName);
    map['national_id'] = Variable<int>(nationalId);
    map['death_date'] = Variable<DateTime>(deathDate);
    map['death_cause'] = Variable<int>(deathCause);
    if (!nullToAbsent || documentType != null) {
      map['document_type'] = Variable<int>(documentType);
    }
    if (!nullToAbsent || documentPath != null) {
      map['document_path'] = Variable<String>(documentPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  FamilyDeceasedTableCompanion toCompanion(bool nullToAbsent) {
    return FamilyDeceasedTableCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      deceasedType: Value(deceasedType),
      firstName: Value(firstName),
      secondName: secondName == null && nullToAbsent
          ? const Value.absent()
          : Value(secondName),
      thirdName: thirdName == null && nullToAbsent
          ? const Value.absent()
          : Value(thirdName),
      familyName: Value(familyName),
      nationalId: Value(nationalId),
      deathDate: Value(deathDate),
      deathCause: Value(deathCause),
      documentType: documentType == null && nullToAbsent
          ? const Value.absent()
          : Value(documentType),
      documentPath: documentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(documentPath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory FamilyDeceased.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyDeceased(
      id: serializer.fromJson<int>(json['id']),
      beneficiaryId: serializer.fromJson<int>(json['beneficiaryId']),
      deceasedType: serializer.fromJson<int>(json['deceasedType']),
      firstName: serializer.fromJson<String>(json['firstName']),
      secondName: serializer.fromJson<String?>(json['secondName']),
      thirdName: serializer.fromJson<String?>(json['thirdName']),
      familyName: serializer.fromJson<String>(json['familyName']),
      nationalId: serializer.fromJson<int>(json['nationalId']),
      deathDate: serializer.fromJson<DateTime>(json['deathDate']),
      deathCause: serializer.fromJson<int>(json['deathCause']),
      documentType: serializer.fromJson<int?>(json['documentType']),
      documentPath: serializer.fromJson<String?>(json['documentPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'beneficiaryId': serializer.toJson<int>(beneficiaryId),
      'deceasedType': serializer.toJson<int>(deceasedType),
      'firstName': serializer.toJson<String>(firstName),
      'secondName': serializer.toJson<String?>(secondName),
      'thirdName': serializer.toJson<String?>(thirdName),
      'familyName': serializer.toJson<String>(familyName),
      'nationalId': serializer.toJson<int>(nationalId),
      'deathDate': serializer.toJson<DateTime>(deathDate),
      'deathCause': serializer.toJson<int>(deathCause),
      'documentType': serializer.toJson<int?>(documentType),
      'documentPath': serializer.toJson<String?>(documentPath),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  FamilyDeceased copyWith(
          {int? id,
          int? beneficiaryId,
          int? deceasedType,
          String? firstName,
          Value<String?> secondName = const Value.absent(),
          Value<String?> thirdName = const Value.absent(),
          String? familyName,
          int? nationalId,
          DateTime? deathDate,
          int? deathCause,
          Value<int?> documentType = const Value.absent(),
          Value<String?> documentPath = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          String? syncState,
          Value<int?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      FamilyDeceased(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        deceasedType: deceasedType ?? this.deceasedType,
        firstName: firstName ?? this.firstName,
        secondName: secondName.present ? secondName.value : this.secondName,
        thirdName: thirdName.present ? thirdName.value : this.thirdName,
        familyName: familyName ?? this.familyName,
        nationalId: nationalId ?? this.nationalId,
        deathDate: deathDate ?? this.deathDate,
        deathCause: deathCause ?? this.deathCause,
        documentType:
            documentType.present ? documentType.value : this.documentType,
        documentPath:
            documentPath.present ? documentPath.value : this.documentPath,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  FamilyDeceased copyWithCompanion(FamilyDeceasedTableCompanion data) {
    return FamilyDeceased(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      deceasedType: data.deceasedType.present
          ? data.deceasedType.value
          : this.deceasedType,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      secondName:
          data.secondName.present ? data.secondName.value : this.secondName,
      thirdName: data.thirdName.present ? data.thirdName.value : this.thirdName,
      familyName:
          data.familyName.present ? data.familyName.value : this.familyName,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      deathCause:
          data.deathCause.present ? data.deathCause.value : this.deathCause,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      documentPath: data.documentPath.present
          ? data.documentPath.value
          : this.documentPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyDeceased(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('deceasedType: $deceasedType, ')
          ..write('firstName: $firstName, ')
          ..write('secondName: $secondName, ')
          ..write('thirdName: $thirdName, ')
          ..write('familyName: $familyName, ')
          ..write('nationalId: $nationalId, ')
          ..write('deathDate: $deathDate, ')
          ..write('deathCause: $deathCause, ')
          ..write('documentType: $documentType, ')
          ..write('documentPath: $documentPath, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      beneficiaryId,
      deceasedType,
      firstName,
      secondName,
      thirdName,
      familyName,
      nationalId,
      deathDate,
      deathCause,
      documentType,
      documentPath,
      notes,
      createdAt,
      updatedAt,
      syncState,
      serverId,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyDeceased &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.deceasedType == this.deceasedType &&
          other.firstName == this.firstName &&
          other.secondName == this.secondName &&
          other.thirdName == this.thirdName &&
          other.familyName == this.familyName &&
          other.nationalId == this.nationalId &&
          other.deathDate == this.deathDate &&
          other.deathCause == this.deathCause &&
          other.documentType == this.documentType &&
          other.documentPath == this.documentPath &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class FamilyDeceasedTableCompanion extends UpdateCompanion<FamilyDeceased> {
  final Value<int> id;
  final Value<int> beneficiaryId;
  final Value<int> deceasedType;
  final Value<String> firstName;
  final Value<String?> secondName;
  final Value<String?> thirdName;
  final Value<String> familyName;
  final Value<int> nationalId;
  final Value<DateTime> deathDate;
  final Value<int> deathCause;
  final Value<int?> documentType;
  final Value<String?> documentPath;
  final Value<String?> notes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<DateTime?> lastSyncedAt;
  const FamilyDeceasedTableCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.deceasedType = const Value.absent(),
    this.firstName = const Value.absent(),
    this.secondName = const Value.absent(),
    this.thirdName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.deathCause = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  FamilyDeceasedTableCompanion.insert({
    this.id = const Value.absent(),
    required int beneficiaryId,
    required int deceasedType,
    required String firstName,
    this.secondName = const Value.absent(),
    this.thirdName = const Value.absent(),
    required String familyName,
    required int nationalId,
    required DateTime deathDate,
    required int deathCause,
    this.documentType = const Value.absent(),
    this.documentPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : beneficiaryId = Value(beneficiaryId),
        deceasedType = Value(deceasedType),
        firstName = Value(firstName),
        familyName = Value(familyName),
        nationalId = Value(nationalId),
        deathDate = Value(deathDate),
        deathCause = Value(deathCause);
  static Insertable<FamilyDeceased> custom({
    Expression<int>? id,
    Expression<int>? beneficiaryId,
    Expression<int>? deceasedType,
    Expression<String>? firstName,
    Expression<String>? secondName,
    Expression<String>? thirdName,
    Expression<String>? familyName,
    Expression<int>? nationalId,
    Expression<DateTime>? deathDate,
    Expression<int>? deathCause,
    Expression<int>? documentType,
    Expression<String>? documentPath,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (deceasedType != null) 'deceased_type': deceasedType,
      if (firstName != null) 'first_name': firstName,
      if (secondName != null) 'second_name': secondName,
      if (thirdName != null) 'third_name': thirdName,
      if (familyName != null) 'family_name': familyName,
      if (nationalId != null) 'national_id': nationalId,
      if (deathDate != null) 'death_date': deathDate,
      if (deathCause != null) 'death_cause': deathCause,
      if (documentType != null) 'document_type': documentType,
      if (documentPath != null) 'document_path': documentPath,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  FamilyDeceasedTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? beneficiaryId,
      Value<int>? deceasedType,
      Value<String>? firstName,
      Value<String?>? secondName,
      Value<String?>? thirdName,
      Value<String>? familyName,
      Value<int>? nationalId,
      Value<DateTime>? deathDate,
      Value<int>? deathCause,
      Value<int?>? documentType,
      Value<String?>? documentPath,
      Value<String?>? notes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<DateTime?>? lastSyncedAt}) {
    return FamilyDeceasedTableCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      deceasedType: deceasedType ?? this.deceasedType,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      thirdName: thirdName ?? this.thirdName,
      familyName: familyName ?? this.familyName,
      nationalId: nationalId ?? this.nationalId,
      deathDate: deathDate ?? this.deathDate,
      deathCause: deathCause ?? this.deathCause,
      documentType: documentType ?? this.documentType,
      documentPath: documentPath ?? this.documentPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<int>(beneficiaryId.value);
    }
    if (deceasedType.present) {
      map['deceased_type'] = Variable<int>(deceasedType.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (secondName.present) {
      map['second_name'] = Variable<String>(secondName.value);
    }
    if (thirdName.present) {
      map['third_name'] = Variable<String>(thirdName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<int>(nationalId.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<DateTime>(deathDate.value);
    }
    if (deathCause.present) {
      map['death_cause'] = Variable<int>(deathCause.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<int>(documentType.value);
    }
    if (documentPath.present) {
      map['document_path'] = Variable<String>(documentPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyDeceasedTableCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('deceasedType: $deceasedType, ')
          ..write('firstName: $firstName, ')
          ..write('secondName: $secondName, ')
          ..write('thirdName: $thirdName, ')
          ..write('familyName: $familyName, ')
          ..write('nationalId: $nationalId, ')
          ..write('deathDate: $deathDate, ')
          ..write('deathCause: $deathCause, ')
          ..write('documentType: $documentType, ')
          ..write('documentPath: $documentPath, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $FamilyMembersTableTable extends FamilyMembersTable
    with TableInfo<$FamilyMembersTableTable, FamilyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<int> beneficiaryId = GeneratedColumn<int>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orphanNationalIdMeta =
      const VerificationMeta('orphanNationalId');
  @override
  late final GeneratedColumn<int> orphanNationalId = GeneratedColumn<int>(
      'orphan_national_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secondNameMeta =
      const VerificationMeta('secondName');
  @override
  late final GeneratedColumn<String> secondName = GeneratedColumn<String>(
      'second_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thirdNameMeta =
      const VerificationMeta('thirdName');
  @override
  late final GeneratedColumn<String> thirdName = GeneratedColumn<String>(
      'third_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familyNameMeta =
      const VerificationMeta('familyName');
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
      'family_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<int> gender = GeneratedColumn<int>(
      'gender', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _healthStatusMeta =
      const VerificationMeta('healthStatus');
  @override
  late final GeneratedColumn<int> healthStatus = GeneratedColumn<int>(
      'health_status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sponsorshipStatusMeta =
      const VerificationMeta('sponsorshipStatus');
  @override
  late final GeneratedColumn<int> sponsorshipStatus = GeneratedColumn<int>(
      'sponsorship_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sponsorshipTypeMeta =
      const VerificationMeta('sponsorshipType');
  @override
  late final GeneratedColumn<int> sponsorshipType = GeneratedColumn<int>(
      'sponsorship_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sponsorNameMeta =
      const VerificationMeta('sponsorName');
  @override
  late final GeneratedColumn<String> sponsorName = GeneratedColumn<String>(
      'sponsor_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sponsorshipStartDateMeta =
      const VerificationMeta('sponsorshipStartDate');
  @override
  late final GeneratedColumn<DateTime> sponsorshipStartDate =
      GeneratedColumn<DateTime>('sponsorship_start_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentsMeta =
      const VerificationMeta('attachments');
  @override
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
      'attachments', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        beneficiaryId,
        orphanNationalId,
        firstName,
        secondName,
        thirdName,
        familyName,
        birthDate,
        age,
        gender,
        healthStatus,
        sponsorshipStatus,
        sponsorshipType,
        sponsorName,
        sponsorshipStartDate,
        notes,
        attachments,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_members';
  @override
  VerificationContext validateIntegrity(Insertable<FamilyMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('orphan_national_id')) {
      context.handle(
          _orphanNationalIdMeta,
          orphanNationalId.isAcceptableOrUnknown(
              data['orphan_national_id']!, _orphanNationalIdMeta));
    } else if (isInserting) {
      context.missing(_orphanNationalIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('second_name')) {
      context.handle(
          _secondNameMeta,
          secondName.isAcceptableOrUnknown(
              data['second_name']!, _secondNameMeta));
    }
    if (data.containsKey('third_name')) {
      context.handle(_thirdNameMeta,
          thirdName.isAcceptableOrUnknown(data['third_name']!, _thirdNameMeta));
    }
    if (data.containsKey('family_name')) {
      context.handle(
          _familyNameMeta,
          familyName.isAcceptableOrUnknown(
              data['family_name']!, _familyNameMeta));
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('health_status')) {
      context.handle(
          _healthStatusMeta,
          healthStatus.isAcceptableOrUnknown(
              data['health_status']!, _healthStatusMeta));
    } else if (isInserting) {
      context.missing(_healthStatusMeta);
    }
    if (data.containsKey('sponsorship_status')) {
      context.handle(
          _sponsorshipStatusMeta,
          sponsorshipStatus.isAcceptableOrUnknown(
              data['sponsorship_status']!, _sponsorshipStatusMeta));
    }
    if (data.containsKey('sponsorship_type')) {
      context.handle(
          _sponsorshipTypeMeta,
          sponsorshipType.isAcceptableOrUnknown(
              data['sponsorship_type']!, _sponsorshipTypeMeta));
    }
    if (data.containsKey('sponsor_name')) {
      context.handle(
          _sponsorNameMeta,
          sponsorName.isAcceptableOrUnknown(
              data['sponsor_name']!, _sponsorNameMeta));
    }
    if (data.containsKey('sponsorship_start_date')) {
      context.handle(
          _sponsorshipStartDateMeta,
          sponsorshipStartDate.isAcceptableOrUnknown(
              data['sponsorship_start_date']!, _sponsorshipStartDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('attachments')) {
      context.handle(
          _attachmentsMeta,
          attachments.isAcceptableOrUnknown(
              data['attachments']!, _attachmentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}beneficiary_id'])!,
      orphanNationalId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}orphan_national_id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      secondName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}second_name']),
      thirdName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}third_name']),
      familyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_name'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gender'])!,
      healthStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}health_status'])!,
      sponsorshipStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sponsorship_status']),
      sponsorshipType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sponsorship_type']),
      sponsorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sponsor_name']),
      sponsorshipStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}sponsorship_start_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      attachments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachments']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $FamilyMembersTableTable createAlias(String alias) {
    return $FamilyMembersTableTable(attachedDatabase, alias);
  }
}

class FamilyMember extends DataClass implements Insertable<FamilyMember> {
  final int id;
  final int beneficiaryId;
  final int orphanNationalId;
  final String firstName;
  final String? secondName;
  final String? thirdName;
  final String familyName;
  final DateTime birthDate;
  final int? age;
  final int gender;
  final int healthStatus;
  final int? sponsorshipStatus;
  final int? sponsorshipType;
  final String? sponsorName;
  final DateTime? sponsorshipStartDate;
  final String? notes;
  final String? attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String syncState;
  final int? serverId;
  final DateTime? lastSyncedAt;
  const FamilyMember(
      {required this.id,
      required this.beneficiaryId,
      required this.orphanNationalId,
      required this.firstName,
      this.secondName,
      this.thirdName,
      required this.familyName,
      required this.birthDate,
      this.age,
      required this.gender,
      required this.healthStatus,
      this.sponsorshipStatus,
      this.sponsorshipType,
      this.sponsorName,
      this.sponsorshipStartDate,
      this.notes,
      this.attachments,
      this.createdAt,
      this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['beneficiary_id'] = Variable<int>(beneficiaryId);
    map['orphan_national_id'] = Variable<int>(orphanNationalId);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || secondName != null) {
      map['second_name'] = Variable<String>(secondName);
    }
    if (!nullToAbsent || thirdName != null) {
      map['third_name'] = Variable<String>(thirdName);
    }
    map['family_name'] = Variable<String>(familyName);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    map['gender'] = Variable<int>(gender);
    map['health_status'] = Variable<int>(healthStatus);
    if (!nullToAbsent || sponsorshipStatus != null) {
      map['sponsorship_status'] = Variable<int>(sponsorshipStatus);
    }
    if (!nullToAbsent || sponsorshipType != null) {
      map['sponsorship_type'] = Variable<int>(sponsorshipType);
    }
    if (!nullToAbsent || sponsorName != null) {
      map['sponsor_name'] = Variable<String>(sponsorName);
    }
    if (!nullToAbsent || sponsorshipStartDate != null) {
      map['sponsorship_start_date'] = Variable<DateTime>(sponsorshipStartDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || attachments != null) {
      map['attachments'] = Variable<String>(attachments);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  FamilyMembersTableCompanion toCompanion(bool nullToAbsent) {
    return FamilyMembersTableCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      orphanNationalId: Value(orphanNationalId),
      firstName: Value(firstName),
      secondName: secondName == null && nullToAbsent
          ? const Value.absent()
          : Value(secondName),
      thirdName: thirdName == null && nullToAbsent
          ? const Value.absent()
          : Value(thirdName),
      familyName: Value(familyName),
      birthDate: Value(birthDate),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender: Value(gender),
      healthStatus: Value(healthStatus),
      sponsorshipStatus: sponsorshipStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorshipStatus),
      sponsorshipType: sponsorshipType == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorshipType),
      sponsorName: sponsorName == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorName),
      sponsorshipStartDate: sponsorshipStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorshipStartDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      attachments: attachments == null && nullToAbsent
          ? const Value.absent()
          : Value(attachments),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMember(
      id: serializer.fromJson<int>(json['id']),
      beneficiaryId: serializer.fromJson<int>(json['beneficiaryId']),
      orphanNationalId: serializer.fromJson<int>(json['orphanNationalId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      secondName: serializer.fromJson<String?>(json['secondName']),
      thirdName: serializer.fromJson<String?>(json['thirdName']),
      familyName: serializer.fromJson<String>(json['familyName']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<int>(json['gender']),
      healthStatus: serializer.fromJson<int>(json['healthStatus']),
      sponsorshipStatus: serializer.fromJson<int?>(json['sponsorshipStatus']),
      sponsorshipType: serializer.fromJson<int?>(json['sponsorshipType']),
      sponsorName: serializer.fromJson<String?>(json['sponsorName']),
      sponsorshipStartDate:
          serializer.fromJson<DateTime?>(json['sponsorshipStartDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      attachments: serializer.fromJson<String?>(json['attachments']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'beneficiaryId': serializer.toJson<int>(beneficiaryId),
      'orphanNationalId': serializer.toJson<int>(orphanNationalId),
      'firstName': serializer.toJson<String>(firstName),
      'secondName': serializer.toJson<String?>(secondName),
      'thirdName': serializer.toJson<String?>(thirdName),
      'familyName': serializer.toJson<String>(familyName),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<int>(gender),
      'healthStatus': serializer.toJson<int>(healthStatus),
      'sponsorshipStatus': serializer.toJson<int?>(sponsorshipStatus),
      'sponsorshipType': serializer.toJson<int?>(sponsorshipType),
      'sponsorName': serializer.toJson<String?>(sponsorName),
      'sponsorshipStartDate':
          serializer.toJson<DateTime?>(sponsorshipStartDate),
      'notes': serializer.toJson<String?>(notes),
      'attachments': serializer.toJson<String?>(attachments),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  FamilyMember copyWith(
          {int? id,
          int? beneficiaryId,
          int? orphanNationalId,
          String? firstName,
          Value<String?> secondName = const Value.absent(),
          Value<String?> thirdName = const Value.absent(),
          String? familyName,
          DateTime? birthDate,
          Value<int?> age = const Value.absent(),
          int? gender,
          int? healthStatus,
          Value<int?> sponsorshipStatus = const Value.absent(),
          Value<int?> sponsorshipType = const Value.absent(),
          Value<String?> sponsorName = const Value.absent(),
          Value<DateTime?> sponsorshipStartDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> attachments = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent(),
          String? syncState,
          Value<int?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      FamilyMember(
        id: id ?? this.id,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        orphanNationalId: orphanNationalId ?? this.orphanNationalId,
        firstName: firstName ?? this.firstName,
        secondName: secondName.present ? secondName.value : this.secondName,
        thirdName: thirdName.present ? thirdName.value : this.thirdName,
        familyName: familyName ?? this.familyName,
        birthDate: birthDate ?? this.birthDate,
        age: age.present ? age.value : this.age,
        gender: gender ?? this.gender,
        healthStatus: healthStatus ?? this.healthStatus,
        sponsorshipStatus: sponsorshipStatus.present
            ? sponsorshipStatus.value
            : this.sponsorshipStatus,
        sponsorshipType: sponsorshipType.present
            ? sponsorshipType.value
            : this.sponsorshipType,
        sponsorName: sponsorName.present ? sponsorName.value : this.sponsorName,
        sponsorshipStartDate: sponsorshipStartDate.present
            ? sponsorshipStartDate.value
            : this.sponsorshipStartDate,
        notes: notes.present ? notes.value : this.notes,
        attachments: attachments.present ? attachments.value : this.attachments,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  FamilyMember copyWithCompanion(FamilyMembersTableCompanion data) {
    return FamilyMember(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      orphanNationalId: data.orphanNationalId.present
          ? data.orphanNationalId.value
          : this.orphanNationalId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      secondName:
          data.secondName.present ? data.secondName.value : this.secondName,
      thirdName: data.thirdName.present ? data.thirdName.value : this.thirdName,
      familyName:
          data.familyName.present ? data.familyName.value : this.familyName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      healthStatus: data.healthStatus.present
          ? data.healthStatus.value
          : this.healthStatus,
      sponsorshipStatus: data.sponsorshipStatus.present
          ? data.sponsorshipStatus.value
          : this.sponsorshipStatus,
      sponsorshipType: data.sponsorshipType.present
          ? data.sponsorshipType.value
          : this.sponsorshipType,
      sponsorName:
          data.sponsorName.present ? data.sponsorName.value : this.sponsorName,
      sponsorshipStartDate: data.sponsorshipStartDate.present
          ? data.sponsorshipStartDate.value
          : this.sponsorshipStartDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      attachments:
          data.attachments.present ? data.attachments.value : this.attachments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMember(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('orphanNationalId: $orphanNationalId, ')
          ..write('firstName: $firstName, ')
          ..write('secondName: $secondName, ')
          ..write('thirdName: $thirdName, ')
          ..write('familyName: $familyName, ')
          ..write('birthDate: $birthDate, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('sponsorshipStatus: $sponsorshipStatus, ')
          ..write('sponsorshipType: $sponsorshipType, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('sponsorshipStartDate: $sponsorshipStartDate, ')
          ..write('notes: $notes, ')
          ..write('attachments: $attachments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        beneficiaryId,
        orphanNationalId,
        firstName,
        secondName,
        thirdName,
        familyName,
        birthDate,
        age,
        gender,
        healthStatus,
        sponsorshipStatus,
        sponsorshipType,
        sponsorName,
        sponsorshipStartDate,
        notes,
        attachments,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMember &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.orphanNationalId == this.orphanNationalId &&
          other.firstName == this.firstName &&
          other.secondName == this.secondName &&
          other.thirdName == this.thirdName &&
          other.familyName == this.familyName &&
          other.birthDate == this.birthDate &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.healthStatus == this.healthStatus &&
          other.sponsorshipStatus == this.sponsorshipStatus &&
          other.sponsorshipType == this.sponsorshipType &&
          other.sponsorName == this.sponsorName &&
          other.sponsorshipStartDate == this.sponsorshipStartDate &&
          other.notes == this.notes &&
          other.attachments == this.attachments &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class FamilyMembersTableCompanion extends UpdateCompanion<FamilyMember> {
  final Value<int> id;
  final Value<int> beneficiaryId;
  final Value<int> orphanNationalId;
  final Value<String> firstName;
  final Value<String?> secondName;
  final Value<String?> thirdName;
  final Value<String> familyName;
  final Value<DateTime> birthDate;
  final Value<int?> age;
  final Value<int> gender;
  final Value<int> healthStatus;
  final Value<int?> sponsorshipStatus;
  final Value<int?> sponsorshipType;
  final Value<String?> sponsorName;
  final Value<DateTime?> sponsorshipStartDate;
  final Value<String?> notes;
  final Value<String?> attachments;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<DateTime?> lastSyncedAt;
  const FamilyMembersTableCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.orphanNationalId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.secondName = const Value.absent(),
    this.thirdName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.sponsorshipStatus = const Value.absent(),
    this.sponsorshipType = const Value.absent(),
    this.sponsorName = const Value.absent(),
    this.sponsorshipStartDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.attachments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  FamilyMembersTableCompanion.insert({
    this.id = const Value.absent(),
    required int beneficiaryId,
    required int orphanNationalId,
    required String firstName,
    this.secondName = const Value.absent(),
    this.thirdName = const Value.absent(),
    required String familyName,
    required DateTime birthDate,
    this.age = const Value.absent(),
    required int gender,
    required int healthStatus,
    this.sponsorshipStatus = const Value.absent(),
    this.sponsorshipType = const Value.absent(),
    this.sponsorName = const Value.absent(),
    this.sponsorshipStartDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.attachments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : beneficiaryId = Value(beneficiaryId),
        orphanNationalId = Value(orphanNationalId),
        firstName = Value(firstName),
        familyName = Value(familyName),
        birthDate = Value(birthDate),
        gender = Value(gender),
        healthStatus = Value(healthStatus);
  static Insertable<FamilyMember> custom({
    Expression<int>? id,
    Expression<int>? beneficiaryId,
    Expression<int>? orphanNationalId,
    Expression<String>? firstName,
    Expression<String>? secondName,
    Expression<String>? thirdName,
    Expression<String>? familyName,
    Expression<DateTime>? birthDate,
    Expression<int>? age,
    Expression<int>? gender,
    Expression<int>? healthStatus,
    Expression<int>? sponsorshipStatus,
    Expression<int>? sponsorshipType,
    Expression<String>? sponsorName,
    Expression<DateTime>? sponsorshipStartDate,
    Expression<String>? notes,
    Expression<String>? attachments,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (orphanNationalId != null) 'orphan_national_id': orphanNationalId,
      if (firstName != null) 'first_name': firstName,
      if (secondName != null) 'second_name': secondName,
      if (thirdName != null) 'third_name': thirdName,
      if (familyName != null) 'family_name': familyName,
      if (birthDate != null) 'birth_date': birthDate,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (healthStatus != null) 'health_status': healthStatus,
      if (sponsorshipStatus != null) 'sponsorship_status': sponsorshipStatus,
      if (sponsorshipType != null) 'sponsorship_type': sponsorshipType,
      if (sponsorName != null) 'sponsor_name': sponsorName,
      if (sponsorshipStartDate != null)
        'sponsorship_start_date': sponsorshipStartDate,
      if (notes != null) 'notes': notes,
      if (attachments != null) 'attachments': attachments,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  FamilyMembersTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? beneficiaryId,
      Value<int>? orphanNationalId,
      Value<String>? firstName,
      Value<String?>? secondName,
      Value<String?>? thirdName,
      Value<String>? familyName,
      Value<DateTime>? birthDate,
      Value<int?>? age,
      Value<int>? gender,
      Value<int>? healthStatus,
      Value<int?>? sponsorshipStatus,
      Value<int?>? sponsorshipType,
      Value<String?>? sponsorName,
      Value<DateTime?>? sponsorshipStartDate,
      Value<String?>? notes,
      Value<String?>? attachments,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<DateTime?>? lastSyncedAt}) {
    return FamilyMembersTableCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      orphanNationalId: orphanNationalId ?? this.orphanNationalId,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      thirdName: thirdName ?? this.thirdName,
      familyName: familyName ?? this.familyName,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      healthStatus: healthStatus ?? this.healthStatus,
      sponsorshipStatus: sponsorshipStatus ?? this.sponsorshipStatus,
      sponsorshipType: sponsorshipType ?? this.sponsorshipType,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorshipStartDate: sponsorshipStartDate ?? this.sponsorshipStartDate,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<int>(beneficiaryId.value);
    }
    if (orphanNationalId.present) {
      map['orphan_national_id'] = Variable<int>(orphanNationalId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (secondName.present) {
      map['second_name'] = Variable<String>(secondName.value);
    }
    if (thirdName.present) {
      map['third_name'] = Variable<String>(thirdName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(gender.value);
    }
    if (healthStatus.present) {
      map['health_status'] = Variable<int>(healthStatus.value);
    }
    if (sponsorshipStatus.present) {
      map['sponsorship_status'] = Variable<int>(sponsorshipStatus.value);
    }
    if (sponsorshipType.present) {
      map['sponsorship_type'] = Variable<int>(sponsorshipType.value);
    }
    if (sponsorName.present) {
      map['sponsor_name'] = Variable<String>(sponsorName.value);
    }
    if (sponsorshipStartDate.present) {
      map['sponsorship_start_date'] =
          Variable<DateTime>(sponsorshipStartDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMembersTableCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('orphanNationalId: $orphanNationalId, ')
          ..write('firstName: $firstName, ')
          ..write('secondName: $secondName, ')
          ..write('thirdName: $thirdName, ')
          ..write('familyName: $familyName, ')
          ..write('birthDate: $birthDate, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('sponsorshipStatus: $sponsorshipStatus, ')
          ..write('sponsorshipType: $sponsorshipType, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('sponsorshipStartDate: $sponsorshipStartDate, ')
          ..write('notes: $notes, ')
          ..write('attachments: $attachments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $AssociationRepresentativesTable extends AssociationRepresentatives
    with TableInfo<$AssociationRepresentativesTable, Representative> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssociationRepresentativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, createdAt, updatedAt, syncState, serverId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'association_representatives';
  @override
  VerificationContext validateIntegrity(Insertable<Representative> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Representative map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Representative(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
    );
  }

  @override
  $AssociationRepresentativesTable createAlias(String alias) {
    return $AssociationRepresentativesTable(attachedDatabase, alias);
  }
}

class Representative extends DataClass implements Insertable<Representative> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final int? serverId;
  const Representative(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState,
      this.serverId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    return map;
  }

  AssociationRepresentativesCompanion toCompanion(bool nullToAbsent) {
    return AssociationRepresentativesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory Representative.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Representative(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
    };
  }

  Representative copyWith(
          {String? id,
          String? name,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState,
          Value<int?> serverId = const Value.absent()}) =>
      Representative(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
      );
  Representative copyWithCompanion(AssociationRepresentativesCompanion data) {
    return Representative(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Representative(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, updatedAt, syncState, serverId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Representative &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId);
}

class AssociationRepresentativesCompanion
    extends UpdateCompanion<Representative> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<int> rowid;
  const AssociationRepresentativesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssociationRepresentativesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Representative> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssociationRepresentativesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<int>? rowid}) {
    return AssociationRepresentativesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociationRepresentativesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssociationsTable extends Associations
    with TableInfo<$AssociationsTable, Association> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssociationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _swiftCodeMeta =
      const VerificationMeta('swiftCode');
  @override
  late final GeneratedColumn<String> swiftCode = GeneratedColumn<String>(
      'swift_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bankPhoneMeta =
      const VerificationMeta('bankPhone');
  @override
  late final GeneratedColumn<String> bankPhone = GeneratedColumn<String>(
      'bank_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountCurrencyMeta =
      const VerificationMeta('accountCurrency');
  @override
  late final GeneratedColumn<String> accountCurrency = GeneratedColumn<String>(
      'account_currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _representativeIdMeta =
      const VerificationMeta('representativeId');
  @override
  late final GeneratedColumn<String> representativeId = GeneratedColumn<String>(
      'representative_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES association_representatives (id)'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        shortName,
        phone,
        email,
        bankName,
        accountNumber,
        swiftCode,
        bankPhone,
        accountCurrency,
        representativeId,
        isActive,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'associations';
  @override
  VerificationContext validateIntegrity(Insertable<Association> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('swift_code')) {
      context.handle(_swiftCodeMeta,
          swiftCode.isAcceptableOrUnknown(data['swift_code']!, _swiftCodeMeta));
    }
    if (data.containsKey('bank_phone')) {
      context.handle(_bankPhoneMeta,
          bankPhone.isAcceptableOrUnknown(data['bank_phone']!, _bankPhoneMeta));
    }
    if (data.containsKey('account_currency')) {
      context.handle(
          _accountCurrencyMeta,
          accountCurrency.isAcceptableOrUnknown(
              data['account_currency']!, _accountCurrencyMeta));
    }
    if (data.containsKey('representative_id')) {
      context.handle(
          _representativeIdMeta,
          representativeId.isAcceptableOrUnknown(
              data['representative_id']!, _representativeIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Association map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Association(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      swiftCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}swift_code']),
      bankPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_phone']),
      accountCurrency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_currency']),
      representativeId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}representative_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $AssociationsTable createAlias(String alias) {
    return $AssociationsTable(attachedDatabase, alias);
  }
}

class Association extends DataClass implements Insertable<Association> {
  final String id;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final int? serverId;
  final DateTime? lastSyncedAt;
  const Association(
      {required this.id,
      required this.name,
      this.shortName,
      required this.phone,
      this.email,
      required this.bankName,
      required this.accountNumber,
      this.swiftCode,
      this.bankPhone,
      this.accountCurrency,
      this.representativeId,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['bank_name'] = Variable<String>(bankName);
    map['account_number'] = Variable<String>(accountNumber);
    if (!nullToAbsent || swiftCode != null) {
      map['swift_code'] = Variable<String>(swiftCode);
    }
    if (!nullToAbsent || bankPhone != null) {
      map['bank_phone'] = Variable<String>(bankPhone);
    }
    if (!nullToAbsent || accountCurrency != null) {
      map['account_currency'] = Variable<String>(accountCurrency);
    }
    if (!nullToAbsent || representativeId != null) {
      map['representative_id'] = Variable<String>(representativeId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  AssociationsCompanion toCompanion(bool nullToAbsent) {
    return AssociationsCompanion(
      id: Value(id),
      name: Value(name),
      shortName: shortName == null && nullToAbsent
          ? const Value.absent()
          : Value(shortName),
      phone: Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      swiftCode: swiftCode == null && nullToAbsent
          ? const Value.absent()
          : Value(swiftCode),
      bankPhone: bankPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(bankPhone),
      accountCurrency: accountCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(accountCurrency),
      representativeId: representativeId == null && nullToAbsent
          ? const Value.absent()
          : Value(representativeId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Association.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Association(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String?>(json['shortName']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      bankName: serializer.fromJson<String>(json['bankName']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      swiftCode: serializer.fromJson<String?>(json['swiftCode']),
      bankPhone: serializer.fromJson<String?>(json['bankPhone']),
      accountCurrency: serializer.fromJson<String?>(json['accountCurrency']),
      representativeId: serializer.fromJson<String?>(json['representativeId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String?>(shortName),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'bankName': serializer.toJson<String>(bankName),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'swiftCode': serializer.toJson<String?>(swiftCode),
      'bankPhone': serializer.toJson<String?>(bankPhone),
      'accountCurrency': serializer.toJson<String?>(accountCurrency),
      'representativeId': serializer.toJson<String?>(representativeId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Association copyWith(
          {String? id,
          String? name,
          Value<String?> shortName = const Value.absent(),
          String? phone,
          Value<String?> email = const Value.absent(),
          String? bankName,
          String? accountNumber,
          Value<String?> swiftCode = const Value.absent(),
          Value<String?> bankPhone = const Value.absent(),
          Value<String?> accountCurrency = const Value.absent(),
          Value<String?> representativeId = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncState,
          Value<int?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Association(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName.present ? shortName.value : this.shortName,
        phone: phone ?? this.phone,
        email: email.present ? email.value : this.email,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        swiftCode: swiftCode.present ? swiftCode.value : this.swiftCode,
        bankPhone: bankPhone.present ? bankPhone.value : this.bankPhone,
        accountCurrency: accountCurrency.present
            ? accountCurrency.value
            : this.accountCurrency,
        representativeId: representativeId.present
            ? representativeId.value
            : this.representativeId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Association copyWithCompanion(AssociationsCompanion data) {
    return Association(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      swiftCode: data.swiftCode.present ? data.swiftCode.value : this.swiftCode,
      bankPhone: data.bankPhone.present ? data.bankPhone.value : this.bankPhone,
      accountCurrency: data.accountCurrency.present
          ? data.accountCurrency.value
          : this.accountCurrency,
      representativeId: data.representativeId.present
          ? data.representativeId.value
          : this.representativeId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Association(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('swiftCode: $swiftCode, ')
          ..write('bankPhone: $bankPhone, ')
          ..write('accountCurrency: $accountCurrency, ')
          ..write('representativeId: $representativeId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      shortName,
      phone,
      email,
      bankName,
      accountNumber,
      swiftCode,
      bankPhone,
      accountCurrency,
      representativeId,
      isActive,
      createdAt,
      updatedAt,
      syncState,
      serverId,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Association &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.swiftCode == this.swiftCode &&
          other.bankPhone == this.bankPhone &&
          other.accountCurrency == this.accountCurrency &&
          other.representativeId == this.representativeId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class AssociationsCompanion extends UpdateCompanion<Association> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> shortName;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String> bankName;
  final Value<String> accountNumber;
  final Value<String?> swiftCode;
  final Value<String?> bankPhone;
  final Value<String?> accountCurrency;
  final Value<String?> representativeId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const AssociationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.swiftCode = const Value.absent(),
    this.bankPhone = const Value.absent(),
    this.accountCurrency = const Value.absent(),
    this.representativeId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssociationsCompanion.insert({
    required String id,
    required String name,
    this.shortName = const Value.absent(),
    required String phone,
    this.email = const Value.absent(),
    required String bankName,
    required String accountNumber,
    this.swiftCode = const Value.absent(),
    this.bankPhone = const Value.absent(),
    this.accountCurrency = const Value.absent(),
    this.representativeId = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone),
        bankName = Value(bankName),
        accountNumber = Value(accountNumber),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Association> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? swiftCode,
    Expression<String>? bankPhone,
    Expression<String>? accountCurrency,
    Expression<String>? representativeId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (swiftCode != null) 'swift_code': swiftCode,
      if (bankPhone != null) 'bank_phone': bankPhone,
      if (accountCurrency != null) 'account_currency': accountCurrency,
      if (representativeId != null) 'representative_id': representativeId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssociationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? shortName,
      Value<String>? phone,
      Value<String?>? email,
      Value<String>? bankName,
      Value<String>? accountNumber,
      Value<String?>? swiftCode,
      Value<String?>? bankPhone,
      Value<String?>? accountCurrency,
      Value<String?>? representativeId,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return AssociationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      swiftCode: swiftCode ?? this.swiftCode,
      bankPhone: bankPhone ?? this.bankPhone,
      accountCurrency: accountCurrency ?? this.accountCurrency,
      representativeId: representativeId ?? this.representativeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (swiftCode.present) {
      map['swift_code'] = Variable<String>(swiftCode.value);
    }
    if (bankPhone.present) {
      map['bank_phone'] = Variable<String>(bankPhone.value);
    }
    if (accountCurrency.present) {
      map['account_currency'] = Variable<String>(accountCurrency.value);
    }
    if (representativeId.present) {
      map['representative_id'] = Variable<String>(representativeId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('swiftCode: $swiftCode, ')
          ..write('bankPhone: $bankPhone, ')
          ..write('accountCurrency: $accountCurrency, ')
          ..write('representativeId: $representativeId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SponsorshipsTable extends Sponsorships
    with TableInfo<$SponsorshipsTable, Sponsorship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponsorshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileNoMeta = const VerificationMeta('fileNo');
  @override
  late final GeneratedColumn<int> fileNo = GeneratedColumn<int>(
      'file_no', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _beneficiaryIdMeta =
      const VerificationMeta('beneficiaryId');
  @override
  late final GeneratedColumn<int> beneficiaryId = GeneratedColumn<int>(
      'beneficiary_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES beneficiaries (id)'));
  static const VerificationMeta _associationIdMeta =
      const VerificationMeta('associationId');
  @override
  late final GeneratedColumn<String> associationId = GeneratedColumn<String>(
      'association_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES associations (id)'));
  static const VerificationMeta _sponsorNameMeta =
      const VerificationMeta('sponsorName');
  @override
  late final GeneratedColumn<String> sponsorName = GeneratedColumn<String>(
      'sponsor_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _internalFileNoMeta =
      const VerificationMeta('internalFileNo');
  @override
  late final GeneratedColumn<String> internalFileNo = GeneratedColumn<String>(
      'internal_file_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalFileNoMeta =
      const VerificationMeta('externalFileNo');
  @override
  late final GeneratedColumn<String> externalFileNo = GeneratedColumn<String>(
      'external_file_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _guardianNameMeta =
      const VerificationMeta('guardianName');
  @override
  late final GeneratedColumn<String> guardianName = GeneratedColumn<String>(
      'guardian_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _guardianIdNumberMeta =
      const VerificationMeta('guardianIdNumber');
  @override
  late final GeneratedColumn<int> guardianIdNumber = GeneratedColumn<int>(
      'guardian_id_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _guardianPhoneMeta =
      const VerificationMeta('guardianPhone');
  @override
  late final GeneratedColumn<String> guardianPhone = GeneratedColumn<String>(
      'guardian_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _guardianAltPhoneMeta =
      const VerificationMeta('guardianAltPhone');
  @override
  late final GeneratedColumn<String> guardianAltPhone = GeneratedColumn<String>(
      'guardian_alt_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMonthsMeta =
      const VerificationMeta('durationMonths');
  @override
  late final GeneratedColumn<int> durationMonths = GeneratedColumn<int>(
      'duration_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _sponsorshipTypeMeta =
      const VerificationMeta('sponsorshipType');
  @override
  late final GeneratedColumn<String> sponsorshipType = GeneratedColumn<String>(
      'sponsorship_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monthly'));
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountHolderNameMeta =
      const VerificationMeta('accountHolderName');
  @override
  late final GeneratedColumn<String> accountHolderName =
      GeneratedColumn<String>('account_holder_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountHolderIdNumberMeta =
      const VerificationMeta('accountHolderIdNumber');
  @override
  late final GeneratedColumn<int> accountHolderIdNumber = GeneratedColumn<int>(
      'account_holder_id_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _swiftCodeMeta =
      const VerificationMeta('swiftCode');
  @override
  late final GeneratedColumn<String> swiftCode = GeneratedColumn<String>(
      'swift_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _governorateMeta =
      const VerificationMeta('governorate');
  @override
  late final GeneratedColumn<String> governorate = GeneratedColumn<String>(
      'governorate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _importBatchIdMeta =
      const VerificationMeta('importBatchId');
  @override
  late final GeneratedColumn<int> importBatchId = GeneratedColumn<int>(
      'import_batch_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        fileNo,
        beneficiaryId,
        associationId,
        sponsorName,
        internalFileNo,
        externalFileNo,
        guardianName,
        guardianIdNumber,
        guardianPhone,
        guardianAltPhone,
        durationMonths,
        startDate,
        endDate,
        amount,
        currency,
        status,
        sponsorshipType,
        bankName,
        accountHolderName,
        accountHolderIdNumber,
        accountNumber,
        swiftCode,
        governorate,
        city,
        address,
        importBatchId,
        notes,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsorships';
  @override
  VerificationContext validateIntegrity(Insertable<Sponsorship> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_no')) {
      context.handle(_fileNoMeta,
          fileNo.isAcceptableOrUnknown(data['file_no']!, _fileNoMeta));
    }
    if (data.containsKey('beneficiary_id')) {
      context.handle(
          _beneficiaryIdMeta,
          beneficiaryId.isAcceptableOrUnknown(
              data['beneficiary_id']!, _beneficiaryIdMeta));
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('association_id')) {
      context.handle(
          _associationIdMeta,
          associationId.isAcceptableOrUnknown(
              data['association_id']!, _associationIdMeta));
    } else if (isInserting) {
      context.missing(_associationIdMeta);
    }
    if (data.containsKey('sponsor_name')) {
      context.handle(
          _sponsorNameMeta,
          sponsorName.isAcceptableOrUnknown(
              data['sponsor_name']!, _sponsorNameMeta));
    }
    if (data.containsKey('internal_file_no')) {
      context.handle(
          _internalFileNoMeta,
          internalFileNo.isAcceptableOrUnknown(
              data['internal_file_no']!, _internalFileNoMeta));
    }
    if (data.containsKey('external_file_no')) {
      context.handle(
          _externalFileNoMeta,
          externalFileNo.isAcceptableOrUnknown(
              data['external_file_no']!, _externalFileNoMeta));
    }
    if (data.containsKey('guardian_name')) {
      context.handle(
          _guardianNameMeta,
          guardianName.isAcceptableOrUnknown(
              data['guardian_name']!, _guardianNameMeta));
    }
    if (data.containsKey('guardian_id_number')) {
      context.handle(
          _guardianIdNumberMeta,
          guardianIdNumber.isAcceptableOrUnknown(
              data['guardian_id_number']!, _guardianIdNumberMeta));
    }
    if (data.containsKey('guardian_phone')) {
      context.handle(
          _guardianPhoneMeta,
          guardianPhone.isAcceptableOrUnknown(
              data['guardian_phone']!, _guardianPhoneMeta));
    }
    if (data.containsKey('guardian_alt_phone')) {
      context.handle(
          _guardianAltPhoneMeta,
          guardianAltPhone.isAcceptableOrUnknown(
              data['guardian_alt_phone']!, _guardianAltPhoneMeta));
    }
    if (data.containsKey('duration_months')) {
      context.handle(
          _durationMonthsMeta,
          durationMonths.isAcceptableOrUnknown(
              data['duration_months']!, _durationMonthsMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('sponsorship_type')) {
      context.handle(
          _sponsorshipTypeMeta,
          sponsorshipType.isAcceptableOrUnknown(
              data['sponsorship_type']!, _sponsorshipTypeMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('account_holder_name')) {
      context.handle(
          _accountHolderNameMeta,
          accountHolderName.isAcceptableOrUnknown(
              data['account_holder_name']!, _accountHolderNameMeta));
    }
    if (data.containsKey('account_holder_id_number')) {
      context.handle(
          _accountHolderIdNumberMeta,
          accountHolderIdNumber.isAcceptableOrUnknown(
              data['account_holder_id_number']!, _accountHolderIdNumberMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('swift_code')) {
      context.handle(_swiftCodeMeta,
          swiftCode.isAcceptableOrUnknown(data['swift_code']!, _swiftCodeMeta));
    }
    if (data.containsKey('governorate')) {
      context.handle(
          _governorateMeta,
          governorate.isAcceptableOrUnknown(
              data['governorate']!, _governorateMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('import_batch_id')) {
      context.handle(
          _importBatchIdMeta,
          importBatchId.isAcceptableOrUnknown(
              data['import_batch_id']!, _importBatchIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileNo};
  @override
  Sponsorship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sponsorship(
      fileNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_no'])!,
      beneficiaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}beneficiary_id'])!,
      associationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}association_id'])!,
      sponsorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sponsor_name']),
      internalFileNo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}internal_file_no']),
      externalFileNo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_file_no']),
      guardianName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guardian_name']),
      guardianIdNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}guardian_id_number']),
      guardianPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guardian_phone']),
      guardianAltPhone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}guardian_alt_phone']),
      durationMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_months']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      sponsorshipType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sponsorship_type'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      accountHolderName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_holder_name']),
      accountHolderIdNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}account_holder_id_number']),
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number']),
      swiftCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}swift_code']),
      governorate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}governorate']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      importBatchId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}import_batch_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SponsorshipsTable createAlias(String alias) {
    return $SponsorshipsTable(attachedDatabase, alias);
  }
}

class Sponsorship extends DataClass implements Insertable<Sponsorship> {
  /// رقم الملف (File No) - فريد على مستوى النظام (Auto-generated)
  final int fileNo;

  /// Foreign keys
  final int beneficiaryId;
  final String associationId;

  /// اسم الكافل (الشخص أو المؤسسة)
  final String? sponsorName;

  /// رقم الملف الداخلي (Internal File Number)
  final String? internalFileNo;

  /// رقم الملف الخارجي (External File Number)
  final String? externalFileNo;

  /// اسم المعيل (Guardian Name)
  final String? guardianName;

  /// رقم هوية المعيل (Guardian ID Number)
  final int? guardianIdNumber;

  /// رقم هاتف المعيل (Guardian Phone)
  final String? guardianPhone;

  /// جوال بديل للمعيل (Guardian Alt Phone)
  final String? guardianAltPhone;

  /// مدة الكفالة بالأشهر (Sponsorship Duration in Months)
  final int? durationMonths;
  final DateTime? startDate;
  final DateTime? endDate;

  /// القيمة المالية
  final double? amount;
  final String? currency;

  /// active | paused | ended
  final String status;

  /// monthly | one_time | other
  final String sponsorshipType;

  /// اسم البنك (Bank Name)
  final String? bankName;

  /// اسم صاحب الحساب (Account Holder Name)
  final String? accountHolderName;

  /// رقم هوية صاحب الحساب (Account Holder ID)
  final int? accountHolderIdNumber;

  /// رقم الحساب البنكي (Account Number)
  final String? accountNumber;

  /// رمز Swift (Swift Code)
  final String? swiftCode;

  /// المحافظة (Governorate)
  final String? governorate;

  /// المدينة (City)
  final String? city;

  /// العنوان التفصيلي (Detailed Address)
  final String? address;

  /// Optional link to import_batches.id
  final int? importBatchId;
  final String? notes;

  /// System fields
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Sync fields (kept consistent with other tables)
  final String syncState;
  final int? serverId;
  final DateTime? lastSyncedAt;
  const Sponsorship(
      {required this.fileNo,
      required this.beneficiaryId,
      required this.associationId,
      this.sponsorName,
      this.internalFileNo,
      this.externalFileNo,
      this.guardianName,
      this.guardianIdNumber,
      this.guardianPhone,
      this.guardianAltPhone,
      this.durationMonths,
      this.startDate,
      this.endDate,
      this.amount,
      this.currency,
      required this.status,
      required this.sponsorshipType,
      this.bankName,
      this.accountHolderName,
      this.accountHolderIdNumber,
      this.accountNumber,
      this.swiftCode,
      this.governorate,
      this.city,
      this.address,
      this.importBatchId,
      this.notes,
      required this.createdAt,
      this.updatedAt,
      required this.syncState,
      this.serverId,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_no'] = Variable<int>(fileNo);
    map['beneficiary_id'] = Variable<int>(beneficiaryId);
    map['association_id'] = Variable<String>(associationId);
    if (!nullToAbsent || sponsorName != null) {
      map['sponsor_name'] = Variable<String>(sponsorName);
    }
    if (!nullToAbsent || internalFileNo != null) {
      map['internal_file_no'] = Variable<String>(internalFileNo);
    }
    if (!nullToAbsent || externalFileNo != null) {
      map['external_file_no'] = Variable<String>(externalFileNo);
    }
    if (!nullToAbsent || guardianName != null) {
      map['guardian_name'] = Variable<String>(guardianName);
    }
    if (!nullToAbsent || guardianIdNumber != null) {
      map['guardian_id_number'] = Variable<int>(guardianIdNumber);
    }
    if (!nullToAbsent || guardianPhone != null) {
      map['guardian_phone'] = Variable<String>(guardianPhone);
    }
    if (!nullToAbsent || guardianAltPhone != null) {
      map['guardian_alt_phone'] = Variable<String>(guardianAltPhone);
    }
    if (!nullToAbsent || durationMonths != null) {
      map['duration_months'] = Variable<int>(durationMonths);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['status'] = Variable<String>(status);
    map['sponsorship_type'] = Variable<String>(sponsorshipType);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || accountHolderName != null) {
      map['account_holder_name'] = Variable<String>(accountHolderName);
    }
    if (!nullToAbsent || accountHolderIdNumber != null) {
      map['account_holder_id_number'] = Variable<int>(accountHolderIdNumber);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || swiftCode != null) {
      map['swift_code'] = Variable<String>(swiftCode);
    }
    if (!nullToAbsent || governorate != null) {
      map['governorate'] = Variable<String>(governorate);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<int>(importBatchId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SponsorshipsCompanion toCompanion(bool nullToAbsent) {
    return SponsorshipsCompanion(
      fileNo: Value(fileNo),
      beneficiaryId: Value(beneficiaryId),
      associationId: Value(associationId),
      sponsorName: sponsorName == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorName),
      internalFileNo: internalFileNo == null && nullToAbsent
          ? const Value.absent()
          : Value(internalFileNo),
      externalFileNo: externalFileNo == null && nullToAbsent
          ? const Value.absent()
          : Value(externalFileNo),
      guardianName: guardianName == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianName),
      guardianIdNumber: guardianIdNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianIdNumber),
      guardianPhone: guardianPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianPhone),
      guardianAltPhone: guardianAltPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianAltPhone),
      durationMonths: durationMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMonths),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      status: Value(status),
      sponsorshipType: Value(sponsorshipType),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      accountHolderName: accountHolderName == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHolderName),
      accountHolderIdNumber: accountHolderIdNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountHolderIdNumber),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      swiftCode: swiftCode == null && nullToAbsent
          ? const Value.absent()
          : Value(swiftCode),
      governorate: governorate == null && nullToAbsent
          ? const Value.absent()
          : Value(governorate),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory Sponsorship.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sponsorship(
      fileNo: serializer.fromJson<int>(json['fileNo']),
      beneficiaryId: serializer.fromJson<int>(json['beneficiaryId']),
      associationId: serializer.fromJson<String>(json['associationId']),
      sponsorName: serializer.fromJson<String?>(json['sponsorName']),
      internalFileNo: serializer.fromJson<String?>(json['internalFileNo']),
      externalFileNo: serializer.fromJson<String?>(json['externalFileNo']),
      guardianName: serializer.fromJson<String?>(json['guardianName']),
      guardianIdNumber: serializer.fromJson<int?>(json['guardianIdNumber']),
      guardianPhone: serializer.fromJson<String?>(json['guardianPhone']),
      guardianAltPhone: serializer.fromJson<String?>(json['guardianAltPhone']),
      durationMonths: serializer.fromJson<int?>(json['durationMonths']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      amount: serializer.fromJson<double?>(json['amount']),
      currency: serializer.fromJson<String?>(json['currency']),
      status: serializer.fromJson<String>(json['status']),
      sponsorshipType: serializer.fromJson<String>(json['sponsorshipType']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      accountHolderName:
          serializer.fromJson<String?>(json['accountHolderName']),
      accountHolderIdNumber:
          serializer.fromJson<int?>(json['accountHolderIdNumber']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      swiftCode: serializer.fromJson<String?>(json['swiftCode']),
      governorate: serializer.fromJson<String?>(json['governorate']),
      city: serializer.fromJson<String?>(json['city']),
      address: serializer.fromJson<String?>(json['address']),
      importBatchId: serializer.fromJson<int?>(json['importBatchId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileNo': serializer.toJson<int>(fileNo),
      'beneficiaryId': serializer.toJson<int>(beneficiaryId),
      'associationId': serializer.toJson<String>(associationId),
      'sponsorName': serializer.toJson<String?>(sponsorName),
      'internalFileNo': serializer.toJson<String?>(internalFileNo),
      'externalFileNo': serializer.toJson<String?>(externalFileNo),
      'guardianName': serializer.toJson<String?>(guardianName),
      'guardianIdNumber': serializer.toJson<int?>(guardianIdNumber),
      'guardianPhone': serializer.toJson<String?>(guardianPhone),
      'guardianAltPhone': serializer.toJson<String?>(guardianAltPhone),
      'durationMonths': serializer.toJson<int?>(durationMonths),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'amount': serializer.toJson<double?>(amount),
      'currency': serializer.toJson<String?>(currency),
      'status': serializer.toJson<String>(status),
      'sponsorshipType': serializer.toJson<String>(sponsorshipType),
      'bankName': serializer.toJson<String?>(bankName),
      'accountHolderName': serializer.toJson<String?>(accountHolderName),
      'accountHolderIdNumber': serializer.toJson<int?>(accountHolderIdNumber),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'swiftCode': serializer.toJson<String?>(swiftCode),
      'governorate': serializer.toJson<String?>(governorate),
      'city': serializer.toJson<String?>(city),
      'address': serializer.toJson<String?>(address),
      'importBatchId': serializer.toJson<int?>(importBatchId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<int?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Sponsorship copyWith(
          {int? fileNo,
          int? beneficiaryId,
          String? associationId,
          Value<String?> sponsorName = const Value.absent(),
          Value<String?> internalFileNo = const Value.absent(),
          Value<String?> externalFileNo = const Value.absent(),
          Value<String?> guardianName = const Value.absent(),
          Value<int?> guardianIdNumber = const Value.absent(),
          Value<String?> guardianPhone = const Value.absent(),
          Value<String?> guardianAltPhone = const Value.absent(),
          Value<int?> durationMonths = const Value.absent(),
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<double?> amount = const Value.absent(),
          Value<String?> currency = const Value.absent(),
          String? status,
          String? sponsorshipType,
          Value<String?> bankName = const Value.absent(),
          Value<String?> accountHolderName = const Value.absent(),
          Value<int?> accountHolderIdNumber = const Value.absent(),
          Value<String?> accountNumber = const Value.absent(),
          Value<String?> swiftCode = const Value.absent(),
          Value<String?> governorate = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<int?> importBatchId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? syncState,
          Value<int?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      Sponsorship(
        fileNo: fileNo ?? this.fileNo,
        beneficiaryId: beneficiaryId ?? this.beneficiaryId,
        associationId: associationId ?? this.associationId,
        sponsorName: sponsorName.present ? sponsorName.value : this.sponsorName,
        internalFileNo:
            internalFileNo.present ? internalFileNo.value : this.internalFileNo,
        externalFileNo:
            externalFileNo.present ? externalFileNo.value : this.externalFileNo,
        guardianName:
            guardianName.present ? guardianName.value : this.guardianName,
        guardianIdNumber: guardianIdNumber.present
            ? guardianIdNumber.value
            : this.guardianIdNumber,
        guardianPhone:
            guardianPhone.present ? guardianPhone.value : this.guardianPhone,
        guardianAltPhone: guardianAltPhone.present
            ? guardianAltPhone.value
            : this.guardianAltPhone,
        durationMonths:
            durationMonths.present ? durationMonths.value : this.durationMonths,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        amount: amount.present ? amount.value : this.amount,
        currency: currency.present ? currency.value : this.currency,
        status: status ?? this.status,
        sponsorshipType: sponsorshipType ?? this.sponsorshipType,
        bankName: bankName.present ? bankName.value : this.bankName,
        accountHolderName: accountHolderName.present
            ? accountHolderName.value
            : this.accountHolderName,
        accountHolderIdNumber: accountHolderIdNumber.present
            ? accountHolderIdNumber.value
            : this.accountHolderIdNumber,
        accountNumber:
            accountNumber.present ? accountNumber.value : this.accountNumber,
        swiftCode: swiftCode.present ? swiftCode.value : this.swiftCode,
        governorate: governorate.present ? governorate.value : this.governorate,
        city: city.present ? city.value : this.city,
        address: address.present ? address.value : this.address,
        importBatchId:
            importBatchId.present ? importBatchId.value : this.importBatchId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        syncState: syncState ?? this.syncState,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  Sponsorship copyWithCompanion(SponsorshipsCompanion data) {
    return Sponsorship(
      fileNo: data.fileNo.present ? data.fileNo.value : this.fileNo,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      associationId: data.associationId.present
          ? data.associationId.value
          : this.associationId,
      sponsorName:
          data.sponsorName.present ? data.sponsorName.value : this.sponsorName,
      internalFileNo: data.internalFileNo.present
          ? data.internalFileNo.value
          : this.internalFileNo,
      externalFileNo: data.externalFileNo.present
          ? data.externalFileNo.value
          : this.externalFileNo,
      guardianName: data.guardianName.present
          ? data.guardianName.value
          : this.guardianName,
      guardianIdNumber: data.guardianIdNumber.present
          ? data.guardianIdNumber.value
          : this.guardianIdNumber,
      guardianPhone: data.guardianPhone.present
          ? data.guardianPhone.value
          : this.guardianPhone,
      guardianAltPhone: data.guardianAltPhone.present
          ? data.guardianAltPhone.value
          : this.guardianAltPhone,
      durationMonths: data.durationMonths.present
          ? data.durationMonths.value
          : this.durationMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      sponsorshipType: data.sponsorshipType.present
          ? data.sponsorshipType.value
          : this.sponsorshipType,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountHolderName: data.accountHolderName.present
          ? data.accountHolderName.value
          : this.accountHolderName,
      accountHolderIdNumber: data.accountHolderIdNumber.present
          ? data.accountHolderIdNumber.value
          : this.accountHolderIdNumber,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      swiftCode: data.swiftCode.present ? data.swiftCode.value : this.swiftCode,
      governorate:
          data.governorate.present ? data.governorate.value : this.governorate,
      city: data.city.present ? data.city.value : this.city,
      address: data.address.present ? data.address.value : this.address,
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sponsorship(')
          ..write('fileNo: $fileNo, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('associationId: $associationId, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('internalFileNo: $internalFileNo, ')
          ..write('externalFileNo: $externalFileNo, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianIdNumber: $guardianIdNumber, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('guardianAltPhone: $guardianAltPhone, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('sponsorshipType: $sponsorshipType, ')
          ..write('bankName: $bankName, ')
          ..write('accountHolderName: $accountHolderName, ')
          ..write('accountHolderIdNumber: $accountHolderIdNumber, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('swiftCode: $swiftCode, ')
          ..write('governorate: $governorate, ')
          ..write('city: $city, ')
          ..write('address: $address, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        fileNo,
        beneficiaryId,
        associationId,
        sponsorName,
        internalFileNo,
        externalFileNo,
        guardianName,
        guardianIdNumber,
        guardianPhone,
        guardianAltPhone,
        durationMonths,
        startDate,
        endDate,
        amount,
        currency,
        status,
        sponsorshipType,
        bankName,
        accountHolderName,
        accountHolderIdNumber,
        accountNumber,
        swiftCode,
        governorate,
        city,
        address,
        importBatchId,
        notes,
        createdAt,
        updatedAt,
        syncState,
        serverId,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sponsorship &&
          other.fileNo == this.fileNo &&
          other.beneficiaryId == this.beneficiaryId &&
          other.associationId == this.associationId &&
          other.sponsorName == this.sponsorName &&
          other.internalFileNo == this.internalFileNo &&
          other.externalFileNo == this.externalFileNo &&
          other.guardianName == this.guardianName &&
          other.guardianIdNumber == this.guardianIdNumber &&
          other.guardianPhone == this.guardianPhone &&
          other.guardianAltPhone == this.guardianAltPhone &&
          other.durationMonths == this.durationMonths &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.sponsorshipType == this.sponsorshipType &&
          other.bankName == this.bankName &&
          other.accountHolderName == this.accountHolderName &&
          other.accountHolderIdNumber == this.accountHolderIdNumber &&
          other.accountNumber == this.accountNumber &&
          other.swiftCode == this.swiftCode &&
          other.governorate == this.governorate &&
          other.city == this.city &&
          other.address == this.address &&
          other.importBatchId == this.importBatchId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SponsorshipsCompanion extends UpdateCompanion<Sponsorship> {
  final Value<int> fileNo;
  final Value<int> beneficiaryId;
  final Value<String> associationId;
  final Value<String?> sponsorName;
  final Value<String?> internalFileNo;
  final Value<String?> externalFileNo;
  final Value<String?> guardianName;
  final Value<int?> guardianIdNumber;
  final Value<String?> guardianPhone;
  final Value<String?> guardianAltPhone;
  final Value<int?> durationMonths;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<double?> amount;
  final Value<String?> currency;
  final Value<String> status;
  final Value<String> sponsorshipType;
  final Value<String?> bankName;
  final Value<String?> accountHolderName;
  final Value<int?> accountHolderIdNumber;
  final Value<String?> accountNumber;
  final Value<String?> swiftCode;
  final Value<String?> governorate;
  final Value<String?> city;
  final Value<String?> address;
  final Value<int?> importBatchId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncState;
  final Value<int?> serverId;
  final Value<DateTime?> lastSyncedAt;
  const SponsorshipsCompanion({
    this.fileNo = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.associationId = const Value.absent(),
    this.sponsorName = const Value.absent(),
    this.internalFileNo = const Value.absent(),
    this.externalFileNo = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.guardianIdNumber = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.guardianAltPhone = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.sponsorshipType = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountHolderName = const Value.absent(),
    this.accountHolderIdNumber = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.swiftCode = const Value.absent(),
    this.governorate = const Value.absent(),
    this.city = const Value.absent(),
    this.address = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SponsorshipsCompanion.insert({
    this.fileNo = const Value.absent(),
    required int beneficiaryId,
    required String associationId,
    this.sponsorName = const Value.absent(),
    this.internalFileNo = const Value.absent(),
    this.externalFileNo = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.guardianIdNumber = const Value.absent(),
    this.guardianPhone = const Value.absent(),
    this.guardianAltPhone = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.sponsorshipType = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountHolderName = const Value.absent(),
    this.accountHolderIdNumber = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.swiftCode = const Value.absent(),
    this.governorate = const Value.absent(),
    this.city = const Value.absent(),
    this.address = const Value.absent(),
    this.importBatchId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  })  : beneficiaryId = Value(beneficiaryId),
        associationId = Value(associationId);
  static Insertable<Sponsorship> custom({
    Expression<int>? fileNo,
    Expression<int>? beneficiaryId,
    Expression<String>? associationId,
    Expression<String>? sponsorName,
    Expression<String>? internalFileNo,
    Expression<String>? externalFileNo,
    Expression<String>? guardianName,
    Expression<int>? guardianIdNumber,
    Expression<String>? guardianPhone,
    Expression<String>? guardianAltPhone,
    Expression<int>? durationMonths,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<String>? sponsorshipType,
    Expression<String>? bankName,
    Expression<String>? accountHolderName,
    Expression<int>? accountHolderIdNumber,
    Expression<String>? accountNumber,
    Expression<String>? swiftCode,
    Expression<String>? governorate,
    Expression<String>? city,
    Expression<String>? address,
    Expression<int>? importBatchId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? serverId,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (fileNo != null) 'file_no': fileNo,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (associationId != null) 'association_id': associationId,
      if (sponsorName != null) 'sponsor_name': sponsorName,
      if (internalFileNo != null) 'internal_file_no': internalFileNo,
      if (externalFileNo != null) 'external_file_no': externalFileNo,
      if (guardianName != null) 'guardian_name': guardianName,
      if (guardianIdNumber != null) 'guardian_id_number': guardianIdNumber,
      if (guardianPhone != null) 'guardian_phone': guardianPhone,
      if (guardianAltPhone != null) 'guardian_alt_phone': guardianAltPhone,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (sponsorshipType != null) 'sponsorship_type': sponsorshipType,
      if (bankName != null) 'bank_name': bankName,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (accountHolderIdNumber != null)
        'account_holder_id_number': accountHolderIdNumber,
      if (accountNumber != null) 'account_number': accountNumber,
      if (swiftCode != null) 'swift_code': swiftCode,
      if (governorate != null) 'governorate': governorate,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (importBatchId != null) 'import_batch_id': importBatchId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SponsorshipsCompanion copyWith(
      {Value<int>? fileNo,
      Value<int>? beneficiaryId,
      Value<String>? associationId,
      Value<String?>? sponsorName,
      Value<String?>? internalFileNo,
      Value<String?>? externalFileNo,
      Value<String?>? guardianName,
      Value<int?>? guardianIdNumber,
      Value<String?>? guardianPhone,
      Value<String?>? guardianAltPhone,
      Value<int?>? durationMonths,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<double?>? amount,
      Value<String?>? currency,
      Value<String>? status,
      Value<String>? sponsorshipType,
      Value<String?>? bankName,
      Value<String?>? accountHolderName,
      Value<int?>? accountHolderIdNumber,
      Value<String?>? accountNumber,
      Value<String?>? swiftCode,
      Value<String?>? governorate,
      Value<String?>? city,
      Value<String?>? address,
      Value<int?>? importBatchId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? syncState,
      Value<int?>? serverId,
      Value<DateTime?>? lastSyncedAt}) {
    return SponsorshipsCompanion(
      fileNo: fileNo ?? this.fileNo,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      associationId: associationId ?? this.associationId,
      sponsorName: sponsorName ?? this.sponsorName,
      internalFileNo: internalFileNo ?? this.internalFileNo,
      externalFileNo: externalFileNo ?? this.externalFileNo,
      guardianName: guardianName ?? this.guardianName,
      guardianIdNumber: guardianIdNumber ?? this.guardianIdNumber,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianAltPhone: guardianAltPhone ?? this.guardianAltPhone,
      durationMonths: durationMonths ?? this.durationMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      sponsorshipType: sponsorshipType ?? this.sponsorshipType,
      bankName: bankName ?? this.bankName,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountHolderIdNumber:
          accountHolderIdNumber ?? this.accountHolderIdNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      swiftCode: swiftCode ?? this.swiftCode,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      address: address ?? this.address,
      importBatchId: importBatchId ?? this.importBatchId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileNo.present) {
      map['file_no'] = Variable<int>(fileNo.value);
    }
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<int>(beneficiaryId.value);
    }
    if (associationId.present) {
      map['association_id'] = Variable<String>(associationId.value);
    }
    if (sponsorName.present) {
      map['sponsor_name'] = Variable<String>(sponsorName.value);
    }
    if (internalFileNo.present) {
      map['internal_file_no'] = Variable<String>(internalFileNo.value);
    }
    if (externalFileNo.present) {
      map['external_file_no'] = Variable<String>(externalFileNo.value);
    }
    if (guardianName.present) {
      map['guardian_name'] = Variable<String>(guardianName.value);
    }
    if (guardianIdNumber.present) {
      map['guardian_id_number'] = Variable<int>(guardianIdNumber.value);
    }
    if (guardianPhone.present) {
      map['guardian_phone'] = Variable<String>(guardianPhone.value);
    }
    if (guardianAltPhone.present) {
      map['guardian_alt_phone'] = Variable<String>(guardianAltPhone.value);
    }
    if (durationMonths.present) {
      map['duration_months'] = Variable<int>(durationMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sponsorshipType.present) {
      map['sponsorship_type'] = Variable<String>(sponsorshipType.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountHolderName.present) {
      map['account_holder_name'] = Variable<String>(accountHolderName.value);
    }
    if (accountHolderIdNumber.present) {
      map['account_holder_id_number'] =
          Variable<int>(accountHolderIdNumber.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (swiftCode.present) {
      map['swift_code'] = Variable<String>(swiftCode.value);
    }
    if (governorate.present) {
      map['governorate'] = Variable<String>(governorate.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<int>(importBatchId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponsorshipsCompanion(')
          ..write('fileNo: $fileNo, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('associationId: $associationId, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('internalFileNo: $internalFileNo, ')
          ..write('externalFileNo: $externalFileNo, ')
          ..write('guardianName: $guardianName, ')
          ..write('guardianIdNumber: $guardianIdNumber, ')
          ..write('guardianPhone: $guardianPhone, ')
          ..write('guardianAltPhone: $guardianAltPhone, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('sponsorshipType: $sponsorshipType, ')
          ..write('bankName: $bankName, ')
          ..write('accountHolderName: $accountHolderName, ')
          ..write('accountHolderIdNumber: $accountHolderIdNumber, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('swiftCode: $swiftCode, ')
          ..write('governorate: $governorate, ')
          ..write('city: $city, ')
          ..write('address: $address, ')
          ..write('importBatchId: $importBatchId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BeneficiariesTable beneficiaries = $BeneficiariesTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $TaxonomiesTable taxonomies = $TaxonomiesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SyncMetadataTableTable syncMetadataTable =
      $SyncMetadataTableTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $FamilyDeceasedTableTable familyDeceasedTable =
      $FamilyDeceasedTableTable(this);
  late final $FamilyMembersTableTable familyMembersTable =
      $FamilyMembersTableTable(this);
  late final $AssociationRepresentativesTable associationRepresentatives =
      $AssociationRepresentativesTable(this);
  late final $AssociationsTable associations = $AssociationsTable(this);
  late final $SponsorshipsTable sponsorships = $SponsorshipsTable(this);
  late final BeneficiariesDao beneficiariesDao =
      BeneficiariesDao(this as AppDatabase);
  late final VisitsDao visitsDao = VisitsDao(this as AppDatabase);
  late final AttachmentsDao attachmentsDao =
      AttachmentsDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final TrackingDao trackingDao = TrackingDao(this as AppDatabase);
  late final TaxonomiesDao taxonomiesDao = TaxonomiesDao(this as AppDatabase);
  late final SyncMetadataDao syncMetadataDao =
      SyncMetadataDao(this as AppDatabase);
  late final FamilyDeceasedDao familyDeceasedDao =
      FamilyDeceasedDao(this as AppDatabase);
  late final FamilyMembersDao familyMembersDao =
      FamilyMembersDao(this as AppDatabase);
  late final AssociationsDao associationsDao =
      AssociationsDao(this as AppDatabase);
  late final SponsorshipsDao sponsorshipsDao =
      SponsorshipsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        beneficiaries,
        visits,
        attachments,
        taxonomies,
        syncQueue,
        syncMetadataTable,
        activities,
        familyDeceasedTable,
        familyMembersTable,
        associationRepresentatives,
        associations,
        sponsorships
      ];
}

typedef $$BeneficiariesTableCreateCompanionBuilder = BeneficiariesCompanion
    Function({
  Value<int> id,
  Value<String?> fileIdNumber,
  Value<String?> originalFileIdFromExcel,
  Value<int?> sectionId,
  Value<int> requestStatus,
  required int idNumber,
  Value<String?> firstName,
  Value<String?> fatherName,
  Value<String?> grandFatherName,
  Value<String?> familyName,
  Value<int?> relationship,
  Value<DateTime?> birthDate,
  Value<int?> gender,
  required int phoneNumber,
  required int altPhoneNumber,
  Value<int?> numberOfIndividuals,
  Value<int?> maritalStatus,
  Value<int?> numberOfMales,
  Value<int?> numberOfFemales,
  Value<int?> academicQualification,
  Value<int?> employmentStatusBreadwinner,
  Value<int?> displacementStatus,
  Value<String?> addressBeforeDisplacement,
  Value<String?> currentAddress,
  Value<int?> city,
  Value<int?> province,
  Value<int?> healthStatus,
  Value<int?> numberOfIndividualsWithChronicDiseases,
  Value<int?> numberOfPeopleWithSpecialNeeds,
  Value<int?> housingStatus,
  Value<int?> currentHousingType,
  Value<String?> descriptionNeeds,
  Value<String?> userInsertData,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<String?> fullNameNorm,
});
typedef $$BeneficiariesTableUpdateCompanionBuilder = BeneficiariesCompanion
    Function({
  Value<int> id,
  Value<String?> fileIdNumber,
  Value<String?> originalFileIdFromExcel,
  Value<int?> sectionId,
  Value<int> requestStatus,
  Value<int> idNumber,
  Value<String?> firstName,
  Value<String?> fatherName,
  Value<String?> grandFatherName,
  Value<String?> familyName,
  Value<int?> relationship,
  Value<DateTime?> birthDate,
  Value<int?> gender,
  Value<int> phoneNumber,
  Value<int> altPhoneNumber,
  Value<int?> numberOfIndividuals,
  Value<int?> maritalStatus,
  Value<int?> numberOfMales,
  Value<int?> numberOfFemales,
  Value<int?> academicQualification,
  Value<int?> employmentStatusBreadwinner,
  Value<int?> displacementStatus,
  Value<String?> addressBeforeDisplacement,
  Value<String?> currentAddress,
  Value<int?> city,
  Value<int?> province,
  Value<int?> healthStatus,
  Value<int?> numberOfIndividualsWithChronicDiseases,
  Value<int?> numberOfPeopleWithSpecialNeeds,
  Value<int?> housingStatus,
  Value<int?> currentHousingType,
  Value<String?> descriptionNeeds,
  Value<String?> userInsertData,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<String?> fullNameNorm,
});

final class $$BeneficiariesTableReferences
    extends BaseReferences<_$AppDatabase, $BeneficiariesTable, Beneficiary> {
  $$BeneficiariesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SponsorshipsTable, List<Sponsorship>>
      _sponsorshipsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sponsorships,
              aliasName: $_aliasNameGenerator(
                  db.beneficiaries.id, db.sponsorships.beneficiaryId));

  $$SponsorshipsTableProcessedTableManager get sponsorshipsRefs {
    final manager = $$SponsorshipsTableTableManager($_db, $_db.sponsorships)
        .filter((f) => f.beneficiaryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sponsorshipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BeneficiariesTableFilterComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileIdNumber => $composableBuilder(
      column: $table.fileIdNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFileIdFromExcel => $composableBuilder(
      column: $table.originalFileIdFromExcel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requestStatus => $composableBuilder(
      column: $table.requestStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get idNumber => $composableBuilder(
      column: $table.idNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grandFatherName => $composableBuilder(
      column: $table.grandFatherName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get altPhoneNumber => $composableBuilder(
      column: $table.altPhoneNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfIndividuals => $composableBuilder(
      column: $table.numberOfIndividuals,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfMales => $composableBuilder(
      column: $table.numberOfMales, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfFemales => $composableBuilder(
      column: $table.numberOfFemales,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get academicQualification => $composableBuilder(
      column: $table.academicQualification,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get employmentStatusBreadwinner => $composableBuilder(
      column: $table.employmentStatusBreadwinner,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displacementStatus => $composableBuilder(
      column: $table.displacementStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressBeforeDisplacement => $composableBuilder(
      column: $table.addressBeforeDisplacement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentAddress => $composableBuilder(
      column: $table.currentAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfIndividualsWithChronicDiseases =>
      $composableBuilder(
          column: $table.numberOfIndividualsWithChronicDiseases,
          builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfPeopleWithSpecialNeeds => $composableBuilder(
      column: $table.numberOfPeopleWithSpecialNeeds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get housingStatus => $composableBuilder(
      column: $table.housingStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHousingType => $composableBuilder(
      column: $table.currentHousingType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionNeeds => $composableBuilder(
      column: $table.descriptionNeeds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userInsertData => $composableBuilder(
      column: $table.userInsertData,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm, builder: (column) => ColumnFilters(column));

  Expression<bool> sponsorshipsRefs(
      Expression<bool> Function($$SponsorshipsTableFilterComposer f) f) {
    final $$SponsorshipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sponsorships,
        getReferencedColumn: (t) => t.beneficiaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SponsorshipsTableFilterComposer(
              $db: $db,
              $table: $db.sponsorships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BeneficiariesTableOrderingComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileIdNumber => $composableBuilder(
      column: $table.fileIdNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFileIdFromExcel => $composableBuilder(
      column: $table.originalFileIdFromExcel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requestStatus => $composableBuilder(
      column: $table.requestStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get idNumber => $composableBuilder(
      column: $table.idNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grandFatherName => $composableBuilder(
      column: $table.grandFatherName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get relationship => $composableBuilder(
      column: $table.relationship,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get altPhoneNumber => $composableBuilder(
      column: $table.altPhoneNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfIndividuals => $composableBuilder(
      column: $table.numberOfIndividuals,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfMales => $composableBuilder(
      column: $table.numberOfMales,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfFemales => $composableBuilder(
      column: $table.numberOfFemales,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get academicQualification => $composableBuilder(
      column: $table.academicQualification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get employmentStatusBreadwinner => $composableBuilder(
      column: $table.employmentStatusBreadwinner,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displacementStatus => $composableBuilder(
      column: $table.displacementStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressBeforeDisplacement => $composableBuilder(
      column: $table.addressBeforeDisplacement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentAddress => $composableBuilder(
      column: $table.currentAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfIndividualsWithChronicDiseases =>
      $composableBuilder(
          column: $table.numberOfIndividualsWithChronicDiseases,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfPeopleWithSpecialNeeds => $composableBuilder(
      column: $table.numberOfPeopleWithSpecialNeeds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get housingStatus => $composableBuilder(
      column: $table.housingStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHousingType => $composableBuilder(
      column: $table.currentHousingType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionNeeds => $composableBuilder(
      column: $table.descriptionNeeds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userInsertData => $composableBuilder(
      column: $table.userInsertData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm,
      builder: (column) => ColumnOrderings(column));
}

class $$BeneficiariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileIdNumber => $composableBuilder(
      column: $table.fileIdNumber, builder: (column) => column);

  GeneratedColumn<String> get originalFileIdFromExcel => $composableBuilder(
      column: $table.originalFileIdFromExcel, builder: (column) => column);

  GeneratedColumn<int> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get requestStatus => $composableBuilder(
      column: $table.requestStatus, builder: (column) => column);

  GeneratedColumn<int> get idNumber =>
      $composableBuilder(column: $table.idNumber, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => column);

  GeneratedColumn<String> get grandFatherName => $composableBuilder(
      column: $table.grandFatherName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => column);

  GeneratedColumn<int> get relationship => $composableBuilder(
      column: $table.relationship, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<int> get altPhoneNumber => $composableBuilder(
      column: $table.altPhoneNumber, builder: (column) => column);

  GeneratedColumn<int> get numberOfIndividuals => $composableBuilder(
      column: $table.numberOfIndividuals, builder: (column) => column);

  GeneratedColumn<int> get maritalStatus => $composableBuilder(
      column: $table.maritalStatus, builder: (column) => column);

  GeneratedColumn<int> get numberOfMales => $composableBuilder(
      column: $table.numberOfMales, builder: (column) => column);

  GeneratedColumn<int> get numberOfFemales => $composableBuilder(
      column: $table.numberOfFemales, builder: (column) => column);

  GeneratedColumn<int> get academicQualification => $composableBuilder(
      column: $table.academicQualification, builder: (column) => column);

  GeneratedColumn<int> get employmentStatusBreadwinner => $composableBuilder(
      column: $table.employmentStatusBreadwinner, builder: (column) => column);

  GeneratedColumn<int> get displacementStatus => $composableBuilder(
      column: $table.displacementStatus, builder: (column) => column);

  GeneratedColumn<String> get addressBeforeDisplacement => $composableBuilder(
      column: $table.addressBeforeDisplacement, builder: (column) => column);

  GeneratedColumn<String> get currentAddress => $composableBuilder(
      column: $table.currentAddress, builder: (column) => column);

  GeneratedColumn<int> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<int> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => column);

  GeneratedColumn<int> get numberOfIndividualsWithChronicDiseases =>
      $composableBuilder(
          column: $table.numberOfIndividualsWithChronicDiseases,
          builder: (column) => column);

  GeneratedColumn<int> get numberOfPeopleWithSpecialNeeds => $composableBuilder(
      column: $table.numberOfPeopleWithSpecialNeeds,
      builder: (column) => column);

  GeneratedColumn<int> get housingStatus => $composableBuilder(
      column: $table.housingStatus, builder: (column) => column);

  GeneratedColumn<int> get currentHousingType => $composableBuilder(
      column: $table.currentHousingType, builder: (column) => column);

  GeneratedColumn<String> get descriptionNeeds => $composableBuilder(
      column: $table.descriptionNeeds, builder: (column) => column);

  GeneratedColumn<String> get userInsertData => $composableBuilder(
      column: $table.userInsertData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm, builder: (column) => column);

  Expression<T> sponsorshipsRefs<T extends Object>(
      Expression<T> Function($$SponsorshipsTableAnnotationComposer a) f) {
    final $$SponsorshipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sponsorships,
        getReferencedColumn: (t) => t.beneficiaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SponsorshipsTableAnnotationComposer(
              $db: $db,
              $table: $db.sponsorships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BeneficiariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BeneficiariesTable,
    Beneficiary,
    $$BeneficiariesTableFilterComposer,
    $$BeneficiariesTableOrderingComposer,
    $$BeneficiariesTableAnnotationComposer,
    $$BeneficiariesTableCreateCompanionBuilder,
    $$BeneficiariesTableUpdateCompanionBuilder,
    (Beneficiary, $$BeneficiariesTableReferences),
    Beneficiary,
    PrefetchHooks Function({bool sponsorshipsRefs})> {
  $$BeneficiariesTableTableManager(_$AppDatabase db, $BeneficiariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeneficiariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeneficiariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeneficiariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> fileIdNumber = const Value.absent(),
            Value<String?> originalFileIdFromExcel = const Value.absent(),
            Value<int?> sectionId = const Value.absent(),
            Value<int> requestStatus = const Value.absent(),
            Value<int> idNumber = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> fatherName = const Value.absent(),
            Value<String?> grandFatherName = const Value.absent(),
            Value<String?> familyName = const Value.absent(),
            Value<int?> relationship = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<int?> gender = const Value.absent(),
            Value<int> phoneNumber = const Value.absent(),
            Value<int> altPhoneNumber = const Value.absent(),
            Value<int?> numberOfIndividuals = const Value.absent(),
            Value<int?> maritalStatus = const Value.absent(),
            Value<int?> numberOfMales = const Value.absent(),
            Value<int?> numberOfFemales = const Value.absent(),
            Value<int?> academicQualification = const Value.absent(),
            Value<int?> employmentStatusBreadwinner = const Value.absent(),
            Value<int?> displacementStatus = const Value.absent(),
            Value<String?> addressBeforeDisplacement = const Value.absent(),
            Value<String?> currentAddress = const Value.absent(),
            Value<int?> city = const Value.absent(),
            Value<int?> province = const Value.absent(),
            Value<int?> healthStatus = const Value.absent(),
            Value<int?> numberOfIndividualsWithChronicDiseases =
                const Value.absent(),
            Value<int?> numberOfPeopleWithSpecialNeeds = const Value.absent(),
            Value<int?> housingStatus = const Value.absent(),
            Value<int?> currentHousingType = const Value.absent(),
            Value<String?> descriptionNeeds = const Value.absent(),
            Value<String?> userInsertData = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> fullNameNorm = const Value.absent(),
          }) =>
              BeneficiariesCompanion(
            id: id,
            fileIdNumber: fileIdNumber,
            originalFileIdFromExcel: originalFileIdFromExcel,
            sectionId: sectionId,
            requestStatus: requestStatus,
            idNumber: idNumber,
            firstName: firstName,
            fatherName: fatherName,
            grandFatherName: grandFatherName,
            familyName: familyName,
            relationship: relationship,
            birthDate: birthDate,
            gender: gender,
            phoneNumber: phoneNumber,
            altPhoneNumber: altPhoneNumber,
            numberOfIndividuals: numberOfIndividuals,
            maritalStatus: maritalStatus,
            numberOfMales: numberOfMales,
            numberOfFemales: numberOfFemales,
            academicQualification: academicQualification,
            employmentStatusBreadwinner: employmentStatusBreadwinner,
            displacementStatus: displacementStatus,
            addressBeforeDisplacement: addressBeforeDisplacement,
            currentAddress: currentAddress,
            city: city,
            province: province,
            healthStatus: healthStatus,
            numberOfIndividualsWithChronicDiseases:
                numberOfIndividualsWithChronicDiseases,
            numberOfPeopleWithSpecialNeeds: numberOfPeopleWithSpecialNeeds,
            housingStatus: housingStatus,
            currentHousingType: currentHousingType,
            descriptionNeeds: descriptionNeeds,
            userInsertData: userInsertData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            fullNameNorm: fullNameNorm,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> fileIdNumber = const Value.absent(),
            Value<String?> originalFileIdFromExcel = const Value.absent(),
            Value<int?> sectionId = const Value.absent(),
            Value<int> requestStatus = const Value.absent(),
            required int idNumber,
            Value<String?> firstName = const Value.absent(),
            Value<String?> fatherName = const Value.absent(),
            Value<String?> grandFatherName = const Value.absent(),
            Value<String?> familyName = const Value.absent(),
            Value<int?> relationship = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<int?> gender = const Value.absent(),
            required int phoneNumber,
            required int altPhoneNumber,
            Value<int?> numberOfIndividuals = const Value.absent(),
            Value<int?> maritalStatus = const Value.absent(),
            Value<int?> numberOfMales = const Value.absent(),
            Value<int?> numberOfFemales = const Value.absent(),
            Value<int?> academicQualification = const Value.absent(),
            Value<int?> employmentStatusBreadwinner = const Value.absent(),
            Value<int?> displacementStatus = const Value.absent(),
            Value<String?> addressBeforeDisplacement = const Value.absent(),
            Value<String?> currentAddress = const Value.absent(),
            Value<int?> city = const Value.absent(),
            Value<int?> province = const Value.absent(),
            Value<int?> healthStatus = const Value.absent(),
            Value<int?> numberOfIndividualsWithChronicDiseases =
                const Value.absent(),
            Value<int?> numberOfPeopleWithSpecialNeeds = const Value.absent(),
            Value<int?> housingStatus = const Value.absent(),
            Value<int?> currentHousingType = const Value.absent(),
            Value<String?> descriptionNeeds = const Value.absent(),
            Value<String?> userInsertData = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<String?> fullNameNorm = const Value.absent(),
          }) =>
              BeneficiariesCompanion.insert(
            id: id,
            fileIdNumber: fileIdNumber,
            originalFileIdFromExcel: originalFileIdFromExcel,
            sectionId: sectionId,
            requestStatus: requestStatus,
            idNumber: idNumber,
            firstName: firstName,
            fatherName: fatherName,
            grandFatherName: grandFatherName,
            familyName: familyName,
            relationship: relationship,
            birthDate: birthDate,
            gender: gender,
            phoneNumber: phoneNumber,
            altPhoneNumber: altPhoneNumber,
            numberOfIndividuals: numberOfIndividuals,
            maritalStatus: maritalStatus,
            numberOfMales: numberOfMales,
            numberOfFemales: numberOfFemales,
            academicQualification: academicQualification,
            employmentStatusBreadwinner: employmentStatusBreadwinner,
            displacementStatus: displacementStatus,
            addressBeforeDisplacement: addressBeforeDisplacement,
            currentAddress: currentAddress,
            city: city,
            province: province,
            healthStatus: healthStatus,
            numberOfIndividualsWithChronicDiseases:
                numberOfIndividualsWithChronicDiseases,
            numberOfPeopleWithSpecialNeeds: numberOfPeopleWithSpecialNeeds,
            housingStatus: housingStatus,
            currentHousingType: currentHousingType,
            descriptionNeeds: descriptionNeeds,
            userInsertData: userInsertData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            fullNameNorm: fullNameNorm,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BeneficiariesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sponsorshipsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sponsorshipsRefs) db.sponsorships],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sponsorshipsRefs)
                    await $_getPrefetchedData<Beneficiary, $BeneficiariesTable,
                            Sponsorship>(
                        currentTable: table,
                        referencedTable: $$BeneficiariesTableReferences
                            ._sponsorshipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BeneficiariesTableReferences(db, table, p0)
                                .sponsorshipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.beneficiaryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BeneficiariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BeneficiariesTable,
    Beneficiary,
    $$BeneficiariesTableFilterComposer,
    $$BeneficiariesTableOrderingComposer,
    $$BeneficiariesTableAnnotationComposer,
    $$BeneficiariesTableCreateCompanionBuilder,
    $$BeneficiariesTableUpdateCompanionBuilder,
    (Beneficiary, $$BeneficiariesTableReferences),
    Beneficiary,
    PrefetchHooks Function({bool sponsorshipsRefs})>;
typedef $$VisitsTableCreateCompanionBuilder = VisitsCompanion Function({
  required String id,
  required String beneficiaryId,
  required DateTime visitDate,
  required String staffName,
  Value<String> notes,
  Value<bool> isSubmitted,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$VisitsTableUpdateCompanionBuilder = VisitsCompanion Function({
  Value<String> id,
  Value<String> beneficiaryId,
  Value<DateTime> visitDate,
  Value<String> staffName,
  Value<String> notes,
  Value<bool> isSubmitted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get staffName => $composableBuilder(
      column: $table.staffName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSubmitted => $composableBuilder(
      column: $table.isSubmitted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get staffName => $composableBuilder(
      column: $table.staffName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSubmitted => $composableBuilder(
      column: $table.isSubmitted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSubmitted => $composableBuilder(
      column: $table.isSubmitted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$VisitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VisitsTable,
    Visit,
    $$VisitsTableFilterComposer,
    $$VisitsTableOrderingComposer,
    $$VisitsTableAnnotationComposer,
    $$VisitsTableCreateCompanionBuilder,
    $$VisitsTableUpdateCompanionBuilder,
    (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
    Visit,
    PrefetchHooks Function()> {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> beneficiaryId = const Value.absent(),
            Value<DateTime> visitDate = const Value.absent(),
            Value<String> staffName = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<bool> isSubmitted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VisitsCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            visitDate: visitDate,
            staffName: staffName,
            notes: notes,
            isSubmitted: isSubmitted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String beneficiaryId,
            required DateTime visitDate,
            required String staffName,
            Value<String> notes = const Value.absent(),
            Value<bool> isSubmitted = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VisitsCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            visitDate: visitDate,
            staffName: staffName,
            notes: notes,
            isSubmitted: isSubmitted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VisitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VisitsTable,
    Visit,
    $$VisitsTableFilterComposer,
    $$VisitsTableOrderingComposer,
    $$VisitsTableAnnotationComposer,
    $$VisitsTableCreateCompanionBuilder,
    $$VisitsTableUpdateCompanionBuilder,
    (Visit, BaseReferences<_$AppDatabase, $VisitsTable, Visit>),
    Visit,
    PrefetchHooks Function()>;
typedef $$AttachmentsTableCreateCompanionBuilder = AttachmentsCompanion
    Function({
  required String id,
  required String beneficiaryId,
  Value<String?> visitId,
  required String fileName,
  required String filePath,
  required String type,
  required int fileSize,
  Value<String?> thumbnailPath,
  Value<String?> documentType,
  Value<String?> personType,
  Value<String?> personId,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<String?> serverUrl,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$AttachmentsTableUpdateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<String> id,
  Value<String> beneficiaryId,
  Value<String?> visitId,
  Value<String> fileName,
  Value<String> filePath,
  Value<String> type,
  Value<int> fileSize,
  Value<String?> thumbnailPath,
  Value<String?> documentType,
  Value<String?> personType,
  Value<String?> personId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<String?> serverUrl,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personType => $composableBuilder(
      column: $table.personType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentType => $composableBuilder(
      column: $table.documentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personType => $composableBuilder(
      column: $table.personType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => column);

  GeneratedColumn<String> get personType => $composableBuilder(
      column: $table.personType, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$AttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>),
    Attachment,
    PrefetchHooks Function()> {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> beneficiaryId = const Value.absent(),
            Value<String?> visitId = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> documentType = const Value.absent(),
            Value<String?> personType = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<String?> serverUrl = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            visitId: visitId,
            fileName: fileName,
            filePath: filePath,
            type: type,
            fileSize: fileSize,
            thumbnailPath: thumbnailPath,
            documentType: documentType,
            personType: personType,
            personId: personId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverUrl: serverUrl,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String beneficiaryId,
            Value<String?> visitId = const Value.absent(),
            required String fileName,
            required String filePath,
            required String type,
            required int fileSize,
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> documentType = const Value.absent(),
            Value<String?> personType = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<String?> serverUrl = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentsCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            visitId: visitId,
            fileName: fileName,
            filePath: filePath,
            type: type,
            fileSize: fileSize,
            thumbnailPath: thumbnailPath,
            documentType: documentType,
            personType: personType,
            personId: personId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverUrl: serverUrl,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>),
    Attachment,
    PrefetchHooks Function()>;
typedef $$TaxonomiesTableCreateCompanionBuilder = TaxonomiesCompanion Function({
  required String id,
  required String group,
  required String code,
  required String label,
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isActive,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TaxonomiesTableUpdateCompanionBuilder = TaxonomiesCompanion Function({
  Value<String> id,
  Value<String> group,
  Value<String> code,
  Value<String> label,
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TaxonomiesTableFilterComposer
    extends Composer<_$AppDatabase, $TaxonomiesTable> {
  $$TaxonomiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TaxonomiesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxonomiesTable> {
  $$TaxonomiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaxonomiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxonomiesTable> {
  $$TaxonomiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TaxonomiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaxonomiesTable,
    Taxonomy,
    $$TaxonomiesTableFilterComposer,
    $$TaxonomiesTableOrderingComposer,
    $$TaxonomiesTableAnnotationComposer,
    $$TaxonomiesTableCreateCompanionBuilder,
    $$TaxonomiesTableUpdateCompanionBuilder,
    (Taxonomy, BaseReferences<_$AppDatabase, $TaxonomiesTable, Taxonomy>),
    Taxonomy,
    PrefetchHooks Function()> {
  $$TaxonomiesTableTableManager(_$AppDatabase db, $TaxonomiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxonomiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxonomiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxonomiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> group = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaxonomiesCompanion(
            id: id,
            group: group,
            code: code,
            label: label,
            parentId: parentId,
            sortOrder: sortOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String group,
            required String code,
            required String label,
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaxonomiesCompanion.insert(
            id: id,
            group: group,
            code: code,
            label: label,
            parentId: parentId,
            sortOrder: sortOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaxonomiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaxonomiesTable,
    Taxonomy,
    $$TaxonomiesTableFilterComposer,
    $$TaxonomiesTableOrderingComposer,
    $$TaxonomiesTableAnnotationComposer,
    $$TaxonomiesTableCreateCompanionBuilder,
    $$TaxonomiesTableUpdateCompanionBuilder,
    (Taxonomy, BaseReferences<_$AppDatabase, $TaxonomiesTable, Taxonomy>),
    Taxonomy,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String entity,
  required String entityId,
  required String operation,
  required String payload,
  Value<int> priority,
  Value<int> attempts,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<DateTime?> scheduledAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> entity,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payload,
  Value<int> priority,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime?> scheduledAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entity: entity,
            entityId: entityId,
            operation: operation,
            payload: payload,
            priority: priority,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
            scheduledAt: scheduledAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entity,
            required String entityId,
            required String operation,
            required String payload,
            Value<int> priority = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entity: entity,
            entityId: entityId,
            operation: operation,
            payload: payload,
            priority: priority,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
            scheduledAt: scheduledAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueItem,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$SyncMetadataTableTableCreateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  required String entity,
  required DateTime lastSyncTime,
  Value<int> totalSynced,
  Value<int> failedSyncs,
  Value<String?> lastError,
  Value<DateTime?> lastErrorTime,
  Value<int> rowid,
});
typedef $$SyncMetadataTableTableUpdateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  Value<String> entity,
  Value<DateTime> lastSyncTime,
  Value<int> totalSynced,
  Value<int> failedSyncs,
  Value<String?> lastError,
  Value<DateTime?> lastErrorTime,
  Value<int> rowid,
});

class $$SyncMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSynced => $composableBuilder(
      column: $table.totalSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedSyncs => $composableBuilder(
      column: $table.failedSyncs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastErrorTime => $composableBuilder(
      column: $table.lastErrorTime, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSynced => $composableBuilder(
      column: $table.totalSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedSyncs => $composableBuilder(
      column: $table.failedSyncs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastErrorTime => $composableBuilder(
      column: $table.lastErrorTime,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncTime => $composableBuilder(
      column: $table.lastSyncTime, builder: (column) => column);

  GeneratedColumn<int> get totalSynced => $composableBuilder(
      column: $table.totalSynced, builder: (column) => column);

  GeneratedColumn<int> get failedSyncs => $composableBuilder(
      column: $table.failedSyncs, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get lastErrorTime => $composableBuilder(
      column: $table.lastErrorTime, builder: (column) => column);
}

class $$SyncMetadataTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadata,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadata,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable, SyncMetadata>
    ),
    SyncMetadata,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableTableManager(
      _$AppDatabase db, $SyncMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entity = const Value.absent(),
            Value<DateTime> lastSyncTime = const Value.absent(),
            Value<int> totalSynced = const Value.absent(),
            Value<int> failedSyncs = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> lastErrorTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion(
            entity: entity,
            lastSyncTime: lastSyncTime,
            totalSynced: totalSynced,
            failedSyncs: failedSyncs,
            lastError: lastError,
            lastErrorTime: lastErrorTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entity,
            required DateTime lastSyncTime,
            Value<int> totalSynced = const Value.absent(),
            Value<int> failedSyncs = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime?> lastErrorTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion.insert(
            entity: entity,
            lastSyncTime: lastSyncTime,
            totalSynced: totalSynced,
            failedSyncs: failedSyncs,
            lastError: lastError,
            lastErrorTime: lastErrorTime,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetadataTableTable,
    SyncMetadata,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadata,
      BaseReferences<_$AppDatabase, $SyncMetadataTableTable, SyncMetadata>
    ),
    SyncMetadata,
    PrefetchHooks Function()>;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required String id,
  required String beneficiaryId,
  required String userId,
  required String activityType,
  required String description,
  Value<String?> changes,
  required DateTime createdAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<String> id,
  Value<String> beneficiaryId,
  Value<String> userId,
  Value<String> activityType,
  Value<String> description,
  Value<String?> changes,
  Value<DateTime> createdAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()> {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> beneficiaryId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> activityType = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> changes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            userId: userId,
            activityType: activityType,
            description: description,
            changes: changes,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String beneficiaryId,
            required String userId,
            required String activityType,
            required String description,
            Value<String?> changes = const Value.absent(),
            required DateTime createdAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            userId: userId,
            activityType: activityType,
            description: description,
            changes: changes,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()>;
typedef $$FamilyDeceasedTableTableCreateCompanionBuilder
    = FamilyDeceasedTableCompanion Function({
  Value<int> id,
  required int beneficiaryId,
  required int deceasedType,
  required String firstName,
  Value<String?> secondName,
  Value<String?> thirdName,
  required String familyName,
  required int nationalId,
  required DateTime deathDate,
  required int deathCause,
  Value<int?> documentType,
  Value<String?> documentPath,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});
typedef $$FamilyDeceasedTableTableUpdateCompanionBuilder
    = FamilyDeceasedTableCompanion Function({
  Value<int> id,
  Value<int> beneficiaryId,
  Value<int> deceasedType,
  Value<String> firstName,
  Value<String?> secondName,
  Value<String?> thirdName,
  Value<String> familyName,
  Value<int> nationalId,
  Value<DateTime> deathDate,
  Value<int> deathCause,
  Value<int?> documentType,
  Value<String?> documentPath,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});

class $$FamilyDeceasedTableTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyDeceasedTableTable> {
  $$FamilyDeceasedTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deceasedType => $composableBuilder(
      column: $table.deceasedType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thirdName => $composableBuilder(
      column: $table.thirdName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deathCause => $composableBuilder(
      column: $table.deathCause, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$FamilyDeceasedTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyDeceasedTableTable> {
  $$FamilyDeceasedTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deceasedType => $composableBuilder(
      column: $table.deceasedType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thirdName => $composableBuilder(
      column: $table.thirdName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deathCause => $composableBuilder(
      column: $table.deathCause, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get documentType => $composableBuilder(
      column: $table.documentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentPath => $composableBuilder(
      column: $table.documentPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$FamilyDeceasedTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyDeceasedTableTable> {
  $$FamilyDeceasedTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<int> get deceasedType => $composableBuilder(
      column: $table.deceasedType, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => column);

  GeneratedColumn<String> get thirdName =>
      $composableBuilder(column: $table.thirdName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => column);

  GeneratedColumn<int> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<DateTime> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<int> get deathCause => $composableBuilder(
      column: $table.deathCause, builder: (column) => column);

  GeneratedColumn<int> get documentType => $composableBuilder(
      column: $table.documentType, builder: (column) => column);

  GeneratedColumn<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$FamilyDeceasedTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamilyDeceasedTableTable,
    FamilyDeceased,
    $$FamilyDeceasedTableTableFilterComposer,
    $$FamilyDeceasedTableTableOrderingComposer,
    $$FamilyDeceasedTableTableAnnotationComposer,
    $$FamilyDeceasedTableTableCreateCompanionBuilder,
    $$FamilyDeceasedTableTableUpdateCompanionBuilder,
    (
      FamilyDeceased,
      BaseReferences<_$AppDatabase, $FamilyDeceasedTableTable, FamilyDeceased>
    ),
    FamilyDeceased,
    PrefetchHooks Function()> {
  $$FamilyDeceasedTableTableTableManager(
      _$AppDatabase db, $FamilyDeceasedTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyDeceasedTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyDeceasedTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyDeceasedTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> beneficiaryId = const Value.absent(),
            Value<int> deceasedType = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String?> secondName = const Value.absent(),
            Value<String?> thirdName = const Value.absent(),
            Value<String> familyName = const Value.absent(),
            Value<int> nationalId = const Value.absent(),
            Value<DateTime> deathDate = const Value.absent(),
            Value<int> deathCause = const Value.absent(),
            Value<int?> documentType = const Value.absent(),
            Value<String?> documentPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              FamilyDeceasedTableCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            deceasedType: deceasedType,
            firstName: firstName,
            secondName: secondName,
            thirdName: thirdName,
            familyName: familyName,
            nationalId: nationalId,
            deathDate: deathDate,
            deathCause: deathCause,
            documentType: documentType,
            documentPath: documentPath,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int beneficiaryId,
            required int deceasedType,
            required String firstName,
            Value<String?> secondName = const Value.absent(),
            Value<String?> thirdName = const Value.absent(),
            required String familyName,
            required int nationalId,
            required DateTime deathDate,
            required int deathCause,
            Value<int?> documentType = const Value.absent(),
            Value<String?> documentPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              FamilyDeceasedTableCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            deceasedType: deceasedType,
            firstName: firstName,
            secondName: secondName,
            thirdName: thirdName,
            familyName: familyName,
            nationalId: nationalId,
            deathDate: deathDate,
            deathCause: deathCause,
            documentType: documentType,
            documentPath: documentPath,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FamilyDeceasedTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamilyDeceasedTableTable,
    FamilyDeceased,
    $$FamilyDeceasedTableTableFilterComposer,
    $$FamilyDeceasedTableTableOrderingComposer,
    $$FamilyDeceasedTableTableAnnotationComposer,
    $$FamilyDeceasedTableTableCreateCompanionBuilder,
    $$FamilyDeceasedTableTableUpdateCompanionBuilder,
    (
      FamilyDeceased,
      BaseReferences<_$AppDatabase, $FamilyDeceasedTableTable, FamilyDeceased>
    ),
    FamilyDeceased,
    PrefetchHooks Function()>;
typedef $$FamilyMembersTableTableCreateCompanionBuilder
    = FamilyMembersTableCompanion Function({
  Value<int> id,
  required int beneficiaryId,
  required int orphanNationalId,
  required String firstName,
  Value<String?> secondName,
  Value<String?> thirdName,
  required String familyName,
  required DateTime birthDate,
  Value<int?> age,
  required int gender,
  required int healthStatus,
  Value<int?> sponsorshipStatus,
  Value<int?> sponsorshipType,
  Value<String?> sponsorName,
  Value<DateTime?> sponsorshipStartDate,
  Value<String?> notes,
  Value<String?> attachments,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});
typedef $$FamilyMembersTableTableUpdateCompanionBuilder
    = FamilyMembersTableCompanion Function({
  Value<int> id,
  Value<int> beneficiaryId,
  Value<int> orphanNationalId,
  Value<String> firstName,
  Value<String?> secondName,
  Value<String?> thirdName,
  Value<String> familyName,
  Value<DateTime> birthDate,
  Value<int?> age,
  Value<int> gender,
  Value<int> healthStatus,
  Value<int?> sponsorshipStatus,
  Value<int?> sponsorshipType,
  Value<String?> sponsorName,
  Value<DateTime?> sponsorshipStartDate,
  Value<String?> notes,
  Value<String?> attachments,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});

class $$FamilyMembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMembersTableTable> {
  $$FamilyMembersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orphanNationalId => $composableBuilder(
      column: $table.orphanNationalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thirdName => $composableBuilder(
      column: $table.thirdName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sponsorshipStatus => $composableBuilder(
      column: $table.sponsorshipStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sponsorshipStartDate => $composableBuilder(
      column: $table.sponsorshipStartDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachments => $composableBuilder(
      column: $table.attachments, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$FamilyMembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMembersTableTable> {
  $$FamilyMembersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orphanNationalId => $composableBuilder(
      column: $table.orphanNationalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thirdName => $composableBuilder(
      column: $table.thirdName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sponsorshipStatus => $composableBuilder(
      column: $table.sponsorshipStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sponsorshipStartDate => $composableBuilder(
      column: $table.sponsorshipStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachments => $composableBuilder(
      column: $table.attachments, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$FamilyMembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMembersTableTable> {
  $$FamilyMembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get beneficiaryId => $composableBuilder(
      column: $table.beneficiaryId, builder: (column) => column);

  GeneratedColumn<int> get orphanNationalId => $composableBuilder(
      column: $table.orphanNationalId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get secondName => $composableBuilder(
      column: $table.secondName, builder: (column) => column);

  GeneratedColumn<String> get thirdName =>
      $composableBuilder(column: $table.thirdName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
      column: $table.familyName, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => column);

  GeneratedColumn<int> get sponsorshipStatus => $composableBuilder(
      column: $table.sponsorshipStatus, builder: (column) => column);

  GeneratedColumn<int> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType, builder: (column) => column);

  GeneratedColumn<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => column);

  GeneratedColumn<DateTime> get sponsorshipStartDate => $composableBuilder(
      column: $table.sponsorshipStartDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get attachments => $composableBuilder(
      column: $table.attachments, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$FamilyMembersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamilyMembersTableTable,
    FamilyMember,
    $$FamilyMembersTableTableFilterComposer,
    $$FamilyMembersTableTableOrderingComposer,
    $$FamilyMembersTableTableAnnotationComposer,
    $$FamilyMembersTableTableCreateCompanionBuilder,
    $$FamilyMembersTableTableUpdateCompanionBuilder,
    (
      FamilyMember,
      BaseReferences<_$AppDatabase, $FamilyMembersTableTable, FamilyMember>
    ),
    FamilyMember,
    PrefetchHooks Function()> {
  $$FamilyMembersTableTableTableManager(
      _$AppDatabase db, $FamilyMembersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMembersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMembersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyMembersTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> beneficiaryId = const Value.absent(),
            Value<int> orphanNationalId = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String?> secondName = const Value.absent(),
            Value<String?> thirdName = const Value.absent(),
            Value<String> familyName = const Value.absent(),
            Value<DateTime> birthDate = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<int> gender = const Value.absent(),
            Value<int> healthStatus = const Value.absent(),
            Value<int?> sponsorshipStatus = const Value.absent(),
            Value<int?> sponsorshipType = const Value.absent(),
            Value<String?> sponsorName = const Value.absent(),
            Value<DateTime?> sponsorshipStartDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> attachments = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              FamilyMembersTableCompanion(
            id: id,
            beneficiaryId: beneficiaryId,
            orphanNationalId: orphanNationalId,
            firstName: firstName,
            secondName: secondName,
            thirdName: thirdName,
            familyName: familyName,
            birthDate: birthDate,
            age: age,
            gender: gender,
            healthStatus: healthStatus,
            sponsorshipStatus: sponsorshipStatus,
            sponsorshipType: sponsorshipType,
            sponsorName: sponsorName,
            sponsorshipStartDate: sponsorshipStartDate,
            notes: notes,
            attachments: attachments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int beneficiaryId,
            required int orphanNationalId,
            required String firstName,
            Value<String?> secondName = const Value.absent(),
            Value<String?> thirdName = const Value.absent(),
            required String familyName,
            required DateTime birthDate,
            Value<int?> age = const Value.absent(),
            required int gender,
            required int healthStatus,
            Value<int?> sponsorshipStatus = const Value.absent(),
            Value<int?> sponsorshipType = const Value.absent(),
            Value<String?> sponsorName = const Value.absent(),
            Value<DateTime?> sponsorshipStartDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> attachments = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              FamilyMembersTableCompanion.insert(
            id: id,
            beneficiaryId: beneficiaryId,
            orphanNationalId: orphanNationalId,
            firstName: firstName,
            secondName: secondName,
            thirdName: thirdName,
            familyName: familyName,
            birthDate: birthDate,
            age: age,
            gender: gender,
            healthStatus: healthStatus,
            sponsorshipStatus: sponsorshipStatus,
            sponsorshipType: sponsorshipType,
            sponsorName: sponsorName,
            sponsorshipStartDate: sponsorshipStartDate,
            notes: notes,
            attachments: attachments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FamilyMembersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamilyMembersTableTable,
    FamilyMember,
    $$FamilyMembersTableTableFilterComposer,
    $$FamilyMembersTableTableOrderingComposer,
    $$FamilyMembersTableTableAnnotationComposer,
    $$FamilyMembersTableTableCreateCompanionBuilder,
    $$FamilyMembersTableTableUpdateCompanionBuilder,
    (
      FamilyMember,
      BaseReferences<_$AppDatabase, $FamilyMembersTableTable, FamilyMember>
    ),
    FamilyMember,
    PrefetchHooks Function()>;
typedef $$AssociationRepresentativesTableCreateCompanionBuilder
    = AssociationRepresentativesCompanion Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<int> rowid,
});
typedef $$AssociationRepresentativesTableUpdateCompanionBuilder
    = AssociationRepresentativesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<int> rowid,
});

final class $$AssociationRepresentativesTableReferences extends BaseReferences<
    _$AppDatabase, $AssociationRepresentativesTable, Representative> {
  $$AssociationRepresentativesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssociationsTable, List<Association>>
      _associationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.associations,
              aliasName: $_aliasNameGenerator(db.associationRepresentatives.id,
                  db.associations.representativeId));

  $$AssociationsTableProcessedTableManager get associationsRefs {
    final manager = $$AssociationsTableTableManager($_db, $_db.associations)
        .filter((f) =>
            f.representativeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_associationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AssociationRepresentativesTableFilterComposer
    extends Composer<_$AppDatabase, $AssociationRepresentativesTable> {
  $$AssociationRepresentativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  Expression<bool> associationsRefs(
      Expression<bool> Function($$AssociationsTableFilterComposer f) f) {
    final $$AssociationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.associations,
        getReferencedColumn: (t) => t.representativeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssociationsTableFilterComposer(
              $db: $db,
              $table: $db.associations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssociationRepresentativesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssociationRepresentativesTable> {
  $$AssociationRepresentativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));
}

class $$AssociationRepresentativesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssociationRepresentativesTable> {
  $$AssociationRepresentativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> associationsRefs<T extends Object>(
      Expression<T> Function($$AssociationsTableAnnotationComposer a) f) {
    final $$AssociationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.associations,
        getReferencedColumn: (t) => t.representativeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssociationsTableAnnotationComposer(
              $db: $db,
              $table: $db.associations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssociationRepresentativesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssociationRepresentativesTable,
    Representative,
    $$AssociationRepresentativesTableFilterComposer,
    $$AssociationRepresentativesTableOrderingComposer,
    $$AssociationRepresentativesTableAnnotationComposer,
    $$AssociationRepresentativesTableCreateCompanionBuilder,
    $$AssociationRepresentativesTableUpdateCompanionBuilder,
    (Representative, $$AssociationRepresentativesTableReferences),
    Representative,
    PrefetchHooks Function({bool associationsRefs})> {
  $$AssociationRepresentativesTableTableManager(
      _$AppDatabase db, $AssociationRepresentativesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssociationRepresentativesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AssociationRepresentativesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssociationRepresentativesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssociationRepresentativesCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssociationRepresentativesCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssociationRepresentativesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({associationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (associationsRefs) db.associations],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (associationsRefs)
                    await $_getPrefetchedData<Representative,
                            $AssociationRepresentativesTable, Association>(
                        currentTable: table,
                        referencedTable:
                            $$AssociationRepresentativesTableReferences
                                ._associationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AssociationRepresentativesTableReferences(
                                    db, table, p0)
                                .associationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.representativeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AssociationRepresentativesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AssociationRepresentativesTable,
        Representative,
        $$AssociationRepresentativesTableFilterComposer,
        $$AssociationRepresentativesTableOrderingComposer,
        $$AssociationRepresentativesTableAnnotationComposer,
        $$AssociationRepresentativesTableCreateCompanionBuilder,
        $$AssociationRepresentativesTableUpdateCompanionBuilder,
        (Representative, $$AssociationRepresentativesTableReferences),
        Representative,
        PrefetchHooks Function({bool associationsRefs})>;
typedef $$AssociationsTableCreateCompanionBuilder = AssociationsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> shortName,
  required String phone,
  Value<String?> email,
  required String bankName,
  required String accountNumber,
  Value<String?> swiftCode,
  Value<String?> bankPhone,
  Value<String?> accountCurrency,
  Value<String?> representativeId,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$AssociationsTableUpdateCompanionBuilder = AssociationsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> shortName,
  Value<String> phone,
  Value<String?> email,
  Value<String> bankName,
  Value<String> accountNumber,
  Value<String?> swiftCode,
  Value<String?> bankPhone,
  Value<String?> accountCurrency,
  Value<String?> representativeId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$AssociationsTableReferences
    extends BaseReferences<_$AppDatabase, $AssociationsTable, Association> {
  $$AssociationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssociationRepresentativesTable _representativeIdTable(
          _$AppDatabase db) =>
      db.associationRepresentatives.createAlias($_aliasNameGenerator(
          db.associations.representativeId, db.associationRepresentatives.id));

  $$AssociationRepresentativesTableProcessedTableManager? get representativeId {
    final $_column = $_itemColumn<String>('representative_id');
    if ($_column == null) return null;
    final manager = $$AssociationRepresentativesTableTableManager(
            $_db, $_db.associationRepresentatives)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_representativeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SponsorshipsTable, List<Sponsorship>>
      _sponsorshipsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sponsorships,
              aliasName: $_aliasNameGenerator(
                  db.associations.id, db.sponsorships.associationId));

  $$SponsorshipsTableProcessedTableManager get sponsorshipsRefs {
    final manager = $$SponsorshipsTableTableManager($_db, $_db.sponsorships)
        .filter(
            (f) => f.associationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sponsorshipsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AssociationsTableFilterComposer
    extends Composer<_$AppDatabase, $AssociationsTable> {
  $$AssociationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get swiftCode => $composableBuilder(
      column: $table.swiftCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankPhone => $composableBuilder(
      column: $table.bankPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountCurrency => $composableBuilder(
      column: $table.accountCurrency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$AssociationRepresentativesTableFilterComposer get representativeId {
    final $$AssociationRepresentativesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.representativeId,
            referencedTable: $db.associationRepresentatives,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AssociationRepresentativesTableFilterComposer(
                  $db: $db,
                  $table: $db.associationRepresentatives,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<bool> sponsorshipsRefs(
      Expression<bool> Function($$SponsorshipsTableFilterComposer f) f) {
    final $$SponsorshipsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sponsorships,
        getReferencedColumn: (t) => t.associationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SponsorshipsTableFilterComposer(
              $db: $db,
              $table: $db.sponsorships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssociationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssociationsTable> {
  $$AssociationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get swiftCode => $composableBuilder(
      column: $table.swiftCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankPhone => $composableBuilder(
      column: $table.bankPhone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountCurrency => $composableBuilder(
      column: $table.accountCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$AssociationRepresentativesTableOrderingComposer get representativeId {
    final $$AssociationRepresentativesTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.representativeId,
            referencedTable: $db.associationRepresentatives,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AssociationRepresentativesTableOrderingComposer(
                  $db: $db,
                  $table: $db.associationRepresentatives,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$AssociationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssociationsTable> {
  $$AssociationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get swiftCode =>
      $composableBuilder(column: $table.swiftCode, builder: (column) => column);

  GeneratedColumn<String> get bankPhone =>
      $composableBuilder(column: $table.bankPhone, builder: (column) => column);

  GeneratedColumn<String> get accountCurrency => $composableBuilder(
      column: $table.accountCurrency, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$AssociationRepresentativesTableAnnotationComposer get representativeId {
    final $$AssociationRepresentativesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.representativeId,
            referencedTable: $db.associationRepresentatives,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AssociationRepresentativesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.associationRepresentatives,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> sponsorshipsRefs<T extends Object>(
      Expression<T> Function($$SponsorshipsTableAnnotationComposer a) f) {
    final $$SponsorshipsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sponsorships,
        getReferencedColumn: (t) => t.associationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SponsorshipsTableAnnotationComposer(
              $db: $db,
              $table: $db.sponsorships,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AssociationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssociationsTable,
    Association,
    $$AssociationsTableFilterComposer,
    $$AssociationsTableOrderingComposer,
    $$AssociationsTableAnnotationComposer,
    $$AssociationsTableCreateCompanionBuilder,
    $$AssociationsTableUpdateCompanionBuilder,
    (Association, $$AssociationsTableReferences),
    Association,
    PrefetchHooks Function({bool representativeId, bool sponsorshipsRefs})> {
  $$AssociationsTableTableManager(_$AppDatabase db, $AssociationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssociationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssociationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssociationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> shortName = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String?> swiftCode = const Value.absent(),
            Value<String?> bankPhone = const Value.absent(),
            Value<String?> accountCurrency = const Value.absent(),
            Value<String?> representativeId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssociationsCompanion(
            id: id,
            name: name,
            shortName: shortName,
            phone: phone,
            email: email,
            bankName: bankName,
            accountNumber: accountNumber,
            swiftCode: swiftCode,
            bankPhone: bankPhone,
            accountCurrency: accountCurrency,
            representativeId: representativeId,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> shortName = const Value.absent(),
            required String phone,
            Value<String?> email = const Value.absent(),
            required String bankName,
            required String accountNumber,
            Value<String?> swiftCode = const Value.absent(),
            Value<String?> bankPhone = const Value.absent(),
            Value<String?> accountCurrency = const Value.absent(),
            Value<String?> representativeId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssociationsCompanion.insert(
            id: id,
            name: name,
            shortName: shortName,
            phone: phone,
            email: email,
            bankName: bankName,
            accountNumber: accountNumber,
            swiftCode: swiftCode,
            bankPhone: bankPhone,
            accountCurrency: accountCurrency,
            representativeId: representativeId,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AssociationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {representativeId = false, sponsorshipsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sponsorshipsRefs) db.sponsorships],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (representativeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.representativeId,
                    referencedTable: $$AssociationsTableReferences
                        ._representativeIdTable(db),
                    referencedColumn: $$AssociationsTableReferences
                        ._representativeIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sponsorshipsRefs)
                    await $_getPrefetchedData<Association, $AssociationsTable,
                            Sponsorship>(
                        currentTable: table,
                        referencedTable: $$AssociationsTableReferences
                            ._sponsorshipsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AssociationsTableReferences(db, table, p0)
                                .sponsorshipsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.associationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AssociationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssociationsTable,
    Association,
    $$AssociationsTableFilterComposer,
    $$AssociationsTableOrderingComposer,
    $$AssociationsTableAnnotationComposer,
    $$AssociationsTableCreateCompanionBuilder,
    $$AssociationsTableUpdateCompanionBuilder,
    (Association, $$AssociationsTableReferences),
    Association,
    PrefetchHooks Function({bool representativeId, bool sponsorshipsRefs})>;
typedef $$SponsorshipsTableCreateCompanionBuilder = SponsorshipsCompanion
    Function({
  Value<int> fileNo,
  required int beneficiaryId,
  required String associationId,
  Value<String?> sponsorName,
  Value<String?> internalFileNo,
  Value<String?> externalFileNo,
  Value<String?> guardianName,
  Value<int?> guardianIdNumber,
  Value<String?> guardianPhone,
  Value<String?> guardianAltPhone,
  Value<int?> durationMonths,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<double?> amount,
  Value<String?> currency,
  Value<String> status,
  Value<String> sponsorshipType,
  Value<String?> bankName,
  Value<String?> accountHolderName,
  Value<int?> accountHolderIdNumber,
  Value<String?> accountNumber,
  Value<String?> swiftCode,
  Value<String?> governorate,
  Value<String?> city,
  Value<String?> address,
  Value<int?> importBatchId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});
typedef $$SponsorshipsTableUpdateCompanionBuilder = SponsorshipsCompanion
    Function({
  Value<int> fileNo,
  Value<int> beneficiaryId,
  Value<String> associationId,
  Value<String?> sponsorName,
  Value<String?> internalFileNo,
  Value<String?> externalFileNo,
  Value<String?> guardianName,
  Value<int?> guardianIdNumber,
  Value<String?> guardianPhone,
  Value<String?> guardianAltPhone,
  Value<int?> durationMonths,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<double?> amount,
  Value<String?> currency,
  Value<String> status,
  Value<String> sponsorshipType,
  Value<String?> bankName,
  Value<String?> accountHolderName,
  Value<int?> accountHolderIdNumber,
  Value<String?> accountNumber,
  Value<String?> swiftCode,
  Value<String?> governorate,
  Value<String?> city,
  Value<String?> address,
  Value<int?> importBatchId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> syncState,
  Value<int?> serverId,
  Value<DateTime?> lastSyncedAt,
});

final class $$SponsorshipsTableReferences
    extends BaseReferences<_$AppDatabase, $SponsorshipsTable, Sponsorship> {
  $$SponsorshipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BeneficiariesTable _beneficiaryIdTable(_$AppDatabase db) =>
      db.beneficiaries.createAlias($_aliasNameGenerator(
          db.sponsorships.beneficiaryId, db.beneficiaries.id));

  $$BeneficiariesTableProcessedTableManager get beneficiaryId {
    final $_column = $_itemColumn<int>('beneficiary_id')!;

    final manager = $$BeneficiariesTableTableManager($_db, $_db.beneficiaries)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beneficiaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AssociationsTable _associationIdTable(_$AppDatabase db) =>
      db.associations.createAlias($_aliasNameGenerator(
          db.sponsorships.associationId, db.associations.id));

  $$AssociationsTableProcessedTableManager get associationId {
    final $_column = $_itemColumn<String>('association_id')!;

    final manager = $$AssociationsTableTableManager($_db, $_db.associations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_associationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SponsorshipsTableFilterComposer
    extends Composer<_$AppDatabase, $SponsorshipsTable> {
  $$SponsorshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get fileNo => $composableBuilder(
      column: $table.fileNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get internalFileNo => $composableBuilder(
      column: $table.internalFileNo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalFileNo => $composableBuilder(
      column: $table.externalFileNo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get guardianIdNumber => $composableBuilder(
      column: $table.guardianIdNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianAltPhone => $composableBuilder(
      column: $table.guardianAltPhone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMonths => $composableBuilder(
      column: $table.durationMonths,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountHolderIdNumber => $composableBuilder(
      column: $table.accountHolderIdNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get swiftCode => $composableBuilder(
      column: $table.swiftCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get governorate => $composableBuilder(
      column: $table.governorate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get importBatchId => $composableBuilder(
      column: $table.importBatchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$BeneficiariesTableFilterComposer get beneficiaryId {
    final $$BeneficiariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.beneficiaryId,
        referencedTable: $db.beneficiaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BeneficiariesTableFilterComposer(
              $db: $db,
              $table: $db.beneficiaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssociationsTableFilterComposer get associationId {
    final $$AssociationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associationId,
        referencedTable: $db.associations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssociationsTableFilterComposer(
              $db: $db,
              $table: $db.associations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SponsorshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $SponsorshipsTable> {
  $$SponsorshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get fileNo => $composableBuilder(
      column: $table.fileNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get internalFileNo => $composableBuilder(
      column: $table.internalFileNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalFileNo => $composableBuilder(
      column: $table.externalFileNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianName => $composableBuilder(
      column: $table.guardianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get guardianIdNumber => $composableBuilder(
      column: $table.guardianIdNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianAltPhone => $composableBuilder(
      column: $table.guardianAltPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMonths => $composableBuilder(
      column: $table.durationMonths,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountHolderIdNumber => $composableBuilder(
      column: $table.accountHolderIdNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get swiftCode => $composableBuilder(
      column: $table.swiftCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get governorate => $composableBuilder(
      column: $table.governorate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get importBatchId => $composableBuilder(
      column: $table.importBatchId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$BeneficiariesTableOrderingComposer get beneficiaryId {
    final $$BeneficiariesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.beneficiaryId,
        referencedTable: $db.beneficiaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BeneficiariesTableOrderingComposer(
              $db: $db,
              $table: $db.beneficiaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssociationsTableOrderingComposer get associationId {
    final $$AssociationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associationId,
        referencedTable: $db.associations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssociationsTableOrderingComposer(
              $db: $db,
              $table: $db.associations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SponsorshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SponsorshipsTable> {
  $$SponsorshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get fileNo =>
      $composableBuilder(column: $table.fileNo, builder: (column) => column);

  GeneratedColumn<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => column);

  GeneratedColumn<String> get internalFileNo => $composableBuilder(
      column: $table.internalFileNo, builder: (column) => column);

  GeneratedColumn<String> get externalFileNo => $composableBuilder(
      column: $table.externalFileNo, builder: (column) => column);

  GeneratedColumn<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => column);

  GeneratedColumn<int> get guardianIdNumber => $composableBuilder(
      column: $table.guardianIdNumber, builder: (column) => column);

  GeneratedColumn<String> get guardianPhone => $composableBuilder(
      column: $table.guardianPhone, builder: (column) => column);

  GeneratedColumn<String> get guardianAltPhone => $composableBuilder(
      column: $table.guardianAltPhone, builder: (column) => column);

  GeneratedColumn<int> get durationMonths => $composableBuilder(
      column: $table.durationMonths, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sponsorshipType => $composableBuilder(
      column: $table.sponsorshipType, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountHolderName => $composableBuilder(
      column: $table.accountHolderName, builder: (column) => column);

  GeneratedColumn<int> get accountHolderIdNumber => $composableBuilder(
      column: $table.accountHolderIdNumber, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get swiftCode =>
      $composableBuilder(column: $table.swiftCode, builder: (column) => column);

  GeneratedColumn<String> get governorate => $composableBuilder(
      column: $table.governorate, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get importBatchId => $composableBuilder(
      column: $table.importBatchId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$BeneficiariesTableAnnotationComposer get beneficiaryId {
    final $$BeneficiariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.beneficiaryId,
        referencedTable: $db.beneficiaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BeneficiariesTableAnnotationComposer(
              $db: $db,
              $table: $db.beneficiaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AssociationsTableAnnotationComposer get associationId {
    final $$AssociationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.associationId,
        referencedTable: $db.associations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssociationsTableAnnotationComposer(
              $db: $db,
              $table: $db.associations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SponsorshipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SponsorshipsTable,
    Sponsorship,
    $$SponsorshipsTableFilterComposer,
    $$SponsorshipsTableOrderingComposer,
    $$SponsorshipsTableAnnotationComposer,
    $$SponsorshipsTableCreateCompanionBuilder,
    $$SponsorshipsTableUpdateCompanionBuilder,
    (Sponsorship, $$SponsorshipsTableReferences),
    Sponsorship,
    PrefetchHooks Function({bool beneficiaryId, bool associationId})> {
  $$SponsorshipsTableTableManager(_$AppDatabase db, $SponsorshipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponsorshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponsorshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SponsorshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> fileNo = const Value.absent(),
            Value<int> beneficiaryId = const Value.absent(),
            Value<String> associationId = const Value.absent(),
            Value<String?> sponsorName = const Value.absent(),
            Value<String?> internalFileNo = const Value.absent(),
            Value<String?> externalFileNo = const Value.absent(),
            Value<String?> guardianName = const Value.absent(),
            Value<int?> guardianIdNumber = const Value.absent(),
            Value<String?> guardianPhone = const Value.absent(),
            Value<String?> guardianAltPhone = const Value.absent(),
            Value<int?> durationMonths = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> sponsorshipType = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountHolderName = const Value.absent(),
            Value<int?> accountHolderIdNumber = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> swiftCode = const Value.absent(),
            Value<String?> governorate = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int?> importBatchId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              SponsorshipsCompanion(
            fileNo: fileNo,
            beneficiaryId: beneficiaryId,
            associationId: associationId,
            sponsorName: sponsorName,
            internalFileNo: internalFileNo,
            externalFileNo: externalFileNo,
            guardianName: guardianName,
            guardianIdNumber: guardianIdNumber,
            guardianPhone: guardianPhone,
            guardianAltPhone: guardianAltPhone,
            durationMonths: durationMonths,
            startDate: startDate,
            endDate: endDate,
            amount: amount,
            currency: currency,
            status: status,
            sponsorshipType: sponsorshipType,
            bankName: bankName,
            accountHolderName: accountHolderName,
            accountHolderIdNumber: accountHolderIdNumber,
            accountNumber: accountNumber,
            swiftCode: swiftCode,
            governorate: governorate,
            city: city,
            address: address,
            importBatchId: importBatchId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> fileNo = const Value.absent(),
            required int beneficiaryId,
            required String associationId,
            Value<String?> sponsorName = const Value.absent(),
            Value<String?> internalFileNo = const Value.absent(),
            Value<String?> externalFileNo = const Value.absent(),
            Value<String?> guardianName = const Value.absent(),
            Value<int?> guardianIdNumber = const Value.absent(),
            Value<String?> guardianPhone = const Value.absent(),
            Value<String?> guardianAltPhone = const Value.absent(),
            Value<int?> durationMonths = const Value.absent(),
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<double?> amount = const Value.absent(),
            Value<String?> currency = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> sponsorshipType = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountHolderName = const Value.absent(),
            Value<int?> accountHolderIdNumber = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> swiftCode = const Value.absent(),
            Value<String?> governorate = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<int?> importBatchId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
          }) =>
              SponsorshipsCompanion.insert(
            fileNo: fileNo,
            beneficiaryId: beneficiaryId,
            associationId: associationId,
            sponsorName: sponsorName,
            internalFileNo: internalFileNo,
            externalFileNo: externalFileNo,
            guardianName: guardianName,
            guardianIdNumber: guardianIdNumber,
            guardianPhone: guardianPhone,
            guardianAltPhone: guardianAltPhone,
            durationMonths: durationMonths,
            startDate: startDate,
            endDate: endDate,
            amount: amount,
            currency: currency,
            status: status,
            sponsorshipType: sponsorshipType,
            bankName: bankName,
            accountHolderName: accountHolderName,
            accountHolderIdNumber: accountHolderIdNumber,
            accountNumber: accountNumber,
            swiftCode: swiftCode,
            governorate: governorate,
            city: city,
            address: address,
            importBatchId: importBatchId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SponsorshipsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {beneficiaryId = false, associationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (beneficiaryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.beneficiaryId,
                    referencedTable:
                        $$SponsorshipsTableReferences._beneficiaryIdTable(db),
                    referencedColumn: $$SponsorshipsTableReferences
                        ._beneficiaryIdTable(db)
                        .id,
                  ) as T;
                }
                if (associationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.associationId,
                    referencedTable:
                        $$SponsorshipsTableReferences._associationIdTable(db),
                    referencedColumn: $$SponsorshipsTableReferences
                        ._associationIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SponsorshipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SponsorshipsTable,
    Sponsorship,
    $$SponsorshipsTableFilterComposer,
    $$SponsorshipsTableOrderingComposer,
    $$SponsorshipsTableAnnotationComposer,
    $$SponsorshipsTableCreateCompanionBuilder,
    $$SponsorshipsTableUpdateCompanionBuilder,
    (Sponsorship, $$SponsorshipsTableReferences),
    Sponsorship,
    PrefetchHooks Function({bool beneficiaryId, bool associationId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BeneficiariesTableTableManager get beneficiaries =>
      $$BeneficiariesTableTableManager(_db, _db.beneficiaries);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$TaxonomiesTableTableManager get taxonomies =>
      $$TaxonomiesTableTableManager(_db, _db.taxonomies);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(_db, _db.syncMetadataTable);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$FamilyDeceasedTableTableTableManager get familyDeceasedTable =>
      $$FamilyDeceasedTableTableTableManager(_db, _db.familyDeceasedTable);
  $$FamilyMembersTableTableTableManager get familyMembersTable =>
      $$FamilyMembersTableTableTableManager(_db, _db.familyMembersTable);
  $$AssociationRepresentativesTableTableManager
      get associationRepresentatives =>
          $$AssociationRepresentativesTableTableManager(
              _db, _db.associationRepresentatives);
  $$AssociationsTableTableManager get associations =>
      $$AssociationsTableTableManager(_db, _db.associations);
  $$SponsorshipsTableTableManager get sponsorships =>
      $$SponsorshipsTableTableManager(_db, _db.sponsorships);
}
