import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../analytics/ux_analytics.dart';
import 'analytics_exporter.dart';

/// 🎯 Enhanced Haptic Patterns with Analytics
///
/// Wraps HapticFeedback with usage tracking for A/B testing
class HapticPatternsWithAnalytics {
  /// Light selection haptic (for taps, toggles)
  static Future<void> selection() async {
    await UxAnalytics.trackHapticUsage();
    await HapticFeedback.selectionClick();
  }

  /// Medium impact haptic (for confirmations, success)
  static Future<void> impact() async {
    await UxAnalytics.trackHapticUsage();
    await HapticFeedback.mediumImpact();
  }

  /// Light impact haptic (for subtle feedback)
  static Future<void> lightImpact() async {
    await UxAnalytics.trackHapticUsage();
    await HapticFeedback.lightImpact();
  }

  /// Heavy impact haptic (for important actions, errors)
  static Future<void> heavyImpact() async {
    await UxAnalytics.trackHapticUsage();
    await HapticFeedback.heavyImpact();
  }

  /// Vibration haptic (for alerts, notifications)
  static Future<void> vibrate() async {
    await UxAnalytics.trackHapticUsage();
    await HapticFeedback.vibrate();
  }
}

/// 🎨 Performance-Monitored Animation Widget
///
/// Wraps animations with performance tracking
class MonitoredAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  const MonitoredAnimation({
    required this.child, required this.duration, super.key,
    this.curve = Curves.easeInOut,
    this.onComplete,
  });

  @override
  State<MonitoredAnimation> createState() => _MonitoredAnimationState();
}

class _MonitoredAnimationState extends State<MonitoredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addListener(_checkFrameRate);
    _controller.addStatusListener(_onAnimationComplete);

    _stopwatch.start();
    _controller.forward();
  }

  void _checkFrameRate() {
    // Track if animation is taking longer than expected (potential frame drops)
    if (_stopwatch.elapsedMilliseconds > widget.duration.inMilliseconds * 1.5) {
      UxAnalytics.trackAnimationFrameDrop();
    }
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _stopwatch.stop();
      UxAnalytics.trackAnimationDuration(_stopwatch.elapsedMilliseconds);
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkFrameRate);
    _controller.removeStatusListener(_onAnimationComplete);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: widget.curve,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 📊 Analytics Dashboard Widget
///
/// Shows UX analytics data for debugging/testing
class UxAnalyticsDashboard extends StatelessWidget {
  const UxAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 UX Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'export_json':
                  await AnalyticsExporter.shareAnalytics();
                  break;
                case 'export_csv':
                  await AnalyticsExporter.shareAnalytics(format: 'csv');
                  break;
                case 'export_txt':
                  await AnalyticsExporter.shareAnalytics(format: 'txt');
                  break;
                case 'reset':
                  await UxAnalytics.resetAnalytics();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم إعادة تعيين الإحصائيات')),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_json',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 20),
                    SizedBox(width: 8),
                    Text('Export JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_txt',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reset Data', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UxAnalytics.getAnalyticsSummary(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final haptic = data['haptic'] as Map<String, dynamic>;
          final darkMode = data['darkMode'] as Map<String, dynamic>;
          final animations = data['animations'] as Map<String, dynamic>;
          final accessibility = data['accessibility'] as Map<String, dynamic>;
          final sessions = data['sessions'] as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 💡 Insights Section
              FutureBuilder<List<String>>(
                future: AnalyticsExporter.generateInsights(),
                builder: (context, insightsSnapshot) {
                  if (insightsSnapshot.hasData &&
                      insightsSnapshot.data!.isNotEmpty) {
                    return Column(
                      children: [
                        _buildSection(
                          '💡 Insights',
                          insightsSnapshot.data!
                              .map((insight) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ',
                                            style: TextStyle(fontSize: 16)),
                                        Expanded(
                                          child: Text(
                                            insight,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              _buildSection(
                '🎯 Haptic Feedback',
                [
                  _buildMetric('مرات الاستخدام', '${haptic['usageCount']}'),
                  _buildMetric('مرات التعطيل', '${haptic['disabledCount']}'),
                  _buildMetric('آخر استخدام', haptic['lastUsed'] ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                '🌙 Dark Mode',
                [
                  _buildMetric(
                      'الحالة', darkMode['enabled'] ? 'مفعّل' : 'معطّل'),
                  _buildMetric('مرات التبديل', '${darkMode['toggleCount']}'),
                  _buildMetric('أول تفعيل', darkMode['firstEnabled'] ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                '🎨 Animations',
                [
                  _buildMetric('Frame Drops', '${animations['frameDrops']}'),
                  _buildMetric(
                      'Avg Duration', '${animations['avgDuration']}ms'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                '♿ Accessibility',
                [
                  _buildMetric('Screen Reader',
                      accessibility['screenReaderUsed'] ? 'نعم' : 'لا'),
                  _buildMetric('Semantics Interactions',
                      '${accessibility['semanticsInteractions']}'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                '📈 Sessions',
                [
                  _buildMetric('إجمالي الجلسات', '${sessions['total']}'),
                  _buildMetric('بداية الجلسة الحالية',
                      sessions['currentStart'] ?? 'N/A'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...metrics,
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
