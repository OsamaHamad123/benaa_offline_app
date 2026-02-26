import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import '../../../../../attachments/domain/models/pending_attachment.dart';
import '../../../../../attachments/presentation/widgets/attachments_section_clean.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../form/attachments/document_type_selector.dart' show PersonTypeSelector;

/// 📎 تبويب مرفقات جديد (MVP)
///
/// نسخة مبسطة وثابتة:
/// - إضافة ملف + metadata
/// - قائمة pending بسيطة وسريعة
/// - عرض المرفقات المحفوظة عند الطلب فقط
class V2UnifiedAttachmentsTab extends ConsumerStatefulWidget {
  final String? beneficiaryId;
  final List<File>? pendingFiles;
  final Function(List<File>)? onPendingFilesChanged;
  final BeneficiaryFormControllers? formControllers;
  final bool showComposer;

  const V2UnifiedAttachmentsTab({
    super.key,
    this.beneficiaryId,
    this.pendingFiles,
    this.onPendingFilesChanged,
    this.formControllers,
    this.showComposer = true,
  });

  @override
  ConsumerState<V2UnifiedAttachmentsTab> createState() => _V2UnifiedAttachmentsTabState();
}

class _V2UnifiedAttachmentsTabState extends ConsumerState<V2UnifiedAttachmentsTab> {
  static const Set<String> _allowedExtensions = {
    'pdf',
    'jpg',
    'jpeg',
    'png',
  };
  static const int _maxFileSizeBytes = 20 * 1024 * 1024;

  static const List<MapEntry<String, String>> _documentTypeOptions = [
    MapEntry('identity_card', 'هوية شخصية'),
    MapEntry('family_book', 'دفتر عائلة'),
    MapEntry('residence_doc', 'إثبات سكن'),
    MapEntry('income_doc', 'إثبات دخل'),
    MapEntry('medical_report', 'تقرير طبي'),
    MapEntry('other', 'أخرى'),
  ];

  static const List<String> _essentialDocumentTypes = [
    'identity_card',
    'residence_doc',
  ];

  String? _selectedDocumentType;
  String? _selectedPerson;
  File? _selectedFile;
  bool _didAttemptAdd = false;
  bool _isAdding = false;
  bool _isPickingFile = false;
  bool _showSavedAttachments = false;
  bool _composerExpanded = false;
  String? _suggestedDocumentType;
  bool _showCompactDetails = false;

  @override
  void initState() {
    super.initState();

    final controllers = widget.formControllers;
    final legacyPendingFiles = widget.pendingFiles ?? const <File>[];
    if (controllers == null || legacyPendingFiles.isEmpty) {
      return;
    }

    if (controllers.pendingAttachments.isNotEmpty) {
      return;
    }

    for (final file in legacyPendingFiles) {
      controllers.addPendingAttachment(
        PendingAttachment(
          file: file,
          personType: 'file_owner',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyMembers = _getAvailableFamilyMembers();
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 360;
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final canShowSecondarySections = !isCompact || (_showCompactDetails && !isKeyboardOpen);

    return ListView(
      padding: EdgeInsets.all(16.w),
      physics: const ClampingScrollPhysics(),
      children: [
        if (isCompact)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showCompactDetails = !_showCompactDetails;
                });
              },
              icon: Icon(_showCompactDetails ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              label: Text(_showCompactDetails ? 'إخفاء التفاصيل الإضافية' : 'إظهار التفاصيل الإضافية'),
            ),
          ),
        if (widget.showComposer) _buildComposerGate(context, familyMembers),
        if (widget.showComposer) SizedBox(height: 24.h),
        if (canShowSecondarySections) ...[
          _buildAttachmentIntelligence(context),
          SizedBox(height: 12.h),
        ],
        _buildPendingAttachmentsList(context),
        if (canShowSecondarySections && widget.beneficiaryId != null && widget.beneficiaryId!.trim().isNotEmpty) ...[
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'المرفقات المحفوظة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showSavedAttachments = !_showSavedAttachments;
                  });
                },
                icon: Icon(
                  _showSavedAttachments ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18.sp,
                ),
                label: Text(_showSavedAttachments ? 'إخفاء' : 'إظهار'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_showSavedAttachments)
            AttachmentsSectionClean(
              beneficiaryId: widget.beneficiaryId!,
              readOnly: true,
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'تم إخفاء قائمة المرفقات المحفوظة لتسريع فتح التبويب. اضغط "إظهار" للعرض.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildComposerGate(BuildContext context, List<String> familyMembers) {
    if (_composerExpanded) {
      return _buildAddAttachmentCard(context, familyMembers);
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'إضافة مرفق جديد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _composerExpanded = true;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('إظهار'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAttachmentCard(BuildContext context, List<String> familyMembers) {
    final controllers = widget.formControllers;
    final canAdd = controllers != null && !_isAdding;
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 360;
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final canShowComposerExtras = !isCompact || (_showCompactDetails && !isKeyboardOpen);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إضافة مرفق جديد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentType,
              decoration: InputDecoration(
                labelText: 'نوع الوثيقة *',
                prefixIcon: const Icon(Icons.description_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              items: _documentTypeOptions
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _selectedDocumentType = value;
                  if (value != null) _didAttemptAdd = false;
                });
              },
            ),
            if (_didAttemptAdd && _selectedDocumentType == null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, right: 4.w),
                child: Text(
                  'يرجى اختيار نوع الوثيقة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            SizedBox(height: 12.h),
            PersonTypeSelector(
              selectedPerson: _selectedPerson,
              availablePersons: familyMembers,
              onChanged: (value) {
                setState(() {
                  _selectedPerson = value;
                  if (value != null) _didAttemptAdd = false;
                });
              },
            ),
            if (_didAttemptAdd && _selectedPerson == null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, right: 4.w),
                child: Text(
                  'يرجى اختيار الشخص',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            SizedBox(height: 12.h),
            Row(
              children: isCompact
                  ? [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: canAdd && !_isPickingFile ? _pickFile : null,
                                icon: const Icon(Icons.attach_file),
                                label: Text(
                                  _isPickingFile
                                      ? 'جاري فتح الملفات...'
                                      : (_selectedFile == null ? 'اختيار ملف' : _fileNameOf(_selectedFile!)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: canAdd ? _addPendingAttachment : null,
                                icon: _isAdding
                                    ? SizedBox(
                                        width: 16.sp,
                                        height: 16.sp,
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.add),
                                label: const Text('إضافة'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: canAdd && !_isPickingFile ? _pickFile : null,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            _isPickingFile
                                ? 'جاري فتح الملفات...'
                                : (_selectedFile == null ? 'اختيار ملف' : _fileNameOf(_selectedFile!)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      FilledButton.icon(
                        onPressed: canAdd ? _addPendingAttachment : null,
                        icon: _isAdding
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add),
                        label: const Text('إضافة'),
                      ),
                    ],
            ),
            if (canShowComposerExtras && _suggestedDocumentType != null && _selectedDocumentType == null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Wrap(
                  spacing: 8.w,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16.sp, color: Theme.of(context).colorScheme.primary),
                    Text('اقتراح تلقائي لنوع الوثيقة: ${_documentTypeLabel(_suggestedDocumentType!)}'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDocumentType = _suggestedDocumentType;
                        });
                      },
                      child: const Text('استخدام الاقتراح'),
                    ),
                  ],
                ),
              ),
            if (_didAttemptAdd && _selectedFile == null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, right: 4.w),
                child: Text(
                  'يرجى اختيار ملف قبل الإضافة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isAdding
                    ? null
                    : () {
                        setState(() {
                          _composerExpanded = false;
                        });
                      },
                icon: const Icon(Icons.expand_less),
                label: const Text('إخفاء نموذج الإضافة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingAttachmentsList(BuildContext context) {
    final controllers = widget.formControllers;
    if (controllers == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<List<PendingAttachment>>(
      valueListenable: controllers.pendingAttachmentsNotifier,
      builder: (context, attachments, _) {
        if (attachments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'لا توجد مرفقات معلّقة حتى الآن.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المرفقات المعلقة (${attachments.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.h),
                ...attachments.map((attachment) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _fileNameOf(attachment.file),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${attachment.documentType ?? 'بدون نوع'} • ${_personLabel(attachment)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => controllers.removePendingAttachment(attachment),
                    ),
                    onTap: () => _openPendingFile(attachment.file),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) return;

    setState(() {
      _isPickingFile = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );

      final picked = result?.files.isNotEmpty == true ? result!.files.first : null;
      if (picked == null) {
        return;
      }

      final ext = picked.extension?.toLowerCase().trim();
      if (ext == null || !_allowedExtensions.contains(ext)) {
        _showMessage('النوع غير مدعوم. الأنواع المسموحة: PDF, JPG, PNG');
        return;
      }

      final filePath = picked.path?.trim();
      if (filePath == null || filePath.isEmpty) {
        _showMessage('تعذر الوصول لمسار الملف. اختر ملفًا محليًا من الجهاز.');
        return;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        _showMessage('الملف المختار غير متاح. حاول اختياره مرة أخرى.');
        return;
      }

      final size = file.lengthSync();
      if (size > _maxFileSizeBytes) {
        _showMessage('حجم الملف كبير جدًا (الحد الأقصى 20MB).');
        return;
      }

      if (!mounted) return;
      final suggestedType = _suggestDocumentTypeFromFileName(_fileNameOf(file));
      setState(() {
        _selectedFile = file;
        _suggestedDocumentType = suggestedType;
        if (_selectedDocumentType == null && suggestedType != null) {
          _selectedDocumentType = suggestedType;
        }
        _didAttemptAdd = false;
      });
    } catch (_) {
      _showMessage('فشل اختيار الملف. حاول مجددًا.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _addPendingAttachment() async {
    final controllers = widget.formControllers;
    if (controllers == null) {
      return;
    }

    if (_selectedFile == null || _selectedDocumentType == null || _selectedPerson == null) {
      if (mounted) {
        setState(() {
          _didAttemptAdd = true;
        });
      }
      _showMessage('يرجى اختيار الملف ونوع الوثيقة والشخص.');
      return;
    }

    try {
      setState(() {
        _isAdding = true;
      });

      if (!_selectedFile!.existsSync()) {
        _showMessage('الملف غير موجود على الجهاز. اختره مرة أخرى.');
        return;
      }

      final personMeta = _resolvePersonMetadata(_selectedPerson!);
      controllers.addPendingAttachment(
        PendingAttachment(
          file: _selectedFile!,
          documentType: _selectedDocumentType,
          personType: personMeta.personType,
          personId: personMeta.personId,
        ),
      );

      if (mounted) {
        setState(() {
          _selectedFile = null;
          _selectedDocumentType = null;
          _suggestedDocumentType = null;
          _selectedPerson = null;
          _didAttemptAdd = false;
        });
      }
    } catch (_) {
      _showMessage('تعذر إضافة المرفق. حاول مجددًا.');
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  Future<void> _openPendingFile(File file) async {
    if (!file.existsSync()) {
      _showMessage('الملف غير موجود على الجهاز.');
      return;
    }

    await OpenFile.open(file.path);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _fileNameOf(File file) {
    final segments = file.path.split(RegExp(r'[\\/]'));
    if (segments.isEmpty) return file.path;
    return segments.last;
  }

  Widget _buildAttachmentIntelligence(BuildContext context) {
    final controllers = widget.formControllers;
    if (controllers == null) {
      return const SizedBox.shrink();
    }

    final existingTypes = <String>{};
    for (final pending in controllers.pendingAttachments) {
      final type = pending.documentType?.trim();
      if (type != null && type.isNotEmpty) {
        existingTypes.add(type);
      }
    }

    final missingTypes = _essentialDocumentTypes.where((type) => !existingTypes.contains(type)).toList(growable: false);
    if (missingTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_alt_outlined, size: 18.sp, color: theme.colorScheme.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'مقترحات ذكية للمرفقات',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'مرفقات أساسية ناقصة: ${missingTypes.map(_documentTypeLabel).join('، ')}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _documentTypeLabel(String typeKey) {
    for (final entry in _documentTypeOptions) {
      if (entry.key == typeKey) {
        return entry.value;
      }
    }
    return typeKey;
  }

  String? _suggestDocumentTypeFromFileName(String fileName) {
    final normalized = fileName.toLowerCase();

    if (normalized.contains('id') || normalized.contains('هوية')) {
      return 'identity_card';
    }
    if (normalized.contains('family') || normalized.contains('عائلة')) {
      return 'family_book';
    }
    if (normalized.contains('residence') || normalized.contains('سكن')) {
      return 'residence_doc';
    }
    if (normalized.contains('income') || normalized.contains('راتب') || normalized.contains('دخل')) {
      return 'income_doc';
    }
    if (normalized.contains('medical') || normalized.contains('طب') || normalized.contains('تقرير')) {
      return 'medical_report';
    }
    return null;
  }

  String _personLabel(PendingAttachment attachment) {
    if (attachment.personType == 'file_owner') {
      return 'صاحب الملف';
    }
    if ((attachment.personId ?? '').trim().isNotEmpty) {
      return attachment.personId!.trim();
    }
    return attachment.personType ?? '-';
  }

  ({String personType, String? personId}) _resolvePersonMetadata(String selectedPersonValue) {
    final normalized = selectedPersonValue.trim();

    if (normalized == 'file_owner') {
      return (personType: 'file_owner', personId: null);
    }

    const deceasedSuffix = '(متوفي)';
    if (normalized.endsWith(deceasedSuffix)) {
      final personName = normalized.substring(0, normalized.length - deceasedSuffix.length).trim();
      return (
        personType: 'deceased_member',
        personId: personName.isEmpty ? null : personName,
      );
    }

    return (
      personType: 'family_member',
      personId: normalized.isEmpty ? null : normalized,
    );
  }

  List<String> _getAvailableFamilyMembers() {
    if (widget.formControllers == null) return [];

    final members = <String>[];

    void addMember(String rawName, {bool isDeceased = false}) {
      final normalized = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (normalized.isEmpty) {
        return;
      }

      final displayName = isDeceased ? '$normalized (متوفي)' : normalized;
      if (!members.contains(displayName)) {
        members.add(displayName);
      }
    }

    // Add living members
    for (final member in widget.formControllers!.livingMembers) {
      final name = _getMemberName(member);
      addMember(name);
    }

    // Add deceased members
    for (final member in widget.formControllers!.deceasedMembers) {
      final name = _getMemberName(member);
      addMember(name, isDeceased: true);
    }

    return members;
  }

  String _getMemberName(Map<String, dynamic> member) {
    final firstName = (member['firstName'] ?? member['first_name'] ?? member['name'] ?? '').toString().trim();
    final familyName =
        (member['familyName'] ?? member['family_name'] ?? member['lastName'] ?? member['last_name'] ?? '')
            .toString()
            .trim();
    return '$firstName $familyName'.trim();
  }
}
