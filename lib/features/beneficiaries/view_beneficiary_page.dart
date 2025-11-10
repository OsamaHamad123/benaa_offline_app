import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/db/drift_database.dart';

class ViewBeneficiaryPage extends ConsumerWidget {
  final String beneficiaryId;

  const ViewBeneficiaryPage({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<Beneficiary?>(
      future: database.getBeneficiaryById(beneficiaryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل المستفيد')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final beneficiary = snapshot.data;
        if (beneficiary == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('لم يتم العثور على المستفيد'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          );
        }

        final categoryColor = _getCategoryColor(beneficiary.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المستفيد'),
            backgroundColor: categoryColor.withOpacity(0.1),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'مشاركة',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سيتم إضافة المشاركة قريباً')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'تعديل',
                onPressed: () {
                  context.push('/beneficiaries/add?id=$beneficiaryId');
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context, database);
                  } else if (value == 'print') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إضافة الطباعة قريباً'),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'print',
                    child: Row(
                      children: [
                        Icon(Icons.print, size: 20),
                        SizedBox(width: 8),
                        Text('طباعة'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: categoryColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [categoryColor.withOpacity(0.1), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: categoryColor.withOpacity(0.2),
                        child: Icon(
                          beneficiary.gender == 'male'
                              ? Icons.person
                              : Icons.person_outline,
                          size: 60,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        beneficiary.fullName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم الملف: ${beneficiary.fileNo}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _SyncStatusBadge(syncState: beneficiary.syncState),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              color: categoryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getCategoryLabel(beneficiary.category),
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Basic Info Section
              _buildSectionTitle(context, 'المعلومات الأساسية'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.badge,
                      label: 'الرقم الوطني',
                      value: beneficiary.nationalId,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.folder,
                      label: 'رقم الملف',
                      value: beneficiary.fileNo,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'المحافظة',
                      value: beneficiary.governorate,
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.wc,
                      label: 'الجنس',
                      value: beneficiary.gender == 'male' ? 'ذكر' : 'أنثى',
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.category,
                      label: 'الفئة',
                      value: _getCategoryLabel(beneficiary.category),
                    ),
                    if (beneficiary.associationName != null &&
                        beneficiary.associationName!.isNotEmpty) ...[
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.business,
                        label: 'اسم الجمعية',
                        value: beneficiary.associationName!,
                      ),
                    ],
                    if (beneficiary.birthDate != null) ...[
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.cake,
                        label: 'تاريخ الميلاد',
                        value:
                            '${beneficiary.birthDate!.year}-${beneficiary.birthDate!.month.toString().padLeft(2, '0')}-${beneficiary.birthDate!.day.toString().padLeft(2, '0')}',
                      ),
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.person,
                        label: 'العمر',
                        value: '${beneficiary.age} سنة',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contact Info Section
              if ((beneficiary.phoneNumber != null &&
                      beneficiary.phoneNumber!.isNotEmpty) ||
                  (beneficiary.district != null &&
                      beneficiary.district!.isNotEmpty) ||
                  (beneficiary.address != null &&
                      beneficiary.address!.isNotEmpty)) ...[
                _buildSectionTitle(context, 'معلومات التواصل'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.phoneNumber != null &&
                          beneficiary.phoneNumber!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'رقم الهاتف',
                          value: beneficiary.phoneNumber!,
                        ),
                        if ((beneficiary.district != null &&
                                beneficiary.district!.isNotEmpty) ||
                            (beneficiary.address != null &&
                                beneficiary.address!.isNotEmpty))
                          const Divider(height: 1),
                      ],
                      if (beneficiary.district != null &&
                          beneficiary.district!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.location_city,
                          label: 'القضاء',
                          value: beneficiary.district!,
                        ),
                        if (beneficiary.address != null &&
                            beneficiary.address!.isNotEmpty)
                          const Divider(height: 1),
                      ],
                      if (beneficiary.address != null &&
                          beneficiary.address!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.home,
                          label: 'العنوان',
                          value: beneficiary.address!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Family Info Section
              if ((beneficiary.fatherName != null &&
                      beneficiary.fatherName!.isNotEmpty) ||
                  (beneficiary.motherName != null &&
                      beneficiary.motherName!.isNotEmpty) ||
                  (beneficiary.grandFatherName != null &&
                      beneficiary.grandFatherName!.isNotEmpty) ||
                  (beneficiary.familyName != null &&
                      beneficiary.familyName!.isNotEmpty) ||
                  beneficiary.familySize != null ||
                  beneficiary.maritalStatus != null ||
                  beneficiary.numberOfMales != null ||
                  beneficiary.numberOfFemales != null) ...[
                _buildSectionTitle(context, 'معلومات العائلة'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.fatherName != null &&
                          beneficiary.fatherName!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.person,
                          label: 'اسم الأب',
                          value: beneficiary.fatherName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.grandFatherName != null &&
                          beneficiary.grandFatherName!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'اسم الجد',
                          value: beneficiary.grandFatherName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.familyName != null &&
                          beneficiary.familyName!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.family_restroom,
                          label: 'اسم العائلة',
                          value: beneficiary.familyName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.motherName != null &&
                          beneficiary.motherName!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.person,
                          label: 'اسم الأم',
                          value: beneficiary.motherName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.familySize != null) ...[
                        _InfoRow(
                          icon: Icons.family_restroom,
                          label: 'عدد أفراد الأسرة',
                          value: '${beneficiary.familySize} أفراد',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfMales != null) ...[
                        _InfoRow(
                          icon: Icons.male,
                          label: 'عدد الذكور',
                          value: '${beneficiary.numberOfMales}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfFemales != null) ...[
                        _InfoRow(
                          icon: Icons.female,
                          label: 'عدد الإناث',
                          value: '${beneficiary.numberOfFemales}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.maritalStatus != null) ...[
                        _InfoRow(
                          icon: Icons.favorite,
                          label: 'الحالة الاجتماعية',
                          value: _getMaritalStatusLabel(
                            beneficiary.maritalStatus,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Displacement & Housing Section
              if ((beneficiary.currentAddress != null &&
                      beneficiary.currentAddress!.isNotEmpty) ||
                  (beneficiary.addressBeforeDisplacement != null &&
                      beneficiary.addressBeforeDisplacement!.isNotEmpty) ||
                  beneficiary.displacementStatus != null ||
                  beneficiary.housingStatus != null ||
                  beneficiary.housingType != null) ...[
                _buildSectionTitle(context, 'معلومات السكن والنزوح'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.currentAddress != null &&
                          beneficiary.currentAddress!.isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.home,
                          label: 'العنوان الحالي',
                          value: beneficiary.currentAddress!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.addressBeforeDisplacement != null &&
                          beneficiary
                              .addressBeforeDisplacement!
                              .isNotEmpty) ...[
                        _InfoRow(
                          icon: Icons.location_city,
                          label: 'العنوان قبل النزوح',
                          value: beneficiary.addressBeforeDisplacement!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.displacementStatus != null) ...[
                        _InfoRow(
                          icon: Icons.move_down,
                          label: 'حالة النزوح',
                          value: 'كود: ${beneficiary.displacementStatus}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.housingStatus != null) ...[
                        _InfoRow(
                          icon: Icons.house,
                          label: 'حالة السكن',
                          value: 'كود: ${beneficiary.housingStatus}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.housingType != null) ...[
                        _InfoRow(
                          icon: Icons.apartment,
                          label: 'نوع السكن',
                          value: 'كود: ${beneficiary.housingType}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Education & Health Section
              if (beneficiary.educationLevel != null ||
                  beneficiary.healthStatus != null ||
                  beneficiary.hasDisability ||
                  (beneficiary.chronicDiseasesCount != null &&
                      beneficiary.chronicDiseasesCount! > 0) ||
                  (beneficiary.specialNeedsCount != null &&
                      beneficiary.specialNeedsCount! > 0)) ...[
                _buildSectionTitle(context, 'التعليم والصحة'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.educationLevel != null) ...[
                        _InfoRow(
                          icon: Icons.school,
                          label: 'المستوى التعليمي',
                          value: _getEducationLabel(
                            beneficiary.educationLevel!,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.healthStatus != null) ...[
                        _InfoRow(
                          icon: Icons.health_and_safety,
                          label: 'الحالة الصحية',
                          value: _getHealthStatusLabel(
                            beneficiary.healthStatus!,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.chronicDiseasesCount != null &&
                          beneficiary.chronicDiseasesCount! > 0) ...[
                        _InfoRow(
                          icon: Icons.medical_services,
                          label: 'عدد الأمراض المزمنة',
                          value: '${beneficiary.chronicDiseasesCount}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.hasDisability) ...[
                        _InfoRow(
                          icon: Icons.accessible,
                          label: 'الإعاقة',
                          value: 'يوجد إعاقة',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.specialNeedsCount != null &&
                          beneficiary.specialNeedsCount! > 0) ...[
                        _InfoRow(
                          icon: Icons.accessible_forward,
                          label: 'عدد ذوي الاحتياجات الخاصة',
                          value: '${beneficiary.specialNeedsCount}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Additional Contact Info
              if (beneficiary.altPhoneNumber != null &&
                  beneficiary.altPhoneNumber!.isNotEmpty) ...[
                _buildSectionTitle(context, 'معلومات اتصال إضافية'),
                const SizedBox(height: 8),
                Card(
                  child: _InfoRow(
                    icon: Icons.phone_android,
                    label: 'رقم هاتف بديل',
                    value: beneficiary.altPhoneNumber!,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes Section
              if (beneficiary.notes.isNotEmpty) ...[
                _buildSectionTitle(context, 'الملاحظات'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(beneficiary.notes),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Metadata Section
              _buildSectionTitle(context, 'بيانات النظام'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'تاريخ الإنشاء',
                      value: _formatDateTime(beneficiary.createdAt),
                    ),
                    const Divider(height: 1),
                    _InfoRow(
                      icon: Icons.update,
                      label: 'آخر تحديث',
                      value: _formatDateTime(beneficiary.updatedAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/attachments/$beneficiaryId');
                      },
                      icon: const Icon(Icons.attachment),
                      label: const Text('المرفقات'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Add visit
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة زيارة'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'orphan':
        return Colors.blue;
      case 'widow':
        return Colors.purple;
      case 'poor':
        return Colors.orange;
      case 'disabled':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orphan':
        return 'يتيم';
      case 'poor':
        return 'فقير';
      case 'widow':
        return 'أرملة';
      case 'disabled':
        return 'معاق';
      default:
        return category;
    }
  }

  String _getMaritalStatusLabel(String? status) {
    if (status == null) return '-';
    switch (status) {
      case 'single':
        return 'أعزب';
      case 'married':
        return 'متزوج';
      case 'divorced':
        return 'مطلق';
      case 'widowed':
        return 'أرمل';
      default:
        return status;
    }
  }

  String _getEducationLabel(String? level) {
    if (level == null) return '-';
    switch (level) {
      case 'none':
        return 'بدون تعليم';
      case 'primary':
        return 'ابتدائي';
      case 'secondary':
        return 'متوسط/ثانوي';
      case 'university':
        return 'جامعي';
      default:
        return level;
    }
  }

  String _getHealthStatusLabel(String? status) {
    if (status == null) return '-';
    switch (status) {
      case 'good':
        return 'جيدة';
      case 'fair':
        return 'متوسطة';
      case 'poor':
        return 'ضعيفة';
      case 'chronic':
        return 'مرض مزمن';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    AppDatabase database,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستفيد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await database.deleteBeneficiary(beneficiaryId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المستفيد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الحذف: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final String syncState;

  const _SyncStatusBadge({required this.syncState});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (syncState) {
      case 'synced':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'تمت المزامنة';
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        label = 'فشل المزامنة';
        break;
      default:
        color = Colors.orange;
        icon = Icons.sync;
        label = 'بانتظار المزامنة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
