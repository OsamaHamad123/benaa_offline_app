import 'dart:async' show unawaited;
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../data/db/drift_database.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('استيراد مستفيدين (Excel)')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تنبيه',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'سيتم إضافة/تحديث المستفيدين حسب الرقم الوطني فقط (بدون إنشاء كفالات تلقائياً).',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            child: ListTile(
              leading: Icon(
                _fileBytes == null ? Icons.insert_drive_file_outlined : Icons.description_outlined,
              ),
              title: Text(_fileName ?? 'اختر ملف Excel'),
              subtitle: Text(
                _fileBytes == null
                    ? 'صيغة .xlsx فقط'
                    : (_rows.isEmpty
                        ? 'الملف جاهز للقراءة'
                        : 'تمت قراءة ${_rows.length} صف • صالحة: $_parseValidRows • مكررة: $_parseDuplicateRows • غير صالحة: $_parseInvalidRows'),
              ),
              trailing: OutlinedButton.icon(
                onPressed: _busy ? null : () => _pickFile(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('اختيار'),
              ),
            ),
          ),
          if (_busy) ...[
            SizedBox(height: 10.h),
            const LinearProgressIndicator(),
            if (_busyLabel != null) ...[
              SizedBox(height: 6.h),
              Text(
                _busyLabel!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: (_busy || _fileBytes == null) ? null : () => _parseExcel(context),
              icon: const Icon(Icons.visibility_outlined),
              label: Text(_busy ? 'جاري القراءة...' : 'قراءة الملف'),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_busy || _rows.isEmpty) ? null : () => _importRows(context),
              icon: const Icon(Icons.download_done_outlined),
              label: Text(_busy ? 'جاري الاستيراد...' : 'استيراد إلى النظام'),
            ),
          ),
          if (_importTotal > 0) ...[
            SizedBox(height: 12.h),
            Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقدم الاستيراد',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_importProcessed / $_importTotal',
                            style: theme.textTheme.bodyMedium,
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
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                'معاينة البيانات',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
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
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(r.fullNameOrFallback),
                    subtitle: Text('الرقم الوطني: ${r.idNumber}'),
                  ),
                );
              },
            ),
        ],
      ),
    );
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
            'Beneficiaries import by nationalId only (no auto sponsorships)',
          ],
        );

        final idRow = await db.customSelect('SELECT last_insert_rowid() AS id').getSingle();
        final newBatchId = idRow.read<int>('id');

        int inserted = 0;
        int updated = 0;
        int skipped = 0;
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
              rows_skipped = ?
          WHERE id = ?
          ''',
          [inserted, updated, skipped, newBatchId],
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
        message: 'تم الاستيراد. إضافة: $_importInserted • تحديث: $_importUpdated • تخطي: $_importSkipped',
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
