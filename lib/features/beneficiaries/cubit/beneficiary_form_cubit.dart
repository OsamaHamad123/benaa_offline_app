import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../data/db/drift_database.dart';
import '../../../core/services/activity_logger.dart';
import 'beneficiary_form_state.dart';

class BeneficiaryFormCubit extends Cubit<BeneficiaryFormState> {
  final AppDatabase database;
  final String? beneficiaryId;

  BeneficiaryFormCubit({required this.database, this.beneficiaryId})
    : super(const BeneficiaryFormState()) {
    if (beneficiaryId != null) {
      _loadBeneficiary();
    }
  }

  Future<void> _loadBeneficiary() async {
    emit(state.copyWith(isLoading: true));

    try {
      final beneficiary = await database.getBeneficiaryById(beneficiaryId!);

      if (beneficiary != null) {
        emit(
          BeneficiaryFormState(
            fullName: beneficiary.fullName,
            nationalId: beneficiary.nationalId,
            fileNo: beneficiary.fileNo,
            governorate: beneficiary.governorate,
            gender: beneficiary.gender,
            category: beneficiary.category,
            birthDate: beneficiary.birthDate,
            notes: beneficiary.notes,
            phoneNumber: beneficiary.phoneNumber ?? '',
            address: beneficiary.address ?? '',
            motherName: beneficiary.motherName ?? '',
            fatherName: beneficiary.fatherName ?? '',
            district: beneficiary.district ?? '',
            associationName: beneficiary.associationName ?? '',
            grandFatherName: beneficiary.grandFatherName ?? '',
            familyName: beneficiary.familyName ?? '',
            altPhoneNumber: beneficiary.altPhoneNumber ?? '',
            addressBeforeDisplacement:
                beneficiary.addressBeforeDisplacement ?? '',
            currentAddress: beneficiary.currentAddress ?? '',
            familySize: beneficiary.familySize ?? 1,
            maritalStatus: beneficiary.maritalStatus ?? 'single',
            educationLevel: beneficiary.educationLevel ?? 'none',
            healthStatus: beneficiary.healthStatus ?? 'good',
            hasDisability: beneficiary.hasDisability,
            displacementStatus: beneficiary.displacementStatus,
            numberOfMales: beneficiary.numberOfMales,
            numberOfFemales: beneficiary.numberOfFemales,
            chronicDiseasesCount: beneficiary.chronicDiseasesCount ?? 0,
            specialNeedsCount: beneficiary.specialNeedsCount ?? 0,
            employmentStatus: beneficiary.employmentStatus,
            housingStatus: beneficiary.housingStatus,
            housingType: beneficiary.housingType,
            requestStatus: beneficiary.requestStatus,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في تحميل البيانات: ${e.toString()}',
        ),
      );
    }
  }

  void updateFullName(String value) => emit(state.copyWith(fullName: value));
  void updateNationalId(String value) =>
      emit(state.copyWith(nationalId: value));
  void updateFileNo(String value) => emit(state.copyWith(fileNo: value));
  void updateGovernorate(String value) =>
      emit(state.copyWith(governorate: value));
  void updateGender(String value) => emit(state.copyWith(gender: value));
  void updateCategory(String value) => emit(state.copyWith(category: value));
  void updateBirthDate(DateTime? value) =>
      emit(state.copyWith(birthDate: value));
  void updateNotes(String value) => emit(state.copyWith(notes: value));
  void updatePhoneNumber(String value) =>
      emit(state.copyWith(phoneNumber: value));
  void updateAddress(String value) => emit(state.copyWith(address: value));
  void updateMotherName(String value) =>
      emit(state.copyWith(motherName: value));
  void updateFatherName(String value) =>
      emit(state.copyWith(fatherName: value));
  void updateDistrict(String value) => emit(state.copyWith(district: value));
  void updateAssociationName(String value) =>
      emit(state.copyWith(associationName: value));
  void updateGrandFatherName(String value) =>
      emit(state.copyWith(grandFatherName: value));
  void updateFamilyName(String value) =>
      emit(state.copyWith(familyName: value));
  void updateAltPhoneNumber(String value) =>
      emit(state.copyWith(altPhoneNumber: value));
  void updateAddressBeforeDisplacement(String value) =>
      emit(state.copyWith(addressBeforeDisplacement: value));
  void updateCurrentAddress(String value) =>
      emit(state.copyWith(currentAddress: value));
  void updateFamilySize(int value) => emit(state.copyWith(familySize: value));
  void updateMaritalStatus(String value) =>
      emit(state.copyWith(maritalStatus: value));
  void updateEducationLevel(String value) =>
      emit(state.copyWith(educationLevel: value));
  void updateHealthStatus(String value) =>
      emit(state.copyWith(healthStatus: value));
  void updateHasDisability(bool value) =>
      emit(state.copyWith(hasDisability: value));
  void updateDisplacementStatus(int? value) =>
      emit(state.copyWith(displacementStatus: value));
  void updateNumberOfMales(int? value) =>
      emit(state.copyWith(numberOfMales: value));
  void updateNumberOfFemales(int? value) =>
      emit(state.copyWith(numberOfFemales: value));
  void updateChronicDiseasesCount(int value) =>
      emit(state.copyWith(chronicDiseasesCount: value));
  void updateSpecialNeedsCount(int value) =>
      emit(state.copyWith(specialNeedsCount: value));
  void updateEmploymentStatus(int? value) =>
      emit(state.copyWith(employmentStatus: value));
  void updateHousingStatus(int? value) =>
      emit(state.copyWith(housingStatus: value));
  void updateHousingType(int? value) =>
      emit(state.copyWith(housingType: value));
  void updateRequestStatus(int? value) =>
      emit(state.copyWith(requestStatus: value));

  Future<bool> saveBeneficiary() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final now = DateTime.now();
      final isEdit = beneficiaryId != null;
      final id = isEdit ? beneficiaryId! : const Uuid().v4();

      final beneficiary = BeneficiariesCompanion(
        id: drift.Value(id),
        fullName: drift.Value(state.fullName.trim()),
        fullNameNorm: drift.Value(state.fullName.trim().toLowerCase()),
        nationalId: drift.Value(state.nationalId.trim()),
        fileNo: drift.Value(state.fileNo.trim()),
        governorate: drift.Value(state.governorate),
        gender: drift.Value(state.gender),
        category: drift.Value(state.category),
        birthDate: drift.Value(state.birthDate),
        notes: drift.Value(state.notes.trim()),
        phoneNumber: drift.Value(state.phoneNumber.trim()),
        address: drift.Value(state.address.trim()),
        motherName: drift.Value(state.motherName.trim()),
        fatherName: drift.Value(state.fatherName.trim()),
        district: drift.Value(state.district.trim()),
        associationName: drift.Value(state.associationName.trim()),
        grandFatherName: drift.Value(state.grandFatherName.trim()),
        familyName: drift.Value(state.familyName.trim()),
        altPhoneNumber: drift.Value(state.altPhoneNumber.trim()),
        addressBeforeDisplacement: drift.Value(
          state.addressBeforeDisplacement.trim(),
        ),
        currentAddress: drift.Value(state.currentAddress.trim()),
        familySize: drift.Value(state.familySize),
        maritalStatus: drift.Value(state.maritalStatus),
        educationLevel: drift.Value(state.educationLevel),
        healthStatus: drift.Value(state.healthStatus),
        hasDisability: drift.Value(state.hasDisability),
        displacementStatus: drift.Value(state.displacementStatus),
        numberOfMales: drift.Value(state.numberOfMales),
        numberOfFemales: drift.Value(state.numberOfFemales),
        chronicDiseasesCount: drift.Value(state.chronicDiseasesCount),
        specialNeedsCount: drift.Value(state.specialNeedsCount),
        employmentStatus: drift.Value(state.employmentStatus),
        housingStatus: drift.Value(state.housingStatus),
        housingType: drift.Value(state.housingType),
        requestStatus: drift.Value(state.requestStatus),
        createdAt: isEdit ? const drift.Value.absent() : drift.Value(now),
        updatedAt: drift.Value(now),
        syncState: const drift.Value('pending'),
      );

      await database
          .into(database.beneficiaries)
          .insertOnConflictUpdate(beneficiary);

      // Log activity
      if (isEdit) {
        await ActivityLogger.logEdit(id, state.fullName.trim());
      } else {
        await ActivityLogger.logAdd(id, state.fullName.trim());
      }

      emit(state.copyWith(isLoading: false, isSaved: true));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في حفظ البيانات: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  String? validateForm() {
    if (state.fullName.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    if (state.fullName.trim().split(' ').length < 2) {
      return 'الرجاء إدخال اسمين على الأقل';
    }
    if (state.nationalId.trim().isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }
    if (state.fileNo.trim().isEmpty) {
      return 'الرجاء إدخال رقم الملف';
    }
    return null;
  }
}
