import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../features/taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
import '../../../../features/taxonomies/domain/entities/taxonomy_group.dart';
import '../../../../features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/ux/ux_widgets.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../../domain/helpers/beneficiary_domain_helpers.dart';
import '../utils/taxonomy_value_resolver.dart';
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

  Map<String, String> _buildTaxonomyLabelMap(List<taxonomy_domain.Taxonomy> options) {
    final labels = <String, String>{};

    for (final taxonomy in options) {
      final code = taxonomy.code.trim();
      final id = taxonomy.id.trim();
      if (code.isNotEmpty) {
        labels[code] = taxonomy.label;
        labels[code.toLowerCase()] = taxonomy.label;
      }
      if (id.isNotEmpty) {
        labels[id] = taxonomy.label;
      }

      final canonical = TaxonomyValueResolver.resolveCanonicalToken(code: taxonomy.code, id: taxonomy.id);
      if (canonical != null && canonical.isNotEmpty) {
        labels[canonical] = taxonomy.label;
      }

      final numericValue = TaxonomyValueResolver.resolveToInt(code: taxonomy.code, id: taxonomy.id);
      if (numericValue != null) {
        labels[numericValue.toString()] = taxonomy.label;
      }
    }

    return labels;
  }

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
      unawaited(ref.read(beneficiaryDetailsProvider.notifier).loadBeneficiary(_beneficiaryIntId!));
      unawaited(ref.read(visitNotifierProvider.notifier).loadBeneficiaryVisits(_resolvedBeneficiaryId!));
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
    final taxonomyIndexAsync = ref.watch(bridgeTaxonomiesIndexOnceProvider);
    final categoryLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) {
        final sectionOptions = index[TaxonomyGroup.section] ?? const <taxonomy_domain.Taxonomy>[];
        final categoryOptions = index[TaxonomyGroup.category] ?? const <taxonomy_domain.Taxonomy>[];
        final source = sectionOptions.isNotEmpty ? sectionOptions : categoryOptions;
        return _buildTaxonomyLabelMap(source);
      },
      orElse: () => const <String, String>{},
    );
    final genderLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) => _buildTaxonomyLabelMap(index[TaxonomyGroup.gender] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
    );
    final governorateLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) => _buildTaxonomyLabelMap(index[TaxonomyGroup.governorate] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
    );
    final cityLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) => _buildTaxonomyLabelMap(index[TaxonomyGroup.governorate] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
    );
    final assistanceTypeLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) =>
          _buildTaxonomyLabelMap(index[TaxonomyGroup.assistanceType] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
    );
    final disabilityTypeLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) =>
          _buildTaxonomyLabelMap(index[TaxonomyGroup.disabilityType] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
    );
    final incomeSourceLabelsByCode = taxonomyIndexAsync.maybeWhen(
      data: (index) => _buildTaxonomyLabelMap(index[TaxonomyGroup.incomeSource] ?? const <taxonomy_domain.Taxonomy>[]),
      orElse: () => const <String, String>{},
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
        categoryLabelsByCode: categoryLabelsByCode,
        genderLabelsByCode: genderLabelsByCode,
        governorateLabelsByCode: governorateLabelsByCode,
        cityLabelsByCode: cityLabelsByCode,
        assistanceTypeLabelsByCode: assistanceTypeLabelsByCode,
        disabilityTypeLabelsByCode: disabilityTypeLabelsByCode,
        incomeSourceLabelsByCode: incomeSourceLabelsByCode,
      ),
      bottomNavigationBar: beneficiary != null ? _buildBottomActionBar(context) : null,
    );
  }

  // ============================================================================
  // 🎨 UI Building Methods
  // ============================================================================

  AppBar _buildAppBar(BuildContext context, beneficiary) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorInfo = beneficiary != null ? BeneficiaryDomainHelpers.getCategoryColorInfo(beneficiary.category) : null;
    final backgroundColor = colorInfo != null ? Color(colorInfo.light) : colorScheme.surface;
    final foregroundColor = _foregroundFor(backgroundColor, colorScheme);

    return AppBar(
      title: const Text('تفاصيل المستفيد'),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: IconThemeData(color: foregroundColor),
      actionsIconTheme: IconThemeData(color: foregroundColor),
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
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
            CheckedPopupMenuItem(
              value: 'timeline',
              checked: _showTimelineView,
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
                  Icon(Icons.delete_outline, size: 20.sp, color: colorScheme.error),
                  SizedBox(width: 10.w),
                  Text('حذف', style: TextStyle(color: colorScheme.error)),
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
    required Map<String, String> categoryLabelsByCode,
    required Map<String, String> genderLabelsByCode,
    required Map<String, String> governorateLabelsByCode,
    required Map<String, String> cityLabelsByCode,
    required Map<String, String> assistanceTypeLabelsByCode,
    required Map<String, String> disabilityTypeLabelsByCode,
    required Map<String, String> incomeSourceLabelsByCode,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionGap = SizedBox(height: 18.h);

    if (isLoading) return _buildShimmerSkeleton(context);
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
                sectionGap,
                _buildQuickStats(beneficiary),
                sectionGap,
                _buildProfileStrengthCard(context, beneficiary),
                sectionGap,
                InfoSection(
                  title: 'المعلومات الأساسية',
                  icon: Icons.person_outline,
                  items: InfoBuilders.buildBasicInfoItems(
                    beneficiary,
                    categoryLabelsByCode: categoryLabelsByCode,
                    genderLabelsByCode: genderLabelsByCode,
                    governorateLabelsByCode: governorateLabelsByCode,
                    cityLabelsByCode: cityLabelsByCode,
                  ),
                ),
                sectionGap,
                InfoSection(
                  title: 'معلومات التواصل',
                  icon: Icons.phone_outlined,
                  accentColor: colorScheme.secondary,
                  items: InfoBuilders.buildContactInfoItems(beneficiary),
                ),
                sectionGap,
                if (BeneficiaryValidationHelpers.hasFamilyInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'معلومات العائلة (أساسية)',
                    icon: Icons.family_restroom,
                    accentColor: colorScheme.tertiary,
                    items: InfoBuilders.buildFamilyInfoItems(beneficiary),
                  ),
                  sectionGap,
                ],
                // قسم أفراد العائلة التفصيلي (الجديد)
                FamilySection(beneficiaryId: _beneficiaryIntId!),
                sectionGap,
                if (BeneficiaryValidationHelpers.hasLocationInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'السكن والنزوح',
                    icon: Icons.home_outlined,
                    accentColor: colorScheme.primary,
                    items: InfoBuilders.buildLocationInfoItems(beneficiary),
                  ),
                  sectionGap,
                ],
                if (BeneficiaryValidationHelpers.hasEducationHealthInfo(
                  beneficiary,
                )) ...[
                  InfoSection(
                    title: 'التعليم والصحة',
                    icon: Icons.school_outlined,
                    accentColor: colorScheme.tertiary,
                    items: InfoBuilders.buildEducationHealthItems(
                      beneficiary,
                      assistanceTypeLabelsByCode: assistanceTypeLabelsByCode,
                      disabilityTypeLabelsByCode: disabilityTypeLabelsByCode,
                      incomeSourceLabelsByCode: incomeSourceLabelsByCode,
                    ),
                  ),
                  sectionGap,
                ],
                if (BeneficiaryValidationHelpers.hasNotes(beneficiary)) ...[
                  NeedsSection(beneficiary: beneficiary),
                  sectionGap,
                ],
                InfoSection(
                  title: 'بيانات النظام',
                  icon: Icons.info_outline,
                  accentColor: colorScheme.onSurfaceVariant,
                  items: InfoBuilders.buildSystemInfoItems(beneficiary),
                ),
                sectionGap,
                SponsorshipsSection(beneficiaryId: _beneficiaryIntId!),
                sectionGap,
                AttachmentsSection(
                  beneficiaryId: _resolvedBeneficiaryId ?? widget.beneficiaryId,
                ),
                sectionGap,
                VisitsSection(
                  beneficiary: beneficiary,
                  beneficiaryId: _resolvedBeneficiaryId ?? widget.beneficiaryId,
                  visitState: ref.watch(visitNotifierProvider),
                  showTimelineView: _showTimelineView,
                  onRetry: () {
                    unawaited(ref
                        .read(visitNotifierProvider.notifier)
                        .loadBeneficiaryVisits(_resolvedBeneficiaryId ?? widget.beneficiaryId));
                  },
                  onToggleView: () {
                    setState(() => _showTimelineView = !_showTimelineView);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: ActionButtons(
          onEdit: () => _navigateToEdit(context),
          onAddVisit: _navigateToAddVisit,
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

  Widget _buildProfileStrengthCard(BuildContext context, dynamic beneficiary) {
    final colorScheme = Theme.of(context).colorScheme;
    var score = 0;
    var checks = 0;

    bool addCheck(bool pass) {
      checks += 1;
      if (pass) score += 1;
      return pass;
    }

    addCheck((beneficiary.fullName as String?)?.trim().isNotEmpty == true);
    addCheck((beneficiary.nationalId as String?)?.trim().isNotEmpty == true);
    addCheck((beneficiary.phoneNumber as String?)?.trim().isNotEmpty == true);
    addCheck((beneficiary.governorate as String?)?.trim().isNotEmpty == true);
    addCheck((beneficiary.district as String?)?.trim().isNotEmpty == true);
    addCheck(beneficiary.birthDate != null);
    addCheck(beneficiary.notes != null && (beneficiary.notes as String).trim().isNotEmpty);

    final percent = checks == 0 ? 0 : ((score / checks) * 100).round();
    final levelText = percent >= 85 ? 'ممتاز' : (percent >= 60 ? 'جيد' : 'ضعيف');
    final levelColor =
        percent >= 85 ? colorScheme.secondary : (percent >= 60 ? colorScheme.tertiary : colorScheme.error);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 18.sp, color: colorScheme.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Profile Strength: $percent%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  levelText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8.h,
                backgroundColor: colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityDebugBanner() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.55)),
      ),
      child: Text(
        'DEBUG LINK | routeId: ${widget.beneficiaryId} | resolvedLocalId: ${_resolvedBeneficiaryId ?? '-'} | localIntId: ${_beneficiaryIntId ?? '-'}',
        style: TextStyle(
          fontSize: 11.sp,
          color: colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildShimmerCard(context, height: 180.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(context, height: 150.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(context, height: 120.h),
        SizedBox(height: 20.h),
        _buildShimmerCard(context, height: 100.h),
      ],
    );
  }

  Widget _buildShimmerCard(BuildContext context, {required double height}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
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
              Container(width: 120.w, height: 16.h, color: colorScheme.surface),
              SizedBox(height: 12.h),
              Expanded(child: Container(color: colorScheme.surface)),
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
      unawaited(context.push('/beneficiaries/${_resolvedBeneficiaryId ?? widget.beneficiaryId}/edit'));
    } catch (e) {
      EnhancedSnackbar.showError(context, message: 'خطأ في الانتقال: $e');
    }
  }

  Future<void> _navigateToAddVisit() async {
    if (!mounted) return;

    final beneficiaryIntId = _beneficiaryIntId;
    if (beneficiaryIntId == null) {
      EnhancedSnackbar.showError(context, message: 'لا يمكن فتح نموذج الزيارة حالياً');
      return;
    }

    LoadingDialog.show(context, message: 'جاري التحميل...');
    final db = ref.read(databaseProvider);
    final rows = await (db.select(db.beneficiaries)..where((t) => t.id.equals(beneficiaryIntId))).get();

    if (!mounted || !context.mounted) return;
    LoadingDialog.hide(context);

    if (rows.isEmpty) {
      EnhancedSnackbar.showError(context, message: 'تعذر فتح نموذج الزيارة');
      return;
    }

    final beneficiary = rows.first;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordVisitPageEnhanced(beneficiary: beneficiary),
      ),
    );
    if (result == true) {
      unawaited(ref
          .read(visitNotifierProvider.notifier)
          .loadBeneficiaryVisits(_resolvedBeneficiaryId ?? widget.beneficiaryId));
    }
  }

  Future<void> _handleRefresh() async {
    if (_beneficiaryIntId == null) return;

    try {
      await ref.read(beneficiaryDetailsProvider.notifier).refresh(_beneficiaryIntId!);
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(context, message: 'تعذر تحديث البيانات');
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

        if (!mounted || !context.mounted) return;
        LoadingDialog.hide(context);

        if (success) {
          EnhancedSnackbar.showSuccess(
            context,
            message: 'تم حذف المستفيد بنجاح',
          );
          context.pop();
        } else {
          final errorMsg = ref.read(beneficiaryDetailsProvider).errorMessage ?? 'خطأ غير معروف';
          EnhancedSnackbar.showError(context, message: 'تعذر حذف المستفيد: $errorMsg');
        }
      } catch (e) {
        if (mounted && context.mounted) {
          LoadingDialog.hide(context);
          EnhancedSnackbar.showError(context, message: 'حدث خطأ غير متوقع أثناء الحذف: $e');
        }
      }
    }
  }

  Future<void> _shareScreenshot(BuildContext context) async {
    try {
      LoadingDialog.show(context, message: 'جاري التحضير...');

      final image = await _screenshotController.capture();

      if (image == null) {
        if (mounted && context.mounted) {
          LoadingDialog.hide(context);
          EnhancedSnackbar.showError(context, message: 'فشل التقاط الصورة');
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/beneficiary_${widget.beneficiaryId}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (!mounted || !context.mounted) return;
      LoadingDialog.hide(context);

      await Share.shareXFiles([XFile(imagePath)], text: 'معلومات المستفيد');
    } catch (e) {
      if (!mounted || !context.mounted) return;
      LoadingDialog.hide(context);
      EnhancedSnackbar.showError(context, message: 'تعذر مشاركة التفاصيل: $e');
    }
  }

  // ============================================================================
  // 🛠️ Utility Methods
  // ============================================================================

  String _formatDateShort(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  Color _foregroundFor(Color background, ColorScheme colorScheme) {
    final isDark = background.computeLuminance() < 0.45;
    return isDark ? colorScheme.onPrimary : colorScheme.onSurface;
  }
}
