import 'package:flutter/foundation.dart';

import 'form_controllers.dart';

class CivilRegistryFillResult {
  final int filledFieldsCount;

  const CivilRegistryFillResult({required this.filledFieldsCount});

  bool get hasFilledFields => filledFieldsCount > 0;
}

class FormCivilRegistryFillHelper {
  static CivilRegistryFillResult apply({
    required BeneficiaryFormControllers controllers,
    required Map<String, dynamic> data,
    void Function(String message)? logger,
    bool enableLogging = kDebugMode,
  }) {
    void log(String message) {
      if (enableLogging && logger != null) {
        logger(message);
      }
    }

    int filledFieldsCount = 0;
    log('🔄 Starting to fill form with data: $data');

    controllers.pauseNotifications();
    try {
      final fullName = _safeText(data['name']);
      if (fullName != null) {
        log('📝 Filling name: $fullName');
        final nameParts =
            fullName.split(RegExp(r'\s+')).where((part) => part.trim().isNotEmpty).toList(growable: false);

        if (nameParts.isNotEmpty) {
          controllers.firstNameController.text = nameParts[0];
          filledFieldsCount++;
        }
        if (nameParts.length > 1) {
          controllers.fatherNameController.text = nameParts[1];
          filledFieldsCount++;
        }
        if (nameParts.length > 2) {
          controllers.grandfatherNameController.text = nameParts[2];
          filledFieldsCount++;
        }
        if (nameParts.length > 3) {
          controllers.lastNameController.text = nameParts.sublist(3).join(' ');
          filledFieldsCount++;
        }
      }

      final nationalId = _safeText(data['nationalId']);
      if (nationalId != null) {
        controllers.nationalIdController.text = nationalId;
        filledFieldsCount++;
      }

      final gender = _safeText(data['gender']);
      if (gender != null) {
        controllers.selectedGender = gender;
        filledFieldsCount++;
      }

      final motherName = _safeText(data['motherName']);
      if (motherName != null) {
        controllers.motherNameController.text = motherName;
        filledFieldsCount++;
      }

      final birthDate = _safeText(data['birthDate']);
      if (birthDate != null) {
        controllers.birthDateController.text = birthDate;
        filledFieldsCount++;
      }

      final city = _safeText(data['city']);
      final governorate = _safeText(data['governorate']);

      if (city != null || governorate != null) {
        final addressParts = <String>[];
        if (governorate != null) {
          addressParts.add(governorate);
          controllers.selectedProvince = governorate;
        }
        if (city != null) {
          addressParts.add(city);
          controllers.selectedCity = city;
        }
        if (addressParts.isNotEmpty) {
          controllers.addressController.text = addressParts.join(' - ');
        }
      }
    } finally {
      controllers.resumeNotifications();
    }

    log('✅ Successfully filled $filledFieldsCount fields from civil registry');
    return CivilRegistryFillResult(filledFieldsCount: filledFieldsCount);
  }

  static String? _safeText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
