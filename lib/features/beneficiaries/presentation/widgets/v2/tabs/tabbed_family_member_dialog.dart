import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_dimensions.dart';

/// 🎨 Tabbed Family Member Dialog - Tab-Based Design
///
/// ✨ تصميم بتبويبات:
/// - Tab 1: المعلومات الشخصية
/// - Tab 2: معلومات إضافية
/// - Tab 3: الملاحظات والوثائق
class TabbedFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const TabbedFamilyMemberDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  State<TabbedFamilyMemberDialog> createState() =>
      _TabbedFamilyMemberDialogState();
}

class _TabbedFamilyMemberDialogState extends State<TabbedFamilyMemberDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
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
  DateTime? _selectedDate;
  int? _healthStatus;
  int? _deathCause;
  int? _documentType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildPersonalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(AppDimensions.md20),
      children: [
        // رأس القسم
        Row(
          children: [
            Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
              size: AppDimensions.iconXL,
            ),
            SizedBox(width: AppDimensions.md12),
            Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(height: AppDimensions.xl),

        // الاسم الأول
        _buildTextField(
          controller: _firstNameController,
          label: 'الاسم الأول',
          icon: Icons.person,
          isRequired: true,
        ),
        SizedBox(height: AppDimensions.md12 + 2.h),

        // اسم الأب
        _buildTextField(
          controller: _secondNameController,
          label: 'اسم الأب',
          icon: Icons.person_outline,
        ),
        SizedBox(height: AppDimensions.md12 + 2.h),

        // اسم الجد
        _buildTextField(
          controller: _thirdNameController,
          label: 'اسم الجد',
          icon: Icons.person_outline,
        ),
        SizedBox(height: AppDimensions.md12 + 2.h),

        // اسم العائلة
        _buildTextField(
          controller: _familyNameController,
          label: 'اسم العائلة',
          icon: Icons.family_restroom,
          isRequired: true,
        ),
        SizedBox(height: AppDimensions.md12 + 2.h),

        // الرقم الوطني
        _buildTextField(
          controller: _nationalIdController,
          label: 'الرقم الوطني',
          icon: Icons.badge,
          isRequired: true,
          keyboardType: TextInputType.number,
          maxLength: 9,
          helperText: '9 أرقام',
          validator: (v) {
            if (v?.trim().isEmpty ?? true) return 'مطلوب';
            if (v!.length != 9) return 'يجب أن يكون 9 أرقام';
            return null;
          },
        ),
        SizedBox(height: AppDimensions.md20),

        // الجنس
        Text(
          'الجنس *',
          style: TextStyle(
            fontSize: AppDimensions.fontMD15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.md12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('ذكر'), icon: Icon(Icons.boy)),
            ButtonSegment(
              value: 2,
              label: Text('أنثى'),
              icon: Icon(Icons.girl),
            ),
          ],
          selected: {_selectedGender},
          onSelectionChanged: (Set<int> newSelection) {
            HapticFeedback.selectionClick();
            setState(() => _selectedGender = newSelection.first);
          },
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: AppDimensions.md12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoTab() {
    return ListView(
      padding: EdgeInsets.all(AppDimensions.md20),
      children: [
        // رأس القسم
        Row(
          children: [
            Icon(
              widget.isDeceased ? Icons.event_busy : Icons.calendar_today,
              color: widget.isDeceased ? Colors.red : Colors.green,
              size: AppDimensions.iconXL,
            ),
            SizedBox(width: AppDimensions.md12),
            Text(
              widget.isDeceased ? 'معلومات الوفاة' : 'معلومات اليتيم',
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(height: AppDimensions.xl),

        // تاريخ (ميلاد أو وفاة)
        _buildDatePicker(),
        SizedBox(height: AppDimensions.md20),

        // حسب النوع
        if (widget.isDeceased) _buildDeceasedSpecificFields(),
        if (!widget.isDeceased) _buildOrphanSpecificFields(),
      ],
    );
  }

  Widget _buildDeceasedSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // سبب الوفاة
        Text(
          'سبب الوفاة',
          style: TextStyle(
            fontSize: AppDimensions.fontMD15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.md12),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _buildChoiceChip(
              'طبيعية',
              Icons.favorite,
              1,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'مرض',
              Icons.local_hospital,
              2,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'فجأة',
              Icons.flash_on,
              3,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'حادث',
              Icons.car_crash,
              4,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'مغدور',
              Icons.dangerous,
              7,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'انتحار',
              Icons.sentiment_very_dissatisfied,
              6,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChoiceChip(
              'أخرى',
              Icons.help_outline,
              5,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.xl),

        // نوع الوثيقة
        Text(
          'نوع الوثيقة',
          style: TextStyle(
            fontSize: AppDimensions.fontMD15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.md12),
        Row(
          children: [
            Expanded(
              child: _buildDocumentTypeCard(
                title: 'شهادة وفاة',
                icon: Icons.description,
                value: 1,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: AppDimensions.md12),
            Expanded(
              child: _buildDocumentTypeCard(
                title: 'إفادة شهيد',
                icon: Icons.military_tech,
                value: 2,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrphanSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الحالة الصحية
        Text(
          'الحالة الصحية',
          style: TextStyle(
            fontSize: AppDimensions.fontMD15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.md12),
        _buildHealthStatusCard('سليم', Icons.check_circle, 1, Colors.green),
        SizedBox(height: 10.h),
        _buildHealthStatusCard('مريض', Icons.sick, 2, Colors.orange),
        SizedBox(height: 10.h),
        _buildHealthStatusCard(
          'مريض مزمن',
          Icons.medical_services,
          3,
          Colors.red,
        ),
        SizedBox(height: 10.h),
        _buildHealthStatusCard('معاق', Icons.accessible, 4, Colors.purple),
      ],
    );
  }

  Widget _buildNotesTab() {
    return ListView(
      padding: EdgeInsets.all(AppDimensions.md20),
      children: [
        // رأس القسم
        Row(
          children: [
            Icon(Icons.note, color: Colors.amber, size: AppDimensions.iconXL),
            SizedBox(width: AppDimensions.md12),
            Text(
              'الملاحظات والوثائق',
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(height: AppDimensions.xl),

        // الملاحظات
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'ملاحظات',
            hintText: 'أضف أي ملاحظات إضافية...',
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          maxLength: 500,
        ),
        SizedBox(height: AppDimensions.md20),

        // زر المرفقات (يمكن استخدامه لاحقاً)
        OutlinedButton.icon(
          onPressed: () {
            // TODO: فتح تبويب المرفقات
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('استخدم تبويب "المرفقات" الرئيسي لإضافة الوثائق'),
              ),
            );
          },
          icon: const Icon(Icons.attach_file),
          label: const Text('إضافة مرفقات'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: AppDimensions.borderRadiusMD),
        filled: true,
        fillColor: Colors.grey.shade50,
        helperText: helperText,
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator:
          validator ??
          (isRequired
              ? (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null
              : null),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      borderRadius: AppDimensions.borderRadiusMD,
      child: Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: AppDimensions.borderRadiusMD,
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: widget.isDeceased ? Colors.red : Colors.green,
            ),
            SizedBox(width: AppDimensions.md12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isDeceased ? 'تاريخ الوفاة' : 'تاريخ الميلاد',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.xs),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'اضغط للاختيار',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLG,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    IconData icon,
    int value,
    int? groupValue,
    Function(int) onSelected,
  ) {
    final isSelected = groupValue == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.fontLG),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onSelected(value);
      },
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusXXL,
      ),
    );
  }

  Widget _buildDocumentTypeCard({
    required String title,
    required IconData icon,
    required int value,
    required Color color,
  }) {
    final isSelected = _documentType == value;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _documentType = value);
      },
      borderRadius: AppDimensions.borderRadiusMD,
      child: Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppDimensions.borderRadiusMD,
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: AppDimensions.iconXXL,
            ),
            SizedBox(height: AppDimensions.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimensions.fontMD13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatusCard(
    String title,
    IconData icon,
    int value,
    Color color,
  ) {
    final isSelected = _healthStatus == value;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _healthStatus = value);
      },
      borderRadius: AppDimensions.borderRadiusMD,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md12 + 2.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppDimensions.borderRadiusMD,
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: AppDimensions.iconLG,
            ),
            SizedBox(width: AppDimensions.md12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontMD15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: AppDimensions.md20),
          ],
        ),
      ),
    );
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
      // الانتقال للتبويب الأول للتحقق
      _tabController.animateTo(0);
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
      memberData['deathCause'] = _deathCause ?? 8;
      memberData['documentType'] = _documentType;
    } else {
      memberData['orphanNationalId'] = int.tryParse(
        _nationalIdController.text.trim(),
      );
      memberData['birthDate'] = _selectedDate ?? DateTime.now();
      memberData['age'] = _selectedDate != null
          ? DateTime.now().difference(_selectedDate!).inDays ~/ 365
          : 0;
      memberData['healthStatus'] = _healthStatus ?? 5;
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
          maxWidth: AppDimensions.dialogMaxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // رأس الحوار
              Container(
                padding: EdgeInsets.all(AppDimensions.md20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.vertical(
                    top: AppDimensions.borderRadiusXXL.topLeft,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isDeceased ? Icons.person_off : Icons.child_care,
                      size: AppDimensions.iconXL,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: AppDimensions.md12),
                    Expanded(
                      child: Text(
                        widget.isDeceased
                            ? 'معلومات المتوفى'
                            : 'معلومات اليتيم',
                        style: TextStyle(
                          fontSize: AppDimensions.fontXXL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // التبويبات
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.person), text: 'شخصي'),
                  Tab(icon: Icon(Icons.info), text: 'إضافي'),
                  Tab(icon: Icon(Icons.note), text: 'ملاحظات'),
                ],
              ),

              // محتوى التبويبات
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalInfoTab(),
                    _buildAdditionalInfoTab(),
                    _buildNotesTab(),
                  ],
                ),
              ),

              // أزرار الحفظ والإلغاء
              Container(
                padding: EdgeInsets.all(AppDimensions.md20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(
                    bottom: AppDimensions.borderRadiusXXL.bottomLeft,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.md12 + 2.h,
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: AppDimensions.md12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.md12 + 2.h,
                          ),
                        ),
                        child: const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
