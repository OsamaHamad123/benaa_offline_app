import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'ux_analytics.dart';

/// 📤 Analytics Export Manager
///
/// Handles exporting analytics data to various formats:
/// - JSON for programmatic access
/// - CSV for Excel/Sheets
/// - Human-readable text reports
class AnalyticsExporter {
  /// Export analytics as JSON file
  static Future<String?> exportAsJson() async {
    try {
      final summary = await UxAnalytics.getAnalyticsSummary();
      final jsonString = const JsonEncoder.withIndent('  ').convert(summary);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/ux_analytics_$timestamp.json');

      await file.writeAsString(jsonString);

      if (kDebugMode) {
        print('✅ Analytics exported to JSON: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exporting JSON: $e');
      }
      return null;
    }
  }

  /// Export analytics as CSV file
  static Future<String?> exportAsCsv() async {
    try {
      final summary = await UxAnalytics.getAnalyticsSummary();
      final csvLines = <String>[
        'Category,Metric,Value',
        '',
        '# Haptic Feedback',
        'Haptic,Usage Count,${summary['haptic']['usageCount']}',
        'Haptic,Disabled Count,${summary['haptic']['disabledCount']}',
        'Haptic,Last Used,${summary['haptic']['lastUsed'] ?? 'N/A'}',
        '',
        '# Dark Mode',
        'Dark Mode,Enabled,${summary['darkMode']['enabled']}',
        'Dark Mode,Toggle Count,${summary['darkMode']['toggleCount']}',
        'Dark Mode,First Enabled,${summary['darkMode']['firstEnabled'] ?? 'N/A'}',
        '',
        '# Animations',
        'Animations,Frame Drops,${summary['animations']['frameDrops']}',
        'Animations,Average Duration (ms),${summary['animations']['avgDuration']}',
        '',
        '# Accessibility',
        'Accessibility,Screen Reader Used,${summary['accessibility']['screenReaderUsed']}',
        'Accessibility,Semantics Interactions,${summary['accessibility']['semanticsInteractions']}',
        '',
        '# Sessions',
        'Sessions,Total Sessions,${summary['sessions']['total']}',
        'Sessions,Current Session Start,${summary['sessions']['currentStart'] ?? 'N/A'}',
      ];

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/ux_analytics_$timestamp.csv');

      await file.writeAsString(csvLines.join('\n'));

      if (kDebugMode) {
        print('✅ Analytics exported to CSV: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exporting CSV: $e');
      }
      return null;
    }
  }

  /// Export analytics as human-readable text report
  static Future<String?> exportAsTextReport() async {
    try {
      final summary = await UxAnalytics.getAnalyticsSummary();
      final now = DateTime.now();

      final reportLines = <String>[
        '═══════════════════════════════════════════',
        '          📊 UX ANALYTICS REPORT           ',
        '═══════════════════════════════════════════',
        '',
        'Generated: ${_formatDateTime(now)}',
        'App: Benaa Offline',
        '',
        '───────────────────────────────────────────',
        '🎯 HAPTIC FEEDBACK METRICS',
        '───────────────────────────────────────────',
        'Total Usage Count:     ${summary['haptic']['usageCount']}',
        'Times Disabled:        ${summary['haptic']['disabledCount']}',
        'Last Used:             ${summary['haptic']['lastUsed'] ?? 'Never'}',
        '',
        '───────────────────────────────────────────',
        '🌙 DARK MODE METRICS',
        '───────────────────────────────────────────',
        'Currently Enabled:     ${summary['darkMode']['enabled'] ? 'Yes' : 'No'}',
        'Toggle Count:          ${summary['darkMode']['toggleCount']}',
        'First Enabled:         ${summary['darkMode']['firstEnabled'] ?? 'Never'}',
        '',
        '───────────────────────────────────────────',
        '🎨 ANIMATION PERFORMANCE',
        '───────────────────────────────────────────',
        'Frame Drops Detected:  ${summary['animations']['frameDrops']}',
        'Average Duration:      ${summary['animations']['avgDuration']}ms',
        'Performance Rating:    ${_getPerformanceRating(summary['animations']['frameDrops'], summary['animations']['avgDuration'])}',
        '',
        '───────────────────────────────────────────',
        '♿ ACCESSIBILITY FEATURES',
        '───────────────────────────────────────────',
        'Screen Reader:         ${summary['accessibility']['screenReaderUsed'] ? 'Active' : 'Not Used'}',
        'Semantics Interactions: ${summary['accessibility']['semanticsInteractions']}',
        '',
        '───────────────────────────────────────────',
        '📈 SESSION STATISTICS',
        '───────────────────────────────────────────',
        'Total Sessions:        ${summary['sessions']['total']}',
        'Current Session:       ${summary['sessions']['currentStart'] ?? 'Not Started'}',
        '',
        '═══════════════════════════════════════════',
        '              END OF REPORT                ',
        '═══════════════════════════════════════════',
      ];

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/ux_analytics_report_$timestamp.txt');

      await file.writeAsString(reportLines.join('\n'));

      if (kDebugMode) {
        print('✅ Analytics exported to TXT: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exporting text report: $e');
      }
      return null;
    }
  }

  /// Share analytics via system share dialog
  static Future<void> shareAnalytics({String format = 'json'}) async {
    try {
      String? filePath;
      String mimeType;

      switch (format) {
        case 'csv':
          filePath = await exportAsCsv();
          mimeType = 'text/csv';
          break;
        case 'txt':
          filePath = await exportAsTextReport();
          mimeType = 'text/plain';
          break;
        case 'json':
        default:
          filePath = await exportAsJson();
          mimeType = 'application/json';
          break;
      }

      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: mimeType)],
          subject: 'UX Analytics Report - Benaa Offline',
          text: 'تقرير إحصائيات UX للتطبيق',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sharing analytics: $e');
      }
    }
  }

  /// Get performance rating based on metrics
  static String _getPerformanceRating(int frameDrops, int avgDuration) {
    if (frameDrops == 0 && avgDuration < 200) return '⭐⭐⭐⭐⭐ Excellent';
    if (frameDrops < 5 && avgDuration < 250) return '⭐⭐⭐⭐ Good';
    if (frameDrops < 10 && avgDuration < 300) return '⭐⭐⭐ Fair';
    if (frameDrops < 20 && avgDuration < 350) return '⭐⭐ Needs Improvement';
    return '⭐ Poor';
  }

  /// Format DateTime in readable format
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  /// Generate weekly summary comparison
  static Future<Map<String, dynamic>> getWeeklySummary() async {
    // This would compare current week vs previous week
    // For now, returning current summary
    return await UxAnalytics.getAnalyticsSummary();
  }

  /// Generate insights based on analytics data
  static Future<List<String>> generateInsights() async {
    final summary = await UxAnalytics.getAnalyticsSummary();
    final insights = <String>[];

    // Haptic insights
    final hapticUsage = summary['haptic']['usageCount'] as int;
    final hapticDisabled = summary['haptic']['disabledCount'] as int;
    if (hapticUsage > 100) {
      insights.add('🎯 Haptic feedback is actively used ($hapticUsage times)');
    }
    if (hapticDisabled > 0) {
      insights.add('⚠️ Users disabled haptic $hapticDisabled times - consider making it less intrusive');
    }

    // Dark mode insights
    final darkModeEnabled = summary['darkMode']['enabled'] as bool;
    final darkModeToggles = summary['darkMode']['toggleCount'] as int;
    if (darkModeEnabled) {
      insights.add('🌙 User prefers Dark Mode');
    }
    if (darkModeToggles > 5) {
      insights.add('🔄 User frequently switches themes ($darkModeToggles times)');
    }

    // Animation insights
    final frameDrops = summary['animations']['frameDrops'] as int;
    final avgDuration = summary['animations']['avgDuration'] as int;
    if (frameDrops > 10) {
      insights.add('⚠️ High frame drops detected ($frameDrops) - animation performance needs optimization');
    }
    if (avgDuration > 300) {
      insights.add('⚠️ Animations running slow (avg ${avgDuration}ms) - target < 250ms');
    }

    // Accessibility insights
    final screenReader = summary['accessibility']['screenReaderUsed'] as bool;
    final semanticsInt = summary['accessibility']['semanticsInteractions'] as int;
    if (screenReader) {
      insights.add('♿ Screen reader detected - accessibility features are being used');
    }
    if (semanticsInt > 50) {
      insights.add('✅ High accessibility engagement ($semanticsInt interactions)');
    }

    // Session insights
    final sessions = summary['sessions']['total'] as int;
    if (sessions > 100) {
      insights.add('🎉 Active user - $sessions sessions recorded');
    }

    if (insights.isEmpty) {
      insights.add('📊 Not enough data yet - keep using the app!');
    }

    return insights;
  }
}
