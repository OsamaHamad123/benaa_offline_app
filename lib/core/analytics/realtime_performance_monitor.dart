import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📈 Real-time Performance Monitor
///
/// Live monitoring dashboard for app performance:
/// - FPS (Frames Per Second)
/// - Frame build time
/// - Jank detection (dropped frames)
/// - Memory usage trends
class RealTimePerformanceMonitor extends StatefulWidget {
  const RealTimePerformanceMonitor({super.key});

  @override
  State<RealTimePerformanceMonitor> createState() => _RealTimePerformanceMonitorState();
}

class _RealTimePerformanceMonitorState extends State<RealTimePerformanceMonitor> {
  final List<double> _fpsHistory = [];
  final List<double> _frameTimeHistory = [];
  final int _maxHistoryLength = 60; // Keep last 60 measurements

  double _currentFps = 0;
  double _currentFrameTime = 0;
  int _jankCount = 0;
  bool _isMonitoring = false;

  Timer? _updateTimer;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    if (_isMonitoring) return;

    setState(() => _isMonitoring = true);

    // Monitor frame timings
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);

    // Update UI every second
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Calculate FPS based on frame count
          _currentFps = _frameCount.toDouble();
          _frameCount = 0;

          // Add to history
          if (_fpsHistory.length >= _maxHistoryLength) {
            _fpsHistory.removeAt(0);
          }
          _fpsHistory.add(_currentFps);
        });
      }
    });
  }

  void _stopMonitoring() {
    setState(() => _isMonitoring = false);
    _updateTimer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    for (final timing in timings) {
      _frameCount++;

      // Calculate frame build time in milliseconds
      final buildTime = timing.buildDuration.inMicroseconds / 1000;
      final rasterTime = timing.rasterDuration.inMicroseconds / 1000;
      final totalTime = buildTime + rasterTime;

      setState(() {
        _currentFrameTime = totalTime;

        // Add to history
        if (_frameTimeHistory.length >= _maxHistoryLength) {
          _frameTimeHistory.removeAt(0);
        }
        _frameTimeHistory.add(totalTime);

        // Detect jank (frame took > 16.67ms for 60fps)
        if (totalTime > 16.67) {
          _jankCount++;
        }
      });
    }
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avgFps = _fpsHistory.isEmpty ? 0.0 : _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;

    final avgFrameTime =
        _frameTimeHistory.isEmpty ? 0.0 : _frameTimeHistory.reduce((a, b) => a + b) / _frameTimeHistory.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Real-time Performance'),
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isMonitoring) {
                _stopMonitoring();
              } else {
                _startMonitoring();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fpsHistory.clear();
                _frameTimeHistory.clear();
                _jankCount = 0;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Status Card
          Card(
            color: _isMonitoring ? Colors.green.shade50 : Colors.grey.shade100,
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(
                    _isMonitoring ? Icons.analytics : Icons.pause_circle,
                    color: _isMonitoring ? Colors.green : Colors.grey,
                    size: 32.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _isMonitoring ? 'Monitoring Active' : 'Monitoring Paused',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // FPS Metric
          _buildMetricCard(
            title: 'Current FPS',
            value: _currentFps.toStringAsFixed(0),
            subtitle: 'Average: ${avgFps.toStringAsFixed(1)} fps',
            icon: Icons.speed,
            color: _getFpsColor(_currentFps),
            chart: _buildMiniChart(_fpsHistory, 60),
          ),

          SizedBox(height: 16.h),

          // Frame Time Metric
          _buildMetricCard(
            title: 'Frame Time',
            value: '${_currentFrameTime.toStringAsFixed(1)}ms',
            subtitle: 'Average: ${avgFrameTime.toStringAsFixed(1)}ms',
            icon: Icons.timer,
            color: _getFrameTimeColor(_currentFrameTime),
            chart: _buildMiniChart(_frameTimeHistory, 16.67),
          ),

          SizedBox(height: 16.h),

          // Jank Counter
          _buildMetricCard(
            title: 'Dropped Frames',
            value: _jankCount.toString(),
            subtitle: 'Frames > 16.67ms',
            icon: Icons.warning_amber,
            color: _jankCount > 10 ? Colors.red : Colors.orange,
          ),

          SizedBox(height: 16.h),

          // Performance Rating
          _buildPerformanceRating(avgFps, avgFrameTime, _jankCount),

          SizedBox(height: 16.h),

          // Recommendations
          _buildRecommendations(avgFps, avgFrameTime, _jankCount),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? chart,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
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
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            if (chart != null) ...[
              SizedBox(height: 12.h),
              chart,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(List<double> data, double threshold) {
    if (data.isEmpty) {
      return Container(
        height: 60.h,
        alignment: Alignment.center,
        child: Text(
          'No data yet',
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 60.h,
      child: CustomPaint(
        painter: _ChartPainter(
          data: data,
          maxValue: maxValue,
          threshold: threshold,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildPerformanceRating(double fps, double frameTime, int jank) {
    String rating;
    Color color;
    IconData icon;

    if (fps >= 55 && frameTime < 17 && jank < 5) {
      rating = 'Excellent ⭐⭐⭐⭐⭐';
      color = Colors.green;
      icon = Icons.sentiment_very_satisfied;
    } else if (fps >= 50 && frameTime < 20 && jank < 10) {
      rating = 'Good ⭐⭐⭐⭐';
      color = Colors.lightGreen;
      icon = Icons.sentiment_satisfied;
    } else if (fps >= 40 && frameTime < 25 && jank < 20) {
      rating = 'Fair ⭐⭐⭐';
      color = Colors.orange;
      icon = Icons.sentiment_neutral;
    } else {
      rating = 'Needs Improvement ⭐';
      color = Colors.red;
      icon = Icons.sentiment_dissatisfied;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Rating',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
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

  Widget _buildRecommendations(double fps, double frameTime, int jank) {
    final recommendations = <String>[];

    if (fps < 50) {
      recommendations.add('• Low FPS detected - consider reducing widget rebuilds');
    }
    if (frameTime > 20) {
      recommendations.add('• High frame time - optimize expensive build operations');
    }
    if (jank > 15) {
      recommendations.add('• Many dropped frames - check for heavy computations in build()');
    }
    if (recommendations.isEmpty) {
      recommendations.add('• Performance is optimal! 🎉');
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 Recommendations',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            ...recommendations.map(
              (rec) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  rec,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 45) return Colors.orange;
    return Colors.red;
  }

  Color _getFrameTimeColor(double time) {
    if (time < 16.67) return Colors.green;
    if (time < 20) return Colors.orange;
    return Colors.red;
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;
  final double threshold;

  _ChartPainter({
    required this.data,
    required this.maxValue,
    required this.threshold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Draw threshold line
    final thresholdPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final thresholdY = size.height - (threshold / maxValue * size.height);
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      thresholdPaint,
    );

    // Draw line chart
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => true;
}
