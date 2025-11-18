import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/welcome_banner.dart';
import '../../../../core/widgets/filter_chip_group.dart';
import '../../../../core/widgets/animated_progress_indicator.dart';
import '../../../../core/providers/providers.dart' as core_providers;
import '../../../sync/sync_page.dart';
import '../providers.dart';
import '../widgets/dashboard_app_bar.dart' as dashboard_widgets;
import '../widgets/statistics_section.dart';
import '../widgets/quick_actions.dart';
import '../widgets/activities_section.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/urgent_cases_section.dart';
import '../widgets/geographic_distribution_section.dart';
import '../widgets/daily_performance_section.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _checkWelcomeBanner();
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

  @override
  Widget build(BuildContext context) {
    final Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: _selectedFilter,
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
        );
        break;
      case 1:
        currentPage = const SyncPage();
        break;
      case 2:
        currentPage = const _SettingsView();
        break;
      default:
        currentPage = _DashboardHome(
          showWelcomeBanner: _showWelcomeBanner,
          selectedFilter: _selectedFilter,
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
        );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: currentPage,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/beneficiaries/add');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة مستفيد'),
              backgroundColor: Colors.blue,
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
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

  PreferredSizeWidget _buildAppBar() {
    if (_selectedIndex == 0) {
      return dashboard_widgets.DashboardAppBar(
        title: 'منظومة بناء',
        onSearchTap: () => context.push('/beneficiaries'),
        onNotificationTap: () {
          final state = ref.read(dashboardProvider);
          final count = state.todayStats?.pendingTasks ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                count > 0 ? 'لديك $count مهمة معلقة' : 'لا توجد مهام معلقة',
              ),
            ),
          );
        },
        onSyncTap: () => setState(() => _selectedIndex = 1),
        onProfileTap: () => context.push('/profile'),
      );
    } else if (_selectedIndex == 1) {
      return const CustomAppBar(title: 'المزامنة', showBackButton: false);
    } else {
      return const CustomAppBar(title: 'الإعدادات', showBackButton: false);
    }
  }
}

class _DashboardHome extends ConsumerWidget {
  final bool showWelcomeBanner;
  final String selectedFilter;
  final VoidCallback onWelcomeDismiss;
  final Function(String) onFilterChanged;

  const _DashboardHome({
    required this.showWelcomeBanner,
    required this.selectedFilter,
    required this.onWelcomeDismiss,
    required this.onFilterChanged,
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
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'خطأ في تحميل الإعدادات',
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
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

    return RefreshIndicator(
      onRefresh: () async {
        await notifier.refresh();
      },
      child: state.isLoadingStats && state.statistics == null
          ? const Center(child: CircularProgressIndicator())
          : state.hasError
          ? _buildErrorView(context, state.errorMessage!, notifier)
          : _buildContent(context, ref, state, notifier, padding),
    );
  }

  Widget _buildErrorView(BuildContext context, String error, dynamic notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            error,
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => notifier.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    dynamic notifier,
    EdgeInsets padding,
  ) {
    final stats = state.statistics;
    if (stats == null) return const SizedBox();

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Filter Chips
          SizedBox(height: 16.h),
          FilterChipGroup(
            filters: [
              FilterChipData(
                label: 'الكل',
                value: 'all',
                icon: Icons.grid_view,
                count: stats.totalBeneficiaries,
              ),
              FilterChipData(
                label: 'اليوم',
                value: 'today',
                icon: Icons.today,
                count: stats.completedVisitsToday,
                color: Colors.green,
              ),
              FilterChipData(
                label: 'هذا الأسبوع',
                value: 'week',
                icon: Icons.date_range,
                color: Colors.blue,
              ),
              FilterChipData(
                label: 'تحتاج متابعة',
                value: 'urgent',
                icon: Icons.warning_amber,
                count: stats.pendingSync,
                color: Colors.red,
              ),
            ],
            selectedFilter: selectedFilter,
            onSelectionChanged: (selected) {
              if (selected.isNotEmpty) {
                onFilterChanged(selected.first);
                // TODO: Apply filter to dashboard data
              }
            },
          ),

          SizedBox(height: 24.h),

          // Last Refresh Time with modern design
          if (state.lastRefreshTime != null)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Text(
                    'آخر تحديث: ${_formatRefreshTime(state.lastRefreshTime)}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

          // Section: Quick Actions (الأكثر استخداماً - في الأعلى)
          _SectionTitle(title: 'إجراءات سريعة', icon: Icons.flash_on),
          SizedBox(height: 12.h),
          QuickActionsGrid(
            onAddBeneficiaryTap: () => context.push('/beneficiaries/add'),
            onSearchTap: () => context.push('/beneficiaries'),
            onSyncTap: () => context.push('/sync'),
            onReportsTap: () => context.push('/reports'),
            onCivilRegistryTap: () => context.push('/search'),
          ),

          SizedBox(height: 24.h),

          // Statistics Grid (مع تحسينات)
          StatisticsGrid(
            totalBeneficiaries: stats.totalBeneficiaries,
            activeBeneficiaries: stats.activeBeneficiaries,
            pendingSync: stats.pendingSync,
            completedVisitsToday: stats.completedVisitsToday,
            onBeneficiariesTap: () => context.push('/beneficiaries'),
            onPendingSyncTap: () => context.push('/sync'),
          ),

          SizedBox(height: 16.h),

          // Sync Progress Indicator
          if (stats.pendingSync > 0)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sync, size: 20.sp, color: Colors.orange),
                        SizedBox(width: 8.w),
                        Text(
                          'تقدم المزامنة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${((stats.totalBeneficiaries - stats.pendingSync) / stats.totalBeneficiaries * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    AnimatedProgressIndicator(
                      value:
                          (stats.totalBeneficiaries - stats.pendingSync) /
                          stats.totalBeneficiaries,
                      height: 8,
                      valueColor: Colors.orange,
                      backgroundColor: Colors.orange.withOpacity(0.2),
                      duration: const Duration(milliseconds: 1500),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${stats.pendingSync} سجل متبقي للمزامنة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 24.h),

          // Section: Urgent Cases - الحالات الطارئة (أولوية عالية)
          _SectionTitle(title: 'حالات تحتاج متابعة', icon: Icons.warning_amber),
          SizedBox(height: 12.h),
          const UrgentCasesSection(),

          SizedBox(height: 24.h),

          // Section: Daily Performance - مؤشر الأداء اليومي
          _SectionTitle(title: 'الأداء اليومي', icon: Icons.trending_up),
          SizedBox(height: 12.h),
          const DailyPerformanceSection(),

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

          SizedBox(height: 24.h),

          // Last Refresh Time (في Footer)
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'آخر تحديث: ${_formatRefreshTime(state.lastRefreshTime)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  String _formatRefreshTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'منذ ${diff.inHours} ساعة';
    }
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.purple.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(widget.icon, size: 20.sp, color: Colors.blue),
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
            HapticFeedback.selectionClick();
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
                Colors.blue.withOpacity(0.2),
                Colors.purple.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: Colors.blue),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
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
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return ListView(
      padding: padding,
      children: [
        SizedBox(height: 16.h),
        Text(
          'الإعدادات',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24.h),
        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () => context.push('/profile'),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.notifications,
              title: 'الإشعارات',
              onTap: () {
                // TODO: Navigate to notifications settings
              },
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.sync,
              title: 'إعدادات المزامنة',
              onTap: () => context.push('/sync'),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.info,
              title: 'حول التطبيق',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'منظومة بناء',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.app_settings_alt, size: 48),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.blue, size: 24.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: 24.sp),
      onTap: onTap,
    );
  }
}
