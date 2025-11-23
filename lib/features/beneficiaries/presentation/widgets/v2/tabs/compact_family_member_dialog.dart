import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🆕
import '../../../../../../core/theme/app_dimensions.dart';
import '../../../../../../core/theme/app_breakpoints.dart';
import '../../../providers/beneficiary_dependencies.dart'; // 🆕 For civilRegistryProvider

/// 🚀 Compact Family Member Dialog - أداء عالي + Responsive
///
/// ✨ مميزات:
/// - Dialog واحد بدون Stepper (تقليل lag)
/// - Scrollable بدون DraggableScrollableSheet
/// - Responsive للموبايل والتابلت (AppBreakpoints)
/// - حقول كاملة بدون تعقيد
/// - يستخدم AppDimensions للـ spacing الموحد
/// - تكامل مع السجل المدني
class CompactFamilyMemberDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const CompactFamilyMemberDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  ConsumerState<CompactFamilyMemberDialog> createState() =>
      _CompactFamilyMemberDialogState();
}

class _CompactFamilyMemberDialogState
    extends ConsumerState<CompactFamilyMemberDialog> {
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
  bool _isFetchingCivilRegistry = false;
  String? _civilRegistryStatus;

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

  /// 🔍 Fetch from Civil Registry
  Future<void> _fetchFromCivilRegistry(String nationalId) async {
    if (nationalId.length != 9) {
      setState(() {
        _civilRegistryStatus = 'الرقم الوطني يجب أن يكون 9 أرقام';
      });
      return;
    }

    setState(() {
      _isFetchingCivilRegistry = true;
      _civilRegistryStatus = 'جاري البحث في السجل المدني...';
    });

    try {
      // 🔥 استخدام الـ provider الحقيقي
      await ref
          .read(civilRegistryProvider.notifier)
          .fetchByNationalId(nationalId); // ✅ الاسم الصحيح

      final civilRegistryState = ref.read(civilRegistryProvider);

      if (civilRegistryState.isSuccess && civilRegistryState.person != null) {
        final person = civilRegistryState.person!;

        // Auto-fill fields
        setState(() {
          _firstNameController.text = person.firstName;
          _secondNameController.text = person.fatherName;
          _thirdNameController.text = person.grandfatherName ?? '';
          _familyNameController.text =
              person.lastName; // ✅ lastName بدل familyName
          _selectedGender = person.gender == 'ذكر' ? 1 : 2;
          if (!widget.isDeceased && person.birthDate != null) {
            _selectedDate = person.birthDate;
          }
          _isFetchingCivilRegistry = false;
          _civilRegistryStatus = '✅ تم العثور على البيانات وملؤها تلقائياً';
        });

        HapticFeedback.lightImpact();
      } else {
        setState(() {
          _isFetchingCivilRegistry = false;
          _civilRegistryStatus = '❌ لم يتم العثور على بيانات في السجل المدني';
        });
      }
    } catch (e) {
      setState(() {
        _isFetchingCivilRegistry = false;
        _civilRegistryStatus = '❌ خطأ في البحث: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.dialogMaxWidth(context),
          maxHeight:
              context.screenHeight * AppDimensions.dialogMaxHeightPercent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(child: _buildHeader(context)),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: AppDimensions.paddingLG,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 500, // تحسين أداء التمرير
                  children: [
                    RepaintBoundary(child: _buildNameFields()),
                    SizedBox(height: AppDimensions.md),
                    RepaintBoundary(child: _buildNationalIdAndGender()),
                    SizedBox(height: AppDimensions.md),
                    RepaintBoundary(child: _buildDatePicker()),
                    SizedBox(height: AppDimensions.md),
                    if (widget.isDeceased)
                      RepaintBoundary(child: _buildDeceasedFields()),
                    if (!widget.isDeceased)
                      RepaintBoundary(child: _buildOrphanFields()),
                    SizedBox(height: AppDimensions.md),
                    RepaintBoundary(child: _buildNotesField()),
                  ],
                ),
              ),
            ),
            RepaintBoundary(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Icon(
            widget.isDeceased ? Icons.person_off : Icons.child_care,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.isDeceased
                  ? (widget.presetDeceasedType == 1 ? 'أب متوفى' : 'أم متوفاة')
                  : 'يتيم',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاسم الكامل',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'الأول *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _secondNameController,
                decoration: const InputDecoration(
                  labelText: 'الأب',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _thirdNameController,
                decoration: const InputDecoration(
                  labelText: 'الجد',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: _familyNameController,
                decoration: const InputDecoration(
                  labelText: 'العائلة *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'مطلوب' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNationalIdAndGender() {
    return Column(
      children: [
        // الرقم الوطني مع زر السجل المدني
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني *',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.badge, size: 20),
                ),
                keyboardType: TextInputType.number,
                maxLength: 9,
                onChanged: (value) {
                  // Auto-fetch when 9 digits entered
                  if (value.length == 9 && !_isFetchingCivilRegistry) {
                    _fetchFromCivilRegistry(value);
                  }
                },
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'مطلوب';
                  if (v!.length != 9) return '9 أرقام';
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.w),
            // زر السجل المدني
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _isFetchingCivilRegistry
                    ? null
                    : () => _fetchFromCivilRegistry(_nationalIdController.text),
                icon: _isFetchingCivilRegistry
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.search, size: 18.sp),
                label: Text('بحث', style: TextStyle(fontSize: 11.sp)),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Civil Registry Status
        if (_civilRegistryStatus != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _civilRegistryStatus!.contains('نجح')
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _civilRegistryStatus!.contains('نجح')
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _civilRegistryStatus!.contains('نجح')
                      ? Icons.check_circle
                      : Icons.info,
                  size: 16.sp,
                  color: _civilRegistryStatus!.contains('نجح')
                      ? Colors.green
                      : Colors.orange,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _civilRegistryStatus!,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: AppDimensions.md),

        // الجنس
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الجنس *', style: TextStyle(fontSize: 13.sp)),
            SizedBox(height: 8.h),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 1,
                  label: Text('ذكر'),
                  icon: Icon(Icons.boy, size: 18),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('أنثى'),
                  icon: Icon(Icons.girl, size: 18),
                ),
              ],
              selected: {_selectedGender},
              onSelectionChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _selectedGender = v.first);
              },
              style: ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      ],
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
      borderRadius: BorderRadius.circular(8.r),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.isDeceased ? 'تاريخ الوفاة' : 'تاريخ الميلاد',
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: Icon(
            Icons.calendar_today,
            size: 20,
            color: widget.isDeceased ? Colors.red : Colors.green,
          ),
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'اضغط للاختيار',
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildDeceasedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سبب الوفاة',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            _buildChip(
              'طبيعية',
              1,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChip(
              'مرض',
              2,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChip(
              'حادث',
              4,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChip(
              'مغدور',
              7,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
            _buildChip(
              'أخرى',
              5,
              _deathCause,
              (v) => setState(() => _deathCause = v),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'نوع الوثيقة',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                'شهادة وفاة',
                Icons.description,
                1,
                _documentType,
                (v) => setState(() => _documentType = v),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildDocCard(
                'إفادة شهيد',
                Icons.military_tech,
                2,
                _documentType,
                (v) => setState(() => _documentType = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrphanFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة الصحية',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: [
            _buildChip(
              'سليم',
              1,
              _healthStatus,
              (v) => setState(() => _healthStatus = v),
              color: Colors.green,
            ),
            _buildChip(
              'مريض',
              2,
              _healthStatus,
              (v) => setState(() => _healthStatus = v),
              color: Colors.orange,
            ),
            _buildChip(
              'مزمن',
              3,
              _healthStatus,
              (v) => setState(() => _healthStatus = v),
              color: Colors.red,
            ),
            _buildChip(
              'معاق',
              4,
              _healthStatus,
              (v) => setState(() => _healthStatus = v),
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'ملاحظات',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      maxLines: 2,
      maxLength: 200,
    );
  }

  Widget _buildChip(
    String label,
    int value,
    int? groupValue,
    Function(int) onTap, {
    Color? color,
  }) {
    final isSelected = groupValue == value;
    final chipColor = color ?? Colors.blue;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? chipColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(
    String label,
    IconData icon,
    int value,
    int? groupValue,
    Function(int) onTap,
  ) {
    final isSelected = groupValue == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _handleSave,
              child: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إكمال الحقول المطلوبة'),
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
}
