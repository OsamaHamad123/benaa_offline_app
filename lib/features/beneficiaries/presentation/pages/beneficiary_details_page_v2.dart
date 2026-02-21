import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../../domain/helpers/beneficiary_domain_helpers.dart';
import '../providers/details/beneficiary_details_provider.dart';
import 'details_widgets/details_header_card.dart';
import 'details_widgets/info_section.dart';
import 'details_widgets/states/reusable_states.dart' hide EmptyStateWidget;
import 'details_widgets/quick_stats_card.dart';
import 'details_widgets/helpers/info_builders.dart';
import 'details_widgets/helpers/validation_helpers.dart';
import 'details_widgets/sections/needs_section.dart';
import 'details_widgets/sections/attachments_section.dart';
import 'details_widgets/sections/visits_section.dart';
import 'details_widgets/sections/action_buttons.dart';
import 'details_widgets/sections/sponsorships_section.dart';
import '../widgets/family_section.dart';
import '../../../visits/presentation/pages/record_visit_page_enhanced.dart';
import '../../../visits/presentation/providers/visit_providers.dart' hide databaseProvider;
import '../../../attachments/presentation/providers/attachments_provider.dart';
import '../../../../core/providers/providers.dart';

/// 📄 Beneficiary Details Page V2 - Clean Architecture
///
/// Refactored for better maintainability and separation of concerns
class BeneficiaryDetailsPageV2 extends ConsumerStatefulWidget {
  final String beneficiaryId;

  const BeneficiaryDetailsPageV2({required this.beneficiaryId, super.key});

  @override
  ConsumerState<BeneficiaryDetailsPageV2> createState() => _BeneficiaryDetailsPageV2State();
}

class _BeneficiaryDetailsPageV2State extends ConsumerState<BeneficiaryDetailsPageV2> {
  int? _beneficiaryIntId;
  String? _resolvedBeneficiaryId;
  bool _isResolvingIdentity = true;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _showTimelineView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final database = ref.read(databaseProvider);
    final resolved = await BeneficiaryIdentityResolver.resolveLocalBeneficiaryIdAsString(
      database: database,
      beneficiaryId: widget.beneficiaryId,
    );

    if (!mounted) return;

    final effective = resolved ?? widget.beneficiaryId;
    final intId = int.tryParse(effective);

    setState(() {
      _resolvedBeneficiaryId = effective;
      _beneficiaryIntId = intId;
      _isResolvingIdentity = false;
    });

    if (_beneficiaryIntId != null) {
      ref.read(beneficiaryDetailsProvider.notifier).loadBeneficiary(_beneficiaryIntId!);
      ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(_resolvedBeneficiaryId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final beneficiary = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.beneficiary),
    );
    final isLoading = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      beneficiaryDetailsProvider.select((s) => s.errorMessage),
    );

    if (_isResolvingIdentity) {
      return Scaffold(
        appBar: AppBar(title: const Text('جاري التحميل...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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

  // ============================================================================
  // 🎨 UI Building Methods
  // ============================================================================

  AppBar _buildAppBar(BuildContext context, beneficiary) {
    final colorInfo = beneficiary != null ? BeneficiaryDomainHelpers.getCategoryColorInfo(beneficiary.category) : null;

    return AppBar(
      title: const Text('تفاصيل المستفيد'),
      backgroundColor: colorInfo != null ? Color(colorInfo.light) : Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'مشاركة',
          onPressed: beneficiary != null ? () => _shareScreenshot(context) : null,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'تعديل',
          onPressed: beneficiary != null ? () => _navigateToEdit(context) : null,
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'timeline',
              child: Row(
                children: [
                  Icon(
                    _showTimelineView ? Icons.list : Icons.timeline,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(_showTimelineView ? 'عرض القائمة' : 'عرض Timeline'),
                ],
              ),
            ),
            const PopupMenuDivider(),
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
    if (isLoading) return _buildShimmerSkeleton();
    if (errorMessage != null) return _buildErrorState(context, errorMessage);
    if (beneficiary == null) return _buildEmptyState(context);

    return Screenshot(
      controller: _screenshotController,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
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
                if (kDebugMode) _buildIdentityDebugBanner(),
                if (kDebugMode) SizedBox(height: 12.h),
                DetailsHeaderCard(beneficiary: beneficiary),
                SizedBox(height: 20.h),
                _buildQuickStats(beneficiary),
                SizedBox(height: 20.h),
                InfoSection(
                  title: 'المعلومات الأساسية',
                  icon: Icons.person_outline,
                  items: InfoBuilders.buildBasicInfoItems(beneficiary),
                ),
                SizedBox(height: 20.h),
                InfoSection(
                  title: 'معلومات التواصل',
                  icon: Icons.phone_outlined,
                  accentColor: Colors.green,
                  items: InfoBuilders.buildContactInfoItems(beneficiary),
                ),
                SizedBox(height: 20.h),
                if (BeneficiaryValidationHelpers.hasFamilyInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'معلومات العائلة (أساسية)',
                    icon: Icons.family_restroom,
                    accentColor: Colors.purple,
                    items: InfoBuilders.buildFamilyInfoItems(beneficiary),
                  ),
                  SizedBox(height: 20.h),
                ],
                // قسم أفراد العائلة التفصيلي (الجديد)
                FamilySection(beneficiaryId: _beneficiaryIntId!),
                SizedBox(height: 20.h),
                if (BeneficiaryValidationHelpers.hasLocationInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'السكن والنزوح',
                    icon: Icons.home_outlined,
                    accentColor: Colors.teal,
                    items: InfoBuilders.buildLocationInfoItems(beneficiary),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (BeneficiaryValidationHelpers.hasEducationHealthInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'التعليم والصحة',
                    icon: Icons.school_outlined,
                    accentColor: Colors.indigo,
                    items: InfoBuilders.buildEducationHealthItems(beneficiary),
                  ),
                  SizedBox(height: 20.h),
                ],
                if (BeneficiaryValidationHelpers.hasNotes(beneficiary)) ...[
                  NeedsSection(beneficiary: beneficiary),
                  SizedBox(height: 20.h),
                ],
                InfoSection(
                  title: 'بيانات النظام',
                  icon: Icons.info_outline,
                  accentColor: Colors.grey,
                  items: InfoBuilders.buildSystemInfoItems(beneficiary),
                ),
                SizedBox(height: 20.h),
                SponsorshipsSection(beneficiaryId: _beneficiaryIntId!),
                SizedBox(height: 20.h),
                AttachmentsSection(
                  beneficiaryId: _resolvedBeneficiaryId ?? widget.beneficiaryId,
                ),
                SizedBox(height: 20.h),
                VisitsSection(
                  beneficiary: beneficiary,
                  beneficiaryId: _resolvedBeneficiaryId ?? widget.beneficiaryId,
                  visitState: ref.watch(visitNotifierProvider),
                  showTimelineView: _showTimelineView,
                  onToggleView: () {
                    setState(() => _showTimelineView = !_showTimelineView);
                  },
                ),
                SizedBox(height: 20.h),
                ActionButtons(
                  onEdit: () => _navigateToEdit(context),
                  onAddVisit: () => _navigateToAddVisit(context, beneficiary),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 📊 Helper Widgets
  // ============================================================================

  Widget _buildQuickStats(beneficiary) {
    final visitState = ref.watch(visitNotifierProvider);
    final attachmentsState = ref.watch(
      attachmentsProvider(_resolvedBeneficiaryId ?? widget.beneficiaryId),
    );

    return QuickStatsCard(
      visitsCount: visitState.visits.length,
      attachmentsCount: attachmentsState.attachments.length,
      lastVisitDate: visitState.visits.isNotEmpty ? _formatDateShort(visitState.visits.first.visitDate) : 'لا توجد',
    );
  }

  Widget _buildIdentityDebugBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.orange.withOpacity(0.55)),
      ),
      child: Text(
        'DEBUG LINK | routeId: ${widget.beneficiaryId} | resolvedLocalId: ${_resolvedBeneficiaryId ?? '-'} | localIntId: ${_beneficiaryIntId ?? '-'}',
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.brown[800],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

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
          borderRadius: AppDimensions.borderRadiusXL,
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

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.person_off_outlined,
      title: 'لا توجد بيانات',
      message: 'لم يتم العثور على معلومات المستفيد',
      action: ElevatedButton(
        onPressed: () => context.pop(),
        child: const Text('رجوع'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return RetryWidget(message: message, onRetry: _handleRefresh);
  }

  // ============================================================================
  // 🎯 Navigation & Actions
  // ============================================================================

  void _navigateToEdit(BuildContext context) {
    try {
      context.push('/beneficiaries/${_resolvedBeneficiaryId ?? widget.beneficiaryId}/edit');
    } catch (e) {
      EnhancedSnackbar.showError(context, message: 'خطأ في الانتقال: $e');
    }
  }

  Future<void> _navigateToRecordVisit(BuildContext context) async {
    try {
      if (_beneficiaryIntId == null) return;

      LoadingDialog.show(context, message: 'جاري التحميل...');

      final db = ref.read(databaseProvider);
      final beneficiaries = await (db.select(
        db.beneficiaries,
      )..where((t) => t.id.equals(_beneficiaryIntId!)))
          .get();

      if (mounted) LoadingDialog.hide(context);

      if (beneficiaries.isEmpty) {
        if (mounted) {
          EnhancedSnackbar.showError(
            context,
            message: 'خطأ: لم يتم العثور على المستفيد',
          );
        }
        return;
      }

      final beneficiary = beneficiaries.first;

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecordVisitPageEnhanced(beneficiary: beneficiary),
          ),
        );

        ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(_resolvedBeneficiaryId ?? widget.beneficiaryId);
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        EnhancedSnackbar.showError(context, message: 'خطأ: $e');
      }
    }
  }

  Future<void> _navigateToAddVisit(
    BuildContext context,
    dynamic beneficiary,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordVisitPageEnhanced(beneficiary: beneficiary),
      ),
    );
    if (result == true) {
      ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(_resolvedBeneficiaryId ?? widget.beneficiaryId);
    }
  }

  Future<void> _handleRefresh() async {
    if (_beneficiaryIntId == null) return;

    try {
      await ref.read(beneficiaryDetailsProvider.notifier).refresh(_beneficiaryIntId!);
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(context, message: 'فشل تحديث البيانات');
      }
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'delete':
        _showDeleteDialog(context);
        break;
      case 'print':
        EnhancedSnackbar.showInfo(
          context,
          message: 'سيتم إضافة الطباعة قريباً',
        );
        break;
      case 'timeline':
        setState(() => _showTimelineView = !_showTimelineView);
        break;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'تأكيد الحذف',
      content: 'هل أنت متأكد من حذف هذا المستفيد؟',
    );

    if (confirmed == true && context.mounted) {
      LoadingDialog.show(context, message: 'جاري الحذف...');

      try {
        if (_beneficiaryIntId == null) return;

        final success = await ref.read(beneficiaryDetailsProvider.notifier).deleteBeneficiary(_beneficiaryIntId!);

        if (mounted) LoadingDialog.hide(context);

        if (success && mounted) {
          EnhancedSnackbar.showSuccess(
            context,
            message: '✓ تم حذف المستفيد بنجاح',
          );
          context.pop();
        } else if (mounted) {
          final errorMsg = ref.read(beneficiaryDetailsProvider).errorMessage ?? 'خطأ غير معروف';
          EnhancedSnackbar.showError(context, message: 'خطأ: $errorMsg');
        }
      } catch (e) {
        if (mounted) {
          LoadingDialog.hide(context);
          EnhancedSnackbar.showError(context, message: 'خطأ غير متوقع: $e');
        }
      }
    }
  }

  Future<void> _shareScreenshot(BuildContext context) async {
    try {
      LoadingDialog.show(context, message: 'جاري التحضير...');

      final image = await _screenshotController.capture();

      if (image == null) {
        if (mounted) {
          LoadingDialog.hide(context);
          EnhancedSnackbar.showError(context, message: 'فشل التقاط الصورة');
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/beneficiary_${widget.beneficiaryId}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (mounted) LoadingDialog.hide(context);

      await Share.shareXFiles([XFile(imagePath)], text: 'معلومات المستفيد');
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        EnhancedSnackbar.showError(context, message: 'خطأ في المشاركة: $e');
      }
    }
  }

  // ============================================================================
  // 🛠️ Utility Methods
  // ============================================================================

  String _formatDateShort(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
