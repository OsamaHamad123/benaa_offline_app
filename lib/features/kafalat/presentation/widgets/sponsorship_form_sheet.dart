import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/providers/providers.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/kafalat_providers.dart';

class SponsorshipFormSheet extends ConsumerStatefulWidget {
  final int beneficiaryId;
  final Sponsorship? initialSponsorship;

  const SponsorshipFormSheet({
    required this.beneficiaryId,
    this.initialSponsorship,
    super.key,
  });

  @override
  ConsumerState<SponsorshipFormSheet> createState() =>
      _SponsorshipFormSheetState();
}

class _SponsorshipFormSheetState extends ConsumerState<SponsorshipFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // معلومات الكافل
  String? _associationId;
  late final TextEditingController _sponsorNameController;

  // معلومات المكفول
  late final TextEditingController _internalFileNoController;
  late final TextEditingController _externalFileNoController;
  late final TextEditingController _guardianNameController;
  late final TextEditingController _guardianIdController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _guardianAltPhoneController;

  // تفاصيل الكفالة
  late final TextEditingController _durationMonthsController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'active';
  String _type = 'monthly';
  String? _currency;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  // معلومات الموقع
  late final TextEditingController _governorateController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;

  // معلومات بنكية
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountHolderNameController;
  late final TextEditingController _accountHolderIdController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _swiftCodeController;

  bool _saving = false;
  bool _loading = true;

  bool get _isEditing => widget.initialSponsorship != null;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSponsorship;

    // معلومات الكافل
    _associationId = s?.associationId;
    _sponsorNameController = TextEditingController(text: s?.sponsorName ?? '');

    // معلومات المكفول
    _internalFileNoController =
        TextEditingController(text: s?.internalFileNo ?? '');
    _externalFileNoController =
        TextEditingController(text: s?.externalFileNo ?? '');
    _guardianNameController =
        TextEditingController(text: s?.guardianName ?? '');
    _guardianIdController =
        TextEditingController(text: s?.guardianIdNumber?.toString() ?? '');
    _guardianPhoneController =
        TextEditingController(text: s?.guardianPhone ?? '');
    _guardianAltPhoneController =
        TextEditingController(text: s?.guardianAltPhone ?? '');

    // تفاصيل الكفالة
    _durationMonthsController =
        TextEditingController(text: s?.durationMonths?.toString() ?? '');
    _startDate = s?.startDate ?? DateTime.now();
    _endDate = s?.endDate;
    _status = s?.status ?? 'active';
    _type = s?.sponsorshipType ?? 'monthly';
    _currency = s?.currency;
    _amountController =
        TextEditingController(text: s?.amount?.toString() ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');

    // معلومات الموقع
    _governorateController = TextEditingController(text: s?.governorate ?? '');
    _cityController = TextEditingController(text: s?.city ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');

    // معلومات بنكية
    _bankNameController = TextEditingController(text: s?.bankName ?? '');
    _accountHolderNameController =
        TextEditingController(text: s?.accountHolderName ?? '');
    _accountHolderIdController =
        TextEditingController(text: s?.accountHolderIdNumber?.toString() ?? '');
    _accountNumberController =
        TextEditingController(text: s?.accountNumber ?? '');
    _swiftCodeController = TextEditingController(text: s?.swiftCode ?? '');

    // تحميل بيانات المستفيد تلقائياً إذا لم نكن في وضع التعديل
    if (!_isEditing) {
      _loadBeneficiaryData();
    } else {
      _loading = false;
    }
  }

  /// تحميل بيانات المستفيد وملء الحقول تلقائياً
  Future<void> _loadBeneficiaryData() async {
    try {
      final db = ref.read(databaseProvider);
      final beneficiary =
          await db.beneficiariesDao.getBeneficiaryById(widget.beneficiaryId);

      if (beneficiary != null && mounted) {
        setState(() {
          // ملء بيانات المستفيد
          final fullName = [
            beneficiary.firstName,
            beneficiary.fatherName,
            beneficiary.grandFatherName,
            beneficiary.familyName,
          ].where((e) => e != null && e.isNotEmpty).join(' ');

          _guardianNameController.text = fullName;
          _guardianIdController.text = beneficiary.idNumber.toString();
          _guardianPhoneController.text = beneficiary.phoneNumber.toString();
          _guardianAltPhoneController.text =
              beneficiary.altPhoneNumber.toString();

          // ملء بيانات الموقع
          if (beneficiary.province != null) {
            _governorateController.text = beneficiary.province.toString();
          }
          if (beneficiary.city != null) {
            _cityController.text = beneficiary.city.toString();
          }
          if (beneficiary.currentAddress != null) {
            _addressController.text = beneficiary.currentAddress!;
          }

          // ملء رقم الملف
          if (beneficiary.fileIdNumber != null) {
            _internalFileNoController.text = beneficiary.fileIdNumber!;
          }

          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _internalFileNoController.dispose();
    _externalFileNoController.dispose();
    _guardianNameController.dispose();
    _guardianIdController.dispose();
    _guardianPhoneController.dispose();
    _guardianAltPhoneController.dispose();
    _durationMonthsController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _accountHolderNameController.dispose();
    _accountHolderIdController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final associationsState = ref.watch(kafalatActiveAssociationsProvider);
    final theme = Theme.of(context);

    // عرض مؤشر التحميل أثناء تحميل بيانات المستفيد
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل بيانات المستفيد...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: 16.h,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ========== معلومات الكافل ==========
            _SectionTitle('معلومات الكافل', theme),
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    associationsState.when(
                      data: (associations) {
                        return DropdownButtonFormField<String>(
                          value: _associationId,
                          decoration: const InputDecoration(
                            labelText: 'المؤسسة الكافلة *',
                            border: OutlineInputBorder(),
                          ),
                          items: associations
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (v) {
                                  setState(() => _associationId = v);
                                },
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'اختر المؤسسة الكافلة';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('فشل تحميل الجمعيات: $e'),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _sponsorNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الكافل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ========== معلومات المكفول ==========
            _SectionTitle('معلومات المكفول', theme),
            if (!_isEditing) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تم ملء البيانات تلقائياً من ملف المستفيد',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _internalFileNoController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الملف الداخلي',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _externalFileNoController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الملف الخارجي',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _guardianNameController,
                      decoration: const InputDecoration(
                        labelText: 'إسم المعيل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _guardianIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم هوية المعيل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _guardianPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم هاتف المعيل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _guardianAltPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'جوال بديل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ========== تفاصيل الكفالة ==========
            _SectionTitle('تفاصيل الكفالة', theme),
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _durationMonthsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مدة الكفالة بالأشهر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _DateField(
                      label: 'تاريخ البداية',
                      value: _startDate,
                      onPick: _saving
                          ? null
                          : () async {
                              final picked =
                                  await _pickDate(context, _startDate);
                              if (picked != null)
                                setState(() => _startDate = picked);
                            },
                    ),
                    SizedBox(height: 12.h),
                    _DateField(
                      label: 'تاريخ النهاية',
                      value: _endDate,
                      onPick: _saving
                          ? null
                          : () async {
                              final picked = await _pickDate(context, _endDate);
                              if (picked != null)
                                setState(() => _endDate = picked);
                            },
                      onClear: _saving
                          ? null
                          : () {
                              setState(() => _endDate = null);
                            },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'نوع الكفالة',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'monthly', child: Text('شهرية')),
                        DropdownMenuItem(
                            value: 'one_time', child: Text('مرة واحدة')),
                        DropdownMenuItem(value: 'other', child: Text('أخرى')),
                      ],
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _type = v ?? 'monthly'),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'حالة الكفالة',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('نشطة')),
                        DropdownMenuItem(
                            value: 'paused', child: Text('موقوفة')),
                        DropdownMenuItem(value: 'ended', child: Text('منتهية')),
                      ],
                      onChanged:
                          _saving ? null : (v) => setState(() => _status = v!),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'القيمة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'IQD', child: Text('IQD')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged:
                          _saving ? null : (v) => setState(() => _currency = v),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ========== معلومات الموقع ==========
            _SectionTitle('معلومات الموقع', theme),
            if (!_isEditing) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تم ملء البيانات تلقائياً من ملف المستفيد',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _governorateController,
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'المدينة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ========== المعلومات البنكية ==========
            _SectionTitle('المعلومات البنكية', theme),
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم البنك',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _accountHolderNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم صاحب الحساب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _accountHolderIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم هوية صاحب الحساب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم الحساب البنكي',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _swiftCodeController,
                      decoration: const InputDecoration(
                        labelText: 'رمز Swift',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : () => _submit(context),
                icon: _saving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'جاري الحفظ...' : 'حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);

      // Parse numeric fields
      final amount = double.tryParse(_amountController.text.trim());
      final durationMonths =
          int.tryParse(_durationMonthsController.text.trim());
      final guardianId = int.tryParse(_guardianIdController.text.trim());
      final accountHolderId =
          int.tryParse(_accountHolderIdController.text.trim());

      // Parse text fields (null if empty)
      String? _parseText(TextEditingController controller) {
        final text = controller.text.trim();
        return text.isEmpty ? null : text;
      }

      if (_isEditing) {
        final fileNo = widget.initialSponsorship!.fileNo;
        await db.sponsorshipsDao.updateSponsorship(
          fileNo: fileNo,
          companion: SponsorshipsCompanion(
            beneficiaryId: drift.Value(widget.beneficiaryId),
            associationId: drift.Value(_associationId!),
            // معلومات الكافل
            sponsorName: drift.Value(_parseText(_sponsorNameController)),
            // معلومات المكفول
            internalFileNo: drift.Value(_parseText(_internalFileNoController)),
            externalFileNo: drift.Value(_parseText(_externalFileNoController)),
            guardianName: drift.Value(_parseText(_guardianNameController)),
            guardianIdNumber: drift.Value(guardianId),
            guardianPhone: drift.Value(_parseText(_guardianPhoneController)),
            guardianAltPhone:
                drift.Value(_parseText(_guardianAltPhoneController)),
            // تفاصيل الكفالة
            durationMonths: drift.Value(durationMonths),
            startDate: drift.Value(_startDate),
            endDate: drift.Value(_endDate),
            amount: drift.Value(amount),
            currency: drift.Value(_currency),
            status: drift.Value(_status),
            sponsorshipType: drift.Value(_type),
            notes: drift.Value(_parseText(_notesController)),
            // معلومات الموقع
            governorate: drift.Value(_parseText(_governorateController)),
            city: drift.Value(_parseText(_cityController)),
            address: drift.Value(_parseText(_addressController)),
            // المعلومات البنكية
            bankName: drift.Value(_parseText(_bankNameController)),
            accountHolderName:
                drift.Value(_parseText(_accountHolderNameController)),
            accountHolderIdNumber: drift.Value(accountHolderId),
            accountNumber: drift.Value(_parseText(_accountNumberController)),
            swiftCode: drift.Value(_parseText(_swiftCodeController)),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

        if (!context.mounted) return;
        unawaited(HapticPatterns.success());
        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم تحديث الكفالة. رقم الملف: $fileNo',
        );
        Navigator.pop(context, true);
        return;
      }

      final fileNo = await db.sponsorshipsDao.createSponsorship(
        SponsorshipsCompanion.insert(
          beneficiaryId: widget.beneficiaryId,
          associationId: _associationId!,
          // معلومات الكافل
          sponsorName: drift.Value(_parseText(_sponsorNameController)),
          // معلومات المكفول
          internalFileNo: drift.Value(_parseText(_internalFileNoController)),
          externalFileNo: drift.Value(_parseText(_externalFileNoController)),
          guardianName: drift.Value(_parseText(_guardianNameController)),
          guardianIdNumber: drift.Value(guardianId),
          guardianPhone: drift.Value(_parseText(_guardianPhoneController)),
          guardianAltPhone:
              drift.Value(_parseText(_guardianAltPhoneController)),
          // تفاصيل الكفالة
          durationMonths: drift.Value(durationMonths),
          startDate: drift.Value(_startDate),
          endDate: drift.Value(_endDate),
          amount: drift.Value(amount),
          currency: drift.Value(_currency),
          status: drift.Value(_status),
          sponsorshipType: drift.Value(_type),
          notes: drift.Value(_parseText(_notesController)),
          // معلومات الموقع
          governorate: drift.Value(_parseText(_governorateController)),
          city: drift.Value(_parseText(_cityController)),
          address: drift.Value(_parseText(_addressController)),
          // المعلومات البنكية
          bankName: drift.Value(_parseText(_bankNameController)),
          accountHolderName:
              drift.Value(_parseText(_accountHolderNameController)),
          accountHolderIdNumber: drift.Value(accountHolderId),
          accountNumber: drift.Value(_parseText(_accountNumberController)),
          swiftCode: drift.Value(_parseText(_swiftCodeController)),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message: 'تم إنشاء الكفالة. رقم الملف: $fileNo',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      unawaited(HapticPatterns.error());
      EnhancedSnackbar.showError(context, message: 'فشل حفظ الكفالة: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'غير محدد'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onPick,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onClear != null && value != null)
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                  tooltip: 'مسح',
                ),
              IconButton(
                onPressed: onPick,
                icon: const Icon(Icons.date_range_outlined),
                tooltip: 'اختيار',
              ),
            ],
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
