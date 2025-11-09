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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameNormMeta = const VerificationMeta(
    'fullNameNorm',
  );
  @override
  late final GeneratedColumn<String> fullNameNorm = GeneratedColumn<String>(
    'full_name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNoMeta = const VerificationMeta('fileNo');
  @override
  late final GeneratedColumn<String> fileNo = GeneratedColumn<String>(
    'file_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _governorateMeta = const VerificationMeta(
    'governorate',
  );
  @override
  late final GeneratedColumn<String> governorate = GeneratedColumn<String>(
    'governorate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherNameMeta = const VerificationMeta(
    'motherName',
  );
  @override
  late final GeneratedColumn<String> motherName = GeneratedColumn<String>(
    'mother_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grandFatherNameMeta = const VerificationMeta(
    'grandFatherName',
  );
  @override
  late final GeneratedColumn<String> grandFatherName = GeneratedColumn<String>(
    'grand_father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyNameMeta = const VerificationMeta(
    'familyName',
  );
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
    'family_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altPhoneNumberMeta = const VerificationMeta(
    'altPhoneNumber',
  );
  @override
  late final GeneratedColumn<String> altPhoneNumber = GeneratedColumn<String>(
    'alt_phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familySizeMeta = const VerificationMeta(
    'familySize',
  );
  @override
  late final GeneratedColumn<int> familySize = GeneratedColumn<int>(
    'family_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maritalStatusMeta = const VerificationMeta(
    'maritalStatus',
  );
  @override
  late final GeneratedColumn<String> maritalStatus = GeneratedColumn<String>(
    'marital_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _educationLevelMeta = const VerificationMeta(
    'educationLevel',
  );
  @override
  late final GeneratedColumn<String> educationLevel = GeneratedColumn<String>(
    'education_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _healthStatusMeta = const VerificationMeta(
    'healthStatus',
  );
  @override
  late final GeneratedColumn<String> healthStatus = GeneratedColumn<String>(
    'health_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasDisabilityMeta = const VerificationMeta(
    'hasDisability',
  );
  @override
  late final GeneratedColumn<bool> hasDisability = GeneratedColumn<bool>(
    'has_disability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_disability" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _displacementStatusMeta =
      const VerificationMeta('displacementStatus');
  @override
  late final GeneratedColumn<int> displacementStatus = GeneratedColumn<int>(
    'displacement_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressBeforeDisplacementMeta =
      const VerificationMeta('addressBeforeDisplacement');
  @override
  late final GeneratedColumn<String> addressBeforeDisplacement =
      GeneratedColumn<String>(
        'address_before_displacement',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentAddressMeta = const VerificationMeta(
    'currentAddress',
  );
  @override
  late final GeneratedColumn<String> currentAddress = GeneratedColumn<String>(
    'current_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberOfMalesMeta = const VerificationMeta(
    'numberOfMales',
  );
  @override
  late final GeneratedColumn<int> numberOfMales = GeneratedColumn<int>(
    'number_of_males',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberOfFemalesMeta = const VerificationMeta(
    'numberOfFemales',
  );
  @override
  late final GeneratedColumn<int> numberOfFemales = GeneratedColumn<int>(
    'number_of_females',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chronicDiseasesCountMeta =
      const VerificationMeta('chronicDiseasesCount');
  @override
  late final GeneratedColumn<int> chronicDiseasesCount = GeneratedColumn<int>(
    'chronic_diseases_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialNeedsCountMeta = const VerificationMeta(
    'specialNeedsCount',
  );
  @override
  late final GeneratedColumn<int> specialNeedsCount = GeneratedColumn<int>(
    'special_needs_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employmentStatusMeta = const VerificationMeta(
    'employmentStatus',
  );
  @override
  late final GeneratedColumn<int> employmentStatus = GeneratedColumn<int>(
    'employment_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _housingStatusMeta = const VerificationMeta(
    'housingStatus',
  );
  @override
  late final GeneratedColumn<int> housingStatus = GeneratedColumn<int>(
    'housing_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _housingTypeMeta = const VerificationMeta(
    'housingType',
  );
  @override
  late final GeneratedColumn<int> housingType = GeneratedColumn<int>(
    'housing_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestStatusMeta = const VerificationMeta(
    'requestStatus',
  );
  @override
  late final GeneratedColumn<int> requestStatus = GeneratedColumn<int>(
    'request_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _associationNameMeta = const VerificationMeta(
    'associationName',
  );
  @override
  late final GeneratedColumn<String> associationName = GeneratedColumn<String>(
    'association_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    fullNameNorm,
    nationalId,
    fileNo,
    governorate,
    district,
    address,
    phoneNumber,
    motherName,
    fatherName,
    grandFatherName,
    familyName,
    altPhoneNumber,
    familySize,
    gender,
    category,
    birthDate,
    maritalStatus,
    educationLevel,
    healthStatus,
    hasDisability,
    displacementStatus,
    addressBeforeDisplacement,
    currentAddress,
    numberOfMales,
    numberOfFemales,
    chronicDiseasesCount,
    specialNeedsCount,
    employmentStatus,
    housingStatus,
    housingType,
    requestStatus,
    notes,
    associationName,
    createdAt,
    updatedAt,
    syncState,
    serverId,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beneficiaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Beneficiary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('full_name_norm')) {
      context.handle(
        _fullNameNormMeta,
        fullNameNorm.isAcceptableOrUnknown(
          data['full_name_norm']!,
          _fullNameNormMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fullNameNormMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('file_no')) {
      context.handle(
        _fileNoMeta,
        fileNo.isAcceptableOrUnknown(data['file_no']!, _fileNoMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNoMeta);
    }
    if (data.containsKey('governorate')) {
      context.handle(
        _governorateMeta,
        governorate.isAcceptableOrUnknown(
          data['governorate']!,
          _governorateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_governorateMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('mother_name')) {
      context.handle(
        _motherNameMeta,
        motherName.isAcceptableOrUnknown(data['mother_name']!, _motherNameMeta),
      );
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('grand_father_name')) {
      context.handle(
        _grandFatherNameMeta,
        grandFatherName.isAcceptableOrUnknown(
          data['grand_father_name']!,
          _grandFatherNameMeta,
        ),
      );
    }
    if (data.containsKey('family_name')) {
      context.handle(
        _familyNameMeta,
        familyName.isAcceptableOrUnknown(data['family_name']!, _familyNameMeta),
      );
    }
    if (data.containsKey('alt_phone_number')) {
      context.handle(
        _altPhoneNumberMeta,
        altPhoneNumber.isAcceptableOrUnknown(
          data['alt_phone_number']!,
          _altPhoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('family_size')) {
      context.handle(
        _familySizeMeta,
        familySize.isAcceptableOrUnknown(data['family_size']!, _familySizeMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('marital_status')) {
      context.handle(
        _maritalStatusMeta,
        maritalStatus.isAcceptableOrUnknown(
          data['marital_status']!,
          _maritalStatusMeta,
        ),
      );
    }
    if (data.containsKey('education_level')) {
      context.handle(
        _educationLevelMeta,
        educationLevel.isAcceptableOrUnknown(
          data['education_level']!,
          _educationLevelMeta,
        ),
      );
    }
    if (data.containsKey('health_status')) {
      context.handle(
        _healthStatusMeta,
        healthStatus.isAcceptableOrUnknown(
          data['health_status']!,
          _healthStatusMeta,
        ),
      );
    }
    if (data.containsKey('has_disability')) {
      context.handle(
        _hasDisabilityMeta,
        hasDisability.isAcceptableOrUnknown(
          data['has_disability']!,
          _hasDisabilityMeta,
        ),
      );
    }
    if (data.containsKey('displacement_status')) {
      context.handle(
        _displacementStatusMeta,
        displacementStatus.isAcceptableOrUnknown(
          data['displacement_status']!,
          _displacementStatusMeta,
        ),
      );
    }
    if (data.containsKey('address_before_displacement')) {
      context.handle(
        _addressBeforeDisplacementMeta,
        addressBeforeDisplacement.isAcceptableOrUnknown(
          data['address_before_displacement']!,
          _addressBeforeDisplacementMeta,
        ),
      );
    }
    if (data.containsKey('current_address')) {
      context.handle(
        _currentAddressMeta,
        currentAddress.isAcceptableOrUnknown(
          data['current_address']!,
          _currentAddressMeta,
        ),
      );
    }
    if (data.containsKey('number_of_males')) {
      context.handle(
        _numberOfMalesMeta,
        numberOfMales.isAcceptableOrUnknown(
          data['number_of_males']!,
          _numberOfMalesMeta,
        ),
      );
    }
    if (data.containsKey('number_of_females')) {
      context.handle(
        _numberOfFemalesMeta,
        numberOfFemales.isAcceptableOrUnknown(
          data['number_of_females']!,
          _numberOfFemalesMeta,
        ),
      );
    }
    if (data.containsKey('chronic_diseases_count')) {
      context.handle(
        _chronicDiseasesCountMeta,
        chronicDiseasesCount.isAcceptableOrUnknown(
          data['chronic_diseases_count']!,
          _chronicDiseasesCountMeta,
        ),
      );
    }
    if (data.containsKey('special_needs_count')) {
      context.handle(
        _specialNeedsCountMeta,
        specialNeedsCount.isAcceptableOrUnknown(
          data['special_needs_count']!,
          _specialNeedsCountMeta,
        ),
      );
    }
    if (data.containsKey('employment_status')) {
      context.handle(
        _employmentStatusMeta,
        employmentStatus.isAcceptableOrUnknown(
          data['employment_status']!,
          _employmentStatusMeta,
        ),
      );
    }
    if (data.containsKey('housing_status')) {
      context.handle(
        _housingStatusMeta,
        housingStatus.isAcceptableOrUnknown(
          data['housing_status']!,
          _housingStatusMeta,
        ),
      );
    }
    if (data.containsKey('housing_type')) {
      context.handle(
        _housingTypeMeta,
        housingType.isAcceptableOrUnknown(
          data['housing_type']!,
          _housingTypeMeta,
        ),
      );
    }
    if (data.containsKey('request_status')) {
      context.handle(
        _requestStatusMeta,
        requestStatus.isAcceptableOrUnknown(
          data['request_status']!,
          _requestStatusMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('association_name')) {
      context.handle(
        _associationNameMeta,
        associationName.isAcceptableOrUnknown(
          data['association_name']!,
          _associationNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Beneficiary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Beneficiary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      fullNameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_norm'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      )!,
      fileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_no'],
      )!,
      governorate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}governorate'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      motherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mother_name'],
      ),
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      ),
      grandFatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grand_father_name'],
      ),
      familyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_name'],
      ),
      altPhoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_phone_number'],
      ),
      familySize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}family_size'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      maritalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marital_status'],
      ),
      educationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}education_level'],
      ),
      healthStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_status'],
      ),
      hasDisability: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_disability'],
      )!,
      displacementStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}displacement_status'],
      ),
      addressBeforeDisplacement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_before_displacement'],
      ),
      currentAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_address'],
      ),
      numberOfMales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_males'],
      ),
      numberOfFemales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_females'],
      ),
      chronicDiseasesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chronic_diseases_count'],
      ),
      specialNeedsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}special_needs_count'],
      ),
      employmentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employment_status'],
      ),
      housingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}housing_status'],
      ),
      housingType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}housing_type'],
      ),
      requestStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_status'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      associationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}association_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $BeneficiariesTable createAlias(String alias) {
    return $BeneficiariesTable(attachedDatabase, alias);
  }
}

class Beneficiary extends DataClass implements Insertable<Beneficiary> {
  final String id;
  final String fullName;
  final String fullNameNorm;
  final String nationalId;
  final String fileNo;
  final String governorate;
  final String? district;
  final String? address;
  final String? phoneNumber;
  final String? motherName;
  final String? fatherName;
  final String? grandFatherName;
  final String? familyName;
  final String? altPhoneNumber;
  final int? familySize;
  final String gender;
  final String category;
  final DateTime? birthDate;
  final String? maritalStatus;
  final String? educationLevel;
  final String? healthStatus;
  final bool hasDisability;
  final int? displacementStatus;
  final String? addressBeforeDisplacement;
  final String? currentAddress;
  final int? numberOfMales;
  final int? numberOfFemales;
  final int? chronicDiseasesCount;
  final int? specialNeedsCount;
  final int? employmentStatus;
  final int? housingStatus;
  final int? housingType;
  final int? requestStatus;
  final String notes;
  final String? associationName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverId;
  final DateTime? lastSyncedAt;
  const Beneficiary({
    required this.id,
    required this.fullName,
    required this.fullNameNorm,
    required this.nationalId,
    required this.fileNo,
    required this.governorate,
    this.district,
    this.address,
    this.phoneNumber,
    this.motherName,
    this.fatherName,
    this.grandFatherName,
    this.familyName,
    this.altPhoneNumber,
    this.familySize,
    required this.gender,
    required this.category,
    this.birthDate,
    this.maritalStatus,
    this.educationLevel,
    this.healthStatus,
    required this.hasDisability,
    this.displacementStatus,
    this.addressBeforeDisplacement,
    this.currentAddress,
    this.numberOfMales,
    this.numberOfFemales,
    this.chronicDiseasesCount,
    this.specialNeedsCount,
    this.employmentStatus,
    this.housingStatus,
    this.housingType,
    this.requestStatus,
    required this.notes,
    this.associationName,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.serverId,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['full_name_norm'] = Variable<String>(fullNameNorm);
    map['national_id'] = Variable<String>(nationalId);
    map['file_no'] = Variable<String>(fileNo);
    map['governorate'] = Variable<String>(governorate);
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || motherName != null) {
      map['mother_name'] = Variable<String>(motherName);
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
    if (!nullToAbsent || altPhoneNumber != null) {
      map['alt_phone_number'] = Variable<String>(altPhoneNumber);
    }
    if (!nullToAbsent || familySize != null) {
      map['family_size'] = Variable<int>(familySize);
    }
    map['gender'] = Variable<String>(gender);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || maritalStatus != null) {
      map['marital_status'] = Variable<String>(maritalStatus);
    }
    if (!nullToAbsent || educationLevel != null) {
      map['education_level'] = Variable<String>(educationLevel);
    }
    if (!nullToAbsent || healthStatus != null) {
      map['health_status'] = Variable<String>(healthStatus);
    }
    map['has_disability'] = Variable<bool>(hasDisability);
    if (!nullToAbsent || displacementStatus != null) {
      map['displacement_status'] = Variable<int>(displacementStatus);
    }
    if (!nullToAbsent || addressBeforeDisplacement != null) {
      map['address_before_displacement'] = Variable<String>(
        addressBeforeDisplacement,
      );
    }
    if (!nullToAbsent || currentAddress != null) {
      map['current_address'] = Variable<String>(currentAddress);
    }
    if (!nullToAbsent || numberOfMales != null) {
      map['number_of_males'] = Variable<int>(numberOfMales);
    }
    if (!nullToAbsent || numberOfFemales != null) {
      map['number_of_females'] = Variable<int>(numberOfFemales);
    }
    if (!nullToAbsent || chronicDiseasesCount != null) {
      map['chronic_diseases_count'] = Variable<int>(chronicDiseasesCount);
    }
    if (!nullToAbsent || specialNeedsCount != null) {
      map['special_needs_count'] = Variable<int>(specialNeedsCount);
    }
    if (!nullToAbsent || employmentStatus != null) {
      map['employment_status'] = Variable<int>(employmentStatus);
    }
    if (!nullToAbsent || housingStatus != null) {
      map['housing_status'] = Variable<int>(housingStatus);
    }
    if (!nullToAbsent || housingType != null) {
      map['housing_type'] = Variable<int>(housingType);
    }
    if (!nullToAbsent || requestStatus != null) {
      map['request_status'] = Variable<int>(requestStatus);
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || associationName != null) {
      map['association_name'] = Variable<String>(associationName);
    }
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

  BeneficiariesCompanion toCompanion(bool nullToAbsent) {
    return BeneficiariesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      fullNameNorm: Value(fullNameNorm),
      nationalId: Value(nationalId),
      fileNo: Value(fileNo),
      governorate: Value(governorate),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      motherName: motherName == null && nullToAbsent
          ? const Value.absent()
          : Value(motherName),
      fatherName: fatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherName),
      grandFatherName: grandFatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(grandFatherName),
      familyName: familyName == null && nullToAbsent
          ? const Value.absent()
          : Value(familyName),
      altPhoneNumber: altPhoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(altPhoneNumber),
      familySize: familySize == null && nullToAbsent
          ? const Value.absent()
          : Value(familySize),
      gender: Value(gender),
      category: Value(category),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      maritalStatus: maritalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(maritalStatus),
      educationLevel: educationLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(educationLevel),
      healthStatus: healthStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(healthStatus),
      hasDisability: Value(hasDisability),
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
      numberOfMales: numberOfMales == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfMales),
      numberOfFemales: numberOfFemales == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfFemales),
      chronicDiseasesCount: chronicDiseasesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(chronicDiseasesCount),
      specialNeedsCount: specialNeedsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(specialNeedsCount),
      employmentStatus: employmentStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(employmentStatus),
      housingStatus: housingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(housingStatus),
      housingType: housingType == null && nullToAbsent
          ? const Value.absent()
          : Value(housingType),
      requestStatus: requestStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(requestStatus),
      notes: Value(notes),
      associationName: associationName == null && nullToAbsent
          ? const Value.absent()
          : Value(associationName),
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

  factory Beneficiary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Beneficiary(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      fullNameNorm: serializer.fromJson<String>(json['fullNameNorm']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      fileNo: serializer.fromJson<String>(json['fileNo']),
      governorate: serializer.fromJson<String>(json['governorate']),
      district: serializer.fromJson<String?>(json['district']),
      address: serializer.fromJson<String?>(json['address']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      motherName: serializer.fromJson<String?>(json['motherName']),
      fatherName: serializer.fromJson<String?>(json['fatherName']),
      grandFatherName: serializer.fromJson<String?>(json['grandFatherName']),
      familyName: serializer.fromJson<String?>(json['familyName']),
      altPhoneNumber: serializer.fromJson<String?>(json['altPhoneNumber']),
      familySize: serializer.fromJson<int?>(json['familySize']),
      gender: serializer.fromJson<String>(json['gender']),
      category: serializer.fromJson<String>(json['category']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      maritalStatus: serializer.fromJson<String?>(json['maritalStatus']),
      educationLevel: serializer.fromJson<String?>(json['educationLevel']),
      healthStatus: serializer.fromJson<String?>(json['healthStatus']),
      hasDisability: serializer.fromJson<bool>(json['hasDisability']),
      displacementStatus: serializer.fromJson<int?>(json['displacementStatus']),
      addressBeforeDisplacement: serializer.fromJson<String?>(
        json['addressBeforeDisplacement'],
      ),
      currentAddress: serializer.fromJson<String?>(json['currentAddress']),
      numberOfMales: serializer.fromJson<int?>(json['numberOfMales']),
      numberOfFemales: serializer.fromJson<int?>(json['numberOfFemales']),
      chronicDiseasesCount: serializer.fromJson<int?>(
        json['chronicDiseasesCount'],
      ),
      specialNeedsCount: serializer.fromJson<int?>(json['specialNeedsCount']),
      employmentStatus: serializer.fromJson<int?>(json['employmentStatus']),
      housingStatus: serializer.fromJson<int?>(json['housingStatus']),
      housingType: serializer.fromJson<int?>(json['housingType']),
      requestStatus: serializer.fromJson<int?>(json['requestStatus']),
      notes: serializer.fromJson<String>(json['notes']),
      associationName: serializer.fromJson<String?>(json['associationName']),
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
      'fullName': serializer.toJson<String>(fullName),
      'fullNameNorm': serializer.toJson<String>(fullNameNorm),
      'nationalId': serializer.toJson<String>(nationalId),
      'fileNo': serializer.toJson<String>(fileNo),
      'governorate': serializer.toJson<String>(governorate),
      'district': serializer.toJson<String?>(district),
      'address': serializer.toJson<String?>(address),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'motherName': serializer.toJson<String?>(motherName),
      'fatherName': serializer.toJson<String?>(fatherName),
      'grandFatherName': serializer.toJson<String?>(grandFatherName),
      'familyName': serializer.toJson<String?>(familyName),
      'altPhoneNumber': serializer.toJson<String?>(altPhoneNumber),
      'familySize': serializer.toJson<int?>(familySize),
      'gender': serializer.toJson<String>(gender),
      'category': serializer.toJson<String>(category),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'maritalStatus': serializer.toJson<String?>(maritalStatus),
      'educationLevel': serializer.toJson<String?>(educationLevel),
      'healthStatus': serializer.toJson<String?>(healthStatus),
      'hasDisability': serializer.toJson<bool>(hasDisability),
      'displacementStatus': serializer.toJson<int?>(displacementStatus),
      'addressBeforeDisplacement': serializer.toJson<String?>(
        addressBeforeDisplacement,
      ),
      'currentAddress': serializer.toJson<String?>(currentAddress),
      'numberOfMales': serializer.toJson<int?>(numberOfMales),
      'numberOfFemales': serializer.toJson<int?>(numberOfFemales),
      'chronicDiseasesCount': serializer.toJson<int?>(chronicDiseasesCount),
      'specialNeedsCount': serializer.toJson<int?>(specialNeedsCount),
      'employmentStatus': serializer.toJson<int?>(employmentStatus),
      'housingStatus': serializer.toJson<int?>(housingStatus),
      'housingType': serializer.toJson<int?>(housingType),
      'requestStatus': serializer.toJson<int?>(requestStatus),
      'notes': serializer.toJson<String>(notes),
      'associationName': serializer.toJson<String?>(associationName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Beneficiary copyWith({
    String? id,
    String? fullName,
    String? fullNameNorm,
    String? nationalId,
    String? fileNo,
    String? governorate,
    Value<String?> district = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> motherName = const Value.absent(),
    Value<String?> fatherName = const Value.absent(),
    Value<String?> grandFatherName = const Value.absent(),
    Value<String?> familyName = const Value.absent(),
    Value<String?> altPhoneNumber = const Value.absent(),
    Value<int?> familySize = const Value.absent(),
    String? gender,
    String? category,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> maritalStatus = const Value.absent(),
    Value<String?> educationLevel = const Value.absent(),
    Value<String?> healthStatus = const Value.absent(),
    bool? hasDisability,
    Value<int?> displacementStatus = const Value.absent(),
    Value<String?> addressBeforeDisplacement = const Value.absent(),
    Value<String?> currentAddress = const Value.absent(),
    Value<int?> numberOfMales = const Value.absent(),
    Value<int?> numberOfFemales = const Value.absent(),
    Value<int?> chronicDiseasesCount = const Value.absent(),
    Value<int?> specialNeedsCount = const Value.absent(),
    Value<int?> employmentStatus = const Value.absent(),
    Value<int?> housingStatus = const Value.absent(),
    Value<int?> housingType = const Value.absent(),
    Value<int?> requestStatus = const Value.absent(),
    String? notes,
    Value<String?> associationName = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<String?> serverId = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Beneficiary(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    fullNameNorm: fullNameNorm ?? this.fullNameNorm,
    nationalId: nationalId ?? this.nationalId,
    fileNo: fileNo ?? this.fileNo,
    governorate: governorate ?? this.governorate,
    district: district.present ? district.value : this.district,
    address: address.present ? address.value : this.address,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    motherName: motherName.present ? motherName.value : this.motherName,
    fatherName: fatherName.present ? fatherName.value : this.fatherName,
    grandFatherName: grandFatherName.present
        ? grandFatherName.value
        : this.grandFatherName,
    familyName: familyName.present ? familyName.value : this.familyName,
    altPhoneNumber: altPhoneNumber.present
        ? altPhoneNumber.value
        : this.altPhoneNumber,
    familySize: familySize.present ? familySize.value : this.familySize,
    gender: gender ?? this.gender,
    category: category ?? this.category,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    maritalStatus: maritalStatus.present
        ? maritalStatus.value
        : this.maritalStatus,
    educationLevel: educationLevel.present
        ? educationLevel.value
        : this.educationLevel,
    healthStatus: healthStatus.present ? healthStatus.value : this.healthStatus,
    hasDisability: hasDisability ?? this.hasDisability,
    displacementStatus: displacementStatus.present
        ? displacementStatus.value
        : this.displacementStatus,
    addressBeforeDisplacement: addressBeforeDisplacement.present
        ? addressBeforeDisplacement.value
        : this.addressBeforeDisplacement,
    currentAddress: currentAddress.present
        ? currentAddress.value
        : this.currentAddress,
    numberOfMales: numberOfMales.present
        ? numberOfMales.value
        : this.numberOfMales,
    numberOfFemales: numberOfFemales.present
        ? numberOfFemales.value
        : this.numberOfFemales,
    chronicDiseasesCount: chronicDiseasesCount.present
        ? chronicDiseasesCount.value
        : this.chronicDiseasesCount,
    specialNeedsCount: specialNeedsCount.present
        ? specialNeedsCount.value
        : this.specialNeedsCount,
    employmentStatus: employmentStatus.present
        ? employmentStatus.value
        : this.employmentStatus,
    housingStatus: housingStatus.present
        ? housingStatus.value
        : this.housingStatus,
    housingType: housingType.present ? housingType.value : this.housingType,
    requestStatus: requestStatus.present
        ? requestStatus.value
        : this.requestStatus,
    notes: notes ?? this.notes,
    associationName: associationName.present
        ? associationName.value
        : this.associationName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    serverId: serverId.present ? serverId.value : this.serverId,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  Beneficiary copyWithCompanion(BeneficiariesCompanion data) {
    return Beneficiary(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      fullNameNorm: data.fullNameNorm.present
          ? data.fullNameNorm.value
          : this.fullNameNorm,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      fileNo: data.fileNo.present ? data.fileNo.value : this.fileNo,
      governorate: data.governorate.present
          ? data.governorate.value
          : this.governorate,
      district: data.district.present ? data.district.value : this.district,
      address: data.address.present ? data.address.value : this.address,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      motherName: data.motherName.present
          ? data.motherName.value
          : this.motherName,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      grandFatherName: data.grandFatherName.present
          ? data.grandFatherName.value
          : this.grandFatherName,
      familyName: data.familyName.present
          ? data.familyName.value
          : this.familyName,
      altPhoneNumber: data.altPhoneNumber.present
          ? data.altPhoneNumber.value
          : this.altPhoneNumber,
      familySize: data.familySize.present
          ? data.familySize.value
          : this.familySize,
      gender: data.gender.present ? data.gender.value : this.gender,
      category: data.category.present ? data.category.value : this.category,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      maritalStatus: data.maritalStatus.present
          ? data.maritalStatus.value
          : this.maritalStatus,
      educationLevel: data.educationLevel.present
          ? data.educationLevel.value
          : this.educationLevel,
      healthStatus: data.healthStatus.present
          ? data.healthStatus.value
          : this.healthStatus,
      hasDisability: data.hasDisability.present
          ? data.hasDisability.value
          : this.hasDisability,
      displacementStatus: data.displacementStatus.present
          ? data.displacementStatus.value
          : this.displacementStatus,
      addressBeforeDisplacement: data.addressBeforeDisplacement.present
          ? data.addressBeforeDisplacement.value
          : this.addressBeforeDisplacement,
      currentAddress: data.currentAddress.present
          ? data.currentAddress.value
          : this.currentAddress,
      numberOfMales: data.numberOfMales.present
          ? data.numberOfMales.value
          : this.numberOfMales,
      numberOfFemales: data.numberOfFemales.present
          ? data.numberOfFemales.value
          : this.numberOfFemales,
      chronicDiseasesCount: data.chronicDiseasesCount.present
          ? data.chronicDiseasesCount.value
          : this.chronicDiseasesCount,
      specialNeedsCount: data.specialNeedsCount.present
          ? data.specialNeedsCount.value
          : this.specialNeedsCount,
      employmentStatus: data.employmentStatus.present
          ? data.employmentStatus.value
          : this.employmentStatus,
      housingStatus: data.housingStatus.present
          ? data.housingStatus.value
          : this.housingStatus,
      housingType: data.housingType.present
          ? data.housingType.value
          : this.housingType,
      requestStatus: data.requestStatus.present
          ? data.requestStatus.value
          : this.requestStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
      associationName: data.associationName.present
          ? data.associationName.value
          : this.associationName,
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
    return (StringBuffer('Beneficiary(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNorm: $fullNameNorm, ')
          ..write('nationalId: $nationalId, ')
          ..write('fileNo: $fileNo, ')
          ..write('governorate: $governorate, ')
          ..write('district: $district, ')
          ..write('address: $address, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('motherName: $motherName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('altPhoneNumber: $altPhoneNumber, ')
          ..write('familySize: $familySize, ')
          ..write('gender: $gender, ')
          ..write('category: $category, ')
          ..write('birthDate: $birthDate, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('hasDisability: $hasDisability, ')
          ..write('displacementStatus: $displacementStatus, ')
          ..write('addressBeforeDisplacement: $addressBeforeDisplacement, ')
          ..write('currentAddress: $currentAddress, ')
          ..write('numberOfMales: $numberOfMales, ')
          ..write('numberOfFemales: $numberOfFemales, ')
          ..write('chronicDiseasesCount: $chronicDiseasesCount, ')
          ..write('specialNeedsCount: $specialNeedsCount, ')
          ..write('employmentStatus: $employmentStatus, ')
          ..write('housingStatus: $housingStatus, ')
          ..write('housingType: $housingType, ')
          ..write('requestStatus: $requestStatus, ')
          ..write('notes: $notes, ')
          ..write('associationName: $associationName, ')
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
    fullName,
    fullNameNorm,
    nationalId,
    fileNo,
    governorate,
    district,
    address,
    phoneNumber,
    motherName,
    fatherName,
    grandFatherName,
    familyName,
    altPhoneNumber,
    familySize,
    gender,
    category,
    birthDate,
    maritalStatus,
    educationLevel,
    healthStatus,
    hasDisability,
    displacementStatus,
    addressBeforeDisplacement,
    currentAddress,
    numberOfMales,
    numberOfFemales,
    chronicDiseasesCount,
    specialNeedsCount,
    employmentStatus,
    housingStatus,
    housingType,
    requestStatus,
    notes,
    associationName,
    createdAt,
    updatedAt,
    syncState,
    serverId,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Beneficiary &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.fullNameNorm == this.fullNameNorm &&
          other.nationalId == this.nationalId &&
          other.fileNo == this.fileNo &&
          other.governorate == this.governorate &&
          other.district == this.district &&
          other.address == this.address &&
          other.phoneNumber == this.phoneNumber &&
          other.motherName == this.motherName &&
          other.fatherName == this.fatherName &&
          other.grandFatherName == this.grandFatherName &&
          other.familyName == this.familyName &&
          other.altPhoneNumber == this.altPhoneNumber &&
          other.familySize == this.familySize &&
          other.gender == this.gender &&
          other.category == this.category &&
          other.birthDate == this.birthDate &&
          other.maritalStatus == this.maritalStatus &&
          other.educationLevel == this.educationLevel &&
          other.healthStatus == this.healthStatus &&
          other.hasDisability == this.hasDisability &&
          other.displacementStatus == this.displacementStatus &&
          other.addressBeforeDisplacement == this.addressBeforeDisplacement &&
          other.currentAddress == this.currentAddress &&
          other.numberOfMales == this.numberOfMales &&
          other.numberOfFemales == this.numberOfFemales &&
          other.chronicDiseasesCount == this.chronicDiseasesCount &&
          other.specialNeedsCount == this.specialNeedsCount &&
          other.employmentStatus == this.employmentStatus &&
          other.housingStatus == this.housingStatus &&
          other.housingType == this.housingType &&
          other.requestStatus == this.requestStatus &&
          other.notes == this.notes &&
          other.associationName == this.associationName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class BeneficiariesCompanion extends UpdateCompanion<Beneficiary> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String> fullNameNorm;
  final Value<String> nationalId;
  final Value<String> fileNo;
  final Value<String> governorate;
  final Value<String?> district;
  final Value<String?> address;
  final Value<String?> phoneNumber;
  final Value<String?> motherName;
  final Value<String?> fatherName;
  final Value<String?> grandFatherName;
  final Value<String?> familyName;
  final Value<String?> altPhoneNumber;
  final Value<int?> familySize;
  final Value<String> gender;
  final Value<String> category;
  final Value<DateTime?> birthDate;
  final Value<String?> maritalStatus;
  final Value<String?> educationLevel;
  final Value<String?> healthStatus;
  final Value<bool> hasDisability;
  final Value<int?> displacementStatus;
  final Value<String?> addressBeforeDisplacement;
  final Value<String?> currentAddress;
  final Value<int?> numberOfMales;
  final Value<int?> numberOfFemales;
  final Value<int?> chronicDiseasesCount;
  final Value<int?> specialNeedsCount;
  final Value<int?> employmentStatus;
  final Value<int?> housingStatus;
  final Value<int?> housingType;
  final Value<int?> requestStatus;
  final Value<String> notes;
  final Value<String?> associationName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const BeneficiariesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fullNameNorm = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.fileNo = const Value.absent(),
    this.governorate = const Value.absent(),
    this.district = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.motherName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.altPhoneNumber = const Value.absent(),
    this.familySize = const Value.absent(),
    this.gender = const Value.absent(),
    this.category = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.hasDisability = const Value.absent(),
    this.displacementStatus = const Value.absent(),
    this.addressBeforeDisplacement = const Value.absent(),
    this.currentAddress = const Value.absent(),
    this.numberOfMales = const Value.absent(),
    this.numberOfFemales = const Value.absent(),
    this.chronicDiseasesCount = const Value.absent(),
    this.specialNeedsCount = const Value.absent(),
    this.employmentStatus = const Value.absent(),
    this.housingStatus = const Value.absent(),
    this.housingType = const Value.absent(),
    this.requestStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.associationName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeneficiariesCompanion.insert({
    required String id,
    required String fullName,
    required String fullNameNorm,
    required String nationalId,
    required String fileNo,
    required String governorate,
    this.district = const Value.absent(),
    this.address = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.motherName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.altPhoneNumber = const Value.absent(),
    this.familySize = const Value.absent(),
    required String gender,
    required String category,
    this.birthDate = const Value.absent(),
    this.maritalStatus = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.hasDisability = const Value.absent(),
    this.displacementStatus = const Value.absent(),
    this.addressBeforeDisplacement = const Value.absent(),
    this.currentAddress = const Value.absent(),
    this.numberOfMales = const Value.absent(),
    this.numberOfFemales = const Value.absent(),
    this.chronicDiseasesCount = const Value.absent(),
    this.specialNeedsCount = const Value.absent(),
    this.employmentStatus = const Value.absent(),
    this.housingStatus = const Value.absent(),
    this.housingType = const Value.absent(),
    this.requestStatus = const Value.absent(),
    this.notes = const Value.absent(),
    this.associationName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName),
       fullNameNorm = Value(fullNameNorm),
       nationalId = Value(nationalId),
       fileNo = Value(fileNo),
       governorate = Value(governorate),
       gender = Value(gender),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Beneficiary> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? fullNameNorm,
    Expression<String>? nationalId,
    Expression<String>? fileNo,
    Expression<String>? governorate,
    Expression<String>? district,
    Expression<String>? address,
    Expression<String>? phoneNumber,
    Expression<String>? motherName,
    Expression<String>? fatherName,
    Expression<String>? grandFatherName,
    Expression<String>? familyName,
    Expression<String>? altPhoneNumber,
    Expression<int>? familySize,
    Expression<String>? gender,
    Expression<String>? category,
    Expression<DateTime>? birthDate,
    Expression<String>? maritalStatus,
    Expression<String>? educationLevel,
    Expression<String>? healthStatus,
    Expression<bool>? hasDisability,
    Expression<int>? displacementStatus,
    Expression<String>? addressBeforeDisplacement,
    Expression<String>? currentAddress,
    Expression<int>? numberOfMales,
    Expression<int>? numberOfFemales,
    Expression<int>? chronicDiseasesCount,
    Expression<int>? specialNeedsCount,
    Expression<int>? employmentStatus,
    Expression<int>? housingStatus,
    Expression<int>? housingType,
    Expression<int>? requestStatus,
    Expression<String>? notes,
    Expression<String>? associationName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (fullNameNorm != null) 'full_name_norm': fullNameNorm,
      if (nationalId != null) 'national_id': nationalId,
      if (fileNo != null) 'file_no': fileNo,
      if (governorate != null) 'governorate': governorate,
      if (district != null) 'district': district,
      if (address != null) 'address': address,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (motherName != null) 'mother_name': motherName,
      if (fatherName != null) 'father_name': fatherName,
      if (grandFatherName != null) 'grand_father_name': grandFatherName,
      if (familyName != null) 'family_name': familyName,
      if (altPhoneNumber != null) 'alt_phone_number': altPhoneNumber,
      if (familySize != null) 'family_size': familySize,
      if (gender != null) 'gender': gender,
      if (category != null) 'category': category,
      if (birthDate != null) 'birth_date': birthDate,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (educationLevel != null) 'education_level': educationLevel,
      if (healthStatus != null) 'health_status': healthStatus,
      if (hasDisability != null) 'has_disability': hasDisability,
      if (displacementStatus != null) 'displacement_status': displacementStatus,
      if (addressBeforeDisplacement != null)
        'address_before_displacement': addressBeforeDisplacement,
      if (currentAddress != null) 'current_address': currentAddress,
      if (numberOfMales != null) 'number_of_males': numberOfMales,
      if (numberOfFemales != null) 'number_of_females': numberOfFemales,
      if (chronicDiseasesCount != null)
        'chronic_diseases_count': chronicDiseasesCount,
      if (specialNeedsCount != null) 'special_needs_count': specialNeedsCount,
      if (employmentStatus != null) 'employment_status': employmentStatus,
      if (housingStatus != null) 'housing_status': housingStatus,
      if (housingType != null) 'housing_type': housingType,
      if (requestStatus != null) 'request_status': requestStatus,
      if (notes != null) 'notes': notes,
      if (associationName != null) 'association_name': associationName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeneficiariesCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String>? fullNameNorm,
    Value<String>? nationalId,
    Value<String>? fileNo,
    Value<String>? governorate,
    Value<String?>? district,
    Value<String?>? address,
    Value<String?>? phoneNumber,
    Value<String?>? motherName,
    Value<String?>? fatherName,
    Value<String?>? grandFatherName,
    Value<String?>? familyName,
    Value<String?>? altPhoneNumber,
    Value<int?>? familySize,
    Value<String>? gender,
    Value<String>? category,
    Value<DateTime?>? birthDate,
    Value<String?>? maritalStatus,
    Value<String?>? educationLevel,
    Value<String?>? healthStatus,
    Value<bool>? hasDisability,
    Value<int?>? displacementStatus,
    Value<String?>? addressBeforeDisplacement,
    Value<String?>? currentAddress,
    Value<int?>? numberOfMales,
    Value<int?>? numberOfFemales,
    Value<int?>? chronicDiseasesCount,
    Value<int?>? specialNeedsCount,
    Value<int?>? employmentStatus,
    Value<int?>? housingStatus,
    Value<int?>? housingType,
    Value<int?>? requestStatus,
    Value<String>? notes,
    Value<String?>? associationName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<String?>? serverId,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return BeneficiariesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      fullNameNorm: fullNameNorm ?? this.fullNameNorm,
      nationalId: nationalId ?? this.nationalId,
      fileNo: fileNo ?? this.fileNo,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      familyName: familyName ?? this.familyName,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      familySize: familySize ?? this.familySize,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      birthDate: birthDate ?? this.birthDate,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      healthStatus: healthStatus ?? this.healthStatus,
      hasDisability: hasDisability ?? this.hasDisability,
      displacementStatus: displacementStatus ?? this.displacementStatus,
      addressBeforeDisplacement:
          addressBeforeDisplacement ?? this.addressBeforeDisplacement,
      currentAddress: currentAddress ?? this.currentAddress,
      numberOfMales: numberOfMales ?? this.numberOfMales,
      numberOfFemales: numberOfFemales ?? this.numberOfFemales,
      chronicDiseasesCount: chronicDiseasesCount ?? this.chronicDiseasesCount,
      specialNeedsCount: specialNeedsCount ?? this.specialNeedsCount,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      housingStatus: housingStatus ?? this.housingStatus,
      housingType: housingType ?? this.housingType,
      requestStatus: requestStatus ?? this.requestStatus,
      notes: notes ?? this.notes,
      associationName: associationName ?? this.associationName,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (fullNameNorm.present) {
      map['full_name_norm'] = Variable<String>(fullNameNorm.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (fileNo.present) {
      map['file_no'] = Variable<String>(fileNo.value);
    }
    if (governorate.present) {
      map['governorate'] = Variable<String>(governorate.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (motherName.present) {
      map['mother_name'] = Variable<String>(motherName.value);
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
    if (altPhoneNumber.present) {
      map['alt_phone_number'] = Variable<String>(altPhoneNumber.value);
    }
    if (familySize.present) {
      map['family_size'] = Variable<int>(familySize.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (maritalStatus.present) {
      map['marital_status'] = Variable<String>(maritalStatus.value);
    }
    if (educationLevel.present) {
      map['education_level'] = Variable<String>(educationLevel.value);
    }
    if (healthStatus.present) {
      map['health_status'] = Variable<String>(healthStatus.value);
    }
    if (hasDisability.present) {
      map['has_disability'] = Variable<bool>(hasDisability.value);
    }
    if (displacementStatus.present) {
      map['displacement_status'] = Variable<int>(displacementStatus.value);
    }
    if (addressBeforeDisplacement.present) {
      map['address_before_displacement'] = Variable<String>(
        addressBeforeDisplacement.value,
      );
    }
    if (currentAddress.present) {
      map['current_address'] = Variable<String>(currentAddress.value);
    }
    if (numberOfMales.present) {
      map['number_of_males'] = Variable<int>(numberOfMales.value);
    }
    if (numberOfFemales.present) {
      map['number_of_females'] = Variable<int>(numberOfFemales.value);
    }
    if (chronicDiseasesCount.present) {
      map['chronic_diseases_count'] = Variable<int>(chronicDiseasesCount.value);
    }
    if (specialNeedsCount.present) {
      map['special_needs_count'] = Variable<int>(specialNeedsCount.value);
    }
    if (employmentStatus.present) {
      map['employment_status'] = Variable<int>(employmentStatus.value);
    }
    if (housingStatus.present) {
      map['housing_status'] = Variable<int>(housingStatus.value);
    }
    if (housingType.present) {
      map['housing_type'] = Variable<int>(housingType.value);
    }
    if (requestStatus.present) {
      map['request_status'] = Variable<int>(requestStatus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (associationName.present) {
      map['association_name'] = Variable<String>(associationName.value);
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
    return (StringBuffer('BeneficiariesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNorm: $fullNameNorm, ')
          ..write('nationalId: $nationalId, ')
          ..write('fileNo: $fileNo, ')
          ..write('governorate: $governorate, ')
          ..write('district: $district, ')
          ..write('address: $address, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('motherName: $motherName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('altPhoneNumber: $altPhoneNumber, ')
          ..write('familySize: $familySize, ')
          ..write('gender: $gender, ')
          ..write('category: $category, ')
          ..write('birthDate: $birthDate, ')
          ..write('maritalStatus: $maritalStatus, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('hasDisability: $hasDisability, ')
          ..write('displacementStatus: $displacementStatus, ')
          ..write('addressBeforeDisplacement: $addressBeforeDisplacement, ')
          ..write('currentAddress: $currentAddress, ')
          ..write('numberOfMales: $numberOfMales, ')
          ..write('numberOfFemales: $numberOfFemales, ')
          ..write('chronicDiseasesCount: $chronicDiseasesCount, ')
          ..write('specialNeedsCount: $specialNeedsCount, ')
          ..write('employmentStatus: $employmentStatus, ')
          ..write('housingStatus: $housingStatus, ')
          ..write('housingType: $housingType, ')
          ..write('requestStatus: $requestStatus, ')
          ..write('notes: $notes, ')
          ..write('associationName: $associationName, ')
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

class $VisitsTable extends Visits with TableInfo<$VisitsTable, Visit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beneficiaryIdMeta = const VerificationMeta(
    'beneficiaryId',
  );
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
    'beneficiary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffNameMeta = const VerificationMeta(
    'staffName',
  );
  @override
  late final GeneratedColumn<String> staffName = GeneratedColumn<String>(
    'staff_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSubmittedMeta = const VerificationMeta(
    'isSubmitted',
  );
  @override
  late final GeneratedColumn<bool> isSubmitted = GeneratedColumn<bool>(
    'is_submitted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_submitted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
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
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Visit> instance, {
    bool isInserting = false,
  }) {
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
          data['beneficiary_id']!,
          _beneficiaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('staff_name')) {
      context.handle(
        _staffNameMeta,
        staffName.isAcceptableOrUnknown(data['staff_name']!, _staffNameMeta),
      );
    } else if (isInserting) {
      context.missing(_staffNameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_submitted')) {
      context.handle(
        _isSubmittedMeta,
        isSubmitted.isAcceptableOrUnknown(
          data['is_submitted']!,
          _isSubmittedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Visit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Visit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beneficiaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiary_id'],
      )!,
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visit_date'],
      )!,
      staffName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isSubmitted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_submitted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
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
  const Visit({
    required this.id,
    required this.beneficiaryId,
    required this.visitDate,
    required this.staffName,
    required this.notes,
    required this.isSubmitted,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.serverId,
    this.lastSyncedAt,
  });
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

  factory Visit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Visit copyWith({
    String? id,
    String? beneficiaryId,
    DateTime? visitDate,
    String? staffName,
    String? notes,
    bool? isSubmitted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<String?> serverId = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Visit(
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
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
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
      isSubmitted: data.isSubmitted.present
          ? data.isSubmitted.value
          : this.isSubmitted,
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
    lastSyncedAt,
  );
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
  }) : id = Value(id),
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

  VisitsCompanion copyWith({
    Value<String>? id,
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
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beneficiaryIdMeta = const VerificationMeta(
    'beneficiaryId',
  );
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
    'beneficiary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
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
    createdAt,
    updatedAt,
    syncState,
    serverUrl,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
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
          data['beneficiary_id']!,
          _beneficiaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beneficiaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiary_id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverUrl;
  final DateTime? lastSyncedAt;
  const Attachment({
    required this.id,
    required this.beneficiaryId,
    this.visitId,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSize,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.serverUrl,
    this.lastSyncedAt,
  });
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

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? beneficiaryId,
    Value<String?> visitId = const Value.absent(),
    String? fileName,
    String? filePath,
    String? type,
    int? fileSize,
    Value<String?> thumbnailPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<String?> serverUrl = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => Attachment(
    id: id ?? this.id,
    beneficiaryId: beneficiaryId ?? this.beneficiaryId,
    visitId: visitId.present ? visitId.value : this.visitId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    type: type ?? this.type,
    fileSize: fileSize ?? this.fileSize,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
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
    createdAt,
    updatedAt,
    syncState,
    serverUrl,
    lastSyncedAt,
  );
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
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
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
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverUrl != null) 'server_url': serverUrl,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? beneficiaryId,
    Value<String?>? visitId,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String>? type,
    Value<int>? fileSize,
    Value<String?>? thumbnailPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<String?>? serverUrl,
    Value<DateTime?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      visitId: visitId ?? this.visitId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    group,
    code,
    label,
    parentId,
    sortOrder,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxonomies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Taxonomy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
        _groupMeta,
        group.isAcceptableOrUnknown(data['group']!, _groupMeta),
      );
    } else if (isInserting) {
      context.missing(_groupMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const Taxonomy({
    required this.id,
    required this.group,
    required this.code,
    required this.label,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.updatedAt,
  });
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

  factory Taxonomy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Taxonomy copyWith({
    String? id,
    String? group,
    String? code,
    String? label,
    Value<String?> parentId = const Value.absent(),
    int? sortOrder,
    bool? isActive,
    DateTime? updatedAt,
  }) => Taxonomy(
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
    id,
    group,
    code,
    label,
    parentId,
    sortOrder,
    isActive,
    updatedAt,
  );
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
  }) : id = Value(id),
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

  TaxonomiesCompanion copyWith({
    Value<String>? id,
    Value<String>? group,
    Value<String>? code,
    Value<String>? label,
    Value<String?>? parentId,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
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
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
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
    scheduledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
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
  const SyncQueueData({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.priority,
    required this.attempts,
    this.lastError,
    required this.createdAt,
    this.scheduledAt,
  });
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

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
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

  SyncQueueData copyWith({
    String? id,
    String? entity,
    String? entityId,
    String? operation,
    String? payload,
    int? priority,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> scheduledAt = const Value.absent(),
  }) => SyncQueueData(
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
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
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
  int get hashCode => Object.hash(
    id,
    entity,
    entityId,
    operation,
    payload,
    priority,
    attempts,
    lastError,
    createdAt,
    scheduledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
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

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
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
  }) : id = Value(id),
       entity = Value(entity),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
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

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? priority,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? scheduledAt,
    Value<int>? rowid,
  }) {
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

class $CivilRegistryTable extends CivilRegistry
    with TableInfo<$CivilRegistryTable, CivilRegistryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'CI_ID_NUM',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'CI_FIRST_ARB',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'CI_FATHER_ARB',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grandFatherNameMeta = const VerificationMeta(
    'grandFatherName',
  );
  @override
  late final GeneratedColumn<String> grandFatherName = GeneratedColumn<String>(
    'CI_GRAND_FATHER_ARB',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyNameMeta = const VerificationMeta(
    'familyName',
  );
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
    'CI_FAMILY_ARB',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthCertificateIdMeta =
      const VerificationMeta('birthCertificateId');
  @override
  late final GeneratedColumn<int> birthCertificateId = GeneratedColumn<int>(
    'CI_BIRTH_TB_CD',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthCodeIdMeta = const VerificationMeta(
    'birthCodeId',
  );
  @override
  late final GeneratedColumn<int> birthCodeId = GeneratedColumn<int>(
    'CI_BIRTH_CD',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'CI_BIRTH_DT',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexCodeMeta = const VerificationMeta(
    'sexCode',
  );
  @override
  late final GeneratedColumn<int> sexCode = GeneratedColumn<int>(
    'CI_SEX_CD',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalCodeIdMeta = const VerificationMeta(
    'personalCodeId',
  );
  @override
  late final GeneratedColumn<int> personalCodeId = GeneratedColumn<int>(
    'CI_PERSONAL_CD',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadDateMeta = const VerificationMeta(
    'deadDate',
  );
  @override
  late final GeneratedColumn<int> deadDate = GeneratedColumn<int>(
    'CI_DEAD_DT',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherNameMeta = const VerificationMeta(
    'motherName',
  );
  @override
  late final GeneratedColumn<String> motherName = GeneratedColumn<String>(
    'MOTHER_NAME1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<int> cityId = GeneratedColumn<int>(
    'CITY',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityNameMeta = const VerificationMeta(
    'cityName',
  );
  @override
  late final GeneratedColumn<String> cityName = GeneratedColumn<String>(
    'city_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'STREET',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _houseNoMeta = const VerificationMeta(
    'houseNo',
  );
  @override
  late final GeneratedColumn<String> houseNo = GeneratedColumn<String>(
    'HOUSE_NO',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationIdMeta = const VerificationMeta(
    'relationId',
  );
  @override
  late final GeneratedColumn<int> relationId = GeneratedColumn<int>(
    'CF_ID_NUM',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativeCodeIdMeta = const VerificationMeta(
    'relativeCodeId',
  );
  @override
  late final GeneratedColumn<int> relativeCodeId = GeneratedColumn<int>(
    'CF_RELATIVE_CD',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relativeIdMeta = const VerificationMeta(
    'relativeId',
  );
  @override
  late final GeneratedColumn<int> relativeId = GeneratedColumn<int>(
    'CF_ID_RELATIVE',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameNormalizedMeta =
      const VerificationMeta('fullNameNormalized');
  @override
  late final GeneratedColumn<String> fullNameNormalized =
      GeneratedColumn<String>(
        'full_name_normalized',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _governorateMeta = const VerificationMeta(
    'governorate',
  );
  @override
  late final GeneratedColumn<String> governorate = GeneratedColumn<String>(
    'governorate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nationalId,
    firstName,
    fatherName,
    grandFatherName,
    familyName,
    birthCertificateId,
    birthCodeId,
    birthDate,
    sexCode,
    personalCodeId,
    deadDate,
    motherName,
    cityId,
    cityName,
    street,
    houseNo,
    relationId,
    relativeCodeId,
    relativeId,
    fullName,
    fullNameNormalized,
    governorate,
    district,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('CI_ID_NUM')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['CI_ID_NUM']!, _nationalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('CI_FIRST_ARB')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['CI_FIRST_ARB']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('CI_FATHER_ARB')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(
          data['CI_FATHER_ARB']!,
          _fatherNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatherNameMeta);
    }
    if (data.containsKey('CI_GRAND_FATHER_ARB')) {
      context.handle(
        _grandFatherNameMeta,
        grandFatherName.isAcceptableOrUnknown(
          data['CI_GRAND_FATHER_ARB']!,
          _grandFatherNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grandFatherNameMeta);
    }
    if (data.containsKey('CI_FAMILY_ARB')) {
      context.handle(
        _familyNameMeta,
        familyName.isAcceptableOrUnknown(
          data['CI_FAMILY_ARB']!,
          _familyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('CI_BIRTH_TB_CD')) {
      context.handle(
        _birthCertificateIdMeta,
        birthCertificateId.isAcceptableOrUnknown(
          data['CI_BIRTH_TB_CD']!,
          _birthCertificateIdMeta,
        ),
      );
    }
    if (data.containsKey('CI_BIRTH_CD')) {
      context.handle(
        _birthCodeIdMeta,
        birthCodeId.isAcceptableOrUnknown(
          data['CI_BIRTH_CD']!,
          _birthCodeIdMeta,
        ),
      );
    }
    if (data.containsKey('CI_BIRTH_DT')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['CI_BIRTH_DT']!, _birthDateMeta),
      );
    }
    if (data.containsKey('CI_SEX_CD')) {
      context.handle(
        _sexCodeMeta,
        sexCode.isAcceptableOrUnknown(data['CI_SEX_CD']!, _sexCodeMeta),
      );
    }
    if (data.containsKey('CI_PERSONAL_CD')) {
      context.handle(
        _personalCodeIdMeta,
        personalCodeId.isAcceptableOrUnknown(
          data['CI_PERSONAL_CD']!,
          _personalCodeIdMeta,
        ),
      );
    }
    if (data.containsKey('CI_DEAD_DT')) {
      context.handle(
        _deadDateMeta,
        deadDate.isAcceptableOrUnknown(data['CI_DEAD_DT']!, _deadDateMeta),
      );
    }
    if (data.containsKey('MOTHER_NAME1')) {
      context.handle(
        _motherNameMeta,
        motherName.isAcceptableOrUnknown(
          data['MOTHER_NAME1']!,
          _motherNameMeta,
        ),
      );
    }
    if (data.containsKey('CITY')) {
      context.handle(
        _cityIdMeta,
        cityId.isAcceptableOrUnknown(data['CITY']!, _cityIdMeta),
      );
    }
    if (data.containsKey('city_name')) {
      context.handle(
        _cityNameMeta,
        cityName.isAcceptableOrUnknown(data['city_name']!, _cityNameMeta),
      );
    }
    if (data.containsKey('STREET')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['STREET']!, _streetMeta),
      );
    }
    if (data.containsKey('HOUSE_NO')) {
      context.handle(
        _houseNoMeta,
        houseNo.isAcceptableOrUnknown(data['HOUSE_NO']!, _houseNoMeta),
      );
    }
    if (data.containsKey('CF_ID_NUM')) {
      context.handle(
        _relationIdMeta,
        relationId.isAcceptableOrUnknown(data['CF_ID_NUM']!, _relationIdMeta),
      );
    }
    if (data.containsKey('CF_RELATIVE_CD')) {
      context.handle(
        _relativeCodeIdMeta,
        relativeCodeId.isAcceptableOrUnknown(
          data['CF_RELATIVE_CD']!,
          _relativeCodeIdMeta,
        ),
      );
    }
    if (data.containsKey('CF_ID_RELATIVE')) {
      context.handle(
        _relativeIdMeta,
        relativeId.isAcceptableOrUnknown(
          data['CF_ID_RELATIVE']!,
          _relativeIdMeta,
        ),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('full_name_normalized')) {
      context.handle(
        _fullNameNormalizedMeta,
        fullNameNormalized.isAcceptableOrUnknown(
          data['full_name_normalized']!,
          _fullNameNormalizedMeta,
        ),
      );
    }
    if (data.containsKey('governorate')) {
      context.handle(
        _governorateMeta,
        governorate.isAcceptableOrUnknown(
          data['governorate']!,
          _governorateMeta,
        ),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nationalId},
  ];
  @override
  CivilRegistryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_ID_NUM'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_FIRST_ARB'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_FATHER_ARB'],
      )!,
      grandFatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_GRAND_FATHER_ARB'],
      )!,
      familyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_FAMILY_ARB'],
      )!,
      birthCertificateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CI_BIRTH_TB_CD'],
      ),
      birthCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CI_BIRTH_CD'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}CI_BIRTH_DT'],
      ),
      sexCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CI_SEX_CD'],
      ),
      personalCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CI_PERSONAL_CD'],
      ),
      deadDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CI_DEAD_DT'],
      ),
      motherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}MOTHER_NAME1'],
      ),
      cityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CITY'],
      ),
      cityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_name'],
      ),
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}STREET'],
      ),
      houseNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}HOUSE_NO'],
      ),
      relationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_ID_NUM'],
      ),
      relativeCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_RELATIVE_CD'],
      ),
      relativeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_ID_RELATIVE'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      fullNameNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name_normalized'],
      ),
      governorate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}governorate'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $CivilRegistryTable createAlias(String alias) {
    return $CivilRegistryTable(attachedDatabase, alias);
  }
}

class CivilRegistryData extends DataClass
    implements Insertable<CivilRegistryData> {
  final int id;
  final String nationalId;
  final String firstName;
  final String fatherName;
  final String grandFatherName;
  final String familyName;
  final int? birthCertificateId;
  final int? birthCodeId;
  final DateTime? birthDate;
  final int? sexCode;
  final int? personalCodeId;
  final int? deadDate;
  final String? motherName;
  final int? cityId;
  final String? cityName;
  final String? street;
  final String? houseNo;
  final int? relationId;
  final int? relativeCodeId;
  final int? relativeId;
  final String? fullName;
  final String? fullNameNormalized;
  final String? governorate;
  final String? district;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const CivilRegistryData({
    required this.id,
    required this.nationalId,
    required this.firstName,
    required this.fatherName,
    required this.grandFatherName,
    required this.familyName,
    this.birthCertificateId,
    this.birthCodeId,
    this.birthDate,
    this.sexCode,
    this.personalCodeId,
    this.deadDate,
    this.motherName,
    this.cityId,
    this.cityName,
    this.street,
    this.houseNo,
    this.relationId,
    this.relativeCodeId,
    this.relativeId,
    this.fullName,
    this.fullNameNormalized,
    this.governorate,
    this.district,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['CI_ID_NUM'] = Variable<String>(nationalId);
    map['CI_FIRST_ARB'] = Variable<String>(firstName);
    map['CI_FATHER_ARB'] = Variable<String>(fatherName);
    map['CI_GRAND_FATHER_ARB'] = Variable<String>(grandFatherName);
    map['CI_FAMILY_ARB'] = Variable<String>(familyName);
    if (!nullToAbsent || birthCertificateId != null) {
      map['CI_BIRTH_TB_CD'] = Variable<int>(birthCertificateId);
    }
    if (!nullToAbsent || birthCodeId != null) {
      map['CI_BIRTH_CD'] = Variable<int>(birthCodeId);
    }
    if (!nullToAbsent || birthDate != null) {
      map['CI_BIRTH_DT'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || sexCode != null) {
      map['CI_SEX_CD'] = Variable<int>(sexCode);
    }
    if (!nullToAbsent || personalCodeId != null) {
      map['CI_PERSONAL_CD'] = Variable<int>(personalCodeId);
    }
    if (!nullToAbsent || deadDate != null) {
      map['CI_DEAD_DT'] = Variable<int>(deadDate);
    }
    if (!nullToAbsent || motherName != null) {
      map['MOTHER_NAME1'] = Variable<String>(motherName);
    }
    if (!nullToAbsent || cityId != null) {
      map['CITY'] = Variable<int>(cityId);
    }
    if (!nullToAbsent || cityName != null) {
      map['city_name'] = Variable<String>(cityName);
    }
    if (!nullToAbsent || street != null) {
      map['STREET'] = Variable<String>(street);
    }
    if (!nullToAbsent || houseNo != null) {
      map['HOUSE_NO'] = Variable<String>(houseNo);
    }
    if (!nullToAbsent || relationId != null) {
      map['CF_ID_NUM'] = Variable<int>(relationId);
    }
    if (!nullToAbsent || relativeCodeId != null) {
      map['CF_RELATIVE_CD'] = Variable<int>(relativeCodeId);
    }
    if (!nullToAbsent || relativeId != null) {
      map['CF_ID_RELATIVE'] = Variable<int>(relativeId);
    }
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || fullNameNormalized != null) {
      map['full_name_normalized'] = Variable<String>(fullNameNormalized);
    }
    if (!nullToAbsent || governorate != null) {
      map['governorate'] = Variable<String>(governorate);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  CivilRegistryCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryCompanion(
      id: Value(id),
      nationalId: Value(nationalId),
      firstName: Value(firstName),
      fatherName: Value(fatherName),
      grandFatherName: Value(grandFatherName),
      familyName: Value(familyName),
      birthCertificateId: birthCertificateId == null && nullToAbsent
          ? const Value.absent()
          : Value(birthCertificateId),
      birthCodeId: birthCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(birthCodeId),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sexCode: sexCode == null && nullToAbsent
          ? const Value.absent()
          : Value(sexCode),
      personalCodeId: personalCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(personalCodeId),
      deadDate: deadDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deadDate),
      motherName: motherName == null && nullToAbsent
          ? const Value.absent()
          : Value(motherName),
      cityId: cityId == null && nullToAbsent
          ? const Value.absent()
          : Value(cityId),
      cityName: cityName == null && nullToAbsent
          ? const Value.absent()
          : Value(cityName),
      street: street == null && nullToAbsent
          ? const Value.absent()
          : Value(street),
      houseNo: houseNo == null && nullToAbsent
          ? const Value.absent()
          : Value(houseNo),
      relationId: relationId == null && nullToAbsent
          ? const Value.absent()
          : Value(relationId),
      relativeCodeId: relativeCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeCodeId),
      relativeId: relativeId == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeId),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      fullNameNormalized: fullNameNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(fullNameNormalized),
      governorate: governorate == null && nullToAbsent
          ? const Value.absent()
          : Value(governorate),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory CivilRegistryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryData(
      id: serializer.fromJson<int>(json['id']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      grandFatherName: serializer.fromJson<String>(json['grandFatherName']),
      familyName: serializer.fromJson<String>(json['familyName']),
      birthCertificateId: serializer.fromJson<int?>(json['birthCertificateId']),
      birthCodeId: serializer.fromJson<int?>(json['birthCodeId']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      sexCode: serializer.fromJson<int?>(json['sexCode']),
      personalCodeId: serializer.fromJson<int?>(json['personalCodeId']),
      deadDate: serializer.fromJson<int?>(json['deadDate']),
      motherName: serializer.fromJson<String?>(json['motherName']),
      cityId: serializer.fromJson<int?>(json['cityId']),
      cityName: serializer.fromJson<String?>(json['cityName']),
      street: serializer.fromJson<String?>(json['street']),
      houseNo: serializer.fromJson<String?>(json['houseNo']),
      relationId: serializer.fromJson<int?>(json['relationId']),
      relativeCodeId: serializer.fromJson<int?>(json['relativeCodeId']),
      relativeId: serializer.fromJson<int?>(json['relativeId']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      fullNameNormalized: serializer.fromJson<String?>(
        json['fullNameNormalized'],
      ),
      governorate: serializer.fromJson<String?>(json['governorate']),
      district: serializer.fromJson<String?>(json['district']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nationalId': serializer.toJson<String>(nationalId),
      'firstName': serializer.toJson<String>(firstName),
      'fatherName': serializer.toJson<String>(fatherName),
      'grandFatherName': serializer.toJson<String>(grandFatherName),
      'familyName': serializer.toJson<String>(familyName),
      'birthCertificateId': serializer.toJson<int?>(birthCertificateId),
      'birthCodeId': serializer.toJson<int?>(birthCodeId),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'sexCode': serializer.toJson<int?>(sexCode),
      'personalCodeId': serializer.toJson<int?>(personalCodeId),
      'deadDate': serializer.toJson<int?>(deadDate),
      'motherName': serializer.toJson<String?>(motherName),
      'cityId': serializer.toJson<int?>(cityId),
      'cityName': serializer.toJson<String?>(cityName),
      'street': serializer.toJson<String?>(street),
      'houseNo': serializer.toJson<String?>(houseNo),
      'relationId': serializer.toJson<int?>(relationId),
      'relativeCodeId': serializer.toJson<int?>(relativeCodeId),
      'relativeId': serializer.toJson<int?>(relativeId),
      'fullName': serializer.toJson<String?>(fullName),
      'fullNameNormalized': serializer.toJson<String?>(fullNameNormalized),
      'governorate': serializer.toJson<String?>(governorate),
      'district': serializer.toJson<String?>(district),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  CivilRegistryData copyWith({
    int? id,
    String? nationalId,
    String? firstName,
    String? fatherName,
    String? grandFatherName,
    String? familyName,
    Value<int?> birthCertificateId = const Value.absent(),
    Value<int?> birthCodeId = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<int?> sexCode = const Value.absent(),
    Value<int?> personalCodeId = const Value.absent(),
    Value<int?> deadDate = const Value.absent(),
    Value<String?> motherName = const Value.absent(),
    Value<int?> cityId = const Value.absent(),
    Value<String?> cityName = const Value.absent(),
    Value<String?> street = const Value.absent(),
    Value<String?> houseNo = const Value.absent(),
    Value<int?> relationId = const Value.absent(),
    Value<int?> relativeCodeId = const Value.absent(),
    Value<int?> relativeId = const Value.absent(),
    Value<String?> fullName = const Value.absent(),
    Value<String?> fullNameNormalized = const Value.absent(),
    Value<String?> governorate = const Value.absent(),
    Value<String?> district = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => CivilRegistryData(
    id: id ?? this.id,
    nationalId: nationalId ?? this.nationalId,
    firstName: firstName ?? this.firstName,
    fatherName: fatherName ?? this.fatherName,
    grandFatherName: grandFatherName ?? this.grandFatherName,
    familyName: familyName ?? this.familyName,
    birthCertificateId: birthCertificateId.present
        ? birthCertificateId.value
        : this.birthCertificateId,
    birthCodeId: birthCodeId.present ? birthCodeId.value : this.birthCodeId,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sexCode: sexCode.present ? sexCode.value : this.sexCode,
    personalCodeId: personalCodeId.present
        ? personalCodeId.value
        : this.personalCodeId,
    deadDate: deadDate.present ? deadDate.value : this.deadDate,
    motherName: motherName.present ? motherName.value : this.motherName,
    cityId: cityId.present ? cityId.value : this.cityId,
    cityName: cityName.present ? cityName.value : this.cityName,
    street: street.present ? street.value : this.street,
    houseNo: houseNo.present ? houseNo.value : this.houseNo,
    relationId: relationId.present ? relationId.value : this.relationId,
    relativeCodeId: relativeCodeId.present
        ? relativeCodeId.value
        : this.relativeCodeId,
    relativeId: relativeId.present ? relativeId.value : this.relativeId,
    fullName: fullName.present ? fullName.value : this.fullName,
    fullNameNormalized: fullNameNormalized.present
        ? fullNameNormalized.value
        : this.fullNameNormalized,
    governorate: governorate.present ? governorate.value : this.governorate,
    district: district.present ? district.value : this.district,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  CivilRegistryData copyWithCompanion(CivilRegistryCompanion data) {
    return CivilRegistryData(
      id: data.id.present ? data.id.value : this.id,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      grandFatherName: data.grandFatherName.present
          ? data.grandFatherName.value
          : this.grandFatherName,
      familyName: data.familyName.present
          ? data.familyName.value
          : this.familyName,
      birthCertificateId: data.birthCertificateId.present
          ? data.birthCertificateId.value
          : this.birthCertificateId,
      birthCodeId: data.birthCodeId.present
          ? data.birthCodeId.value
          : this.birthCodeId,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sexCode: data.sexCode.present ? data.sexCode.value : this.sexCode,
      personalCodeId: data.personalCodeId.present
          ? data.personalCodeId.value
          : this.personalCodeId,
      deadDate: data.deadDate.present ? data.deadDate.value : this.deadDate,
      motherName: data.motherName.present
          ? data.motherName.value
          : this.motherName,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      cityName: data.cityName.present ? data.cityName.value : this.cityName,
      street: data.street.present ? data.street.value : this.street,
      houseNo: data.houseNo.present ? data.houseNo.value : this.houseNo,
      relationId: data.relationId.present
          ? data.relationId.value
          : this.relationId,
      relativeCodeId: data.relativeCodeId.present
          ? data.relativeCodeId.value
          : this.relativeCodeId,
      relativeId: data.relativeId.present
          ? data.relativeId.value
          : this.relativeId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      fullNameNormalized: data.fullNameNormalized.present
          ? data.fullNameNormalized.value
          : this.fullNameNormalized,
      governorate: data.governorate.present
          ? data.governorate.value
          : this.governorate,
      district: data.district.present ? data.district.value : this.district,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryData(')
          ..write('id: $id, ')
          ..write('nationalId: $nationalId, ')
          ..write('firstName: $firstName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('birthCertificateId: $birthCertificateId, ')
          ..write('birthCodeId: $birthCodeId, ')
          ..write('birthDate: $birthDate, ')
          ..write('sexCode: $sexCode, ')
          ..write('personalCodeId: $personalCodeId, ')
          ..write('deadDate: $deadDate, ')
          ..write('motherName: $motherName, ')
          ..write('cityId: $cityId, ')
          ..write('cityName: $cityName, ')
          ..write('street: $street, ')
          ..write('houseNo: $houseNo, ')
          ..write('relationId: $relationId, ')
          ..write('relativeCodeId: $relativeCodeId, ')
          ..write('relativeId: $relativeId, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNormalized: $fullNameNormalized, ')
          ..write('governorate: $governorate, ')
          ..write('district: $district, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    nationalId,
    firstName,
    fatherName,
    grandFatherName,
    familyName,
    birthCertificateId,
    birthCodeId,
    birthDate,
    sexCode,
    personalCodeId,
    deadDate,
    motherName,
    cityId,
    cityName,
    street,
    houseNo,
    relationId,
    relativeCodeId,
    relativeId,
    fullName,
    fullNameNormalized,
    governorate,
    district,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryData &&
          other.id == this.id &&
          other.nationalId == this.nationalId &&
          other.firstName == this.firstName &&
          other.fatherName == this.fatherName &&
          other.grandFatherName == this.grandFatherName &&
          other.familyName == this.familyName &&
          other.birthCertificateId == this.birthCertificateId &&
          other.birthCodeId == this.birthCodeId &&
          other.birthDate == this.birthDate &&
          other.sexCode == this.sexCode &&
          other.personalCodeId == this.personalCodeId &&
          other.deadDate == this.deadDate &&
          other.motherName == this.motherName &&
          other.cityId == this.cityId &&
          other.cityName == this.cityName &&
          other.street == this.street &&
          other.houseNo == this.houseNo &&
          other.relationId == this.relationId &&
          other.relativeCodeId == this.relativeCodeId &&
          other.relativeId == this.relativeId &&
          other.fullName == this.fullName &&
          other.fullNameNormalized == this.fullNameNormalized &&
          other.governorate == this.governorate &&
          other.district == this.district &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class CivilRegistryCompanion extends UpdateCompanion<CivilRegistryData> {
  final Value<int> id;
  final Value<String> nationalId;
  final Value<String> firstName;
  final Value<String> fatherName;
  final Value<String> grandFatherName;
  final Value<String> familyName;
  final Value<int?> birthCertificateId;
  final Value<int?> birthCodeId;
  final Value<DateTime?> birthDate;
  final Value<int?> sexCode;
  final Value<int?> personalCodeId;
  final Value<int?> deadDate;
  final Value<String?> motherName;
  final Value<int?> cityId;
  final Value<String?> cityName;
  final Value<String?> street;
  final Value<String?> houseNo;
  final Value<int?> relationId;
  final Value<int?> relativeCodeId;
  final Value<int?> relativeId;
  final Value<String?> fullName;
  final Value<String?> fullNameNormalized;
  final Value<String?> governorate;
  final Value<String?> district;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  const CivilRegistryCompanion({
    this.id = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.birthCertificateId = const Value.absent(),
    this.birthCodeId = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sexCode = const Value.absent(),
    this.personalCodeId = const Value.absent(),
    this.deadDate = const Value.absent(),
    this.motherName = const Value.absent(),
    this.cityId = const Value.absent(),
    this.cityName = const Value.absent(),
    this.street = const Value.absent(),
    this.houseNo = const Value.absent(),
    this.relationId = const Value.absent(),
    this.relativeCodeId = const Value.absent(),
    this.relativeId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fullNameNormalized = const Value.absent(),
    this.governorate = const Value.absent(),
    this.district = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  CivilRegistryCompanion.insert({
    this.id = const Value.absent(),
    required String nationalId,
    required String firstName,
    required String fatherName,
    required String grandFatherName,
    required String familyName,
    this.birthCertificateId = const Value.absent(),
    this.birthCodeId = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sexCode = const Value.absent(),
    this.personalCodeId = const Value.absent(),
    this.deadDate = const Value.absent(),
    this.motherName = const Value.absent(),
    this.cityId = const Value.absent(),
    this.cityName = const Value.absent(),
    this.street = const Value.absent(),
    this.houseNo = const Value.absent(),
    this.relationId = const Value.absent(),
    this.relativeCodeId = const Value.absent(),
    this.relativeId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fullNameNormalized = const Value.absent(),
    this.governorate = const Value.absent(),
    this.district = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSyncedAt = const Value.absent(),
  }) : nationalId = Value(nationalId),
       firstName = Value(firstName),
       fatherName = Value(fatherName),
       grandFatherName = Value(grandFatherName),
       familyName = Value(familyName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryData> custom({
    Expression<int>? id,
    Expression<String>? nationalId,
    Expression<String>? firstName,
    Expression<String>? fatherName,
    Expression<String>? grandFatherName,
    Expression<String>? familyName,
    Expression<int>? birthCertificateId,
    Expression<int>? birthCodeId,
    Expression<DateTime>? birthDate,
    Expression<int>? sexCode,
    Expression<int>? personalCodeId,
    Expression<int>? deadDate,
    Expression<String>? motherName,
    Expression<int>? cityId,
    Expression<String>? cityName,
    Expression<String>? street,
    Expression<String>? houseNo,
    Expression<int>? relationId,
    Expression<int>? relativeCodeId,
    Expression<int>? relativeId,
    Expression<String>? fullName,
    Expression<String>? fullNameNormalized,
    Expression<String>? governorate,
    Expression<String>? district,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nationalId != null) 'CI_ID_NUM': nationalId,
      if (firstName != null) 'CI_FIRST_ARB': firstName,
      if (fatherName != null) 'CI_FATHER_ARB': fatherName,
      if (grandFatherName != null) 'CI_GRAND_FATHER_ARB': grandFatherName,
      if (familyName != null) 'CI_FAMILY_ARB': familyName,
      if (birthCertificateId != null) 'CI_BIRTH_TB_CD': birthCertificateId,
      if (birthCodeId != null) 'CI_BIRTH_CD': birthCodeId,
      if (birthDate != null) 'CI_BIRTH_DT': birthDate,
      if (sexCode != null) 'CI_SEX_CD': sexCode,
      if (personalCodeId != null) 'CI_PERSONAL_CD': personalCodeId,
      if (deadDate != null) 'CI_DEAD_DT': deadDate,
      if (motherName != null) 'MOTHER_NAME1': motherName,
      if (cityId != null) 'CITY': cityId,
      if (cityName != null) 'city_name': cityName,
      if (street != null) 'STREET': street,
      if (houseNo != null) 'HOUSE_NO': houseNo,
      if (relationId != null) 'CF_ID_NUM': relationId,
      if (relativeCodeId != null) 'CF_RELATIVE_CD': relativeCodeId,
      if (relativeId != null) 'CF_ID_RELATIVE': relativeId,
      if (fullName != null) 'full_name': fullName,
      if (fullNameNormalized != null)
        'full_name_normalized': fullNameNormalized,
      if (governorate != null) 'governorate': governorate,
      if (district != null) 'district': district,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  CivilRegistryCompanion copyWith({
    Value<int>? id,
    Value<String>? nationalId,
    Value<String>? firstName,
    Value<String>? fatherName,
    Value<String>? grandFatherName,
    Value<String>? familyName,
    Value<int?>? birthCertificateId,
    Value<int?>? birthCodeId,
    Value<DateTime?>? birthDate,
    Value<int?>? sexCode,
    Value<int?>? personalCodeId,
    Value<int?>? deadDate,
    Value<String?>? motherName,
    Value<int?>? cityId,
    Value<String?>? cityName,
    Value<String?>? street,
    Value<String?>? houseNo,
    Value<int?>? relationId,
    Value<int?>? relativeCodeId,
    Value<int?>? relativeId,
    Value<String?>? fullName,
    Value<String?>? fullNameNormalized,
    Value<String?>? governorate,
    Value<String?>? district,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return CivilRegistryCompanion(
      id: id ?? this.id,
      nationalId: nationalId ?? this.nationalId,
      firstName: firstName ?? this.firstName,
      fatherName: fatherName ?? this.fatherName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      familyName: familyName ?? this.familyName,
      birthCertificateId: birthCertificateId ?? this.birthCertificateId,
      birthCodeId: birthCodeId ?? this.birthCodeId,
      birthDate: birthDate ?? this.birthDate,
      sexCode: sexCode ?? this.sexCode,
      personalCodeId: personalCodeId ?? this.personalCodeId,
      deadDate: deadDate ?? this.deadDate,
      motherName: motherName ?? this.motherName,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      street: street ?? this.street,
      houseNo: houseNo ?? this.houseNo,
      relationId: relationId ?? this.relationId,
      relativeCodeId: relativeCodeId ?? this.relativeCodeId,
      relativeId: relativeId ?? this.relativeId,
      fullName: fullName ?? this.fullName,
      fullNameNormalized: fullNameNormalized ?? this.fullNameNormalized,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nationalId.present) {
      map['CI_ID_NUM'] = Variable<String>(nationalId.value);
    }
    if (firstName.present) {
      map['CI_FIRST_ARB'] = Variable<String>(firstName.value);
    }
    if (fatherName.present) {
      map['CI_FATHER_ARB'] = Variable<String>(fatherName.value);
    }
    if (grandFatherName.present) {
      map['CI_GRAND_FATHER_ARB'] = Variable<String>(grandFatherName.value);
    }
    if (familyName.present) {
      map['CI_FAMILY_ARB'] = Variable<String>(familyName.value);
    }
    if (birthCertificateId.present) {
      map['CI_BIRTH_TB_CD'] = Variable<int>(birthCertificateId.value);
    }
    if (birthCodeId.present) {
      map['CI_BIRTH_CD'] = Variable<int>(birthCodeId.value);
    }
    if (birthDate.present) {
      map['CI_BIRTH_DT'] = Variable<DateTime>(birthDate.value);
    }
    if (sexCode.present) {
      map['CI_SEX_CD'] = Variable<int>(sexCode.value);
    }
    if (personalCodeId.present) {
      map['CI_PERSONAL_CD'] = Variable<int>(personalCodeId.value);
    }
    if (deadDate.present) {
      map['CI_DEAD_DT'] = Variable<int>(deadDate.value);
    }
    if (motherName.present) {
      map['MOTHER_NAME1'] = Variable<String>(motherName.value);
    }
    if (cityId.present) {
      map['CITY'] = Variable<int>(cityId.value);
    }
    if (cityName.present) {
      map['city_name'] = Variable<String>(cityName.value);
    }
    if (street.present) {
      map['STREET'] = Variable<String>(street.value);
    }
    if (houseNo.present) {
      map['HOUSE_NO'] = Variable<String>(houseNo.value);
    }
    if (relationId.present) {
      map['CF_ID_NUM'] = Variable<int>(relationId.value);
    }
    if (relativeCodeId.present) {
      map['CF_RELATIVE_CD'] = Variable<int>(relativeCodeId.value);
    }
    if (relativeId.present) {
      map['CF_ID_RELATIVE'] = Variable<int>(relativeId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (fullNameNormalized.present) {
      map['full_name_normalized'] = Variable<String>(fullNameNormalized.value);
    }
    if (governorate.present) {
      map['governorate'] = Variable<String>(governorate.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryCompanion(')
          ..write('id: $id, ')
          ..write('nationalId: $nationalId, ')
          ..write('firstName: $firstName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('familyName: $familyName, ')
          ..write('birthCertificateId: $birthCertificateId, ')
          ..write('birthCodeId: $birthCodeId, ')
          ..write('birthDate: $birthDate, ')
          ..write('sexCode: $sexCode, ')
          ..write('personalCodeId: $personalCodeId, ')
          ..write('deadDate: $deadDate, ')
          ..write('motherName: $motherName, ')
          ..write('cityId: $cityId, ')
          ..write('cityName: $cityName, ')
          ..write('street: $street, ')
          ..write('houseNo: $houseNo, ')
          ..write('relationId: $relationId, ')
          ..write('relativeCodeId: $relativeCodeId, ')
          ..write('relativeId: $relativeId, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNormalized: $fullNameNormalized, ')
          ..write('governorate: $governorate, ')
          ..write('district: $district, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $CivilRegistryCityTable extends CivilRegistryCity
    with TableInfo<$CivilRegistryCityTable, CivilRegistryCityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryCityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, city, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry_city';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryCityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CivilRegistryCityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryCityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CivilRegistryCityTable createAlias(String alias) {
    return $CivilRegistryCityTable(attachedDatabase, alias);
  }
}

class CivilRegistryCityData extends DataClass
    implements Insertable<CivilRegistryCityData> {
  final int id;
  final String city;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CivilRegistryCityData({
    required this.id,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city'] = Variable<String>(city);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CivilRegistryCityCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryCityCompanion(
      id: Value(id),
      city: Value(city),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CivilRegistryCityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryCityData(
      id: serializer.fromJson<int>(json['id']),
      city: serializer.fromJson<String>(json['city']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'city': serializer.toJson<String>(city),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CivilRegistryCityData copyWith({
    int? id,
    String? city,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CivilRegistryCityData(
    id: id ?? this.id,
    city: city ?? this.city,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CivilRegistryCityData copyWithCompanion(CivilRegistryCityCompanion data) {
    return CivilRegistryCityData(
      id: data.id.present ? data.id.value : this.id,
      city: data.city.present ? data.city.value : this.city,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryCityData(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, city, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryCityData &&
          other.id == this.id &&
          other.city == this.city &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CivilRegistryCityCompanion
    extends UpdateCompanion<CivilRegistryCityData> {
  final Value<int> id;
  final Value<String> city;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CivilRegistryCityCompanion({
    this.id = const Value.absent(),
    this.city = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CivilRegistryCityCompanion.insert({
    this.id = const Value.absent(),
    required String city,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : city = Value(city),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryCityData> custom({
    Expression<int>? id,
    Expression<String>? city,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (city != null) 'city': city,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CivilRegistryCityCompanion copyWith({
    Value<int>? id,
    Value<String>? city,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CivilRegistryCityCompanion(
      id: id ?? this.id,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryCityCompanion(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CivilRegistryRelationsTable extends CivilRegistryRelations
    with TableInfo<$CivilRegistryRelationsTable, CivilRegistryRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'CF_ID_NUM',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeIdMeta = const VerificationMeta(
    'relativeId',
  );
  @override
  late final GeneratedColumn<int> relativeId = GeneratedColumn<int>(
    'CF_ID_RELATIVE',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeCodeIdMeta = const VerificationMeta(
    'relativeCodeId',
  );
  @override
  late final GeneratedColumn<int> relativeCodeId = GeneratedColumn<int>(
    'CF_RELATIVE_CD',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    relativeId,
    relativeCodeId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry_relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryRelation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('CF_ID_NUM')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['CF_ID_NUM']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('CF_ID_RELATIVE')) {
      context.handle(
        _relativeIdMeta,
        relativeId.isAcceptableOrUnknown(
          data['CF_ID_RELATIVE']!,
          _relativeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeIdMeta);
    }
    if (data.containsKey('CF_RELATIVE_CD')) {
      context.handle(
        _relativeCodeIdMeta,
        relativeCodeId.isAcceptableOrUnknown(
          data['CF_RELATIVE_CD']!,
          _relativeCodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativeCodeIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CivilRegistryRelation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryRelation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_ID_NUM'],
      )!,
      relativeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_ID_RELATIVE'],
      )!,
      relativeCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}CF_RELATIVE_CD'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CivilRegistryRelationsTable createAlias(String alias) {
    return $CivilRegistryRelationsTable(attachedDatabase, alias);
  }
}

class CivilRegistryRelation extends DataClass
    implements Insertable<CivilRegistryRelation> {
  final int id;
  final int personId;
  final int relativeId;
  final int relativeCodeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CivilRegistryRelation({
    required this.id,
    required this.personId,
    required this.relativeId,
    required this.relativeCodeId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['CF_ID_NUM'] = Variable<int>(personId);
    map['CF_ID_RELATIVE'] = Variable<int>(relativeId);
    map['CF_RELATIVE_CD'] = Variable<int>(relativeCodeId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CivilRegistryRelationsCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryRelationsCompanion(
      id: Value(id),
      personId: Value(personId),
      relativeId: Value(relativeId),
      relativeCodeId: Value(relativeCodeId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CivilRegistryRelation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryRelation(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      relativeId: serializer.fromJson<int>(json['relativeId']),
      relativeCodeId: serializer.fromJson<int>(json['relativeCodeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'relativeId': serializer.toJson<int>(relativeId),
      'relativeCodeId': serializer.toJson<int>(relativeCodeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CivilRegistryRelation copyWith({
    int? id,
    int? personId,
    int? relativeId,
    int? relativeCodeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CivilRegistryRelation(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    relativeId: relativeId ?? this.relativeId,
    relativeCodeId: relativeCodeId ?? this.relativeCodeId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CivilRegistryRelation copyWithCompanion(
    CivilRegistryRelationsCompanion data,
  ) {
    return CivilRegistryRelation(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      relativeId: data.relativeId.present
          ? data.relativeId.value
          : this.relativeId,
      relativeCodeId: data.relativeCodeId.present
          ? data.relativeCodeId.value
          : this.relativeCodeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryRelation(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('relativeId: $relativeId, ')
          ..write('relativeCodeId: $relativeCodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    relativeId,
    relativeCodeId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryRelation &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.relativeId == this.relativeId &&
          other.relativeCodeId == this.relativeCodeId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CivilRegistryRelationsCompanion
    extends UpdateCompanion<CivilRegistryRelation> {
  final Value<int> id;
  final Value<int> personId;
  final Value<int> relativeId;
  final Value<int> relativeCodeId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CivilRegistryRelationsCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.relativeId = const Value.absent(),
    this.relativeCodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CivilRegistryRelationsCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    required int relativeId,
    required int relativeCodeId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : personId = Value(personId),
       relativeId = Value(relativeId),
       relativeCodeId = Value(relativeCodeId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryRelation> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<int>? relativeId,
    Expression<int>? relativeCodeId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'CF_ID_NUM': personId,
      if (relativeId != null) 'CF_ID_RELATIVE': relativeId,
      if (relativeCodeId != null) 'CF_RELATIVE_CD': relativeCodeId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CivilRegistryRelationsCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<int>? relativeId,
    Value<int>? relativeCodeId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CivilRegistryRelationsCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      relativeId: relativeId ?? this.relativeId,
      relativeCodeId: relativeCodeId ?? this.relativeCodeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['CF_ID_NUM'] = Variable<int>(personId.value);
    }
    if (relativeId.present) {
      map['CF_ID_RELATIVE'] = Variable<int>(relativeId.value);
    }
    if (relativeCodeId.present) {
      map['CF_RELATIVE_CD'] = Variable<int>(relativeCodeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryRelationsCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('relativeId: $relativeId, ')
          ..write('relativeCodeId: $relativeCodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CivilRegistryRelationCategoriesTable
    extends CivilRegistryRelationCategories
    with
        TableInfo<
          $CivilRegistryRelationCategoriesTable,
          CivilRegistryRelationCategory
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryRelationCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributeMeta = const VerificationMeta(
    'attribute',
  );
  @override
  late final GeneratedColumn<String> attribute = GeneratedColumn<String>(
    'attribute',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, attribute, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry_relation_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryRelationCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attribute')) {
      context.handle(
        _attributeMeta,
        attribute.isAcceptableOrUnknown(data['attribute']!, _attributeMeta),
      );
    } else if (isInserting) {
      context.missing(_attributeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CivilRegistryRelationCategory map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryRelationCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attribute: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribute'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CivilRegistryRelationCategoriesTable createAlias(String alias) {
    return $CivilRegistryRelationCategoriesTable(attachedDatabase, alias);
  }
}

class CivilRegistryRelationCategory extends DataClass
    implements Insertable<CivilRegistryRelationCategory> {
  final int id;
  final String attribute;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CivilRegistryRelationCategory({
    required this.id,
    required this.attribute,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attribute'] = Variable<String>(attribute);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CivilRegistryRelationCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryRelationCategoriesCompanion(
      id: Value(id),
      attribute: Value(attribute),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CivilRegistryRelationCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryRelationCategory(
      id: serializer.fromJson<int>(json['id']),
      attribute: serializer.fromJson<String>(json['attribute']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attribute': serializer.toJson<String>(attribute),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CivilRegistryRelationCategory copyWith({
    int? id,
    String? attribute,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CivilRegistryRelationCategory(
    id: id ?? this.id,
    attribute: attribute ?? this.attribute,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CivilRegistryRelationCategory copyWithCompanion(
    CivilRegistryRelationCategoriesCompanion data,
  ) {
    return CivilRegistryRelationCategory(
      id: data.id.present ? data.id.value : this.id,
      attribute: data.attribute.present ? data.attribute.value : this.attribute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryRelationCategory(')
          ..write('id: $id, ')
          ..write('attribute: $attribute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attribute, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryRelationCategory &&
          other.id == this.id &&
          other.attribute == this.attribute &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CivilRegistryRelationCategoriesCompanion
    extends UpdateCompanion<CivilRegistryRelationCategory> {
  final Value<int> id;
  final Value<String> attribute;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CivilRegistryRelationCategoriesCompanion({
    this.id = const Value.absent(),
    this.attribute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CivilRegistryRelationCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String attribute,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : attribute = Value(attribute),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryRelationCategory> custom({
    Expression<int>? id,
    Expression<String>? attribute,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attribute != null) 'attribute': attribute,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CivilRegistryRelationCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? attribute,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CivilRegistryRelationCategoriesCompanion(
      id: id ?? this.id,
      attribute: attribute ?? this.attribute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attribute.present) {
      map['attribute'] = Variable<String>(attribute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryRelationCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('attribute: $attribute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CivilRegistryBirthCodeTable extends CivilRegistryBirthCode
    with TableInfo<$CivilRegistryBirthCodeTable, CivilRegistryBirthCodeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryBirthCodeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthCodeMeta = const VerificationMeta(
    'birthCode',
  );
  @override
  late final GeneratedColumn<String> birthCode = GeneratedColumn<String>(
    'CI_BIRTH_TB_CD',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, birthCode, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry_birth_code';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryBirthCodeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('CI_BIRTH_TB_CD')) {
      context.handle(
        _birthCodeMeta,
        birthCode.isAcceptableOrUnknown(
          data['CI_BIRTH_TB_CD']!,
          _birthCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birthCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CivilRegistryBirthCodeData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryBirthCodeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      birthCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_BIRTH_TB_CD'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CivilRegistryBirthCodeTable createAlias(String alias) {
    return $CivilRegistryBirthCodeTable(attachedDatabase, alias);
  }
}

class CivilRegistryBirthCodeData extends DataClass
    implements Insertable<CivilRegistryBirthCodeData> {
  final int id;
  final String birthCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CivilRegistryBirthCodeData({
    required this.id,
    required this.birthCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['CI_BIRTH_TB_CD'] = Variable<String>(birthCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CivilRegistryBirthCodeCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryBirthCodeCompanion(
      id: Value(id),
      birthCode: Value(birthCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CivilRegistryBirthCodeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryBirthCodeData(
      id: serializer.fromJson<int>(json['id']),
      birthCode: serializer.fromJson<String>(json['birthCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'birthCode': serializer.toJson<String>(birthCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CivilRegistryBirthCodeData copyWith({
    int? id,
    String? birthCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CivilRegistryBirthCodeData(
    id: id ?? this.id,
    birthCode: birthCode ?? this.birthCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CivilRegistryBirthCodeData copyWithCompanion(
    CivilRegistryBirthCodeCompanion data,
  ) {
    return CivilRegistryBirthCodeData(
      id: data.id.present ? data.id.value : this.id,
      birthCode: data.birthCode.present ? data.birthCode.value : this.birthCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryBirthCodeData(')
          ..write('id: $id, ')
          ..write('birthCode: $birthCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, birthCode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryBirthCodeData &&
          other.id == this.id &&
          other.birthCode == this.birthCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CivilRegistryBirthCodeCompanion
    extends UpdateCompanion<CivilRegistryBirthCodeData> {
  final Value<int> id;
  final Value<String> birthCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CivilRegistryBirthCodeCompanion({
    this.id = const Value.absent(),
    this.birthCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CivilRegistryBirthCodeCompanion.insert({
    this.id = const Value.absent(),
    required String birthCode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : birthCode = Value(birthCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryBirthCodeData> custom({
    Expression<int>? id,
    Expression<String>? birthCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (birthCode != null) 'CI_BIRTH_TB_CD': birthCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CivilRegistryBirthCodeCompanion copyWith({
    Value<int>? id,
    Value<String>? birthCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CivilRegistryBirthCodeCompanion(
      id: id ?? this.id,
      birthCode: birthCode ?? this.birthCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (birthCode.present) {
      map['CI_BIRTH_TB_CD'] = Variable<String>(birthCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryBirthCodeCompanion(')
          ..write('id: $id, ')
          ..write('birthCode: $birthCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CivilRegistryPersonalCodeTable extends CivilRegistryPersonalCode
    with
        TableInfo<
          $CivilRegistryPersonalCodeTable,
          CivilRegistryPersonalCodeData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CivilRegistryPersonalCodeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalCodeMeta = const VerificationMeta(
    'personalCode',
  );
  @override
  late final GeneratedColumn<String> personalCode = GeneratedColumn<String>(
    'CI_PERSONAL_CD',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personalCode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'civil_registry_personal_code';
  @override
  VerificationContext validateIntegrity(
    Insertable<CivilRegistryPersonalCodeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('CI_PERSONAL_CD')) {
      context.handle(
        _personalCodeMeta,
        personalCode.isAcceptableOrUnknown(
          data['CI_PERSONAL_CD']!,
          _personalCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_personalCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CivilRegistryPersonalCodeData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CivilRegistryPersonalCodeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}CI_PERSONAL_CD'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CivilRegistryPersonalCodeTable createAlias(String alias) {
    return $CivilRegistryPersonalCodeTable(attachedDatabase, alias);
  }
}

class CivilRegistryPersonalCodeData extends DataClass
    implements Insertable<CivilRegistryPersonalCodeData> {
  final int id;
  final String personalCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CivilRegistryPersonalCodeData({
    required this.id,
    required this.personalCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['CI_PERSONAL_CD'] = Variable<String>(personalCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CivilRegistryPersonalCodeCompanion toCompanion(bool nullToAbsent) {
    return CivilRegistryPersonalCodeCompanion(
      id: Value(id),
      personalCode: Value(personalCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CivilRegistryPersonalCodeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CivilRegistryPersonalCodeData(
      id: serializer.fromJson<int>(json['id']),
      personalCode: serializer.fromJson<String>(json['personalCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personalCode': serializer.toJson<String>(personalCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CivilRegistryPersonalCodeData copyWith({
    int? id,
    String? personalCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CivilRegistryPersonalCodeData(
    id: id ?? this.id,
    personalCode: personalCode ?? this.personalCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CivilRegistryPersonalCodeData copyWithCompanion(
    CivilRegistryPersonalCodeCompanion data,
  ) {
    return CivilRegistryPersonalCodeData(
      id: data.id.present ? data.id.value : this.id,
      personalCode: data.personalCode.present
          ? data.personalCode.value
          : this.personalCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryPersonalCodeData(')
          ..write('id: $id, ')
          ..write('personalCode: $personalCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personalCode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CivilRegistryPersonalCodeData &&
          other.id == this.id &&
          other.personalCode == this.personalCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CivilRegistryPersonalCodeCompanion
    extends UpdateCompanion<CivilRegistryPersonalCodeData> {
  final Value<int> id;
  final Value<String> personalCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CivilRegistryPersonalCodeCompanion({
    this.id = const Value.absent(),
    this.personalCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CivilRegistryPersonalCodeCompanion.insert({
    this.id = const Value.absent(),
    required String personalCode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : personalCode = Value(personalCode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CivilRegistryPersonalCodeData> custom({
    Expression<int>? id,
    Expression<String>? personalCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personalCode != null) 'CI_PERSONAL_CD': personalCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CivilRegistryPersonalCodeCompanion copyWith({
    Value<int>? id,
    Value<String>? personalCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CivilRegistryPersonalCodeCompanion(
      id: id ?? this.id,
      personalCode: personalCode ?? this.personalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personalCode.present) {
      map['CI_PERSONAL_CD'] = Variable<String>(personalCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CivilRegistryPersonalCodeCompanion(')
          ..write('id: $id, ')
          ..write('personalCode: $personalCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beneficiaryIdMeta = const VerificationMeta(
    'beneficiaryId',
  );
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
    'beneficiary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changesMeta = const VerificationMeta(
    'changes',
  );
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
    'changes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    beneficiaryId,
    userId,
    activityType,
    description,
    changes,
    createdAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
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
          data['beneficiary_id']!,
          _beneficiaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('changes')) {
      context.handle(
        _changesMeta,
        changes.isAcceptableOrUnknown(data['changes']!, _changesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beneficiaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiary_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      changes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
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
  const Activity({
    required this.id,
    required this.beneficiaryId,
    required this.userId,
    required this.activityType,
    required this.description,
    this.changes,
    required this.createdAt,
    required this.syncState,
  });
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

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Activity copyWith({
    String? id,
    String? beneficiaryId,
    String? userId,
    String? activityType,
    String? description,
    Value<String?> changes = const Value.absent(),
    DateTime? createdAt,
    String? syncState,
  }) => Activity(
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
      description: data.description.present
          ? data.description.value
          : this.description,
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
  int get hashCode => Object.hash(
    id,
    beneficiaryId,
    userId,
    activityType,
    description,
    changes,
    createdAt,
    syncState,
  );
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
  }) : id = Value(id),
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

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? beneficiaryId,
    Value<String>? userId,
    Value<String>? activityType,
    Value<String>? description,
    Value<String?>? changes,
    Value<DateTime>? createdAt,
    Value<String>? syncState,
    Value<int>? rowid,
  }) {
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

class $DataRequestsTable extends DataRequests
    with TableInfo<$DataRequestsTable, DataRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beneficiaryIdMeta = const VerificationMeta(
    'beneficiaryId',
  );
  @override
  late final GeneratedColumn<String> beneficiaryId = GeneratedColumn<String>(
    'beneficiary_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestTypeMeta = const VerificationMeta(
    'requestType',
  );
  @override
  late final GeneratedColumn<String> requestType = GeneratedColumn<String>(
    'request_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _requestDateMeta = const VerificationMeta(
    'requestDate',
  );
  @override
  late final GeneratedColumn<DateTime> requestDate = GeneratedColumn<DateTime>(
    'request_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseDateMeta = const VerificationMeta(
    'responseDate',
  );
  @override
  late final GeneratedColumn<DateTime> responseDate = GeneratedColumn<DateTime>(
    'response_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _respondedByMeta = const VerificationMeta(
    'respondedBy',
  );
  @override
  late final GeneratedColumn<String> respondedBy = GeneratedColumn<String>(
    'responded_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    beneficiaryId,
    requestType,
    status,
    details,
    notes,
    requestDate,
    responseDate,
    respondedBy,
    createdAt,
    updatedAt,
    syncState,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataRequest> instance, {
    bool isInserting = false,
  }) {
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
          data['beneficiary_id']!,
          _beneficiaryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beneficiaryIdMeta);
    }
    if (data.containsKey('request_type')) {
      context.handle(
        _requestTypeMeta,
        requestType.isAcceptableOrUnknown(
          data['request_type']!,
          _requestTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('request_date')) {
      context.handle(
        _requestDateMeta,
        requestDate.isAcceptableOrUnknown(
          data['request_date']!,
          _requestDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestDateMeta);
    }
    if (data.containsKey('response_date')) {
      context.handle(
        _responseDateMeta,
        responseDate.isAcceptableOrUnknown(
          data['response_date']!,
          _responseDateMeta,
        ),
      );
    }
    if (data.containsKey('responded_by')) {
      context.handle(
        _respondedByMeta,
        respondedBy.isAcceptableOrUnknown(
          data['responded_by']!,
          _respondedByMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beneficiaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beneficiary_id'],
      )!,
      requestType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      requestDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}request_date'],
      )!,
      responseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}response_date'],
      ),
      respondedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responded_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $DataRequestsTable createAlias(String alias) {
    return $DataRequestsTable(attachedDatabase, alias);
  }
}

class DataRequest extends DataClass implements Insertable<DataRequest> {
  final String id;
  final String beneficiaryId;
  final String requestType;
  final String status;
  final String? details;
  final String notes;
  final DateTime requestDate;
  final DateTime? responseDate;
  final String? respondedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;
  final String? serverId;
  const DataRequest({
    required this.id,
    required this.beneficiaryId,
    required this.requestType,
    required this.status,
    this.details,
    required this.notes,
    required this.requestDate,
    this.responseDate,
    this.respondedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['beneficiary_id'] = Variable<String>(beneficiaryId);
    map['request_type'] = Variable<String>(requestType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['notes'] = Variable<String>(notes);
    map['request_date'] = Variable<DateTime>(requestDate);
    if (!nullToAbsent || responseDate != null) {
      map['response_date'] = Variable<DateTime>(responseDate);
    }
    if (!nullToAbsent || respondedBy != null) {
      map['responded_by'] = Variable<String>(respondedBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    return map;
  }

  DataRequestsCompanion toCompanion(bool nullToAbsent) {
    return DataRequestsCompanion(
      id: Value(id),
      beneficiaryId: Value(beneficiaryId),
      requestType: Value(requestType),
      status: Value(status),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      notes: Value(notes),
      requestDate: Value(requestDate),
      responseDate: responseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(responseDate),
      respondedBy: respondedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory DataRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataRequest(
      id: serializer.fromJson<String>(json['id']),
      beneficiaryId: serializer.fromJson<String>(json['beneficiaryId']),
      requestType: serializer.fromJson<String>(json['requestType']),
      status: serializer.fromJson<String>(json['status']),
      details: serializer.fromJson<String?>(json['details']),
      notes: serializer.fromJson<String>(json['notes']),
      requestDate: serializer.fromJson<DateTime>(json['requestDate']),
      responseDate: serializer.fromJson<DateTime?>(json['responseDate']),
      respondedBy: serializer.fromJson<String?>(json['respondedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beneficiaryId': serializer.toJson<String>(beneficiaryId),
      'requestType': serializer.toJson<String>(requestType),
      'status': serializer.toJson<String>(status),
      'details': serializer.toJson<String?>(details),
      'notes': serializer.toJson<String>(notes),
      'requestDate': serializer.toJson<DateTime>(requestDate),
      'responseDate': serializer.toJson<DateTime?>(responseDate),
      'respondedBy': serializer.toJson<String?>(respondedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  DataRequest copyWith({
    String? id,
    String? beneficiaryId,
    String? requestType,
    String? status,
    Value<String?> details = const Value.absent(),
    String? notes,
    DateTime? requestDate,
    Value<DateTime?> responseDate = const Value.absent(),
    Value<String?> respondedBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncState,
    Value<String?> serverId = const Value.absent(),
  }) => DataRequest(
    id: id ?? this.id,
    beneficiaryId: beneficiaryId ?? this.beneficiaryId,
    requestType: requestType ?? this.requestType,
    status: status ?? this.status,
    details: details.present ? details.value : this.details,
    notes: notes ?? this.notes,
    requestDate: requestDate ?? this.requestDate,
    responseDate: responseDate.present ? responseDate.value : this.responseDate,
    respondedBy: respondedBy.present ? respondedBy.value : this.respondedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncState: syncState ?? this.syncState,
    serverId: serverId.present ? serverId.value : this.serverId,
  );
  DataRequest copyWithCompanion(DataRequestsCompanion data) {
    return DataRequest(
      id: data.id.present ? data.id.value : this.id,
      beneficiaryId: data.beneficiaryId.present
          ? data.beneficiaryId.value
          : this.beneficiaryId,
      requestType: data.requestType.present
          ? data.requestType.value
          : this.requestType,
      status: data.status.present ? data.status.value : this.status,
      details: data.details.present ? data.details.value : this.details,
      notes: data.notes.present ? data.notes.value : this.notes,
      requestDate: data.requestDate.present
          ? data.requestDate.value
          : this.requestDate,
      responseDate: data.responseDate.present
          ? data.responseDate.value
          : this.responseDate,
      respondedBy: data.respondedBy.present
          ? data.respondedBy.value
          : this.respondedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataRequest(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('requestType: $requestType, ')
          ..write('status: $status, ')
          ..write('details: $details, ')
          ..write('notes: $notes, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('respondedBy: $respondedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    beneficiaryId,
    requestType,
    status,
    details,
    notes,
    requestDate,
    responseDate,
    respondedBy,
    createdAt,
    updatedAt,
    syncState,
    serverId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataRequest &&
          other.id == this.id &&
          other.beneficiaryId == this.beneficiaryId &&
          other.requestType == this.requestType &&
          other.status == this.status &&
          other.details == this.details &&
          other.notes == this.notes &&
          other.requestDate == this.requestDate &&
          other.responseDate == this.responseDate &&
          other.respondedBy == this.respondedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState &&
          other.serverId == this.serverId);
}

class DataRequestsCompanion extends UpdateCompanion<DataRequest> {
  final Value<String> id;
  final Value<String> beneficiaryId;
  final Value<String> requestType;
  final Value<String> status;
  final Value<String?> details;
  final Value<String> notes;
  final Value<DateTime> requestDate;
  final Value<DateTime?> responseDate;
  final Value<String?> respondedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncState;
  final Value<String?> serverId;
  final Value<int> rowid;
  const DataRequestsCompanion({
    this.id = const Value.absent(),
    this.beneficiaryId = const Value.absent(),
    this.requestType = const Value.absent(),
    this.status = const Value.absent(),
    this.details = const Value.absent(),
    this.notes = const Value.absent(),
    this.requestDate = const Value.absent(),
    this.responseDate = const Value.absent(),
    this.respondedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DataRequestsCompanion.insert({
    required String id,
    required String beneficiaryId,
    required String requestType,
    required String status,
    this.details = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime requestDate,
    this.responseDate = const Value.absent(),
    this.respondedBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncState = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       beneficiaryId = Value(beneficiaryId),
       requestType = Value(requestType),
       status = Value(status),
       requestDate = Value(requestDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DataRequest> custom({
    Expression<String>? id,
    Expression<String>? beneficiaryId,
    Expression<String>? requestType,
    Expression<String>? status,
    Expression<String>? details,
    Expression<String>? notes,
    Expression<DateTime>? requestDate,
    Expression<DateTime>? responseDate,
    Expression<String>? respondedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncState,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beneficiaryId != null) 'beneficiary_id': beneficiaryId,
      if (requestType != null) 'request_type': requestType,
      if (status != null) 'status': status,
      if (details != null) 'details': details,
      if (notes != null) 'notes': notes,
      if (requestDate != null) 'request_date': requestDate,
      if (responseDate != null) 'response_date': responseDate,
      if (respondedBy != null) 'responded_by': respondedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DataRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? beneficiaryId,
    Value<String>? requestType,
    Value<String>? status,
    Value<String?>? details,
    Value<String>? notes,
    Value<DateTime>? requestDate,
    Value<DateTime?>? responseDate,
    Value<String?>? respondedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncState,
    Value<String?>? serverId,
    Value<int>? rowid,
  }) {
    return DataRequestsCompanion(
      id: id ?? this.id,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      requestType: requestType ?? this.requestType,
      status: status ?? this.status,
      details: details ?? this.details,
      notes: notes ?? this.notes,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      respondedBy: respondedBy ?? this.respondedBy,
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
    if (beneficiaryId.present) {
      map['beneficiary_id'] = Variable<String>(beneficiaryId.value);
    }
    if (requestType.present) {
      map['request_type'] = Variable<String>(requestType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (requestDate.present) {
      map['request_date'] = Variable<DateTime>(requestDate.value);
    }
    if (responseDate.present) {
      map['response_date'] = Variable<DateTime>(responseDate.value);
    }
    if (respondedBy.present) {
      map['responded_by'] = Variable<String>(respondedBy.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataRequestsCompanion(')
          ..write('id: $id, ')
          ..write('beneficiaryId: $beneficiaryId, ')
          ..write('requestType: $requestType, ')
          ..write('status: $status, ')
          ..write('details: $details, ')
          ..write('notes: $notes, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('respondedBy: $respondedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
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
  late final $CivilRegistryTable civilRegistry = $CivilRegistryTable(this);
  late final $CivilRegistryCityTable civilRegistryCity =
      $CivilRegistryCityTable(this);
  late final $CivilRegistryRelationsTable civilRegistryRelations =
      $CivilRegistryRelationsTable(this);
  late final $CivilRegistryRelationCategoriesTable
  civilRegistryRelationCategories = $CivilRegistryRelationCategoriesTable(this);
  late final $CivilRegistryBirthCodeTable civilRegistryBirthCode =
      $CivilRegistryBirthCodeTable(this);
  late final $CivilRegistryPersonalCodeTable civilRegistryPersonalCode =
      $CivilRegistryPersonalCodeTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $DataRequestsTable dataRequests = $DataRequestsTable(this);
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
    civilRegistry,
    civilRegistryCity,
    civilRegistryRelations,
    civilRegistryRelationCategories,
    civilRegistryBirthCode,
    civilRegistryPersonalCode,
    activities,
    dataRequests,
  ];
}

typedef $$BeneficiariesTableCreateCompanionBuilder =
    BeneficiariesCompanion Function({
      required String id,
      required String fullName,
      required String fullNameNorm,
      required String nationalId,
      required String fileNo,
      required String governorate,
      Value<String?> district,
      Value<String?> address,
      Value<String?> phoneNumber,
      Value<String?> motherName,
      Value<String?> fatherName,
      Value<String?> grandFatherName,
      Value<String?> familyName,
      Value<String?> altPhoneNumber,
      Value<int?> familySize,
      required String gender,
      required String category,
      Value<DateTime?> birthDate,
      Value<String?> maritalStatus,
      Value<String?> educationLevel,
      Value<String?> healthStatus,
      Value<bool> hasDisability,
      Value<int?> displacementStatus,
      Value<String?> addressBeforeDisplacement,
      Value<String?> currentAddress,
      Value<int?> numberOfMales,
      Value<int?> numberOfFemales,
      Value<int?> chronicDiseasesCount,
      Value<int?> specialNeedsCount,
      Value<int?> employmentStatus,
      Value<int?> housingStatus,
      Value<int?> housingType,
      Value<int?> requestStatus,
      Value<String> notes,
      Value<String?> associationName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<String?> serverId,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$BeneficiariesTableUpdateCompanionBuilder =
    BeneficiariesCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String> fullNameNorm,
      Value<String> nationalId,
      Value<String> fileNo,
      Value<String> governorate,
      Value<String?> district,
      Value<String?> address,
      Value<String?> phoneNumber,
      Value<String?> motherName,
      Value<String?> fatherName,
      Value<String?> grandFatherName,
      Value<String?> familyName,
      Value<String?> altPhoneNumber,
      Value<int?> familySize,
      Value<String> gender,
      Value<String> category,
      Value<DateTime?> birthDate,
      Value<String?> maritalStatus,
      Value<String?> educationLevel,
      Value<String?> healthStatus,
      Value<bool> hasDisability,
      Value<int?> displacementStatus,
      Value<String?> addressBeforeDisplacement,
      Value<String?> currentAddress,
      Value<int?> numberOfMales,
      Value<int?> numberOfFemales,
      Value<int?> chronicDiseasesCount,
      Value<int?> specialNeedsCount,
      Value<int?> employmentStatus,
      Value<int?> housingStatus,
      Value<int?> housingType,
      Value<int?> requestStatus,
      Value<String> notes,
      Value<String?> associationName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<String?> serverId,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });

class $$BeneficiariesTableFilterComposer
    extends Composer<_$AppDatabase, $BeneficiariesTable> {
  $$BeneficiariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullNameNorm => $composableBuilder(
    column: $table.fullNameNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileNo => $composableBuilder(
    column: $table.fileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altPhoneNumber => $composableBuilder(
    column: $table.altPhoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get familySize => $composableBuilder(
    column: $table.familySize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maritalStatus => $composableBuilder(
    column: $table.maritalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthStatus => $composableBuilder(
    column: $table.healthStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDisability => $composableBuilder(
    column: $table.hasDisability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displacementStatus => $composableBuilder(
    column: $table.displacementStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressBeforeDisplacement => $composableBuilder(
    column: $table.addressBeforeDisplacement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentAddress => $composableBuilder(
    column: $table.currentAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfMales => $composableBuilder(
    column: $table.numberOfMales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfFemales => $composableBuilder(
    column: $table.numberOfFemales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chronicDiseasesCount => $composableBuilder(
    column: $table.chronicDiseasesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get specialNeedsCount => $composableBuilder(
    column: $table.specialNeedsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get employmentStatus => $composableBuilder(
    column: $table.employmentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get housingStatus => $composableBuilder(
    column: $table.housingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get housingType => $composableBuilder(
    column: $table.housingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestStatus => $composableBuilder(
    column: $table.requestStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullNameNorm => $composableBuilder(
    column: $table.fullNameNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileNo => $composableBuilder(
    column: $table.fileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altPhoneNumber => $composableBuilder(
    column: $table.altPhoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get familySize => $composableBuilder(
    column: $table.familySize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maritalStatus => $composableBuilder(
    column: $table.maritalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthStatus => $composableBuilder(
    column: $table.healthStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDisability => $composableBuilder(
    column: $table.hasDisability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displacementStatus => $composableBuilder(
    column: $table.displacementStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressBeforeDisplacement => $composableBuilder(
    column: $table.addressBeforeDisplacement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentAddress => $composableBuilder(
    column: $table.currentAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfMales => $composableBuilder(
    column: $table.numberOfMales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfFemales => $composableBuilder(
    column: $table.numberOfFemales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chronicDiseasesCount => $composableBuilder(
    column: $table.chronicDiseasesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get specialNeedsCount => $composableBuilder(
    column: $table.specialNeedsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get employmentStatus => $composableBuilder(
    column: $table.employmentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get housingStatus => $composableBuilder(
    column: $table.housingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get housingType => $composableBuilder(
    column: $table.housingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestStatus => $composableBuilder(
    column: $table.requestStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fullNameNorm => $composableBuilder(
    column: $table.fullNameNorm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileNo =>
      $composableBuilder(column: $table.fileNo, builder: (column) => column);

  GeneratedColumn<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get altPhoneNumber => $composableBuilder(
    column: $table.altPhoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get familySize => $composableBuilder(
    column: $table.familySize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get maritalStatus => $composableBuilder(
    column: $table.maritalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get healthStatus => $composableBuilder(
    column: $table.healthStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDisability => $composableBuilder(
    column: $table.hasDisability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displacementStatus => $composableBuilder(
    column: $table.displacementStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressBeforeDisplacement => $composableBuilder(
    column: $table.addressBeforeDisplacement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentAddress => $composableBuilder(
    column: $table.currentAddress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfMales => $composableBuilder(
    column: $table.numberOfMales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfFemales => $composableBuilder(
    column: $table.numberOfFemales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chronicDiseasesCount => $composableBuilder(
    column: $table.chronicDiseasesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get specialNeedsCount => $composableBuilder(
    column: $table.specialNeedsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get employmentStatus => $composableBuilder(
    column: $table.employmentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get housingStatus => $composableBuilder(
    column: $table.housingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get housingType => $composableBuilder(
    column: $table.housingType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestStatus => $composableBuilder(
    column: $table.requestStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get associationName => $composableBuilder(
    column: $table.associationName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$BeneficiariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BeneficiariesTable,
          Beneficiary,
          $$BeneficiariesTableFilterComposer,
          $$BeneficiariesTableOrderingComposer,
          $$BeneficiariesTableAnnotationComposer,
          $$BeneficiariesTableCreateCompanionBuilder,
          $$BeneficiariesTableUpdateCompanionBuilder,
          (
            Beneficiary,
            BaseReferences<_$AppDatabase, $BeneficiariesTable, Beneficiary>,
          ),
          Beneficiary,
          PrefetchHooks Function()
        > {
  $$BeneficiariesTableTableManager(_$AppDatabase db, $BeneficiariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeneficiariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeneficiariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeneficiariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> fullNameNorm = const Value.absent(),
                Value<String> nationalId = const Value.absent(),
                Value<String> fileNo = const Value.absent(),
                Value<String> governorate = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<String?> grandFatherName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> altPhoneNumber = const Value.absent(),
                Value<int?> familySize = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> maritalStatus = const Value.absent(),
                Value<String?> educationLevel = const Value.absent(),
                Value<String?> healthStatus = const Value.absent(),
                Value<bool> hasDisability = const Value.absent(),
                Value<int?> displacementStatus = const Value.absent(),
                Value<String?> addressBeforeDisplacement = const Value.absent(),
                Value<String?> currentAddress = const Value.absent(),
                Value<int?> numberOfMales = const Value.absent(),
                Value<int?> numberOfFemales = const Value.absent(),
                Value<int?> chronicDiseasesCount = const Value.absent(),
                Value<int?> specialNeedsCount = const Value.absent(),
                Value<int?> employmentStatus = const Value.absent(),
                Value<int?> housingStatus = const Value.absent(),
                Value<int?> housingType = const Value.absent(),
                Value<int?> requestStatus = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeneficiariesCompanion(
                id: id,
                fullName: fullName,
                fullNameNorm: fullNameNorm,
                nationalId: nationalId,
                fileNo: fileNo,
                governorate: governorate,
                district: district,
                address: address,
                phoneNumber: phoneNumber,
                motherName: motherName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                familyName: familyName,
                altPhoneNumber: altPhoneNumber,
                familySize: familySize,
                gender: gender,
                category: category,
                birthDate: birthDate,
                maritalStatus: maritalStatus,
                educationLevel: educationLevel,
                healthStatus: healthStatus,
                hasDisability: hasDisability,
                displacementStatus: displacementStatus,
                addressBeforeDisplacement: addressBeforeDisplacement,
                currentAddress: currentAddress,
                numberOfMales: numberOfMales,
                numberOfFemales: numberOfFemales,
                chronicDiseasesCount: chronicDiseasesCount,
                specialNeedsCount: specialNeedsCount,
                employmentStatus: employmentStatus,
                housingStatus: housingStatus,
                housingType: housingType,
                requestStatus: requestStatus,
                notes: notes,
                associationName: associationName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                serverId: serverId,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                required String fullNameNorm,
                required String nationalId,
                required String fileNo,
                required String governorate,
                Value<String?> district = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<String?> grandFatherName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> altPhoneNumber = const Value.absent(),
                Value<int?> familySize = const Value.absent(),
                required String gender,
                required String category,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> maritalStatus = const Value.absent(),
                Value<String?> educationLevel = const Value.absent(),
                Value<String?> healthStatus = const Value.absent(),
                Value<bool> hasDisability = const Value.absent(),
                Value<int?> displacementStatus = const Value.absent(),
                Value<String?> addressBeforeDisplacement = const Value.absent(),
                Value<String?> currentAddress = const Value.absent(),
                Value<int?> numberOfMales = const Value.absent(),
                Value<int?> numberOfFemales = const Value.absent(),
                Value<int?> chronicDiseasesCount = const Value.absent(),
                Value<int?> specialNeedsCount = const Value.absent(),
                Value<int?> employmentStatus = const Value.absent(),
                Value<int?> housingStatus = const Value.absent(),
                Value<int?> housingType = const Value.absent(),
                Value<int?> requestStatus = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> associationName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeneficiariesCompanion.insert(
                id: id,
                fullName: fullName,
                fullNameNorm: fullNameNorm,
                nationalId: nationalId,
                fileNo: fileNo,
                governorate: governorate,
                district: district,
                address: address,
                phoneNumber: phoneNumber,
                motherName: motherName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                familyName: familyName,
                altPhoneNumber: altPhoneNumber,
                familySize: familySize,
                gender: gender,
                category: category,
                birthDate: birthDate,
                maritalStatus: maritalStatus,
                educationLevel: educationLevel,
                healthStatus: healthStatus,
                hasDisability: hasDisability,
                displacementStatus: displacementStatus,
                addressBeforeDisplacement: addressBeforeDisplacement,
                currentAddress: currentAddress,
                numberOfMales: numberOfMales,
                numberOfFemales: numberOfFemales,
                chronicDiseasesCount: chronicDiseasesCount,
                specialNeedsCount: specialNeedsCount,
                employmentStatus: employmentStatus,
                housingStatus: housingStatus,
                housingType: housingType,
                requestStatus: requestStatus,
                notes: notes,
                associationName: associationName,
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
        ),
      );
}

typedef $$BeneficiariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BeneficiariesTable,
      Beneficiary,
      $$BeneficiariesTableFilterComposer,
      $$BeneficiariesTableOrderingComposer,
      $$BeneficiariesTableAnnotationComposer,
      $$BeneficiariesTableCreateCompanionBuilder,
      $$BeneficiariesTableUpdateCompanionBuilder,
      (
        Beneficiary,
        BaseReferences<_$AppDatabase, $BeneficiariesTable, Beneficiary>,
      ),
      Beneficiary,
      PrefetchHooks Function()
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
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
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffName => $composableBuilder(
    column: $table.staffName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.beneficiaryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get staffName =>
      $composableBuilder(column: $table.staffName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
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
              }) => VisitsCompanion(
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
          createCompanionCallback:
              ({
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
              }) => VisitsCompanion.insert(
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
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String beneficiaryId,
      Value<String?> visitId,
      required String fileName,
      required String filePath,
      required String type,
      required int fileSize,
      Value<String?> thumbnailPath,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<String?> serverUrl,
      Value<DateTime?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> beneficiaryId,
      Value<String?> visitId,
      Value<String> fileName,
      Value<String> filePath,
      Value<String> type,
      Value<int> fileSize,
      Value<String?> thumbnailPath,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitId => $composableBuilder(
    column: $table.visitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.beneficiaryId,
    builder: (column) => column,
  );

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
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> beneficiaryId = const Value.absent(),
                Value<String?> visitId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                beneficiaryId: beneficiaryId,
                visitId: visitId,
                fileName: fileName,
                filePath: filePath,
                type: type,
                fileSize: fileSize,
                thumbnailPath: thumbnailPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                serverUrl: serverUrl,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String beneficiaryId,
                Value<String?> visitId = const Value.absent(),
                required String fileName,
                required String filePath,
                required String type,
                required int fileSize,
                Value<String?> thumbnailPath = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                beneficiaryId: beneficiaryId,
                visitId: visitId,
                fileName: fileName,
                filePath: filePath,
                type: type,
                fileSize: fileSize,
                thumbnailPath: thumbnailPath,
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
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$TaxonomiesTableCreateCompanionBuilder =
    TaxonomiesCompanion Function({
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
typedef $$TaxonomiesTableUpdateCompanionBuilder =
    TaxonomiesCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
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

class $$TaxonomiesTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$TaxonomiesTableTableManager(_$AppDatabase db, $TaxonomiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxonomiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxonomiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxonomiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> group = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxonomiesCompanion(
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
          createCompanionCallback:
              ({
                required String id,
                required String group,
                required String code,
                required String label,
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TaxonomiesCompanion.insert(
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
        ),
      );
}

typedef $$TaxonomiesTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
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
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.scheduledAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
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
              }) => SyncQueueCompanion(
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
          createCompanionCallback:
              ({
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
              }) => SyncQueueCompanion.insert(
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
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryTableCreateCompanionBuilder =
    CivilRegistryCompanion Function({
      Value<int> id,
      required String nationalId,
      required String firstName,
      required String fatherName,
      required String grandFatherName,
      required String familyName,
      Value<int?> birthCertificateId,
      Value<int?> birthCodeId,
      Value<DateTime?> birthDate,
      Value<int?> sexCode,
      Value<int?> personalCodeId,
      Value<int?> deadDate,
      Value<String?> motherName,
      Value<int?> cityId,
      Value<String?> cityName,
      Value<String?> street,
      Value<String?> houseNo,
      Value<int?> relationId,
      Value<int?> relativeCodeId,
      Value<int?> relativeId,
      Value<String?> fullName,
      Value<String?> fullNameNormalized,
      Value<String?> governorate,
      Value<String?> district,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$CivilRegistryTableUpdateCompanionBuilder =
    CivilRegistryCompanion Function({
      Value<int> id,
      Value<String> nationalId,
      Value<String> firstName,
      Value<String> fatherName,
      Value<String> grandFatherName,
      Value<String> familyName,
      Value<int?> birthCertificateId,
      Value<int?> birthCodeId,
      Value<DateTime?> birthDate,
      Value<int?> sexCode,
      Value<int?> personalCodeId,
      Value<int?> deadDate,
      Value<String?> motherName,
      Value<int?> cityId,
      Value<String?> cityName,
      Value<String?> street,
      Value<String?> houseNo,
      Value<int?> relationId,
      Value<int?> relativeCodeId,
      Value<int?> relativeId,
      Value<String?> fullName,
      Value<String?> fullNameNormalized,
      Value<String?> governorate,
      Value<String?> district,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
    });

class $$CivilRegistryTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryTable> {
  $$CivilRegistryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthCertificateId => $composableBuilder(
    column: $table.birthCertificateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthCodeId => $composableBuilder(
    column: $table.birthCodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sexCode => $composableBuilder(
    column: $table.sexCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personalCodeId => $composableBuilder(
    column: $table.personalCodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadDate => $composableBuilder(
    column: $table.deadDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityName => $composableBuilder(
    column: $table.cityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseNo => $composableBuilder(
    column: $table.houseNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relationId => $composableBuilder(
    column: $table.relationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullNameNormalized => $composableBuilder(
    column: $table.fullNameNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryTable> {
  $$CivilRegistryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthCertificateId => $composableBuilder(
    column: $table.birthCertificateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthCodeId => $composableBuilder(
    column: $table.birthCodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sexCode => $composableBuilder(
    column: $table.sexCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personalCodeId => $composableBuilder(
    column: $table.personalCodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadDate => $composableBuilder(
    column: $table.deadDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cityId => $composableBuilder(
    column: $table.cityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityName => $composableBuilder(
    column: $table.cityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseNo => $composableBuilder(
    column: $table.houseNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relationId => $composableBuilder(
    column: $table.relationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullNameNormalized => $composableBuilder(
    column: $table.fullNameNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryTable> {
  $$CivilRegistryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthCertificateId => $composableBuilder(
    column: $table.birthCertificateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthCodeId => $composableBuilder(
    column: $table.birthCodeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get sexCode =>
      $composableBuilder(column: $table.sexCode, builder: (column) => column);

  GeneratedColumn<int> get personalCodeId => $composableBuilder(
    column: $table.personalCodeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deadDate =>
      $composableBuilder(column: $table.deadDate, builder: (column) => column);

  GeneratedColumn<String> get motherName => $composableBuilder(
    column: $table.motherName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get cityName =>
      $composableBuilder(column: $table.cityName, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get houseNo =>
      $composableBuilder(column: $table.houseNo, builder: (column) => column);

  GeneratedColumn<int> get relationId => $composableBuilder(
    column: $table.relationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fullNameNormalized => $composableBuilder(
    column: $table.fullNameNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get governorate => $composableBuilder(
    column: $table.governorate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$CivilRegistryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryTable,
          CivilRegistryData,
          $$CivilRegistryTableFilterComposer,
          $$CivilRegistryTableOrderingComposer,
          $$CivilRegistryTableAnnotationComposer,
          $$CivilRegistryTableCreateCompanionBuilder,
          $$CivilRegistryTableUpdateCompanionBuilder,
          (
            CivilRegistryData,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryTable,
              CivilRegistryData
            >,
          ),
          CivilRegistryData,
          PrefetchHooks Function()
        > {
  $$CivilRegistryTableTableManager(_$AppDatabase db, $CivilRegistryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CivilRegistryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CivilRegistryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nationalId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<String> grandFatherName = const Value.absent(),
                Value<String> familyName = const Value.absent(),
                Value<int?> birthCertificateId = const Value.absent(),
                Value<int?> birthCodeId = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<int?> sexCode = const Value.absent(),
                Value<int?> personalCodeId = const Value.absent(),
                Value<int?> deadDate = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<int?> cityId = const Value.absent(),
                Value<String?> cityName = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> houseNo = const Value.absent(),
                Value<int?> relationId = const Value.absent(),
                Value<int?> relativeCodeId = const Value.absent(),
                Value<int?> relativeId = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> fullNameNormalized = const Value.absent(),
                Value<String?> governorate = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => CivilRegistryCompanion(
                id: id,
                nationalId: nationalId,
                firstName: firstName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                familyName: familyName,
                birthCertificateId: birthCertificateId,
                birthCodeId: birthCodeId,
                birthDate: birthDate,
                sexCode: sexCode,
                personalCodeId: personalCodeId,
                deadDate: deadDate,
                motherName: motherName,
                cityId: cityId,
                cityName: cityName,
                street: street,
                houseNo: houseNo,
                relationId: relationId,
                relativeCodeId: relativeCodeId,
                relativeId: relativeId,
                fullName: fullName,
                fullNameNormalized: fullNameNormalized,
                governorate: governorate,
                district: district,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nationalId,
                required String firstName,
                required String fatherName,
                required String grandFatherName,
                required String familyName,
                Value<int?> birthCertificateId = const Value.absent(),
                Value<int?> birthCodeId = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<int?> sexCode = const Value.absent(),
                Value<int?> personalCodeId = const Value.absent(),
                Value<int?> deadDate = const Value.absent(),
                Value<String?> motherName = const Value.absent(),
                Value<int?> cityId = const Value.absent(),
                Value<String?> cityName = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> houseNo = const Value.absent(),
                Value<int?> relationId = const Value.absent(),
                Value<int?> relativeCodeId = const Value.absent(),
                Value<int?> relativeId = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> fullNameNormalized = const Value.absent(),
                Value<String?> governorate = const Value.absent(),
                Value<String?> district = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => CivilRegistryCompanion.insert(
                id: id,
                nationalId: nationalId,
                firstName: firstName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                familyName: familyName,
                birthCertificateId: birthCertificateId,
                birthCodeId: birthCodeId,
                birthDate: birthDate,
                sexCode: sexCode,
                personalCodeId: personalCodeId,
                deadDate: deadDate,
                motherName: motherName,
                cityId: cityId,
                cityName: cityName,
                street: street,
                houseNo: houseNo,
                relationId: relationId,
                relativeCodeId: relativeCodeId,
                relativeId: relativeId,
                fullName: fullName,
                fullNameNormalized: fullNameNormalized,
                governorate: governorate,
                district: district,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryTable,
      CivilRegistryData,
      $$CivilRegistryTableFilterComposer,
      $$CivilRegistryTableOrderingComposer,
      $$CivilRegistryTableAnnotationComposer,
      $$CivilRegistryTableCreateCompanionBuilder,
      $$CivilRegistryTableUpdateCompanionBuilder,
      (
        CivilRegistryData,
        BaseReferences<_$AppDatabase, $CivilRegistryTable, CivilRegistryData>,
      ),
      CivilRegistryData,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryCityTableCreateCompanionBuilder =
    CivilRegistryCityCompanion Function({
      Value<int> id,
      required String city,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CivilRegistryCityTableUpdateCompanionBuilder =
    CivilRegistryCityCompanion Function({
      Value<int> id,
      Value<String> city,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CivilRegistryCityTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryCityTable> {
  $$CivilRegistryCityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryCityTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryCityTable> {
  $$CivilRegistryCityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryCityTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryCityTable> {
  $$CivilRegistryCityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CivilRegistryCityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryCityTable,
          CivilRegistryCityData,
          $$CivilRegistryCityTableFilterComposer,
          $$CivilRegistryCityTableOrderingComposer,
          $$CivilRegistryCityTableAnnotationComposer,
          $$CivilRegistryCityTableCreateCompanionBuilder,
          $$CivilRegistryCityTableUpdateCompanionBuilder,
          (
            CivilRegistryCityData,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryCityTable,
              CivilRegistryCityData
            >,
          ),
          CivilRegistryCityData,
          PrefetchHooks Function()
        > {
  $$CivilRegistryCityTableTableManager(
    _$AppDatabase db,
    $CivilRegistryCityTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryCityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CivilRegistryCityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CivilRegistryCityTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CivilRegistryCityCompanion(
                id: id,
                city: city,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String city,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CivilRegistryCityCompanion.insert(
                id: id,
                city: city,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryCityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryCityTable,
      CivilRegistryCityData,
      $$CivilRegistryCityTableFilterComposer,
      $$CivilRegistryCityTableOrderingComposer,
      $$CivilRegistryCityTableAnnotationComposer,
      $$CivilRegistryCityTableCreateCompanionBuilder,
      $$CivilRegistryCityTableUpdateCompanionBuilder,
      (
        CivilRegistryCityData,
        BaseReferences<
          _$AppDatabase,
          $CivilRegistryCityTable,
          CivilRegistryCityData
        >,
      ),
      CivilRegistryCityData,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryRelationsTableCreateCompanionBuilder =
    CivilRegistryRelationsCompanion Function({
      Value<int> id,
      required int personId,
      required int relativeId,
      required int relativeCodeId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CivilRegistryRelationsTableUpdateCompanionBuilder =
    CivilRegistryRelationsCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<int> relativeId,
      Value<int> relativeCodeId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CivilRegistryRelationsTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationsTable> {
  $$CivilRegistryRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryRelationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationsTable> {
  $$CivilRegistryRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryRelationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationsTable> {
  $$CivilRegistryRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<int> get relativeId => $composableBuilder(
    column: $table.relativeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relativeCodeId => $composableBuilder(
    column: $table.relativeCodeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CivilRegistryRelationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryRelationsTable,
          CivilRegistryRelation,
          $$CivilRegistryRelationsTableFilterComposer,
          $$CivilRegistryRelationsTableOrderingComposer,
          $$CivilRegistryRelationsTableAnnotationComposer,
          $$CivilRegistryRelationsTableCreateCompanionBuilder,
          $$CivilRegistryRelationsTableUpdateCompanionBuilder,
          (
            CivilRegistryRelation,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryRelationsTable,
              CivilRegistryRelation
            >,
          ),
          CivilRegistryRelation,
          PrefetchHooks Function()
        > {
  $$CivilRegistryRelationsTableTableManager(
    _$AppDatabase db,
    $CivilRegistryRelationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryRelationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CivilRegistryRelationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CivilRegistryRelationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<int> relativeId = const Value.absent(),
                Value<int> relativeCodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CivilRegistryRelationsCompanion(
                id: id,
                personId: personId,
                relativeId: relativeId,
                relativeCodeId: relativeCodeId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                required int relativeId,
                required int relativeCodeId,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CivilRegistryRelationsCompanion.insert(
                id: id,
                personId: personId,
                relativeId: relativeId,
                relativeCodeId: relativeCodeId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryRelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryRelationsTable,
      CivilRegistryRelation,
      $$CivilRegistryRelationsTableFilterComposer,
      $$CivilRegistryRelationsTableOrderingComposer,
      $$CivilRegistryRelationsTableAnnotationComposer,
      $$CivilRegistryRelationsTableCreateCompanionBuilder,
      $$CivilRegistryRelationsTableUpdateCompanionBuilder,
      (
        CivilRegistryRelation,
        BaseReferences<
          _$AppDatabase,
          $CivilRegistryRelationsTable,
          CivilRegistryRelation
        >,
      ),
      CivilRegistryRelation,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryRelationCategoriesTableCreateCompanionBuilder =
    CivilRegistryRelationCategoriesCompanion Function({
      Value<int> id,
      required String attribute,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CivilRegistryRelationCategoriesTableUpdateCompanionBuilder =
    CivilRegistryRelationCategoriesCompanion Function({
      Value<int> id,
      Value<String> attribute,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CivilRegistryRelationCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationCategoriesTable> {
  $$CivilRegistryRelationCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribute => $composableBuilder(
    column: $table.attribute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryRelationCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationCategoriesTable> {
  $$CivilRegistryRelationCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribute => $composableBuilder(
    column: $table.attribute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryRelationCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryRelationCategoriesTable> {
  $$CivilRegistryRelationCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attribute =>
      $composableBuilder(column: $table.attribute, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CivilRegistryRelationCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryRelationCategoriesTable,
          CivilRegistryRelationCategory,
          $$CivilRegistryRelationCategoriesTableFilterComposer,
          $$CivilRegistryRelationCategoriesTableOrderingComposer,
          $$CivilRegistryRelationCategoriesTableAnnotationComposer,
          $$CivilRegistryRelationCategoriesTableCreateCompanionBuilder,
          $$CivilRegistryRelationCategoriesTableUpdateCompanionBuilder,
          (
            CivilRegistryRelationCategory,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryRelationCategoriesTable,
              CivilRegistryRelationCategory
            >,
          ),
          CivilRegistryRelationCategory,
          PrefetchHooks Function()
        > {
  $$CivilRegistryRelationCategoriesTableTableManager(
    _$AppDatabase db,
    $CivilRegistryRelationCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryRelationCategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CivilRegistryRelationCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CivilRegistryRelationCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> attribute = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CivilRegistryRelationCategoriesCompanion(
                id: id,
                attribute: attribute,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String attribute,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CivilRegistryRelationCategoriesCompanion.insert(
                id: id,
                attribute: attribute,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryRelationCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryRelationCategoriesTable,
      CivilRegistryRelationCategory,
      $$CivilRegistryRelationCategoriesTableFilterComposer,
      $$CivilRegistryRelationCategoriesTableOrderingComposer,
      $$CivilRegistryRelationCategoriesTableAnnotationComposer,
      $$CivilRegistryRelationCategoriesTableCreateCompanionBuilder,
      $$CivilRegistryRelationCategoriesTableUpdateCompanionBuilder,
      (
        CivilRegistryRelationCategory,
        BaseReferences<
          _$AppDatabase,
          $CivilRegistryRelationCategoriesTable,
          CivilRegistryRelationCategory
        >,
      ),
      CivilRegistryRelationCategory,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryBirthCodeTableCreateCompanionBuilder =
    CivilRegistryBirthCodeCompanion Function({
      Value<int> id,
      required String birthCode,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CivilRegistryBirthCodeTableUpdateCompanionBuilder =
    CivilRegistryBirthCodeCompanion Function({
      Value<int> id,
      Value<String> birthCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CivilRegistryBirthCodeTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryBirthCodeTable> {
  $$CivilRegistryBirthCodeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthCode => $composableBuilder(
    column: $table.birthCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryBirthCodeTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryBirthCodeTable> {
  $$CivilRegistryBirthCodeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthCode => $composableBuilder(
    column: $table.birthCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryBirthCodeTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryBirthCodeTable> {
  $$CivilRegistryBirthCodeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get birthCode =>
      $composableBuilder(column: $table.birthCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CivilRegistryBirthCodeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryBirthCodeTable,
          CivilRegistryBirthCodeData,
          $$CivilRegistryBirthCodeTableFilterComposer,
          $$CivilRegistryBirthCodeTableOrderingComposer,
          $$CivilRegistryBirthCodeTableAnnotationComposer,
          $$CivilRegistryBirthCodeTableCreateCompanionBuilder,
          $$CivilRegistryBirthCodeTableUpdateCompanionBuilder,
          (
            CivilRegistryBirthCodeData,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryBirthCodeTable,
              CivilRegistryBirthCodeData
            >,
          ),
          CivilRegistryBirthCodeData,
          PrefetchHooks Function()
        > {
  $$CivilRegistryBirthCodeTableTableManager(
    _$AppDatabase db,
    $CivilRegistryBirthCodeTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryBirthCodeTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CivilRegistryBirthCodeTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CivilRegistryBirthCodeTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> birthCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CivilRegistryBirthCodeCompanion(
                id: id,
                birthCode: birthCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String birthCode,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CivilRegistryBirthCodeCompanion.insert(
                id: id,
                birthCode: birthCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryBirthCodeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryBirthCodeTable,
      CivilRegistryBirthCodeData,
      $$CivilRegistryBirthCodeTableFilterComposer,
      $$CivilRegistryBirthCodeTableOrderingComposer,
      $$CivilRegistryBirthCodeTableAnnotationComposer,
      $$CivilRegistryBirthCodeTableCreateCompanionBuilder,
      $$CivilRegistryBirthCodeTableUpdateCompanionBuilder,
      (
        CivilRegistryBirthCodeData,
        BaseReferences<
          _$AppDatabase,
          $CivilRegistryBirthCodeTable,
          CivilRegistryBirthCodeData
        >,
      ),
      CivilRegistryBirthCodeData,
      PrefetchHooks Function()
    >;
typedef $$CivilRegistryPersonalCodeTableCreateCompanionBuilder =
    CivilRegistryPersonalCodeCompanion Function({
      Value<int> id,
      required String personalCode,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CivilRegistryPersonalCodeTableUpdateCompanionBuilder =
    CivilRegistryPersonalCodeCompanion Function({
      Value<int> id,
      Value<String> personalCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CivilRegistryPersonalCodeTableFilterComposer
    extends Composer<_$AppDatabase, $CivilRegistryPersonalCodeTable> {
  $$CivilRegistryPersonalCodeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalCode => $composableBuilder(
    column: $table.personalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CivilRegistryPersonalCodeTableOrderingComposer
    extends Composer<_$AppDatabase, $CivilRegistryPersonalCodeTable> {
  $$CivilRegistryPersonalCodeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalCode => $composableBuilder(
    column: $table.personalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CivilRegistryPersonalCodeTableAnnotationComposer
    extends Composer<_$AppDatabase, $CivilRegistryPersonalCodeTable> {
  $$CivilRegistryPersonalCodeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personalCode => $composableBuilder(
    column: $table.personalCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CivilRegistryPersonalCodeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CivilRegistryPersonalCodeTable,
          CivilRegistryPersonalCodeData,
          $$CivilRegistryPersonalCodeTableFilterComposer,
          $$CivilRegistryPersonalCodeTableOrderingComposer,
          $$CivilRegistryPersonalCodeTableAnnotationComposer,
          $$CivilRegistryPersonalCodeTableCreateCompanionBuilder,
          $$CivilRegistryPersonalCodeTableUpdateCompanionBuilder,
          (
            CivilRegistryPersonalCodeData,
            BaseReferences<
              _$AppDatabase,
              $CivilRegistryPersonalCodeTable,
              CivilRegistryPersonalCodeData
            >,
          ),
          CivilRegistryPersonalCodeData,
          PrefetchHooks Function()
        > {
  $$CivilRegistryPersonalCodeTableTableManager(
    _$AppDatabase db,
    $CivilRegistryPersonalCodeTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CivilRegistryPersonalCodeTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CivilRegistryPersonalCodeTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CivilRegistryPersonalCodeTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> personalCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CivilRegistryPersonalCodeCompanion(
                id: id,
                personalCode: personalCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String personalCode,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CivilRegistryPersonalCodeCompanion.insert(
                id: id,
                personalCode: personalCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CivilRegistryPersonalCodeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CivilRegistryPersonalCodeTable,
      CivilRegistryPersonalCodeData,
      $$CivilRegistryPersonalCodeTableFilterComposer,
      $$CivilRegistryPersonalCodeTableOrderingComposer,
      $$CivilRegistryPersonalCodeTableAnnotationComposer,
      $$CivilRegistryPersonalCodeTableCreateCompanionBuilder,
      $$CivilRegistryPersonalCodeTableUpdateCompanionBuilder,
      (
        CivilRegistryPersonalCodeData,
        BaseReferences<
          _$AppDatabase,
          $CivilRegistryPersonalCodeTable,
          CivilRegistryPersonalCodeData
        >,
      ),
      CivilRegistryPersonalCodeData,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
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
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changes => $composableBuilder(
    column: $table.changes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changes => $composableBuilder(
    column: $table.changes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.beneficiaryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> beneficiaryId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> changes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
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
          createCompanionCallback:
              ({
                required String id,
                required String beneficiaryId,
                required String userId,
                required String activityType,
                required String description,
                Value<String?> changes = const Value.absent(),
                required DateTime createdAt,
                Value<String> syncState = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
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
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;
typedef $$DataRequestsTableCreateCompanionBuilder =
    DataRequestsCompanion Function({
      required String id,
      required String beneficiaryId,
      required String requestType,
      required String status,
      Value<String?> details,
      Value<String> notes,
      required DateTime requestDate,
      Value<DateTime?> responseDate,
      Value<String?> respondedBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncState,
      Value<String?> serverId,
      Value<int> rowid,
    });
typedef $$DataRequestsTableUpdateCompanionBuilder =
    DataRequestsCompanion Function({
      Value<String> id,
      Value<String> beneficiaryId,
      Value<String> requestType,
      Value<String> status,
      Value<String?> details,
      Value<String> notes,
      Value<DateTime> requestDate,
      Value<DateTime?> responseDate,
      Value<String?> respondedBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncState,
      Value<String?> serverId,
      Value<int> rowid,
    });

class $$DataRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $DataRequestsTable> {
  $$DataRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respondedBy => $composableBuilder(
    column: $table.respondedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DataRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $DataRequestsTable> {
  $$DataRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respondedBy => $composableBuilder(
    column: $table.respondedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DataRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataRequestsTable> {
  $$DataRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get beneficiaryId => $composableBuilder(
    column: $table.beneficiaryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestType => $composableBuilder(
    column: $table.requestType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get requestDate => $composableBuilder(
    column: $table.requestDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get responseDate => $composableBuilder(
    column: $table.responseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get respondedBy => $composableBuilder(
    column: $table.respondedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);
}

class $$DataRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DataRequestsTable,
          DataRequest,
          $$DataRequestsTableFilterComposer,
          $$DataRequestsTableOrderingComposer,
          $$DataRequestsTableAnnotationComposer,
          $$DataRequestsTableCreateCompanionBuilder,
          $$DataRequestsTableUpdateCompanionBuilder,
          (
            DataRequest,
            BaseReferences<_$AppDatabase, $DataRequestsTable, DataRequest>,
          ),
          DataRequest,
          PrefetchHooks Function()
        > {
  $$DataRequestsTableTableManager(_$AppDatabase db, $DataRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> beneficiaryId = const Value.absent(),
                Value<String> requestType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> requestDate = const Value.absent(),
                Value<DateTime?> responseDate = const Value.absent(),
                Value<String?> respondedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DataRequestsCompanion(
                id: id,
                beneficiaryId: beneficiaryId,
                requestType: requestType,
                status: status,
                details: details,
                notes: notes,
                requestDate: requestDate,
                responseDate: responseDate,
                respondedBy: respondedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String beneficiaryId,
                required String requestType,
                required String status,
                Value<String?> details = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime requestDate,
                Value<DateTime?> responseDate = const Value.absent(),
                Value<String?> respondedBy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncState = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DataRequestsCompanion.insert(
                id: id,
                beneficiaryId: beneficiaryId,
                requestType: requestType,
                status: status,
                details: details,
                notes: notes,
                requestDate: requestDate,
                responseDate: responseDate,
                respondedBy: respondedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncState: syncState,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DataRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DataRequestsTable,
      DataRequest,
      $$DataRequestsTableFilterComposer,
      $$DataRequestsTableOrderingComposer,
      $$DataRequestsTableAnnotationComposer,
      $$DataRequestsTableCreateCompanionBuilder,
      $$DataRequestsTableUpdateCompanionBuilder,
      (
        DataRequest,
        BaseReferences<_$AppDatabase, $DataRequestsTable, DataRequest>,
      ),
      DataRequest,
      PrefetchHooks Function()
    >;

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
  $$CivilRegistryTableTableManager get civilRegistry =>
      $$CivilRegistryTableTableManager(_db, _db.civilRegistry);
  $$CivilRegistryCityTableTableManager get civilRegistryCity =>
      $$CivilRegistryCityTableTableManager(_db, _db.civilRegistryCity);
  $$CivilRegistryRelationsTableTableManager get civilRegistryRelations =>
      $$CivilRegistryRelationsTableTableManager(
        _db,
        _db.civilRegistryRelations,
      );
  $$CivilRegistryRelationCategoriesTableTableManager
  get civilRegistryRelationCategories =>
      $$CivilRegistryRelationCategoriesTableTableManager(
        _db,
        _db.civilRegistryRelationCategories,
      );
  $$CivilRegistryBirthCodeTableTableManager get civilRegistryBirthCode =>
      $$CivilRegistryBirthCodeTableTableManager(
        _db,
        _db.civilRegistryBirthCode,
      );
  $$CivilRegistryPersonalCodeTableTableManager get civilRegistryPersonalCode =>
      $$CivilRegistryPersonalCodeTableTableManager(
        _db,
        _db.civilRegistryPersonalCode,
      );
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$DataRequestsTableTableManager get dataRequests =>
      $$DataRequestsTableTableManager(_db, _db.dataRequests);
}
