import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart' as core_providers;
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/beneficiary/visit_card.dart';
import '../../data/db/drift_database.dart';
import '../../features/visits/presentation/pages/record_visit_page_enhanced.dart';
import '../../features/visits/presentation/providers/visit_providers.dart';
import '../attachments/presentation/widgets/attachments_section_enhanced.dart';

class ViewBeneficiaryPage extends ConsumerWidget {
  final String beneficiaryId;

  const ViewBeneficiaryPage({super.key, required this.beneficiaryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(core_providers.databaseProvider);
    final intId = int.tryParse(beneficiaryId);

    if (intId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المستفيد')),
        body: const Center(child: Text('ID غير صالح')),
      );
    }

    return FutureBuilder<Beneficiary?>(
      future: database.beneficiariesDao.getBeneficiaryById(intId),
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
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  const Text('لم يتم العثور على المستفيد'),
                  SizedBox(height: 24.h),
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

        final categoryColor = _getCategoryColor(beneficiary.sectionId);

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
                  PopupMenuItem(
                    value: 'print',
                    child: Row(
                      children: [
                        Icon(Icons.print, size: 20.sp),
                        SizedBox(width: 8.w),
                        const Text('طباعة'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: categoryColor.withOpacity(0.5),
                    width: 2.w,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: [categoryColor.withOpacity(0.1), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: categoryColor.withOpacity(0.2),
                        child: Icon(
                          beneficiary.gender == 1
                              ? Icons.person
                              : Icons.person_outline,
                          size: 60.sp,
                          color: categoryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        beneficiary.fullName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'رقم الملف: ${beneficiary.fileIdNumber ?? "غير محدد"}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _SyncStatusBadge(syncState: beneficiary.syncState),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
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
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _getCategoryLabel(beneficiary.sectionId),
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Basic Info Section
              _buildSectionTitle(context, 'المعلومات الأساسية'),
              SizedBox(height: 8.h),
              Card(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.badge,
                      label: 'الرقم الوطني',
                      value: beneficiary.idNumber.toString(),
                    ),
                    const Divider(height: 1),
                    InfoRow(
                      icon: Icons.folder,
                      label: 'رقم الملف',
                      value: beneficiary.fileIdNumber ?? 'غير محدد',
                    ),
                    const Divider(height: 1),
                    InfoRow(
                      icon: Icons.location_on,
                      label: 'المحافظة',
                      value: beneficiary.province?.toString() ?? 'غير محدد',
                    ),
                    const Divider(height: 1),
                    InfoRow(
                      icon: Icons.wc,
                      label: 'الجنس',
                      value: beneficiary.gender == 1 ? 'ذكر' : 'أنثى',
                    ),
                    const Divider(height: 1),
                    InfoRow(
                      icon: Icons.category,
                      label: 'الفئة',
                      value: _getCategoryLabel(beneficiary.sectionId),
                    ),
                    if (beneficiary.birthDate != null) ...[
                      const Divider(height: 1),
                      InfoRow(
                        icon: Icons.cake,
                        label: 'تاريخ الميلاد',
                        value:
                            '${beneficiary.birthDate!.year}-${beneficiary.birthDate!.month.toString().padLeft(2, '0')}-${beneficiary.birthDate!.day.toString().padLeft(2, '0')}',
                      ),
                      const Divider(height: 1),
                      InfoRow(
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
              _buildSectionTitle(context, 'معلومات التواصل'),
              const SizedBox(height: 8),
              Card(
                child: InfoRow(
                  icon: Icons.phone,
                  label: 'رقم الهاتف',
                  value: beneficiary.phoneNumber.toString(),
                ),
              ),
              SizedBox(height: 16.h),

              // Family Info Section
              if ((beneficiary.fatherName != null &&
                      beneficiary.fatherName!.isNotEmpty) ||
                  (beneficiary.grandFatherName != null &&
                      beneficiary.grandFatherName!.isNotEmpty) ||
                  (beneficiary.familyName != null &&
                      beneficiary.familyName!.isNotEmpty) ||
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
                        InfoRow(
                          icon: Icons.person,
                          label: 'اسم الأب',
                          value: beneficiary.fatherName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.grandFatherName != null &&
                          beneficiary.grandFatherName!.isNotEmpty) ...[
                        InfoRow(
                          icon: Icons.person_outline,
                          label: 'اسم الجد',
                          value: beneficiary.grandFatherName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.familyName != null &&
                          beneficiary.familyName!.isNotEmpty) ...[
                        InfoRow(
                          icon: Icons.family_restroom,
                          label: 'اسم العائلة',
                          value: beneficiary.familyName!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfMales != null ||
                          beneficiary.numberOfFemales != null) ...[
                        InfoRow(
                          icon: Icons.family_restroom,
                          label: 'عدد أفراد الأسرة',
                          value:
                              '${(beneficiary.numberOfMales ?? 0) + (beneficiary.numberOfFemales ?? 0)} أفراد',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfMales != null) ...[
                        InfoRow(
                          icon: Icons.male,
                          label: 'عدد الذكور',
                          value: '${beneficiary.numberOfMales}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfFemales != null) ...[
                        InfoRow(
                          icon: Icons.female,
                          label: 'عدد الإناث',
                          value: '${beneficiary.numberOfFemales}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.maritalStatus != null) ...[
                        InfoRow(
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
                  beneficiary.housingStatus != null) ...[
                _buildSectionTitle(context, 'معلومات السكن والنزوح'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.currentAddress != null &&
                          beneficiary.currentAddress!.isNotEmpty) ...[
                        InfoRow(
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
                        InfoRow(
                          icon: Icons.location_city,
                          label: 'العنوان قبل النزوح',
                          value: beneficiary.addressBeforeDisplacement!,
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.displacementStatus != null) ...[
                        InfoRow(
                          icon: Icons.move_down,
                          label: 'حالة النزوح',
                          value: 'كود: ${beneficiary.displacementStatus}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.housingStatus != null) ...[
                        InfoRow(
                          icon: Icons.house,
                          label: 'حالة السكن',
                          value: 'كود: ${beneficiary.housingStatus}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Education & Health Section
              if (beneficiary.academicQualification != null ||
                  beneficiary.healthStatus != null ||
                  (beneficiary.numberOfIndividualsWithChronicDiseases != null &&
                      beneficiary.numberOfIndividualsWithChronicDiseases! >
                          0) ||
                  (beneficiary.numberOfPeopleWithSpecialNeeds != null &&
                      beneficiary.numberOfPeopleWithSpecialNeeds! > 0)) ...[
                _buildSectionTitle(context, 'التعليم والصحة'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      if (beneficiary.academicQualification != null) ...[
                        InfoRow(
                          icon: Icons.school,
                          label: 'المستوى التعليمي',
                          value: _getEducationLabel(
                            beneficiary.academicQualification,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.healthStatus != null) ...[
                        InfoRow(
                          icon: Icons.health_and_safety,
                          label: 'الحالة الصحية',
                          value: _getHealthStatusLabel(
                            beneficiary.healthStatus,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfIndividualsWithChronicDiseases !=
                              null &&
                          beneficiary.numberOfIndividualsWithChronicDiseases! >
                              0) ...[
                        InfoRow(
                          icon: Icons.medical_services,
                          label: 'عدد الأمراض المزمنة',
                          value:
                              '${beneficiary.numberOfIndividualsWithChronicDiseases}',
                        ),
                        const Divider(height: 1),
                      ],
                      if (beneficiary.numberOfPeopleWithSpecialNeeds != null &&
                          beneficiary.numberOfPeopleWithSpecialNeeds! > 0) ...[
                        InfoRow(
                          icon: Icons.accessible_forward,
                          label: 'ذوي الاحتياجات الخاصة',
                          value:
                              'يوجد ${beneficiary.numberOfPeopleWithSpecialNeeds} أفراد',
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Additional Contact Info
              _buildSectionTitle(context, 'معلومات اتصال إضافية'),
              const SizedBox(height: 8),
              Card(
                child: InfoRow(
                  icon: Icons.phone_android,
                  label: 'رقم هاتف بديل',
                  value: beneficiary.altPhoneNumber.toString(),
                ),
              ),
              const SizedBox(height: 16),

              // Metadata Section
              _buildSectionTitle(context, 'بيانات النظام'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.access_time,
                      label: 'تاريخ الإنشاء',
                      value: beneficiary.createdAt != null
                          ? _formatDateTime(beneficiary.createdAt!)
                          : 'غير محدد',
                    ),
                    const Divider(height: 1),
                    InfoRow(
                      icon: Icons.update,
                      label: 'آخر تحديث',
                      value: beneficiary.updatedAt != null
                          ? _formatDateTime(beneficiary.updatedAt!)
                          : 'غير محدد',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Attachments Section
              _buildSectionTitle(context, 'المرفقات'),
              SizedBox(height: 8.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: AttachmentsSectionEnhanced(
                    beneficiaryId: beneficiaryId,
                    readOnly: false,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Visits Section
              _buildSectionTitle(context, 'سجل الزيارات'),
              SizedBox(height: 8.h),
              _VisitsSection(
                beneficiaryId: beneficiaryId,
                beneficiary: beneficiary,
              ),
              SizedBox(height: 16.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/beneficiaries/add?id=$beneficiaryId');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecordVisitPageEnhanced(
                              beneficiary: beneficiary,
                            ),
                          ),
                        );
                        if (result == true) {
                          // Reload visits after successful creation
                          ref
                              .read(visitNotifierProvider.notifier)
                              .loadBeneficiaryVisits(beneficiaryId);
                        }
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

  Color _getCategoryColor(int? sectionId) {
    switch (sectionId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(int? sectionId) {
    switch (sectionId) {
      case 1:
        return 'يتيم';
      case 2:
        return 'فقير';
      case 3:
        return 'أرملة';
      case 4:
        return 'معاق';
      default:
        return sectionId?.toString() ?? '-';
    }
  }

  String _getMaritalStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'أعزب';
      case 2:
        return 'متزوج';
      case 3:
        return 'مطلق';
      case 4:
        return 'أرمل';
      default:
        return status.toString();
    }
  }

  String _getHealthStatusLabel(int? status) {
    if (status == null) return '-';
    switch (status) {
      case 1:
        return 'جيدة';
      case 2:
        return 'متوسطة';
      case 3:
        return 'ضعيفة';
      case 4:
        return 'مرض مزمن';
      default:
        return status.toString();
    }
  }

  String _getEducationLabel(int? level) {
    if (level == null) return '-';
    switch (level) {
      case 1:
        return 'بدون تعليم';
      case 2:
        return 'ابتدائي';
      case 3:
        return 'متوسط/ثانوي';
      case 4:
        return 'جامعي';
      default:
        return level.toString();
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
        final intId = int.tryParse(beneficiaryId);
        if (intId == null) return;
        await database.beneficiariesDao.deleteBeneficiary(intId);
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

// Visits Section Widget using Clean Architecture
class _VisitsSection extends ConsumerStatefulWidget {
  final String beneficiaryId;
  final Beneficiary beneficiary;

  const _VisitsSection({
    required this.beneficiaryId,
    required this.beneficiary,
  });

  @override
  ConsumerState<_VisitsSection> createState() => _VisitsSectionState();
}

class _VisitsSectionState extends ConsumerState<_VisitsSection> {
  @override
  void initState() {
    super.initState();
    // Load visits when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(visitNotifierProvider.notifier)
          .loadBeneficiaryVisits(widget.beneficiaryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(visitNotifierProvider);

    if (visitState.isLoading) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (visitState.errorMessage != null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
              SizedBox(height: 12.h),
              Text(
                visitState.errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final visits = visitState.visits;

    if (visits.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'لا توجد زيارات مسجلة',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Visits Summary
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'عدد الزيارات: ${visits.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                if (visits.isNotEmpty)
                  Text(
                    'آخر زيارة: ${_formatDateShort(visits.first.visitDate)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          // Visits List (show last 3) using VisitCard widget
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visits.length > 3 ? 3 : visits.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return VisitCard(
                visit: visit,
                onTap: () {
                  // TODO: Navigate to visit details page
                },
              );
            },
          ),
          if (visits.length > 3)
            TextButton(
              onPressed: () {
                // TODO: Show all visits page
              },
              child: Text('عرض جميع الزيارات (${visits.length})'),
            ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
