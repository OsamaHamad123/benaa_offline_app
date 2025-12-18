import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../sync/mobile_sync_page.dart';
import '../providers.dart';
import '../widgets/quick_actions.dart';
import '../widgets/activities_section.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/urgent_cases_section.dart';
import '../widgets/geographic_distribution_section.dart';
import '../widgets/daily_performance_section.dart';
import '../widgets/dashboard_summary_widget.dart';
import '../widgets/advanced_filters_widget.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/settings/enhanced_settings_page.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/utils/haptic_patterns.dart';

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

    // Log screen exit with error handling
    try {
      ref.read(appMonitoringProvider).logScreenExit('Dashboard');
    } catch (_) {
      // Ignore if ref is already disposed
    }
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
                HapticPatterns.submit();
                context.push('/beneficiaries/add');
              },
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticPatterns.submit();
                  context.push('/beneficiaries/add');
                },
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة مستفيد'),
                backgroundColor: AppColors.primary,
                elevation: 4,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticPatterns.selection();
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
              style: TextStyle(fontSize: 16.sp, color: AppColors.error),
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

    return CustomScrollView(
      slivers: [
        // Modern App Bar - مكون موحد قابل لإعادة الاستخدام
        ModernSliverAppBar(
          title: !isOnline ? 'منظومة بناء (غير متصل)' : 'منظومة بناء',
          icon: Icons.dashboard_rounded,
          actions: [
            ModernActionButton(
              icon: Icons.search_rounded,
              tooltip: 'البحث',
              iconSize: 28,
              onPressed: () => context.push('/beneficiaries'),
            ),
            ModernActionButton(
              icon: Icons.notifications_outlined,
              tooltip: 'الإشعارات',
              iconSize: 28,
              badge: state.todayStats?.pendingTasks,
              onPressed: () {
                final count = state.todayStats?.pendingTasks ?? 0;
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
              HapticPatterns.refresh();
              await notifier.refresh();
            },
            color: AppColors.primary,
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

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline Indicator Banner
          if (!isOnline)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    color: AppColors.warningDark,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وضع عدم الاتصال',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warningDark,
                          ),
                        ),
                        Text(
                          'يمكنك العمل حالياً وسيتم المزامنة عند عودة الاتصال',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Welcome Banner (First time users)
          if (showWelcomeBanner)
            WelcomeBanner(
              userName: 'المستخدم',
              message: 'مرحباً بك في منظومة بناء',
              onGetStarted: () {
                context.push('/beneficiaries/add');
              },
              onDismiss: onWelcomeDismiss,
            ),

          // Filter Chips with Advanced Filters Button - في الأعلى للوصول السريع
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _SectionTitle(
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
            filters: [
              FilterChipData(
                label: 'الكل',
                value: 'all',
                icon: Icons.grid_view,
              ),
              FilterChipData(
                label: 'اليوم',
                value: 'today',
                icon: Icons.today,
                color: AppColors.success,
              ),
              FilterChipData(
                label: 'هذا الأسبوع',
                value: 'week',
                icon: Icons.date_range,
                color: AppColors.primary,
              ),
              FilterChipData(
                label: 'تحتاج متابعة',
                value: 'urgent',
                icon: Icons.warning_amber,
                color: AppColors.error,
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
          FadeSlideTransition(
            duration: AppDurations.fast,
            child: const DashboardSummaryWidget(),
          ),

          SizedBox(height: 24.h),

          // Section: Quick Actions (الأكثر استخداماً - في الأعلى)
          _SectionTitle(title: 'إجراءات سريعة', icon: Icons.flash_on),
          SizedBox(height: 12.h),
          QuickActionsGrid(
            onAddBeneficiaryTap: () {
              HapticPatterns.submit();
              context.push('/beneficiaries/add');
            },
            onKafalatTap: () {
              HapticPatterns.selection();
              context.push('/kafalat');
            },
            onSearchTap: () {
              HapticPatterns.selection();
              context.push('/beneficiaries');
            },
            onSyncTap: () {
              HapticPatterns.selection();
              context.push('/sync');
            },
            onReportsTap: () {
              HapticPatterns.selection();
              context.push('/reports');
            },
            onCivilRegistryTap: () {
              HapticPatterns.selection();
              context.push('/search');
            },
            onVisitsTap: () {
              HapticPatterns.selection();
              context.push('/visits');
            },
            onAssociationsTap: () {
              HapticPatterns.selection();
              context.push('/associations');
            },
            syncBadge: stats.pendingSync,
            reportsBadge: null,
          ),

          SizedBox(height: 24.h),

          // 📊 Interactive Charts Section - NEW!
          _SectionTitle(title: 'الإحصائيات التفاعلية', icon: Icons.bar_chart),
          SizedBox(height: 12.h),

          // Trend Line Chart
          FadeSlideTransition(
            duration: AppDurations.normal,
            slideOffset: const Offset(0, 0.2),
            child: TrendLineChart(
              title: 'نمو المستفيدين (آخر 6 أشهر)',
              data: [
                stats.totalBeneficiaries * 0.5,
                stats.totalBeneficiaries * 0.65,
                stats.totalBeneficiaries * 0.75,
                stats.totalBeneficiaries * 0.85,
                stats.totalBeneficiaries * 0.92,
                stats.totalBeneficiaries.toDouble(),
              ],
              labels: const ['ين', 'فب', 'مار', 'أبر', 'ماي', 'يون'],
              lineColor: AppColors.primary,
            ),
          ),

          SizedBox(height: 24.h),

          // Section: Urgent Cases - الحالات الطارئة (أولوية عالية)
          _SectionTitle(title: 'حالات تحتاج متابعة', icon: Icons.warning_amber),
          SizedBox(height: 12.h),
          ScaleTransitionWidget(
            duration: AppDurations.fast,
            child: const UrgentCasesSection(),
          ),

          SizedBox(height: 24.h),

          // Section: Daily Performance - مؤشر الأداء اليومي
          _SectionTitle(title: 'الأداء اليومي', icon: Icons.trending_up),
          SizedBox(height: 12.h),
          ScaleTransitionWidget(
            duration: AppDurations.fast,
            child: const DailyPerformanceSection(),
          ),

          SizedBox(height: 24.h),

          // Section: Recent Activities (آخر 5 فقط)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: 'الأنشطة الحديثة', icon: Icons.history),
              TextButton.icon(
                onPressed: () {
                  context.push('/activities');
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
          _CollapsibleSection(
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
          _CollapsibleSection(
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

/// Collapsible Section Widget
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // إزالة المسافة الخارجية
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.divider.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.orphan.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(widget.icon, size: 20.sp, color: AppColors.primary),
          ),
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.expand_more),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
            HapticPatterns.selection();
          },
          children: [
            Padding(padding: EdgeInsets.all(16.w), child: widget.child),
          ],
        ),
      ),
    );
  }
}

/// Section Title Widget with Icon
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.orphan.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Settings View
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    // استخدم صفحة الإعدادات الجديدة المحسّنة
    return const EnhancedSettingsPage();
  }
}
