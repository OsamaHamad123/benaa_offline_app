import '../entities/civil_registry_person.dart';

/// ⚡ Use Case: Autofill Form from Civil Registry
///
/// Takes civil registry data and fills the beneficiary form controllers.
/// Handles field mapping, validation, and provides undo functionality.
class AutofillFromCivilRegistryUseCase {
  /// Execute autofill operation
  ///
  /// Returns [AutofillResult] with filled fields count and undo data.
  AutofillResult execute({
    required CivilRegistryPerson person,
    required dynamic controllers, // BeneficiaryFormControllers
  }) {
    // Save current state for undo
    final undoData = _captureCurrentState(controllers);

    int filledCount = 0;

    // Fill name fields
    if (_fillIfEmpty(controllers.firstNameController, person.firstName)) {
      filledCount++;
    }
    if (_fillIfEmpty(controllers.fatherNameController, person.fatherName)) {
      filledCount++;
    }
    if (person.grandfatherName != null &&
        _fillIfEmpty(
          controllers.grandfatherNameController,
          person.grandfatherName!,
        )) {
      filledCount++;
    }
    if (_fillIfEmpty(controllers.lastNameController, person.lastName)) {
      filledCount++;
    }
    if (person.motherName != null &&
        _fillIfEmpty(controllers.motherNameController, person.motherName!)) {
      filledCount++;
    }

    // Fill national ID (always)
    controllers.nationalIdController.text = person.nationalId;
    filledCount++;

    // Fill birth date
    if (person.birthDate != null) {
      final formattedDate = _formatDate(person.birthDate!);
      if (_fillIfEmpty(controllers.birthDateController, formattedDate)) {
        filledCount++;
      }
    }

    // Fill gender
    if (person.gender != null && controllers.selectedGender == null) {
      controllers.selectedGender = person.gender;
      filledCount++;
    }

    // Fill address info if available
    if (person.address != null &&
        _fillIfEmpty(controllers.addressController, person.address!)) {
      filledCount++;
    }
    if (person.province != null && controllers.selectedProvince == null) {
      controllers.selectedProvince = _mapProvince(person.province!);
      filledCount++;
    }
    if (person.city != null && controllers.selectedCity == null) {
      controllers.selectedCity = _mapCity(person.city!);
      filledCount++;
    }

    return AutofillResult(
      filledFieldsCount: filledCount,
      undoData: undoData,
      person: person,
    );
  }

  /// Undo autofill operation
  void undo({
    required dynamic controllers, // BeneficiaryFormControllers
    required Map<String, dynamic> undoData,
  }) {
    controllers.firstNameController.text = undoData['firstName'] ?? '';
    controllers.fatherNameController.text = undoData['fatherName'] ?? '';
    controllers.grandfatherNameController.text =
        undoData['grandfatherName'] ?? '';
    controllers.lastNameController.text = undoData['lastName'] ?? '';
    controllers.motherNameController.text = undoData['motherName'] ?? '';
    controllers.nationalIdController.text = undoData['nationalId'] ?? '';
    controllers.birthDateController.text = undoData['birthDate'] ?? '';
    controllers.selectedGender = undoData['gender'];
    controllers.addressController.text = undoData['address'] ?? '';
    controllers.selectedProvince = undoData['province'];
    controllers.selectedCity = undoData['city'];
  }

  /// Fill field only if it's empty
  bool _fillIfEmpty(dynamic controller, String value) {
    if (controller.text.trim().isEmpty && value.isNotEmpty) {
      controller.text = value;
      return true;
    }
    return false;
  }

  /// Capture current form state for undo
  Map<String, dynamic> _captureCurrentState(dynamic controllers) {
    return {
      'firstName': controllers.firstNameController.text,
      'fatherName': controllers.fatherNameController.text,
      'grandfatherName': controllers.grandfatherNameController.text,
      'lastName': controllers.lastNameController.text,
      'motherName': controllers.motherNameController.text,
      'nationalId': controllers.nationalIdController.text,
      'birthDate': controllers.birthDateController.text,
      'gender': controllers.selectedGender,
      'address': controllers.addressController.text,
      'province': controllers.selectedProvince,
      'city': controllers.selectedCity,
    };
  }

  /// Format date to display string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Map province from civil registry to app format
  String? _mapProvince(String province) {
    // Map common province names to app values
    final provinceMap = {
      'دمشق': 'damascus',
      'ريف دمشق': 'rif_dimashq',
      'حلب': 'aleppo',
      'حمص': 'homs',
      'حماة': 'hama',
      'اللاذقية': 'latakia',
      'طرطوس': 'tartus',
      'إدلب': 'idlib',
      'درعا': 'daraa',
      'السويداء': 'suwayda',
      'القنيطرة': 'quneitra',
      'دير الزور': 'deir_ez_zor',
      'الرقة': 'raqqa',
      'الحسكة': 'hasakah',
    };

    return provinceMap[province];
  }

  /// Map city from civil registry to app format
  String? _mapCity(String city) {
    final cityMap = {
      'دمشق': 'damascus_city',
      'حلب': 'aleppo_city',
      'حمص': 'homs_city',
      'حماة': 'hama_city',
      'اللاذقية': 'latakia_city',
    };

    return cityMap[city] ?? 'other';
  }
}

/// 📋 Result of autofill operation
class AutofillResult {
  final int filledFieldsCount;
  final Map<String, dynamic> undoData;
  final CivilRegistryPerson person;

  const AutofillResult({
    required this.filledFieldsCount,
    required this.undoData,
    required this.person,
  });

  String get successMessage {
    return 'تم تعبئة $filledFieldsCount حقل تلقائياً';
  }
}
