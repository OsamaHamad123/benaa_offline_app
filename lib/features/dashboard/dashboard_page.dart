import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/services/activity_logger.dart';
import '../../data/models/activity_log.dart';
import '../sync/sync_widgets.dart';
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_insights.dart';
import 'widgets/dashboard_actions.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Widget currentPage;

    switch (_selectedIndex) {
      case 0:
        currentPage = const _DashboardHome();
        break;
      case 1:
        currentPage = const SyncDetailsPage();
        break;
      case 2:
        currentPage = const _SettingsView();
        break;
      default:
        currentPage = const _DashboardHome();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: currentPage,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
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
    // AppBar مخصص حسب الصفحة الحالية
    if (_selectedIndex == 0) {
      // Dashboard AppBar مع Notifications
      final notificationsAsync = ref.watch(notificationsCountProvider);

      return DashboardAppBar(
        title: 'منظومة بناء',
        notificationCount: notificationsAsync.maybeWhen(
          data: (count) => count,
          orElse: () => 0,
        ),
        onNotificationTap: () {
          final count = notificationsAsync.maybeWhen(
            data: (count) => count,
            orElse: () => 0,
          );

          if (count == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد إشعارات جديدة')),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('لديك $count إشعار')));
          }
        },
        onSyncTap: () {
          setState(() => _selectedIndex = 1); // Navigate to Sync tab
        },
        onProfileTap: () {
          context.push('/profile');
        },
      );
    } else if (_selectedIndex == 1) {
      // Sync Page AppBar
      return const CustomAppBar(title: 'المزامنة', showBackButton: false);
    } else {
      // Settings AppBar
      return const CustomAppBar(title: 'الإعدادات', showBackButton: false);
    }
  }
}

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Stack(
      children: [
        Column(
          children: [
            const ConnectionStatusBar(isOnline: true),
            const SyncStatusBar(), // شريط حالة المزامنة
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // إعادة تحميل كل البيانات
                  ref.invalidate(statisticsProvider);
                  ref.invalidate(notificationsCountProvider);

                  // انتظار التحديث
                  await Future.wait([
                    ref.read(statisticsProvider.future),
                    ref.read(notificationsCountProvider.future),
                  ]);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث البيانات'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: ListView(
                  padding: padding,
                  children: [
                    // Welcome Header
                    _WelcomeHeader(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Alerts & Insights
                    const PendingSyncAlert(),
                    const SizedBox(height: 12),
                    const LastSyncStatus(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Statistics Cards
                    const _StatisticsSection(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Charts Row
                    if (ResponsiveUtils.isTablet(context) ||
                        ResponsiveUtils.isDesktop(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: BeneficiariesGrowthChart()),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                            ),
                          ),
                          const Expanded(child: CategoryDistributionChart()),
                        ],
                      )
                    else ...[
                      const BeneficiariesGrowthChart(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(context),
                      ),
                      const CategoryDistributionChart(),
                    ],
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Performance & Quality
                    if (ResponsiveUtils.isTablet(context) ||
                        ResponsiveUtils.isDesktop(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: PerformanceMetricsCard()),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                            ),
                          ),
                          const Expanded(child: DataQualityScore()),
                        ],
                      )
                    else ...[
                      const PerformanceMetricsCard(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(context),
                      ),
                      const DataQualityScore(),
                    ],
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Quick Actions
                    Text(
                      'الإجراءات السريعة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
                    ),
                    const _QuickActionsGrid(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Export Actions
                    const ExportActionsRow(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Today's Stats Summary
                    const _TodayStatsSummary(),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context),
                    ),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'النشاط الأخير',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: View all activity
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
                    ),
                    const _RecentActivityList(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
        // Speed Dial FAB
        const Positioned(bottom: 16, left: 16, child: DashboardSpeedDial()),
      ],
    );
  }
}

// Welcome Header Widget
class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color greetingColor;

    if (hour < 12) {
      greeting = 'صباح الخير ☀️';
      greetingIcon = Icons.wb_sunny_rounded;
      greetingColor = Colors.orange;
    } else if (hour < 18) {
      greeting = 'مساء الخير 🌤️';
      greetingIcon = Icons.wb_cloudy_rounded;
      greetingColor = Colors.blue;
    } else {
      greeting = 'مساء الخير 🌙';
      greetingIcon = Icons.nights_stay_rounded;
      greetingColor = Colors.indigo;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              greetingColor.withOpacity(0.05),
              greetingColor.withOpacity(0.15),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      greetingColor.withOpacity(0.2),
                      greetingColor.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: greetingColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(greetingIcon, size: 32, color: greetingColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: greetingColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مرحباً بك في منظومة بناء',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'متصل',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsSection extends ConsumerWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<List<int>>(
      future: Future.wait([
        database.countBeneficiaries(),
        database.countPendingSync(),
        database.countBeneficiariesByCategory('orphan'),
        database.countBeneficiariesByCategory('poor'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
          context,
          mobile: 2,
          tablet: 4,
          desktop: 4,
        );
        final spacing = ResponsiveUtils.getResponsiveSpacing(context);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 1.5,
            tablet: 1.3,
            desktop: 1.4,
          ),
          children: [
            _StatCard(
              title: 'إجمالي المستفيدين',
              value: '${stats[0]}',
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'بانتظار المزامنة',
              value: '${stats[1]}',
              icon: Icons.sync,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'أيتام',
              value: '${stats[2]}',
              icon: Icons.child_care,
              color: Colors.purple,
            ),
            _StatCard(
              title: 'فقراء',
              value: '${stats[3]}',
              icon: Icons.volunteer_activism,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animation with delay based on position
    Future.delayed(Duration(milliseconds: widget.value.hashCode % 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.05),
                  widget.color.withOpacity(0.15),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                      fontSize: isSmallScreen ? 28 : 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Today's Stats Summary Widget
class _TodayStatsSummary extends StatelessWidget {
  const _TodayStatsSummary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityLog>>(
      future: ActivityLogger.getTodayActivities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final todayActivities = snapshot.data!;
        if (todayActivities.isEmpty) {
          return const SizedBox.shrink();
        }

        // Count activities by type
        final addCount = todayActivities.where((a) => a.type == 'add').length;
        final editCount = todayActivities.where((a) => a.type == 'edit').length;
        final syncCount = todayActivities.where((a) => a.type == 'sync').length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.withOpacity(0.05),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.indigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'نشاط اليوم',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${todayActivities.length} عملية',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (addCount > 0)
                      Expanded(
                        child: _TodayStatItem(
                          icon: Icons.person_add_rounded,
                          label: 'إضافة',
                          count: addCount,
                          color: Colors.green,
                        ),
                      ),
                    if (editCount > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TodayStatItem(
                          icon: Icons.edit_rounded,
                          label: 'تعديل',
                          count: editCount,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                    if (syncCount > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TodayStatItem(
                          icon: Icons.sync_rounded,
                          label: 'مزامنة',
                          count: syncCount,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodayStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _TodayStatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'إضافة مستفيد',
        icon: Icons.person_add,
        color: Colors.blue,
        onTap: () => context.push('/beneficiaries/add'),
      ),
      _QuickAction(
        title: 'البحث',
        icon: Icons.search,
        color: Colors.green,
        onTap: () => context.push('/search'),
      ),
      _QuickAction(
        title: 'التقارير',
        icon: Icons.assessment,
        color: Colors.orange,
        onTap: () => context.push('/reports'),
      ),
      _QuickAction(
        title: 'المزامنة',
        icon: Icons.sync,
        color: Colors.purple,
        onTap: () => context.push('/sync'),
      ),
      _QuickAction(
        title: 'قائمة المستفيدين',
        icon: Icons.list,
        color: Colors.teal,
        onTap: () => context.push('/beneficiaries'),
      ),
      _QuickAction(
        title: 'السجل المدني',
        icon: Icons.badge,
        color: Colors.indigo,
        onTap: () => context.push('/search'),
      ),
      _QuickAction(
        title: 'استيراد بيانات تجربة',
        icon: Icons.cloud_download,
        color: Colors.green,
        onTap: () => context.push('/import-test'),
      ),
      _QuickAction(
        title: 'اختبار Sync',
        icon: Icons.sync_problem,
        color: Colors.deepOrange,
        onTap: () => context.push('/test-sync'),
      ),
    ];

    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 6,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: ResponsiveUtils.getResponsiveValue(
          context,
          mobile: 1.0,
          tablet: 1.1,
          desktop: 1.0,
        ),
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }
}

class _QuickAction extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Card(
        elevation: _isPressed ? 1 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.05),
                  widget.color.withOpacity(0.1),
                ],
              ),
            ),
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: isSmallScreen ? 26 : 30,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 11 : 12,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityLog>>(
      future: ActivityLogger.getRecentActivities(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _EmptyActivityCard();
        }

        final activities = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _Activity(
              title: activity.title,
              subtitle: activity.subtitle,
              time: activity.getRelativeTime(),
              icon: _getIconForActivityType(activity.type),
              color: _getColorForActivityType(activity.type),
              onTap: activity.beneficiaryId != null
                  ? () =>
                        context.push('/beneficiaries/${activity.beneficiaryId}')
                  : null,
            );
          },
        );
      },
    );
  }

  IconData _getIconForActivityType(String type) {
    switch (type) {
      case 'add':
        return Icons.person_add_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'delete':
        return Icons.delete_rounded;
      case 'sync':
        return Icons.sync_rounded;
      case 'visit':
        return Icons.event_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColorForActivityType(String type) {
    switch (type) {
      case 'add':
        return Colors.green;
      case 'edit':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'sync':
        return Colors.purple;
      case 'visit':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Empty State Card for activities
class _EmptyActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نشاطات بعد',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة مستفيدين أو إجراء مزامنة',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [color.withOpacity(0.05), Colors.white],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return ListView(
      padding: padding,
      children: [
        Text(
          'الإعدادات',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('الملف الشخصي'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('الإشعارات'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('إعدادات المزامنة'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/sync'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('حول التطبيق'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'منظومة بناء',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 جميع الحقوق محفوظة',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
