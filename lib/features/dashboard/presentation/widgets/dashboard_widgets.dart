/// Dashboard Barrel Export - تسهيل الاستيراد
///
/// بدلاً من:
/// ```dart
/// import '../widgets/core/section_title.dart';
/// import '../widgets/core/dashboard_card.dart';
/// import '../widgets/core/collapsible_section.dart';
/// ```
///
/// استخدم:
/// ```dart
/// import '../widgets/dashboard_widgets.dart';
/// ```
library;

// Core Widgets
export 'core/section_title.dart';
export 'core/collapsible_section.dart';
export 'core/dashboard_card.dart';

// Banners
export 'banners/offline_banner.dart';
export 'dashboard_operational_status_strip.dart';

// Phase 3 Cards
export 'dashboard_todays_work_card.dart';
export 'dashboard_sync_health_card.dart';

// Loading
export 'loading/dashboard_skeleton.dart';

// Existing Widgets
export 'quick_actions.dart';
export 'activities_section.dart';
export 'dashboard_charts.dart';
export 'urgent_cases_section.dart';
export 'geographic_distribution_section.dart';
export 'daily_performance_section.dart';
export 'dashboard_summary_widget.dart';
export 'advanced_filters_widget.dart';
export 'statistics_section.dart';
export 'trend_indicator.dart';
