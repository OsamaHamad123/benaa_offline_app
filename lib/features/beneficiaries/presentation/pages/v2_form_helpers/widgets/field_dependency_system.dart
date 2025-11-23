import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔗 Field Dependency System
///
/// Smart system to link form fields together with conditional logic
///
/// Features:
/// - Auto show/hide dependent fields
/// - Conditional validation
/// - Value propagation
/// - Multi-level dependencies
///
/// Usage:
/// ```dart
/// FieldDependencyController controller = FieldDependencyController();
///
/// controller.addDependency(
///   sourceField: 'maritalStatus',
///   dependentField: 'spouseName',
///   condition: (value) => value == 'متزوج',
/// );
/// ```

/// Dependency configuration
class FieldDependency {
  final String sourceField;
  final String dependentField;
  final bool Function(dynamic value) condition;
  final dynamic Function(dynamic sourceValue)? valueTransform;
  final String? Function(String? value)? validator;
  final bool required;
  final String? requiredMessage;

  const FieldDependency({
    required this.sourceField,
    required this.dependentField,
    required this.condition,
    this.valueTransform,
    this.validator,
    this.required = false,
    this.requiredMessage,
  });
}

/// Field dependency controller
class FieldDependencyController extends ChangeNotifier {
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, bool> _fieldVisibility = {};
  final Map<String, List<FieldDependency>> _dependencies = {};

  /// Add a dependency rule
  void addDependency(FieldDependency dependency) {
    if (!_dependencies.containsKey(dependency.sourceField)) {
      _dependencies[dependency.sourceField] = [];
    }
    _dependencies[dependency.sourceField]!.add(dependency);

    // Initialize visibility
    _fieldVisibility[dependency.dependentField] = false;
  }

  /// Add multiple dependencies
  void addDependencies(List<FieldDependency> dependencies) {
    for (var dep in dependencies) {
      addDependency(dep);
    }
  }

  /// Update field value and check dependencies
  void updateField(String fieldName, dynamic value) {
    final oldValue = _fieldValues[fieldName];
    _fieldValues[fieldName] = value;

    // Check if this change affects any dependent fields
    if (_dependencies.containsKey(fieldName)) {
      for (var dependency in _dependencies[fieldName]!) {
        final shouldShow = dependency.condition(value);
        final currentVisibility = _fieldVisibility[dependency.dependentField];

        if (shouldShow != currentVisibility) {
          _fieldVisibility[dependency.dependentField] = shouldShow;

          // Clear dependent field value when hiding
          if (!shouldShow) {
            _fieldValues[dependency.dependentField] = null;
          }

          // Transform and set value if needed
          if (shouldShow && dependency.valueTransform != null) {
            _fieldValues[dependency.dependentField] =
                dependency.valueTransform!(value);
          }

          notifyListeners();
        }
      }
    }

    if (oldValue != value) {
      notifyListeners();
    }
  }

  /// Check if field is visible
  bool isFieldVisible(String fieldName) {
    return _fieldVisibility[fieldName] ?? true;
  }

  /// Get field value
  dynamic getFieldValue(String fieldName) {
    return _fieldValues[fieldName];
  }

  /// Get all visible fields
  List<String> get visibleFields {
    return _fieldVisibility.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all field values
  Map<String, dynamic> get allValues => Map.from(_fieldValues);

  /// Validate all visible fields
  Map<String, String?> validateAll() {
    final errors = <String, String?>{};

    for (var sourceField in _dependencies.keys) {
      for (var dependency in _dependencies[sourceField]!) {
        if (isFieldVisible(dependency.dependentField)) {
          // Check required
          if (dependency.required) {
            final value = _fieldValues[dependency.dependentField];
            if (value == null || value.toString().isEmpty) {
              errors[dependency.dependentField] =
                  dependency.requiredMessage ?? 'هذا الحقل مطلوب';
            }
          }

          // Custom validator
          if (dependency.validator != null) {
            final value = _fieldValues[dependency.dependentField];
            final error = dependency.validator!(value?.toString());
            if (error != null) {
              errors[dependency.dependentField] = error;
            }
          }
        }
      }
    }

    return errors;
  }

  /// Clear all dependencies
  void clear() {
    _fieldValues.clear();
    _fieldVisibility.clear();
    _dependencies.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}

/// Animated field wrapper with dependency support
class DependentField extends StatelessWidget {
  final String fieldName;
  final FieldDependencyController controller;
  final Widget child;
  final Duration animationDuration;

  const DependentField({
    super.key,
    required this.fieldName,
    required this.controller,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isVisible = controller.isFieldVisible(fieldName);

        return AnimatedSize(
          duration: animationDuration,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: animationDuration,
            child: isVisible
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Pre-configured dependency scenarios
class DependencyScenarios {
  DependencyScenarios._();

  /// Marital status → Spouse name
  static FieldDependency maritalStatusToSpouse() {
    return FieldDependency(
      sourceField: 'maritalStatus',
      dependentField: 'spouseName',
      condition: (value) => value == 'متزوج' || value == 'متزوجة',
      required: true,
      requiredMessage: 'اسم الزوج/الزوجة مطلوب للمتزوجين',
    );
  }

  /// Employment status → Employer name
  static FieldDependency employmentStatusToEmployer() {
    return FieldDependency(
      sourceField: 'employmentStatus',
      dependentField: 'employerName',
      condition: (value) => value == 'موظف' || value == 'موظفة',
      required: true,
      requiredMessage: 'اسم جهة العمل مطلوب للموظفين',
    );
  }

  /// Employment status → Monthly income
  static FieldDependency employmentStatusToIncome() {
    return FieldDependency(
      sourceField: 'employmentStatus',
      dependentField: 'monthlyIncome',
      condition: (value) =>
          value == 'موظف' ||
          value == 'موظفة' ||
          value == 'عمل حر' ||
          value == 'أعمال خاصة',
      validator: (value) {
        if (value == null || value.isEmpty) return 'الدخل الشهري مطلوب';
        final income = int.tryParse(value);
        if (income == null) return 'أدخل رقماً صحيحاً';
        if (income < 0) return 'الدخل لا يمكن أن يكون سالباً';
        if (income > 10000000) return 'الرقم كبير جداً';
        return null;
      },
    );
  }

  /// Has disability → Disability type
  static FieldDependency hasDisabilityToType() {
    return FieldDependency(
      sourceField: 'hasDisability',
      dependentField: 'disabilityType',
      condition: (value) => value == true || value == 'نعم',
      required: true,
      requiredMessage: 'يرجى تحديد نوع الإعاقة',
    );
  }

  /// Has disability → Disability percentage
  static FieldDependency hasDisabilityToPercentage() {
    return FieldDependency(
      sourceField: 'hasDisability',
      dependentField: 'disabilityPercentage',
      condition: (value) => value == true || value == 'نعم',
      validator: (value) {
        if (value == null || value.isEmpty) return 'نسبة الإعاقة مطلوبة';
        final percentage = int.tryParse(value);
        if (percentage == null) return 'أدخل رقماً صحيحاً';
        if (percentage < 1 || percentage > 100) return 'النسبة بين 1-100';
        return null;
      },
    );
  }

  /// Owns house → House type
  static FieldDependency ownsHouseToType() {
    return FieldDependency(
      sourceField: 'ownsHouse',
      dependentField: 'houseType',
      condition: (value) => value == true || value == 'نعم',
      required: true,
      requiredMessage: 'يرجى تحديد نوع المنزل',
    );
  }

  /// Owns house → House area
  static FieldDependency ownsHouseToArea() {
    return FieldDependency(
      sourceField: 'ownsHouse',
      dependentField: 'houseArea',
      condition: (value) => value == true || value == 'نعم',
      validator: (value) {
        if (value == null || value.isEmpty) return null; // Optional
        final area = double.tryParse(value);
        if (area == null) return 'أدخل رقماً صحيحاً';
        if (area < 10) return 'المساحة صغيرة جداً';
        if (area > 1000) return 'المساحة كبيرة جداً';
        return null;
      },
    );
  }

  /// Has children → Number of children
  static FieldDependency hasChildrenToCount() {
    return FieldDependency(
      sourceField: 'hasChildren',
      dependentField: 'childrenCount',
      condition: (value) => value == true || value == 'نعم',
      required: true,
      requiredMessage: 'عدد الأطفال مطلوب',
      validator: (value) {
        if (value == null || value.isEmpty) return 'عدد الأطفال مطلوب';
        final count = int.tryParse(value);
        if (count == null) return 'أدخل رقماً صحيحاً';
        if (count < 1) return 'على الأقل طفل واحد';
        if (count > 20) return 'العدد كبير جداً';
        return null;
      },
    );
  }

  /// Receives aid → Aid source
  static FieldDependency receivesAidToSource() {
    return FieldDependency(
      sourceField: 'receivesAid',
      dependentField: 'aidSource',
      condition: (value) => value == true || value == 'نعم',
      required: true,
      requiredMessage: 'مصدر المساعدة مطلوب',
    );
  }

  /// Receives aid → Aid amount
  static FieldDependency receivesAidToAmount() {
    return FieldDependency(
      sourceField: 'receivesAid',
      dependentField: 'aidAmount',
      condition: (value) => value == true || value == 'نعم',
      validator: (value) {
        if (value == null || value.isEmpty) return null; // Optional
        final amount = int.tryParse(value);
        if (amount == null) return 'أدخل رقماً صحيحاً';
        if (amount < 0) return 'المبلغ لا يمكن أن يكون سالباً';
        return null;
      },
    );
  }

  /// Get all common scenarios
  static List<FieldDependency> getAllCommonScenarios() {
    return [
      maritalStatusToSpouse(),
      employmentStatusToEmployer(),
      employmentStatusToIncome(),
      hasDisabilityToType(),
      hasDisabilityToPercentage(),
      ownsHouseToType(),
      ownsHouseToArea(),
      hasChildrenToCount(),
      receivesAidToSource(),
      receivesAidToAmount(),
    ];
  }
}

/// Visual indicator for required dependent fields
class DependencyIndicator extends StatelessWidget {
  final String fieldName;
  final FieldDependencyController controller;
  final String message;

  const DependencyIndicator({
    super.key,
    required this.fieldName,
    required this.controller,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isVisible = controller.isFieldVisible(fieldName);

        if (!isVisible) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
