import 'package:flutter/material.dart';
import 'animated_form_fields.dart';
import '../../pages/v2_form_helpers/widgets/inline_validation_message.dart';

/// 📚 Usage Examples for AnimatedFormField with Inline Validation
///
/// This file demonstrates how to use the enhanced AnimatedFormField
/// with real-time validation feedback.

class ValidationExamples extends StatefulWidget {
  const ValidationExamples({super.key});

  @override
  State<ValidationExamples> createState() => _ValidationExamplesState();
}

class _ValidationExamplesState extends State<ValidationExamples> {
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  String? _nationalIdValidation;
  ValidationLevel? _nationalIdLevel;
  bool _showNationalIdValidation = false;

  String? _phoneValidation;
  ValidationLevel? _phoneLevel;
  bool _showPhoneValidation = false;

  String? _nameValidation;
  ValidationLevel? _nameLevel;
  bool _showNameValidation = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateNationalId(String value) {
    setState(() {
      if (value.isEmpty) {
        _nationalIdValidation = null;
        _showNationalIdValidation = false;
      } else if (value.length != 18) {
        _nationalIdValidation = 'الرقم الوطني يجب أن يكون 18 رقماً';
        _nationalIdLevel = ValidationLevel.error;
        _showNationalIdValidation = true;
      } else if (!_isValidNationalId(value)) {
        _nationalIdValidation = 'الرقم الوطني غير صحيح';
        _nationalIdLevel = ValidationLevel.error;
        _showNationalIdValidation = true;
      } else {
        _nationalIdValidation = 'الرقم الوطني صحيح ✓';
        _nationalIdLevel = ValidationLevel.success;
        _showNationalIdValidation = true;
      }
    });
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneValidation = null;
        _showPhoneValidation = false;
      } else if (value.length != 11 || !value.startsWith('07')) {
        _phoneValidation = 'رقم الهاتف يجب أن يكون 11 رقماً (07XXXXXXXXX)';
        _phoneLevel = ValidationLevel.error;
        _showPhoneValidation = true;
      } else {
        _phoneValidation = 'رقم الهاتف صحيح ✓';
        _phoneLevel = ValidationLevel.success;
        _showPhoneValidation = true;
      }
    });
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameValidation = null;
        _showNameValidation = false;
      } else if (value.length < 2) {
        _nameValidation = 'الاسم يجب أن يكون على الأقل حرفين';
        _nameLevel = ValidationLevel.warning;
        _showNameValidation = true;
      } else if (value.length < 3) {
        _nameValidation = 'الاسم قصير نوعاً ما';
        _nameLevel = ValidationLevel.info;
        _showNameValidation = true;
      } else {
        _nameValidation = 'الاسم صحيح ✓';
        _nameLevel = ValidationLevel.success;
        _showNameValidation = true;
      }
    });
  }

  bool _isValidNationalId(String value) {
    // Simple check: only digits
    return RegExp(r'^\d+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: National ID with Error/Success validation
          const Text(
            'مثال 1: الرقم الوطني',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedFormField(
            controller: _nationalIdController,
            labelText: 'الرقم الوطني',
            hintText: 'أدخل 18 رقماً',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            onChanged: _validateNationalId,
            validationMessage: _nationalIdValidation,
            validationLevel: _nationalIdLevel,
            showValidation: _showNationalIdValidation,
          ),

          const SizedBox(height: 24),

          // Example 2: Phone number validation
          const Text(
            'مثال 2: رقم الهاتف',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedFormField(
            controller: _phoneController,
            labelText: 'رقم الهاتف',
            hintText: '07XXXXXXXXX',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            onChanged: _validatePhone,
            validationMessage: _phoneValidation,
            validationLevel: _phoneLevel,
            showValidation: _showPhoneValidation,
          ),

          const SizedBox(height: 24),

          // Example 3: Name with Info/Warning/Success
          const Text(
            'مثال 3: الاسم (تدرج التحذيرات)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedFormField(
            controller: _nameController,
            labelText: 'الاسم الأول',
            hintText: 'أدخل الاسم',
            prefixIcon: Icons.person,
            onChanged: _validateName,
            validationMessage: _nameValidation,
            validationLevel: _nameLevel,
            showValidation: _showNameValidation,
          ),

          const SizedBox(height: 32),

          // Static examples of all validation levels
          const Text(
            'أمثلة ثابتة لجميع المستويات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const InlineValidationMessage(
            message: 'تم التحقق بنجاح! البيانات صحيحة',
            level: ValidationLevel.success,
          ),

          const SizedBox(height: 8),

          const InlineValidationMessage(
            message: 'معلومة: يمكنك إضافة رقم هاتف ثاني اختياري',
            level: ValidationLevel.info,
          ),

          const SizedBox(height: 8),

          const InlineValidationMessage(
            message: 'تحذير: هذا الحقل موصى به ولكنه غير إلزامي',
            level: ValidationLevel.warning,
          ),

          const SizedBox(height: 8),

          const InlineValidationMessage(
            message: 'خطأ: هذا الحقل مطلوب ولا يمكن تركه فارغاً',
            level: ValidationLevel.error,
          ),
        ],
      ),
    );
  }
}

/// 🔧 Helper: Validation State Manager
///
/// Use this class to manage validation state for a field
class FieldValidationState {
  String? message;
  ValidationLevel? level;
  bool show;

  FieldValidationState({this.message, this.level, this.show = false});

  void setError(String msg) {
    message = msg;
    level = ValidationLevel.error;
    show = true;
  }

  void setWarning(String msg) {
    message = msg;
    level = ValidationLevel.warning;
    show = true;
  }

  void setInfo(String msg) {
    message = msg;
    level = ValidationLevel.info;
    show = true;
  }

  void setSuccess(String msg) {
    message = msg;
    level = ValidationLevel.success;
    show = true;
  }

  void clear() {
    message = null;
    level = null;
    show = false;
  }
}

/// 📝 Real-world Example: Beneficiary Form Field
class BeneficiaryFormExample extends StatefulWidget {
  const BeneficiaryFormExample({super.key});

  @override
  State<BeneficiaryFormExample> createState() => _BeneficiaryFormExampleState();
}

class _BeneficiaryFormExampleState extends State<BeneficiaryFormExample> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();

  final _firstNameValidation = FieldValidationState();
  final _lastNameValidation = FieldValidationState();
  final _nationalIdValidation = FieldValidationState();
  final _phoneValidation = FieldValidationState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نموذج مستفيد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedFormField(
            controller: _firstNameController,
            labelText: 'الاسم الأول *',
            prefixIcon: Icons.person,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _firstNameValidation.setError('الاسم الأول مطلوب');
                } else if (value.length < 2) {
                  _firstNameValidation.setWarning(
                    'الاسم يجب أن يكون على الأقل حرفين',
                  );
                } else {
                  _firstNameValidation.setSuccess('الاسم الأول صحيح ✓');
                }
              });
            },
            validationMessage: _firstNameValidation.message,
            validationLevel: _firstNameValidation.level,
            showValidation: _firstNameValidation.show,
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            controller: _lastNameController,
            labelText: 'اسم العائلة *',
            prefixIcon: Icons.family_restroom,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _lastNameValidation.setError('اسم العائلة مطلوب');
                } else {
                  _lastNameValidation.setSuccess('اسم العائلة صحيح ✓');
                }
              });
            },
            validationMessage: _lastNameValidation.message,
            validationLevel: _lastNameValidation.level,
            showValidation: _lastNameValidation.show,
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            controller: _nationalIdController,
            labelText: 'الرقم الوطني *',
            hintText: '18 رقماً',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _nationalIdValidation.clear();
                } else if (value.length != 18) {
                  _nationalIdValidation.setError(
                    'الرقم الوطني يجب أن يكون 18 رقماً',
                  );
                } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                  _nationalIdValidation.setError('الرقم الوطني غير صحيح');
                } else {
                  _nationalIdValidation.setSuccess('الرقم الوطني صحيح ✓');
                }
              });
            },
            validationMessage: _nationalIdValidation.message,
            validationLevel: _nationalIdValidation.level,
            showValidation: _nationalIdValidation.show,
          ),
          const SizedBox(height: 16),
          AnimatedFormField(
            controller: _phoneController,
            labelText: 'رقم الهاتف *',
            hintText: '07XXXXXXXXX',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _phoneValidation.setError('رقم الهاتف مطلوب');
                } else if (value.length != 11 || !value.startsWith('07')) {
                  _phoneValidation.setError(
                    'رقم الهاتف يجب أن يكون 11 رقماً (07XXXXXXXXX)',
                  );
                } else {
                  _phoneValidation.setSuccess('رقم الهاتف صحيح ✓');
                }
              });
            },
            validationMessage: _phoneValidation.message,
            validationLevel: _phoneValidation.level,
            showValidation: _phoneValidation.show,
          ),
        ],
      ),
    );
  }
}
