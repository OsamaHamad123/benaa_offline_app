import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../../core/theme/app_dimensions.dart';

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
import 'v2_form_helpers/widgets/loading_overlay.dart';
import 'v2_form_helpers/widgets/skeleton_loader.dart'; // 💀 Skeleton screens
import 'v2_form_helpers/widgets/enhanced_snackbar.dart';
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

// 🚀 Phase 3 - Advanced UX Features
import 'v2_form_helpers/widgets/field_dependency_system.dart'; // 🔗 Field Dependencies
import 'v2_form_helpers/widgets/smart_field_hints.dart'; // 💡 Smart Hints
// Disabled for performance: import 'v2_form_helpers/widgets/form_progress_tracker.dart';
import 'v2_form_helpers/widgets/mobile_quick_actions.dart'; // 📱 Mobile Quick Actions

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
class BeneficiaryFormPageV3 extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const BeneficiaryFormPageV3({super.key, this.beneficiaryId});

  @override
  ConsumerState<BeneficiaryFormPageV3> createState() =>
      _BeneficiaryFormPageV3State();
}

class _BeneficiaryFormPageV3State extends ConsumerState<BeneficiaryFormPageV3>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late final BeneficiaryFormControllers _controllers;
  late final FormHistory<FormStateSnapshot> _formHistory;

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoading = false;
  bool _isSavingLocked = false;

  DateTime? _lastSaved;
  bool _hasUnsavedChanges = false;

  // 🆕 New features state
  bool _showStatistics = false;
  bool _showTourGuide = false;
  bool _showFieldHelpers = false; // ✅ مخفية افتراضياً - تبسيط
  // ⚠️ Search moved to FormContentWidget local state for performance

  final FocusNode _firstFieldFocusNode = FocusNode();

  // 🔄 Debouncing Timer for auto-save
  Timer? _autoSaveDebouncer;

  // 🚀 Phase 3 - Advanced UX Features
  late final FieldDependencyController _dependencyController;
  final Map<String, SmartHint> _fieldHints = {}; // Smart hints for fields

  @override
  void initState() {
    super.initState();
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
      // Show tour after a short delay
      Future.delayed(const Duration(seconds: 1), () {
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

  /// 🔄 Debounced Auto-Save (2 seconds delay)
  Future<void> _performAutoSave() async {
    if (_isSaving || _isDeleting || _isLoading) return;

    // Cancel previous debouncer
    _autoSaveDebouncer?.cancel();

    // Schedule new auto-save with 2-second delay
    _autoSaveDebouncer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final hasChanges =
          _controllers.firstNameController.text.isNotEmpty ||
          _controllers.nationalIdController.text.isNotEmpty;

      if (!hasChanges) return;

      if (_controllers.firstNameController.text.trim().isEmpty ||
          _controllers.nationalIdController.text.trim().isEmpty ||
          _controllers.nationalIdController.text.trim().length !=
              FormConstants.nationalIdLength) {
        return;
      }

      await _handleSave(isAutoSave: true);
    });
  }

  void _initializeForm() async {
    setState(() => _isLoading = true);

    if (widget.beneficiaryId != null) {
      await ref
          .read(beneficiaryFormProvider.notifier)
          .loadBeneficiary(widget.beneficiaryId!);

      final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      if (beneficiary != null) {
        _populateControllers(beneficiary);
        _saveToHistory('Initial load');
      }
    } else {
      _clearAllControllers();
      ref.read(beneficiaryFormProvider.notifier).createNew();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _firstFieldFocusNode.requestFocus();
        }
      });
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
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
    _controllers.phoneController.text = '07701234567';
    _controllers.addressController.text = 'بغداد - الكرادة';
    _controllers.selectedGender = 'ذكر';
    _controllers.selectedMaritalStatus = 'متزوج';

    setState(() {});

    EnhancedSnackbar.showSuccess(context, message: 'تم ملء البيانات التجريبية');
  }

  /// ⬅️ التالي - الانتقال للتاب التالي (يمين في RTL)
  void _handleNextTab() {
    if (_tabController.index < FormConstants.totalTabs - 1) {
      _tabController.animateTo(_tabController.index + 1);
      HapticFeedback.selectionClick();
    }
  }

  /// ➡️ السابق - الرجوع للتاب السابق (يسار في RTL)
  void _handlePreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
      HapticFeedback.selectionClick();
    }
  }

  /// 📋 Show final review before saving
  Future<void> _showFinalReview() async {
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: FinalReviewSheet(
              formControllers: _controllers,
              scrollController: scrollController,
              onConfirm: () => Navigator.pop(context, true),
              onEdit: () => Navigator.pop(context, false),
            ),
          );
        },
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

      setState(() => _isSaving = true);

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
          EnhancedSnackbar.showSuccess(
            context,
            message: 'تم حفظ المسودة "$draftName" بنجاح ✓',
          );

          // Show button to view drafts
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يمكنك عرض المسودات المحفوظة من القائمة'),
              action: SnackBarAction(
                label: 'عرض',
                onPressed: () => _showDraftsList(),
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (mounted) {
          HapticFeedback.heavyImpact();
          EnhancedSnackbar.showError(context, message: 'فشل حفظ المسودة: $e');
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drafts,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'المسودات المحفوظة (${drafts.length})',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Drafts List
                Expanded(
                  child: drafts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد مسودات محفوظة',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
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
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text('حذف'),
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
              ],
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        EnhancedSnackbar.showError(context, message: 'فشل تحميل المسودات: $e');
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
      _controllers.grandfatherNameController.text =
          formData['grandfatherName'] ?? '';
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        EnhancedSnackbar.showError(context, message: 'فشل تحميل المسودة: $e');
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
    _autoSaveDebouncer?.cancel(); // Cancel debouncer on dispose
    _controllers.removeListener(_onFormChanged);
    _controllers.dispose();
    _tabController.dispose();
    _firstFieldFocusNode.dispose();
    _formHistory.dispose();
    // ⚠️ _searchController moved to FormContentWidget
    super.dispose();
  }

  void _scrollToFirstError() {
    final hasBasicInfoError =
        _controllers.firstNameController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().length !=
            FormConstants.nationalIdLength;

    if (hasBasicInfoError && _tabController.index != 0) {
      _tabController.animateTo(0);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _firstFieldFocusNode.canRequestFocus) {
          _firstFieldFocusNode.requestFocus();
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

      setState(() => _isSaving = true);

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
      );

      if (hasDuplicate) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        return;
      }

      ref
          .read(beneficiaryFormProvider.notifier)
          .updateField((_) => beneficiary);
      final success = await ref.read(beneficiaryFormProvider.notifier).save();

      if (success && mounted) {
        final savedBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
        if (savedBeneficiary == null) {
          if (!mounted) return;
          setState(() => _isSaving = false);
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
        setState(() {
          _lastSaved = DateTime.now();
          _hasUnsavedChanges = false;
        });

        if (!isAutoSave) {
          HapticFeedback.mediumImpact();
          if (mounted) {
            // 🎉 Show success animation overlay
            SuccessOverlay.show(
              context,
              message: FormConstants.saveSuccessMessage,
            );
          }

          if (!mounted) return;
          setState(() => _isSaving = false);
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted && context.mounted) {
            context.pop(true);
          }
        } else {
          if (!mounted) return;
          setState(() => _isSaving = false);
        }
      } else {
        if (!mounted) return;
        setState(() => _isSaving = false);
        if (!isAutoSave && mounted) {
          HapticFeedback.heavyImpact();
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

    HapticFeedback.mediumImpact();

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
      } catch (e) {
        if (mounted) {
          if (!mounted) return;
          setState(() => _isDeleting = false);
          HapticFeedback.heavyImpact();
          EnhancedSnackbar.showError(
            context,
            message: 'فشل الحذف: $e',
            onRetry: _handleDelete,
          );
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
      child: PopScope(
        canPop: !_hasUnsavedChanges,
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
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,

          // 📱 AppBar - Separated widget
          appBar: FormAppBarWidget(
            beneficiaryId: widget.beneficiaryId,
            isSaving: _isSaving,
            lastSaved: _lastSaved,
            hasUnsavedChanges: _hasUnsavedChanges,
            showStatistics: _showStatistics,
            showFieldHelpers: _showFieldHelpers,
            // onToggleSearch removed - search is local to FormContentWidget
            onToggleStatistics: _toggleStatistics,
            onToggleFieldHelpers: () {
              setState(() => _showFieldHelpers = !_showFieldHelpers);
            },
            onViewDrafts: _showDraftsList,
            onSaveDraft: _hasUnsavedChanges ? _handleDraftSave : null,
            onShowHelp: () => showKeyboardShortcutsHelp(context),
            onDelete: widget.beneficiaryId != null ? _handleDelete : null,
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

                          // 🎯 Bottom Navigation - Separated widget
                          FormBottomNavWidget(
                            tabController: _tabController,
                            onPrevious: _handlePreviousTab,
                            onNext: _handleNextTab,
                            onSave: _showFinalReview,
                            isLoading: _isSaving,
                          ),
                        ],
                      ),
                    ),

                    LoadingOverlay(
                      isVisible: _isSaving || _isDeleting,
                      message: _isSaving
                          ? FormConstants.savingMessage
                          : FormConstants.deletingMessage,
                    ),

                    // 🎓 Tour Guide
                    if (_showTourGuide)
                      TourGuide(
                        steps: [
                          TourStep(
                            title: 'مرحباً بك! 👋',
                            description:
                                'هذا نموذج إضافة مستفيد جديد. دعنا نأخذ جولة سريعة!',
                            icon: Icons.waving_hand,
                          ),
                          TourStep(
                            title: 'التبويبات 📑',
                            description:
                                'النموذج مقسم إلى 4 تبويبات لسهولة التنقل والتنظيم.',
                            icon: Icons.tab,
                          ),
                          TourStep(
                            title: 'كارد التقدم 📊',
                            description:
                                'يعرض نسبة إنجازك في ملء النموذج والحقول المكتملة.',
                            icon: Icons.analytics,
                          ),
                          TourStep(
                            title: 'حفظ المسودة 💾',
                            description:
                                'يمكنك حفظ تقدمك كمسودة والعودة لاحقاً لإكمالها.',
                            icon: Icons.save,
                          ),
                          TourStep(
                            title: 'المراجعة النهائية 📋',
                            description:
                                'في النهاية، راجع جميع البيانات قبل الحفظ النهائي.',
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
