import 'form_constants.dart';
import 'form_controllers.dart';

class PersonalProfileValidationResult {
  final List<String> criticalIssues;

  const PersonalProfileValidationResult({required this.criticalIssues});

  static const int totalCriticalFields = 5;

  bool get isComplete => criticalIssues.isEmpty;
  int get missingCriticalFields => criticalIssues.length;
  int get completedCriticalFields => totalCriticalFields - missingCriticalFields;
}

class PersonalProfileValidator {
  const PersonalProfileValidator._();

  static PersonalProfileValidationResult evaluate(
    BeneficiaryFormControllers controllers,
  ) {
    final nationalId = controllers.nationalIdController.text.trim();
    final firstName = controllers.firstNameController.text.trim();
    final fatherName = controllers.fatherNameController.text.trim();
    final lastName = controllers.lastNameController.text.trim();

    final criticalIssues = <String>[
      if (nationalId.isEmpty)
        'أدخل الرقم الوطني'
      else if (nationalId.length != FormConstants.nationalIdLength)
        'الرقم الوطني يجب أن يكون ${FormConstants.nationalIdLength} أرقام',
      if (firstName.isEmpty) 'أدخل الاسم الأول',
      if (fatherName.isEmpty) 'أدخل اسم الأب',
      if (lastName.isEmpty) 'أدخل اللقب',
      if (controllers.selectedGender == null) 'حدد الجنس',
    ];

    return PersonalProfileValidationResult(criticalIssues: criticalIssues);
  }

  static bool isComplete(BeneficiaryFormControllers controllers) {
    return evaluate(controllers).isComplete;
  }

  static bool hasValidNationalId(BeneficiaryFormControllers controllers) {
    return controllers.nationalIdController.text.trim().length == FormConstants.nationalIdLength;
  }
}
