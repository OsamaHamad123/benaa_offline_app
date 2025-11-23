/// 📦 Widgets Index - V2 Form Helpers
///
/// Central export file for all form helper widgets
/// Import this file to access all widgets at once

// ============================================================================
// 🎯 Core Form Widgets
// ============================================================================
export 'form_tabs_4_merged.dart';
export 'bottom_navigation_buttons.dart';
export 'unified_progress_card.dart';

// ============================================================================
// 💾 Draft & Save Widgets
// ============================================================================
export 'draft_save_dialog.dart';
export 'draft_widgets.dart';
export 'auto_save_indicator.dart';
export 'smart_auto_save_indicator.dart';

// ============================================================================
// ⌨️ Keyboard & Shortcuts
// ============================================================================
export 'keyboard_shortcuts.dart' hide FormKeyboardShortcuts;
export 'keyboard_shortcuts_handler.dart';
export 'keyboard_shortcuts_help.dart';

// ============================================================================
// 📊 Progress & Statistics
// ============================================================================
export 'form_completion_progress.dart';
export 'form_statistics_dashboard.dart';
export 'enhanced_progress_indicator.dart';

// ============================================================================
// 📋 Review & Finalization
// ============================================================================
export 'final_review_sheet.dart';
export 'quick_review_sheet.dart';

// ============================================================================
// 🔍 Search & Navigation
// ============================================================================
export 'form_search_dialog.dart';
export 'tab_navigation_bar.dart';
export 'tab_navigation_buttons.dart';
export 'quick_actions.dart';
export 'quick_actions_fab.dart';
export 'form_fab_menu.dart';

// ============================================================================
// 🎨 Enhanced UI Components
// ============================================================================
export 'enhanced_ui_components.dart';
export 'enhanced_section_widgets.dart';
export 'enhanced_snackbar.dart';
export 'material3_components.dart';

// ============================================================================
// 🎭 Animated Widgets
// ============================================================================
export 'animated_widgets.dart';
export 'animated_tab_transition.dart';

// ============================================================================
// 📱 Mobile Optimized
// ============================================================================
export 'mobile_optimized_inputs.dart';
export 'large_touch_inputs.dart';
export 'media_capture_widgets.dart';

// ============================================================================
// 🌐 Offline & Field Work
// ============================================================================
export 'offline_mode_widgets.dart';
export 'field_work_widgets.dart';
export 'device_monitoring_widgets.dart';

// ============================================================================
// 🧠 Smart Widgets
// ============================================================================
export 'smart_widgets.dart' hide StatusBadge;
export 'form_helper_widgets.dart';

// ============================================================================
// ✅ Validation Widgets
// ============================================================================
export 'validation_widgets.dart';

// ============================================================================
// 🎓 Help & Tutorial
// ============================================================================
export 'help_widgets.dart';

// ============================================================================
// 🔧 Utility Widgets
// ============================================================================
export 'utility_widgets.dart'
    hide LoadingOverlay, EmptyStateWidget, SkeletonLoader;
export 'loading_overlay.dart'; // Use this LoadingOverlay (simpler version)
export 'empty_state_widget.dart'; // Use this EmptyStateWidget
export 'skeleton_loader.dart'; // Use this SkeletonLoader

// ============================================================================
// 📝 Form Tabs (Legacy)
// ============================================================================
export 'form_tabs.dart';

// ============================================================================
// 📚 Usage Examples:
// ============================================================================
//
// Instead of importing individual widgets:
// import 'v2_form_helpers/widgets/draft_save_dialog.dart';
// import 'v2_form_helpers/widgets/keyboard_shortcuts_help.dart';
// import 'v2_form_helpers/widgets/unified_progress_card.dart';
// ... and so on
//
// Just import this index file:
// import 'v2_form_helpers/widgets/widgets_index.dart';
//
// And use all widgets directly:
// - showDraftSaveDialog(context)
// - showKeyboardShortcutsHelp(context)
// - UnifiedProgressCard(...)
// - ValidationIndicator(...)
// - LoadingOverlay(...)
// - etc.
//
// ============================================================================
