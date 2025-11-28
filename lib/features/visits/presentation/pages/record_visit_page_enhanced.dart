import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart'; // 🔥 UUID للـ ID الآمن
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/widgets/beneficiary/beneficiary_info_card.dart';
import '../../../../core/widgets/beneficiary/date_time_picker_field.dart';
import '../../domain/entities/visit_entity.dart';
import '../providers/visit_providers.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/utils/haptic_patterns.dart';

/// Record Visit Page - Enhanced Version 🔥
class RecordVisitPageEnhanced extends ConsumerStatefulWidget {
  final Beneficiary beneficiary;

  const RecordVisitPageEnhanced({super.key, required this.beneficiary});

  @override
  ConsumerState<RecordVisitPageEnhanced> createState() => _RecordVisitPageEnhancedState();
}

class _RecordVisitPageEnhancedState extends ConsumerState<RecordVisitPageEnhanced> {
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

  void _loadLastStaffName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastStaffName = prefs.getString('last_staff_name');
      if (lastStaffName != null && lastStaffName.isNotEmpty) {
        _staffNameController.text = lastStaffName;
      }
    } catch (e) {
      // Silently fail - not critical
    }
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
      EnhancedSnackbar.showWarning(
        context,
        message: 'يرجى ملء جميع الحقول المطلوبة',
      );
      return;
    }

    // Show loading overlay
    if (!mounted) return;

    setState(() {});

    try {
      // Show loading overlay
      if (!mounted) return;

      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Allow UI to update

      if (!mounted) return;

      // Build notes with categories and type
      String fullNotes = _notesController.text.trim();
      if (_selectedVisitType != null) {
        fullNotes = 'نوع الزيارة: $_selectedVisitType\n\n$fullNotes';
      }
      if (_selectedCategories.isNotEmpty) {
        fullNotes = '$fullNotes\n\nالفئات: ${_selectedCategories.join(', ')}';
      }

      // 🔥 Generate secure unique ID using UUID
      final now = DateTime.now();
      final visitId = const Uuid().v4();

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

      // 🔥 Use CreateVisitWithActivity - يحفظ الزيارة ويسجل النشاط تلقائياً
      final createVisitWithActivity = ref.read(createVisitWithActivityProvider);
      await createVisitWithActivity(
        visit: visit,
        beneficiaryName: widget.beneficiary.fullName,
      );

      // Save staff name for next time
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_staff_name', visit.staffName);
      } catch (_) {
        // Ignore cache errors
      }

      if (mounted) {
        // Show success dialog with animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ScaleTransitionWidget(
            duration: AppDurations.fast,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'تم حفظ الزيارة بنجاح',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'تم حفظ بيانات الزيارة وستتم المزامنة قريباً',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Close page
                  },
                  child: Text('حسناً'),
                ),
              ],
            ),
          ),
        );

        HapticPatterns.success();

        // Save staff name for next time
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'last_staff_name',
            _staffNameController.text.trim(),
          );
        } catch (e) {
          // Silently fail - not critical
        }
      } else if (mounted) {
        HapticPatterns.error();
        final errorMessage = ref.read(visitNotifierProvider).errorMessage;
        EnhancedSnackbar.showError(
          context,
          message: errorMessage ?? 'فشل حفظ الزيارة',
        );
      }
    } catch (e) {
      if (mounted) {
        HapticPatterns.error();
        GlobalErrorHandler.handleError(
          context,
          AppError(
            type: ErrorType.unknown,
            message: 'خطأ غير متوقع',
            originalError: e,
          ),
          onRetry: _saveVisit,
        );
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
            icon: const Icon(Icons.info_outline),
            tooltip: 'معلومات',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ScaleTransitionWidget(
                  duration: AppDurations.fast,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    title: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8.w),
                        const Text('نصائح لتسجيل الزيارة'),
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
                        child: const Text('فهمت'),
                      ),
                    ],
                  ),
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
              FadeSlideTransition(
                duration: AppDurations.fast,
                child: BeneficiaryInfoCard(beneficiary: widget.beneficiary),
              ),
              SizedBox(height: 24.h),

              // 📅 Date Time Picker
              ScaleTransitionWidget(
                duration: AppDurations.fast,
                child: DateTimePickerField(
                  label: 'التاریخ والوقت',
                  selectedDate: _selectedDateTime,
                  onTap: _selectDateTime,
                ),
              ),
              SizedBox(height: 24.h),

              // 🏷️ Visit Type Selector
              FadeSlideTransition(
                duration: AppDurations.normal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('نوع الزيارة', Icons.category),
                    SizedBox(height: 12.h),
                    _buildVisitTypeSelector(),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // 📋 Categories Selector
              FadeSlideTransition(
                duration: AppDurations.normal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('الفئات (اختياري)', Icons.label_outline),
                    SizedBox(height: 12.h),
                    _buildCategoriesSelector(),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // 👨‍💼 Staff Name Field
              ScaleTransitionWidget(
                duration: AppDurations.fast,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('اسم الموظف', Icons.person),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _staffNameController,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم الموظف',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
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
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
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
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // 📝 Notes Field
              ScaleTransitionWidget(
                duration: AppDurations.fast,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
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
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // 💾 Action Buttons
              ScaleTransitionWidget(
                duration: AppDurations.fast,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('إلغاء'),
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
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ الزيارة'),
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
