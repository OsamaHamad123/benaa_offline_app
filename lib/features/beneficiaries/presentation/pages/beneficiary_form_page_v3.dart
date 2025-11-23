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
import 'v2_form_helpers/widgets/form_tabs_4_merged.dart';
import 'v2_form_helpers/widgets/loading_overlay.dart';
import 'v2_form_helpers/widgets/skeleton_loader.dart'; // 💀 Skeleton screens
import 'v2_form_helpers/widgets/enhanced_snackbar.dart';
import 'v2_form_helpers/widgets/smart_auto_save_indicator.dart';
import 'v2_form_helpers/widgets/keyboard_shortcuts_handler.dart';
import 'v2_form_helpers/widgets/unified_progress_card.dart'; // 📊 Unified Progress
import 'v2_form_helpers/widgets/bottom_navigation_buttons.dart'; // 🎯 Navigation Buttons
import 'v2_form_helpers/widgets/final_review_sheet.dart'; // 📋 Final Review
import 'v2_form_helpers/widgets/draft_save_dialog.dart'; // 💾 Draft Save
import 'v2_form_helpers/widgets/keyboard_shortcuts_help.dart'; // ⌨️ Shortcuts Help
import 'v2_form_helpers/widgets/help_widgets.dart'; // 🎓 Help Widgets
import 'v2_form_helpers/widgets/form_helper_widgets.dart'; // 📝 Form Helpers
import 'v2_form_helpers/smart_helpers.dart'; // 🧠 Smart suggestions
import 'v2_form_helpers/widgets/form_page_widgets.dart'; // 📦 Extracted Form Widgets
import 'v2_form_helpers/widgets/success_animation.dart'; // ✅ Success Animation

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
  String _searchQuery = ''; // البحث السريع في النموذج
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _firstFieldFocusNode = FocusNode();

  // 🔄 Debouncing Timer for auto-save
  Timer? _autoSaveDebouncer;

  @override
  void initState() {
    super.initState();

    _controllers = BeneficiaryFormControllers(onAutoSave: _performAutoSave);
    _formHistory = FormHistory<FormStateSnapshot>(maxHistorySize: 50);
    _tabController = TabController(
      length: FormConstants.totalTabs,
      vsync: this,
    );

    // Listen to controller changes for history
    _controllers.addListener(_onFormChanged);

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

  /// 🔍 Toggle Quick Search
  void _toggleQuickSearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _searchQuery = ' '; // تفعيل البحث
      } else {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

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

  /// ⬅️ التالي - الانتقال للتاب التالي (يمين في RTL)
  void _handleNextTab() {
    if (_tabController.index < FormConstants.totalTabs - 1) {
      setState(() {
        _tabController.animateTo(_tabController.index + 1);
      });
      HapticFeedback.selectionClick();
    }
  }

  /// ➡️ السابق - الرجوع للتاب السابق (يسار في RTL)
  void _handlePreviousTab() {
    if (_tabController.index > 0) {
      setState(() {
        _tabController.animateTo(_tabController.index - 1);
      });
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
      setState(() {
        _controllers.selectedGender = formData['gender'];
        _controllers.selectedMaritalStatus = formData['maritalStatus'];
        _controllers.selectedEducationLevel = formData['educationLevel'];
      });

      // Navigate to saved tab
      final savedTab = draft['currentTab'] ?? 0;
      _tabController.animateTo(savedTab);

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
    _searchController.dispose();
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

          setState(() => _isSaving = false);
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted && context.mounted) {
            context.pop(true);
          }
        } else {
          setState(() => _isSaving = false);
        }
      } else {
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
    final state = ref.watch(beneficiaryFormProvider);
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
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.beneficiaryId == null
                            ? 'إضافة مستفيد'
                            : 'تعديل مستفيد',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SmartAutoSaveIndicator(
                      isSaving: _isSaving,
                      lastSaved: _lastSaved,
                      hasUnsavedChanges: _hasUnsavedChanges,
                    ),
                  ],
                ),
                actions: [
                  FormAppBarActions(
                    showStatistics: _showStatistics,
                    showFieldHelpers: _showFieldHelpers,
                    onToggleSearch: _toggleQuickSearch,
                    onToggleStatistics: _toggleStatistics,
                    onToggleFieldHelpers: () {
                      setState(() => _showFieldHelpers = !_showFieldHelpers);
                    },
                    onViewDrafts: _showDraftsList,
                    onSaveDraft: _hasUnsavedChanges ? _handleDraftSave : null,
                    onShowHelp: () => showKeyboardShortcutsHelp(context),
                    onDelete: widget.beneficiaryId != null
                        ? _handleDelete
                        : null,
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          ),
          body: _isLoading
              ? const SkeletonFormScreen() // Enhanced skeleton instead of basic loading
              : Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (state.errorMessage != null)
                            V2ErrorBanner(
                              message: state.errorMessage!,
                              onDismiss: () => ref
                                  .read(beneficiaryFormProvider.notifier)
                                  .clearError(),
                            ),

                          // 🔍 Quick Search Bar
                          if (_searchQuery.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              color: theme.colorScheme.primaryContainer,
                              child: SearchField(
                                controller: _searchController,
                                hint: 'ابحث في الحقول...',
                                onSearch: (query) {
                                  setState(() => _searchQuery = query);
                                },
                                onClear: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              ),
                            ),

                          ListenableBuilder(
                            listenable: _tabController,
                            builder: (context, _) {
                              return Column(
                                children: [
                                  // 🏆 Enhanced TabBar with Completion Badges
                                  ListenableBuilder(
                                    listenable: _controllers,
                                    builder: (context, _) {
                                      final tabStats =
                                          FormCompletionCalculator.calculateTabStats(
                                            _controllers,
                                          );

                                      return BeneficiaryFormTabBar4(
                                        controller: _tabController,
                                        currentIndex: _tabController.index,
                                        tabStats: tabStats,
                                      );
                                    },
                                  ),
                                  // 📊 Unified Progress Card with Animated Counter
                                  RepaintBoundary(
                                    child: ListenableBuilder(
                                      listenable: _controllers,
                                      builder: (context, child) {
                                        final completed =
                                            FormCompletionCalculator.getCompletedCount(
                                              _controllers,
                                            );
                                        final total =
                                            FormCompletionCalculator.getTotalRequired();

                                        return UnifiedProgressCard(
                                          currentTab: _tabController.index,
                                          totalTabs: FormConstants.totalTabs,
                                          completedFields: completed,
                                          totalFields: total,
                                          currentTabTitle: FormTabs
                                              .tabs[_tabController.index]
                                              .fullTitle,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                // 🎓 Field Helpers (if enabled) - Optimized with const
                                if (_showFieldHelpers &&
                                    _tabController.index == 0)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    child: const FormFieldHelper(
                                      title: 'نصائح للمعلومات الشخصية',
                                      description:
                                          'تأكد من إدخال الاسم الثلاثي كاملاً والرقم الوطني صحيح',
                                      examples: [
                                        'الاسم: محمد أحمد علي',
                                        'الرقم الوطني: 12 رقم',
                                        'التاريخ: YYYY-MM-DD',
                                      ],
                                      tips: [
                                        'استخدم الاسم الكامل كما في الوثائق',
                                        'تحقق من الرقم الوطني مرتين',
                                      ],
                                    ),
                                  ),
                                if (_showFieldHelpers &&
                                    _tabController.index == 2)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    child: const FormFieldHelper(
                                      title: 'نصائح التواصل',
                                      description:
                                          'تأكد من صحة أرقام الهواتف والعناوين',
                                      examples: [
                                        'رقم الهاتف: 07XXXXXXXXX',
                                        'العنوان: المحافظة، المدينة، الحي',
                                      ],
                                      tips: [
                                        'أضف رقم بديل للطوارئ',
                                        'كن دقيقاً في العنوان',
                                      ],
                                    ),
                                  ),

                                // Main Form Tabs
                                Expanded(
                                  child: BeneficiaryFormTabs4Merged(
                                    controller: _tabController,
                                    formControllers: _controllers,
                                    onBirthDateTap: () => _selectDate(context),
                                    firstFieldFocusNode: _firstFieldFocusNode,
                                    beneficiaryId: widget.beneficiaryId,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🎯 Bottom Navigation Buttons
                          ListenableBuilder(
                            listenable: _tabController,
                            builder: (context, _) {
                              return RepaintBoundary(
                                child: BottomNavigationButtons(
                                  currentTab: _tabController.index,
                                  totalTabs: FormConstants.totalTabs,
                                  onPrevious: _handlePreviousTab,
                                  onNext: _handleNextTab,
                                  onSave: _showFinalReview,
                                  isLoading: _isSaving,
                                ),
                              );
                            },
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

                    // 🎓 Tour Guide for First Time Users
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
