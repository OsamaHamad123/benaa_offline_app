import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/welcome_banner.dart';
import '../../../../core/widgets/filter_chip_group.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/charts.dart';
import '../../../../core/widgets/modern_sliver_app_bar.dart';
import '../../../../core/widgets/enhanced_refresh_indicator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/auth/role_provider.dart';
import '../../../../core/providers/providers.dart' as core_providers;
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/analytics/app_analytics.dart';
import '../../../../core/analytics/ux_flow_analytics.dart';
import '../../../../core/analytics/ux_feature_flags.dart';
import '../../../../core/settings/clean_settings_page.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../theme/app_colors.dart';
import '../../../taxonomies/presentation/providers/taxonomy_providers.dart';

// Civil DB Download
import '../../../civil_db_download/presentation/providers/database_download_provider.dart';
import '../../../civil_db_download/domain/entities/download_progress.dart';

// Dashboard
import '../providers.dart';
import '../providers/dashboard_ui_state_provider.dart';
import '../services/dashboard_navigation_service.dart';
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_haptics.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_search_delegate.dart';
import '../widgets/dashboard_export_dialog.dart';
import '../widgets/monitoring_dashboard.dart';
import '../../../sync/mobile_sync_page.dart';

/// Dashboard Page - Clean Architecture Version with Navigation
/// Uses StateNotifier for state management with performance optimizations
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  bool _showWelcomeBanner = false;
  bool _isOnline = true;
  // _dashboardViewMode stays local — it is a view-mode enum not in DashboardUIState.
  // Filter fields (_selectedFilter, _selectedCategory, _selectedGovernorate, _syncedOnly)
  // are stored in dashboardUIStateProvider to survive screen recreation.
  _DashboardViewMode _dashboardViewMode = _DashboardViewMode.operational;
  DateTime? _dashboardOpenedAt;
  bool _dashboardFirstActionTracked = false;

  // Connectivity subscription - لتجنب memory leak
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startDashboardSession();
    _checkWelcomeBanner();
    _checkConnectivity();
    _listenToConnectivity();

    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appMonitoringProvider).logScreenView('Dashboard');
    });
  }

  @override
  void dispose() {
    // Cancel connectivity subscription to prevent memory leak
    _connectivitySubscription?.cancel();

    // Direct static call avoids provider access while route is popping.
    AppAnalytics.logScreenExit('Dashboard');
    super.dispose();
  }

  void _startDashboardSession() {
    _dashboardOpenedAt = DateTime.now();
    _dashboardFirstActionTracked = false;
    UxFlowAnalytics.trackDashboardOpened(viewMode: _dashboardViewMode.name);
  }

  void _trackDashboardAction(
    String action, {
    Map<String, dynamic>? extra,
  }) {
    final now = DateTime.now();

    if (!_dashboardFirstActionTracked && _dashboardOpenedAt != null) {
      _dashboardFirstActionTracked = true;
      UxFlowAnalytics.trackDashboardFirstAction(
        action: action,
        elapsedMs: now.difference(_dashboardOpenedAt!).inMilliseconds,
        viewMode: _dashboardViewMode.name,
      );
    }

    UxFlowAnalytics.trackDashboardAction(
      action,
      parameters: {
        'view_mode': _dashboardViewMode.name,
        ...?extra,
      },
    );
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = !connectivityResult.contains(ConnectivityResult.none);
      });
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        final wasOffline = !_isOnline;
        final isNowOnline = !result.contains(ConnectivityResult.none);

        setState(() {
          _isOnline = isNowOnline;
        });

        if (wasOffline && isNowOnline) {
          _showOnlineSnackbar();
          // ✅ أعد تحميل البيانات عند عودة الاتصال — guard with mounted check
          if (mounted) {
            ref.read(dashboardProvider.notifier).refresh();
          }
        }
      }
    });
  }

  void _showOnlineSnackbar() {
    EnhancedSnackbar.showSuccess(
      context,
      message: 'تم الاتصال بالإنترنت - جاري المزامنة التلقائية',
    );
  }

  Future<void> _checkWelcomeBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('welcome_banner_shown') ?? false;
    if (mounted) {
      setState(() {
        _showWelcomeBanner = !shown;
      });
    }
  }

  void _showAdvancedFilters() {
    final uiState = ref.read(dashboardUIStateProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersWidget(
        selectedCategory: uiState.selectedCategory,
        selectedGovernorate: uiState.selectedGovernorate,
        syncedOnly: uiState.syncedOnly,
        onApply: (category, governorate, synced) {
          ref.read(dashboardUIStateProvider.notifier).applyAdvancedFilters(
                category: category,
                governorate: governorate,
                syncedOnly: synced,
              );

          // Note: Filter implementation depends on provider architecture
          // Currently filters are applied when beneficiaries list is loaded
          // Dashboard statistics are recalculated based on filtered data

          EnhancedSnackbar.showSuccess(context, message: 'تم تطبيق الفلاتر');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uxFlags = ref.watch(core_providers.uxFeatureFlagsProvider).valueOrNull ?? const UxFeatureFlags();
    // Read UI filter state from provider — survives screen recreation.
    final uiState = ref.watch(dashboardUIStateProvider);
    final Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: uiState.selectedFilter,
          isOnline: _isOnline,
          dashboardViewMode: _dashboardViewMode,
          selectedCategory: uiState.selectedCategory,
          selectedGovernorate: uiState.selectedGovernorate,
          syncedOnly: uiState.syncedOnly,
          onWelcomeDismiss: () {
            setState(() {
              _showWelcomeBanner = false;
            });
          },
          onFilterChanged: (filter) {
            ref.read(dashboardUIStateProvider.notifier).setSelectedFilter(filter);
          },
          onViewModeChanged: (mode) {
            setState(() {
              _dashboardViewMode = mode;
            });
            UxFlowAnalytics.trackDashboardModeChanged(mode: mode.name);
            _trackDashboardAction('view_mode_changed', extra: {'mode': mode.name});
          },
          onShowFilters: _showAdvancedFilters,
          onDashboardAction: _trackDashboardAction,
          enableAnalyticalMode: uxFlags.enableDashboardAnalyticalMode,
        );
        break;
      case 1:
        currentPage = const MobileSyncPage();
        break;
      case 2:
        currentPage = const CleanSettingsPage();
        break;
      default:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: uiState.selectedFilter,
          isOnline: _isOnline,
          dashboardViewMode: _dashboardViewMode,
          selectedCategory: uiState.selectedCategory,
          selectedGovernorate: uiState.selectedGovernorate,
          syncedOnly: uiState.syncedOnly,
          onWelcomeDismiss: () {
            setState(() {
              _showWelcomeBanner = false;
            });
          },
          onFilterChanged: (filter) {
            ref.read(dashboardUIStateProvider.notifier).setSelectedFilter(filter);
          },
          onViewModeChanged: (mode) {
            setState(() {
              _dashboardViewMode = mode;
            });
            UxFlowAnalytics.trackDashboardModeChanged(mode: mode.name);
            _trackDashboardAction('view_mode_changed', extra: {'mode': mode.name});
          },
          onShowFilters: _showAdvancedFilters,
          onDashboardAction: _trackDashboardAction,
          enableAnalyticalMode: uxFlags.enableDashboardAnalyticalMode,
        );
    }

    return Scaffold(
      body: currentPage,
      floatingActionButton: _selectedIndex == 0
          ? MicroInteractions.bounceButton(
              onTap: () {
                DashboardNavigationService.navigateToAddBeneficiary(context);
              },
              child: FloatingActionButton.extended(
                onPressed: () {
                  DashboardNavigationService.navigateToAddBeneficiary(context);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة مستفيد'),
                backgroundColor: DashboardColors.totalBeneficiaries,
                elevation: 4,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          DashboardHaptics.onNavigation();
          if (index == 0 && _selectedIndex != 0) {
            _startDashboardSession();
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 22),
            selectedIcon: Icon(Icons.dashboard, size: 22),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_outlined, size: 22),
            selectedIcon: Icon(Icons.sync, size: 22),
            label: 'المزامنة',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 22),
            selectedIcon: Icon(Icons.settings, size: 22),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends ConsumerWidget {
  final bool showWelcomeBanner;
  final String selectedFilter;
  final VoidCallback onWelcomeDismiss;
  final Function(String) onFilterChanged;
  final ValueChanged<_DashboardViewMode> onViewModeChanged;
  final bool isOnline;
  final _DashboardViewMode dashboardViewMode;
  final String? selectedCategory;
  final String? selectedGovernorate;
  final bool? syncedOnly;
  final VoidCallback onShowFilters;
  final void Function(String action, {Map<String, dynamic>? extra}) onDashboardAction;
  final bool enableAnalyticalMode;

  const _DashboardHome({
    required this.showWelcomeBanner,
    required this.selectedFilter,
    required this.onWelcomeDismiss,
    required this.onFilterChanged,
    required this.onViewModeChanged,
    required this.isOnline,
    required this.dashboardViewMode,
    required this.selectedCategory,
    required this.selectedGovernorate,
    required this.syncedOnly,
    required this.onShowFilters,
    required this.onDashboardAction,
    required this.enableAnalyticalMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for SharedPreferences to load first
    final prefsAsync = ref.watch(core_providers.sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) => _buildDashboard(context, ref),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'خطأ في تحميل الإعدادات',
              style: DashboardTextStyles.emptyStateTitle.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    // Selective watching: يعيد build فقط عند تغيير pendingTasks
    final pendingTasksCount = ref.watch(
      dashboardProvider.select((state) => state.todayStats?.pendingTasks),
    );

    // Admin role — used for gating admin-only AppBar tools
    final isAdmin = ref.watch(isAdminProvider);

    return CustomScrollView(
      slivers: [
        // Modern App Bar — أدوات المستخدم الأساسية فقط
        // الأدوات التقنية/الإدارية مخفية في قائمة الـ popup للمدير فقط
        ModernSliverAppBar(
          title: !isOnline ? 'منظومة بناء (غير متصل)' : 'منظومة بناء',
          icon: Icons.dashboard_rounded,
          actions: [
            // Phase 5: explicit spacing between AppBar icons for visual breathing room
            // بحث — متاح لجميع المستخدمين
            ModernActionButton(
              icon: Icons.search_rounded,
              tooltip: 'البحث',
              onPressed: () {
                onDashboardAction('search_opened');
                showSearch(
                  context: context,
                  delegate: DashboardSearchDelegate(ref),
                );
              },
            ),
            SizedBox(width: 6.w),
            // إشعارات — متاحة لجميع المستخدمين
            ModernActionButton(
              icon: Icons.notifications_outlined,
              tooltip: 'الإشعارات',
              badge: pendingTasksCount,
              onPressed: () {
                onDashboardAction('notifications_opened');
                final count = pendingTasksCount ?? 0;
                EnhancedSnackbar.showInfo(
                  context,
                  message: count > 0 ? '$count سجل بانتظار الرفع' : 'لا توجد سجلات معلقة',
                );
              },
            ),
            SizedBox(width: 4.w),
            // قائمة إضافية: التصدير/المراقبة/التصنيفات — للمدير أو debug فقط
            _DashboardAdminPopupMenu(
              isAdmin: isAdmin,
              onDashboardAction: onDashboardAction,
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: EnhancedRefreshIndicator(
            onRefresh: () async {
              DashboardHaptics.onRefresh();
              onDashboardAction('pull_to_refresh');
              await notifier.refresh();
            },
            color: DashboardColors.totalBeneficiaries,
            child: state.isLoadingStats && state.statistics == null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: SkeletonCard(
                            width: double.infinity,
                            height: 80.h,
                          ),
                        ),
                      ),
                    ),
                  )
                : state.hasError
                    ? _buildErrorView(context, state.errorMessage!, notifier)
                    : _buildContent(
                        context,
                        ref,
                        state,
                        notifier,
                        padding,
                        isOnline,
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String error, dynamic notifier) {
    return RetryWidget(message: error, onRetry: () => notifier.refresh());
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    dynamic notifier,
    EdgeInsets padding,
    bool isOnline,
  ) {
    final stats = state.statistics;
    if (stats == null) return const SizedBox();

    // ✅ Conditional watch: trendChartData يُحمل فقط في وضع التحليل لتجنب البناء غير الضروري
    final effectiveViewMode = enableAnalyticalMode ? dashboardViewMode : _DashboardViewMode.operational;
    final trendChartData =
        effectiveViewMode == _DashboardViewMode.analytical ? ref.watch(trendChartDataProvider) : const <double>[];

    // Admin role — needed for taxonomy banner gate
    final isAdmin = ref.watch(isAdminProvider);

    // Compute operational status from cheap available data
    final operationalStatus = DashboardOperationalStatus.resolve(
      isOnline: isOnline,
      pendingSync: stats.pendingSync,
      lastSyncTime: stats.lastSyncTime,
    );

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Operational Status Strip - يوحد حالة التشغيل (يستبدل OfflineBanner)
          DashboardOperationalStatusStrip(
            status: operationalStatus,
            onTap: operationalStatus.level != DashboardStatusLevel.normal
                ? () => DashboardNavigationService.navigateToSync(context)
                : null,
          ),

          // Civil Registry Banner — يظهر فقط أثناء التحميل (مخفي عند الجهوزية — Phase 1)
          _CivilRegistryBanner(ref: ref),

          // Taxonomy Sync Health Banner — للمدير أو وضع debug فقط (ليس حقل العمل)
          if (isAdmin || kDebugMode) const _TaxonomySyncHealthBanner(),

          // Welcome Banner — يظهر فقط عند الحالة الطبيعية (لا أعباء معلقة، لا أخطاء)
          if (showWelcomeBanner && operationalStatus.level == DashboardStatusLevel.normal)
            WelcomeBanner(
              userName: 'المستخدم',
              message: 'مرحباً بك في منظومة بناء',
              onGetStarted: () {
                onDashboardAction('welcome_get_started');
                DashboardNavigationService.navigateToAddBeneficiary(context);
              },
              onDismiss: onWelcomeDismiss,
            ),

          if (enableAnalyticalMode) ...[
            SizedBox(height: 8.h),
            _buildHomeModeSwitcher(),
            SizedBox(height: 8.h),
          ],

          // Dashboard Summary Widget - لوحة المعلومات المصغرة
          const RepaintBoundary(
            child: FadeSlideTransition(
              duration: AppDurations.fast,
              delay: Duration(), // ✅ Stagger: أول widget
              child: DashboardSummaryWidget(contextLabel: 'اليوم'),
            ),
          ),

          SizedBox(height: 24.h),

          // Section: Quick Actions (الأكثر استخداماً - في الأعلى)
          const SectionTitle(title: 'إجراءات سريعة', icon: Icons.flash_on),
          SizedBox(height: 12.h),
          FadeSlideTransition(
            duration: AppDurations.fast,
            delay: const Duration(milliseconds: 50), // ✅ Stagger: ثاني widget
            child: QuickActionsGrid(
              onAddBeneficiaryTap: () {
                onDashboardAction('quick_add_beneficiary');
                DashboardNavigationService.navigateToAddBeneficiary(context);
              },
              onKafalatTap: () {
                onDashboardAction('quick_kafalat');
                DashboardNavigationService.navigateToKafalat(context);
              },
              onSearchTap: () {
                onDashboardAction('quick_search_beneficiaries');
                DashboardNavigationService.navigateToBeneficiariesList(context);
              },
              onSyncTap: () {
                onDashboardAction('quick_sync_hub');
                DashboardNavigationService.navigateToSync(context);
              },
              onReportsTap: () {
                onDashboardAction('quick_reports');
                DashboardNavigationService.navigateToReports(context);
              },
              onCivilRegistryTap: () {
                onDashboardAction('quick_civil_registry');
                DashboardNavigationService.navigateToCivilRegistry(context);
              },
              onVisitsTap: () {
                onDashboardAction('quick_visits');
                DashboardNavigationService.navigateToVisits(context);
              },
              onAssociationsTap: () {
                onDashboardAction('quick_associations');
                DashboardNavigationService.navigateToAssociations(context);
              },
              syncBadge: stats.pendingSync,
            ),
          ),

          SizedBox(height: 24.h),

          // Today's Work Card — ملخص عمل اليوم للعمال الميدانيين
          if (effectiveViewMode == _DashboardViewMode.operational)
            DashboardTodaysWorkCard(
              todayStats: stats.todayStats,
              onViewVisits: () {
                onDashboardAction('todays_work_view_visits');
                DashboardNavigationService.navigateToVisits(context);
              },
              onAddVisit: () {
                onDashboardAction('todays_work_add_visit');
                DashboardNavigationService.navigateToAddVisit(context);
              },
            ),

          if (effectiveViewMode == _DashboardViewMode.operational) SizedBox(height: 16.h),

          // Compact Sync Health Card — حالة المزامنة المختصرة
          if (effectiveViewMode == _DashboardViewMode.operational)
            DashboardSyncHealthCard(
              pendingSync: stats.pendingSync,
              isOnline: isOnline,
              lastSyncTime: stats.lastSyncTime,
              onOpenSync: () {
                onDashboardAction('sync_health_open_sync');
                DashboardNavigationService.navigateToSync(context);
              },
            ),

          SizedBox(height: 24.h),

          // Phase 5: Filter section — replaced heavy SectionTitle with a compact
          // secondary row. Filters are a secondary control, not a primary section.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Text(
                  'عرض البيانات',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                        letterSpacing: 0.3,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      onDashboardAction('filters_refresh');
                      HapticFeedback.mediumImpact();
                      notifier.refresh();
                      EnhancedSnackbar.showSuccess(
                        context,
                        message: 'تم تحديث البيانات',
                      );
                    },
                    tooltip: 'تحديث البيانات',
                  ),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: selectedCategory != null || selectedGovernorate != null || syncedOnly != null,
                      label: Text(
                        '${(selectedCategory != null ? 1 : 0) + (selectedGovernorate != null ? 1 : 0) + (syncedOnly != null ? 1 : 0)}',
                      ),
                      child: const Icon(Icons.tune),
                    ),
                    onPressed: onShowFilters,
                    tooltip: 'فلاتر متقدمة',
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),

          FilterChipGroup(
            filters: const [
              FilterChipData(
                label: 'الكل',
                value: 'all',
                icon: Icons.grid_view,
              ),
              FilterChipData(
                label: 'اليوم',
                value: 'today',
                icon: Icons.today,
                color: DashboardColors.success,
              ),
              FilterChipData(
                label: 'هذا الأسبوع',
                value: 'week',
                icon: Icons.date_range,
                color: DashboardColors.totalBeneficiaries,
              ),
              FilterChipData(
                label: 'تحتاج متابعة',
                value: 'urgent',
                icon: Icons.warning_amber,
                color: DashboardColors.urgent,
              ),
            ],
            selectedFilter: selectedFilter,
            onSelectionChanged: (selected) {
              if (selected.isNotEmpty) {
                onDashboardAction('filter_changed', extra: {'filter': selected.first});
                onFilterChanged(selected.first);
              }
            },
          ),

          if (effectiveViewMode == _DashboardViewMode.operational) ...[
            SizedBox(height: 24.h),
            const SectionTitle(title: 'تفاصيل المتابعة', icon: Icons.warning_amber),
            SizedBox(height: 12.h),
            const ScaleTransitionWidget(
              duration: AppDurations.fast,
              delay: Duration(milliseconds: 120),
              child: UrgentCasesSection(),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionTitle(title: 'الأنشطة الحديثة', icon: Icons.history),
                TextButton.icon(
                  onPressed: () {
                    DashboardNavigationService.navigateToAllActivities(context);
                  },
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
                    size: 16,
                  ),
                  label: const Text('عرض الكل'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            RecentActivitiesList(
              activities: state.activities.take(5).toList(),
              isLoading: state.isLoadingActivities,
              hasMore: state.hasMoreActivities,
              onLoadMore: () => notifier.loadMoreActivities(),
            ),
            SizedBox(height: 32.h),
          ] else ...[
            // 📊 Interactive Charts Section - NEW!
            const SectionTitle(title: 'الإحصائيات التفاعلية', icon: Icons.bar_chart),
            SizedBox(height: 12.h),

            // Trend Line Chart
            RepaintBoundary(
              child: FadeSlideTransition(
                delay: const Duration(milliseconds: 100), // ✅ Stagger: ثالث widget
                slideOffset: const Offset(0, 0.2),
                child: TrendLineChart(
                  title: 'نمو المستفيدين (آخر 6 أشهر)',
                  data: trendChartData, // ✅ Memoized data
                  labels: const ['ين', 'فب', 'مار', 'أبر', 'ماي', 'يون'],
                  lineColor: DashboardColors.totalBeneficiaries,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Section: Urgent Cases - الحالات الطارئة (أولوية عالية)
            const SectionTitle(title: 'تفاصيل المتابعة', icon: Icons.warning_amber),
            SizedBox(height: 12.h),
            const ScaleTransitionWidget(
              duration: AppDurations.fast,
              delay: Duration(milliseconds: 150), // ✅ Stagger
              child: UrgentCasesSection(),
            ),

            SizedBox(height: 24.h),

            // Section: Daily Performance - مؤشر الأداء اليومي
            const SectionTitle(title: 'الأداء اليومي', icon: Icons.trending_up),
            SizedBox(height: 12.h),
            const ScaleTransitionWidget(
              duration: AppDurations.fast,
              delay: Duration(milliseconds: 200), // ✅ Stagger
              child: DailyPerformanceSection(),
            ),

            SizedBox(height: 24.h),

            // Section: Recent Activities (آخر 5 فقط)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionTitle(title: 'الأنشطة الحديثة', icon: Icons.history),
                TextButton.icon(
                  onPressed: () {
                    DashboardNavigationService.navigateToAllActivities(context);
                  },
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
                    size: 16,
                  ),
                  label: const Text('عرض الكل'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            RecentActivitiesList(
              activities: state.activities.take(5).toList(),
              isLoading: state.isLoadingActivities,
              hasMore: state.hasMoreActivities,
              onLoadMore: () => notifier.loadMoreActivities(),
            ),

            SizedBox(height: 24.h),

            // Section: Charts (قابلة للطي)
            CollapsibleSection(
              title: 'إحصائيات النمو',
              icon: Icons.trending_up,
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  GrowthChart(growthData: stats.growthData),
                  SizedBox(height: 16.h),
                  CategoryDistributionChart(categoryCounts: stats.categoryCounts),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Section: Geographic Distribution (قابلة للطي)
            CollapsibleSection(
              title: 'التوزيع الجغرافي',
              icon: Icons.map,
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  const GeographicDistributionSection(),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeModeSwitcher() {
    return Row(
      children: [
        Semantics(
          label: 'وضع الداشبورد المبسط',
          button: true,
          child: ChoiceChip(
            label: const Text('عرض مبسط'),
            selected: dashboardViewMode == _DashboardViewMode.operational,
            onSelected: (_) {
              onDashboardAction('mode_chip_tapped', extra: {'mode': _DashboardViewMode.operational.name});
              onViewModeChanged(_DashboardViewMode.operational);
            },
          ),
        ),
        SizedBox(width: 8.w),
        Semantics(
          label: 'وضع الداشبورد التفصيلي',
          button: true,
          child: ChoiceChip(
            label: const Text('عرض تفصيلي'),
            selected: dashboardViewMode == _DashboardViewMode.analytical,
            onSelected: (_) {
              onDashboardAction('mode_chip_tapped', extra: {'mode': _DashboardViewMode.analytical.name});
              onViewModeChanged(_DashboardViewMode.analytical);
            },
          ),
        ),
      ],
    );
  }
}

enum _DashboardViewMode { operational, analytical }

// ============================================================
// Admin / Secondary actions popup menu — مخفي لغير المدير
// ============================================================

/// قائمة الإجراءات الإدارية والثانوية في AppBar — للمدير أو debug فقط.
///
/// يُظهر:
/// - تصدير التقرير
/// - إدارة التصنيفات (Taxonomies)
/// - لوحة المراقبة (Monitoring Dashboard)
///
/// [Dashboard] admin tools visible: `true|false`
class _DashboardAdminPopupMenu extends ConsumerWidget {
  final bool isAdmin;
  final void Function(String action, {Map<String, dynamic>? extra}) onDashboardAction;

  const _DashboardAdminPopupMenu({
    required this.isAdmin,
    required this.onDashboardAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAdmin = isAdmin || kDebugMode;
    debugPrint('[Dashboard] admin tools visible: $showAdmin');
    if (!showAdmin) return const SizedBox.shrink();

    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Tooltip(
      message: 'أدوات إدارية',
      child: PopupMenuButton<_AdminAction>(
        icon: Icon(Icons.more_vert_rounded, color: onPrimary, size: 20),
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _AdminAction.export,
            child: ListTile(
              leading: Icon(Icons.file_download_outlined),
              title: Text('تصدير التقرير'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: _AdminAction.taxonomies,
            child: ListTile(
              leading: Icon(Icons.category_rounded),
              title: Text('إدارة التصنيفات'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          if (kDebugMode)
            const PopupMenuItem(
              value: _AdminAction.monitoring,
              child: ListTile(
                leading: Icon(Icons.monitor_heart_outlined),
                title: Text('لوحة المراقبة'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, _AdminAction action) {
    switch (action) {
      case _AdminAction.export:
        onDashboardAction('export_report_tapped');
        // Use ref.read — this is an imperative action, not a watch.
        final dashboard = ref.read(dashboardProvider).statistics;
        if (dashboard != null) {
          showDialog(
            context: context,
            builder: (_) => DashboardExportDialog(dashboard: dashboard),
          );
        } else {
          EnhancedSnackbar.showWarning(context, message: 'الرجاء الانتظار حتى يتم تحميل البيانات');
        }
      case _AdminAction.taxonomies:
        onDashboardAction('admin_taxonomies_tapped');
        context.push('/taxonomies');
      case _AdminAction.monitoring:
        onDashboardAction('admin_monitoring_tapped');
        debugPrint('[Dashboard] MonitoringDashboard access: ${isAdmin ? 'allowed' : 'debug_only'}');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MonitoringDashboard()),
        );
    }
  }
}

enum _AdminAction { export, taxonomies, monitoring }

class _TaxonomySyncHealthBanner extends ConsumerWidget {
  const _TaxonomySyncHealthBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoState = ref.watch(taxonomyAutoSyncStateProvider);
    final lastSyncAsync = ref.watch(lastSyncTimeProvider);

    final lastSync = lastSyncAsync.asData?.value;
    final now = DateTime.now();
    final isStale = lastSync == null || now.difference(lastSync) > const Duration(hours: 24);
    final hasFailures = autoState.consecutiveFailures >= 3;

    if (!isStale && !hasFailures) {
      return const SizedBox.shrink();
    }

    final color = hasFailures ? Colors.red.shade700 : Colors.orange.shade700;
    final bg = hasFailures ? Colors.red.shade50 : Colors.orange.shade50;
    final border = hasFailures ? Colors.red.shade200 : Colors.orange.shade200;

    final subtitle = hasFailures
        ? 'فشل متكرر في مزامنة التصنيفات. راجع الاتصال أو نفّذ مزامنة يدوية.'
        : 'التصنيفات تحتاج تحديث (${lastSync == null ? 'لم تتم مزامنة بعد' : 'آخر مزامنة قديمة'}).';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: color, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasFailures ? 'تنبيه مزامنة التصنيفات' : 'التصنيفات قد تكون قديمة',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp, color: color),
                ),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/taxonomies'),
            child: const Text('فتح'),
          ),
        ],
      ),
    );
  }
}

/// Civil Registry Download Banner - بانر تذكير بتحميل السجل المدني
class _CivilRegistryBanner extends ConsumerWidget {
  final WidgetRef ref;

  const _CivilRegistryBanner({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(databaseDownloadProvider);
    final status = dbState.progress.status;
    final isProcessing = status == DownloadStatus.downloading ||
        status == DownloadStatus.extracting ||
        status == DownloadStatus.verifying ||
        status == DownloadStatus.checking;
    final downloadedAt = dbState.downloadDate;
    final dateText = downloadedAt == null
        ? 'غير متوفر'
        : '${downloadedAt.year}/${downloadedAt.month.toString().padLeft(2, '0')}/${downloadedAt.day.toString().padLeft(2, '0')} '
            '${downloadedAt.hour.toString().padLeft(2, '0')}:${downloadedAt.minute.toString().padLeft(2, '0')}';

    final isReady = dbState.isAvailable;

    // بانر "السجل المدني جاهز" غير ضروري — يُختفى لتقليل التراكم البصري
    if (isReady) return const SizedBox.shrink();

    final accentColor = isReady
        ? Colors.green
        : isProcessing
            ? Colors.blue
            : Colors.orange;
    final title = isReady
        ? 'السجل المدني جاهز'
        : isProcessing
            ? 'تحميل السجل المدني قيد التنفيذ'
            : 'السجل المدني غير محمّل';
    final subtitle = isReady
        ? 'آخر تحديث: $dateText • ${dbState.fileSizeFormatted}'
        : isProcessing
            ? 'التقدم الحالي: ${dbState.progress.displayPercentage}'
            : 'بعض الميزات لن تعمل بدون تحميل السجل المدني';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: accentColor.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accentColor.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: accentColor.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isReady
                  ? Icons.verified_rounded
                  : isProcessing
                      ? Icons.downloading_rounded
                      : Icons.info_outline_rounded,
              color: accentColor.shade700,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: accentColor.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: accentColor.shade700,
                  ),
                ),
                if (isProcessing) ...[
                  SizedBox(height: 6.h),
                  LinearProgressIndicator(
                    value: dbState.progress.percentage / 100,
                    minHeight: 5.h,
                    borderRadius: BorderRadius.circular(8.r),
                    backgroundColor: accentColor.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor.shade700),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          FilledButton.tonal(
            onPressed: () {
              context.push('/database-download');
            },
            style: FilledButton.styleFrom(
              backgroundColor: accentColor.shade100,
              foregroundColor: accentColor.shade800,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            child: Text(isReady
                ? 'إدارة'
                : isProcessing
                    ? 'متابعة'
                    : 'تحميل'),
          ),
        ],
      ),
    );
  }
}
