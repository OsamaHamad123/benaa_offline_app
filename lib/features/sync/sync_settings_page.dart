import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client_with_mock.dart';

/// ⚙️ صفحة إعدادات المزامنة
class SyncSettingsPage extends ConsumerStatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  ConsumerState<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends ConsumerState<SyncSettingsPage> {
  bool _useMockApi = true;
  bool _simulateNetworkDelay = true;
  double _networkDelayMin = 500;
  double _networkDelayMax = 2000;
  double _errorRate = 0.1;
  bool _simulateConflicts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useMockApi = prefs.getBool('use_mock_api') ?? true;
      _simulateNetworkDelay = prefs.getBool('simulate_network_delay') ?? true;
      _networkDelayMin = prefs.getDouble('network_delay_min') ?? 500;
      _networkDelayMax = prefs.getDouble('network_delay_max') ?? 2000;
      _errorRate = prefs.getDouble('error_rate') ?? 0.1;
      _simulateConflicts = prefs.getBool('simulate_conflicts') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_mock_api', _useMockApi);
    await prefs.setBool('simulate_network_delay', _simulateNetworkDelay);
    await prefs.setDouble('network_delay_min', _networkDelayMin);
    await prefs.setDouble('network_delay_max', _networkDelayMax);
    await prefs.setDouble('error_rate', _errorRate);
    await prefs.setBool('simulate_conflicts', _simulateConflicts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ تم حفظ الإعدادات'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المزامنة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'حفظ الإعدادات',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============== API Mode ==============
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _useMockApi ? Icons.science : Icons.cloud,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text('وضع API', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('استخدام Mock API'),
                    subtitle: Text(
                      _useMockApi
                          ? 'سيرفر وهمي محلي للتجربة'
                          : 'API حقيقي (يتطلب اتصال بالسيرفر)',
                    ),
                    value: _useMockApi,
                    onChanged: (value) {
                      setState(() => _useMockApi = value);
                    },
                  ),
                  if (_useMockApi) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'في وضع Mock، البيانات محفوظة محلياً في جهازك فقط',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============== Mock Server Settings ==============
          if (_useMockApi) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'إعدادات السيرفر الوهمي',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Network Delay
                    SwitchListTile(
                      title: const Text('محاكاة تأخير الشبكة'),
                      subtitle: const Text('إضافة تأخير واقعي للطلبات'),
                      value: _simulateNetworkDelay,
                      onChanged: (value) {
                        setState(() => _simulateNetworkDelay = value);
                      },
                    ),

                    if (_simulateNetworkDelay) ...[
                      const SizedBox(height: 16),
                      Text(
                        'التأخير الأدنى: ${_networkDelayMin.toInt()} ms',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Slider(
                        value: _networkDelayMin,
                        min: 0,
                        max: 3000,
                        divisions: 30,
                        label: '${_networkDelayMin.toInt()} ms',
                        onChanged: (value) {
                          setState(() {
                            _networkDelayMin = value;
                            if (_networkDelayMin > _networkDelayMax) {
                              _networkDelayMax = _networkDelayMin;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'التأخير الأقصى: ${_networkDelayMax.toInt()} ms',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Slider(
                        value: _networkDelayMax,
                        min: 0,
                        max: 5000,
                        divisions: 50,
                        label: '${_networkDelayMax.toInt()} ms',
                        onChanged: (value) {
                          setState(() {
                            _networkDelayMax = value;
                            if (_networkDelayMax < _networkDelayMin) {
                              _networkDelayMin = _networkDelayMax;
                            }
                          });
                        },
                      ),
                    ],

                    const Divider(height: 32),

                    // Error Rate
                    Text(
                      'نسبة الأخطاء: ${(_errorRate * 100).toInt()}%',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _errorRate,
                      min: 0,
                      max: 0.5,
                      divisions: 50,
                      label: '${(_errorRate * 100).toInt()}%',
                      onChanged: (value) {
                        setState(() => _errorRate = value);
                      },
                    ),
                    Text(
                      'احتمال فشل الطلبات بشكل عشوائي',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const Divider(height: 32),

                    // Simulate Conflicts
                    SwitchListTile(
                      title: const Text('محاكاة التعارضات'),
                      subtitle: const Text('اكتشاف تعديلات متزامنة'),
                      value: _simulateConflicts,
                      onChanged: (value) {
                        setState(() => _simulateConflicts = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============== Mock Server Actions ==============
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'إدارة البيانات الوهمية',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _seedTestData,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('إضافة بيانات تجريبية'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _clearServerData,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('مسح بيانات السيرفر الوهمي'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _seedTestData() async {
    try {
      final apiClient = await ref.read(apiClientWithMockProvider.future);
      await apiClient.seedMockTestData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم إضافة بيانات تجريبية'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _clearServerData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المسح'),
        content: const Text(
          'هل أنت متأكد من مسح جميع بيانات السيرفر الوهمي؟\n\n'
          'ملاحظة: البيانات المحلية في جهازك لن تتأثر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiClient = await ref.read(apiClientWithMockProvider.future);
      await apiClient.clearMockServerData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم مسح بيانات السيرفر الوهمي'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
