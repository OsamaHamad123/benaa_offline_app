import 'package:equatable/equatable.dart';

class BeneficiaryFormState extends Equatable {
  final String fullName;
  final String nationalId;
  final String fileNo;
  final String governorate;
  final String gender;
  final String category;
  final DateTime? birthDate;
  final String notes;

  // Additional fields
  final String phoneNumber;
  final String address;
  final String motherName;
  final String fatherName;
  final String district;
  final String associationName;
  final String grandFatherName;
  final String familyName;
  final String altPhoneNumber;
  final String addressBeforeDisplacement;
  final String currentAddress;

  final int familySize;
  final String maritalStatus;
  final String educationLevel;
  final String healthStatus;
  final bool hasDisability;

  final int? displacementStatus;
  final int? numberOfMales;
  final int? numberOfFemales;
  final int chronicDiseasesCount;
  final int specialNeedsCount;
  final int? employmentStatus;
  final int? housingStatus;
  final int? housingType;
  final int? requestStatus;

  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  const BeneficiaryFormState({
    this.fullName = '',
    this.nationalId = '',
    this.fileNo = '',
    this.governorate = 'بغداد',
    this.gender = 'male',
    this.category = 'orphan',
    this.birthDate,
    this.notes = '',
    this.phoneNumber = '',
    this.address = '',
    this.motherName = '',
    this.fatherName = '',
    this.district = '',
    this.associationName = '',
    this.grandFatherName = '',
    this.familyName = '',
    this.altPhoneNumber = '',
    this.addressBeforeDisplacement = '',
    this.currentAddress = '',
    this.familySize = 1,
    this.maritalStatus = 'single',
    this.educationLevel = 'none',
    this.healthStatus = 'good',
    this.hasDisability = false,
    this.displacementStatus,
    this.numberOfMales,
    this.numberOfFemales,
    this.chronicDiseasesCount = 0,
    this.specialNeedsCount = 0,
    this.employmentStatus,
    this.housingStatus,
    this.housingType,
    this.requestStatus,
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  BeneficiaryFormState copyWith({
    String? fullName,
    String? nationalId,
    String? fileNo,
    String? governorate,
    String? gender,
    String? category,
    DateTime? birthDate,
    String? notes,
    String? phoneNumber,
    String? address,
    String? motherName,
    String? fatherName,
    String? district,
    String? associationName,
    String? grandFatherName,
    String? familyName,
    String? altPhoneNumber,
    String? addressBeforeDisplacement,
    String? currentAddress,
    int? familySize,
    String? maritalStatus,
    String? educationLevel,
    String? healthStatus,
    bool? hasDisability,
    int? displacementStatus,
    int? numberOfMales,
    int? numberOfFemales,
    int? chronicDiseasesCount,
    int? specialNeedsCount,
    int? employmentStatus,
    int? housingStatus,
    int? housingType,
    int? requestStatus,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
  }) {
    return BeneficiaryFormState(
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      fileNo: fileNo ?? this.fileNo,
      governorate: governorate ?? this.governorate,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      district: district ?? this.district,
      associationName: associationName ?? this.associationName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      familyName: familyName ?? this.familyName,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      addressBeforeDisplacement:
          addressBeforeDisplacement ?? this.addressBeforeDisplacement,
      currentAddress: currentAddress ?? this.currentAddress,
      familySize: familySize ?? this.familySize,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      healthStatus: healthStatus ?? this.healthStatus,
      hasDisability: hasDisability ?? this.hasDisability,
      displacementStatus: displacementStatus ?? this.displacementStatus,
      numberOfMales: numberOfMales ?? this.numberOfMales,
      numberOfFemales: numberOfFemales ?? this.numberOfFemales,
      chronicDiseasesCount: chronicDiseasesCount ?? this.chronicDiseasesCount,
      specialNeedsCount: specialNeedsCount ?? this.specialNeedsCount,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      housingStatus: housingStatus ?? this.housingStatus,
      housingType: housingType ?? this.housingType,
      requestStatus: requestStatus ?? this.requestStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    nationalId,
    fileNo,
    governorate,
    gender,
    category,
    birthDate,
    notes,
    phoneNumber,
    address,
    motherName,
    fatherName,
    district,
    associationName,
    grandFatherName,
    familyName,
    altPhoneNumber,
    addressBeforeDisplacement,
    currentAddress,
    familySize,
    maritalStatus,
    educationLevel,
    healthStatus,
    hasDisability,
    displacementStatus,
    numberOfMales,
    numberOfFemales,
    chronicDiseasesCount,
    specialNeedsCount,
    employmentStatus,
    housingStatus,
    housingType,
    requestStatus,
    isLoading,
    errorMessage,
    isSaved,
  ];
}
