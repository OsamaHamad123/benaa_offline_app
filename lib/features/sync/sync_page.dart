import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  bool _isSyncing = false;
  String? _syncMessage;
  double _syncProgress = 0.0;

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
      _syncMessage = 'جاري الاتصال بالخادم...';
    });

    try {
      // Simulate sync process
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _syncProgress = 0.3;
        _syncMessage = 'جاري مزامنة المستفيدين...';
      });

      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _syncProgress = 0.7;
        _syncMessage = 'جاري رفع المرفقات...';
      });

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _syncProgress = 1.0;
        _syncMessage = 'اكتملت المزامنة بنجاح!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت المزامنة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncMessage = 'فشلت المزامنة: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المزامنة'),
        // actions: [ // تم تعطيل الإعدادات والدليل مؤقتاً
        //   IconButton(
        //     icon: const Icon(Icons.help_outline),
        //     onPressed: () {},
        //     tooltip: 'دليل التجربة',
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {},
        //     tooltip: 'إعدادات المزامنة',
        //   ),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isSyncing ? Icons.sync : Icons.cloud_done,
                        color: _isSyncing
                            ? Theme.of(context).colorScheme.primary
                            : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSyncing ? 'جاري المزامنة...' : 'حالة المزامنة',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (_syncMessage != null)
                              Text(
                                _syncMessage!,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isSyncing) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _syncProgress),
                    const SizedBox(height: 8),
                    Text(
                      '${(_syncProgress * 100).toInt()}%',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pending Items
          FutureBuilder<int>(
            future: database.countPendingSync(),
            builder: (context, snapshot) {
              final pendingCount = snapshot.data ?? 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العناصر بانتظار المزامنة',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.people,
                              label: 'مستفيدين',
                              count: pendingCount,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.attach_file,
                              label: 'مرفقات',
                              count: 0,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Sync Settings
          Text(
            'إعدادات المزامنة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('المزامنة التلقائية'),
                  subtitle: const Text('مزامنة البيانات تلقائياً عند الاتصال'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement auto sync setting
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('استخدام Wi-Fi فقط'),
                  subtitle: const Text('المزامنة عند الاتصال بشبكة Wi-Fi فقط'),
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement WiFi only setting
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('آخر مزامنة'),
                  subtitle: const Text('لم يتم المزامنة بعد'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show sync history
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sync Button
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSyncing ? null : _performSync,
              icon: Icon(_isSyncing ? Icons.sync : Icons.cloud_upload),
              label: Text(_isSyncing ? 'جاري المزامنة...' : 'بدء المزامنة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
