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
import '../../../../features/taxonomies/domain/entities/taxonomy.dart' as tax_domain;
import '../../../../features/taxonomies/taxonomies.dart';
import '../../data/services/kafalat_excel_import_parser.dart';
import '../providers/kafalat_providers.dart';

class KafalatImportPage extends ConsumerStatefulWidget {
  const KafalatImportPage({super.key});

  @override
  ConsumerState<KafalatImportPage> createState() => _KafalatImportPageState();
}

class _KafalatImportPageState extends ConsumerState<KafalatImportPage> {
  final KafalatExcelImportParser _parser = const KafalatExcelImportParser();

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

  List<KafalatExcelSponsorshipRow> _rows = const [];
  List<String> _parseWarnings = const [];

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
                        '1) الإسم\n'
                        '2) رقم الهوية (مطلوب)\n'
                        '3) إسم المعيل\n'
                        '4) رقم هوية المعيل\n'
                        '5) إسم المؤسسة الكافلة\n'
                        '6) إسم الكافل\n'
                        '7) رقم الملف الداخلي\n'
                        '8) رقم الملف الخارجي\n'
                        '9) مدة الكفالة\n'
                        '10) فترة الكفالة\n'
                        '11) نوع الكفالة\n'
                        '12) المدينة\n'
                        '13) العنوان\n'
                        '14) إسم البنك\n'
                        '15) إسم صاحب الحساب\n'
                        '16) رقم هوية صاحب الحساب\n'
                        '17) رقم الجوال المربوط بالحساب\n'
                        '18) المتبقي\n'
                        '19) تاريخ الإضافة',
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
                                'مهم: سيتم التعرّف على المستفيد حسب رقم الهوية مع إنشاء/تحديث الكفالة بذكاء.\n'
                                'الأعمدة غير المتوفرة سيتم تعويضها تلقائياً من الإعدادات أو القيم الافتراضية.',
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
                if (_parseWarnings.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'تنبيهات الفحص: ${_parseWarnings.length}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    textAlign: TextAlign.right,
                  ),
                ],
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
                        subtitle: Text(
                          'الرقم الوطني: ${r.idNumber} • المؤسسة: ${r.associationName.isEmpty ? 'غير محددة' : r.associationName}',
                        ),
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
          TextCellValue('الإسم'),
          TextCellValue('رقم الهوية'),
          TextCellValue('إسم المعيل'),
          TextCellValue('رقم هوية المعيل'),
          TextCellValue('إسم المؤسسة الكافلة'),
          TextCellValue('إسم الكافل'),
          TextCellValue('رقم الملف الداخلي'),
          TextCellValue('رقم الملف الخارجي'),
          TextCellValue('مدة الكفالة'),
          TextCellValue('فترة الكفالة'),
          TextCellValue('نوع الكفالة'),
          TextCellValue('المدينة'),
          TextCellValue('العنوان'),
          TextCellValue('إسم البنك'),
          TextCellValue('إسم صاحب الحساب'),
          TextCellValue('رقم هوية صاحب الحساب'),
          TextCellValue('رقم الجوال المربوط بالحساب'),
          TextCellValue('المتبقي'),
          TextCellValue('تاريخ الإضافة'),
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
        _parseWarnings = const [];
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
      final result = _parser.parse(_fileBytes!);

      setState(() {
        _rows = result.rows;
        _parseTotalRows = result.totalRows;
        _parseInvalidRows = result.invalidRows;
        _parseDuplicateRows = result.duplicateRows;
        _parseValidRows = result.validRows;
        _parseWarnings = result.warnings;
      });

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message: 'تمت قراءة ${result.rows.length} صف صالحة (عرض أول 30 صف فقط).',
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
      final associations = await ref.read(kafalatActiveAssociationsProvider.future);
      final hasAnyAssociationFallback = _selectedAssociationId != null && _selectedAssociationId!.trim().isNotEmpty;
      final hasAnyAssociationInRows = _rows.any((row) => row.associationName.trim().isNotEmpty);

      if (!hasAnyAssociationFallback && !hasAnyAssociationInRows) {
        if (!context.mounted) return;
        EnhancedSnackbar.showError(context,
            message: 'يرجى اختيار المؤسسة الكافلة أو توفير عمود "إسم المؤسسة الكافلة" في الملف');
        return;
      }

      final idNumbers = _rows.map((e) => e.idNumber).toList(growable: false);
      final existing = await _prefetchExistingNationalIds(db, idNumbers);
      final associationByName = <String, String>{
        for (final association in associations) _normalizeLooseText(association.name): association.id,
      };
      final taxonomyIndex = await ref.read(bridgeTaxonomiesIndexOnceProvider.future);
      final sponsorshipTypeLookup = _buildCanonicalCodeLookup(
        taxonomyIndex[TaxonomyGroup.sponsorshipType] ?? const <tax_domain.Taxonomy>[],
      );
      final guaranteeTypeLookup = _buildCanonicalCodeLookup(
        taxonomyIndex[TaxonomyGroup.guaranteeType] ?? const <tax_domain.Taxonomy>[],
      );
      final bankNameLookup = _buildCanonicalLabelLookup(
        taxonomyIndex[TaxonomyGroup.bankName] ?? const <tax_domain.Taxonomy>[],
      );

      final result = await db.transaction(() async {
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
            'Smart sponsorship import from real Excel schema',
          ],
        );

        final idRow = await db.customSelect('SELECT last_insert_rowid() AS id').getSingle();
        final newBatchId = idRow.read<int>('id');

        int inserted = 0;
        int updated = 0;
        int skipped = 0;
        int sponsorshipsInserted = 0;
        int sponsorshipsUpdated = 0;
        int sponsorshipsSkipped = 0;
        int unresolvedAssociations = 0;
        int processed = 0;

        for (final r in _rows) {
          try {
            final existed = existing.contains(r.idNumber);
            await db.beneficiariesDao.upsertBeneficiaryByNationalId(
              BeneficiariesCompanion.insert(
                idNumber: r.idNumber,
                phoneNumber: r.phoneNumber,
                altPhoneNumber: r.altPhoneNumber,
                firstName: drift.Value(r.firstName),
                fatherName: drift.Value(r.fatherName),
                grandFatherName: drift.Value(r.grandFatherName),
                familyName: drift.Value(r.familyName),
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
        final existingSponsorshipBySignature = await _prefetchExistingSponsorshipSignatures(
          db,
          beneficiaryIdByNationalId.values.toList(growable: false),
        );

        // Idempotency for active sponsorships: don't create a new active sponsorship
        // if the beneficiary already has any active sponsorship.
        final hasActiveSponsorship = await _prefetchBeneficiariesWithActiveSponsorship(
          db,
          beneficiaryIdByNationalId.values.toList(growable: false),
        );

        for (final r in _rows) {
          final beneficiaryId = beneficiaryIdByNationalId[r.idNumber];
          if (beneficiaryId == null) {
            sponsorshipsSkipped++;
            continue;
          }

          final associationId = _resolveAssociationId(
            rowAssociationName: r.associationName,
            fallbackAssociationId: _selectedAssociationId,
            associations: associations,
            exactLookup: associationByName,
          );

          if (associationId == null) {
            unresolvedAssociations++;
            sponsorshipsSkipped++;
            continue;
          }

          final sponsorshipType = _resolveCanonicalTaxonomyCode(
            rawCode: r.sponsorshipTypeCode,
            fallbackCode: _selectedSponsorshipType,
            lookup: sponsorshipTypeLookup,
            defaultCode: 'monthly',
          );
          final guaranteeType = _resolveCanonicalTaxonomyCodeOrNull(
            rawCode: r.sponsorshipTypeCode,
            fallbackCode: _selectedSponsorshipType,
            lookup: guaranteeTypeLookup,
          );
          final canonicalBankName = _resolveCanonicalTaxonomyLabel(
            rawLabel: r.bankName,
            lookup: bankNameLookup,
          );
          final status = _resolveSponsorshipStatus(
            fallbackStatus: _selectedSponsorshipStatus,
            inferredEndDate: r.inferredPeriodEnd,
            now: now,
          );

          final startDate = r.inferredPeriodStart ?? r.addedAt ?? now;
          final endDate = status == 'ended' ? (r.inferredPeriodEnd ?? now) : r.inferredPeriodEnd;

          final notes = [
            if (r.sponsorshipPeriodText.trim().isNotEmpty) 'فترة الكفالة: ${r.sponsorshipPeriodText.trim()}',
            if (r.remainingAmount != null) 'المتبقي: ${r.remainingAmount}',
          ].join(' | ');

          final signature = _buildSponsorshipSignature(
            beneficiaryId: beneficiaryId,
            associationId: associationId,
            internalFileNo: r.internalFileNo,
            externalFileNo: r.externalFileNo,
            sponsorName: r.sponsorName,
          );

          final existingFileNo = existingSponsorshipBySignature[signature];

          if (existingFileNo == null && status == 'active' && hasActiveSponsorship.contains(beneficiaryId)) {
            sponsorshipsSkipped++;
            continue;
          }

          try {
            final companion = SponsorshipsCompanion(
              beneficiaryId: drift.Value(beneficiaryId),
              associationId: drift.Value(associationId),
              sponsorName: drift.Value(r.sponsorName.isEmpty ? null : r.sponsorName),
              internalFileNo: drift.Value(r.internalFileNo.isEmpty ? null : r.internalFileNo),
              externalFileNo: drift.Value(r.externalFileNo.isEmpty ? null : r.externalFileNo),
              guardianName: drift.Value(r.guardianName.isEmpty ? null : r.guardianName),
              guardianIdNumber: drift.Value(r.guardianIdNumber),
              guardianPhone: drift.Value(r.accountLinkedMobile.isEmpty ? null : r.accountLinkedMobile),
              durationMonths: drift.Value(r.durationMonths),
              startDate: drift.Value(startDate),
              endDate: drift.Value(endDate),
              status: drift.Value(status),
              sponsorshipType: drift.Value(sponsorshipType),
              guaranteeType: drift.Value(guaranteeType),
              bankName: drift.Value(canonicalBankName),
              accountHolderName: drift.Value(r.accountHolderName.isEmpty ? null : r.accountHolderName),
              accountHolderIdNumber: drift.Value(r.accountHolderIdNumber),
              city: drift.Value(r.city.isEmpty ? null : r.city),
              address: drift.Value(r.address.isEmpty ? null : r.address),
              importBatchId: drift.Value(newBatchId),
              notes: drift.Value(notes.isEmpty ? null : notes),
              updatedAt: drift.Value(now),
            );

            if (existingFileNo != null) {
              await db.sponsorshipsDao.updateSponsorship(
                fileNo: existingFileNo,
                companion: companion,
              );
              sponsorshipsUpdated++;
            } else {
              await db.sponsorshipsDao.createSponsorship(companion);
              sponsorshipsInserted++;
            }

            if (status == 'active') {
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

        return (
          batchId: newBatchId,
          inserted: inserted,
          updated: updated,
          skipped: skipped,
          sponsorshipsInserted: sponsorshipsInserted,
          sponsorshipsUpdated: sponsorshipsUpdated,
          sponsorshipsSkipped: sponsorshipsSkipped,
          unresolvedAssociations: unresolvedAssociations,
        );
      });

      if (mounted) {
        setState(() {
          _lastImportBatchId = result.batchId;
          _importInserted = result.inserted;
          _importUpdated = result.updated;
          _importSkipped = result.skipped;
          _busyLabel = null;
        });
      }

      if (!context.mounted) return;
      unawaited(HapticPatterns.success());
      EnhancedSnackbar.showSuccess(
        context,
        message:
            'تم الاستيراد. مستفيدون: إضافة ${result.inserted} • تحديث ${result.updated} • تخطي ${result.skipped} | '
            'كفالات: إضافة ${result.sponsorshipsInserted} • تحديث ${result.sponsorshipsUpdated} • تخطي ${result.sponsorshipsSkipped}'
            '${result.unresolvedAssociations > 0 ? ' • جمعيات غير مطابقة: ${result.unresolvedAssociations}' : ''}',
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

  Future<Map<String, int>> _prefetchExistingSponsorshipSignatures(AppDatabase db, List<int> beneficiaryIds) async {
    if (beneficiaryIds.isEmpty) return const {};

    final map = <String, int>{};
    const chunkSize = 900;

    for (var i = 0; i < beneficiaryIds.length; i += chunkSize) {
      final chunk = beneficiaryIds.skip(i).take(chunkSize).toList(growable: false);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.customSelect(
        '''
        SELECT
          file_no AS fileNo,
          beneficiary_id AS beneficiaryId,
          association_id AS associationId,
          internal_file_no AS internalFileNo,
          external_file_no AS externalFileNo,
          sponsor_name AS sponsorName
        FROM sponsorships
        WHERE beneficiary_id IN ($placeholders)
        ''',
        variables: [for (final id in chunk) drift.Variable.withInt(id)],
        readsFrom: {db.sponsorships},
      ).get();

      for (final row in rows) {
        final signature = _buildSponsorshipSignature(
          beneficiaryId: row.read<int>('beneficiaryId'),
          associationId: row.read<String>('associationId'),
          internalFileNo: row.read<String?>('internalFileNo') ?? '',
          externalFileNo: row.read<String?>('externalFileNo') ?? '',
          sponsorName: row.read<String?>('sponsorName') ?? '',
        );

        map[signature] = row.read<int>('fileNo');
      }
    }

    return map;
  }

  String _buildSponsorshipSignature({
    required int beneficiaryId,
    required String associationId,
    required String internalFileNo,
    required String externalFileNo,
    required String sponsorName,
  }) {
    return [
      beneficiaryId.toString(),
      _normalizeLooseText(associationId),
      _normalizeLooseText(internalFileNo),
      _normalizeLooseText(externalFileNo),
      _normalizeLooseText(sponsorName),
    ].join('|');
  }

  String _normalizeLooseText(String raw) {
    return ArabicNormalizer.normalize(raw).trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Map<String, String> _buildCanonicalCodeLookup(List<tax_domain.Taxonomy> taxonomies) {
    final lookup = <String, String>{};
    for (final taxonomy in taxonomies) {
      final code = taxonomy.code.trim();
      final label = taxonomy.label.trim();
      if (code.isEmpty) continue;

      lookup[_normalizeLooseText(code)] = code;
      if (label.isNotEmpty) {
        lookup[_normalizeLooseText(label)] = code;
      }
    }
    return lookup;
  }

  Map<String, String> _buildCanonicalLabelLookup(List<tax_domain.Taxonomy> taxonomies) {
    final lookup = <String, String>{};
    for (final taxonomy in taxonomies) {
      final label = taxonomy.label.trim();
      final code = taxonomy.code.trim();
      if (label.isEmpty) continue;

      lookup[_normalizeLooseText(label)] = label;
      if (code.isNotEmpty) {
        lookup[_normalizeLooseText(code)] = label;
      }
    }
    return lookup;
  }

  String _resolveCanonicalTaxonomyCode({
    required String? rawCode,
    required String? fallbackCode,
    required Map<String, String> lookup,
    required String defaultCode,
  }) {
    final candidates = <String?>[rawCode, fallbackCode];

    for (final candidate in candidates) {
      final normalized = _normalizeLooseText(candidate ?? '');
      if (normalized.isEmpty) continue;

      final canonical = lookup[normalized];
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    return defaultCode;
  }

  String? _resolveCanonicalTaxonomyCodeOrNull({
    required String? rawCode,
    required String? fallbackCode,
    required Map<String, String> lookup,
  }) {
    final candidates = <String?>[rawCode, fallbackCode];

    for (final candidate in candidates) {
      final normalized = _normalizeLooseText(candidate ?? '');
      if (normalized.isEmpty) continue;

      final canonical = lookup[normalized];
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    return null;
  }

  String? _resolveCanonicalTaxonomyLabel({
    required String rawLabel,
    required Map<String, String> lookup,
  }) {
    final normalized = _normalizeLooseText(rawLabel);
    if (normalized.isEmpty) return null;

    return lookup[normalized] ?? rawLabel.trim();
  }

  String? _resolveAssociationId({
    required String rowAssociationName,
    required String? fallbackAssociationId,
    required List<Association> associations,
    required Map<String, String> exactLookup,
  }) {
    final normalizedRowName = _normalizeLooseText(rowAssociationName);
    if (normalizedRowName.isNotEmpty) {
      final exact = exactLookup[normalizedRowName];
      if (exact != null) return exact;

      for (final association in associations) {
        final normalizedAssociationName = _normalizeLooseText(association.name);
        if (normalizedAssociationName.contains(normalizedRowName) ||
            normalizedRowName.contains(normalizedAssociationName)) {
          return association.id;
        }
      }
    }

    final fallback = fallbackAssociationId?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return null;
  }

  String _resolveSponsorshipStatus({
    required String? fallbackStatus,
    required DateTime? inferredEndDate,
    required DateTime now,
  }) {
    if (inferredEndDate != null && inferredEndDate.isBefore(now)) {
      return 'ended';
    }

    final normalized = fallbackStatus?.trim().toLowerCase();
    if (normalized == 'paused' || normalized == 'ended' || normalized == 'active') {
      return normalized!;
    }

    return 'active';
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
