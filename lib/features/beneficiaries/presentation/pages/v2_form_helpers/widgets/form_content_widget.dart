import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../form_controllers.dart';
import '../form_constants.dart';
import '../personal_profile_validator.dart';
import '../smart_helpers.dart';
import 'tab_completion_badge.dart';
import 'form_tabs_4_merged.dart';

/// 📝 Form Content Widget (Separated for performance)
///
/// Contains TabBar and TabBarView - rebuilt only when needed
/// Search state is local to prevent parent rebuilds
class FormContentWidget extends StatefulWidget {
  final TabController tabController;
  final BeneficiaryFormControllers controllers;
  final VoidCallback onBirthDateTap;
  final FocusNode firstFieldFocusNode;
  final String? beneficiaryId;
  final bool showFieldHelpers;
  final bool showProgressCard;
  final bool minimizeTopInsights;
  final VoidCallback? onFinalSave; // 🆕 Callback for final save from review tab

  const FormContentWidget({
    required this.tabController,
    required this.controllers,
    required this.onBirthDateTap,
    required this.firstFieldFocusNode,
    required this.beneficiaryId,
    required this.showFieldHelpers,
    this.showProgressCard = false,
    this.minimizeTopInsights = false,
    super.key,
    this.onFinalSave,
  });

  @override
  State<FormContentWidget> createState() => _FormContentWidgetState();
}

class _FormContentWidgetState extends State<FormContentWidget> {
  static const double _panelRadius = 10;
  static const double _panelHorizontal = 12;
  static const double _panelTop = 8;
  static const double _panelBottom = 6;

  static const Map<int, String> _tabGuidance = {
    0: 'أكمل البيانات الأساسية أولاً ثم انتقل للعائلة.',
    1: 'أضف معلومات أفراد العائلة الأساسية قبل المتابعة.',
    2: 'تحقق من بيانات التواصل والملاحظات لتسهيل المتابعة الميدانية.',
    3: 'أضف المرفقات المطلوبة حسب الحالة ثم راجعها قبل الحفظ.',
    4: 'راجع جميع البيانات وتأكد من الاكتمال قبل الحفظ النهائي.',
  };

  // ⚡ Local state - prevents parent rebuilds
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showCompactGuidance = false;
  bool _showCompactInsights = false;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  static const List<int> _tabOrderByPriority = [0, 2, 1, 3, 4];

  @override
  void didUpdateWidget(covariant FormContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_onTabChanged);
      widget.tabController.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (widget.tabController.indexIsChanging) return;
    setState(() {
      _showCompactGuidance = false;
      _showCompactInsights = false;
    });
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 360;
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final tabStats = FormCompletionCalculator.calculateTabStats(widget.controllers);
    final currentIndex = widget.tabController.index.clamp(0, FormConstants.totalTabs - 1);
    final currentStats =
        tabStats[currentIndex] ?? const TabCompletionStats(completedFields: 0, totalFields: 1, progress: 0);
    final baseAverage = tabStats.isEmpty
        ? 0.0
        : tabStats.values.fold<double>(0.0, (sum, stat) => sum + stat.progress) / tabStats.length;
    final overallProgress = currentIndex == FormConstants.totalTabs - 1 ? 1.0 : baseAverage;
    final overallPercent = (overallProgress * 100).round().clamp(0, 100);
    final guidanceText = _tabGuidance[currentIndex] ?? 'أكمل الحقول المطلوبة ثم تابع للخطوة التالية.';
    final missingRequired = _calculateMissingRequiredFields();
    final pendingAttachments = widget.controllers.pendingAttachments.length;
    final confidenceScore = _calculateConfidenceScore(
      overallPercent: overallPercent,
      missingRequired: missingRequired,
      pendingAttachments: pendingAttachments,
    );
    final nextAction = _resolveNextAction();
    final compactFocusMode = isCompact && widget.minimizeTopInsights;
    final shouldShowProgressCard = widget.showProgressCard && mediaQuery.size.height >= 700;
    final shouldShowSearchBar = mediaQuery.size.height >= 760 || _searchQuery.isNotEmpty;

    return Column(
      children: [
        if (shouldShowProgressCard)
          Semantics(
            container: true,
            liveRegion: true,
            label:
                'تقدم النموذج $overallPercent بالمئة. الحقول المطلوبة الناقصة $missingRequired. المرفقات المعلقة $pendingAttachments.',
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(_panelHorizontal.w, _panelTop.h, _panelHorizontal.w, _panelBottom.h),
              padding: EdgeInsets.symmetric(horizontal: (isCompact ? 10 : 12).w, vertical: (isCompact ? 8 : 10).h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(_panelRadius.r),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'تقدّم النموذج: $overallPercent%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${currentStats.completedFields}/${currentStats.totalFields}',
                        style: theme.textTheme.bodySmall,
                      ),
                      _buildKpiChip(context,
                          icon: Icons.verified_outlined, label: 'جودة السجل', value: '$confidenceScore/100'),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: LinearProgressIndicator(
                      value: overallProgress,
                      minHeight: 6.h,
                    ),
                  ),
                  if (compactFocusMode) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'وضع تركيز: تم إخفاء التفاصيل أثناء الإدخال',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_rounded, size: 16.sp, color: theme.colorScheme.primary),
                      ],
                    ),
                  ],
                  if (isCompact) ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showCompactInsights = !_showCompactInsights;
                          });
                        },
                        icon: Icon(_showCompactInsights ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        label: Text(_showCompactInsights ? 'إخفاء التفاصيل' : 'إظهار التفاصيل'),
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  if (!compactFocusMode && (!isCompact || _showCompactInsights))
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _buildKpiChip(context,
                            icon: Icons.rule_rounded, label: 'ناقص مطلوب', value: '$missingRequired'),
                        _buildKpiChip(context,
                            icon: Icons.attach_file_rounded, label: 'مرفقات معلّقة', value: '$pendingAttachments'),
                        _buildKpiChip(context,
                            icon: Icons.checklist_rounded, label: 'الإكمال', value: '$overallPercent%'),
                      ],
                    )
                  else if (!compactFocusMode && _showCompactInsights)
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _buildKpiChip(context, icon: Icons.rule_rounded, label: 'ناقص', value: '$missingRequired'),
                        _buildKpiChip(context,
                            icon: Icons.attach_file_rounded, label: 'مرفقات', value: '$pendingAttachments'),
                      ],
                    ),
                  SizedBox(height: 8.h),
                  if (!compactFocusMode)
                    if (!isCompact || _showCompactInsights)
                      Text(
                        guidanceText,
                        style: theme.textTheme.bodySmall,
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _showCompactGuidance ? guidanceText : 'توجيه سريع متاح',
                              style: theme.textTheme.bodySmall,
                              maxLines: _showCompactGuidance ? 3 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showCompactGuidance = !_showCompactGuidance;
                              });
                            },
                            child: Text(_showCompactGuidance ? 'إخفاء' : 'إظهار'),
                          ),
                        ],
                      ),
                  SizedBox(height: 8.h),
                  if (!compactFocusMode && (!isCompact || _showCompactInsights))
                    _buildSmartNextAction(
                      context,
                      nextAction: nextAction,
                      isCompact: isCompact,
                      isTablet: isTablet,
                    ),
                ],
              ),
            ),
          ),

        // 🔍 Quick Search Bar (adaptive to avoid vertical overflow)
        if (shouldShowSearchBar)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: theme.colorScheme.primaryContainer,
            child: QuickSearchInput(
              controller: _searchController,
              hint: 'ابحث في الحقول...',
              onSearch: (query) {
                setState(() => _searchQuery = query);
              },
            ),
          ),

        Semantics(
          container: true,
          label: 'تبويبات إدخال بيانات المستفيد',
          child: BeneficiaryFormTabBar4(
            controller: widget.tabController,
            currentIndex: currentIndex,
            tabStats: tabStats,
          ),
        ),

        // ⚡ TabBarView with proper sizing - NO ScrollView!
        Expanded(
          child: BeneficiaryFormTabs4Merged(
            controller: widget.tabController,
            formControllers: widget.controllers,
            onBirthDateTap: widget.onBirthDateTap,
            firstFieldFocusNode: widget.firstFieldFocusNode,
            beneficiaryId: widget.beneficiaryId,
            onFinalSave: widget.onFinalSave, // 🆕 Pass callback
          ),
        ),
      ],
    );
  }

  Widget _buildKpiChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: theme.colorScheme.primary),
          SizedBox(width: 5.w),
          Text(
            '$label: $value',
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartNextAction(
    BuildContext context, {
    required ({int targetTab, String message, IconData icon}) nextAction,
    required bool isCompact,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(nextAction.icon, size: 16.sp, color: theme.colorScheme.primary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        nextAction.message,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => widget.tabController.animateTo(nextAction.targetTab),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('التالي'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Icon(nextAction.icon, size: isTablet ? 18.sp : 16.sp, color: theme.colorScheme.primary),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    nextAction.message,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(width: 8.w),
                FilledButton.tonalIcon(
                  onPressed: () => widget.tabController.animateTo(nextAction.targetTab),
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('الخطوة التالية'),
                ),
              ],
            ),
    );
  }

  int _calculateConfidenceScore({
    required int overallPercent,
    required int missingRequired,
    required int pendingAttachments,
  }) {
    var score = overallPercent;
    score -= (missingRequired * 8);
    if (pendingAttachments > 0) {
      score -= pendingAttachments.clamp(1, 5) * 2;
    }
    if (widget.controllers.nationalIdController.text.trim().length == FormConstants.nationalIdLength) {
      score += 6;
    }
    if (widget.controllers.phoneController.text.trim().isNotEmpty) {
      score += 4;
    }
    return score.clamp(0, 100);
  }

  ({int targetTab, String message, IconData icon}) _resolveNextAction() {
    if (widget.controllers.firstNameController.text.trim().isEmpty) {
      return (targetTab: 0, message: 'أدخل الاسم الأول لإكمال أساس السجل.', icon: Icons.person_outline_rounded);
    }

    if (widget.controllers.nationalIdController.text.trim().length != FormConstants.nationalIdLength) {
      return (targetTab: 0, message: 'أكمل الرقم الوطني (9 أرقام) لتقليل أخطاء الحفظ.', icon: Icons.badge_outlined);
    }

    if (widget.controllers.phoneController.text.trim().isEmpty) {
      return (targetTab: 2, message: 'أضف رقم الهاتف لتسهيل المتابعة الميدانية.', icon: Icons.phone_outlined);
    }

    if (widget.controllers.pendingAttachments.isEmpty) {
      return (targetTab: 3, message: 'أضف مرفقًا واحدًا على الأقل قبل الحفظ النهائي.', icon: Icons.attach_file_rounded);
    }

    for (final tabIndex in _tabOrderByPriority) {
      if (tabIndex < FormConstants.totalTabs - 1 && widget.tabController.index != tabIndex) {
        return (
          targetTab: tabIndex,
          message: 'تابع التحقق من بيانات التبويب التالي حسب الأولوية.',
          icon: Icons.checklist_rounded
        );
      }
    }

    return (
      targetTab: FormConstants.totalTabs - 1,
      message: 'البيانات شبه مكتملة، انتقل للمراجعة النهائية.',
      icon: Icons.fact_check_outlined
    );
  }

  int _calculateMissingRequiredFields() {
    final validation = PersonalProfileValidator.evaluate(widget.controllers);
    int missing = validation.missingCriticalFields;
    if (widget.controllers.phoneController.text.trim().isEmpty) missing++;
    return missing;
  }
}

/// 🔍 Quick Search Input Widget
class QuickSearchInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSearch;

  const QuickSearchInput({
    required this.controller,
    required this.hint,
    required this.onSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'بحث سريع داخل الحقول',
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onChanged: onSearch,
      ),
    );
  }
}
