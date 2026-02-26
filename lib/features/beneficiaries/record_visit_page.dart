import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:benaa_offline_app/core/extensions/context_extensions.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';
import '../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../taxonomies/domain/entities/taxonomy_group.dart';
import '../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';

/// Record Visit Page - صفحة تسجيل الزيارات الميدانية
class RecordVisitPage extends ConsumerStatefulWidget {
  final String beneficiaryId;
  final Beneficiary beneficiary;

  const RecordVisitPage({
    required this.beneficiaryId,
    required this.beneficiary,
    super.key,
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
  String? _selectedVisitTypeCode;
  final List<String> _selectedCategoryCodes = [];

  static const Map<String, String> _fallbackVisitTypes = {
    'home_visit': 'زيارة منزلية',
    'follow_up': 'زيارة متابعة',
    'consultation': 'زيارة استشارية',
    'emergency': 'زيارة طارئة',
    'other': 'أخرى',
  };

  static const Map<String, String> _fallbackCategories = {
    'health': 'صحية',
    'education': 'تعليمية',
    'economic': 'اقتصادية',
    'psychological': 'نفسية',
    'social': 'اجتماعية',
  };

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
      if (!mounted) return;
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
      final rawNotes = _notesController.text.trim();
      var notes = rawNotes;

      if (_selectedVisitTypeCode != null) {
        final label = _fallbackVisitTypes[_selectedVisitTypeCode!] ?? _selectedVisitTypeCode!;
        notes = 'نوع الزيارة: $label\n\n$notes';
      }

      if (_selectedCategoryCodes.isNotEmpty) {
        final labels = _selectedCategoryCodes.map((code) => _fallbackCategories[code] ?? code).toList(growable: false);
        notes = '$notes\n\nالفئات: ${labels.join(', ')}';
      }

      await database.visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: const Uuid().v4(),
          beneficiaryId: widget.beneficiaryId,
          visitDate: _visitDate,
          staffName: _staffNameController.text.trim().isNotEmpty ? _staffNameController.text.trim() : 'غير محدد',
          notes: drift.Value(notes),
          isSubmitted: const drift.Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (mounted) {
        context.showSuccess('تم تسجيل الزيارة بنجاح');
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        context.showError('خطأ في التسجيل: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitTypeItems = ref.watch(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.visitType)).maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );
    final categoryItems = ref.watch(bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.category)).maybeWhen(
          data: (items) => items,
          orElse: () => const <taxonomy_domain.Taxonomy>[],
        );

    final visitTypes = visitTypeItems.isNotEmpty ? _toCodeLabelMap(visitTypeItems) : _fallbackVisitTypes;
    final categories = categoryItems.isNotEmpty ? _toCodeLabelMap(categoryItems) : _fallbackCategories;

    if (_selectedVisitTypeCode != null && !visitTypes.containsKey(_selectedVisitTypeCode)) {
      _selectedVisitTypeCode = null;
    }
    _selectedCategoryCodes.removeWhere((code) => !categories.containsKey(code));

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
                                'رقم الملف: ${widget.beneficiary.fileIdNumber ?? "غير محدد"}',
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
                          widget.beneficiary.province?.toString() ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (widget.beneficiary.city != null) ...[
                          Text(
                            ' - ${widget.beneficiary.city}',
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

            // Visit Type
            Text(
              'نوع الزيارة (اختياري)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedVisitTypeCode,
              decoration: InputDecoration(
                hintText: 'اختر نوع الزيارة',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: visitTypes.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                setState(() => _selectedVisitTypeCode = value);
              },
            ),

            SizedBox(height: 24.h),

            // Categories
            Text(
              'الفئات (اختياري)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: categories.entries.map((entry) {
                final code = entry.key;
                final label = entry.value;
                final selected = _selectedCategoryCodes.contains(code);
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        if (!_selectedCategoryCodes.contains(code)) {
                          _selectedCategoryCodes.add(code);
                        }
                      } else {
                        _selectedCategoryCodes.remove(code);
                      }
                    });
                  },
                );
              }).toList(growable: false),
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

  Map<String, String> _toCodeLabelMap(List<taxonomy_domain.Taxonomy> taxonomies) {
    final map = <String, String>{};
    for (final item in taxonomies) {
      final code = item.code.trim();
      final label = item.label.trim();
      if (code.isEmpty || label.isEmpty) continue;
      map.putIfAbsent(code, () => label);
    }
    return map;
  }
}
