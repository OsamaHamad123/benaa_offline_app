import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';
import '../../../../core/utils/family_enums.dart';
import '../../../../core/utils/ux_helpers.dart';
import '../../../../core/enums/sponsorship_enums.dart';

class FamilyMembersForm extends ConsumerStatefulWidget {
  final int beneficiaryId;
  final FamilyMember? existingMember;
  final VoidCallback onSaved;

  const FamilyMembersForm({
    super.key,
    required this.beneficiaryId,
    this.existingMember,
    required this.onSaved,
  });

  @override
  ConsumerState<FamilyMembersForm> createState() => _FamilyMembersFormState();
}

class _FamilyMembersFormState extends ConsumerState<FamilyMembersForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _thirdNameController;
  late TextEditingController _familyNameController;
  late TextEditingController _orphanNationalIdController;
  late TextEditingController _notesController;

  int? _selectedGender;
  int? _selectedHealthStatus;
  DateTime? _birthDate;
  int? _calculatedAge;

  // Sponsorship fields
  int? _selectedSponsorshipStatus;
  int? _selectedSponsorshipType;
  late TextEditingController _sponsorNameController;
  DateTime? _sponsorshipStartDate;

  // Attachments
  String? _nationalIdImagePath;
  String? _medicalReportPath;
  String? _birthCertificatePath;
  String? _lastCertificatePath;
  String? _personalPhotoPath;
  String? _fullPhotoPath;

  @override
  void initState() {
    super.initState();
    final member = widget.existingMember;
    _firstNameController = TextEditingController(text: member?.firstName);
    _secondNameController = TextEditingController(text: member?.secondName);
    _thirdNameController = TextEditingController(text: member?.thirdName);
    _familyNameController = TextEditingController(text: member?.familyName);
    _orphanNationalIdController = TextEditingController(
      text: member?.orphanNationalId.toString() ?? '',
    );
    _notesController = TextEditingController(text: member?.notes);
    _sponsorNameController = TextEditingController(text: member?.sponsorName);

    // تحميل القيم
    _selectedGender = member?.gender;
    _selectedHealthStatus = member?.healthStatus;
    _birthDate = member?.birthDate;
    if (_birthDate != null) {
      _calculatedAge = DateTime.now().difference(_birthDate!).inDays ~/ 365;
    }

    // Sponsorship values
    _selectedSponsorshipStatus = member?.sponsorshipStatus;
    _selectedSponsorshipType = member?.sponsorshipType;
    _sponsorshipStartDate = member?.sponsorshipStartDate;

    // Parse existing attachments
    if (member?.attachments != null && member!.attachments!.isNotEmpty) {
      final attachmentsList = member.attachments!.split(',');
      for (var attachment in attachmentsList) {
        if (attachment.contains('national_id')) {
          _nationalIdImagePath = attachment;
        } else if (attachment.contains('medical')) {
          _medicalReportPath = attachment;
        } else if (attachment.contains('birth')) {
          _birthCertificatePath = attachment;
        } else if (attachment.contains('certificate')) {
          _lastCertificatePath = attachment;
        } else if (attachment.contains('personal')) {
          _personalPhotoPath = attachment;
        } else if (attachment.contains('full')) {
          _fullPhotoPath = attachment;
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _orphanNationalIdController.dispose();
    _notesController.dispose();
    _sponsorNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _calculatedAge = DateTime.now().difference(picked).inDays ~/ 365;
      });
    }
  }

  Future<void> _selectSponsorshipStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sponsorshipStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _sponsorshipStartDate = picked;
      });
    }
  }

  Future<void> _pickFile(String attachmentType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        switch (attachmentType) {
          case 'national_id':
            _nationalIdImagePath = result.files.single.path;
            break;
          case 'medical':
            _medicalReportPath = result.files.single.path;
            break;
          case 'birth':
            _birthCertificatePath = result.files.single.path;
            break;
          case 'certificate':
            _lastCertificatePath = result.files.single.path;
            break;
          case 'personal':
            _personalPhotoPath = result.files.single.path;
            break;
          case 'full':
            _fullPhotoPath = result.files.single.path;
            break;
        }
      });
    }
  }

  String _buildAttachmentsString() {
    final attachments = <String>[];
    if (_nationalIdImagePath != null) attachments.add(_nationalIdImagePath!);
    if (_medicalReportPath != null) attachments.add(_medicalReportPath!);
    if (_birthCertificatePath != null) attachments.add(_birthCertificatePath!);
    if (_lastCertificatePath != null) attachments.add(_lastCertificatePath!);
    if (_personalPhotoPath != null) attachments.add(_personalPhotoPath!);
    if (_fullPhotoPath != null) attachments.add(_fullPhotoPath!);
    return attachments.join(',');
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ToastHelper.showError('الرجاء اختيار تاريخ الميلاد');
      return;
    }

    // Validate required attachments
    if (_nationalIdImagePath == null ||
        _medicalReportPath == null ||
        _birthCertificatePath == null ||
        _lastCertificatePath == null ||
        _personalPhotoPath == null ||
        _fullPhotoPath == null) {
      ToastHelper.showWarning('الرجاء رفع جميع المرفقات المطلوبة');
      return;
    }

    final database = ref.read(databaseProvider);
    final dao = database.familyMembersDao;

    final orphanNationalIdInt = int.parse(
      _orphanNationalIdController.text.trim(),
    );

    final companion = FamilyMembersTableCompanion(
      id: widget.existingMember != null ? drift.Value(widget.existingMember!.id) : const drift.Value.absent(),
      beneficiaryId: drift.Value(widget.beneficiaryId),
      orphanNationalId: drift.Value(orphanNationalIdInt),
      firstName: drift.Value(_firstNameController.text.trim()),
      secondName: _secondNameController.text.trim().isEmpty
          ? const drift.Value(null)
          : drift.Value(_secondNameController.text.trim()),
      thirdName: _thirdNameController.text.trim().isEmpty
          ? const drift.Value(null)
          : drift.Value(_thirdNameController.text.trim()),
      familyName: drift.Value(_familyNameController.text.trim()),
      birthDate: drift.Value(_birthDate!),
      age: drift.Value(_calculatedAge),
      gender: drift.Value(_selectedGender ?? Gender.male),
      healthStatus: drift.Value(_selectedHealthStatus ?? HealthStatus.unknown),
      attachments: drift.Value(_buildAttachmentsString()),
      notes: drift.Value(_notesController.text.trim()),
      // Sponsorship fields
      sponsorshipStatus:
          _selectedSponsorshipStatus != null ? drift.Value(_selectedSponsorshipStatus) : const drift.Value(null),
      sponsorshipType:
          _selectedSponsorshipType != null ? drift.Value(_selectedSponsorshipType) : const drift.Value(null),
      sponsorName: _sponsorNameController.text.trim().isEmpty
          ? const drift.Value(null)
          : drift.Value(_sponsorNameController.text.trim()),
      sponsorshipStartDate:
          _sponsorshipStartDate != null ? drift.Value(_sponsorshipStartDate) : const drift.Value(null),
      syncState: const drift.Value('pending'),
      serverId: const drift.Value(null),
      lastSyncedAt: const drift.Value(null),
      createdAt:
          widget.existingMember != null ? drift.Value(widget.existingMember!.createdAt) : drift.Value(DateTime.now()),
      updatedAt: drift.Value(DateTime.now()),
    );

    try {
      if (widget.existingMember != null) {
        final updateCompanion = FamilyMembersTableCompanion(
          id: drift.Value(widget.existingMember!.id),
          orphanNationalId: drift.Value(orphanNationalIdInt),
          firstName: drift.Value(_firstNameController.text.trim()),
          secondName: _secondNameController.text.trim().isEmpty
              ? const drift.Value(null)
              : drift.Value(_secondNameController.text.trim()),
          thirdName: _thirdNameController.text.trim().isEmpty
              ? const drift.Value(null)
              : drift.Value(_thirdNameController.text.trim()),
          familyName: drift.Value(_familyNameController.text.trim()),
          birthDate: drift.Value(_birthDate!),
          age: drift.Value(_calculatedAge),
          gender: drift.Value(_selectedGender ?? Gender.male),
          healthStatus: drift.Value(
            _selectedHealthStatus ?? HealthStatus.unknown,
          ),
          attachments: drift.Value(_buildAttachmentsString()),
          notes: drift.Value(_notesController.text.trim()),
          // Sponsorship fields
          sponsorshipStatus:
              _selectedSponsorshipStatus != null ? drift.Value(_selectedSponsorshipStatus) : const drift.Value(null),
          sponsorshipType:
              _selectedSponsorshipType != null ? drift.Value(_selectedSponsorshipType) : const drift.Value(null),
          sponsorName: _sponsorNameController.text.trim().isEmpty
              ? const drift.Value(null)
              : drift.Value(_sponsorNameController.text.trim()),
          sponsorshipStartDate:
              _sponsorshipStartDate != null ? drift.Value(_sponsorshipStartDate) : const drift.Value(null),
          updatedAt: drift.Value(DateTime.now()),
        );
        await (database.update(database.familyMembersTable)..where((t) => t.id.equals(widget.existingMember!.id)))
            .write(updateCompanion);
      } else {
        await dao.addMember(companion);
      }

      if (mounted) {
        ToastHelper.showSuccess('تم الحفظ بنجاح');
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError('خطأ في الحفظ: $e');
      }
    }
  }

  Widget _buildAttachmentButton({
    required String label,
    required String attachmentType,
    required String? filePath,
    required IconData icon,
  }) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => _pickFile(attachmentType),
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            foregroundColor: filePath != null ? Colors.green : Colors.red,
          ),
        ),
        if (filePath != null) ...[
          const SizedBox(height: 4),
          Text(
            '✓ تم الرفع',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          const Text(
            'مطلوب *',
            style: TextStyle(fontSize: 11, color: Colors.red),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMember != null ? 'تعديل بيانات يتيم' : 'إضافة يتيم',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveMember),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: معلومات الهوية
            const Text(
              'معلومات الهوية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // رقم هوية اليتيم
            TextFormField(
              controller: _orphanNationalIdController,
              decoration: const InputDecoration(
                labelText: 'رقم هوية اليتيم *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              maxLength: 9,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهوية';
                }
                if (value.trim().length != 9) {
                  return 'رقم الهوية يجب أن يكون 9 أرقام';
                }
                final intValue = int.tryParse(value.trim());
                if (intValue == null) {
                  return 'رقم الهوية يجب أن يكون أرقام فقط';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Section: الاسم الرباعي
            const Text(
              'الاسم الرباعي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // الاسم الأول
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الأول *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم الأول';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // اسم الأب
            TextFormField(
              controller: _secondNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الأب',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // اسم الجد
            TextFormField(
              controller: _thirdNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الجد',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // اسم العائلة
            TextFormField(
              controller: _familyNameController,
              decoration: const InputDecoration(
                labelText: 'اسم العائلة *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم العائلة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: المعلومات الشخصية
            const Text(
              'المعلومات الشخصية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // تاريخ الميلاد
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الميلاد *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthDate != null
                          ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                          : 'اختر التاريخ',
                      style: TextStyle(
                        color: _birthDate != null ? null : Colors.grey,
                      ),
                    ),
                    if (_calculatedAge != null)
                      Text(
                        'العمر: $_calculatedAge سنة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // الجنس
            DropdownButtonFormField<int>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'الجنس *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
              ),
              items: [
                DropdownMenuItem(
                  value: Gender.male,
                  child: Text(Gender.toArabic(Gender.male)),
                ),
                DropdownMenuItem(
                  value: Gender.female,
                  child: Text(Gender.toArabic(Gender.female)),
                ),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (value) {
                if (value == null) return 'الرجاء اختيار الجنس';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // الحالة الصحية
            DropdownButtonFormField<int>(
              value: _selectedHealthStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة الصحية *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              items: HealthStatus.allValues.map((statusValue) {
                return DropdownMenuItem(
                  value: statusValue,
                  child: Text(HealthStatus.toArabic(statusValue)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedHealthStatus = value),
              validator: (value) {
                if (value == null) return 'الرجاء اختيار الحالة الصحية';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Section: بيانات الكفالة
            const Text(
              'بيانات الكفالة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // حالة الكفالة
            DropdownButtonFormField<int>(
              value: _selectedSponsorshipStatus,
              decoration: const InputDecoration(
                labelText: 'حالة الكفالة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified_user),
                hintText: 'اختياري',
              ),
              items: SponsorshipStatus.allValues.map((status) {
                return DropdownMenuItem(
                  value: status.id,
                  child: Text(status.arabicName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSponsorshipStatus = value),
            ),
            const SizedBox(height: 16),

            // نوع الكفالة
            DropdownButtonFormField<int>(
              value: _selectedSponsorshipType,
              decoration: const InputDecoration(
                labelText: 'نوع الكفالة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'اختياري',
              ),
              items: SponsorshipType.allValues.map((type) {
                return DropdownMenuItem(
                  value: type.id,
                  child: Text(type.arabicName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSponsorshipType = value),
            ),
            const SizedBox(height: 16),

            // اسم الكفيل
            TextFormField(
              controller: _sponsorNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الكفيل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add),
                hintText: 'اختياري',
              ),
            ),
            const SizedBox(height: 16),

            // تاريخ بدء الكفالة
            InkWell(
              onTap: _selectSponsorshipStartDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ بدء الكفالة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                  hintText: 'اختياري',
                ),
                child: Text(
                  _sponsorshipStartDate != null
                      ? '${_sponsorshipStartDate!.year}-${_sponsorshipStartDate!.month.toString().padLeft(2, '0')}-${_sponsorshipStartDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر التاريخ',
                  style: TextStyle(
                    color: _sponsorshipStartDate != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: المرفقات المطلوبة
            const Text(
              'المرفقات المطلوبة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'صورة هوية',
                    attachmentType: 'national_id',
                    filePath: _nationalIdImagePath,
                    icon: Icons.credit_card,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'تقرير طبي',
                    attachmentType: 'medical',
                    filePath: _medicalReportPath,
                    icon: Icons.medical_information,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'شهادة الميلاد',
                    attachmentType: 'birth',
                    filePath: _birthCertificatePath,
                    icon: Icons.description,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'آخر شهادة',
                    attachmentType: 'certificate',
                    filePath: _lastCertificatePath,
                    icon: Icons.school,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'صورة شخصية',
                    attachmentType: 'personal',
                    filePath: _personalPhotoPath,
                    icon: Icons.face,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAttachmentButton(
                    label: 'صورة طولية',
                    attachmentType: 'full',
                    filePath: _fullPhotoPath,
                    icon: Icons.person,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ملاحظات
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: _saveMember,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
