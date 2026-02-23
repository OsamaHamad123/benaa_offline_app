import 'dart:async' show unawaited;

import 'package:drift/drift.dart' as drift;
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/utils/file_write.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../features/taxonomies/taxonomies.dart';
import '../providers/kafalat_providers.dart';

class KafalatImportPage extends ConsumerStatefulWidget {
  const KafalatImportPage({super.key});

  @override
  ConsumerState<KafalatImportPage> createState() => _KafalatImportPageState();
}

class _KafalatImportPageState extends ConsumerState<KafalatImportPage> {
  Uint8List? _fileBytes;
  String? _fileName;
  bool _busy = false;

  String? _busyLabel;

  int _parseTotalRows = 0;
  int _parseValidRows = 0;
  int _parseInvalidRows = 0;
  int _parseDuplicateRows = 0;

  int _importTotal = 0;
  int _importProcessed = 0;
  int _importInserted = 0;
  int _importUpdated = 0;
  int _importSkipped = 0;
  int? _lastImportBatchId;

  List<_ExcelBeneficiaryRow> _rows = const [];

  String? _selectedAssociationId;
  String? _selectedSponsorshipType = 'monthly';
  String? _selectedSponsorshipStatus = 'active';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sponsorshipTypesAsync = ref.watch(
      bridgeTaxonomiesByGroupOnceProvider(TaxonomyGroup.sponsorshipType),
    );

    final dynamicSponsorshipTypeItems = sponsorshipTypesAsync.maybeWhen(
      data: (items) => items
          .where((item) => item.code.trim().isNotEmpty && item.label.trim().isNotEmpty)
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.code,
              child: Text(item.label, textAlign: TextAlign.right),
            ),
          )
          .toList(growable: false),
      orElse: () => const <DropdownMenuItem<String>>[],
    );

    final sponsorshipTypeItems = dynamicSponsorshipTypeItems.isNotEmpty
        ? dynamicSponsorshipTypeItems
        : const [
            DropdownMenuItem(value: 'monthly', child: Text('شهرية')),
            DropdownMenuItem(value: 'one_time', child: Text('مرة واحدة')),
            DropdownMenuItem(value: 'other', child: Text('أخرى')),
          ];

    final selectedSponsorshipTypeExists = sponsorshipTypeItems.any(
      (item) => item.value == _selectedSponsorshipType,
    );
    final selectedSponsorshipType = selectedSponsorshipTypeExists ? _selectedSponsorshipType : null;

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final maxWidth = isWide ? 980.0 : double.infinity;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: GradientAppBar(
        title: 'رفع ملف Excel',
        leading: IconButton(
          tooltip: 'إغلاق',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Instructions panel
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.primary),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'تعليمات رفع الملف',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _busy ? null : () => _downloadTemplate(context),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('تحميل القالب'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'يجب أن يحتوي ملف Excel على الأعمدة التالية بالترتيب (يمكن اختلاف الأسماء طالما تشير لنفس المعنى):\n'
                        '1) رقم الهوية (مطلوب)\n'
                        '2) الهاتف\n'
                        '3) هاتف بديل\n'
                        '4) الاسم\n'
                        '5) اسم الأب\n'
                        '6) اسم الجد\n'
                        '7) اللقب',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: theme.colorScheme.tertiary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onTertiaryContainer),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'مهم: سيتم تحديث/إضافة المستفيدين حسب رقم الهوية، ثم إنشاء كفالات حسب الإعدادات.\n'
                                'لن يتم إنشاء كفالة "نشطة" إذا كان لدى المستفيد كفالة نشطة مسبقاً.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Import settings
              Text(
                'إعدادات الاستيراد',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isThreeCols = constraints.maxWidth >= 800;

                  final associationField = _AssociationDropdown(
                    value: _selectedAssociationId,
                    enabled: !_busy,
                    onChanged: (v) => setState(() => _selectedAssociationId = v),
                  );

                  final typeField = _SimpleDropdown(
                    label: 'نوع الكفالة',
                    value: selectedSponsorshipType,
                    enabled: !_busy,
                    items: sponsorshipTypeItems,
                    onChanged: (v) => setState(() => _selectedSponsorshipType = v),
                  );

                  final statusField = _SimpleDropdown(
                    label: 'حالة الكفالة',
                    value: _selectedSponsorshipStatus,
                    enabled: !_busy,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('نشطة')),
                      DropdownMenuItem(value: 'paused', child: Text('موقوفة')),
                      DropdownMenuItem(value: 'ended', child: Text('منتهية')),
                    ],
                    onChanged: (v) => setState(() => _selectedSponsorshipStatus = v),
                  );

                  if (isThreeCols) {
                    return Row(
                      children: [
                        Expanded(child: associationField),
                        SizedBox(width: 12.w),
                        Expanded(child: typeField),
                        SizedBox(width: 12.w),
                        Expanded(child: statusField),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      associationField,
                      SizedBox(height: 12.h),
                      typeField,
                      SizedBox(height: 12.h),
                      statusField,
                    ],
                  );
                },
              ),

              SizedBox(height: 18.h),

              // File chooser
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ملف Excel',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(height: 8.h),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fileName ?? 'No file chosen',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      OutlinedButton(
                        onPressed: _busy ? null : () => _pickFile(context),
                        child: const Text('Choose File'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_fileBytes != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _rows.isEmpty
                      ? 'الملف جاهز للفحص'
                      : 'تمت قراءة ${_rows.length} صف • صالحة: $_parseValidRows • مكررة: $_parseDuplicateRows • غير صالحة: $_parseInvalidRows',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.right,
                ),
              ],

              if (_busy) ...[
                SizedBox(height: 10.h),
                const LinearProgressIndicator(),
                if (_busyLabel != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    _busyLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],

              SizedBox(height: 18.h),

              // Actions
              LayoutBuilder(
                builder: (context, constraints) {
                  final isRow = constraints.maxWidth >= 520;

                  final scanButton = SizedBox(
                    width: isRow ? null : double.infinity,
                    child: FilledButton.icon(
                      onPressed: (_busy || _fileBytes == null) ? null : () => _parseExcel(context),
                      icon: const Icon(Icons.search),
                      label: Text(_busy ? 'جاري الفحص...' : 'فحص الملف'),
                    ),
                  );

                  final importButton = SizedBox(
                    width: isRow ? null : double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: (_busy || _rows.isEmpty) ? null : () => _importRows(context),
                      icon: const Icon(Icons.download_done_outlined),
                      label: Text(_busy ? 'جاري الاستيراد...' : 'استيراد'),
                    ),
                  );

                  final cancelButton = SizedBox(
                    width: isRow ? null : double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.maybePop(context),
                      child: const Text('إلغاء'),
                    ),
                  );

                  if (isRow) {
                    return Row(
                      children: [
                        scanButton,
                        SizedBox(width: 12.w),
                        importButton,
                        const Spacer(),
                        cancelButton,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      scanButton,
                      SizedBox(height: 10.h),
                      importButton,
                      SizedBox(height: 10.h),
                      cancelButton,
                    ],
                  );
                },
              ),

              if (_importTotal > 0) ...[
                SizedBox(height: 16.h),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'تقدم الاستيراد',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$_importProcessed / $_importTotal',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Text(
                              'إضافة: $_importInserted • تحديث: $_importUpdated • تخطي: $_importSkipped',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        LinearProgressIndicator(
                          value: _importTotal == 0 ? null : (_importProcessed / _importTotal).clamp(0, 1),
                        ),
                        if (_lastImportBatchId != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Batch ID: $_lastImportBatchId',
                            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 18.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'معاينة البيانات',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Text(
                    _rows.isEmpty ? '0 صف' : '${_rows.length} صف',
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (_rows.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      Icon(Icons.table_rows_outlined, size: 36.sp, color: theme.colorScheme.onSurfaceVariant),
                      SizedBox(height: 10.h),
                      Text(
                        'لا توجد بيانات لعرضها',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rows.length > 30 ? 30 : _rows.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final r = _rows[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(r.fullNameOrFallback),
                        subtitle: Text('الرقم الوطني: ${r.idNumber}'),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      unawaited(HapticPatterns.selection());

      // Build template
      final excel = Excel.createExcel();
      final sheet = excel.sheets.values.first;
      sheet.appendRow(
        [
          TextCellValue('رقم الهوية'),
          TextCellValue('الهاتف'),
          TextCellValue('هاتف بديل'),
          TextCellValue('الاسم'),
          TextCellValue('اسم الأب'),
          TextCellValue('اسم الجد'),
          TextCellValue('اللقب'),
        ],
      );

      final bytes = excel.encode();
      if (bytes == null) throw Exception('فشل توليد ملف القالب');

      if (kIsWeb) {
        if (!context.mounted) return;
        EnhancedSnackbar.showError(context, message: 'تحميل القالب غير مدعوم على الويب حالياً');
        return;
      }

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ قالب Excel',
        fileName: 'kafalat_template.xlsx',
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );

      if (savePath == null) return;
      await writeBytesToPath(savePath, bytes);

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(context, message: 'تم حفظ القالب');
    } catch (e) {
      if (!context.mounted) return;
      unawaited(HapticPatterns.error());
      EnhancedSnackbar.showError(context, message: 'فشل تحميل القالب: $e');
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      unawaited(HapticPatterns.selection());
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: true,
      );

      final f = res?.files.single;
      if (f == null || f.bytes == null) return;

      setState(() {
        _fileBytes = f.bytes;
        _fileName = f.name;
        _rows = const [];

        _busyLabel = null;

        _parseTotalRows = 0;
        _parseValidRows = 0;
        _parseInvalidRows = 0;
        _parseDuplicateRows = 0;

        _importTotal = 0;
        _importProcessed = 0;
        _importInserted = 0;
        _importUpdated = 0;
        _importSkipped = 0;
        _lastImportBatchId = null;
      });
    } catch (e) {
      if (!context.mounted) return;
      EnhancedSnackbar.showError(context, message: 'فشل اختيار الملف: $e');
    }
  }

  Future<void> _parseExcel(BuildContext context) async {
    if (_fileBytes == null) return;

    setState(() {
      _busy = true;
      _busyLabel = 'جاري قراءة الملف وتحليل الأعمدة...';
    });
    try {
      final excel = Excel.decodeBytes(_fileBytes!);
      if (excel.tables.isEmpty) {
        throw Exception('لا توجد أوراق داخل الملف');
      }

      final sheet = excel.tables.values.first;
      final rows = sheet.rows;
      if (rows.isEmpty) {
        throw Exception('لا توجد بيانات');
      }

      final headers = rows.first.map((c) => _normalizeHeader(_cellToString(c))).toList(growable: false);

      final parsed = <_ExcelBeneficiaryRow>[];

      final seenIds = <int>{};
      int total = 0;
      int invalid = 0;
      int duplicates = 0;

      for (var i = 1; i < rows.length; i++) {
        total++;
        final row = rows[i];
        final map = <String, String>{};
        for (var j = 0; j < headers.length && j < row.length; j++) {
          final key = headers[j];
          if (key.isEmpty) continue;
          map[key] = _cellToString(row[j]).trim();
        }

        final idNumber = _parseNationalId(map);
        if (idNumber == null) {
          invalid++;
          continue;
        }

        if (seenIds.contains(idNumber)) {
          duplicates++;
          continue;
        }
        seenIds.add(idNumber);

        parsed.add(
          _ExcelBeneficiaryRow(
            idNumber: idNumber,
            phoneNumber: _parseInt(map[_h('phone')]) ?? 0,
            altPhoneNumber: _parseInt(map[_h('alt_phone')]) ?? 0,
            firstName: map[_h('first_name')] ?? map[_h('name')] ?? '',
            fatherName: map[_h('father_name')] ?? '',
            grandFatherName: map[_h('grand_father_name')] ?? '',
            familyName: map[_h('family_name')] ?? '',
          ),
        );
      }

      setState(() => _rows = parsed);
      setState(() {
        _parseTotalRows = total;
        _parseInvalidRows = invalid;
        _parseDuplicateRows = duplicates;
        _parseValidRows = parsed.length;
      });

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message: 'تمت قراءة ${parsed.length} صف صالحة (عرض أول 30 صف فقط).',
      );
    } catch (e) {
      if (!context.mounted) return;
      unawaited(HapticPatterns.error());
      EnhancedSnackbar.showError(context, message: 'فشل قراءة الملف: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importRows(BuildContext context) async {
    if (_rows.isEmpty) return;

    if (_selectedAssociationId == null || _selectedAssociationId!.isEmpty) {
      EnhancedSnackbar.showError(context, message: 'يرجى اختيار المؤسسة الكافلة');
      return;
    }
    if (_selectedSponsorshipType == null || _selectedSponsorshipType!.isEmpty) {
      EnhancedSnackbar.showError(context, message: 'يرجى اختيار نوع الكفالة');
      return;
    }
    if (_selectedSponsorshipStatus == null || _selectedSponsorshipStatus!.isEmpty) {
      EnhancedSnackbar.showError(context, message: 'يرجى اختيار حالة الكفالة');
      return;
    }

    setState(() {
      _busy = true;
      _busyLabel = 'جاري تجهيز الاستيراد...';

      _importTotal = _rows.length;
      _importProcessed = 0;
      _importInserted = 0;
      _importUpdated = 0;
      _importSkipped = 0;
      _lastImportBatchId = null;
    });
    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now();

      final associationId = _selectedAssociationId!;
      final sponsorshipType = _selectedSponsorshipType!;
      final sponsorshipStatus = _selectedSponsorshipStatus!;

      final idNumbers = _rows.map((e) => e.idNumber).toList(growable: false);
      final existing = await _prefetchExistingNationalIds(db, idNumbers);

      final batchId = await db.transaction(() async {
        await db.customStatement(
          '''
          INSERT INTO import_batches (
            file_name,
            rows_total,
            rows_valid,
            rows_invalid,
            rows_duplicates,
            notes
          ) VALUES (?, ?, ?, ?, ?, ?)
          ''',
          [
            _fileName,
            _parseTotalRows,
            _parseValidRows,
            _parseInvalidRows,
            _parseDuplicateRows,
            'Beneficiaries + Sponsorships import by nationalId'
                ' | association=$associationId'
                ' | type=$sponsorshipType'
                ' | status=$sponsorshipStatus',
          ],
        );

        final idRow = await db.customSelect('SELECT last_insert_rowid() AS id').getSingle();
        final newBatchId = idRow.read<int>('id');

        int inserted = 0;
        int updated = 0;
        int skipped = 0;
        int sponsorshipsInserted = 0;
        int sponsorshipsSkipped = 0;
        int processed = 0;

        for (final r in _rows) {
          try {
            final existed = existing.contains(r.idNumber);
            await db.beneficiariesDao.upsertBeneficiaryByNationalId(
              BeneficiariesCompanion.insert(
                idNumber: r.idNumber,
                phoneNumber: r.phoneNumber,
                altPhoneNumber: r.altPhoneNumber,
                firstName: drift.Value(r.firstNameSafe),
                fatherName: drift.Value(r.fatherNameSafe),
                grandFatherName: drift.Value(r.grandFatherNameSafe),
                familyName: drift.Value(r.familyNameSafe),
                createdAt: drift.Value(now),
                updatedAt: drift.Value(now),
              ),
            );

            if (existed) {
              updated++;
            } else {
              inserted++;
              existing.add(r.idNumber);
            }
          } catch (_) {
            skipped++;
          } finally {
            processed++;
            if (mounted && processed % 25 == 0) {
              setState(() {
                _busyLabel = 'جاري الاستيراد...';
                _importProcessed = processed;
                _importInserted = inserted;
                _importUpdated = updated;
                _importSkipped = skipped;
              });
            }
          }
        }

        // Build a mapping nationalId -> beneficiaryId after upsert.
        final beneficiaryIdByNationalId = await _fetchBeneficiaryIdMap(db, idNumbers);

        // Idempotency for active sponsorships: don't create a new active sponsorship
        // if the beneficiary already has any active sponsorship.
        final hasActiveSponsorship = sponsorshipStatus == 'active'
            ? await _prefetchBeneficiariesWithActiveSponsorship(db, beneficiaryIdByNationalId.values.toList())
            : <int>{};

        for (final r in _rows) {
          final beneficiaryId = beneficiaryIdByNationalId[r.idNumber];
          if (beneficiaryId == null) {
            sponsorshipsSkipped++;
            continue;
          }

          if (sponsorshipStatus == 'active' && hasActiveSponsorship.contains(beneficiaryId)) {
            sponsorshipsSkipped++;
            continue;
          }

          try {
            await db.sponsorshipsDao.createSponsorship(
              SponsorshipsCompanion.insert(
                beneficiaryId: beneficiaryId,
                associationId: associationId,
                startDate: drift.Value(now),
                endDate: sponsorshipStatus == 'ended' ? drift.Value(now) : const drift.Value.absent(),
                status: drift.Value(sponsorshipStatus),
                sponsorshipType: drift.Value(sponsorshipType),
                importBatchId: drift.Value(newBatchId),
                updatedAt: drift.Value(now),
              ),
            );
            sponsorshipsInserted++;
            if (sponsorshipStatus == 'active') {
              hasActiveSponsorship.add(beneficiaryId);
            }
          } catch (_) {
            sponsorshipsSkipped++;
          }
        }

        setState(() {
          _importProcessed = processed;
          _importInserted = inserted;
          _importUpdated = updated;
          _importSkipped = skipped;
        });

        await db.customStatement(
          '''
          UPDATE import_batches
          SET rows_inserted = ?,
              rows_updated = ?,
              rows_skipped = ?,
              sponsorships_inserted = ?,
              sponsorships_skipped = ?
          WHERE id = ?
          ''',
          [inserted, updated, skipped, sponsorshipsInserted, sponsorshipsSkipped, newBatchId],
        );

        return newBatchId;
      });

      if (mounted) {
        setState(() {
          _lastImportBatchId = batchId;
        });
      }

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message: 'تم الاستيراد. مستفيدون: إضافة $_importInserted • تحديث $_importUpdated • تخطي $_importSkipped',
      );
    } catch (e) {
      if (!context.mounted) return;
      unawaited(HapticPatterns.error());
      EnhancedSnackbar.showError(context, message: 'فشل الاستيراد: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyLabel = null;
        });
      }
    }
  }

  Future<Map<int, int>> _fetchBeneficiaryIdMap(AppDatabase db, List<int> idNumbers) async {
    if (idNumbers.isEmpty) return const {};
    final map = <int, int>{};

    const chunkSize = 900;
    for (var i = 0; i < idNumbers.length; i += chunkSize) {
      final chunk = idNumbers.skip(i).take(chunkSize).toList(growable: false);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.customSelect(
        'SELECT id, id_number AS idNumber FROM beneficiaries WHERE id_number IN ($placeholders)',
        variables: [
          for (final id in chunk) drift.Variable.withInt(id),
        ],
        readsFrom: {db.beneficiaries},
      ).get();

      for (final r in rows) {
        map[r.read<int>('idNumber')] = r.read<int>('id');
      }
    }

    return map;
  }

  Future<Set<int>> _prefetchBeneficiariesWithActiveSponsorship(AppDatabase db, List<int> beneficiaryIds) async {
    if (beneficiaryIds.isEmpty) return <int>{};
    final result = <int>{};

    const chunkSize = 900;
    for (var i = 0; i < beneficiaryIds.length; i += chunkSize) {
      final chunk = beneficiaryIds.skip(i).take(chunkSize).toList(growable: false);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.customSelect(
        "SELECT DISTINCT beneficiary_id AS beneficiaryId FROM sponsorships WHERE status = 'active' AND beneficiary_id IN ($placeholders)",
        variables: [
          for (final id in chunk) drift.Variable.withInt(id),
        ],
        readsFrom: {db.sponsorships},
      ).get();
      for (final r in rows) {
        result.add(r.read<int>('beneficiaryId'));
      }
    }

    return result;
  }

  Future<Set<int>> _prefetchExistingNationalIds(AppDatabase db, List<int> idNumbers) async {
    if (idNumbers.isEmpty) return <int>{};

    final result = <int>{};
    const chunkSize = 900;

    for (var i = 0; i < idNumbers.length; i += chunkSize) {
      final chunk = idNumbers.skip(i).take(chunkSize).toList(growable: false);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.customSelect(
        'SELECT id_number AS idNumber FROM beneficiaries WHERE id_number IN ($placeholders)',
        variables: [
          for (final id in chunk) drift.Variable.withInt(id),
        ],
        readsFrom: {db.beneficiaries},
      ).get();

      for (final r in rows) {
        result.add(r.read<int>('idNumber'));
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _normalizeHeader(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '';

    final norm = ArabicNormalizer.normalize(trimmed)
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll('/', '');

    return norm;
  }

  static String _h(String key) => _normalizeHeader(key);

  static String _cellToString(Data? cell) {
    final v = cell?.value;
    if (v == null) return '';
    return v.toString();
  }

  static int? _parseInt(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;

    return int.tryParse(digits);
  }

  static int? _parseNationalId(Map<String, String> map) {
    // Common aliases
    const candidates = [
      'idnumber',
      'nationalid',
      'nationalidnumber',
      'id',
      'رقمالوطني',
      'الرقمالوطني',
      'رقمالهوية',
      'هوية',
    ];

    for (final c in candidates) {
      final v = map[_normalizeHeader(c)];
      final parsed = _parseInt(v);
      if (parsed != null) return parsed;
    }

    // Fallback: try any header that contains "id" or "وطني"
    for (final e in map.entries) {
      final k = e.key;
      if (k.contains('id') || k.contains('وطني') || k.contains('هوية')) {
        final parsed = _parseInt(e.value);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }
}

class _ExcelBeneficiaryRow {
  final int idNumber;
  final int phoneNumber;
  final int altPhoneNumber;
  final String firstName;
  final String fatherName;
  final String grandFatherName;
  final String familyName;

  const _ExcelBeneficiaryRow({
    required this.idNumber,
    required this.phoneNumber,
    required this.altPhoneNumber,
    required this.firstName,
    required this.fatherName,
    required this.grandFatherName,
    required this.familyName,
  });

  String get firstNameSafe => firstName.trim().isEmpty ? '' : firstName.trim();
  String get fatherNameSafe => fatherName.trim().isEmpty ? '' : fatherName.trim();
  String get grandFatherNameSafe => grandFatherName.trim().isEmpty ? '' : grandFatherName.trim();
  String get familyNameSafe => familyName.trim().isEmpty ? '' : familyName.trim();

  String get fullNameOrFallback {
    final parts = [
      firstNameSafe,
      fatherNameSafe,
      grandFatherNameSafe,
      familyNameSafe,
    ].where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) return 'مستفيد ($idNumber)';
    return parts.join(' ');
  }
}

class _SimpleDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final bool enabled;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _SimpleDropdown({
    required this.label,
    required this.value,
    required this.enabled,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
    );
  }
}

class _AssociationDropdown extends ConsumerWidget {
  final String? value;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _AssociationDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kafalatActiveAssociationsProvider);

    return state.when(
      data: (items) {
        return DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          decoration: const InputDecoration(
            labelText: 'المؤسسة الكافلة',
            border: OutlineInputBorder(),
          ),
          items: items
              .map(
                (a) => DropdownMenuItem<String>(
                  value: a.id,
                  child: Text(a.name, textAlign: TextAlign.right),
                ),
              )
              .toList(growable: false),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (e, _) => Text('فشل تحميل المؤسسات: $e', textAlign: TextAlign.right),
    );
  }
}
