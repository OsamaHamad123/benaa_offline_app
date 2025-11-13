import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/widgets/beneficiary/beneficiary_info_card.dart';
import '../../../../core/widgets/beneficiary/date_time_picker_field.dart';
import '../../domain/entities/visit_entity.dart';
import '../providers/visit_providers.dart';

/// Record Visit Page using Clean Architecture
class RecordVisitPageClean extends ConsumerStatefulWidget {
  final Beneficiary beneficiary;

  const RecordVisitPageClean({super.key, required this.beneficiary});

  @override
  ConsumerState<RecordVisitPageClean> createState() =>
      _RecordVisitPageCleanState();
}

class _RecordVisitPageCleanState extends ConsumerState<RecordVisitPageClean> {
  final _formKey = GlobalKey<FormState>();
  final _staffNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isSubmitted = false;

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
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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
      return;
    }

    final visit = VisitEntity(
      id: '', // Will be auto-generated
      beneficiaryId: widget.beneficiary.id,
      visitDate: _selectedDateTime,
      staffName: _staffNameController.text.trim(),
      notes: _notesController.text.trim(),
      isSubmitted: _isSubmitted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncState: 'pending',
    );

    final success = await ref
        .read(visitNotifierProvider.notifier)
        .createNewVisit(visit);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الزيارة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      final errorMessage = ref.read(visitNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'فشل حفظ الزيارة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل زيارة')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Beneficiary Info Card
              BeneficiaryInfoCard(beneficiary: widget.beneficiary),
              SizedBox(height: 24.h),

              // Date Time Picker
              DateTimePickerField(
                selectedDate: _selectedDateTime,
                onTap: _selectDateTime,
              ),
              SizedBox(height: 24.h),

              // Staff Name Field
              Text(
                'اسم الموظف',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _staffNameController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسم الموظف',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم الموظف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Notes Field
              Text(
                'ملاحظات الزيارة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'أدخل ملاحظات الزيارة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال ملاحظات الزيارة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Submitted Checkbox
              CheckboxListTile(
                title: const Text('تم إرسال الزيارة'),
                subtitle: const Text(
                  'حدد هذا الخيار إذا تم إرسال بيانات الزيارة للخادم',
                ),
                value: _isSubmitted,
                onChanged: (value) {
                  setState(() {
                    _isSubmitted = value ?? false;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Save Button
              ElevatedButton(
                onPressed: visitState.isLoading ? null : _saveVisit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: visitState.isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('حفظ الزيارة', style: TextStyle(fontSize: 16.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
