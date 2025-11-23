import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'field_dependency_system.dart';
import '../../../widgets/v2/animated_form_fields.dart';

/// 📚 Field Dependencies Examples
///
/// Demonstrates various use cases for the field dependency system

// ═══════════════════════════════════════════════════════════════════════
// Example 1: Basic Marital Status Dependency
// ═══════════════════════════════════════════════════════════════════════

class MaritalStatusExample extends StatefulWidget {
  const MaritalStatusExample({super.key});

  @override
  State<MaritalStatusExample> createState() => _MaritalStatusExampleState();
}

class _MaritalStatusExampleState extends State<MaritalStatusExample> {
  final _controller = FieldDependencyController();
  final _maritalStatusController = TextEditingController();
  final _spouseNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add dependency: Show spouse name field when marital status is 'متزوج'
    _controller.addDependency(DependencyScenarios.maritalStatusToSpouse());
  }

  @override
  void dispose() {
    _controller.dispose();
    _maritalStatusController.dispose();
    _spouseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال: الحالة الاجتماعية')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Marital Status Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الحالة الاجتماعية',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'أعزب', child: Text('أعزب')),
                DropdownMenuItem(value: 'عزباء', child: Text('عزباء')),
                DropdownMenuItem(value: 'متزوج', child: Text('متزوج')),
                DropdownMenuItem(value: 'متزوجة', child: Text('متزوجة')),
                DropdownMenuItem(value: 'مطلق', child: Text('مطلق')),
                DropdownMenuItem(value: 'مطلقة', child: Text('مطلقة')),
                DropdownMenuItem(value: 'أرمل', child: Text('أرمل')),
                DropdownMenuItem(value: 'أرملة', child: Text('أرملة')),
              ],
              onChanged: (value) {
                _controller.updateField('maritalStatus', value);
              },
            ),

            // Spouse Name (appears only when married)
            DependentField(
              fieldName: 'spouseName',
              controller: _controller,
              child: Column(
                children: [
                  DependencyIndicator(
                    fieldName: 'spouseName',
                    controller: _controller,
                    message: 'يرجى إدخال اسم الزوج/الزوجة الكامل',
                  ),
                  AnimatedFormField(
                    controller: _spouseNameController,
                    labelText: 'اسم الزوج/الزوجة',
                    onChanged: (value) {
                      _controller.updateField('spouseName', value);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Submit button with validation
            ElevatedButton(
              onPressed: () {
                final errors = _controller.validateAll();
                if (errors.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ جميع البيانات صحيحة')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ ${errors.values.first}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 2: Employment Status Dependencies
// ═══════════════════════════════════════════════════════════════════════

class EmploymentStatusExample extends StatefulWidget {
  const EmploymentStatusExample({super.key});

  @override
  State<EmploymentStatusExample> createState() =>
      _EmploymentStatusExampleState();
}

class _EmploymentStatusExampleState extends State<EmploymentStatusExample> {
  final _controller = FieldDependencyController();
  final _employerController = TextEditingController();
  final _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add multiple dependencies
    _controller.addDependencies([
      DependencyScenarios.employmentStatusToEmployer(),
      DependencyScenarios.employmentStatusToIncome(),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _employerController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال: حالة التوظيف')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employment Status
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'حالة التوظيف',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'موظف', child: Text('موظف')),
                DropdownMenuItem(value: 'موظفة', child: Text('موظفة')),
                DropdownMenuItem(value: 'عمل حر', child: Text('عمل حر')),
                DropdownMenuItem(
                  value: 'أعمال خاصة',
                  child: Text('أعمال خاصة'),
                ),
                DropdownMenuItem(value: 'عاطل', child: Text('عاطل عن العمل')),
                DropdownMenuItem(value: 'متقاعد', child: Text('متقاعد')),
                DropdownMenuItem(value: 'طالب', child: Text('طالب')),
              ],
              onChanged: (value) {
                _controller.updateField('employmentStatus', value);
              },
            ),

            // Employer Name (for employees only)
            DependentField(
              fieldName: 'employerName',
              controller: _controller,
              child: Column(
                children: [
                  DependencyIndicator(
                    fieldName: 'employerName',
                    controller: _controller,
                    message: 'اسم جهة العمل أو الشركة',
                  ),
                  AnimatedFormField(
                    controller: _employerController,
                    labelText: 'اسم جهة العمل',
                    onChanged: (value) {
                      _controller.updateField('employerName', value);
                    },
                  ),
                ],
              ),
            ),

            // Monthly Income (for all working statuses)
            DependentField(
              fieldName: 'monthlyIncome',
              controller: _controller,
              child: Column(
                children: [
                  DependencyIndicator(
                    fieldName: 'monthlyIncome',
                    controller: _controller,
                    message: 'الدخل الشهري بالدينار العراقي',
                  ),
                  AnimatedFormField(
                    controller: _incomeController,
                    labelText: 'الدخل الشهري (IQD)',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _controller.updateField('monthlyIncome', value);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Debug: Show visible fields
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحقول المرئية:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _controller.visibleFields.isEmpty
                            ? 'لا توجد حقول تابعة'
                            : _controller.visibleFields.join(', '),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 3: Disability Information
// ═══════════════════════════════════════════════════════════════════════

class DisabilityExample extends StatefulWidget {
  const DisabilityExample({super.key});

  @override
  State<DisabilityExample> createState() => _DisabilityExampleState();
}

class _DisabilityExampleState extends State<DisabilityExample> {
  final _controller = FieldDependencyController();
  final _disabilityTypeController = TextEditingController();
  final _disabilityPercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.addDependencies([
      DependencyScenarios.hasDisabilityToType(),
      DependencyScenarios.hasDisabilityToPercentage(),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _disabilityTypeController.dispose();
    _disabilityPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال: معلومات الإعاقة')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Has Disability Switch
            SwitchListTile(
              title: const Text('هل لديك إعاقة؟'),
              value: _controller.getFieldValue('hasDisability') ?? false,
              onChanged: (value) {
                setState(() {
                  _controller.updateField('hasDisability', value);
                });
              },
            ),

            // Disability Type
            DependentField(
              fieldName: 'disabilityType',
              controller: _controller,
              child: Column(
                children: [
                  DependencyIndicator(
                    fieldName: 'disabilityType',
                    controller: _controller,
                    message: 'حدد نوع الإعاقة من القائمة',
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'نوع الإعاقة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'حركية', child: Text('حركية')),
                      DropdownMenuItem(value: 'بصرية', child: Text('بصرية')),
                      DropdownMenuItem(value: 'سمعية', child: Text('سمعية')),
                      DropdownMenuItem(value: 'ذهنية', child: Text('ذهنية')),
                      DropdownMenuItem(value: 'متعددة', child: Text('متعددة')),
                    ],
                    onChanged: (value) {
                      _controller.updateField('disabilityType', value);
                    },
                  ),
                ],
              ),
            ),

            // Disability Percentage
            DependentField(
              fieldName: 'disabilityPercentage',
              controller: _controller,
              child: Column(
                children: [
                  DependencyIndicator(
                    fieldName: 'disabilityPercentage',
                    controller: _controller,
                    message: 'نسبة الإعاقة من 1 إلى 100',
                  ),
                  AnimatedFormField(
                    controller: _disabilityPercentageController,
                    labelText: 'نسبة الإعاقة (%)',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _controller.updateField('disabilityPercentage', value);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            ElevatedButton(
              onPressed: () {
                final errors = _controller.validateAll();
                if (errors.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ جميع البيانات صحيحة')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ ${errors.values.first}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Example 4: Complete Beneficiary Form with Multiple Dependencies
// ═══════════════════════════════════════════════════════════════════════

class CompleteBeneficiaryFormExample extends StatefulWidget {
  const CompleteBeneficiaryFormExample({super.key});

  @override
  State<CompleteBeneficiaryFormExample> createState() =>
      _CompleteBeneficiaryFormExampleState();
}

class _CompleteBeneficiaryFormExampleState
    extends State<CompleteBeneficiaryFormExample> {
  final _controller = FieldDependencyController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _spouseNameController = TextEditingController();
  final _employerController = TextEditingController();
  final _incomeController = TextEditingController();
  final _childrenCountController = TextEditingController();
  final _aidSourceController = TextEditingController();
  final _aidAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Add all common scenarios
    _controller.addDependencies(DependencyScenarios.getAllCommonScenarios());
  }

  @override
  void dispose() {
    _controller.dispose();
    _spouseNameController.dispose();
    _employerController.dispose();
    _incomeController.dispose();
    _childrenCountController.dispose();
    _aidSourceController.dispose();
    _aidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نموذج المستفيد الكامل'),
        actions: [
          // Show field count
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    '${_controller.visibleFields.length} حقل نشط',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Personal Info
              _buildSectionTitle('المعلومات الشخصية'),
              _buildMaritalStatusField(),
              _buildSpouseNameField(),

              SizedBox(height: 24.h),

              // Section 2: Employment
              _buildSectionTitle('معلومات التوظيف'),
              _buildEmploymentStatusField(),
              _buildEmployerField(),
              _buildIncomeField(),

              SizedBox(height: 24.h),

              // Section 3: Family
              _buildSectionTitle('معلومات العائلة'),
              _buildHasChildrenField(),
              _buildChildrenCountField(),

              SizedBox(height: 24.h),

              // Section 4: Aid
              _buildSectionTitle('المساعدات'),
              _buildReceivesAidField(),
              _buildAidSourceField(),
              _buildAidAmountField(),

              SizedBox(height: 32.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('حفظ البيانات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMaritalStatusField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'الحالة الاجتماعية',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'أعزب', child: Text('أعزب')),
        DropdownMenuItem(value: 'متزوج', child: Text('متزوج')),
        DropdownMenuItem(value: 'مطلق', child: Text('مطلق')),
        DropdownMenuItem(value: 'أرمل', child: Text('أرمل')),
      ],
      onChanged: (value) => _controller.updateField('maritalStatus', value),
    );
  }

  Widget _buildSpouseNameField() {
    return DependentField(
      fieldName: 'spouseName',
      controller: _controller,
      child: Column(
        children: [
          DependencyIndicator(
            fieldName: 'spouseName',
            controller: _controller,
            message: 'اسم الزوج/الزوجة مطلوب',
          ),
          AnimatedFormField(
            controller: _spouseNameController,
            labelText: 'اسم الزوج/الزوجة',
            onChanged: (value) => _controller.updateField('spouseName', value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentStatusField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'حالة التوظيف',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'موظف', child: Text('موظف')),
        DropdownMenuItem(value: 'عمل حر', child: Text('عمل حر')),
        DropdownMenuItem(value: 'عاطل', child: Text('عاطل')),
      ],
      onChanged: (value) => _controller.updateField('employmentStatus', value),
    );
  }

  Widget _buildEmployerField() {
    return DependentField(
      fieldName: 'employerName',
      controller: _controller,
      child: AnimatedFormField(
        controller: _employerController,
        labelText: 'اسم جهة العمل',
        onChanged: (value) => _controller.updateField('employerName', value),
      ),
    );
  }

  Widget _buildIncomeField() {
    return DependentField(
      fieldName: 'monthlyIncome',
      controller: _controller,
      child: AnimatedFormField(
        controller: _incomeController,
        labelText: 'الدخل الشهري',
        keyboardType: TextInputType.number,
        onChanged: (value) => _controller.updateField('monthlyIncome', value),
      ),
    );
  }

  Widget _buildHasChildrenField() {
    return SwitchListTile(
      title: const Text('هل لديك أطفال؟'),
      value: _controller.getFieldValue('hasChildren') ?? false,
      onChanged: (value) {
        setState(() => _controller.updateField('hasChildren', value));
      },
    );
  }

  Widget _buildChildrenCountField() {
    return DependentField(
      fieldName: 'childrenCount',
      controller: _controller,
      child: AnimatedFormField(
        controller: _childrenCountController,
        labelText: 'عدد الأطفال',
        keyboardType: TextInputType.number,
        onChanged: (value) => _controller.updateField('childrenCount', value),
      ),
    );
  }

  Widget _buildReceivesAidField() {
    return SwitchListTile(
      title: const Text('هل تتلقى مساعدات؟'),
      value: _controller.getFieldValue('receivesAid') ?? false,
      onChanged: (value) {
        setState(() => _controller.updateField('receivesAid', value));
      },
    );
  }

  Widget _buildAidSourceField() {
    return DependentField(
      fieldName: 'aidSource',
      controller: _controller,
      child: AnimatedFormField(
        controller: _aidSourceController,
        labelText: 'مصدر المساعدة',
        onChanged: (value) => _controller.updateField('aidSource', value),
      ),
    );
  }

  Widget _buildAidAmountField() {
    return DependentField(
      fieldName: 'aidAmount',
      controller: _controller,
      child: AnimatedFormField(
        controller: _aidAmountController,
        labelText: 'مبلغ المساعدة',
        keyboardType: TextInputType.number,
        onChanged: (value) => _controller.updateField('aidAmount', value),
      ),
    );
  }

  void _handleSubmit() {
    final errors = _controller.validateAll();

    if (errors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم حفظ البيانات بنجاح'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'عرض',
            textColor: Colors.white,
            onPressed: () {
              _showSummary();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: ${errors.values.first}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملخص البيانات'),
        content: SingleChildScrollView(
          child: Text(
            _controller.allValues.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
