import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🚀 Dialog سريع ومبسط لإضافة أفراد العائلة
///
/// ✅ التحسينات:
/// - تصميم مبسط وسريع جداً
/// - فقط الحقول الأساسية المطلوبة
/// - لا توجد صور أو حقول معقدة
/// - أداء ممتاز - لا lag
/// - UX محسّن بشكل كبير
class QuickFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType; // 1 للأب، 2 للأم
  final Function(Map<String, dynamic>) onSave;

  const QuickFamilyMemberDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  State<QuickFamilyMemberDialog> createState() =>
      _QuickFamilyMemberDialogState();
}

class _QuickFamilyMemberDialogState extends State<QuickFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _ageController;

  int _selectedGender = 1; // 1 = ذكر، 2 = أنثى
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    final member = widget.existingMember;

    _firstNameController = TextEditingController(text: member?['firstName']);
    _familyNameController = TextEditingController(text: member?['familyName']);
    _nationalIdController = TextEditingController(
      text:
          member?['nationalId']?.toString() ??
          member?['orphanNationalId']?.toString(),
    );
    _ageController = TextEditingController(text: member?['age']?.toString());
    _selectedGender = member?['gender'] ?? 1;
    _selectedBirthDate = member?['birthDate'] as DateTime?;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    final memberData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'gender': _selectedGender,
      'age': int.tryParse(_ageController.text) ?? 0,
      'birthDate': _selectedBirthDate ?? DateTime.now(),
      'notes': '',
    };

    if (widget.isDeceased) {
      memberData['deceasedType'] = widget.presetDeceasedType;
      memberData['nationalId'] = _nationalIdController.text.trim();
    } else {
      memberData['orphanNationalId'] = _nationalIdController.text.trim();
    }

    widget.onSave(memberData);
    Navigator.pop(context);
  }

  String _getTitle() {
    if (widget.existingMember != null) {
      return 'تعديل ${_getEntityName()}';
    }
    return 'إضافة ${_getEntityName()}';
  }

  String _getEntityName() {
    if (widget.isDeceased) {
      if (widget.presetDeceasedType == 1) return 'الأب المتوفى';
      if (widget.presetDeceasedType == 2) return 'الأم المتوفية';
      return 'المتوفى';
    }
    return 'يتيم';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 600.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isDeceased ? Icons.local_hospital : Icons.person_add,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _getTitle(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الاسم الأول
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم الأول *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'مطلوب' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // اسم العائلة
                      TextFormField(
                        controller: _familyNameController,
                        decoration: InputDecoration(
                          labelText: 'اسم العائلة *',
                          prefixIcon: const Icon(Icons.family_restroom),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'مطلوب' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // الرقم الوطني
                      TextFormField(
                        controller: _nationalIdController,
                        decoration: InputDecoration(
                          labelText: 'الرقم الوطني',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // الجنس
                      Text(
                        'الجنس *',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderButton(
                              label: 'ذكر',
                              icon: Icons.boy,
                              value: 1,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildGenderButton(
                              label: 'أنثى',
                              icon: Icons.girl,
                              value: 2,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // العمر
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'العمر',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          suffixText: 'سنة',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 24.h),

                      // أزرار الحفظ والإلغاء
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: const Text('إلغاء'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSave,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: const Text('حفظ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required int value,
    required Color color,
  }) {
    final isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedGender = value);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
