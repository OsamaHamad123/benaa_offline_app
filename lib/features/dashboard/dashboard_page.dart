import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/secure_store.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../sync/sync_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SecureStore.clearCredentials();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منظومة بناء'),
        actions: [
          const SyncButton(), // زر المزامنة
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const _DashboardHome()
          : _selectedIndex == 1
          ? const SyncDetailsPage()
          : const _SettingsView(),
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
}

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Column(
      children: [
        const SyncStatusBar(), // شريط حالة المزامنة
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // TODO: Refresh data
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              padding: padding,
              children: [
                // Welcome Header
                _WelcomeHeader(),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Statistics Cards
                const _StatisticsSection(),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Quick Actions
                Text(
                  'الإجراءات السريعة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
                ),
                const _QuickActionsGrid(),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),

                // Recent Activity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'النشاط الأخير',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                  height: ResponsiveUtils.getResponsiveSpacing(context) * 0.75,
                ),
                const _RecentActivityList(),
              ],
            ),
          ),
        ),
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

    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مرحباً بك في منظومة بناء',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
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

class _StatCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return Card(
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
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isSmallScreen ? 24 : 28,
              ),
            ),
          ],
        ),
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

class _QuickAction extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 11 : 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
    // TODO: Replace with real data
    final activities = [
      _Activity(
        title: 'إضافة مستفيد جديد',
        subtitle: 'أحمد محمد علي',
        time: 'منذ ساعة',
        icon: Icons.person_add,
        color: Colors.green,
      ),
      _Activity(
        title: 'تعديل بيانات',
        subtitle: 'فاطمة حسن',
        time: 'منذ ساعتين',
        icon: Icons.edit,
        color: Colors.blue,
      ),
      _Activity(
        title: 'مزامنة البيانات',
        subtitle: '15 مستفيد تم مزامنته',
        time: 'منذ 3 ساعات',
        icon: Icons.sync,
        color: Colors.purple,
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) => activities[index],
    );
  }
}

class _Activity extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
