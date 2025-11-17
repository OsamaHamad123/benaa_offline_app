import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/helpers/beneficiary_domain_helpers.dart';
import '../providers/details/beneficiary_details_provider.dart';
import 'details_widgets/details_header_card.dart';
import 'details_widgets/info_section.dart';
import 'details_widgets/states/reusable_states.dart';
import '../../../visits/presentation/pages/record_visit_page_clean.dart';
import '../../../visits/presentation/providers/visit_providers.dart';
import '../../../../core/widgets/beneficiary/visit_card.dart';
import '../../../attachments/presentation/widgets/attachments_section_enhanced.dart';

/// Beneficiary Details Page V2 - Clean Architecture
class BeneficiaryDetailsPageV2 extends ConsumerStatefulWidget {
  final String beneficiaryId;

  const BeneficiaryDetailsPageV2({super.key, required this.beneficiaryId});

  @override
  ConsumerState<BeneficiaryDetailsPageV2> createState() =>
      _BeneficiaryDetailsPageV2State();
}

class _BeneficiaryDetailsPageV2State
    extends ConsumerState<BeneficiaryDetailsPageV2> {
  // ⚡ Performance: Cache parsed ID to avoid repeated parsing
  late final int? _beneficiaryIntId;

  @override
  void initState() {
    super.initState();
    // Parse ID once and cache
    _beneficiaryIntId = int.tryParse(widget.beneficiaryId);

    // Load beneficiary data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_beneficiaryIntId != null) {
        ref
            .read(beneficiaryDetailsProvider.notifier)
            .loadBeneficiary(_beneficiaryIntId);
        ref
            .read(visitNotifierProvider.notifier)
            .loadBeneficiaryVisits(widget.beneficiaryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ Performance: Selective watching - rebuild only when specific fields change
    final beneficiary = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.beneficiary),
    );
    final isLoading = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.errorMessage),
    );

    if (_beneficiaryIntId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('ID غير صالح')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, beneficiary),
      body: _buildBody(
        context,
        beneficiary: beneficiary,
        isLoading: isLoading,
        errorMessage: errorMessage,
      ),
      floatingActionButton: beneficiary != null
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToRecordVisit(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('تسجيل زيارة'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  AppBar _buildAppBar(BuildContext context, beneficiary) {
    final colorInfo = beneficiary != null
        ? BeneficiaryDomainHelpers.getCategoryColorInfo(beneficiary.category)
        : null;

    return AppBar(
      title: const Text('تفاصيل المستفيد'),
      backgroundColor: colorInfo != null
          ? Color(colorInfo.light)
          : Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'مشاركة',
          onPressed: beneficiary != null
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سيتم إضافة المشاركة قريباً')),
                  );
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'تعديل',
          onPressed: beneficiary != null
              ? () => _navigateToEdit(context)
              : null,
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print_outlined, size: 20.sp),
                  SizedBox(width: 10.w),
                  const Text('طباعة'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20.sp, color: Colors.red),
                  SizedBox(width: 10.w),
                  const Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required beneficiary,
    required bool isLoading,
    required String? errorMessage,
  }) {
    if (isLoading) {
      return _buildShimmerSkeleton();
    }

    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage);
    }

    if (beneficiary == null) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(),
      displacement: 40,
      strokeWidth: 3.0,
      child: AnimationLimiter(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              // Header Card
              DetailsHeaderCard(beneficiary: beneficiary),
              SizedBox(height: 20.h),

              // Basic Info Section
              InfoSection(
                title: 'المعلومات الأساسية',
                icon: Icons.person_outline,
                items: _buildBasicInfoItems(beneficiary),
              ),
              SizedBox(height: 20.h),

              // Contact Info Section
              InfoSection(
                title: 'معلومات التواصل',
                icon: Icons.phone_outlined,
                accentColor: Colors.green,
                items: _buildContactInfoItems(beneficiary),
              ),
              SizedBox(height: 20.h),

              // Family Info Section
              if (_hasFamilyInfo(beneficiary)) ...[
                InfoSection(
                  title: 'معلومات العائلة',
                  icon: Icons.family_restroom,
                  accentColor: Colors.purple,
                  items: _buildFamilyInfoItems(beneficiary),
                ),
                SizedBox(height: 20.h),
              ],

              // Location & Displacement Section
              if (_hasLocationInfo(beneficiary)) ...[
                InfoSection(
                  title: 'السكن والنزوح',
                  icon: Icons.home_outlined,
                  accentColor: Colors.teal,
                  items: _buildLocationInfoItems(beneficiary),
                ),
                SizedBox(height: 20.h),
              ],

              // Education & Health Section
              if (_hasEducationHealthInfo(beneficiary)) ...[
                InfoSection(
                  title: 'التعليم والصحة',
                  icon: Icons.school_outlined,
                  accentColor: Colors.indigo,
                  items: _buildEducationHealthItems(beneficiary),
                ),
                SizedBox(height: 20.h),
              ],

              // Needs & Notes Section
              if (beneficiary.notes != null &&
                  beneficiary.notes!.isNotEmpty) ...[
                _buildNeedsSection(beneficiary),
                SizedBox(height: 20.h),
              ],

              // System Metadata
              InfoSection(
                title: 'بيانات النظام',
                icon: Icons.info_outline,
                accentColor: Colors.grey,
                items: _buildSystemInfoItems(beneficiary),
              ),
              SizedBox(height: 20.h),

              // Attachments Section
              _buildAttachmentsSection(),
              SizedBox(height: 20.h),

              // Visits Section
              _buildVisitsSection(beneficiary),
              SizedBox(height: 20.h),

              // Action Buttons
              _buildActionButtons(context, beneficiary),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
            ],
          ),
        ),
      ),
    );
  }

  List<InfoItem> _buildBasicInfoItems(beneficiary) {
    final items = <InfoItem>[];

    items.add(
      InfoItem(
        icon: Icons.badge_outlined,
        label: 'الرقم الوطني',
        value: beneficiary.nationalId,
      ),
    );

    if (beneficiary.fileNo != null) {
      items.add(
        InfoItem(
          icon: Icons.folder_outlined,
          label: 'رقم الملف',
          value: beneficiary.fileNo!,
        ),
      );
    }

    items.add(
      InfoItem(
        icon: Icons.category_outlined,
        label: 'الفئة',
        value: BeneficiaryDomainHelpers.getCategoryLabel(beneficiary.category),
      ),
    );

    items.add(
      InfoItem(
        icon: Icons.wc_outlined,
        label: 'الجنس',
        value: BeneficiaryDomainHelpers.getGenderLabel(beneficiary.gender),
      ),
    );

    if (beneficiary.birthDate != null) {
      items.add(
        InfoItem(
          icon: Icons.cake_outlined,
          label: 'تاريخ الميلاد',
          value: BeneficiaryDomainHelpers.formatDate(beneficiary.birthDate),
        ),
      );
    }

    if (beneficiary.governorate != null) {
      items.add(
        InfoItem(
          icon: Icons.location_on_outlined,
          label: 'المحافظة',
          value: BeneficiaryDomainHelpers.getGovernorateName(
            beneficiary.governorate,
          ),
        ),
      );
    }

    if (beneficiary.district != null) {
      items.add(
        InfoItem(
          icon: Icons.location_city_outlined,
          label: 'المدينة',
          value: BeneficiaryDomainHelpers.getDistrictName(beneficiary.district),
        ),
      );
    }

    return items;
  }

  List<InfoItem> _buildContactInfoItems(beneficiary) {
    final items = <InfoItem>[];

    items.add(
      InfoItem(
        icon: Icons.phone,
        label: 'رقم الهاتف',
        value: beneficiary.phoneNumber ?? '-',
      ),
    );

    items.add(
      InfoItem(
        icon: Icons.phone_android,
        label: 'رقم هاتف بديل',
        value: beneficiary.altPhoneNumber ?? '-',
      ),
    );

    return items;
  }

  List<InfoItem> _buildFamilyInfoItems(beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.fatherName != null && beneficiary.fatherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outlined,
          label: 'اسم الأب',
          value: beneficiary.fatherName!,
        ),
      );
    }

    if (beneficiary.grandFatherName != null &&
        beneficiary.grandFatherName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.person_outline,
          label: 'اسم الجد',
          value: beneficiary.grandFatherName!,
        ),
      );
    }

    if (beneficiary.familyName != null && beneficiary.familyName!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.family_restroom,
          label: 'اسم العائلة',
          value: beneficiary.familyName!,
        ),
      );
    }

    if (beneficiary.maritalStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.favorite_outline,
          label: 'الحالة الاجتماعية',
          value: BeneficiaryDomainHelpers.getMaritalStatusLabel(
            beneficiary.maritalStatus,
          ),
        ),
      );
    }

    if (beneficiary.familySize != null) {
      items.add(
        InfoItem(
          icon: Icons.groups_outlined,
          label: 'عدد أفراد الأسرة',
          value: '${beneficiary.familySize} فرد',
        ),
      );
    }

    if (beneficiary.numberOfMales != null) {
      items.add(
        InfoItem(
          icon: Icons.male,
          label: 'عدد الذكور',
          value: beneficiary.numberOfMales.toString(),
        ),
      );
    }

    if (beneficiary.numberOfFemales != null) {
      items.add(
        InfoItem(
          icon: Icons.female,
          label: 'عدد الإناث',
          value: beneficiary.numberOfFemales.toString(),
        ),
      );
    }

    return items;
  }

  List<InfoItem> _buildLocationInfoItems(beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.currentAddress != null &&
        beneficiary.currentAddress!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.home,
          label: 'العنوان الحالي',
          value: beneficiary.currentAddress!,
        ),
      );
    }

    if (beneficiary.addressBeforeDisplacement != null &&
        beneficiary.addressBeforeDisplacement!.isNotEmpty) {
      items.add(
        InfoItem(
          icon: Icons.location_city,
          label: 'العنوان قبل النزوح',
          value: beneficiary.addressBeforeDisplacement!,
        ),
      );
    }

    if (beneficiary.displacementStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.move_down,
          label: 'حالة النزوح',
          value: BeneficiaryDomainHelpers.getDisplacementStatusLabel(
            beneficiary.displacementStatus,
          ),
        ),
      );
    }

    if (beneficiary.housingStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.house_outlined,
          label: 'حالة السكن',
          value: BeneficiaryDomainHelpers.getHousingStatusLabel(
            beneficiary.housingStatus,
          ),
        ),
      );
    }

    if (beneficiary.housingType != null) {
      items.add(
        InfoItem(
          icon: Icons.home_work_outlined,
          label: 'نوع السكن',
          value: BeneficiaryDomainHelpers.getHousingTypeLabel(
            beneficiary.housingType,
          ),
        ),
      );
    }

    return items;
  }

  List<InfoItem> _buildEducationHealthItems(beneficiary) {
    final items = <InfoItem>[];

    if (beneficiary.educationLevel != null) {
      items.add(
        InfoItem(
          icon: Icons.school,
          label: 'المستوى التعليمي',
          value: BeneficiaryDomainHelpers.getEducationLabel(
            beneficiary.educationLevel,
          ),
        ),
      );
    }

    if (beneficiary.employmentStatus != null) {
      items.add(
        InfoItem(
          icon: Icons.work_outline,
          label: 'حالة عمل المعيل',
          value: BeneficiaryDomainHelpers.getEmploymentStatusLabel(
            beneficiary.employmentStatus,
          ),
        ),
      );
    }

    items.add(
      InfoItem(
        icon: Icons.health_and_safety_outlined,
        label: 'الحالة الصحية',
        value: BeneficiaryDomainHelpers.getHealthStatusLabel(
          beneficiary.healthStatus,
        ),
      ),
    );

    if (beneficiary.chronicDiseasesCount != null &&
        beneficiary.chronicDiseasesCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.medical_services_outlined,
          label: 'عدد الأمراض المزمنة',
          value: beneficiary.chronicDiseasesCount.toString(),
        ),
      );
    }

    if (beneficiary.specialNeedsCount != null &&
        beneficiary.specialNeedsCount! > 0) {
      items.add(
        InfoItem(
          icon: Icons.accessible_forward,
          label: 'ذوي الاحتياجات الخاصة',
          value: '${beneficiary.specialNeedsCount} أفراد',
        ),
      );
    }

    return items;
  }

  List<InfoItem> _buildSystemInfoItems(beneficiary) {
    return [
      InfoItem(
        icon: Icons.access_time,
        label: 'تاريخ الإنشاء',
        value: BeneficiaryDomainHelpers.formatDateTime(beneficiary.createdAt),
      ),
      InfoItem(
        icon: Icons.update,
        label: 'آخر تحديث',
        value: BeneficiaryDomainHelpers.formatDateTime(beneficiary.updatedAt),
      ),
    ];
  }

  Widget _buildNeedsSection(beneficiary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notes_outlined, color: Colors.amber, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'الاحتياجات والملاحظات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              beneficiary.notes!,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file_outlined,
              color: Colors.blueGrey,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'المرفقات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: AttachmentsSectionEnhanced(
              beneficiaryId: widget.beneficiaryId,
              readOnly: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitsSection(beneficiary) {
    final visitState = ref.watch(visitNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_outlined, color: Colors.blue, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'سجل الزيارات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _VisitsCard(
          visitState: visitState,
          beneficiaryId: widget.beneficiaryId,
          beneficiary: beneficiary,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, beneficiary) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/beneficiaries/${widget.beneficiaryId}/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('تعديل'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RecordVisitPageClean(beneficiary: beneficiary),
                ),
              );
              if (result == true) {
                ref
                    .read(visitNotifierProvider.notifier)
                    .loadBeneficiaryVisits(widget.beneficiaryId);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة زيارة'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 🎯 Helper Methods - Extracted for better architecture
  // ============================================================================

  /// Navigate to edit page with error handling
  void _navigateToEdit(BuildContext context) {
    try {
      context.push('/beneficiaries/${widget.beneficiaryId}/edit');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في الانتقال: $e')));
    }
  }

  /// Navigate to record visit page
  Future<void> _navigateToRecordVisit(BuildContext context) async {
    try {
      if (_beneficiaryIntId == null) return;

      // Show loading
      LoadingDialog.show(context, message: 'جاري التحميل...');

      // Get full beneficiary from database
      final db = ref.read(databaseProvider);
      final beneficiaries = await (db.select(
        db.beneficiaries,
      )..where((t) => t.id.equals(_beneficiaryIntId))).get();

      if (mounted) {
        LoadingDialog.hide(context);
      }

      if (beneficiaries.isEmpty) {
        if (mounted) {
          ErrorSnackBar.show(context, 'خطأ: لم يتم العثور على المستفيد');
        }
        return;
      }

      final beneficiary = beneficiaries.first;

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                RecordVisitPageClean(beneficiary: beneficiary),
          ),
        );

        // Refresh visits after returning
        ref
            .read(visitNotifierProvider.notifier)
            .loadBeneficiaryVisits(widget.beneficiaryId);
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ErrorSnackBar.show(context, 'خطأ: $e');
      }
    }
  }

  /// Handle refresh action with proper error handling
  Future<void> _handleRefresh() async {
    if (_beneficiaryIntId == null) return;

    try {
      await ref
          .read(beneficiaryDetailsProvider.notifier)
          .refresh(_beneficiaryIntId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('فشل تحديث البيانات'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: _handleRefresh,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  /// Build empty state UI - Using reusable widget
  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.person_off_outlined,
      title: 'لا توجد بيانات',
      subtitle: 'لم يتم العثور على معلومات المستفيد',
      onActionPressed: () => context.pop(),
      actionLabel: 'رجوع',
    );
  }

  /// Build error state UI - Using reusable widget
  Widget _buildErrorState(BuildContext context, String message) {
    return ErrorStateWidget(
      message: message,
      onRetry: _handleRefresh,
      onBack: () => context.pop(),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    if (action == 'delete') {
      _showDeleteDialog(context);
    } else if (action == 'print') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم إضافة الطباعة قريباً')),
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    // ✅ Use reusable confirmation dialog
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'تأكيد الحذف',
      content: 'هل أنت متأكد من حذف هذا المستفيد؟',
    );

    if (confirmed == true && context.mounted) {
      // ✅ Use reusable loading dialog
      LoadingDialog.show(context, message: 'جاري الحذف...');

      try {
        if (_beneficiaryIntId == null) return;

        final success = await ref
            .read(beneficiaryDetailsProvider.notifier)
            .deleteBeneficiary(_beneficiaryIntId);

        if (mounted) {
          LoadingDialog.hide(context); // Close loading dialog
        }

        if (success && mounted) {
          // ✅ Use reusable success snackbar
          SuccessSnackBar.show(context, '✓ تم حذف المستفيد بنجاح');
          context.pop();
        } else if (mounted) {
          final errorMsg =
              ref.read(beneficiaryDetailsProvider).errorMessage ??
              'خطأ غير معروف';
          // ✅ Use reusable error snackbar with retry
          ErrorSnackBar.show(
            context,
            'خطأ: $errorMsg',
            onRetry: () => _showDeleteDialog(context),
          );
        }
      } catch (e) {
        if (mounted) {
          LoadingDialog.hide(context); // Close loading dialog
          ErrorSnackBar.show(context, 'خطأ غير متوقع: $e');
        }
      }
    }
  }

  bool _hasFamilyInfo(beneficiary) {
    return (beneficiary.fatherName != null &&
            beneficiary.fatherName!.isNotEmpty) ||
        (beneficiary.grandFatherName != null &&
            beneficiary.grandFatherName!.isNotEmpty) ||
        (beneficiary.familyName != null &&
            beneficiary.familyName!.isNotEmpty) ||
        beneficiary.maritalStatus != null ||
        beneficiary.familySize != null ||
        beneficiary.numberOfMales != null ||
        beneficiary.numberOfFemales != null;
  }

  bool _hasLocationInfo(beneficiary) {
    return (beneficiary.currentAddress != null &&
            beneficiary.currentAddress!.isNotEmpty) ||
        (beneficiary.addressBeforeDisplacement != null &&
            beneficiary.addressBeforeDisplacement!.isNotEmpty) ||
        beneficiary.displacementStatus != null ||
        beneficiary.housingStatus != null ||
        beneficiary.housingType != null;
  }

  bool _hasEducationHealthInfo(beneficiary) {
    return beneficiary.educationLevel != null ||
        beneficiary.employmentStatus != null ||
        (beneficiary.chronicDiseasesCount != null &&
            beneficiary.chronicDiseasesCount! > 0) ||
        (beneficiary.specialNeedsCount != null &&
            beneficiary.specialNeedsCount! > 0);
  }

  // ✨ Shimmer loading skeleton
  Widget _buildShimmerSkeleton() {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildShimmerCard(height: 180.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(height: 150.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(height: 120.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(height: 100.h),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          height: height,
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120.w, height: 16.h, color: Colors.white),
              SizedBox(height: 12.h),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visits Card Widget
class _VisitsCard extends ConsumerStatefulWidget {
  final dynamic visitState;
  final String beneficiaryId;
  final dynamic beneficiary;

  const _VisitsCard({
    required this.visitState,
    required this.beneficiaryId,
    required this.beneficiary,
  });

  @override
  ConsumerState<_VisitsCard> createState() => _VisitsCardState();
}

class _VisitsCardState extends ConsumerState<_VisitsCard> {
  bool _showAllVisits = false;

  @override
  Widget build(BuildContext context) {
    if (widget.visitState.isLoading) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.visitState.errorMessage != null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red[400]),
              SizedBox(height: 12.h),
              Text(
                widget.visitState.errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final visits = widget.visitState.visits;

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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          // Summary
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
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

          // Visits List with pagination
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllVisits
                ? visits.length
                : (visits.length > 3 ? 3 : visits.length),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final visit = visits[index];
              return VisitCard(visit: visit, onTap: () {});
            },
          ),

          // Show/Hide All button
          if (visits.length > 3)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllVisits = !_showAllVisits;
                  });
                },
                icon: Icon(
                  _showAllVisits
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20.sp,
                ),
                label: Text(
                  _showAllVisits
                      ? 'إخفاء الزيارات'
                      : 'عرض جميع الزيارات (${visits.length})',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
