import 'dart:ui';
import 'dart:developer' as developer;

import 'package:benaa_offline_app/core/widgets/responsive_dialog.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/civil_registry_provider.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/beneficiary_activity_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/errors/user_friendly_error.dart';
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart'; // 📱 Responsive Bottom Sheet
import '../../../../core/providers/providers.dart'; // 🔌 Core Providers
import '../../../../core/sync/presentation/providers/sync_providers.dart' as sync_providers;

import '../providers/beneficiary_form_provider.dart';
import '../providers/beneficiary_dependencies.dart' hide databaseProvider; // Hide conflicting provider
import '../widgets/v2/v2_widgets.dart';
import '../../domain/entities/beneficiary.dart';

// Helper Classes
import 'v2_form_helpers/form_controllers.dart';
import 'v2_form_helpers/form_data_handler.dart';
import 'v2_form_helpers/save_operations_helper.dart';
import 'v2_form_helpers/family_save_helper.dart';
import 'v2_form_helpers/form_constants.dart';
import 'v2_form_helpers/form_history.dart';
import 'v2_form_helpers/draft_manager.dart'; // 💾 Draft Manager
import 'v2_form_helpers/form_bootstrap_controller.dart';
import 'v2_form_helpers/draft_save_coordinator.dart';
import 'v2_form_helpers/form_save_coordinator.dart';
import 'v2_form_helpers/draft_load_coordinator.dart';
import 'v2_form_helpers/beneficiary_delete_coordinator.dart';
import 'v2_form_helpers/form_flow_tracer.dart';
import 'v2_form_helpers/form_feedback_coordinator.dart';
import 'v2_form_helpers/form_open_benchmark.dart';
import 'v2_form_helpers/form_flow_metrics_collector.dart';
import 'v2_form_helpers/auto_save_throttle_guard.dart';
import 'v2_form_helpers/form_controller_reset_helper.dart';
import 'v2_form_helpers/form_taxonomy_bulk_normalizer.dart';
import 'v2_form_helpers/form_initialization_helper.dart';
import 'v2_form_helpers/form_save_flow_helper.dart';
import 'v2_form_helpers/form_taxonomy_coverage_helper.dart';
import 'v2_form_helpers/form_save_guard_helper.dart';
import 'v2_form_helpers/form_delete_flow_helper.dart';
import 'v2_form_helpers/form_taxonomy_sync_helper.dart';
import 'v2_form_helpers/form_auto_save_helper.dart';
import 'v2_form_helpers/form_draft_load_flow_helper.dart';
import 'v2_form_helpers/form_validation_error_helper.dart';
import 'v2_form_helpers/form_draft_save_flow_helper.dart';
import 'v2_form_helpers/form_drafts_list_helper.dart';
import 'v2_form_helpers/form_save_outcome_helper.dart';
import 'v2_form_helpers/form_civil_registry_fill_helper.dart';
import 'v2_form_helpers/personal_profile_validator.dart';
import 'v2_form_helpers/smart_helpers.dart';
import '../../domain/entities/guardian_bank_account.dart';

// Widgets
import 'v2_form_helpers/widgets/loading_overlay.dart' as local;
import 'v2_form_helpers/widgets/skeleton_loader.dart'; // 💀 Skeleton screens
import 'v2_form_helpers/widgets/keyboard_shortcuts_handler.dart';
import 'v2_form_helpers/widgets/final_review_sheet.dart'; // 📋 Final Review
import 'v2_form_helpers/widgets/draft_save_dialog.dart'; // 💾 Draft Save
import 'v2_form_helpers/widgets/keyboard_shortcuts_help.dart'; // ⌨️ Shortcuts Help
import 'v2_form_helpers/widgets/help_widgets.dart'; // 🎓 Help Widgets
import 'v2_form_helpers/widgets/form_page_widgets.dart'; // 📦 Extracted Form Widgets

// 🚀 Performance-optimized widgets
import 'v2_form_helpers/widgets/form_error_banner_widget.dart';
import 'v2_form_helpers/widgets/form_content_widget.dart';
import 'v2_form_helpers/widgets/form_bottom_nav_widget.dart';

// 🚀 Phase 3 - Advanced UX Features
import 'v2_form_helpers/widgets/field_dependency_system.dart'; // 🔗 Field Dependencies
import 'v2_form_helpers/widgets/smart_field_hints.dart'; // 💡 Smart Hints
// Disabled for performance: import 'v2_form_helpers/widgets/form_progress_tracker.dart';
import 'v2_form_helpers/utils/animation_helpers.dart'; // 🎬 Animation helpers

// ✨ NEW: Extracted Form Components (Phase 1.3)
import '../widgets/form/app_bar/beneficiary_form_app_bar.dart';
import '../widgets/form/statistics/completion_stats_widget.dart';
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../../taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import '../../../taxonomies/presentation/providers/taxonomy_providers.dart' as taxonomy_ui;

/// 🎨 Beneficiary Form Page V3 - Ultra Modern & Enhanced
///
/// ✨ New Features:
/// ✅ 4 Tabs (merged from 7) - Better UX
/// ✅ Material 3 Components
/// ✅ Keyboard Shortcuts (Ctrl+S, Ctrl+Tab, etc.)
/// ✅ Smart Auto-Save Indicator
/// ✅ Quick Actions FAB
/// ✅ Undo/Redo Support
/// ✅ Enhanced Validation Messages
/// ✅ Better Performance
/// ✅ Auto-fill from Civil Registry
class BeneficiaryFormPageV3 extends ConsumerStatefulWidget {
  final String? beneficiaryId;
  final Map<String, dynamic>? civilRegistryData; // ✨ بيانات السجل المدني

  const BeneficiaryFormPageV3({
    super.key,
    this.beneficiaryId,
    this.civilRegistryData,
  });

  @override
  ConsumerState<BeneficiaryFormPageV3> createState() => _BeneficiaryFormPageV3State();
}

class _BeneficiaryFormPageV3State extends ConsumerState<BeneficiaryFormPageV3> with SingleTickerProviderStateMixin {
  static const bool _enableFormTour = false;
  static const bool _enableRuntimePerfTracing = false;
  static const bool _enableOnScreenPerfDiagnostics = false;

  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late final BeneficiaryFormControllers _controllers;
  late final FormHistory<FormStateSnapshot> _formHistory;

  // ⚡ Performance: استخدام ValueNotifier بدلاً من setState
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isDeletingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isTaxonomyCoverageLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<List<TaxonomyGroup>> _missingTaxonomyGroupsNotifier = ValueNotifier(const <TaxonomyGroup>[]);
  final ValueNotifier<List<String>> _unknownTaxonomyGroupsNotifier = ValueNotifier(const <String>[]);
  bool _isSavingLocked = false;

  final ValueNotifier<DateTime?> _lastSavedNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _lastAutoSavedNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _hasUnsavedChangesNotifier = ValueNotifier(false);

  // Setters للكتابة السهلة (Getters غير مطلوبة لأننا نستخدم ValueListenableBuilder)
  bool get _isSaving => _isSavingNotifier.value;
  set _isSaving(bool value) => _isSavingNotifier.value = value;
  bool get _isDeleting => _isDeletingNotifier.value;
  set _isDeleting(bool value) => _isDeletingNotifier.value = value;
  bool get _isLoading => _isLoadingNotifier.value;
  set _isLoading(bool value) => _isLoadingNotifier.value = value;

  set _lastSaved(DateTime? value) => _lastSavedNotifier.value = value;
  set _lastAutoSaved(DateTime? value) => _lastAutoSavedNotifier.value = value;

  set _hasUnsavedChanges(bool value) => _hasUnsavedChangesNotifier.value = value;

  // 💾 Auto-draft ID - ثابت لتجنب إنشاء مسودات متكررة
  String? _autoSaveDraftId;
  final BeneficiaryFormBootstrapController _bootstrapController = const BeneficiaryFormBootstrapController();
  final DraftSaveCoordinator _draftSaveCoordinator = const DraftSaveCoordinator();
  final FormSaveCoordinator _formSaveCoordinator = const FormSaveCoordinator();
  final DraftLoadCoordinator _draftLoadCoordinator = const DraftLoadCoordinator();
  final BeneficiaryDeleteCoordinator _beneficiaryDeleteCoordinator = const BeneficiaryDeleteCoordinator();
  final FormFeedbackCoordinator _feedbackCoordinator = const FormFeedbackCoordinator();
  final FormOpenBenchmark _openBenchmark = FormOpenBenchmark();
  final FormFlowMetricsCollector _flowMetricsCollector = FormFlowMetricsCollector();
  final AutoSaveThrottleGuard _autoSaveThrottleGuard = AutoSaveThrottleGuard();

  // 🆕 New features state
  final ValueNotifier<bool> _showStatisticsNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showProgressCardNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showTourGuideNotifier = ValueNotifier(false);
  final ValueNotifier<int> _statisticsVersionNotifier = ValueNotifier(0);
  bool get _showStatistics => _showStatisticsNotifier.value;
  set _showStatistics(bool value) => _showStatisticsNotifier.value = value;
  bool get _showProgressCard => _showProgressCardNotifier.value;
  set _showProgressCard(bool value) => _showProgressCardNotifier.value = value;
  set _showTourGuide(bool value) => _showTourGuideNotifier.value = value;
  final bool _showFieldHelpers = false; // ✅ مخفية افتراضياً - تبسيط
  // ⚠️ Search moved to FormContentWidget local state for performance
  bool _taxonomyNormalizationInFlight = false;
  bool _taxonomyNormalizationQueued = false;

  final FocusNode _firstFieldFocusNode = FocusNode();

  // 🔄 Debouncing for auto-save
  late final Debouncer _autoSaveDebouncer; // ✅ Debouncer for auto-save
  // Timer to check and offer auto-saved drafts (cancelable)
  Timer? _offerAutoSavedDraftsTimer;
  // Timer to show first-time user tour (cancelable)
  Timer? _tourShowTimer;
  Timer? _statisticsRefreshTimer;

  // 🚀 Phase 3 - Advanced UX Features
  FieldDependencyController? _dependencyController;
  final Map<String, SmartHint> _fieldHints = {}; // Smart hints for fields

  // 🧪 Runtime perf tracing (debug only)
  int _totalFramesObserved = 0;
  int _slowBuildFrames = 0;
  int _slowRasterFrames = 0;
  int _verySlowFrames = 0;
  Duration _worstTotalFrame = Duration.zero;
  bool _previousCivilLookupDiagnosticsEnabled = false;
  static const Duration _watchdogTick = Duration(milliseconds: 450);
  static const Duration _watchdogLagThreshold = Duration(milliseconds: 180);
  Timer? _uiWatchdogTimer;
  DateTime? _uiWatchdogLastTick;
  int _uiLagBurstCount = 0;
  bool _uiEmergencyMode = false;
  bool _didOfferAutoRestore = false;
  int _lastSettledTabIndex = 0;
  bool _progressCardDefaultApplied = false;
  final ValueNotifier<int> _perfOverlayVersionNotifier = ValueNotifier(0);
  final Map<String, _PerfAggregate> _perfAggregates = <String, _PerfAggregate>{};
  bool _showPerfOverlay = true;
  bool _isTabTransitionLocked = false;

  @override
  void initState() {
    super.initState();
    _openBenchmark.start();

    // ✅ Initialize Debouncer for auto-save (2 seconds)
    _autoSaveDebouncer = Debouncer(delay: const Duration(seconds: 2));

    _controllers = BeneficiaryFormControllers(
      onAutoSave: _performAutoSave,
      onFieldEdited: _onFormChanged,
    );
    _formHistory = FormHistory<FormStateSnapshot>();
    _tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: this,
    );
    _lastSettledTabIndex = _tabController.index;
    _tabController.addListener(_onTabNavigationSettled);

    // 🚀 Initialize Phase 3 features
    if (_showFieldHelpers) {
      _dependencyController = FieldDependencyController();
      _setupFieldDependencies();
    }
    _setupSmartHints();
    _startUiWatchdog();

    _setTaxonomySyncSuspended(true);

    if (kDebugMode && (_enableRuntimePerfTracing || _enableOnScreenPerfDiagnostics)) {
      WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    }

    if (kDebugMode && _enableRuntimePerfTracing) {
      _previousCivilLookupDiagnosticsEnabled = CivilRegistryLookupDiagnostics.enabled;
      CivilRegistryLookupDiagnostics.enabled = true;
    }

    // ⚠️ DISABLED for performance - causes setState on every keystroke
    // Listen to controller changes for history
    // _controllers.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
      _checkFirstTimeUser();
      _openBenchmark.stopAndReport();

      if (!_progressCardDefaultApplied && mounted) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        _showProgressCard = !isMobile;
        _progressCardDefaultApplied = true;
      }
    });
  }

  void _startUiWatchdog() {
    _uiWatchdogLastTick = DateTime.now();
    _uiWatchdogTimer?.cancel();
    _uiWatchdogTimer = Timer.periodic(_watchdogTick, (_) {
      if (!mounted) return;

      final now = DateTime.now();
      final previous = _uiWatchdogLastTick;
      _uiWatchdogLastTick = now;
      if (previous == null) return;

      final expected = previous.add(_watchdogTick);
      final lag = now.difference(expected);

      if (lag > _watchdogLagThreshold) {
        _uiLagBurstCount += 1;
        _recordPerfSample('ui.mainThreadLag', lag.inMilliseconds);
      } else if (_uiLagBurstCount > 0) {
        _uiLagBurstCount -= 1;
      }

      final shouldEnableEmergency = _uiLagBurstCount >= 3;
      if (shouldEnableEmergency == _uiEmergencyMode) {
        return;
      }

      _uiEmergencyMode = shouldEnableEmergency;
      _recordPerfSample('ui.emergencyToggle', shouldEnableEmergency ? 1 : 0);
      Future.microtask(() {
        if (!mounted) return;
        ref.read(taxonomy_ui.taxonomyAutoSyncEmergencyModeProvider.notifier).state = shouldEnableEmergency;
      });
    });
  }

  void _recordPerfSample(String key, int durationMs) {
    if (durationMs < 0) return;

    final aggregate = _perfAggregates.putIfAbsent(key, _PerfAggregate.new);
    aggregate.add(durationMs);
    _perfOverlayVersionNotifier.value = _perfOverlayVersionNotifier.value + 1;
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _totalFramesObserved++;

      final buildDuration = timing.buildDuration;
      final rasterDuration = timing.rasterDuration;
      final totalDuration = timing.totalSpan;

      if (buildDuration > const Duration(milliseconds: 16)) {
        _slowBuildFrames++;
      }
      if (rasterDuration > const Duration(milliseconds: 16)) {
        _slowRasterFrames++;
      }
      if (totalDuration > const Duration(milliseconds: 50)) {
        _verySlowFrames++;
      }

      if (totalDuration > _worstTotalFrame) {
        _worstTotalFrame = totalDuration;
      }
    }

    if (_enableOnScreenPerfDiagnostics && _showPerfOverlay && _totalFramesObserved % 10 == 0) {
      _perfOverlayVersionNotifier.value = _perfOverlayVersionNotifier.value + 1;
    }
  }

  void _setTaxonomySyncSuspended(bool suspended) {
    Future.microtask(() {
      if (!mounted) return;
      ref.read(taxonomy_ui.taxonomyAutoSyncSuspendedProvider.notifier).state = suspended;
    });
  }

  /// 🎓 Check if first time user and show tour
  void _checkFirstTimeUser() async {
    if (!_enableFormTour) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final shouldShowTour = await _bootstrapController.shouldShowTour(
      tourEnabled: _enableFormTour,
      prefs: prefs,
    );

    if (shouldShowTour && mounted) {
      // Show tour after a short delay (cancelable timer)
      _tourShowTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          _showTourGuide = true;
        }
      });
    }
  }

  /// 📊 Toggle Statistics Dashboard
  void _toggleStatistics() {
    _showStatistics = !_showStatistics;
    if (_showStatistics) {
      _statisticsVersionNotifier.value = _statisticsVersionNotifier.value + 1;
    }
  }

  void _toggleProgressCard() {
    _showProgressCard = !_showProgressCard;
    if (!mounted) return;
    final message = _showProgressCard ? 'تم إظهار بطاقة تقدّم النموذج' : 'تم إخفاء بطاقة تقدّم النموذج';
    EnhancedSnackbar.showInfo(context, message: message);
  }

  /// ⚠️ Search functionality moved to FormContentWidget for performance
  /// Prevents parent setState on every keystroke

  void _onFormChanged() {
    _hasUnsavedChanges = true;
    if (_showStatistics) {
      _statisticsRefreshTimer?.cancel();
      _statisticsRefreshTimer = Timer(const Duration(milliseconds: 120), () {
        if (!mounted || !_showStatistics) return;
        _statisticsVersionNotifier.value = _statisticsVersionNotifier.value + 1;
      });
    }
  }

  /// 📊 Calculate form progress (filled fields)
  int _calculateFilledFields() {
    int filled = 0;

    // Required text fields
    if (_controllers.firstNameController.text.isNotEmpty) filled++;
    if (_controllers.fatherNameController.text.isNotEmpty) filled++;
    if (_controllers.grandfatherNameController.text.isNotEmpty) filled++;
    if (_controllers.lastNameController.text.isNotEmpty) filled++;
    if (_controllers.nationalIdController.text.isNotEmpty) filled++;
    if (_controllers.birthDateController.text.isNotEmpty) filled++;
    if (_controllers.phoneController.text.isNotEmpty) filled++;
    if (_controllers.addressController.text.isNotEmpty) filled++;
    if (_controllers.selectedGender != null) filled++;
    if (_controllers.selectedMaritalStatus != null) filled++;
    if (_controllers.selectedEducationLevel != null) filled++;

    // Optional field: family members
    if (_controllers.livingMembers.isNotEmpty || _controllers.deceasedMembers.isNotEmpty) filled++;

    return filled;
  }

  Map<String, double> _calculateTabCompletions() {
    final stats = FormCompletionCalculator.calculateTabStats(_controllers);
    final tabCompletions = <String, double>{};

    for (int index = 0; index < FormConstants.totalTabs; index++) {
      final title = FormTabs.tabs[index].title;
      if (index == FormConstants.totalTabs - 1) {
        final overall = ((_calculateFilledFields() / 12) * 100).clamp(0.0, 100.0);
        tabCompletions[title] = overall;
        continue;
      }

      final tabStat = stats[index];
      if (tabStat == null) {
        tabCompletions[title] = 0;
      } else {
        tabCompletions[title] = (tabStat.progress * 100).clamp(0.0, 100.0);
      }
    }

    return tabCompletions;
  }

  /// 🔄 Debounced Auto-Save (2 seconds delay)
  /// ✅ Changed to save as draft instead of direct database save
  Future<void> _performAutoSave() async {
    await FormAutoSaveHelper.performAutoSave(
      isSaving: _isSaving,
      isDeleting: _isDeleting,
      isLoading: _isLoading,
      runDebounced: (action) => _autoSaveDebouncer(action),
      isMounted: () => mounted,
      hasChanges: _controllers.firstNameController.text.isNotEmpty || _controllers.nationalIdController.text.isNotEmpty,
      throttleGuard: _autoSaveThrottleGuard,
      autoSaveDraft: _autoSaveDraft,
    );
  }

  /// 💾 Auto-save as draft (silent, no validation required)
  Future<void> _autoSaveDraft() async {
    await FormAutoSaveHelper.autoSaveDraft(
      controllers: _controllers,
      draftSaveCoordinator: _draftSaveCoordinator,
      throttleGuard: _autoSaveThrottleGuard,
      currentTabIndex: _tabController.index,
      beneficiaryId: widget.beneficiaryId,
      currentAutoSaveDraftId: _autoSaveDraftId,
      setAutoSaveDraftId: (value) => _autoSaveDraftId = value,
      onLastSaved: (value) {
        _lastSaved = value;
        _lastAutoSaved = value;
      },
      isMounted: () => mounted,
      flowMetricsCollector: _flowMetricsCollector,
    );
  }

  void _initializeForm() async {
    final initStopwatch = Stopwatch()..start();
    _isLoading = true;
    String? resolvedBeneficiaryId;

    try {
      final initResult = await FormInitializationHelper.initialize(
        routeBeneficiaryId: widget.beneficiaryId,
        civilRegistryData: widget.civilRegistryData,
        resolveLocalBeneficiaryId: (beneficiaryId) async {
          final database = ref.read(databaseProvider);
          return BeneficiaryIdentityResolver.resolveLocalBeneficiaryIdAsString(
            database: database,
            beneficiaryId: beneficiaryId,
          );
        },
        loadBeneficiary: (beneficiaryId) async {
          await ref.read(beneficiaryFormProvider.notifier).loadBeneficiary(beneficiaryId);
        },
        readLoadedBeneficiary: () => ref.read(beneficiaryFormProvider).beneficiary,
        onLoadedBeneficiary: (beneficiary) async {
          _populateControllers(beneficiary);
          await _normalizeAllTaxonomySelections();
        },
        onCreateNew: () => ref.read(beneficiaryFormProvider.notifier).createNew(),
        onClearControllers: _clearAllControllers,
        onScheduleCivilRegistryFill: (data) {
          debugPrint('📋 Civil Registry Data received (keys: ${data.keys.length})');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _fillFromCivilRegistry(data);
              _hasUnsavedChanges = true;
            }
          });
        },
        onScheduleFirstFieldFocus: () {
          _offerAutoSavedDraftsTimer = Timer(
            const Duration(milliseconds: 350),
            () {
              if (mounted) {
                _firstFieldFocusNode.requestFocus();
              }
            },
          );
        },
        onRefreshTaxonomyCoverage: () => _refreshTaxonomyCoverage(showSnackBar: false),
        onSaveToHistory: _saveToHistory,
      );

      resolvedBeneficiaryId = initResult.resolvedBeneficiaryId;

      if (mounted) {
        unawaited(_offerSmartAutoSavedRestore(resolvedBeneficiaryId: resolvedBeneficiaryId));
      }
    } catch (e, stackTrace) {
      _logFormOpenFailure(
        error: e,
        stackTrace: stackTrace,
        contextData: {
          'routeBeneficiaryId': widget.beneficiaryId,
          'resolvedBeneficiaryId': resolvedBeneficiaryId,
          'hasCivilRegistryData': widget.civilRegistryData != null,
        },
      );
      final message = UserFriendlyError.getMessage(e, stackTrace);
      debugPrint('❌ Form init failed: $message (technical: $e)');
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'تعذر فتح نموذج إضافة المستفيد. حاول مرة أخرى.',
        );
      }
    } finally {
      initStopwatch.stop();
      _recordPerfSample('flow.initializeForm', initStopwatch.elapsedMilliseconds);
      if (mounted) {
        _isLoading = false;
      }
    }
  }

  void _logFormOpenFailure({
    required Object error,
    required StackTrace stackTrace,
    required Map<String, Object?> contextData,
  }) {
    developer.log(
      'Beneficiary form open failed | context=$contextData',
      name: 'BeneficiaryFormOpen',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _refreshTaxonomyCoverage({bool showSnackBar = false}) async {
    if (!mounted) return;

    final stopwatch = Stopwatch()..start();
    _isTaxonomyCoverageLoadingNotifier.value = true;
    final db = ref.read(databaseProvider);

    try {
      final snapshot = await FormTaxonomyCoverageHelper.evaluate(db);
      final missingGroups = snapshot.missingGroups;
      final unknownGroups = snapshot.unknownGroups;

      if (!mounted) return;
      _missingTaxonomyGroupsNotifier.value = missingGroups;
      _unknownTaxonomyGroupsNotifier.value = unknownGroups;

      if (unknownGroups.isNotEmpty) {
        developer.log(
          'taxonomy coverage contains unknown groups: ${unknownGroups.join(', ')}',
          name: 'BeneficiaryFormTaxonomyCoverage',
        );
      }

      if (showSnackBar && missingGroups.isNotEmpty) {
        EnhancedSnackbar.showWarning(
          context,
          message: FormTaxonomyCoverageHelper.formatMissingGroupsMessage(missingGroups),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'taxonomy coverage check failed',
        name: 'BeneficiaryFormTaxonomyCoverage',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      stopwatch.stop();
      _recordPerfSample('db.taxonomyCoverage', stopwatch.elapsedMilliseconds);
      if (mounted) {
        _isTaxonomyCoverageLoadingNotifier.value = false;
      }
    }
  }

  Future<void> _syncTaxonomiesFromCoverageCard() async {
    if (!mounted) return;

    final stopwatch = Stopwatch()..start();
    try {
      await ref.read(sync_providers.syncControllerProvider.notifier).deltaSync('taxonomies');
      if (!mounted) return;

      final syncState = ref.read(sync_providers.syncControllerProvider);
      if (syncState.isError) {
        final message = FormTaxonomySyncHelper.resolveFailureMessage(syncState.error);
        EnhancedSnackbar.showError(context, message: message);
      } else {
        EnhancedSnackbar.showSuccess(context, message: FormTaxonomySyncHelper.successMessage);
      }
    } catch (error, stackTrace) {
      developer.log(
        'taxonomy sync from coverage card failed',
        name: 'BeneficiaryFormTaxonomyCoverage',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: FormTaxonomySyncHelper.exceptionFailureMessage);
      }
    } finally {
      stopwatch.stop();
      _recordPerfSample('sync.taxonomiesDelta', stopwatch.elapsedMilliseconds);
      if (mounted) {
        unawaited(_refreshTaxonomyCoverage(showSnackBar: false));
      }
    }
  }

  void _clearAllControllers() {
    FormControllerResetHelper.reset(_controllers);

    // ✅ Safe reset - don't crash if civil registry is not available
    try {
      ref.read(civilRegistryProvider.notifier).reset();
    } catch (e) {
      // Silently ignore - civil registry is optional
      debugPrint('⚠️ Civil registry not available: $e');
    }
  }

  void _populateControllers(Beneficiary beneficiary) {
    BeneficiaryFormDataHandler.populateControllers(
      _controllers,
      beneficiary,
      (fn) => fn(),
    );
    _loadFamilyMembers(beneficiary.id);
    unawaited(_loadGuardianBankAccount(beneficiary.id));
  }

  Future<void> _loadGuardianBankAccount(String beneficiaryId) async {
    final stopwatch = Stopwatch()..start();
    try {
      final useCase = ref.read(loadGuardianBankAccountUseCaseProvider);
      final account = await useCase.execute(beneficiaryId);
      if (account == null) return;

      _controllers.bankNameIdController.text = account.bankNameId?.toString() ?? '';
      _controllers.bankNameLabelController.text = account.bankNameLabel ?? '';
      _controllers.ibanUsdController.text = account.ibanUsd ?? '';
      _controllers.ibanShekelController.text = account.ibanShekel ?? '';
      _controllers.bankRepresentativeIdController.text = account.representativeIdNumber ?? '';
      _controllers.bankGuardianNameController.text = account.guardianName ?? '';
      _controllers.bankRepresentativePhoneController.text = account.representativePhone ?? '';
      _controllers.bankOwnerIdentityController.text = account.ownerIdentityNumber ?? '';
      _controllers.bankCheckAccountApproved = account.checkAccountApproved;
    } finally {
      stopwatch.stop();
      _recordPerfSample('db.loadGuardianBankAccount', stopwatch.elapsedMilliseconds);
    }
  }

  Future<void> _normalizeAllTaxonomySelections() async {
    if (!mounted) return;

    if (_taxonomyNormalizationInFlight) {
      _taxonomyNormalizationQueued = true;
      return;
    }

    _taxonomyNormalizationInFlight = true;
    try {
      do {
        _taxonomyNormalizationQueued = false;
        final stopwatch = Stopwatch()..start();

        final taxonomyIndex = await ref.read(bridgeTaxonomiesIndexOnceProvider.future);
        await FormTaxonomyBulkNormalizer.normalizeAll(
          controllers: _controllers,
          taxonomyIndex: taxonomyIndex,
        );

        stopwatch.stop();
        _recordPerfSample('db.normalizeTaxonomySelections', stopwatch.elapsedMilliseconds);
      } while (_taxonomyNormalizationQueued && mounted);
    } finally {
      _taxonomyNormalizationInFlight = false;
    }
  }

  Future<void> _loadFamilyMembers(String beneficiaryId) async {
    final stopwatch = Stopwatch()..start();
    try {
      final familyData = await FamilySaveHelper.loadFamilyMembers(
        database: ref.read(databaseProvider),
        beneficiaryId: beneficiaryId,
      );

      _controllers.updateLivingMembers(familyData.living);
      _controllers.updateDeceasedMembers(familyData.deceased);
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'تعذر تحميل بيانات أفراد العائلة',
        );
      }
    } finally {
      stopwatch.stop();
      _recordPerfSample('db.loadFamilyMembers', stopwatch.elapsedMilliseconds);
    }
  }

  void _saveToHistory(String description) {
    final snapshot = FormStateSnapshot.fromControllers({
      'firstName': _controllers.firstNameController,
      'fatherName': _controllers.fatherNameController,
      'nationalId': _controllers.nationalIdController,
      // Add more as needed
    }, description: description);
    _formHistory.push(snapshot);
  }

  void _handleUndo() {
    final snapshot = _formHistory.undo();
    if (snapshot != null) {
      snapshot.applyTo({
        'firstName': _controllers.firstNameController,
        'fatherName': _controllers.fatherNameController,
        'nationalId': _controllers.nationalIdController,
      });
      HapticFeedback.lightImpact();
      EnhancedSnackbar.showInfo(context, message: 'تم التراجع');
    }
  }

  void _handleRedo() {
    final snapshot = _formHistory.redo();
    if (snapshot != null) {
      snapshot.applyTo({
        'firstName': _controllers.firstNameController,
        'fatherName': _controllers.fatherNameController,
        'nationalId': _controllers.nationalIdController,
      });
      HapticFeedback.lightImpact();
      EnhancedSnackbar.showInfo(context, message: 'تم الإعادة');
    }
  }

  /// 🔗 Setup Field Dependencies (Phase 3)
  void _setupFieldDependencies() {
    final dependencyController = _dependencyController;
    if (dependencyController == null) {
      return;
    }

    // Add common dependency scenarios
    final scenarios = DependencyScenarios.getAllCommonScenarios();
    for (final scenario in scenarios) {
      dependencyController.addDependency(scenario);
    }

    // Listen to text field changes
    _controllers.firstNameController.addListener(() {
      _dependencyController?.updateField(
        'maritalStatus',
        _controllers.selectedMaritalStatus,
      );
    });
  }

  /// 💡 Setup Smart Hints (Phase 3)
  void _setupSmartHints() {
    _fieldHints['nationalId'] = SmartHint.nationalId();
    _fieldHints['phoneNumber'] = SmartHint.phoneNumber();
    _fieldHints['email'] = SmartHint.email();
    _fieldHints['dateOfBirth'] = SmartHint.dateOfBirth();
    _fieldHints['address'] = SmartHint.address();
    _fieldHints['occupation'] = SmartHint.occupation();
    _fieldHints['income'] = SmartHint.income();
    _fieldHints['familyMembers'] = SmartHint.familyMembers();
    _fieldHints['unhcrNumber'] = SmartHint.unhcrNumber();
    _fieldHints['rationCard'] = SmartHint.rationCard();
  }

  /// 📊 Calculate Form Progress (Phase 3) - DISABLED for performance
  // Uncomment if re-enabling Progress Tracker
  /*
  List<FormSection> _calculateFormProgress() {
    return [
      FormSection(
        name: 'المعلومات الشخصية',
        icon: Icons.person,
        requiredFields: 5,
        completedRequiredFields: _countCompletedFields([
          _controllers.firstNameController.text,
          _controllers.fatherNameController.text,
          _controllers.lastNameController.text,
          _controllers.nationalIdController.text,
          _controllers.selectedGender?.toString(),
        ]),
        optionalFields: 3,
        completedOptionalFields: _countCompletedFields([
          _controllers.grandfatherNameController.text,
          _controllers.motherNameController.text,
          _controllers.birthDateController.text,
        ]),
        color: Colors.blue,
      ),
      FormSection(
        name: 'معلومات الاتصال',
        icon: Icons.phone,
        requiredFields: 1,
        completedRequiredFields: _countCompletedFields([
          _controllers.phoneController.text,
        ]),
        optionalFields: 2,
        completedOptionalFields: _countCompletedFields([
          _controllers.altPhoneController.text,
          _controllers.addressController.text,
        ]),
        color: Colors.green,
      ),
      FormSection(
        name: 'الحالة الاجتماعية',
        icon: Icons.family_restroom,
        requiredFields: 2,
        completedRequiredFields: _countCompletedFields([
          _controllers.selectedMaritalStatus?.toString(),
          _controllers.selectedEducationLevel?.toString(),
        ]),
        optionalFields: 1,
        completedOptionalFields: _countCompletedFields([
          _controllers.numberOfDependentsController.text,
        ]),
        color: Colors.purple,
      ),
      FormSection(
        name: 'العائلة',
        icon: Icons.groups,
        requiredFields: 0,
        completedRequiredFields: 0,
        optionalFields: 2,
        completedOptionalFields:
            0, // We'll update this when we have access to family members
        color: Colors.orange,
      ),
    ];
  }

  int _countCompletedFields(List<String?> fields) {
    return fields.where((f) => f != null && f.isNotEmpty).length;
  }
  */

  /// ✨ Fill form from Civil Registry data
  void _fillFromCivilRegistry(Map<String, dynamic> data) {
    try {
      final fillResult = FormCivilRegistryFillHelper.apply(
        controllers: _controllers,
        data: data,
        logger: debugPrint,
      );

      if (mounted && fillResult.hasFilledFields) {
        unawaited(_normalizeAllTaxonomySelections());

        EnhancedSnackbar.showSuccess(
          context,
          message: '✅ تم ملء ${fillResult.filledFieldsCount} حقل من السجل المدني',
        );
      } else if (!fillResult.hasFilledFields) {
        debugPrint('⚠️ No fields were filled - data might be incomplete');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error filling form from civil registry: $e\n$stackTrace');
      if (mounted) {
        EnhancedSnackbar.showError(
          context,
          message: 'حدث خطأ أثناء ملء البيانات',
        );
      }
    }
  }

  /// ⬅️ التالي - الانتقال للتاب التالي (يمين في RTL)
  void _handleNextTab() {
    if (_tabController.indexIsChanging || _isTabTransitionLocked) return;

    final current = _tabController.index;
    if (current >= FormConstants.totalTabs - 1) {
      HapticFeedback.heavyImpact();
      return;
    }

    final target = current + 1;
    _isTabTransitionLocked = true;

    HapticPatterns.selection();
    _tabController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      _isTabTransitionLocked = false;
    });
  }

  /// ➡️ السابق - الرجوع للتاب السابق (يسار في RTL)
  void _handlePreviousTab() {
    if (_tabController.indexIsChanging || _isTabTransitionLocked) return;

    if (_tabController.index > 0) {
      _isTabTransitionLocked = true;
      HapticPatterns.selection();
      _tabController.animateTo(
        _tabController.index - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );

      Future.delayed(const Duration(milliseconds: 240), () {
        if (!mounted) return;
        _isTabTransitionLocked = false;
      });
    }
  }

  int? _firstIncompleteTabIndex() {
    final checks = <int, bool>{
      0: _isPersonalTabComplete(),
      2: _isContactTabComplete(),
      3: _isAttachmentsTabComplete(),
    };

    for (final entry in checks.entries) {
      if (!entry.value) return entry.key;
    }
    return null;
  }

  bool _isPersonalTabComplete() {
    return PersonalProfileValidator.isComplete(_controllers);
  }

  bool _isContactTabComplete() {
    return _controllers.phoneController.text.trim().isNotEmpty;
  }

  bool _isAttachmentsTabComplete() {
    return _controllers.pendingAttachments.isNotEmpty;
  }

  bool _isTextInputFocused() {
    try {
      final focusedNode = FocusManager.instance.primaryFocus;
      if (focusedNode == null) return false;

      final focusedContext = focusedNode.context;
      if (focusedContext == null || !focusedContext.mounted) return false;

      return focusedContext.widget is EditableText;
    } catch (_) {
      return false;
    }
  }

  void _handleHorizontalTabSwipe(DragEndDetails details) {
    if (_isTextInputFocused()) return;

    final velocityX = details.primaryVelocity ?? 0;
    if (velocityX.abs() < 380) return;

    if (velocityX < 0) {
      _handleNextTab();
    } else {
      _handlePreviousTab();
    }
  }

  void _onTabNavigationSettled() {
    if (!mounted || _tabController.indexIsChanging) return;

    _isTabTransitionLocked = false;

    final newIndex = _tabController.index;
    if (newIndex == _lastSettledTabIndex) return;

    final previousIndex = _lastSettledTabIndex;
    _lastSettledTabIndex = newIndex;

    if (_hasUnsavedChangesNotifier.value && !_isSaving && !_isDeleting && !_isLoading) {
      unawaited(_autoSaveDraft());
    }

    final firstIncomplete = _firstIncompleteTabIndex();
    if (firstIncomplete != null && newIndex > firstIncomplete && newIndex > previousIndex) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: Text('لا يزال هناك حقول ناقصة. أول تبويب يحتاج متابعة: ${FormTabs.tabs[firstIncomplete].title}'),
          action: SnackBarAction(
            label: 'اذهب الآن',
            onPressed: () {
              _tabController.animateTo(
                firstIncomplete,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
              );
            },
          ),
        ),
      );
    }
  }

  /// 📋 Show final review before saving
  Future<void> _showFinalReview() async {
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: 'المراجعة النهائية',
        icon: Icons.assignment_turned_in,
        showCloseButton: false, // FinalReviewSheet has its own buttons
        builder: (scrollController) => FinalReviewSheet(
          formControllers: _controllers,
          scrollController: scrollController,
          onConfirm: () => Navigator.pop(context, true),
          onEdit: () => Navigator.pop(context, false),
        ),
      ),
    );

    if (shouldSave == true) {
      await _handleSave();
    }
  }

  /// 💾 Handle Draft Save
  // ignore: unused_element
  Future<void> _handleDraftSave() async {
    await FormDraftSaveFlowHelper.execute(
      showDraftDialog: () => showDraftSaveDialog(context),
      setSaving: (value) => _isSaving = value,
      controllers: _controllers,
      draftSaveCoordinator: _draftSaveCoordinator,
      currentTabIndex: _tabController.index,
      beneficiaryId: widget.beneficiaryId,
      isMounted: () => mounted,
      setLastSaved: (value) => _lastSaved = value,
      setHasUnsavedChanges: (value) => _hasUnsavedChanges = value,
      onSuccess: (draftName) {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
          builder: (context) => Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: FormAnimations.successCheckmark(
                  size: 80.sp,
                ),
              ),
            ),
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context, rootNavigator: true).pop();
        });

        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم حفظ المسودة "$draftName" بنجاح ✓',
        );
        EnhancedSnackbar.showInfo(
          context,
          message: 'يمكنك عرض المسودات المحفوظة من القائمة',
        );
      },
      onError: (message) {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        EnhancedSnackbar.showError(context, message: message);
      },
      logError: debugPrint,
    );
  }

  /// 📋 Show Drafts List
  // ignore: unused_element
  Future<void> _showDraftsList() async {
    try {
      final drafts = await DraftManager.getAllDrafts();
      final draftItems = FormDraftsListHelper.normalizeDrafts(drafts);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ResponsiveBottomSheet(
          title: 'المسودات المحفوظة (${draftItems.length})',
          icon: Icons.drafts,
          child: draftItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64.sp,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد مسودات محفوظة',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: draftItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final draftItem = draftItems[index];
                    final savedAt = draftItem.savedAt;
                    final savedAtLabel = savedAt == null ? 'غير معروف' : _formatDateTime(savedAt);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.description,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          draftItem.draftName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'حُفظت: $savedAtLabel',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => ResponsiveDialog(
                                    title: 'حذف المسودة',
                                    icon: Icons.delete_outline,
                                    iconColor: Theme.of(context).colorScheme.error,
                                    content: const Text(
                                      'هل تريد حذف هذه المسودة؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          false,
                                        ),
                                        child: const Text('إلغاء'),
                                      ),
                                      AnimatedButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          true,
                                        ),
                                        child: FilledButton(
                                          onPressed: null, // handled by AnimatedButton
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            foregroundColor: Theme.of(
                                              context,
                                            ).colorScheme.onError,
                                          ),
                                          child: const Text('حذف'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await DraftManager.deleteDraft(
                                    draftItem.draftId,
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  EnhancedSnackbar.showSuccess(
                                    this.context,
                                    message: 'تم حذف المسودة بنجاح',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await _loadDraft(draftItem.rawDraft);
                        },
                      ),
                    );
                  },
                ),
        ),
      );
    } catch (e, stackTrace) {
      if (mounted) {
        final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
        EnhancedSnackbar.showError(context, message: errorMsg);
        debugPrint('❌ Load drafts error: $e');
      }
    }
  }

  /// 📥 Load Draft
  Future<void> _loadDraft(Map<String, dynamic> draft) async {
    await FormDraftLoadFlowHelper.execute(
      draft: draft,
      controllers: _controllers,
      draftLoadCoordinator: _draftLoadCoordinator,
      normalizeAllTaxonomySelections: _normalizeAllTaxonomySelections,
      setLoading: (value) => _isLoading = value,
      goToTab: (tabIndex) => _tabController.animateTo(tabIndex),
      isMounted: () => mounted,
      setHasUnsavedChanges: (value) => _hasUnsavedChanges = value,
      showSuccess: (message) => _feedbackCoordinator.showSuccess(context, message),
      showError: (message) => _feedbackCoordinator.showError(context, message),
      logError: debugPrint,
      flowMetricsCollector: _flowMetricsCollector,
    );

    final savedAtRaw = draft['savedAt']?.toString();
    final savedAt = savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw);
    if (savedAt != null) {
      _lastAutoSaved = savedAt;
      _lastSaved = savedAt;
    }
  }

  Future<void> _offerSmartAutoSavedRestore({required String? resolvedBeneficiaryId}) async {
    if (!mounted || _didOfferAutoRestore) return;

    _didOfferAutoRestore = true;

    try {
      final autoDrafts = await DraftManager.getAllDrafts(
        limit: 25,
        autoSavedOnly: true,
      );

      if (!mounted || autoDrafts.isEmpty) return;

      Map<String, dynamic>? selectedDraft;

      if (resolvedBeneficiaryId != null && resolvedBeneficiaryId.isNotEmpty) {
        for (final draft in autoDrafts) {
          if ((draft['beneficiaryId']?.toString() ?? '') == resolvedBeneficiaryId) {
            selectedDraft = draft;
            break;
          }
        }
      }

      selectedDraft ??= autoDrafts.firstWhere(
        (draft) => (draft['beneficiaryId'] == null || (draft['beneficiaryId']?.toString() ?? '').isEmpty),
        orElse: () => autoDrafts.first,
      );

      final selectedSavedAt = DateTime.tryParse((selectedDraft['savedAt'] ?? '').toString());
      final selectedName = (selectedDraft['name'] ?? 'مسودة تلقائية').toString();
      final selectedSavedAtLabel = selectedSavedAt == null ? 'غير معروف' : _formatDateTime(selectedSavedAt);

      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.restore_page_rounded, color: Theme.of(context).colorScheme.primary),
          title: const Text('استعادة آخر حفظ تلقائي؟'),
          content: Text('تم العثور على "$selectedName" (آخر تحديث: $selectedSavedAtLabel).\nهل تريد استعادتها؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('تجاهل'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.restore_rounded),
              label: const Text('استعادة'),
            ),
          ],
        ),
      );

      if (shouldRestore == true && mounted) {
        await _loadDraft(selectedDraft);
      }
    } catch (e, stackTrace) {
      developer.log(
        'auto-restore offer failed',
        name: 'BeneficiaryFormAutoRestore',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 📅 Format DateTime
  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return '${dt.year}/${dt.month}/${dt.day}';
  }

  Widget _buildAutoSaveIndicator(BuildContext context, DateTime? lastAutoSavedAt) {
    if (lastAutoSavedAt == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done_rounded,
            size: 16.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'آخر حفظ تلقائي: ${_formatDateTime(lastAutoSavedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _uiWatchdogTimer?.cancel();
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      Future.microtask(() {
        container.read(taxonomy_ui.taxonomyAutoSyncSuspendedProvider.notifier).state = false;
        container.read(taxonomy_ui.taxonomyAutoSyncEmergencyModeProvider.notifier).state = false;
      });
    } catch (_) {
      // no-op in rare teardown edge-cases
    }

    _autoSaveDebouncer.dispose(); // Dispose debouncer
    _offerAutoSavedDraftsTimer?.cancel();
    _tourShowTimer?.cancel();
    _statisticsRefreshTimer?.cancel();
    _tabController.removeListener(_onTabNavigationSettled);
    _controllers.dispose();
    _tabController.dispose();
    _firstFieldFocusNode.dispose();
    _formHistory.dispose();
    _dependencyController?.dispose();
    // ⚠️ _searchController moved to FormContentWidget

    if (kDebugMode && (_enableRuntimePerfTracing || _enableOnScreenPerfDiagnostics)) {
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    }

    if (kDebugMode && _enableRuntimePerfTracing) {
      CivilRegistryLookupDiagnostics.enabled = _previousCivilLookupDiagnosticsEnabled;

      debugPrint(
        '[BeneficiaryFormPerf] frames=$_totalFramesObserved slowBuild=$_slowBuildFrames slowRaster=$_slowRasterFrames verySlow=$_verySlowFrames worst=${_worstTotalFrame.inMilliseconds}ms',
      );

      final lookupEvents = CivilRegistryLookupDiagnostics.snapshot();
      if (lookupEvents.isNotEmpty) {
        debugPrint('[BeneficiaryFormPerf] civilLookupEvents=${lookupEvents.length}');
      }

      final summaries = _flowMetricsCollector.summarizeAll();
      for (final summary in summaries) {
        debugPrint(
          '[BeneficiaryFormPerf] flow=${summary.operation} count=${summary.count} p50=${summary.p50Ms}ms p95=${summary.p95Ms}ms max=${summary.maxMs}ms',
        );
      }
    }

    // ⚡ Dispose ValueNotifiers
    _isSavingNotifier.dispose();
    _isDeletingNotifier.dispose();
    _isLoadingNotifier.dispose();
    _isTaxonomyCoverageLoadingNotifier.dispose();
    _missingTaxonomyGroupsNotifier.dispose();
    _unknownTaxonomyGroupsNotifier.dispose();
    _lastSavedNotifier.dispose();
    _lastAutoSavedNotifier.dispose();
    _hasUnsavedChangesNotifier.dispose();
    _showStatisticsNotifier.dispose();
    _showProgressCardNotifier.dispose();
    _showTourGuideNotifier.dispose();
    _statisticsVersionNotifier.dispose();
    _perfOverlayVersionNotifier.dispose();

    super.dispose();
  }

  /// 🔍 Scroll to first error and show detailed message
  void _scrollToFirstError() {
    final validationResult = FormValidationErrorHelper.evaluateRequiredFieldErrors(_controllers);
    if (validationResult == null) {
      return;
    }

    if (_tabController.index != validationResult.firstErrorTab) {
      _tabController.animateTo(validationResult.firstErrorTab);
    }

    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      EnhancedSnackbar.showError(
        context,
        message: FormValidationErrorHelper.buildSnackbarMessage(validationResult),
      );

      if (validationResult.firstErrorTab == 0 && _firstFieldFocusNode.canRequestFocus) {
        _firstFieldFocusNode.requestFocus();
      }
    });
  }

  Future<void> _saveFamilyMembers(String beneficiaryId) async {
    await FamilySaveHelper.saveFamilyMembers(
      database: ref.read(databaseProvider),
      beneficiaryId: beneficiaryId,
      livingMembers: _controllers.livingMembers,
      deceasedMembers: _controllers.deceasedMembers,
    );
  }

  Future<void> _saveGuardianBankAccount(String beneficiaryId) async {
    final useCase = ref.read(saveGuardianBankAccountUseCaseProvider);
    final draft = GuardianBankAccount(
      guardianRegistration: 0,
      bankNameId: int.tryParse(_controllers.bankNameIdController.text.trim()),
      bankNameLabel: _controllers.bankNameLabelController.text.trim(),
      ibanUsd: _controllers.ibanUsdController.text.trim(),
      ibanShekel: _controllers.ibanShekelController.text.trim(),
      representativeIdNumber: _controllers.bankRepresentativeIdController.text.trim(),
      guardianName: _controllers.bankGuardianNameController.text.trim(),
      representativePhone: _controllers.bankRepresentativePhoneController.text.trim(),
      ownerIdentityNumber: _controllers.bankOwnerIdentityController.text.trim(),
      checkAccountApproved: _controllers.bankCheckAccountApproved,
    );

    await useCase.execute(
      beneficiaryId: beneficiaryId,
      draft: draft,
    );
  }

  /// 🆕 Handle final save from Review Tab with confirmation
  Future<void> _handleFinalSaveFromReview() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.save_rounded, size: 48.sp, color: Theme.of(context).colorScheme.primary),
        title: const Text('حفظ السجل نهائياً'),
        content: const Text(
          'هل أنت متأكد من حفظ السجل بشكل نهائي؟\n'
          'يرجى التأكد من صحة جميع البيانات.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('تأكيد الحفظ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleSave();
    }
  }

  Future<void> _handleSave({bool isAutoSave = false}) async {
    if (_isSavingLocked) return;

    _isSavingLocked = true;
    final trace = FormFlowTracer.start('save');

    try {
      if (!isAutoSave && !await _ensureTaxonomyCoverageBeforeSave()) {
        final elapsed = trace.end(result: 'taxonomy_coverage_blocked');
        _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
        _recordPerfSample('flow.save', elapsed);
        return;
      }

      final formState = _formKey.currentState;
      if (formState == null || !formState.validate()) {
        if (isAutoSave) {
          final elapsed = trace.end(result: 'autosave_validation_failed');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
          _recordPerfSample('flow.save', elapsed);
          return;
        }
        _scrollToFirstError();
        _feedbackCoordinator.showError(context, FormConstants.requiredFieldMessage);
        final elapsed = trace.end(result: 'validation_failed');
        _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
        _recordPerfSample('flow.save', elapsed);
        return;
      }

      _isSaving = true; // ⚡ Direct assignment

      final currentBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      final now = DateTime.now();
      AttachmentSaveResult? attachmentSaveResult;
      final beneficiary = FormSaveFlowHelper.prepareBeneficiaryForSave(
        controllers: _controllers,
        beneficiaryId: widget.beneficiaryId,
        currentBeneficiary: currentBeneficiary,
        now: now,
      );
      ref.read(beneficiaryFormProvider.notifier).updateField((_) => beneficiary);
      trace.startStep('orchestration');
      final result = await FormSaveFlowHelper.executeSaveFlow(
        coordinator: _formSaveCoordinator,
        checkDuplicate: () async {
          final repository = ref.read(beneficiaryRepositoryProvider);
          return SaveOperationsHelper.checkDuplicate(
            context: context,
            repository: repository,
            nationalId: _controllers.nationalIdController.text.trim(),
            isNewBeneficiary: widget.beneficiaryId == null,
            currentBeneficiaryId: widget.beneficiaryId,
          );
        },
        saveBeneficiary: () => ref.read(beneficiaryFormProvider.notifier).save(),
        getSavedBeneficiaryId: () async => ref.read(beneficiaryFormProvider).beneficiary?.id,
        saveAttachments: (beneficiaryId) async {
          final attachmentsStopwatch = Stopwatch()..start();
          attachmentSaveResult = await SaveOperationsHelper.savePendingAttachments(
            database: ref.read(databaseProvider),
            beneficiaryId: beneficiaryId,
            pendingAttachments: _controllers.pendingAttachments,
          );
          attachmentsStopwatch.stop();
          _recordPerfSample('flow.attachmentsSave', attachmentsStopwatch.elapsedMilliseconds);
          return attachmentSaveResult?.failedCount ?? _controllers.pendingAttachments.length;
        },
        saveFamilyMembers: _saveFamilyMembers,
        saveGuardianBankAccount: _saveGuardianBankAccount,
        clearPendingAttachments: _controllers.clearPendingAttachments,
      );
      trace.endStep('orchestration');

      final outcome = FormSaveOutcomeHelper.resolve(
        result: result,
        isAutoSave: isAutoSave,
      );

      if (!mounted) return;

      if (outcome.showAttachmentWarning) {
        _feedbackCoordinator.showWarning(context, 'بعض الملفات فشل حفظها (${result.failedAttachmentsCount})');
      }

      final failedPendingAttachments = attachmentSaveResult?.failedPendingAttachments;
      if (failedPendingAttachments != null && failedPendingAttachments.isNotEmpty) {
        _controllers.updatePendingAttachments(failedPendingAttachments);
      }

      if (outcome.markSavedState) {
        final savedBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
        final resolvedFileNumber = (savedBeneficiary?.fileIdNumber ?? savedBeneficiary?.fileNo ?? '').trim();
        if (resolvedFileNumber.isNotEmpty && _controllers.fileNumberController.text.trim() != resolvedFileNumber) {
          _controllers.fileNumberController.text = resolvedFileNumber;
        }

        _lastSaved = DateTime.now();
        _hasUnsavedChanges = false;
      }

      if (outcome.showSaveSuccessOverlay) {
        final successMessage = (!isAutoSave && _controllers.fileNumberController.text.trim().isNotEmpty)
            ? '${FormConstants.saveSuccessMessage} • رقم الملف: ${_controllers.fileNumberController.text.trim()}'
            : FormConstants.saveSuccessMessage;
        _feedbackCoordinator.showSaveSuccessOverlay(context, successMessage);
      }

      if (outcome.failureMessage != null) {
        _feedbackCoordinator.showError(
          context,
          outcome.failureMessage!,
          onRetry: () => _handleSave(),
        );
      }

      _isSaving = false;

      if (outcome.delayThenPop) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted && context.mounted) {
          context.pop(true);
        }
      }

      final elapsed = trace.end(result: outcome.traceResult);
      _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
      _recordPerfSample('flow.save', elapsed);
    } finally {
      _isSavingLocked = false;
    }
  }

  Future<bool> _ensureTaxonomyCoverageBeforeSave() async {
    return FormSaveGuardHelper.ensureTaxonomyCoverage(
      currentMissingGroups: _missingTaxonomyGroupsNotifier.value,
      refreshCoverage: () => _refreshTaxonomyCoverage(showSnackBar: false),
      onWarning: (message) => _feedbackCoordinator.showWarning(
        context,
        message,
      ),
    );
  }

  Future<void> _handleDelete() async {
    final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
    if (beneficiary == null) return;

    HapticPatterns.warning();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => V2ConfirmDialog(
        title: 'حذف مستفيد',
        message: 'هل أنت متأكد من حذف "${beneficiary.fullName}"؟',
        confirmText: 'حذف',
        isDangerous: true,
        icon: Icons.delete_forever_rounded,
        onConfirm: () {},
      ),
    );

    if (confirmed == true && mounted) {
      final trace = FormFlowTracer.start('delete');
      _isDeleting = true;

      final deleteUseCase = ref.read(deleteBeneficiaryWithActivityProvider);
      trace.startStep('deleteUseCase');
      final deleteResult = await FormDeleteFlowHelper.execute(
        coordinator: _beneficiaryDeleteCoordinator,
        beneficiaryId: beneficiary.id,
        deleteAction: (beneficiaryId) => deleteUseCase(
          beneficiaryId: int.parse(beneficiaryId),
          beneficiaryName: beneficiary.fullName,
          fileNo: beneficiary.fileIdNumber,
        ),
      );
      trace.endStep('deleteUseCase');

      if (!mounted) return;
      _isDeleting = false;

      if (deleteResult.success) {
        _feedbackCoordinator.showDeleteSuccess(context, FormConstants.deleteSuccessMessage);

        if (context.mounted) {
          context.pop();
        }
        final elapsed = trace.end(result: 'deleted');
        _flowMetricsCollector.record(operation: 'delete', durationMs: elapsed);
      } else {
        final errorMsg = UserFriendlyError.getMessage(
          deleteResult.error ?? Exception('Delete failed'),
          deleteResult.stackTrace,
        );
        _feedbackCoordinator.showError(
          context,
          errorMsg,
          onRetry: _handleDelete,
        );
        debugPrint('❌ Delete error: ${deleteResult.error}');
        final elapsed = trace.end(result: 'delete_failed');
        _flowMetricsCollector.record(operation: 'delete', durationMs: elapsed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<sync_providers.SyncState>(
      sync_providers.syncControllerProvider,
      (previous, next) {
        final wasSyncing = previous?.status == sync_providers.SyncStatus.syncing;
        final isSuccess = next.status == sync_providers.SyncStatus.success;
        if (wasSyncing && isSuccess) {
          unawaited(_refreshTaxonomyCoverage(showSnackBar: false));
        }
      },
    );

    final resolvedBeneficiaryId = ref.watch(
      beneficiaryFormProvider.select((state) => state.beneficiary?.id),
    );
    final syncState = ref.watch(sync_providers.syncControllerProvider);
    final isSyncRunning = syncState.status == sync_providers.SyncStatus.syncing;
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;
    final isCompactMobile = mediaQuery.size.width < 360;
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final isShortHeight = mediaQuery.size.height < 760;

    // ⚠️ DON'T use ref.watch here - causes rebuild on every provider change!
    // Use Consumer only where needed
    final theme = Theme.of(context);

    return FormKeyboardShortcuts(
      onSave: _handleSave,
      onNextTab: _handleNextTab,
      onPreviousTab: _handlePreviousTab,
      onUndo: _formHistory.canUndo ? _handleUndo : null,
      onRedo: _formHistory.canRedo ? _handleRedo : null,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasUnsavedChangesNotifier,
        builder: (context, hasUnsavedChanges, child) {
          return PopScope(
            canPop: !hasUnsavedChanges,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) return;

              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => const UnsavedChangesDialog(),
              );

              if (shouldPop == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,

          // 📱 AppBar - NEW: Using extracted BeneficiaryFormAppBar
          appBar: BeneficiaryFormAppBar(
            isEditMode: widget.beneficiaryId != null,
            beneficiaryName: widget.beneficiaryId != null ? _controllers.firstNameController.text : null,
            isSavingNotifier: _isSavingNotifier,
            lastSavedNotifier: _lastSavedNotifier,
            hasUnsavedChangesNotifier: _hasUnsavedChangesNotifier,
            onSave: _handleSave,
            onToggleProgressCard: _toggleProgressCard,
            isProgressCardVisible: _showProgressCard,
            onDelete: widget.beneficiaryId != null ? _handleDelete : null,
            onShowHistory: _showHistoryNotAvailable,
            onShowHelp: () => showKeyboardShortcutsHelp(context),
            canUndo: _formHistory.canUndo,
            canRedo: _formHistory.canRedo,
            onUndo: _handleUndo,
            onRedo: _handleRedo,
          ),

          body: ValueListenableBuilder<bool>(
            valueListenable: _isLoadingNotifier,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const SkeletonFormScreen();
              }

              return Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 🚨 Error Banner - Separated widget
                        const FormErrorBanner(),

                        if (!isMobile && !isShortHeight) ...[
                          ValueListenableBuilder<DateTime?>(
                            valueListenable: _lastAutoSavedNotifier,
                            builder: (context, lastAutoSavedAt, _) {
                              return _buildAutoSaveIndicator(context, lastAutoSavedAt);
                            },
                          ),
                          _buildSaveSyncTimeline(context, syncState),
                        ],

                        ValueListenableBuilder<bool>(
                          valueListenable: _isTaxonomyCoverageLoadingNotifier,
                          builder: (context, isCoverageLoading, _) {
                            return ValueListenableBuilder<List<TaxonomyGroup>>(
                              valueListenable: _missingTaxonomyGroupsNotifier,
                              builder: (context, missingGroups, __) {
                                return ValueListenableBuilder<List<String>>(
                                  valueListenable: _unknownTaxonomyGroupsNotifier,
                                  builder: (context, unknownGroups, ___) {
                                    if (!isCoverageLoading && missingGroups.isEmpty && unknownGroups.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    final totalGroups = essentialBeneficiaryFormTaxonomyGroups.length;
                                    final filledGroups = totalGroups - missingGroups.length;

                                    if ((isMobile || isShortHeight) && !isCoverageLoading) {
                                      return const SizedBox.shrink();
                                    }

                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(color: theme.colorScheme.outlineVariant),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 8.w,
                                            runSpacing: 4.h,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.sync_problem,
                                                      size: 18.sp, color: theme.colorScheme.primary),
                                                  SizedBox(width: 8.w),
                                                ],
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(minWidth: 160.w),
                                                child: Text(
                                                  'تغطية التصنيفات: مكتمل $filledGroups/$totalGroups',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: () =>
                                                    unawaited(_refreshTaxonomyCoverage(showSnackBar: true)),
                                                icon: const Icon(Icons.refresh, size: 16),
                                                label: const Text('إعادة الفحص'),
                                              ),
                                              TextButton.icon(
                                                onPressed: isSyncRunning ? null : _syncTaxonomiesFromCoverageCard,
                                                icon: Icon(isSyncRunning ? Icons.sync : Icons.cloud_download, size: 16),
                                                label: Text(isSyncRunning ? 'جاري المزامنة...' : 'مزامنة التصنيفات'),
                                              ),
                                            ],
                                          ),
                                          if (isCoverageLoading) ...[
                                            SizedBox(height: 8.h),
                                            const LinearProgressIndicator(),
                                          ],
                                          if (missingGroups.isNotEmpty) ...[
                                            SizedBox(height: 8.h),
                                            Text(
                                              'المجموعات الناقصة: ${missingGroups.map((g) => g.arabicName).join('، ')}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                          if (unknownGroups.isNotEmpty) ...[
                                            SizedBox(height: 6.h),
                                            Text(
                                              'مجموعات غير معروفة في البيانات المحلية: ${unknownGroups.join(', ')}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),

                        if (kDebugMode && !isShortHeight)
                          _buildIdentityDebugCard(
                            context,
                            resolvedBeneficiaryId: resolvedBeneficiaryId,
                            routeBeneficiaryId: widget.beneficiaryId,
                          ),

                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragEnd: _handleHorizontalTabSwipe,
                            child: FormContentWidget(
                              tabController: _tabController,
                              controllers: _controllers,
                              onBirthDateTap: () => _selectDate(context),
                              firstFieldFocusNode: _firstFieldFocusNode,
                              beneficiaryId: resolvedBeneficiaryId ?? widget.beneficiaryId,
                              showFieldHelpers: _showFieldHelpers,
                              showProgressCard: _showProgressCard,
                              minimizeTopInsights: isCompactMobile && isKeyboardOpen,
                              onFinalSave: _handleFinalSaveFromReview, // 🆕 Pass callback
                            ),
                          ),
                        ),

                        // 🎯 Bottom Navigation - Separated widget with ValueListenableBuilder
                        ValueListenableBuilder<bool>(
                          valueListenable: _isSavingNotifier,
                          builder: (context, isSaving, _) {
                            return FormBottomNavWidget(
                              tabController: _tabController,
                              onPrevious: _handlePreviousTab,
                              onNext: _handleNextTab,
                              onSave: _showFinalReview,
                              onSaveDraft: _handleDraftSave,
                              isLoading: isSaving,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ⚡ Loading Overlay with ValueListenableBuilder
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSavingNotifier,
                    builder: (context, isSaving, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isDeletingNotifier,
                        builder: (context, isDeleting, _) {
                          return local.LoadingOverlay(
                            isVisible: isSaving || isDeleting,
                            message: isSaving ? FormConstants.savingMessage : FormConstants.deletingMessage,
                          );
                        },
                      );
                    },
                  ),

                  // 📊 Statistics Widget (if visible)
                  ValueListenableBuilder<bool>(
                    valueListenable: _showStatisticsNotifier,
                    builder: (context, showStatistics, _) {
                      if (!showStatistics) return const SizedBox.shrink();
                      return ValueListenableBuilder<int>(
                        valueListenable: _statisticsVersionNotifier,
                        builder: (context, _, __) {
                          final completedFields = _calculateFilledFields();
                          return Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: CompletionStatsWidget(
                              overallCompletion: completedFields / 12 * 100,
                              completedFields: completedFields,
                              totalFields: 12,
                              tabCompletions: _calculateTabCompletions(),
                              onTap: _toggleStatistics,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showTourGuideNotifier,
                    builder: (context, showTourGuide, _) {
                      if (!showTourGuide) return const SizedBox.shrink();
                      return TourGuide(
                        steps: const [
                          TourStep(
                            title: 'مرحباً بك! 👋',
                            description: 'هذا نموذج إضافة مستفيد جديد. دعنا نأخذ جولة سريعة!',
                            icon: Icons.waving_hand,
                          ),
                          TourStep(
                            title: 'التبويبات 📑',
                            description: 'النموذج مقسم إلى 4 تبويبات لسهولة التنقل والتنظيم.',
                            icon: Icons.tab,
                          ),
                          TourStep(
                            title: 'كارد التقدم 📊',
                            description: 'يعرض نسبة إنجازك في ملء النموذج والحقول المكتملة.',
                            icon: Icons.analytics,
                          ),
                          TourStep(
                            title: 'حفظ المسودة 💾',
                            description: 'يمكنك حفظ تقدمك كمسودة والعودة لاحقاً لإكمالها.',
                            icon: Icons.save,
                          ),
                          TourStep(
                            title: 'المراجعة النهائية 📋',
                            description: 'في النهاية، راجع جميع البيانات قبل الحفظ النهائي.',
                            icon: Icons.checklist,
                          ),
                        ],
                        onComplete: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await _bootstrapController.markTourSeen(prefs);
                          _showTourGuide = false;
                        },
                        onSkip: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await _bootstrapController.markTourSeen(prefs);
                          _showTourGuide = false;
                        },
                      );
                    },
                  ),

                  if (kDebugMode && _enableOnScreenPerfDiagnostics)
                    _buildOnScreenPerfDiagnostics(
                      context,
                      isSyncRunning: isSyncRunning,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSaveSyncTimeline(BuildContext context, sync_providers.SyncState syncState) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: _lastSavedNotifier,
      builder: (context, lastSavedAt, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _hasUnsavedChangesNotifier,
          builder: (context, hasUnsaved, __) {
            final theme = Theme.of(context);
            final isCompact = MediaQuery.of(context).size.width < 380;

            final localStatusLabel =
                lastSavedAt == null ? 'لم يتم حفظ محلي بعد' : 'تم الحفظ محليًا (${_formatDateTime(lastSavedAt)})';

            final queueStatusLabel = hasUnsaved ? 'تغييرات بانتظار المزامنة' : 'لا توجد تغييرات معلّقة';

            final syncStatusLabel = switch (syncState.status) {
              sync_providers.SyncStatus.syncing => 'جارٍ المزامنة',
              sync_providers.SyncStatus.success => 'آخر مزامنة ناجحة',
              sync_providers.SyncStatus.error => 'فشلت آخر مزامنة',
              _ => 'المزامنة غير مفعلة الآن',
            };

            return Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 6.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimelineRow(context, icon: Icons.save_outlined, text: localStatusLabel),
                        SizedBox(height: 4.h),
                        _buildTimelineRow(context, icon: Icons.hourglass_top_rounded, text: queueStatusLabel),
                        SizedBox(height: 4.h),
                        _buildTimelineRow(context, icon: Icons.cloud_sync_outlined, text: syncStatusLabel),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildTimelineRow(context, icon: Icons.save_outlined, text: localStatusLabel)),
                        SizedBox(width: 10.w),
                        Expanded(
                            child:
                                _buildTimelineRow(context, icon: Icons.hourglass_top_rounded, text: queueStatusLabel)),
                        SizedBox(width: 10.w),
                        Expanded(
                            child: _buildTimelineRow(context, icon: Icons.cloud_sync_outlined, text: syncStatusLabel)),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineRow(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: theme.colorScheme.primary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  void _showHistoryNotAvailable() {
    if (!mounted) return;
    EnhancedSnackbar.showInfo(
      context,
      message: 'سجل التغييرات سيتوفر قريبًا. يمكنك استخدام التراجع/الإعادة حاليًا.',
    );
  }

  Widget _buildOnScreenPerfDiagnostics(
    BuildContext context, {
    required bool isSyncRunning,
  }) {
    return Positioned(
      right: 8.w,
      bottom: 90.h,
      child: ValueListenableBuilder<int>(
        valueListenable: _perfOverlayVersionNotifier,
        builder: (context, _, __) {
          final entries = _perfAggregates.entries.toList(growable: false)
            ..sort((a, b) => b.value.maxMs.compareTo(a.value.maxMs));
          final topEntries = entries.take(4).toList(growable: false);

          return GestureDetector(
            onTap: () {
              setState(() => _showPerfOverlay = !_showPerfOverlay);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              constraints: BoxConstraints(maxWidth: 280.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: _showPerfOverlay
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PERF DEBUG',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'sync=${isSyncRunning ? 'on' : 'off'} | emergency=${_uiEmergencyMode ? 'on' : 'off'} | lagBurst=$_uiLagBurstCount',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onInverseSurface.withValues(alpha: 0.75),
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'frames=$_totalFramesObserved slowBuild=$_slowBuildFrames slowRaster=$_slowRasterFrames verySlow=$_verySlowFrames',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onInverseSurface.withValues(alpha: 0.75),
                            fontSize: 10.sp,
                          ),
                        ),
                        if (topEntries.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          for (final entry in topEntries)
                            Text(
                              '${entry.key}: n=${entry.value.count} avg=${entry.value.averageMs}ms max=${entry.value.maxMs}ms >50=${entry.value.over50Ms}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onInverseSurface,
                                fontSize: 10.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ],
                    )
                  : Text(
                      'PERF',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusXL,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      _controllers.birthDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildIdentityDebugCard(
    BuildContext context, {
    required String? resolvedBeneficiaryId,
    required String? routeBeneficiaryId,
  }) {
    final effectiveId = resolvedBeneficiaryId ?? routeBeneficiaryId;
    if (effectiveId == null || effectiveId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final familyCount = _controllers.livingMembers.length + _controllers.deceasedMembers.length;
    final pendingAttachmentsCount = _controllers.pendingAttachments.length;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: colorScheme.secondary.withOpacity(0.55)),
        ),
        child: Text(
          'DEBUG LINK | routeId: ${routeBeneficiaryId ?? '-'} | effectiveId: $effectiveId | family(pending): $familyCount | attachments(pending): $pendingAttachmentsCount',
          style: TextStyle(
            fontSize: 11.sp,
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PerfAggregate {
  int count = 0;
  int totalMs = 0;
  int maxMs = 0;
  int over50Ms = 0;

  int get averageMs => count == 0 ? 0 : (totalMs / count).round();

  void add(int durationMs) {
    count += 1;
    totalMs += durationMs;
    if (durationMs > maxMs) {
      maxMs = durationMs;
    }
    if (durationMs > 50) {
      over50Ms += 1;
    }
  }
}
