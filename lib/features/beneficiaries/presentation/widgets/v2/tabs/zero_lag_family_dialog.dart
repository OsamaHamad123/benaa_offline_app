import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'family_dialog_widgets.dart';
import '../../../providers/beneficiary_dependencies.dart';

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
// Toggle this during manual debugging to see rebuild counts.
bool _enableRebuildLogging = false;

class RebuildLogger extends StatefulWidget {
  final String name;
  final Widget child;
  const RebuildLogger({required this.name, required this.child, super.key});

  @override
  State<RebuildLogger> createState() => _RebuildLoggerState();
}

class _RebuildLoggerState extends State<RebuildLogger> {
  // simple counter removed to avoid unused variable lint; rebuild counts
  // are tracked via the debug map only.

  @override
  Widget build(BuildContext context) {
    // Rebuild tracking is enabled in debug mode for tests and instrumentation.
    if (kDebugMode && _enableRebuildLogging) {
      _debugRebuildCounts[widget.name] =
          (_debugRebuildCounts[widget.name] ?? 0) + 1;
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
    required this.onSave, super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
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
  late final ValueNotifier<bool> _isFetchingCivil;
  late final ValueNotifier<String?> _civilStatus;
  late final ValueNotifier<bool> _hideSearchButton;
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
  Timer? _delayedDocumentTimer;

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
    _isFetchingCivil = ValueNotifier<bool>(false);
    _civilStatus = ValueNotifier<String?>(null);
    _hideSearchButton = ValueNotifier<bool>(false);
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
    // Listener registration is deferred until after first frame to avoid
    // firing ensureVisible during initial focus and causing input lag.

    // Initially set lightweight placeholders to avoid heavy widget construction
    _hoistedHeader = const SizedBox.shrink();

    // Placeholder for document section - fill after first frame
    _hoistedDocumentSection = const SizedBox.shrink();

    // Defer construction of hoisted heavy widgets until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Hoist header first frame (lightweight)
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
      });

      // Register focus listeners after the first frame to avoid immediate
      // ensureVisible work during dialog open typing measurements.
      for (final fn in _focusKeyMap.keys) {
        fn.addListener(() {
          if (fn.hasFocus) {
            // Defer to microtask to avoid blocking typing
            Future.microtask(() => _ensureVisibleFor(fn));
          }
        });
      }

      // Defer the document section to a later microtask to avoid adding
      // extra synchronous work on the first frame. Use a cancellable Timer
      // so tests can dispose without pending timers.
      _delayedDocumentTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
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
                                  const Icon(Icons.check_circle, color: Colors.green),
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
    });
    // measure synchronous init work
    _syncInitTimer.stop();
    if (kDebugMode && _enableRebuildLogging) {
      debugPrint(
        'ZeroLagFamilyDialog synchronous init took ${_syncInitTimer.elapsedMilliseconds}ms',
      );
    }
    // start wall timer to first frame
    _initTimer.start();
  }

  @override
  void dispose() {
    _delayedDocumentTimer?.cancel();
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
    _isFetchingCivil.dispose();
    _civilStatus.dispose();
    _hideSearchButton.dispose();
    _firstNameFocus.dispose();
    _secondNameFocus.dispose();
    _thirdNameFocus.dispose();
    _familyNameFocus.dispose();
    _nationalIdFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Scroll to keep focused field visible
  // Simplified for maximum performance - removed post-frame delay
  void _ensureVisibleFor(FocusNode node) {
    final key = _focusKeyMap[node];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    // Instant scroll without delay for better responsiveness
    Scrollable.ensureVisible(ctx, alignment: 0.12);
  }

  /// 🔍 Fetch from Civil Registry
  Future<void> _fetchFromCivilRegistry() async {
    final nationalId = _nationalIdCtrl.text.trim();
    if (nationalId.length != 9) {
      _civilStatus.value = 'الرقم الوطني يجب أن يكون 9 أرقام';
      return;
    }

    _isFetchingCivil.value = true;
    _civilStatus.value = 'جاري البحث في السجل المدني...';

    try {
      await ref
          .read(civilRegistryProvider.notifier)
          .fetchByNationalId(nationalId);

      final civilRegistryState = ref.read(civilRegistryProvider);

      if (civilRegistryState.isSuccess && civilRegistryState.person != null) {
        final person = civilRegistryState.person!;

        _firstNameCtrl.text = person.firstName;
        _secondNameCtrl.text = person.fatherName;
        _thirdNameCtrl.text = person.grandfatherName ?? '';
        _familyNameCtrl.text = person.lastName;
        _gender.value = person.gender == 'ذكر' ? 1 : 2;

        if (!widget.isDeceased && person.birthDate != null) {
          _date.value = person.birthDate;
        }

        _isFetchingCivil.value = false;
        _civilStatus.value = '✅ تم العثور على البيانات وملؤها تلقائياً';

        // Hide button after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _hideSearchButton.value = true;
          }
        });

        HapticFeedback.lightImpact();
      } else {
        _isFetchingCivil.value = false;
        _civilStatus.value = '❌ لم يتم العثور على بيانات في السجل المدني';
      }
    } catch (e) {
      _isFetchingCivil.value = false;
      _civilStatus.value = '❌ خطأ في البحث: ${e.toString()}';
    }
  }

  void _handleNationalIdChanged(String value) {
    // Reset button visibility when ID changes
    if (value.length != 9) {
      _hideSearchButton.value = false;
      _civilStatus.value = null;
    }

    if (value.length == 9 && !_isFetchingCivil.value) {
      _fetchFromCivilRegistry();
    }
  }

  /// Pick document file
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
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

  void _save() async {
    // Validation محسّن
    if (_firstNameCtrl.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى إدخال الاسم الأول'),
          backgroundColor: Colors.orange,
        ),
      );
      _firstNameFocus.requestFocus();
      return;
    }

    if (_familyNameCtrl.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى إدخال اسم العائلة'),
          backgroundColor: Colors.orange,
        ),
      );
      _familyNameFocus.requestFocus();
      return;
    }

    // Validation للرقم الوطني
    final nationalId = _nationalIdCtrl.text.trim();
    if (nationalId.isNotEmpty && nationalId.length != 9) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الرقم الوطني يجب أن يكون 9 أرقام'),
          backgroundColor: Colors.orange,
        ),
      );
      _nationalIdFocus.requestFocus();
      return;
    }

    // تأكيد قبل الحفظ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          widget.isDeceased ? Icons.person_off : Icons.child_care,
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
        title: Text(
          widget.isDeceased ? 'تأكيد إضافة متوفى' : 'تأكيد إضافة يتيم',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmationRow(
              Icons.person,
              'الاسم',
              '${_firstNameCtrl.text} ${_familyNameCtrl.text}',
            ),
            if (nationalId.isNotEmpty)
              _buildConfirmationRow(Icons.badge, 'الرقم الوطني', nationalId),
            _buildConfirmationRow(
              _gender.value == 1 ? Icons.male : Icons.female,
              'الجنس',
              _gender.value == 1 ? 'ذكر' : 'أنثى',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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

    // تأكيد النجاح
    HapticFeedback.mediumImpact();
    widget.onSave(data);
    Navigator.pop(context);

    // رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isDeceased
              ? '✅ تم إضافة المتوفى بنجاح'
              : '✅ تم إضافة اليتيم بنجاح',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log time-to-first-frame relative to initState to detect UI freeze on open
    if (!_didLogFirstFrame && kDebugMode) {
      _didLogFirstFrame = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initTimer.stop();
        if (_enableRebuildLogging) {
          debugPrint(
            'ZeroLagFamilyDialog time-to-first-frame ${_initTimer.elapsedMilliseconds}ms',
          );
        }
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
                        // Name Fields - استخدام الـ widget الجديد
                        NameFieldsSection(
                          firstNameController: _firstNameCtrl,
                          secondNameController: _secondNameCtrl,
                          thirdNameController: _thirdNameCtrl,
                          familyNameController: _familyNameCtrl,
                          firstNameFocus: _firstNameFocus,
                          secondNameFocus: _secondNameFocus,
                          thirdNameFocus: _thirdNameFocus,
                          familyNameFocus: _familyNameFocus,
                        ),
                        const SizedBox(height: 16),

                        // National ID - استخدام الـ widget الجديد مع civil registry
                        ValueListenableBuilder3<bool, String?, bool>(
                          first: _isFetchingCivil,
                          second: _civilStatus,
                          third: _hideSearchButton,
                          builder:
                              (context, isFetching, status, hideButton, _) {
                            return NationalIdWithCivilRegistry(
                              nationalIdController: _nationalIdCtrl,
                              isFetching: isFetching,
                              statusMessage: status,
                              hideButtonAfterFetch: hideButton,
                              onFetch: _fetchFromCivilRegistry,
                              onChanged: _handleNationalIdChanged,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Gender - استخدام الـ widget الجديد
                        RebuildLogger(
                          name: 'gender_section',
                          child: ValueListenableBuilder<int>(
                            valueListenable: _gender,
                            builder: (_, gender, __) => GenderSelector(
                              selectedGender: gender,
                              onChanged: (value) => _gender.value = value,
                            ),
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

  // Helper method للـ confirmation dialog
  Widget _buildConfirmationRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ ZERO LAG TextField - Absolute Minimum Overhead
// ═══════════════════════════════════════════════════════════════════════════

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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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

/// ⚡ Custom ValueListenableBuilder for 3 values
class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final ValueNotifier<C> third;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child)
      builder;
  final Widget? child;

  const ValueListenableBuilder3({
    required this.first, required this.second, required this.third, required this.builder, super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, _) {
            return ValueListenableBuilder<C>(
              valueListenable: third,
              builder: (context, c, _) {
                return builder(context, a, b, c, child);
              },
            );
          },
        );
      },
    );
  }
}
