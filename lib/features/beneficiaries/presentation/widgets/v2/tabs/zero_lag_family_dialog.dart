import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Hoisted static const config to avoid reallocations
const List<ButtonSegment<int>> _genderSegments = [
  ButtonSegment(value: 1, label: Text('ذكر'), icon: Icon(Icons.boy, size: 18)),
  ButtonSegment(
    value: 2,
    label: Text('أنثى'),
    icon: Icon(Icons.girl, size: 18),
  ),
];

const Map<int, String> _deathCauseOptions = {
  1: 'حرب',
  2: 'مرض',
  3: 'حادث',
  8: 'أخرى',
};

const Map<int, String> _docTypeOptions = {
  1: 'شهادة وفاة',
  2: 'تقرير طبي',
  3: 'إفادة',
};

const Map<int, String> _healthStatusOptions = {
  1: 'سليم',
  2: 'مريض',
  3: 'مزمن',
  4: 'معاق',
  5: 'غير محدد',
};

// Debug helper: lightweight rebuild logger used only for performance investigation.
class RebuildLogger extends StatefulWidget {
  final String name;
  final Widget child;
  const RebuildLogger({super.key, required this.name, required this.child});

  @override
  State<RebuildLogger> createState() => _RebuildLoggerState();
}

class _RebuildLoggerState extends State<RebuildLogger> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    _count++;
    // Only track and print in debug mode to avoid runtime overhead in release.
    if (kDebugMode) {
      _debugRebuildCounts[widget.name] =
          (_debugRebuildCounts[widget.name] ?? 0) + 1;
      debugPrint('RebuildLogger(${widget.name}) build #$_count');
    }
    return widget.child;
  }
}

// Debug-only global counters (used by tests to assert rebuild counts).
final Map<String, int> _debugRebuildCounts = {};
void debugRebuildCountsReset() {
  if (kDebugMode) {
    _debugRebuildCounts.clear();
  }
}

Map<String, int> debugGetRebuildCounts() => Map.from(_debugRebuildCounts);

/// ⚡ ZERO LAG - Absolute Maximum Performance
///
/// Radical optimizations:
/// 1. NO ScreenUtil - direct MediaQuery
/// 2. NO decorations during typing
/// 3. Minimal widget tree
/// 4. Immediate keyboard response
class ZeroLagFamilyDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const ZeroLagFamilyDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  ConsumerState<ZeroLagFamilyDialog> createState() =>
      _ZeroLagFamilyDialogState();
}

class _ZeroLagFamilyDialogState extends ConsumerState<ZeroLagFamilyDialog> {
  // Controllers
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _secondNameCtrl;
  late final TextEditingController _thirdNameCtrl;
  late final TextEditingController _familyNameCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _notesCtrl;

  // ValueNotifiers
  late final ValueNotifier<int> _gender;
  late final ValueNotifier<DateTime?> _date;
  late final ValueNotifier<int?> _healthStatus;
  late final ValueNotifier<int?> _deathCause;
  late final ValueNotifier<int?> _docType;
  late final ValueNotifier<File?> _selectedFile;
  // FocusNodes for fields - reuse to avoid reallocation and reduce focus churn
  late final FocusNode _firstNameFocus;
  late final FocusNode _secondNameFocus;
  late final FocusNode _thirdNameFocus;
  late final FocusNode _familyNameFocus;
  late final FocusNode _nationalIdFocus;
  // Scroll controller to keep focused field visible without heavy layout
  late final ScrollController _scrollCtrl;
  // Keys for each field to locate their contexts for ensureVisible
  late final GlobalKey _firstNameKey;
  late final GlobalKey _secondNameKey;
  late final GlobalKey _thirdNameKey;
  late final GlobalKey _familyNameKey;
  late final GlobalKey _nationalIdKey;
  late final Map<FocusNode, GlobalKey> _focusKeyMap;
  // Hoisted widgets to avoid rebuilding large static subtrees
  late Widget _hoistedHeader;
  late Widget _hoistedDocumentSection;
  // Instrumentation timers for diagnosing dialog open jank
  late final Stopwatch _syncInitTimer;
  late final Stopwatch _initTimer;
  bool _didLogFirstFrame = false;

  @override
  void initState() {
    // start synchronous init timer
    _syncInitTimer = Stopwatch()..start();
    _initTimer = Stopwatch();
    super.initState();
    final m = widget.existingMember;

    _firstNameCtrl = TextEditingController(text: m?['firstName']);
    _secondNameCtrl = TextEditingController(text: m?['secondName']);
    _thirdNameCtrl = TextEditingController(text: m?['thirdName']);
    _familyNameCtrl = TextEditingController(text: m?['familyName']);
    _nationalIdCtrl = TextEditingController(
      text: m?['nationalId']?.toString() ?? m?['orphanNationalId']?.toString(),
    );
    _notesCtrl = TextEditingController(text: m?['notes']);

    _gender = ValueNotifier<int>(m?['gender'] ?? 1);
    _date = ValueNotifier<DateTime?>(
      m?['birthDate'] as DateTime? ?? m?['deathDate'] as DateTime?,
    );
    _healthStatus = ValueNotifier<int?>(m?['healthStatus']);
    _deathCause = ValueNotifier<int?>(m?['deathCause']);
    _docType = ValueNotifier<int?>(m?['documentType']);
    _selectedFile = ValueNotifier<File?>(null);
    // Initialize focus nodes
    _firstNameFocus = FocusNode();
    _secondNameFocus = FocusNode();
    _thirdNameFocus = FocusNode();
    _familyNameFocus = FocusNode();
    _nationalIdFocus = FocusNode();
    // Initialize scroll controller and keys
    _scrollCtrl = ScrollController();
    _firstNameKey = GlobalKey();
    _secondNameKey = GlobalKey();
    _thirdNameKey = GlobalKey();
    _familyNameKey = GlobalKey();
    _nationalIdKey = GlobalKey();
    _focusKeyMap = {
      _firstNameFocus: _firstNameKey,
      _secondNameFocus: _secondNameKey,
      _thirdNameFocus: _thirdNameKey,
      _familyNameFocus: _familyNameKey,
      _nationalIdFocus: _nationalIdKey,
    };
    // Ensure focused field is visible when keyboard opens
    for (final fn in _focusKeyMap.keys) {
      fn.addListener(() {
        if (fn.hasFocus) _ensureVisibleFor(fn);
      });
    }

    // Initially set lightweight placeholders to avoid heavy widget construction
    _hoistedHeader = const SizedBox.shrink();

    // Placeholder for document section - fill after first frame
    _hoistedDocumentSection = const SizedBox.shrink();

    // Defer construction of hoisted heavy widgets until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        final title = widget.isDeceased
            ? (widget.presetDeceasedType == 1
                  ? 'إضافة أب متوفى'
                  : 'إضافة أم متوفاة')
            : 'إضافة يتيم';
        _hoistedHeader = RebuildLogger(
          name: 'header',
          child: Builder(
            builder: (context) {
              final primary = Theme.of(context).primaryColor;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isDeceased ? Icons.person_off : Icons.child_care,
                      color: primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        _hoistedDocumentSection = Builder(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'رفع الوثيقة',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RebuildLogger(
                  name: 'document_upload',
                  child: ValueListenableBuilder<File?>(
                    valueListenable: _selectedFile,
                    builder: (context, file, _) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: file == null
                          ? InkWell(
                              onTap: _pickFile,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'اضغط لرفع الوثيقة (PDF, JPG, PNG)',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    file.path.split('/').last,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade700,
                                  ),
                                  onPressed: () {
                                    _selectedFile.value = null;
                                  },
                                  tooltip: 'حذف',
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    });
    // measure synchronous init work
    _syncInitTimer.stop();
    if (kDebugMode) {
      debugPrint(
        'ZeroLagFamilyDialog synchronous init took ${_syncInitTimer.elapsedMilliseconds}ms',
      );
    }
    // start wall timer to first frame
    _initTimer.start();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _secondNameCtrl.dispose();
    _thirdNameCtrl.dispose();
    _familyNameCtrl.dispose();
    _nationalIdCtrl.dispose();
    _notesCtrl.dispose();
    _gender.dispose();
    _date.dispose();
    _healthStatus.dispose();
    _deathCause.dispose();
    _docType.dispose();
    _selectedFile.dispose();
    _firstNameFocus.dispose();
    _secondNameFocus.dispose();
    _thirdNameFocus.dispose();
    _familyNameFocus.dispose();
    _nationalIdFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _ensureVisibleFor(FocusNode node) {
    final key = _focusKeyMap[node];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    // Slight delay lets the focus settle before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 120),
        alignment: 0.12,
        curve: Curves.easeInOut,
      );
    });
  }

  /// Pick document file
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        _selectedFile.value = file;
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الملف: $e')));
      }
    }
  }

  void _save() {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _familyNameCtrl.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الاسم الأول والعائلة')),
      );
      return;
    }

    final data = <String, dynamic>{
      'firstName': _firstNameCtrl.text.trim(),
      'secondName': _secondNameCtrl.text.trim(),
      'thirdName': _thirdNameCtrl.text.trim(),
      'familyName': _familyNameCtrl.text.trim(),
      'gender': _gender.value,
      'notes': _notesCtrl.text.trim(),
    };

    if (widget.isDeceased) {
      data.addAll({
        'deceasedType': widget.presetDeceasedType,
        'nationalId': int.tryParse(_nationalIdCtrl.text.trim()),
        'deathDate': _date.value ?? DateTime.now(),
        'deathCause': _deathCause.value ?? 8,
        'documentType': _docType.value,
        'documentFile': _selectedFile.value, // ملف الوثيقة
      });
    } else {
      data.addAll({
        'orphanNationalId': int.tryParse(_nationalIdCtrl.text.trim()),
        'birthDate': _date.value ?? DateTime.now(),
        'age': _date.value != null
            ? DateTime.now().difference(_date.value!).inDays ~/ 365
            : 0,
        'healthStatus': _healthStatus.value ?? 5,
      });
    }

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Log time-to-first-frame relative to initState to detect UI freeze on open
    if (!_didLogFirstFrame && kDebugMode) {
      _didLogFirstFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initTimer.stop();
        debugPrint(
          'ZeroLagFamilyDialog time-to-first-frame ${_initTimer.elapsedMilliseconds}ms',
        );
      });
    }

    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      // Prevent the dialog from resizing when the keyboard appears.
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Container(
          width: size.width > 600 ? 500 : size.width - 32,
          constraints: BoxConstraints(maxHeight: size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (hoisted)
              _hoistedHeader,

              // Content
              Expanded(
                // Use a single-child scroll view + Column to minimize
                // expensive ListView rebuilding when the keyboard appears.
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(12),
                  child: RebuildLogger(
                    name: 'dialog_content',
                    child: Column(
                      children: [
                        // Name Fields
                        const Text(
                          'الاسم الكامل',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                key: _firstNameKey,
                                child: _FastField(
                                  _firstNameCtrl,
                                  'الأول *',
                                  focusNode: _firstNameFocus,
                                  onSubmitted: (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_secondNameFocus),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                key: _secondNameKey,
                                child: _FastField(
                                  _secondNameCtrl,
                                  'الأب',
                                  focusNode: _secondNameFocus,
                                  onSubmitted: (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_thirdNameFocus),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                key: _thirdNameKey,
                                child: _FastField(
                                  _thirdNameCtrl,
                                  'الجد',
                                  focusNode: _thirdNameFocus,
                                  onSubmitted: (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_familyNameFocus),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                key: _familyNameKey,
                                child: _FastField(
                                  _familyNameCtrl,
                                  'العائلة *',
                                  focusNode: _familyNameFocus,
                                  onSubmitted: (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_nationalIdFocus),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gender (minimized rebuild scope)
                        RebuildLogger(
                          name: 'gender_section',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الجنس *'),
                              const SizedBox(height: 8),
                              ValueListenableBuilder<int>(
                                valueListenable: _gender,
                                builder: (_, gender, __) =>
                                    SegmentedButton<int>(
                                      segments: _genderSegments,
                                      selected: {gender},
                                      onSelectionChanged: (v) {
                                        HapticFeedback.selectionClick();
                                        _gender.value = v.first;
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // National ID
                        Container(
                          key: _nationalIdKey,
                          child: _FastField(
                            _nationalIdCtrl,
                            'الرقم الوطني (9 أرقام)',
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            focusNode: _nationalIdFocus,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date
                        ValueListenableBuilder<DateTime?>(
                          valueListenable: _date,
                          builder: (context, date, _) => InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) _date.value = picked;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      date != null
                                          ? '${date.day}/${date.month}/${date.year}'
                                          : (widget.isDeceased
                                                ? 'تاريخ الوفاة - اضغط للاختيار'
                                                : 'تاريخ الميلاد - اضغط للاختيار'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Conditional Fields
                        if (widget.isDeceased) ...[
                          ValueListenableBuilder<int?>(
                            valueListenable: _deathCause,
                            builder: (_, cause, __) => _ChipSelector(
                              label: 'سبب الوفاة',
                              options: _deathCauseOptions,
                              selected: cause,
                              onSelect: (v) => _deathCause.value = v,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<int?>(
                            valueListenable: _docType,
                            builder: (_, type, __) => _ChipSelector(
                              label: 'نوع الوثيقة',
                              options: _docTypeOptions,
                              selected: type,
                              onSelect: (v) => _docType.value = v,
                            ),
                          ),
                        ] else ...[
                          ValueListenableBuilder<int?>(
                            valueListenable: _healthStatus,
                            builder: (_, status, __) => _ChipSelector(
                              label: 'الحالة الصحية',
                              options: _healthStatusOptions,
                              selected: status,
                              onSelect: (v) => _healthStatus.value = v,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Document Upload Section (hoisted)
                        if (widget.isDeceased) ...[_hoistedDocumentSection],
                        const SizedBox(height: 16),

                        // Notes
                        TextField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('حفظ'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ ZERO LAG TextField - Absolute Minimum Overhead
// ═══════════════════════════════════════════════════════════════════════════

class _FastField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const _FastField(
    this.controller,
    this.label, {
    this.keyboardType,
    this.maxLength,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Lightweight field: label above + container with minimal decoration.
    // This avoids InputDecorator animations and heavy rebuilds when keyboard appears.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, height: 1.1)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            onSubmitted: onSubmitted,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              counterText: '',
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ Fast Chip Selector
// ═══════════════════════════════════════════════════════════════════════════

class _ChipSelector extends StatelessWidget {
  final String label;
  final Map<int, String> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _ChipSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.entries.map((e) {
            final isSelected = selected == e.key;
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(e.key);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
