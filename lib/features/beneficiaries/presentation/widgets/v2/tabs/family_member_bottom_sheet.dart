import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../reusable_civil_registry_lookup.dart';
import '../../../../../../core/theme/app_dimensions.dart';
import '../../../../../../core/theme/app_breakpoints.dart';

/// 🎨 Bottom Sheet احترافي محسّن لإضافة/تعديل فرد من العائلة
///
/// ✨ التحسينات:
/// - Haptic Feedback عند التفاعلات
/// - Auto-validation ذكية
/// - Keyboard handling محسّن
/// - FocusNode management
/// - File size validation
/// - Smooth animations
/// - Better UX feedback
class FamilyMemberBottomSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType; // 1 للأب، 2 للأم
  final Function(Map<String, dynamic>) onSave;

  const FamilyMemberBottomSheet({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  ConsumerState<FamilyMemberBottomSheet> createState() =>
      _FamilyMemberBottomSheetState();
}

class _FamilyMemberBottomSheetState
    extends ConsumerState<FamilyMemberBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _ageController;
  late final TextEditingController _notesController;

  int _selectedGender = 1; // 1 = ذكر، 2 = أنثى
  DateTime? _selectedBirthDate;
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  bool _autoValidate = false;

  // Focus Nodes للتنقل السلس
  final _firstNameFocus = FocusNode();
  final _familyNameFocus = FocusNode();
  final _nationalIdFocus = FocusNode();
  final _notesFocus = FocusNode();

  void _calculateAge() {
    if (_selectedBirthDate != null) {
      final age = DateTime.now().difference(_selectedBirthDate!).inDays ~/ 365;
      _ageController.text = age.toString();
    }
  }

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
    _notesController = TextEditingController(text: member?['notes']);

    _selectedGender = member?['gender'] ?? 1;
    if (member?['birthDate'] != null) {
      _selectedBirthDate = member!['birthDate'] as DateTime;
      _calculateAge();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    _firstNameFocus.dispose();
    _familyNameFocus.dispose();
    _nationalIdFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.selectionClick();

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null) {
        // Check file size (max 5MB)
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'حجم الصورة كبير جداً (الحد الأقصى 5 ميجابايت)',
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
        });

        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم اختيار الصورة بنجاح'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل اختيار الصورة: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    HapticFeedback.selectionClick();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusXL,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedBirthDate = picked;
        _calculateAge();
      });
    }
  }

  void _handleSave() {
    // Enable auto validation
    setState(() => _autoValidate = true);

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إكمال جميع الحقول المطلوبة'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final memberData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'gender': _selectedGender,
      'age': int.tryParse(_ageController.text) ?? 0,
      'birthDate': _selectedBirthDate,
      'notes': _notesController.text.trim(),
    };

    if (widget.isDeceased) {
      memberData['deceasedType'] = widget.presetDeceasedType;
      memberData['nationalId'] = _nationalIdController.text.trim();
    } else {
      memberData['orphanNationalId'] = _nationalIdController.text.trim();
    }

    if (_selectedImage != null) {
      memberData['imagePath'] = _selectedImage!.path;
    }

    widget.onSave(memberData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.existingMember != null
        ? 'تعديل ${_getEntityName()}'
        : 'إضافة ${_getEntityName()}';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: context.screenHeight * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.xxl),
          ),
        ),
        child: Column(
          children: [
            // Header مع تصميم محسّن
            _buildHeader(title),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  padding: AppDimensions.paddingLG,
                  children: [
                    // صورة الفرد
                    _buildImagePicker(),
                    SizedBox(height: AppDimensions.xl),

                    // البيانات الأساسية
                    _buildBasicInfoSection(),
                    SizedBox(height: AppDimensions.lg),

                    // معلومات إضافية
                    _buildAdditionalInfoSection(),
                    SizedBox(height: AppDimensions.lg),

                    // الملاحظات
                    _buildNotesSection(),

                    // Extra padding for keyboard
                    SizedBox(
                      height:
                          MediaQuery.of(context).viewInsets.bottom +
                          AppDimensions.lg,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: AppDimensions.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.xxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              tooltip: 'إغلاق',
            ),
            SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontLG,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.check, size: 20),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm + 4.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusMD,
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEntityName() {
    if (widget.isDeceased) {
      if (widget.presetDeceasedType == 1) return 'الأب المتوفى';
      if (widget.presetDeceasedType == 2) return 'الأم المتوفية';
      return 'المتوفى';
    }
    return 'اليتيم';
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          Hero(
            tag: 'member_image_${widget.existingMember?['id'] ?? 'new'}',
            child: Container(
              width: AppDimensions.avatarXL,
              height: AppDimensions.avatarXL,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Icon(
                      _selectedGender == 1 ? Icons.boy : Icons.girl,
                      size: AppDimensions.iconHuge,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.sm + 2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: AppDimensions.iconMD,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'البيانات الأساسية',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'الاسم الأول',
          icon: Icons.badge,
          isRequired: true,
          focusNode: _firstNameFocus,
          nextFocus: _familyNameFocus,
        ),
        SizedBox(height: AppDimensions.md),
        _buildTextField(
          controller: _familyNameController,
          label: 'اسم العائلة',
          icon: Icons.family_restroom,
          isRequired: true,
          focusNode: _familyNameFocus,
          nextFocus: _nationalIdFocus,
        ),
        SizedBox(height: AppDimensions.md),
        _buildTextField(
          controller: _nationalIdController,
          label: 'الرقم الوطني',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          maxLength: 9,
          focusNode: _nationalIdFocus,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
        ),
        SizedBox(height: AppDimensions.sm),

        // Civil Registry Lookup
        CompactCivilRegistryLookup(
          nationalIdController: _nationalIdController,
          onDataFetched: (person) {
            if (mounted) {
              HapticFeedback.mediumImpact();
              setState(() {
                _firstNameController.text = person['firstName'] ?? '';
                _familyNameController.text = person['lastName'] ?? '';

                // Gender: 'ذكر' = 1, 'أنثى' = 2
                final gender = person['gender']?.toString();
                _selectedGender = gender == 'ذكر' ? 1 : 2;

                if (person['birthDate'] != null) {
                  _selectedBirthDate = person['birthDate'] as DateTime;
                  _calculateAge();
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم ملء البيانات من السجل المدني'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return _buildSectionCard(
      title: 'معلومات إضافية',
      icon: Icons.info,
      children: [
        // Gender Selector
        _buildGenderSelector(),
        SizedBox(height: AppDimensions.md),

        // تاريخ الميلاد
        InkWell(
          onTap: _selectBirthDate,
          borderRadius: AppDimensions.borderRadiusMD,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'تاريخ الميلاد',
              prefixIcon: const Icon(Icons.cake),
              suffixIcon: _selectedBirthDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedBirthDate = null;
                          _ageController.clear();
                        });
                      },
                    )
                  : const Icon(Icons.calendar_today, size: 20),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            child: Text(
              _selectedBirthDate != null
                  ? '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}'
                  : 'اختر تاريخ الميلاد',
              style: TextStyle(
                fontSize: AppDimensions.fontMD,
                color: _selectedBirthDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.md),

        // العمر (للعرض فقط)
        _buildTextField(
          controller: _ageController,
          label: 'العمر',
          icon: Icons.numbers,
          readOnly: true,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return _buildSectionCard(
      title: 'ملاحظات',
      icon: Icons.note_alt,
      children: [
        _buildTextField(
          controller: _notesController,
          label: 'ملاحظات إضافية',
          icon: Icons.edit_note,
          maxLines: 3,
          focusNode: _notesFocus,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: AppDimensions.paddingMD,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDimensions.borderRadiusXL,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: AppDimensions.borderRadiusSM,
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconLG,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontMD + 1.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool readOnly = false,
    bool enabled = true,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      readOnly: readOnly,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: AppDimensions.borderRadiusMD),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled
            ? Theme.of(context).colorScheme.surface
            : Colors.grey[200],
        counterText: '',
        helperText: isRequired ? null : 'اختياري',
        helperStyle: TextStyle(
          fontSize: AppDimensions.fontXS + 1.sp,
          color: Colors.grey,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label مطلوب';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: AppDimensions.borderRadiusMD,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedGender = 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                decoration: BoxDecoration(
                  color: _selectedGender == 1
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(AppDimensions.md - 4.r),
                  ),
                  border: _selectedGender == 1
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.boy,
                      color: _selectedGender == 1 ? Colors.blue : Colors.grey,
                      size: AppDimensions.iconLG + 4.sp,
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      'ذكر',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMD,
                        color: _selectedGender == 1 ? Colors.blue : Colors.grey,
                        fontWeight: _selectedGender == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedGender = 2);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                decoration: BoxDecoration(
                  color: _selectedGender == 2
                      ? Colors.pink.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppDimensions.md - 4.r),
                  ),
                  border: _selectedGender == 2
                      ? Border.all(color: Colors.pink, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.girl,
                      color: _selectedGender == 2 ? Colors.pink : Colors.grey,
                      size: AppDimensions.iconLG + 4.sp,
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      'أنثى',
                      style: TextStyle(
                        fontSize: AppDimensions.fontMD,
                        color: _selectedGender == 2 ? Colors.pink : Colors.grey,
                        fontWeight: _selectedGender == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
