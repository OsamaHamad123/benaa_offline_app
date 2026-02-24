import 'dart:ui';
import 'dart:developer' as developer;

import 'package:benaa_offline_app/core/widgets/responsive_dialog.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/providers/civil_registry_provider.dart';
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
import '../../../../core/design_system/app_animations.dart';
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
import 'v2_form_helpers/widgets/mobile_quick_actions.dart'; // 📱 Mobile Quick Actions
import 'v2_form_helpers/utils/animation_helpers.dart'; // 🎬 Animation helpers

// ✨ NEW: Extracted Form Components (Phase 1.3)
import '../widgets/form/app_bar/beneficiary_form_app_bar.dart';
import '../widgets/form/statistics/completion_stats_widget.dart';
import '../../../taxonomies/domain/entities/taxonomy_group.dart';
import '../../../taxonomies/domain/contracts/beneficiary_taxonomy_contract.dart';
import '../../../taxonomies/domain/entities/taxonomy.dart' as taxonomy_domain;
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
  static const Duration _nonCriticalUiDelay = Duration(milliseconds: 1200);

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
  final ValueNotifier<bool> _hasUnsavedChangesNotifier = ValueNotifier(false);

  // Setters للكتابة السهلة (Getters غير مطلوبة لأننا نستخدم ValueListenableBuilder)
  bool get _isSaving => _isSavingNotifier.value;
  set _isSaving(bool value) => _isSavingNotifier.value = value;
  bool get _isDeleting => _isDeletingNotifier.value;
  set _isDeleting(bool value) => _isDeletingNotifier.value = value;
  bool get _isLoading => _isLoadingNotifier.value;
  set _isLoading(bool value) => _isLoadingNotifier.value = value;

  set _lastSaved(DateTime? value) => _lastSavedNotifier.value = value;

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
  bool _showStatistics = false;
  bool _showTourGuide = false;
  final bool _showFieldHelpers = false; // ✅ مخفية افتراضياً - تبسيط
  // ⚠️ Search moved to FormContentWidget local state for performance

  final FocusNode _firstFieldFocusNode = FocusNode();

  // 🔄 Debouncing for auto-save
  late final Debouncer _autoSaveDebouncer; // ✅ Debouncer for auto-save
  // Timer to check and offer auto-saved drafts (cancelable)
  Timer? _offerAutoSavedDraftsTimer;
  // Timer to show first-time user tour (cancelable)
  Timer? _tourShowTimer;
  Timer? _nonCriticalUiTimer;

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
  final ValueNotifier<int> _perfOverlayVersionNotifier = ValueNotifier(0);
  final Map<String, _PerfAggregate> _perfAggregates = <String, _PerfAggregate>{};
  bool _showPerfOverlay = true;
  bool _nonCriticalUiReady = false;

  @override
  void initState() {
    super.initState();
    _openBenchmark.start();

    // ✅ Initialize Debouncer for auto-save (2 seconds)
    _autoSaveDebouncer = Debouncer(delay: const Duration(seconds: 2));

    _controllers = BeneficiaryFormControllers(onAutoSave: _performAutoSave);
    _formHistory = FormHistory<FormStateSnapshot>();
    _tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: this,
    );

    // 🚀 Initialize Phase 3 features
    if (_showFieldHelpers) {
      _dependencyController = FieldDependencyController();
      _setupFieldDependencies();
    }
    _setupSmartHints();
    _startUiWatchdog();

    _setTaxonomySyncSuspended(true);
    _nonCriticalUiTimer = Timer(_nonCriticalUiDelay, () {
      if (!mounted) return;
      setState(() {
        _nonCriticalUiReady = true;
      });
    });

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
    if (!kDebugMode) return;
    if (durationMs < 0) return;

    final aggregate = _perfAggregates.putIfAbsent(key, _PerfAggregate.new);
    aggregate.add(durationMs);

    if (_showPerfOverlay) {
      _perfOverlayVersionNotifier.value = _perfOverlayVersionNotifier.value + 1;
    }
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
          setState(() => _showTourGuide = true);
        }
      });
    }
  }

  /// 📊 Toggle Statistics Dashboard
  void _toggleStatistics() {
    setState(() => _showStatistics = !_showStatistics);
  }

  /// ⚠️ Search functionality moved to FormContentWidget for performance
  /// Prevents parent setState on every keystroke

  void _onFormChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
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

  /// 🔄 Debounced Auto-Save (2 seconds delay)
  /// ✅ Changed to save as draft instead of direct database save
  Future<void> _performAutoSave() async {
    if (_isSaving || _isDeleting || _isLoading) return;

    // Use Debouncer to delay auto-save
    _autoSaveDebouncer(() async {
      if (!mounted) return;

      final hasChanges =
          _controllers.firstNameController.text.isNotEmpty || _controllers.nationalIdController.text.isNotEmpty;

      if (!hasChanges) return;

      final now = DateTime.now();
      if (!_autoSaveThrottleGuard.canAttempt(now)) {
        return;
      }

      // ✅ Auto-save as draft instead of full save
      // This prevents validation errors and allows partial forms
      await _autoSaveDraft();
    });
  }

  /// 💾 Auto-save as draft (silent, no validation required)
  Future<void> _autoSaveDraft() async {
    final trace = FormFlowTracer.start('autoSaveDraft');
    final now = DateTime.now();
    _autoSaveThrottleGuard.markStarted();
    var success = false;
    var signature = '';

    try {
      final formData = _draftSaveCoordinator.buildAutoSaveFormData(_controllers);
      signature = AutoSaveThrottleGuard.buildSignature(
        formData: formData,
        currentTab: _tabController.index,
      );

      if (_autoSaveThrottleGuard.shouldSkipUnchanged(signature: signature, now: now)) {
        success = true;
        final elapsed = trace.end(result: 'skipped_unchanged');
        _flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
        return;
      }

      // استخدام ID ثابت للمسودة التلقائية - يتم التحديث بدلاً من الإنشاء
      _autoSaveDraftId = _draftSaveCoordinator.ensureAutoSaveDraftId(
        currentDraftId: _autoSaveDraftId,
        beneficiaryId: widget.beneficiaryId,
        nationalId: _controllers.nationalIdController.text.trim(),
        now: now,
      );

      final draftName = _draftSaveCoordinator.buildAutoDraftName(_controllers);

      await DraftManager.saveDraft(
        draftId: _autoSaveDraftId!,
        formData: _draftSaveCoordinator.buildDraftEnvelope(
          name: draftName,
          notes: 'آخر تحديث: ${now.toString().split('.')[0]}',
          formData: formData,
          currentTab: _tabController.index,
          beneficiaryId: widget.beneficiaryId,
          isAutoSaved: true,
        ),
      ).timeout(const Duration(seconds: 2), onTimeout: () {
        throw TimeoutException('Auto-save draft timed out');
      });

      if (mounted) {
        _lastSaved = DateTime.now();
      }

      debugPrint('✅ Auto-saved draft successfully');
      success = true;
      final elapsed = trace.end(result: 'saved');
      _flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
    } catch (e, stackTrace) {
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      debugPrint('❌ Auto-save failed: $errorMsg (technical: $e)');
      final elapsed = trace.end(result: 'failed');
      _flowMetricsCollector.record(operation: 'autoSaveDraft', durationMs: elapsed);
      // Silent failure - don't disturb user with auto-save errors
    } finally {
      _autoSaveThrottleGuard.markFinished(
        success: success,
        signature: signature,
        now: now,
      );
    }
  }

  void _initializeForm() async {
    final initStopwatch = Stopwatch()..start();
    _isLoading = true;
    String? resolvedBeneficiaryId;

    try {
      if (widget.beneficiaryId != null) {
        final database = ref.read(databaseProvider);
        resolvedBeneficiaryId = await BeneficiaryIdentityResolver.resolveLocalBeneficiaryIdAsString(
          database: database,
          beneficiaryId: widget.beneficiaryId,
        );
        final beneficiaryIdForLoad = resolvedBeneficiaryId ?? widget.beneficiaryId!;

        await ref.read(beneficiaryFormProvider.notifier).loadBeneficiary(beneficiaryIdForLoad);

        final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
        if (beneficiary != null) {
          _populateControllers(beneficiary);
          await _normalizeAllTaxonomySelections();
          _saveToHistory('Initial load');
        }
      } else {
        _clearAllControllers();
        ref.read(beneficiaryFormProvider.notifier).createNew();

        if (widget.civilRegistryData != null) {
          debugPrint('📋 Civil Registry Data received: ${widget.civilRegistryData}');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _fillFromCivilRegistry(widget.civilRegistryData!);
              setState(() {
                _hasUnsavedChanges = true;
              });
            }
          });
        } else {
          _offerAutoSavedDraftsTimer = Timer(
            const Duration(milliseconds: 350),
            () {
              if (mounted) {
                _firstFieldFocusNode.requestFocus();
              }
            },
          );
        }
      }

      unawaited(_refreshTaxonomyCoverage(showSnackBar: false));
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
      final availableGroups =
          await db.taxonomiesDao.getAllGroups().timeout(const Duration(seconds: 2), onTimeout: () => const <String>[]);
      final coverage = analyzeBeneficiaryTaxonomyCoverage(availableGroups);
      final formCoverage = BeneficiaryTaxonomyCoverageReport(
        resolvedGroups: coverage.resolvedGroups,
        unknownGroups: coverage.unknownGroups,
        missingGroups: missingEssentialBeneficiaryFormTaxonomyGroups(coverage.resolvedGroups),
      );
      final missingGroups = formCoverage.missingGroups;

      if (!mounted) return;
      _missingTaxonomyGroupsNotifier.value = missingGroups;
      _unknownTaxonomyGroupsNotifier.value = formCoverage.unknownGroups;

      if (formCoverage.unknownGroups.isNotEmpty) {
        developer.log(
          'taxonomy coverage contains unknown groups: ${formCoverage.unknownGroups.join(', ')}',
          name: 'BeneficiaryFormTaxonomyCoverage',
        );
      }

      if (showSnackBar && missingGroups.isNotEmpty) {
        final missingNames = missingGroups.map((g) => g.arabicName).join('، ');
        EnhancedSnackbar.showWarning(
          context,
          message: '⚠️ تصنيفات غير متوفرة في الفورم: $missingNames. يرجى مزامنة التصنيفات.',
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
        final message =
            (syncState.error == null || syncState.error!.trim().isEmpty) ? 'فشلت مزامنة التصنيفات.' : syncState.error!;
        EnhancedSnackbar.showError(context, message: message);
      } else {
        EnhancedSnackbar.showSuccess(context, message: 'تمت مزامنة التصنيفات بنجاح.');
      }
    } catch (error, stackTrace) {
      developer.log(
        'taxonomy sync from coverage card failed',
        name: 'BeneficiaryFormTaxonomyCoverage',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        EnhancedSnackbar.showError(context, message: 'تعذر مزامنة التصنيفات حالياً.');
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
    _controllers.firstNameController.clear();
    _controllers.fatherNameController.clear();
    _controllers.grandfatherNameController.clear();
    _controllers.lastNameController.clear();
    _controllers.motherNameController.clear();
    _controllers.nationalIdController.clear();
    _controllers.birthDateController.clear();
    _controllers.phoneController.clear();
    _controllers.altPhoneController.clear();
    _controllers.addressController.clear();
    _controllers.neighborhoodController.clear();
    _controllers.notesController.clear();
    _controllers.numberOfDependentsController.clear();
    _controllers.numberOfMalesController.clear();
    _controllers.numberOfFemalesController.clear();
    _controllers.chronicDiseasesController.clear();
    _controllers.addressBeforeDisplacementController.clear();

    _controllers.selectedGender = null;
    _controllers.selectedCategory = null;
    _controllers.selectedMaritalStatus = null;
    _controllers.selectedEducationLevel = null;
    _controllers.selectedEmploymentStatus = null;
    _controllers.selectedRelationship = null;
    _controllers.selectedCity = null;
    _controllers.selectedProvince = null;
    _controllers.selectedDisplacementStatus = null;
    _controllers.selectedHealthStatus = null;
    _controllers.selectedHousingStatus = null;
    _controllers.selectedHousingType = null;
    _controllers.selectedAssistanceType = null;
    _controllers.selectedRequestStatus = null;
    _controllers.hasDisability = false;
    _controllers.updatePendingFiles([]);

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
  }

  Future<void> _normalizeAllTaxonomySelections() async {
    if (!mounted) return;
    final stopwatch = Stopwatch()..start();

    final taxonomyIndex = await ref.read(bridgeTaxonomiesIndexOnceProvider.future);

    await _normalizeAndSet(
      group: TaxonomyGroup.gender,
      rawValue: _controllers.selectedGender,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedGender = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.category,
      rawValue: _controllers.selectedCategory,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedCategory = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.maritalStatus,
      rawValue: _controllers.selectedMaritalStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedMaritalStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.educationLevel,
      rawValue: _controllers.selectedEducationLevel,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedEducationLevel = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.employmentStatus,
      rawValue: _controllers.selectedEmploymentStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedEmploymentStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.relationship,
      rawValue: _controllers.selectedRelationship,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedRelationship = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.section,
      rawValue: _controllers.selectedSection,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedSection = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.governorate,
      rawValue: _controllers.selectedProvince,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedProvince = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.displacementStatus,
      rawValue: _controllers.selectedDisplacementStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedDisplacementStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.healthStatus,
      rawValue: _controllers.selectedHealthStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedHealthStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.housingStatus,
      rawValue: _controllers.selectedHousingStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedHousingStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.housingType,
      rawValue: _controllers.selectedHousingType,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedHousingType = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.assistanceType,
      rawValue: _controllers.selectedAssistanceType,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedAssistanceType = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.beneficiaryStatus,
      rawValue: _controllers.selectedRequestStatus,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedRequestStatus = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.disabilityType,
      rawValue: _controllers.selectedDisabilityType,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedDisabilityType = value,
    );
    await _normalizeAndSet(
      group: TaxonomyGroup.incomeSource,
      rawValue: _controllers.selectedIncomeSource,
      taxonomyIndex: taxonomyIndex,
      setter: (value) => _controllers.selectedIncomeSource = value,
    );

    stopwatch.stop();
    _recordPerfSample('db.normalizeTaxonomySelections', stopwatch.elapsedMilliseconds);
  }

  Future<void> _normalizeAndSet({
    required TaxonomyGroup group,
    required String? rawValue,
    required Map<TaxonomyGroup, List<taxonomy_domain.Taxonomy>> taxonomyIndex,
    required void Function(String?) setter,
  }) async {
    final normalized = _resolveTaxonomyCode(
      group: group,
      rawValue: rawValue,
      taxonomies: taxonomyIndex[group] ?? const <taxonomy_domain.Taxonomy>[],
    );
    if (normalized != null && normalized != rawValue) {
      setter(normalized);
    }
  }

  String? _resolveTaxonomyCode({
    required TaxonomyGroup group,
    required String? rawValue,
    required List<taxonomy_domain.Taxonomy> taxonomies,
  }) {
    final raw = rawValue?.trim();
    if (raw == null || raw.isEmpty) return null;

    if (taxonomies.isEmpty) return raw;

    final candidates = {
      _normalizeTaxonomyToken(raw),
    };

    for (final taxonomy in taxonomies) {
      final codeNorm = _normalizeTaxonomyToken(taxonomy.code);
      final labelNorm = _normalizeTaxonomyToken(taxonomy.label);
      final idNorm = _normalizeTaxonomyToken(taxonomy.id.toString());

      if (candidates.contains(codeNorm) ||
          candidates.contains(labelNorm) ||
          (idNorm.isNotEmpty && candidates.contains(idNorm))) {
        return taxonomy.code;
      }
    }

    return raw;
  }

  String _normalizeTaxonomyToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
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
    if (_dependencyController == null) {
      return;
    }

    // Add common dependency scenarios
    final scenarios = DependencyScenarios.getAllCommonScenarios();
    for (final scenario in scenarios) {
      _dependencyController!.addDependency(scenario);
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

  /// 📱 Mobile Quick Actions Handlers
  Future<void> _handleCopyFromBeneficiary() async {
    // Temporarily show message - will implement after database method is available
    if (mounted) {
      EnhancedSnackbar.showInfo(
        context,
        message: 'هذه الميزة ستكون متاحة قريباً',
      );
    }

    // TODO: Implement after adding getAllBeneficiaries to database
    /*
    final database = ref.read(databaseProvider);
    final allBeneficiaries = await database.getAllBeneficiaries();

    if (allBeneficiaries.isEmpty) {
      if (mounted) {
        EnhancedSnackbar.showInfo(
          context,
          message: 'لا يوجد مستفيدون لنسخ البيانات منهم',
        );
      }
      return;
    }

    final previews = allBeneficiaries.map((b) {
      return BeneficiaryPreview(
        id: b.id,
        name: '${b.firstName} ${b.fatherName} ${b.lastName}',
        nationalId: b.nationalId,
        phoneNumber: b.phoneNumber,
      );
    }).toList();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => CopyFromBeneficiaryDialog(
          beneficiaries: previews,
          onSelect: (beneficiaryId) async {
            final beneficiary = allBeneficiaries.firstWhere(
              (b) => b.id == beneficiaryId,
            );
            _populateControllers(beneficiary);
            
            _controllers.nationalIdController.clear();
            
            if (mounted) {
              EnhancedSnackbar.showSuccess(
                context,
                message: 'تم نسخ البيانات بنجاح',
              );
            }
          },
        ),
      );
    }
    */
  }

  void _handleClearAllFields() {
    showDialog(
      context: context,
      builder: (context) => ClearFieldsDialog(
        onConfirm: () {
          _clearAllControllers();
          HapticFeedback.mediumImpact();
          EnhancedSnackbar.showSuccess(context, message: 'تم مسح جميع الحقول');
        },
      ),
    );
  }

  Future<void> _handlePasteData() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null || clipboardData.text == null) {
      if (mounted) {
        EnhancedSnackbar.showInfo(context, message: 'الحافظة فارغة');
      }
      return;
    }

    // Simple paste - just paste into first field
    _controllers.firstNameController.text = clipboardData.text!;

    if (mounted) {
      EnhancedSnackbar.showSuccess(context, message: 'تم اللصق من الحافظة');
    }
  }

  void _handleFillDemoData() {
    _controllers.firstNameController.text = 'محمد';
    _controllers.fatherNameController.text = 'أحمد';
    _controllers.grandfatherNameController.text = 'علي';
    _controllers.lastNameController.text = 'الأحمدي';
    _controllers.motherNameController.text = 'فاطمة';
    _controllers.nationalIdController.text = '123456789012345678';
    _controllers.phoneController.text = '0595735352';
    _controllers.addressController.text = 'بغداد - الكرادة';
    _controllers.selectedGender = 'ذكر';
    _controllers.selectedMaritalStatus = 'متزوج';
    unawaited(_normalizeAllTaxonomySelections());

    setState(() {});

    EnhancedSnackbar.showSuccess(context, message: 'تم ملء البيانات التجريبية');
  }

  /// ✨ Fill form from Civil Registry data
  void _fillFromCivilRegistry(Map<String, dynamic> data) {
    try {
      debugPrint('🔄 Starting to fill form with data: $data');
      int filledFieldsCount = 0;

      // Parse fullName into parts
      final fullName = data['name'] as String?;
      if (fullName != null && fullName.isNotEmpty) {
        debugPrint('📝 Filling name: $fullName');
        final nameParts = fullName.trim().split(RegExp(r'\s+'));
        if (nameParts.isNotEmpty) {
          _controllers.firstNameController.text = nameParts[0];
          filledFieldsCount++;
          debugPrint('✅ First name: ${nameParts[0]}');
        }
        if (nameParts.length > 1) {
          _controllers.fatherNameController.text = nameParts[1];
          filledFieldsCount++;
          debugPrint('✅ Father name: ${nameParts[1]}');
        }
        if (nameParts.length > 2) {
          _controllers.grandfatherNameController.text = nameParts[2];
          filledFieldsCount++;
          debugPrint('✅ Grandfather name: ${nameParts[2]}');
        }
        if (nameParts.length > 3) {
          _controllers.lastNameController.text = nameParts.sublist(3).join(' ');
          filledFieldsCount++;
          debugPrint('✅ Last name: ${nameParts.sublist(3).join(' ')}');
        }
      }

      // National ID
      final nationalId = data['nationalId'] as String?;
      if (nationalId != null && nationalId.isNotEmpty) {
        _controllers.nationalIdController.text = nationalId;
        filledFieldsCount++;
        debugPrint('✅ National ID: $nationalId');
      }

      // Gender
      final gender = data['gender'] as String?;
      if (gender != null && gender.isNotEmpty) {
        _controllers.selectedGender = gender;
        filledFieldsCount++;
        debugPrint('✅ Gender: $gender');
      }

      // Mother Name
      final motherName = data['motherName'] as String?;
      if (motherName != null && motherName.isNotEmpty) {
        _controllers.motherNameController.text = motherName;
        filledFieldsCount++;
        debugPrint('✅ Mother name: $motherName');
      }

      // Birth Date
      final birthDate = data['birthDate'] as String?;
      if (birthDate != null && birthDate.isNotEmpty) {
        _controllers.birthDateController.text = birthDate;
        filledFieldsCount++;
        debugPrint('✅ Birth date: $birthDate');
      }

      // Address/Location
      final city = data['city'] as String?;
      final governorate = data['governorate'] as String?;

      if (city != null || governorate != null) {
        final addressParts = <String>[];
        if (governorate != null && governorate.isNotEmpty) {
          addressParts.add(governorate);
          _controllers.selectedProvince = governorate;
        }
        if (city != null && city.isNotEmpty) {
          addressParts.add(city);
          _controllers.selectedCity = city;
        }
        if (addressParts.isNotEmpty) {
          _controllers.addressController.text = addressParts.join(' - ');
        }
      }

      // Show success message with count
      debugPrint('✅ Successfully filled $filledFieldsCount fields from civil registry');

      if (mounted && filledFieldsCount > 0) {
        // Force UI update
        setState(() {});
        unawaited(_normalizeAllTaxonomySelections());

        EnhancedSnackbar.showSuccess(
          context,
          message: '✅ تم ملء $filledFieldsCount حقل من السجل المدني',
        );
      } else if (filledFieldsCount == 0) {
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
    if (_tabController.index < FormConstants.totalTabs - 1) {
      HapticPatterns.selection();
      _tabController.animateTo(
        _tabController.index + 1,
        duration: AppDurations.fast,
        curve: AppCurves.smooth,
      );
    }
  }

  /// ➡️ السابق - الرجوع للتاب السابق (يسار في RTL)
  void _handlePreviousTab() {
    if (_tabController.index > 0) {
      HapticPatterns.selection();
      _tabController.animateTo(
        _tabController.index - 1,
        duration: AppDurations.fast,
        curve: AppCurves.smooth,
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
    final result = await showDraftSaveDialog(context);

    if (result != null) {
      final draftName = result['name']!;
      final draftNotes = result['notes']!;

      _isSaving = true; // ⚡ Direct assignment instead of setState

      try {
        final formData = _draftSaveCoordinator.buildManualSaveFormData(_controllers);

        // 💾 Save to local storage using DraftManager
        final draftId = 'draft_${DateTime.now().millisecondsSinceEpoch}';
        await DraftManager.saveDraft(
          draftId: draftId,
          formData: _draftSaveCoordinator.buildDraftEnvelope(
            name: draftName,
            notes: draftNotes,
            formData: formData,
            currentTab: _tabController.index,
            beneficiaryId: widget.beneficiaryId,
          ),
        );

        if (!mounted) return;
        setState(() {
          _lastSaved = DateTime.now();
          _hasUnsavedChanges = false;
          _isSaving = false;
        });

        if (mounted) {
          HapticFeedback.mediumImpact();
          // 🎬 Show success animation
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            builder: (context) => Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
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

          // Show info about viewing drafts
          EnhancedSnackbar.showInfo(
            context,
            message: 'يمكنك عرض المسودات المحفوظة من القائمة',
          );
        }
      } catch (e, stackTrace) {
        if (!mounted) return;
        _isSaving = false; // ⚡ Direct assignment
        if (mounted) {
          HapticFeedback.heavyImpact();
          final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
          EnhancedSnackbar.showError(context, message: errorMsg);
          debugPrint('❌ Save draft error: $e');
        }
      }
    }
  }

  /// 📋 Show Drafts List
  // ignore: unused_element
  Future<void> _showDraftsList() async {
    try {
      final drafts = await DraftManager.getAllDrafts();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ResponsiveBottomSheet(
          title: 'المسودات المحفوظة (${drafts.length})',
          icon: Icons.drafts,
          child: drafts.isEmpty
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
                  itemCount: drafts.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final draft = drafts[index];
                    final savedAt = DateTime.parse(draft['savedAt']);
                    final draftName = draft['name'] ?? 'مسودة';

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
                          draftName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'حُفظت: ${_formatDateTime(savedAt)}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => ResponsiveDialog(
                                    title: 'حذف المسودة',
                                    icon: Icons.delete_outline,
                                    iconColor: Colors.red,
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
                                    draft['draftId'],
                                  );
                                  Navigator.pop(context);
                                  _showDraftsList();
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await _loadDraft(draft);
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
    final trace = FormFlowTracer.start('loadDraft');
    try {
      _isLoading = true;
      trace.startStep('applyDraft');

      final result = _draftLoadCoordinator.applyDraft(
        controllers: _controllers,
        draft: draft,
      );
      await _normalizeAllTaxonomySelections();
      trace.endStep('applyDraft');

      // Navigate to saved tab (defensive clamp for legacy drafts)
      final safeTab = result.currentTab.clamp(0, FormConstants.totalTabs - 1);
      _tabController.animateTo(safeTab);

      if (!mounted) return;
      _isLoading = false;
      _hasUnsavedChanges = true;

      if (mounted) {
        _feedbackCoordinator.showSuccess(
          context,
          'تم تحميل المسودة "${draft['name']}" بنجاح',
        );
      }
      final elapsed = trace.end(result: 'success');
      _flowMetricsCollector.record(operation: 'loadDraft', durationMs: elapsed);
    } catch (e, stackTrace) {
      if (!mounted) return;
      _isLoading = false;
      if (mounted) {
        final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
        _feedbackCoordinator.showError(context, errorMsg);
        debugPrint('❌ Load draft error: $e');
      }
      final elapsed = trace.end(result: 'error');
      _flowMetricsCollector.record(operation: 'loadDraft', durationMs: elapsed);
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

  @override
  void dispose() {
    _uiWatchdogTimer?.cancel();
    _nonCriticalUiTimer?.cancel();
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
    _controllers.removeListener(_onFormChanged);
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
    _hasUnsavedChangesNotifier.dispose();
    _perfOverlayVersionNotifier.dispose();

    super.dispose();
  }

  /// 🔍 Scroll to first error and show detailed message
  void _scrollToFirstError() {
    // تحديد الحقول الفارغة في كل تبويب
    final Map<int, List<String>> errorsByTab = {};

    // تبويب 0: المعلومات الأساسية
    final basicErrors = <String>[];
    if (_controllers.firstNameController.text.trim().isEmpty) {
      basicErrors.add('الاسم الأول');
    }
    if (_controllers.fatherNameController.text.trim().isEmpty) {
      basicErrors.add('اسم الأب');
    }
    if (_controllers.lastNameController.text.trim().isEmpty) {
      basicErrors.add('اسم العائلة');
    }
    if (_controllers.nationalIdController.text.trim().isEmpty) {
      basicErrors.add('الرقم الوطني');
    } else if (_controllers.nationalIdController.text.trim().length != FormConstants.nationalIdLength) {
      basicErrors.add('الرقم الوطني (غير صحيح)');
    }
    if (_controllers.selectedGender == null) {
      basicErrors.add('الجنس');
    }
    if (basicErrors.isNotEmpty) {
      errorsByTab[0] = basicErrors;
    }

    // تبويب 1: معلومات الاتصال
    final contactErrors = <String>[];
    if (_controllers.phoneController.text.trim().isEmpty) {
      contactErrors.add('رقم الهاتف');
    }
    if (contactErrors.isNotEmpty) {
      errorsByTab[1] = contactErrors;
    }

    // إيجاد أول تبويب به أخطاء
    if (errorsByTab.isNotEmpty) {
      final firstErrorTab = errorsByTab.keys.first;
      final errorFields = errorsByTab[firstErrorTab]!;

      // الانتقال للتبويب
      if (_tabController.index != firstErrorTab) {
        _tabController.animateTo(firstErrorTab);
      }

      // عرض رسالة مفصلة مع haptic feedback
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final tabName = firstErrorTab == 0
              ? 'المعلومات الأساسية'
              : firstErrorTab == 1
                  ? 'معلومات الاتصال'
                  : firstErrorTab == 2
                      ? 'العائلة'
                      : 'المرفقات';

          EnhancedSnackbar.showError(
            context,
            message: '⚠️ يرجى تعبئة الحقول التالية في "$tabName":\n• ${errorFields.join('\n• ')}',
          );

          // تحريك التركيز للحقل الأول
          if (firstErrorTab == 0 && _firstFieldFocusNode.canRequestFocus) {
            _firstFieldFocusNode.requestFocus();
          }
        }
      });
    }
  }

  Future<void> _saveFamilyMembers(String beneficiaryId) async {
    await FamilySaveHelper.saveFamilyMembers(
      database: ref.read(databaseProvider),
      beneficiaryId: beneficiaryId,
      livingMembers: _controllers.livingMembers,
      deceasedMembers: _controllers.deceasedMembers,
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
        return;
      }

      if (!_formKey.currentState!.validate()) {
        if (isAutoSave) {
          final elapsed = trace.end(result: 'autosave_validation_failed');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
          return;
        }
        _scrollToFirstError();
        _feedbackCoordinator.showError(context, FormConstants.requiredFieldMessage);
        final elapsed = trace.end(result: 'validation_failed');
        _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
        return;
      }

      _isSaving = true; // ⚡ Direct assignment

      final currentBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      final now = DateTime.now();
      final enteredFileNo = _controllers.fileNumberController.text.trim();
      final beneficiary = BeneficiaryFormDataHandler.buildBeneficiary(
        controllers: _controllers,
        beneficiaryId: widget.beneficiaryId,
        fileNo: enteredFileNo.isNotEmpty
            ? enteredFileNo
            : (currentBeneficiary?.fileNo ?? 'F-${now.millisecondsSinceEpoch}'),
        createdAt: currentBeneficiary?.createdAt ?? now,
      );
      ref.read(beneficiaryFormProvider.notifier).updateField((_) => beneficiary);
      trace.startStep('orchestration');
      final result = await _formSaveCoordinator.execute(
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
          final attachmentResult = await SaveOperationsHelper.saveAttachments(
            database: ref.read(databaseProvider),
            beneficiaryId: beneficiaryId,
            pendingFiles: _controllers.pendingAttachmentFiles,
          );
          return attachmentResult.failedCount;
        },
        saveFamilyMembers: _saveFamilyMembers,
        clearPendingAttachments: _controllers.pendingAttachmentFiles.clear,
      );
      trace.endStep('orchestration');

      if (result.status == FormSaveStatus.saved && mounted) {
        if (result.failedAttachmentsCount > 0 && !isAutoSave) {
          _feedbackCoordinator.showWarning(context, 'بعض الملفات فشل حفظها (${result.failedAttachmentsCount})');
        }

        if (!mounted) return;
        // ⚡ Direct assignments instead of setState
        _lastSaved = DateTime.now();
        _hasUnsavedChanges = false;

        if (!isAutoSave) {
          if (mounted) {
            _feedbackCoordinator.showSaveSuccessOverlay(context, FormConstants.saveSuccessMessage);
          }

          if (!mounted) return;
          _isSaving = false; // ⚡ Direct assignment
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted && context.mounted) {
            context.pop(true);
          }
          final elapsed = trace.end(result: 'saved');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
        } else {
          if (!mounted) return;
          _isSaving = false; // ⚡ Direct assignment
          final elapsed = trace.end(result: 'autosaved');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
        }
      } else {
        if (!mounted) return;
        _isSaving = false; // ⚡ Direct assignment
        if (result.status == FormSaveStatus.duplicateNationalId) {
          final elapsed = trace.end(result: 'duplicate');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
          return;
        }
        if (result.status == FormSaveStatus.missingSavedBeneficiary) {
          final elapsed = trace.end(result: 'missing_saved_beneficiary');
          _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
          return;
        }
        if (!isAutoSave) {
          _feedbackCoordinator.showError(
            context,
            'فشل في حفظ البيانات',
            onRetry: () => _handleSave(),
          );
        }
        final elapsed = trace.end(result: 'save_failed');
        _flowMetricsCollector.record(operation: 'save', durationMs: elapsed);
      }
    } finally {
      _isSavingLocked = false;
    }
  }

  Future<bool> _ensureTaxonomyCoverageBeforeSave() async {
    if (_missingTaxonomyGroupsNotifier.value.isEmpty) {
      await _refreshTaxonomyCoverage(showSnackBar: false);
    }

    final missingGroups = _missingTaxonomyGroupsNotifier.value;
    if (missingGroups.isEmpty) {
      return true;
    }

    final missingNames = missingGroups.map((group) => group.arabicName).join('، ');
    _feedbackCoordinator.showWarning(
      context,
      'تعذّر إكمال الحفظ قبل مزامنة التصنيفات الناقصة: $missingNames',
    );
    return false;
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

      final deleteUseCase = ref.read(deleteBeneficiaryUseCaseProvider);
      trace.startStep('deleteUseCase');
      final deleteResult = await _beneficiaryDeleteCoordinator.execute(
        beneficiaryId: beneficiary.id,
        deleteAction: deleteUseCase.execute,
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
            child: child!,
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
                                                  'Taxonomy Coverage: filled=$filledGroups/$totalGroups',
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

                        if (kDebugMode)
                          _buildIdentityDebugCard(
                            context,
                            resolvedBeneficiaryId: resolvedBeneficiaryId,
                            routeBeneficiaryId: widget.beneficiaryId,
                          ),

                        // 📝 Form Content - Separated widget
                        Expanded(
                          child: FormContentWidget(
                            tabController: _tabController,
                            controllers: _controllers,
                            onBirthDateTap: () => _selectDate(context),
                            firstFieldFocusNode: _firstFieldFocusNode,
                            beneficiaryId: resolvedBeneficiaryId ?? widget.beneficiaryId,
                            showFieldHelpers: _showFieldHelpers,
                            onFinalSave: _handleFinalSaveFromReview, // 🆕 Pass callback
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
                  if (_showStatistics)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: CompletionStatsWidget(
                        overallCompletion: _calculateFilledFields() / 12 * 100,
                        completedFields: _calculateFilledFields(),
                        totalFields: 12,
                        tabCompletions: const {
                          'البيانات الأساسية': 75.0,
                          'أفراد الأسرة': 50.0,
                          'المرفقات': 25.0,
                          'التقييم': 90.0,
                        },
                        onTap: _toggleStatistics,
                      ),
                    ),

                  // 🎓 Tour Guide
                  if (_showTourGuide)
                    TourGuide(
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
                        setState(() => _showTourGuide = false);
                      },
                      onSkip: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await _bootstrapController.markTourSeen(prefs);
                        setState(() => _showTourGuide = false);
                      },
                    ),

                  // 📱 Mobile Quick Actions
                  if (_nonCriticalUiReady)
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSavingNotifier,
                      builder: (context, isSaving, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isDeletingNotifier,
                          builder: (context, isDeleting, _) {
                            return MobileQuickActions(
                              onCopyFromBeneficiary: _handleCopyFromBeneficiary,
                              onClearAllFields: _handleClearAllFields,
                              onPasteData: _handlePasteData,
                              onFillDemoData: _handleFillDemoData,
                              enabled: !isSaving && !isDeleting,
                            );
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
                color: Colors.black.withOpacity(0.70),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white24),
              ),
              child: _showPerfOverlay
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PERF DEBUG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'sync=${isSyncRunning ? 'on' : 'off'} | emergency=${_uiEmergencyMode ? 'on' : 'off'} | lagBurst=$_uiLagBurstCount',
                          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'frames=$_totalFramesObserved slowBuild=$_slowBuildFrames slowRaster=$_slowRasterFrames verySlow=$_verySlowFrames',
                          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                        ),
                        if (topEntries.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          for (final entry in topEntries)
                            Text(
                              '${entry.key}: n=${entry.value.count} avg=${entry.value.averageMs}ms max=${entry.value.maxMs}ms >50=${entry.value.over50Ms}',
                              style: TextStyle(color: Colors.white, fontSize: 10.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ],
                    )
                  : Text(
                      'PERF',
                      style: TextStyle(
                        color: Colors.white,
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
          child: child!,
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
