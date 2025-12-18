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

  const SponsorshipFormSheet({
    required this.beneficiaryId,
    super.key,
  });

  @override
  ConsumerState<SponsorshipFormSheet> createState() => _SponsorshipFormSheetState();
}

class _SponsorshipFormSheetState extends ConsumerState<SponsorshipFormSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _associationId;
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'active';
  String? _currency;

  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final associationsState = ref.watch(kafalatActiveAssociationsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: 16.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Text('بيانات الكفالة', style: theme.textTheme.titleMedium),
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
                          initialValue: _associationId,
                          decoration: const InputDecoration(
                            labelText: 'الجمعية',
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
                              return 'اختر جمعية';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('فشل تحميل الجمعيات: $e'),
                    ),
                    SizedBox(height: 12.h),
                    _DateField(
                      label: 'تاريخ البداية',
                      value: _startDate,
                      onPick: _saving
                          ? null
                          : () async {
                              final picked = await _pickDate(context, _startDate);
                              if (picked != null) setState(() => _startDate = picked);
                            },
                    ),
                    SizedBox(height: 12.h),
                    _DateField(
                      label: 'تاريخ النهاية (اختياري)',
                      value: _endDate,
                      onPick: _saving
                          ? null
                          : () async {
                              final picked = await _pickDate(context, _endDate);
                              if (picked != null) setState(() => _endDate = picked);
                            },
                      onClear: _saving
                          ? null
                          : () {
                              setState(() => _endDate = null);
                            },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'الحالة',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('نشطة')),
                        DropdownMenuItem(value: 'paused', child: Text('موقوفة')),
                        DropdownMenuItem(value: 'ended', child: Text('منتهية')),
                      ],
                      onChanged: _saving ? null : (v) => setState(() => _status = v!),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text('المبلغ (اختياري)', style: theme.textTheme.titleMedium),
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'القيمة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'IQD', child: Text('IQD')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged: _saving ? null : (v) => setState(() => _currency = v),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text('ملاحظات', style: theme.textTheme.titleMedium),
            SizedBox(height: 10.h),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    border: OutlineInputBorder(),
                  ),
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

      final amount = double.tryParse(_amountController.text.trim());
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      final fileNo = await db.sponsorshipsDao.createSponsorship(
        SponsorshipsCompanion.insert(
          beneficiaryId: widget.beneficiaryId,
          associationId: _associationId!,
          startDate: drift.Value(_startDate),
          endDate: drift.Value(_endDate),
          amount: drift.Value(amount),
          currency: drift.Value(_currency),
          status: drift.Value(_status),
          notes: drift.Value(notes),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message: 'تم إنشاء الكفالة. رقم الملف: $fileNo',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      unawaited(HapticPatterns.error());
      EnhancedSnackbar.showError(context, message: 'فشل حفظ الكفالة: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
