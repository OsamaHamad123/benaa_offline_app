import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/widgets/beneficiary/beneficiary_info_card.dart';
import '../../../../core/widgets/beneficiary/date_time_picker_field.dart';
import '../../domain/entities/visit_entity.dart';
import '../providers/visit_providers.dart';
import '../../../beneficiaries/presentation/pages/details_widgets/states/reusable_states.dart';

/// Record Visit Page - Enhanced Version 🔥
class RecordVisitPageEnhanced extends ConsumerStatefulWidget {
  final Beneficiary beneficiary;

  const RecordVisitPageEnhanced({super.key, required this.beneficiary});

  @override
  ConsumerState<RecordVisitPageEnhanced> createState() =>
      _RecordVisitPageEnhancedState();
}

class _RecordVisitPageEnhancedState
    extends ConsumerState<RecordVisitPageEnhanced> {
  final _formKey = GlobalKey<FormState>();
  final _staffNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  // 🎯 Visit Types
  String? _selectedVisitType;
  final List<String> _visitTypes = [
    'زيارة منزلية',
    'زيارة متابعة',
    'زيارة استشارية',
    'زيارة طارئة',
    'أخرى',
  ];

  // 📋 Visit Categories
  final List<String> _selectedCategories = [];
  final List<String> _categories = [
    'صحية',
    'تعليمية',
    'اقتصادية',
    'نفسية',
    'اجتماعية',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill staff name from cache/preferences
    _loadLastStaffName();
  }

  void _loadLastStaffName() {
    // TODO: Load from SharedPreferences
    // For now, we'll keep it empty
  }

  @override
  void dispose() {
    _staffNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12.w),
              Text('يرجى ملء جميع الحقول المطلوبة'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    LoadingDialog.show(context, message: 'جاري حفظ الزيارة...');

    try {
      // Build notes with categories and type
      String fullNotes = _notesController.text.trim();
      if (_selectedVisitType != null) {
        fullNotes = 'نوع الزيارة: $_selectedVisitType\n\n$fullNotes';
      }
      if (_selectedCategories.isNotEmpty) {
        fullNotes = '$fullNotes\n\nالفئات: ${_selectedCategories.join(', ')}';
      }

      // Generate unique ID for the visit
      final now = DateTime.now();
      final visitId = '${widget.beneficiary.id}_${now.millisecondsSinceEpoch}';

      final visit = VisitEntity(
        id: visitId,
        beneficiaryId: widget.beneficiary.id.toString(),
        visitDate: _selectedDateTime,
        staffName: _staffNameController.text.trim(),
        notes: fullNotes,
        isSubmitted: false,
        createdAt: now,
        updatedAt: now,
        syncState: 'pending',
        serverId: null,
        lastSyncedAt: null,
      );

      final success = await ref
          .read(visitNotifierProvider.notifier)
          .createNewVisit(visit);

      if (mounted) {
        LoadingDialog.hide(context);
      }

      if (success && mounted) {
        SuccessSnackBar.show(context, '✓ تم حفظ الزيارة بنجاح');

        // Save staff name for next time
        // TODO: Save to SharedPreferences

        // Return to previous screen
        Navigator.pop(context, true);
      } else if (mounted) {
        final errorMessage = ref.read(visitNotifierProvider).errorMessage;
        ErrorSnackBar.show(
          context,
          errorMessage ?? 'فشل حفظ الزيارة',
          onRetry: _saveVisit,
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ErrorSnackBar.show(context, 'خطأ غير متوقع: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل زيارة'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'معلومات',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8.w),
                      Text('نصائح لتسجيل الزيارة'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTip('✍️ اكتب ملاحظات واضحة ومفصلة'),
                      _buildTip('📅 تأكد من صحة التاريخ والوقت'),
                      _buildTip('🏷️ حدد نوع الزيارة والفئات المناسبة'),
                      _buildTip('✅ راجع المعلومات قبل الحفظ'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('فهمت'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 👤 Beneficiary Info Card
              BeneficiaryInfoCard(beneficiary: widget.beneficiary),
              SizedBox(height: 24.h),

              // 📅 Date Time Picker
              DateTimePickerField(
                label: 'التاریخ والوقت',
                selectedDate: _selectedDateTime,
                onTap: _selectDateTime,
              ),
              SizedBox(height: 24.h),

              // 🏷️ Visit Type Selector
              _buildSectionTitle('نوع الزيارة', Icons.category),
              SizedBox(height: 12.h),
              _buildVisitTypeSelector(),
              SizedBox(height: 24.h),

              // 📋 Categories Selector
              _buildSectionTitle('الفئات (اختياري)', Icons.label_outline),
              SizedBox(height: 12.h),
              _buildCategoriesSelector(),
              SizedBox(height: 24.h),

              // 👨‍💼 Staff Name Field
              _buildSectionTitle('اسم الموظف', Icons.person),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _staffNameController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسم الموظف',
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم الموظف';
                  }
                  if (value.trim().length < 3) {
                    return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // 📝 Notes Field
              _buildSectionTitle('ملاحظات الزيارة', Icons.note_alt),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _notesController,
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظات تفصيلية عن الزيارة...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  helperText: 'وصف واضح يساعد في متابعة الحالة',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال ملاحظات الزيارة';
                  }
                  if (value.trim().length < 10) {
                    return 'الملاحظات يجب أن تكون 10 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),

              // 💾 Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      label: Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveVisit,
                      icon: Icon(Icons.save),
                      label: Text('حفظ الزيارة'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.blue),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildVisitTypeSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _visitTypes.map((type) {
        final isSelected = _selectedVisitType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedVisitType = selected ? type : null;
            });
          },
          selectedColor: Colors.blue[100],
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue[900] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          selectedColor: Colors.green[100],
          checkmarkColor: Colors.green[900],
          labelStyle: TextStyle(
            color: isSelected ? Colors.green[900] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(tip, style: TextStyle(fontSize: 13.sp))],
      ),
    );
  }
}
