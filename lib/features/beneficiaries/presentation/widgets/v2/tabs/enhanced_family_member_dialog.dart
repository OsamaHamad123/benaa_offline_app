import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_dimensions.dart';

/// 🎨 Enhanced Family Member Dialog - Wizard Style
///
/// ✨ تصميم جديد مع Stepper:
/// - Step 1: المعلومات الأساسية (الاسم، الرقم الوطني)
/// - Step 2: معلومات إضافية (تاريخ الوفاة/الميلاد، الحالة الصحية)
/// - Step 3: مراجعة وحفظ
class EnhancedFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const EnhancedFamilyMemberDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  State<EnhancedFamilyMemberDialog> createState() =>
      _EnhancedFamilyMemberDialogState();
}

class _EnhancedFamilyMemberDialogState
    extends State<EnhancedFamilyMemberDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _thirdNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _notesController;

  // Data
  int _selectedGender = 1;
  DateTime? _selectedDate; // birth or death date
  int? _healthStatus; // للأيتام فقط
  int? _deathCause; // للمتوفيين فقط
  int? _documentType; // للمتوفيين فقط

  @override
  void initState() {
    super.initState();
    final m = widget.existingMember;

    _firstNameController = TextEditingController(text: m?['firstName']);
    _secondNameController = TextEditingController(text: m?['secondName']);
    _thirdNameController = TextEditingController(text: m?['thirdName']);
    _familyNameController = TextEditingController(text: m?['familyName']);
    _nationalIdController = TextEditingController(
      text: m?['nationalId']?.toString() ?? m?['orphanNationalId']?.toString(),
    );
    _notesController = TextEditingController(text: m?['notes']);

    _selectedGender = m?['gender'] ?? 1;
    _selectedDate =
        m?['birthDate'] as DateTime? ?? m?['deathDate'] as DateTime?;
    _healthStatus = m?['healthStatus'];
    _deathCause = m?['deathCause'];
    _documentType = m?['documentType'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Step> _buildSteps() {
    return [
      // Step 1: المعلومات الأساسية
      Step(
        title: const Text('المعلومات الأساسية'),
        subtitle: const Text('الاسم والهوية'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: _buildBasicInfoStep(),
      ),

      // Step 2: معلومات إضافية
      Step(
        title: const Text('معلومات إضافية'),
        subtitle: Text(
          widget.isDeceased ? 'تاريخ وسبب الوفاة' : 'العمر والصحة',
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: _buildAdditionalInfoStep(),
      ),

      // Step 3: المراجعة
      Step(
        title: const Text('مراجعة'),
        subtitle: const Text('التأكد من البيانات'),
        isActive: _currentStep >= 2,
        state: StepState.indexed,
        content: _buildReviewStep(),
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الاسم الأول
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'الاسم الأول *',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppDimensions.md12),

        // اسم الأب
        TextFormField(
          controller: _secondNameController,
          decoration: InputDecoration(
            labelText: 'اسم الأب',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppDimensions.md12),

        // اسم الجد
        TextFormField(
          controller: _thirdNameController,
          decoration: InputDecoration(
            labelText: 'اسم الجد',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppDimensions.md12),

        // اسم العائلة
        TextFormField(
          controller: _familyNameController,
          decoration: InputDecoration(
            labelText: 'اسم العائلة *',
            prefixIcon: const Icon(Icons.family_restroom),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppDimensions.md12),

        // الرقم الوطني
        TextFormField(
          controller: _nationalIdController,
          decoration: InputDecoration(
            labelText: 'الرقم الوطني *',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            helperText: '9 أرقام',
          ),
          keyboardType: TextInputType.number,
          maxLength: 9,
          validator: (v) {
            if (v?.trim().isEmpty ?? true) return 'مطلوب';
            if (v!.length != 9) return 'يجب أن يكون 9 أرقام';
            return null;
          },
        ),
        SizedBox(height: AppDimensions.md12),

        // الجنس
        Text(
          'الجنس *',
          style: TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'ذكر',
                icon: Icons.boy,
                value: 1,
                groupValue: _selectedGender,
                onSelected: (v) => setState(() => _selectedGender = v),
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildChoiceChip(
                label: 'أنثى',
                icon: Icons.girl,
                value: 2,
                groupValue: _selectedGender,
                onSelected: (v) => setState(() => _selectedGender = v),
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
    if (widget.isDeceased) {
      return _buildDeceasedAdditionalInfo();
    } else {
      return _buildOrphanAdditionalInfo();
    }
  }

  Widget _buildDeceasedAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تاريخ الوفاة
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today, color: Colors.red),
          title: const Text('تاريخ الوفاة'),
          subtitle: Text(
            _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'اضغط للاختيار',
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        SizedBox(height: AppDimensions.md),

        // سبب الوفاة
        Text(
          'سبب الوفاة',
          style: TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildChoiceChip(
              label: 'طبيعية',
              icon: Icons.favorite,
              value: 1,
              groupValue: _deathCause,
              onSelected: (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              label: 'مرض',
              icon: Icons.local_hospital,
              value: 2,
              groupValue: _deathCause,
              onSelected: (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              label: 'حادث',
              icon: Icons.car_crash,
              value: 4,
              groupValue: _deathCause,
              onSelected: (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              label: 'مغدور',
              icon: Icons.dangerous,
              value: 7,
              groupValue: _deathCause,
              onSelected: (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              label: 'أخرى',
              icon: Icons.help_outline,
              value: 5,
              groupValue: _deathCause,
              onSelected: (v) => setState(() => _deathCause = v),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.md),

        // نوع الوثيقة
        Text(
          'الوثيقة',
          style: TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'شهادة وفاة',
                icon: Icons.description,
                value: 1,
                groupValue: _documentType,
                onSelected: (v) => setState(() => _documentType = v),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildChoiceChip(
                label: 'إفادة شهيد',
                icon: Icons.military_tech,
                value: 2,
                groupValue: _documentType,
                onSelected: (v) => setState(() => _documentType = v),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.md),

        // ملاحظات
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'ملاحظات',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildOrphanAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تاريخ الميلاد
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cake, color: Colors.green),
          title: const Text('تاريخ الميلاد'),
          subtitle: Text(
            _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : 'اضغط للاختيار',
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  _selectedDate ??
                  DateTime.now().subtract(const Duration(days: 365 * 5)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        SizedBox(height: AppDimensions.md),

        // الحالة الصحية
        Text(
          'الحالة الصحية',
          style: TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildChoiceChip(
              label: 'سليم',
              icon: Icons.check_circle,
              value: 1,
              groupValue: _healthStatus,
              onSelected: (v) => setState(() => _healthStatus = v),
              color: Colors.green,
            ),
            _buildChoiceChip(
              label: 'مريض',
              icon: Icons.sick,
              value: 2,
              groupValue: _healthStatus,
              onSelected: (v) => setState(() => _healthStatus = v),
              color: Colors.orange,
            ),
            _buildChoiceChip(
              label: 'مريض مزمن',
              icon: Icons.medical_services,
              value: 3,
              groupValue: _healthStatus,
              onSelected: (v) => setState(() => _healthStatus = v),
              color: Colors.red,
            ),
            _buildChoiceChip(
              label: 'معاق',
              icon: Icons.accessible,
              value: 4,
              groupValue: _healthStatus,
              onSelected: (v) => setState(() => _healthStatus = v),
              color: Colors.purple,
            ),
          ],
        ),
        SizedBox(height: AppDimensions.md),

        // ملاحظات
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'ملاحظات',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final fullName =
        '${_firstNameController.text} ${_secondNameController.text} ${_thirdNameController.text} ${_familyNameController.text}'
            .trim();

    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
      child: Padding(
        padding: AppDimensions.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue, size: 32.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'مراجعة البيانات',
                    style: TextStyle(
                      fontSize: AppDimensions.fontXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24.h),
            _buildReviewItem('الاسم الكامل', fullName),
            _buildReviewItem('الرقم الوطني', _nationalIdController.text),
            _buildReviewItem('الجنس', _selectedGender == 1 ? 'ذكر' : 'أنثى'),
            if (_selectedDate != null)
              _buildReviewItem(
                widget.isDeceased ? 'تاريخ الوفاة' : 'تاريخ الميلاد',
                '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            if (widget.isDeceased && _deathCause != null)
              _buildReviewItem('سبب الوفاة', _getDeathCauseLabel(_deathCause!)),
            if (!widget.isDeceased && _healthStatus != null)
              _buildReviewItem(
                'الحالة الصحية',
                _getHealthStatusLabel(_healthStatus!),
              ),
            if (_notesController.text.isNotEmpty)
              _buildReviewItem('ملاحظات', _notesController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.md12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontMD13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppDimensions.fontMD,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required int value,
    required int? groupValue,
    required Function(int) onSelected,
    Color? color,
  }) {
    final isSelected = groupValue == value;
    final chipColor = color ?? Theme.of(context).primaryColor;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: isSelected ? chipColor : Colors.grey),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onSelected(value);
      },
      selectedColor: chipColor.withValues(alpha: 0.2),
      checkmarkColor: chipColor,
      side: BorderSide(
        color: isSelected ? chipColor : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusXXL,
      ),
    );
  }

  String _getDeathCauseLabel(int cause) {
    switch (cause) {
      case 1:
        return 'طبيعية';
      case 2:
        return 'مرض';
      case 3:
        return 'فجأة';
      case 4:
        return 'حادث';
      case 5:
        return 'أخرى';
      case 6:
        return 'انتحار';
      case 7:
        return 'مغدور';
      default:
        return 'غير معروف';
    }
  }

  String _getHealthStatusLabel(int status) {
    switch (status) {
      case 1:
        return 'سليم';
      case 2:
        return 'مريض';
      case 3:
        return 'مريض مزمن';
      case 4:
        return 'معاق';
      default:
        return 'غير معروف';
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إكمال جميع الحقول المطلوبة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final memberData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'secondName': _secondNameController.text.trim(),
      'thirdName': _thirdNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'gender': _selectedGender,
      'notes': _notesController.text.trim(),
    };

    if (widget.isDeceased) {
      memberData['deceasedType'] = widget.presetDeceasedType;
      memberData['nationalId'] = int.tryParse(
        _nationalIdController.text.trim(),
      );
      memberData['deathDate'] = _selectedDate ?? DateTime.now();
      memberData['deathCause'] = _deathCause ?? 8; // غير معروف
      memberData['documentType'] = _documentType;
    } else {
      memberData['orphanNationalId'] = int.tryParse(
        _nationalIdController.text.trim(),
      );
      memberData['birthDate'] = _selectedDate ?? DateTime.now();
      memberData['age'] = _selectedDate != null
          ? DateTime.now().difference(_selectedDate!).inDays ~/ 365
          : 0;
      memberData['healthStatus'] = _healthStatus ?? 5; // غير معروف
    }

    widget.onSave(memberData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusXXL,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600.w,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              if (_currentStep < 2) {
                if (_currentStep == 0 && !_formKey.currentState!.validate()) {
                  return;
                }
                setState(() => _currentStep++);
              } else {
                _handleSave();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('السابق'),
                      ),
                    if (_currentStep > 0) SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(_currentStep < 2 ? 'التالي' : 'حفظ'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ],
                ),
              );
            },
            steps: _buildSteps(),
          ),
        ),
      ),
    );
  }
}
