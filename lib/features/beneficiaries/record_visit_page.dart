import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';

/// Record Visit Page - صفحة تسجيل الزيارات الميدانية
class RecordVisitPage extends ConsumerStatefulWidget {
  final String beneficiaryId;
  final Beneficiary beneficiary;

  const RecordVisitPage({
    super.key,
    required this.beneficiaryId,
    required this.beneficiary,
  });

  @override
  ConsumerState<RecordVisitPage> createState() => _RecordVisitPageState();
}

class _RecordVisitPageState extends ConsumerState<RecordVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _staffNameController = TextEditingController();

  DateTime _visitDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _staffNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitDate),
      );

      if (time != null) {
        setState(() {
          _visitDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final database = ref.read(databaseProvider);
      final now = DateTime.now();

      await database.visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: const Uuid().v4(),
          beneficiaryId: widget.beneficiaryId,
          visitDate: _visitDate,
          staffName: _staffNameController.text.trim().isNotEmpty
              ? _staffNameController.text.trim()
              : 'غير محدد',
          notes: drift.Value(_notesController.text.trim()),
          isSubmitted: const drift.Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الزيارة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل زيارة'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveVisit,
              icon: const Icon(Icons.check),
              tooltip: 'حفظ',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Beneficiary Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            widget.beneficiary.fullName.substring(0, 1),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.beneficiary.fullName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'رقم الملف: ${widget.beneficiary.fileNo}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.beneficiary.governorate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (widget.beneficiary.district != null &&
                            widget.beneficiary.district!.isNotEmpty) ...[
                          Text(
                            ' - ${widget.beneficiary.district}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Visit Date
            Text(
              'تاريخ ووقت الزيارة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _formatDateTime(_visitDate),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Staff Name
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
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم الموظف';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Notes
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
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'أدخل تفاصيل الزيارة والملاحظات...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال ملاحظات الزيارة';
                }
                return null;
              },
            ),

            SizedBox(height: 32.h),

            // Save Button
            SizedBox(
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveVisit,
                icon: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'جاري الحفظ...' : 'حفظ الزيارة',
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year - $hour:$minute';
  }
}
