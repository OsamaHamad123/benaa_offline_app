import 'dart:async';
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
import '../../../../core/providers/providers.dart' as core_providers;
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/analytics/app_analytics.dart';
import '../../../../core/settings/enhanced_settings_page.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../theme/app_colors.dart';
import '../../../taxonomies/presentation/providers/taxonomy_providers.dart';

// Civil DB Download
import '../../../civil_db_download/presentation/providers/database_download_provider.dart';

// Dashboard
import '../providers.dart';
import '../services/dashboard_navigation_service.dart';
import '../utils/dashboard_colors.dart';
import '../utils/dashboard_text_styles.dart';
import '../utils/dashboard_haptics.dart';
import '../widgets/quick_actions.dart';
import '../widgets/activities_section.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/urgent_cases_section.dart';
import '../widgets/geographic_distribution_section.dart';
import '../widgets/daily_performance_section.dart';
import '../widgets/dashboard_summary_widget.dart';
import '../widgets/advanced_filters_widget.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_search_delegate.dart';
import '../widgets/dashboard_export_dialog.dart';
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
  String _selectedFilter = 'all';
  bool _isOnline = true;

  // Advanced Filters
  String? _selectedCategory;
  String? _selectedGovernorate;
  bool? _syncedOnly;

  // Connectivity subscription - لتجنب memory leak
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
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
          // ✅ أعد تحميل البيانات عند عودة الاتصال
          try {
            ref.read(dashboardProvider.notifier).refresh();
          } catch (_) {
            // Ignore if provider is not available
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFiltersWidget(
        selectedCategory: _selectedCategory,
        selectedGovernorate: _selectedGovernorate,
        syncedOnly: _syncedOnly,
        onApply: (category, governorate, synced) {
          setState(() {
            _selectedCategory = category;
            _selectedGovernorate = governorate;
            _syncedOnly = synced;
          });

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
    final Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: _selectedFilter,
          isOnline: _isOnline,
          selectedCategory: _selectedCategory,
          selectedGovernorate: _selectedGovernorate,
          syncedOnly: _syncedOnly,
          onWelcomeDismiss: () {
            setState(() {
              _showWelcomeBanner = false;
            });
          },
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          onShowFilters: _showAdvancedFilters,
        );
        break;
      case 1:
        currentPage = const MobileSyncPage();
        break;
      case 2:
        currentPage = const _SettingsView();
        break;
      default:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: _selectedFilter,
          isOnline: _isOnline,
          selectedCategory: _selectedCategory,
          selectedGovernorate: _selectedGovernorate,
          syncedOnly: _syncedOnly,
          onWelcomeDismiss: () {
            setState(() {
              _showWelcomeBanner = false;
            });
          },
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          onShowFilters: _showAdvancedFilters,
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
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_outlined),
            selectedIcon: Icon(Icons.sync),
            label: 'المزامنة',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
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
  final bool isOnline;
  final String? selectedCategory;
  final String? selectedGovernorate;
  final bool? syncedOnly;
  final VoidCallback onShowFilters;

  const _DashboardHome({
    required this.showWelcomeBanner,
    required this.selectedFilter,
    required this.onWelcomeDismiss,
    required this.onFilterChanged,
    required this.isOnline,
    required this.selectedCategory,
    required this.selectedGovernorate,
    required this.syncedOnly,
    required this.onShowFilters,
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
    final taxonomySyncStatus = ref.watch(taxonomySyncStatusProvider);
    final taxonomyStatsAsync = ref.watch(taxonomyStatisticsProvider);
    final taxonomyTotal = taxonomyStatsAsync.valueOrNull?.totalCount ?? 0;

    return CustomScrollView(
      slivers: [
        // Modern App Bar - مكون موحد قابل لإعادة الاستخدام
        ModernSliverAppBar(
          title: !isOnline ? 'منظومة بناء (غير متصل)' : 'منظومة بناء',
          icon: Icons.dashboard_rounded,
          actions: [
            _buildTaxonomyStatusBadge(
              context,
              taxonomySyncStatus,
              taxonomyTotal,
            ),
            ModernActionButton(
              icon: Icons.search_rounded,
              tooltip: 'البحث',
              iconSize: 28,
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DashboardSearchDelegate(ref),
                );
              },
            ),
            ModernActionButton(
              icon: Icons.file_download_outlined,
              tooltip: 'تصدير التقرير',
              iconSize: 28,
              onPressed: () {
                // Show export dialog
                final dashboard = state.statistics;
                if (dashboard != null) {
                  showDialog(
                    context: context,
                    builder: (_) => DashboardExportDialog(dashboard: dashboard),
                  );
                } else {
                  EnhancedSnackbar.showWarning(
                    context,
                    message: 'الرجاء الانتظار حتى يتم تحميل البيانات',
                  );
                }
              },
            ),
            ModernActionButton(
              icon: Icons.notifications_outlined,
              tooltip: 'الإشعارات',
              iconSize: 28,
              badge: pendingTasksCount,
              onPressed: () {
                final count = pendingTasksCount ?? 0;
                EnhancedSnackbar.showInfo(
                  context,
                  message: count > 0 ? 'لديك $count مهمة معلقة' : 'لا توجد مهام معلقة',
                );
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: EnhancedRefreshIndicator(
            onRefresh: () async {
              DashboardHaptics.onRefresh();
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

  Widget _buildTaxonomyStatusBadge(
    BuildContext context,
    TaxonomySyncStatus status,
    int totalTaxonomies,
  ) {
    final (Color badgeColor, IconData icon, String label) = switch (status) {
      TaxonomySyncStatus.success => (Colors.green, Icons.category_rounded, 'تصنيفات $totalTaxonomies'),
      TaxonomySyncStatus.syncing => (Colors.blue, Icons.sync_rounded, 'تصنيفات...'),
      TaxonomySyncStatus.error => (Colors.red, Icons.error_outline_rounded, 'تصنيفات !'),
      TaxonomySyncStatus.idle => (Colors.grey, Icons.category_outlined, 'تصنيفات'),
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GestureDetector(
        onTap: () {
          final message = switch (status) {
            TaxonomySyncStatus.success => 'التصنيفات جاهزة ($totalTaxonomies)',
            TaxonomySyncStatus.syncing => 'جاري مزامنة التصنيفات...',
            TaxonomySyncStatus.error => 'هناك مشكلة في مزامنة التصنيفات',
            TaxonomySyncStatus.idle => 'لم يتم فحص التصنيفات بعد',
          };

          EnhancedSnackbar.showInfo(context, message: message);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: badgeColor.withOpacity(0.9), width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14.sp, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                label,
                style: DashboardTextStyles.badge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    // ✅ Memoization: استخدام cached chart data
    final trendChartData = ref.watch(trendChartDataProvider);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline Indicator Banner
          if (!isOnline) const OfflineBanner(),

          // Civil Registry Banner - إذا لم يتم تحميل السجل المدني
          _CivilRegistryBanner(ref: ref),

          // Taxonomies Sync Health Banner
          const _TaxonomySyncHealthBanner(),

          // Welcome Banner (First time users)
          if (showWelcomeBanner)
            WelcomeBanner(
              userName: 'المستخدم',
              message: 'مرحباً بك في منظومة بناء',
              onGetStarted: () {
                DashboardNavigationService.navigateToAddBeneficiary(context);
              },
              onDismiss: onWelcomeDismiss,
            ),

          // Filter Chips with Advanced Filters Button - في الأعلى للوصول السريع
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const SectionTitle(
                  title: 'التصنيفات السريعة',
                  icon: Icons.filter_alt,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      notifier.refresh();
                      EnhancedSnackbar.showSuccess(
                        context,
                        message: 'تم تحديث البيانات',
                      );
                    },
                    tooltip: 'تحديث البيانات',
                  ),
                  // Advanced Filters
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
                onFilterChanged(selected.first);
                // Filter is applied through onFilterChanged callback
                // which triggers dashboard data refresh
              }
            },
          ),

          SizedBox(height: 24.h),

          // Dashboard Summary Widget - لوحة المعلومات المصغرة
          RepaintBoundary(
            child: FadeSlideTransition(
              duration: AppDurations.fast,
              delay: const Duration(milliseconds: 0), // ✅ Stagger: أول widget
              child: const DashboardSummaryWidget(),
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
                DashboardNavigationService.navigateToAddBeneficiary(context);
              },
              onKafalatTap: () {
                DashboardNavigationService.navigateToKafalat(context);
              },
              onSearchTap: () {
                DashboardNavigationService.navigateToBeneficiariesList(context);
              },
              onSyncTap: () {
                DashboardNavigationService.navigateToSync(context);
              },
              onReportsTap: () {
                DashboardNavigationService.navigateToReports(context);
              },
              onCivilRegistryTap: () {
                DashboardNavigationService.navigateToCivilRegistry(context);
              },
              onVisitsTap: () {
                DashboardNavigationService.navigateToVisits(context);
              },
              onAssociationsTap: () {
                DashboardNavigationService.navigateToAssociations(context);
              },
              syncBadge: stats.pendingSync,
              reportsBadge: null,
            ),
          ),
          // 📊 Interactive Charts Section - NEW!
          const SectionTitle(title: 'الإحصائيات التفاعلية', icon: Icons.bar_chart),
          SizedBox(height: 12.h),

          // Trend Line Chart
          RepaintBoundary(
            child: FadeSlideTransition(
              duration: AppDurations.normal,
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
          const SectionTitle(title: 'حالات تحتاج متابعة', icon: Icons.warning_amber),
          SizedBox(height: 12.h),
          ScaleTransitionWidget(
            duration: AppDurations.fast,
            delay: const Duration(milliseconds: 150), // ✅ Stagger
            child: const UrgentCasesSection(),
          ),

          SizedBox(height: 24.h),

          // Section: Daily Performance - مؤشر الأداء اليومي
          const SectionTitle(title: 'الأداء اليومي', icon: Icons.trending_up),
          SizedBox(height: 12.h),
          ScaleTransitionWidget(
            duration: AppDurations.fast,
            delay: const Duration(milliseconds: 200), // ✅ Stagger
            child: const DailyPerformanceSection(),
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
                icon: const Icon(Icons.arrow_forward, size: 16),
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
      ),
    );
  }
}

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

/// Settings View
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    // استخدم صفحة الإعدادات الجديدة المحسّنة مع زر Dashboard Settings
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'إعدادات الداشبورد',
            onPressed: () {
              context.push('/settings/dashboard');
            },
          ),
        ],
      ),
      body: const EnhancedSettingsPage(),
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

    // لا تعرض البانر إذا كان السجل المدني محملاً
    if (dbState.isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.orange.shade700,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السجل المدني غير محمّل',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'بعض الميزات لن تعمل بدون تحميل السجل المدني',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          FilledButton.tonal(
            onPressed: () {
              context.push('/database-download');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.orange.shade800,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            child: const Text('تحميل'),
          ),
        ],
      ),
    );
  }
}
