import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/errors/user_friendly_error.dart';
import '../../../../core/utils/value_listenable_builder.dart'; // ⚡ Multi ValueListenableBuilder
import '../../../../core/error_handling/error_handler.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/utils/haptic_patterns.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart'; // 📱 Responsive Bottom Sheet
import '../../../../core/validation/field_validators.dart'; // 📋 Field Validators

import '../providers/beneficiary_form_provider.dart';
import '../providers/beneficiary_dependencies.dart';
import '../widgets/v2/v2_widgets.dart';
import '../../domain/entities/beneficiary.dart';

// Helper Classes
import 'v2_form_helpers/form_controllers.dart';
import 'v2_form_helpers/form_data_handler.dart';
import 'v2_form_helpers/beneficiary_builder.dart';
import 'v2_form_helpers/save_operations_helper.dart';
import 'v2_form_helpers/family_save_helper.dart';
import 'v2_form_helpers/form_constants.dart';
import 'v2_form_helpers/form_history.dart';
import 'v2_form_helpers/draft_manager.dart'; // 💾 Draft Manager

// Widgets
import 'v2_form_helpers/widgets/loading_overlay.dart' as local;
import 'v2_form_helpers/widgets/skeleton_loader.dart'; // 💀 Skeleton screens
import 'v2_form_helpers/widgets/keyboard_shortcuts_handler.dart';
import 'v2_form_helpers/widgets/final_review_sheet.dart'; // 📋 Final Review
import 'v2_form_helpers/widgets/draft_save_dialog.dart'; // 💾 Draft Save
import 'v2_form_helpers/widgets/keyboard_shortcuts_help.dart'; // ⌨️ Shortcuts Help
import 'v2_form_helpers/widgets/help_widgets.dart'; // 🎓 Help Widgets
import 'v2_form_helpers/widgets/form_page_widgets.dart'; // 📦 Extracted Form Widgets
import 'v2_form_helpers/widgets/success_animation.dart'; // ✅ Success Animation

// 🚀 Performance-optimized widgets
import 'v2_form_helpers/widgets/form_error_banner_widget.dart';
import 'v2_form_helpers/widgets/form_app_bar_widget.dart';
import 'v2_form_helpers/widgets/form_content_widget.dart';
import 'v2_form_helpers/widgets/form_bottom_nav_widget.dart';
import 'v2_form_helpers/widgets/form_progress_widgets.dart'; // 📊 Progress widgets

// 🚀 Phase 3 - Advanced UX Features
import 'v2_form_helpers/widgets/field_dependency_system.dart'; // 🔗 Field Dependencies
import 'v2_form_helpers/widgets/smart_field_hints.dart'; // 💡 Smart Hints
// Disabled for performance: import 'v2_form_helpers/widgets/form_progress_tracker.dart';
import 'v2_form_helpers/widgets/mobile_quick_actions.dart'; // 📱 Mobile Quick Actions
import 'v2_form_helpers/utils/animation_helpers.dart'; // 🎬 Animation helpers

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
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late final BeneficiaryFormControllers _controllers;
  late final FormHistory<FormStateSnapshot> _formHistory;

  // ⚡ Performance: استخدام ValueNotifier بدلاً من setState
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);
  bool _isDeleting = false;
  bool _isLoading = false;
  bool _isSavingLocked = false;

  final ValueNotifier<DateTime?> _lastSavedNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _hasUnsavedChangesNotifier = ValueNotifier(false);

  // Setters للكتابة السهلة (Getters غير مطلوبة لأننا نستخدم ValueListenableBuilder)
  bool get _isSaving => _isSavingNotifier.value;
  set _isSaving(bool value) => _isSavingNotifier.value = value;

  set _lastSaved(DateTime? value) => _lastSavedNotifier.value = value;

  set _hasUnsavedChanges(bool value) => _hasUnsavedChangesNotifier.value = value;

  // 💾 Auto-draft ID - ثابت لتجنب إنشاء مسودات متكررة
  String? _autoSaveDraftId;

  // 🆕 New features state
  bool _showStatistics = false;
  bool _showTourGuide = false;
  bool _showFieldHelpers = false; // ✅ مخفية افتراضياً - تبسيط
  // ⚠️ Search moved to FormContentWidget local state for performance

  final FocusNode _firstFieldFocusNode = FocusNode();

  // 🔄 Debouncing for auto-save
  late final Debouncer _autoSaveDebouncer; // ✅ Debouncer for auto-save
  // Timer to check and offer auto-saved drafts (cancelable)
  Timer? _offerAutoSavedDraftsTimer;
  // Timer to show first-time user tour (cancelable)
  Timer? _tourShowTimer;

  // 🚀 Phase 3 - Advanced UX Features
  late final FieldDependencyController _dependencyController;
  final Map<String, SmartHint> _fieldHints = {}; // Smart hints for fields

  @override
  void initState() {
    super.initState();

    // ✅ Initialize Debouncer for auto-save (2 seconds)
    _autoSaveDebouncer = Debouncer(delay: const Duration(seconds: 2));

    _controllers = BeneficiaryFormControllers(onAutoSave: _performAutoSave);
    _formHistory = FormHistory<FormStateSnapshot>(maxHistorySize: 50);
    _tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: this,
    );

    // 🚀 Initialize Phase 3 features
    _dependencyController = FieldDependencyController();
    _setupFieldDependencies();
    _setupSmartHints();

    // ⚠️ DISABLED for performance - causes setState on every keystroke
    // Listen to controller changes for history
    // _controllers.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
      _checkFirstTimeUser();
    });
  }

  /// 🎓 Check if first time user and show tour
  void _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool('has_seen_form_tour') ?? false;

    if (!hasSeenTour && mounted) {
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

      // ✅ Auto-save as draft instead of full save
      // This prevents validation errors and allows partial forms
      await _autoSaveDraft();
    });
  }

  /// 💾 Auto-save as draft (silent, no validation required)
  Future<void> _autoSaveDraft() async {
    try {
      final formData = {
        'firstName': _controllers.firstNameController.text,
        'fatherName': _controllers.fatherNameController.text,
        'grandfatherName': _controllers.grandfatherNameController.text,
        'lastName': _controllers.lastNameController.text,
        'motherName': _controllers.motherNameController.text,
        'nationalId': _controllers.nationalIdController.text,
        'birthDate': _controllers.birthDateController.text,
        'phone': _controllers.phoneController.text,
        'altPhone': _controllers.altPhoneController.text,
        'address': _controllers.addressController.text,
        'neighborhood': _controllers.neighborhoodController.text,
        'notes': _controllers.notesController.text,
        'gender': _controllers.selectedGender,
        'maritalStatus': _controllers.selectedMaritalStatus,
        'educationLevel': _controllers.selectedEducationLevel,
        'employmentStatus': _controllers.selectedEmploymentStatus,
        'category': _controllers.selectedCategory,
        'displacementStatus': _controllers.selectedDisplacementStatus,
        'healthStatus': _controllers.selectedHealthStatus,
        'housingStatus': _controllers.selectedHousingStatus,
        'housingType': _controllers.selectedHousingType,
        'hasDisability': _controllers.hasDisability,
      };

      // استخدام ID ثابت للمسودة التلقائية - يتم التحديث بدلاً من الإنشاء
      _autoSaveDraftId ??= widget.beneficiaryId ??
          'auto_draft_${_controllers.nationalIdController.text.isNotEmpty ? _controllers.nationalIdController.text : 'temp_${DateTime.now().millisecondsSinceEpoch}'}';

      final firstName = _controllers.firstNameController.text;
      final lastName = _controllers.lastNameController.text;
      final draftName =
          firstName.isNotEmpty ? 'حفظ تلقائي - $firstName ${lastName.isNotEmpty ? lastName : ""}' : 'مسودة جديدة';

      await DraftManager.saveDraft(
        draftId: _autoSaveDraftId!,
        formData: {
          'name': draftName,
          'notes': 'آخر تحديث: ${DateTime.now().toString().split('.')[0]}',
          'formData': formData,
          'currentTab': _tabController.index,
          'beneficiaryId': widget.beneficiaryId,
          'isAutoSaved': true,
        },
      );

      if (mounted) {
        setState(() {
          _lastSaved = DateTime.now();
        });
      }

      debugPrint('✅ Auto-saved draft successfully');
    } catch (e, stackTrace) {
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      debugPrint('❌ Auto-save failed: $errorMsg (technical: $e)');
      // Silent failure - don't disturb user with auto-save errors
    }
  }

  void _initializeForm() async {
    setState(() => _isLoading = true);

    if (widget.beneficiaryId != null) {
      await ref.read(beneficiaryFormProvider.notifier).loadBeneficiary(widget.beneficiaryId!);

      final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      if (beneficiary != null) {
        _populateControllers(beneficiary);
        _saveToHistory('Initial load');
      }
    } else {
      _clearAllControllers();
      ref.read(beneficiaryFormProvider.notifier).createNew();

      // ✨ ملء البيانات من السجل المدني إذا كانت موجودة
      if (widget.civilRegistryData != null) {
        debugPrint('📋 Civil Registry Data received: ${widget.civilRegistryData}');
        // تأخير بسيط للسماح للـ controllers بالتحميل
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _fillFromCivilRegistry(widget.civilRegistryData!);
            setState(() {
              _hasUnsavedChanges = true;
            });
          }
        });
      } else {
        // ✅ التحقق من وجود مسودات تلقائية واقتراحها على المستخدم (cancelable)
        _offerAutoSavedDraftsTimer = Timer(
          const Duration(milliseconds: 500),
          () async {
            if (mounted) {
              await _checkAndOfferAutoSavedDrafts();
              _firstFieldFocusNode.requestFocus();
            }
          },
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  /// 💾 Check for auto-saved drafts and offer to restore
  Future<void> _checkAndOfferAutoSavedDrafts() async {
    try {
      final drafts = await DraftManager.getAllDrafts();

      // تصفية المسودات التلقائية فقط
      final autoSavedDrafts = drafts.where((d) => d['isAutoSaved'] == true).toList();

      if (autoSavedDrafts.isEmpty) return;

      // عرض أحدث مسودة تلقائية فقط
      final latestDraft = autoSavedDrafts.first;
      final draftName = latestDraft['name'] ?? 'مسودة';
      final savedAt = DateTime.parse(latestDraft['savedAt']);
      final timeSince = _formatDateTime(savedAt);

      if (!mounted) return;

      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.restore_outlined, color: Colors.blue, size: 48.sp),
          title: const Text('استعادة مسودة تلقائية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم العثور على مسودة محفوظة تلقائياً:',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16.sp,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            draftName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          timeSince,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'هل تريد استعادة هذه المسودة؟',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('بدء جديد'),
            ),
            AnimatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: FilledButton.icon(
                onPressed: null, // handled by AnimatedButton
                icon: const Icon(Icons.restore),
                label: const Text('استعادة المسودة'),
              ),
            ),
          ],
        ),
      );

      if (shouldRestore == true && mounted) {
        await _loadDraft(latestDraft);
      }
    } catch (e, stackTrace) {
      final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
      debugPrint('❌ Error checking drafts: $errorMsg (technical: $e)');
      // Silent failure - don't block form initialization
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
    _controllers.hasDisability = false;
    _controllers.updatePendingFiles([]);

    ref.read(civilRegistryProvider.notifier).reset();
  }

  void _populateControllers(Beneficiary beneficiary) {
    BeneficiaryFormDataHandler.populateControllers(
      _controllers,
      beneficiary,
      (fn) => fn(),
    );
    _loadFamilyMembers(beneficiary.id);
  }

  Future<void> _loadFamilyMembers(String beneficiaryId) async {
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
    // Add common dependency scenarios
    final scenarios = DependencyScenarios.getAllCommonScenarios();
    for (final scenario in scenarios) {
      _dependencyController.addDependency(scenario);
    }

    // Listen to text field changes
    _controllers.firstNameController.addListener(() {
      _dependencyController.updateField(
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

        EnhancedSnackbar.showSuccess(
          context,
          message: '✅ تم ملء $filledFieldsCount حقل من السجل المدني',
          duration: const Duration(seconds: 3),
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
  Future<void> _handleDraftSave() async {
    final result = await showDraftSaveDialog(context);

    if (result != null) {
      final draftName = result['name']!;
      final draftNotes = result['notes']!;

      _isSaving = true; // ⚡ Direct assignment instead of setState

      try {
        // 📦 Prepare draft data
        final formData = {
          'firstName': _controllers.firstNameController.text,
          'fatherName': _controllers.fatherNameController.text,
          'grandfatherName': _controllers.grandfatherNameController.text,
          'lastName': _controllers.lastNameController.text,
          'motherName': _controllers.motherNameController.text,
          'nationalId': _controllers.nationalIdController.text,
          'birthDate': _controllers.birthDateController.text,
          'phone': _controllers.phoneController.text,
          'altPhone': _controllers.altPhoneController.text,
          'address': _controllers.addressController.text,
          'neighborhood': _controllers.neighborhoodController.text,
          'notes': _controllers.notesController.text,
          'gender': _controllers.selectedGender,
          'maritalStatus': _controllers.selectedMaritalStatus,
          'educationLevel': _controllers.selectedEducationLevel,
        };

        // 💾 Save to local storage using DraftManager
        final draftId = 'draft_${DateTime.now().millisecondsSinceEpoch}';
        await DraftManager.saveDraft(
          draftId: draftId,
          formData: {
            'name': draftName,
            'notes': draftNotes,
            'formData': formData,
            'currentTab': _tabController.index,
            'beneficiaryId': widget.beneficiaryId,
          },
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
            barrierDismissible: true,
            barrierColor: Colors.black26,
            builder: (context) => Center(
              child: FormAnimations.successCheckmark(
                size: 80.sp,
                color: Theme.of(context).colorScheme.primary,
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
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                                  builder: (context) => AlertDialog(
                                    title: Text('حذف المسودة'),
                                    content: Text(
                                      'هل تريد حذف هذه المسودة؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          false,
                                        ),
                                        child: Text('إلغاء'),
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
    try {
      setState(() => _isLoading = true);

      final formData = draft['formData'] as Map<String, dynamic>;

      // Fill controllers with draft data
      _controllers.firstNameController.text = formData['firstName'] ?? '';
      _controllers.fatherNameController.text = formData['fatherName'] ?? '';
      _controllers.grandfatherNameController.text = formData['grandfatherName'] ?? '';
      _controllers.lastNameController.text = formData['lastName'] ?? '';
      _controllers.motherNameController.text = formData['motherName'] ?? '';
      _controllers.nationalIdController.text = formData['nationalId'] ?? '';
      _controllers.phoneController.text = formData['phone'] ?? '';
      _controllers.altPhoneController.text = formData['altPhone'] ?? '';
      _controllers.addressController.text = formData['address'] ?? '';
      _controllers.neighborhoodController.text = formData['neighborhood'] ?? '';
      _controllers.notesController.text = formData['notes'] ?? '';

      if (formData['birthDate'] != null) {
        _controllers.birthDateController.text = formData['birthDate'];
      }

      // Set dropdowns
      if (!mounted) return;
      setState(() {
        _controllers.selectedGender = formData['gender'];
        _controllers.selectedMaritalStatus = formData['maritalStatus'];
        _controllers.selectedEducationLevel = formData['educationLevel'];
      });

      // Navigate to saved tab
      final savedTab = draft['currentTab'] ?? 0;
      _tabController.animateTo(savedTab);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = true;
      });

      if (mounted) {
        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم تحميل المسودة "${draft['name']}" بنجاح',
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
        EnhancedSnackbar.showError(context, message: errorMsg);
        debugPrint('❌ Load draft error: $e');
      }
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
    _autoSaveDebouncer.dispose(); // Dispose debouncer
    _offerAutoSavedDraftsTimer?.cancel();
    _tourShowTimer?.cancel();
    _controllers.removeListener(_onFormChanged);
    _controllers.dispose();
    _tabController.dispose();
    _firstFieldFocusNode.dispose();
    _formHistory.dispose();
    // ⚠️ _searchController moved to FormContentWidget

    // ⚡ Dispose ValueNotifiers
    _isSavingNotifier.dispose();
    _lastSavedNotifier.dispose();
    _hasUnsavedChangesNotifier.dispose();

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

  Future<void> _handleSave({bool isAutoSave = false}) async {
    if (_isSavingLocked) return;

    _isSavingLocked = true;

    try {
      if (!_formKey.currentState!.validate()) {
        if (isAutoSave) return;
        _scrollToFirstError();
        EnhancedSnackbar.showError(
          context,
          message: FormConstants.requiredFieldMessage,
        );
        return;
      }

      _isSaving = true; // ⚡ Direct assignment

      final currentBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      final beneficiary = BeneficiaryEntityBuilder.build(
        controllers: _controllers,
        existingId: widget.beneficiaryId,
        existingFileNo: currentBeneficiary?.fileNo,
        existingCreatedAt: currentBeneficiary?.createdAt,
      );

      final repository = ref.read(beneficiaryRepositoryProvider);
      final hasDuplicate = await SaveOperationsHelper.checkDuplicate(
        context: context,
        repository: repository,
        nationalId: _controllers.nationalIdController.text.trim(),
        isNewBeneficiary: widget.beneficiaryId == null,
        currentBeneficiaryId: widget.beneficiaryId,
      );

      if (hasDuplicate) {
        if (!mounted) return;
        _isSaving = false; // ⚡ Direct assignment
        return;
      }

      ref.read(beneficiaryFormProvider.notifier).updateField((_) => beneficiary);
      final success = await ref.read(beneficiaryFormProvider.notifier).save();

      if (success && mounted) {
        final savedBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
        if (savedBeneficiary == null) {
          if (!mounted) return;
          _isSaving = false; // ⚡ Direct assignment
          return;
        }

        final attachmentResult = await SaveOperationsHelper.saveAttachments(
          database: ref.read(databaseProvider),
          beneficiaryId: savedBeneficiary.id,
          pendingFiles: _controllers.pendingAttachmentFiles,
        );

        if (attachmentResult.failedCount > 0 && mounted && !isAutoSave) {
          EnhancedSnackbar.showWarning(
            context,
            message: 'بعض الملفات فشل حفظها (${attachmentResult.failedCount})',
          );
        }

        _controllers.pendingAttachmentFiles.clear();
        await _saveFamilyMembers(savedBeneficiary.id);

        if (!mounted) return;
        // ⚡ Direct assignments instead of setState
        _lastSaved = DateTime.now();
        _hasUnsavedChanges = false;

        if (!isAutoSave) {
          HapticPatterns.success();
          if (mounted) {
            // 🎉 Show success animation overlay
            SuccessOverlay.show(
              context,
              message: FormConstants.saveSuccessMessage,
            );
          }

          if (!mounted) return;
          _isSaving = false; // ⚡ Direct assignment
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted && context.mounted) {
            context.pop(true);
          }
        } else {
          if (!mounted) return;
          _isSaving = false; // ⚡ Direct assignment
        }
      } else {
        if (!mounted) return;
        _isSaving = false; // ⚡ Direct assignment
        if (!isAutoSave && mounted) {
          HapticPatterns.error();
          EnhancedSnackbar.showError(
            context,
            message: 'فشل في حفظ البيانات',
            onRetry: () => _handleSave(),
          );
        }
      }
    } finally {
      _isSavingLocked = false;
    }
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
        cancelText: 'إلغاء',
        isDangerous: true,
        icon: Icons.delete_forever_rounded,
        onConfirm: () {},
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);

      try {
        final deleteUseCase = ref.read(deleteBeneficiaryUseCaseProvider);
        await deleteUseCase.execute(beneficiary.id);

        if (mounted) {
          if (!mounted) return;
          setState(() => _isDeleting = false);
          HapticFeedback.lightImpact();
          EnhancedSnackbar.showSuccess(
            context,
            message: FormConstants.deleteSuccessMessage,
          );

          if (context.mounted) {
            context.pop();
          }
        }
      } catch (e, stackTrace) {
        if (mounted) {
          if (!mounted) return;
          setState(() => _isDeleting = false);
          HapticFeedback.heavyImpact();
          final errorMsg = UserFriendlyError.getMessage(e, stackTrace);
          EnhancedSnackbar.showError(
            context,
            message: errorMsg,
            onRetry: _handleDelete,
          );
          debugPrint('❌ Delete error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // 📱 AppBar - Separated widget with ValueListenableBuilder
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 52),
            child: ValueListenableBuilder3<bool, DateTime?, bool>(
              first: _isSavingNotifier,
              second: _lastSavedNotifier,
              third: _hasUnsavedChangesNotifier,
              builder: (context, isSaving, lastSaved, hasUnsavedChanges, _) {
                return FormAppBarWidget(
                  beneficiaryId: widget.beneficiaryId,
                  isSaving: isSaving,
                  lastSaved: lastSaved,
                  hasUnsavedChanges: hasUnsavedChanges,
                  showStatistics: _showStatistics,
                  showFieldHelpers: _showFieldHelpers,
                  // onToggleSearch removed - search is local to FormContentWidget
                  onToggleStatistics: _toggleStatistics,
                  onToggleFieldHelpers: () {
                    setState(() => _showFieldHelpers = !_showFieldHelpers);
                  },
                  onViewDrafts: _showDraftsList,
                  onSaveDraft: hasUnsavedChanges ? _handleDraftSave : null,
                  onShowHelp: () => showKeyboardShortcutsHelp(context),
                  onDelete: widget.beneficiaryId != null ? _handleDelete : null,
                  onUndo: _formHistory.canUndo ? _handleUndo : null,
                  onRedo: _formHistory.canRedo ? _handleRedo : null,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(52.h),
                    child: FormProgressIndicator(
                      filledFields: _calculateFilledFields(),
                      totalRequiredFields: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          body: _isLoading
              ? const SkeletonFormScreen()
              : Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 🚨 Error Banner - Separated widget
                          const FormErrorBanner(),

                          // 📝 Form Content - Separated widget
                          Expanded(
                            child: FormContentWidget(
                              tabController: _tabController,
                              controllers: _controllers,
                              onBirthDateTap: () => _selectDate(context),
                              firstFieldFocusNode: _firstFieldFocusNode,
                              beneficiaryId: widget.beneficiaryId,
                              showFieldHelpers: _showFieldHelpers,
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
                        return local.LoadingOverlay(
                          isVisible: isSaving || _isDeleting,
                          message: isSaving ? FormConstants.savingMessage : FormConstants.deletingMessage,
                        );
                      },
                    ),

                    // 🎓 Tour Guide
                    if (_showTourGuide)
                      TourGuide(
                        steps: [
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
                          await prefs.setBool('has_seen_form_tour', true);
                          setState(() => _showTourGuide = false);
                        },
                        onSkip: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('has_seen_form_tour', true);
                          setState(() => _showTourGuide = false);
                        },
                      ),

                    // 📱 Mobile Quick Actions
                    MobileQuickActions(
                      onCopyFromBeneficiary: _handleCopyFromBeneficiary,
                      onClearAllFields: _handleClearAllFields,
                      onPasteData: _handlePasteData,
                      onFillDemoData: _handleFillDemoData,
                      enabled: !_isSaving && !_isDeleting,
                    ),
                  ],
                ),
        ),
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
}
