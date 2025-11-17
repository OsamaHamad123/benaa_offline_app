import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✨ Haptic Feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/beneficiary_form_provider.dart';
import '../providers/beneficiary_dependencies.dart';
import '../widgets/v2/v2_widgets.dart';
import '../../domain/entities/beneficiary.dart';

// 🆕 Helper Classes
import 'v2_form_helpers/form_controllers.dart';
import 'v2_form_helpers/form_data_handler.dart';
import 'v2_form_helpers/beneficiary_builder.dart';
import 'v2_form_helpers/save_operations_helper.dart';

// 🆕 Reusable Widgets
import 'v2_form_helpers/widgets/tab_navigation_bar.dart';
import 'v2_form_helpers/widgets/tab_navigation_buttons.dart';
import 'v2_form_helpers/widgets/loading_overlay.dart';
import 'v2_form_helpers/widgets/form_tabs.dart';
import 'v2_form_helpers/widgets/enhanced_snackbar.dart'; // ✨

/// 🎨 Beneficiary Form Page V2 - Ultra Responsive & Performant
///
/// Features:
/// ✅ Full responsive with flutter_screenutil
/// ✅ Separated reusable widgets
/// ✅ Modern icons and design
/// ✅ High performance (const widgets, keys, memo)
/// ✅ Clean architecture
class BeneficiaryFormPageV2 extends ConsumerStatefulWidget {
  final String? beneficiaryId;

  const BeneficiaryFormPageV2({super.key, this.beneficiaryId});

  @override
  ConsumerState<BeneficiaryFormPageV2> createState() =>
      _BeneficiaryFormPageV2State();
}

class _BeneficiaryFormPageV2State extends ConsumerState<BeneficiaryFormPageV2>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // 🆕 Use helper class for all controllers (with ChangeNotifier)
  late final BeneficiaryFormControllers _controllers;

  // Loading states
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoading = false;

  // Focus node for auto-focus
  final FocusNode _firstFieldFocusNode = FocusNode();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // 🆕 Initialize controllers with auto-save callback
    _controllers = BeneficiaryFormControllers(onAutoSave: _performAutoSave);

    _tabController = TabController(length: 6, vsync: this);

    // ✅ No need for TabController listener - ListenableBuilder handles it

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  /// Performs auto-save if there are changes
  Future<void> _performAutoSave() async {
    // Don't auto-save if already saving or if no changes
    if (_isSaving || _isDeleting || _isLoading) return;

    // Check if there are any changes
    final hasChanges =
        _controllers.firstNameController.text.isNotEmpty ||
        _controllers.fatherNameController.text.isNotEmpty ||
        _controllers.nationalIdController.text.isNotEmpty;

    if (!hasChanges) return;

    // Don't auto-save if validation fails (basic required fields)
    if (_controllers.firstNameController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().length != 11) {
      return;
    }

    // Save silently in background (reuse existing save logic)
    await _handleSave(isAutoSave: true);
  }

  void _initializeForm() async {
    setState(() => _isLoading = true);

    if (widget.beneficiaryId != null) {
      // Edit mode - load existing data
      await ref
          .read(beneficiaryFormProvider.notifier)
          .loadBeneficiary(widget.beneficiaryId!);

      // Load data into controllers
      final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      if (beneficiary != null) {
        _populateControllers(beneficiary);
      }
    } else {
      // 🆕 Add mode - CLEAR all controllers first
      _clearAllControllers();

      ref.read(beneficiaryFormProvider.notifier).createNew();

      // Auto-focus on first field for new beneficiary
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _firstFieldFocusNode.requestFocus();
        }
      });
    }

    setState(() => _isLoading = false);
  }

  /// 🧹 Clear all form controllers (for new beneficiary)
  void _clearAllControllers() {
    // Basic Info
    _controllers.firstNameController.clear();
    _controllers.fatherNameController.clear();
    _controllers.grandfatherNameController.clear();
    _controllers.lastNameController.clear();
    _controllers.motherNameController.clear();
    _controllers.nationalIdController.clear();
    _controllers.birthDateController.clear();

    // Contact Info
    _controllers.phoneController.clear();
    _controllers.altPhoneController.clear();
    _controllers.addressController.clear();
    _controllers.neighborhoodController.clear();

    // Additional Info
    _controllers.notesController.clear();
    _controllers.numberOfDependentsController.clear();
    _controllers.numberOfMalesController.clear();
    _controllers.numberOfFemalesController.clear();
    _controllers.chronicDiseasesController.clear();
    _controllers.addressBeforeDisplacementController.clear();

    // Reset dropdowns to default
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

    // Reset booleans
    _controllers.hasDisability = false;

    // Clear pending attachment files
    _controllers.updatePendingFiles([]);

    // 🆕 Also reset civil registry state
    ref.read(civilRegistryProvider.notifier).reset();
  }

  void _populateControllers(Beneficiary beneficiary) {
    // 🆕 Use helper class (no setState needed - ChangeNotifier handles it)
    BeneficiaryFormDataHandler.populateControllers(
      _controllers,
      beneficiary,
      (fn) => fn(), // Dummy setState - ChangeNotifier will notify
    );
  }

  @override
  void dispose() {
    // 🆕 Dispose controllers (includes auto-save timer)
    _controllers.dispose();
    _tabController.dispose();
    _firstFieldFocusNode.dispose();
    super.dispose();
  }

  /// Scrolls to the first field with validation error
  void _scrollToFirstError() {
    // Find the tab with error by validating form
    // Tab 0: Basic Info - required fields
    final hasBasicInfoError =
        _controllers.firstNameController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().isEmpty ||
        _controllers.nationalIdController.text.trim().length != 9;

    if (hasBasicInfoError && _tabController.index != 0) {
      // Switch to Basic Info tab
      _tabController.animateTo(0);

      // Wait for tab animation, then focus first field
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_firstFieldFocusNode.canRequestFocus) {
          _firstFieldFocusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _handleSave({bool isAutoSave = false}) async {
    if (!_formKey.currentState!.validate()) {
      // Don't show errors for auto-save
      if (isAutoSave) return;

      // Scroll to first error field
      _scrollToFirstError();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى إكمال الحقول المطلوبة'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // 🆕 Build beneficiary using helper
    final currentBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
    final beneficiary = BeneficiaryEntityBuilder.build(
      controllers: _controllers,
      existingId: widget.beneficiaryId,
      existingFileNo: currentBeneficiary?.fileNo,
      existingCreatedAt: currentBeneficiary?.createdAt,
    );

    // 🆕 Check for duplicate using helper
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

    // Update provider with new beneficiary
    ref.read(beneficiaryFormProvider.notifier).updateField((_) => beneficiary);

    final success = await ref.read(beneficiaryFormProvider.notifier).save();

    if (success && mounted) {
      // 🆕 Get the saved beneficiary with correct ID
      final savedBeneficiary = ref.read(beneficiaryFormProvider).beneficiary;
      if (savedBeneficiary == null) {
        setState(() => _isSaving = false);
        return;
      }

      // 🆕 Save attachments using helper with CORRECT beneficiaryId
      debugPrint(
        '💾 [FormPage] Saving attachments for beneficiary: ${savedBeneficiary.id}',
      );
      debugPrint(
        '💾 [FormPage] Pending files count: ${_controllers.pendingAttachmentFiles.length}',
      );

      final attachmentResult = await SaveOperationsHelper.saveAttachments(
        database: ref.read(databaseProvider),
        beneficiaryId: savedBeneficiary.id,
        pendingFiles: _controllers.pendingAttachmentFiles,
      );

      debugPrint(
        '💾 [FormPage] Attachment save result - Saved: ${attachmentResult.savedCount}, Failed: ${attachmentResult.failedCount}',
      );
      _controllers.pendingAttachmentFiles.clear();

      // Don't show snackbar or pop for auto-save
      if (!isAutoSave) {
        // ✨ Haptic feedback for success
        HapticFeedback.mediumImpact();

        // ✨ Enhanced snackbar
        EnhancedSnackbar.showSuccess(
          context,
          message: 'تم الحفظ بنجاح',
          duration: const Duration(seconds: 2),
        );

        setState(() => _isSaving = false);

        // Success animation - delay before pop (only for manual save)
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.pop(true);
        }
      } else {
        // Auto-save: just update state silently
        setState(() => _isSaving = false);
      }
    } else {
      setState(() => _isSaving = false);

      // ✨ Show error with haptic feedback
      if (!isAutoSave && mounted) {
        HapticFeedback.heavyImpact();
        EnhancedSnackbar.showError(
          context,
          message: 'فشل في حفظ البيانات. يرجى المحاولة مرة أخرى',
          onRetry: () => _handleSave(),
        );
      }
    }
  }

  void _handleCancel() async {
    // Check if any field has data (unsaved changes)
    final hasChanges =
        _controllers.firstNameController.text.isNotEmpty ||
        _controllers.fatherNameController.text.isNotEmpty ||
        _controllers.nationalIdController.text.isNotEmpty ||
        _controllers.phoneController.text.isNotEmpty;

    if (hasChanges) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => V2ConfirmDialog(
          title: 'تحذير',
          message: 'لديك تغييرات غير محفوظة. هل تريد الخروج بدون حفظ؟',
          confirmText: 'خروج',
          cancelText: 'إلغاء',
          isDangerous: true,
          icon: Icons.warning_rounded,
          onConfirm: () {},
        ),
      );

      if (confirmed == true && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  Future<void> _handleDelete() async {
    final beneficiary = ref.read(beneficiaryFormProvider).beneficiary;
    if (beneficiary == null) return;

    // Haptic feedback on delete attempt
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
        // Delete beneficiary using use case
        final deleteUseCase = ref.read(deleteBeneficiaryUseCaseProvider);
        await deleteUseCase.execute(beneficiary.id);

        if (mounted) {
          setState(() => _isDeleting = false);

          // Haptic feedback on successful delete
          HapticFeedback.lightImpact();

          EnhancedSnackbar.showSuccess(context, message: 'تم الحذف بنجاح');

          context.pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);

          // Haptic feedback on delete error
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final state = ref.watch(beneficiaryFormProvider);
    final notifier = ref.read(beneficiaryFormProvider.notifier);

    return PopScope(
      canPop: !state.hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تحذير'),
            content: const Text(
              'لديك تغييرات غير محفوظة. هل تريد المغادرة دون حفظ؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('البقاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('المغادرة'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: V2BeneficiaryAppBar(
          title: widget.beneficiaryId == null ? 'إضافة مستفيد' : 'تعديل مستفيد',
          canSave: !_isSaving && !_isDeleting,
          isSaving: _isSaving,
          onSave: _handleSave,
          onDelete: widget.beneficiaryId != null ? _handleDelete : null,
        ),
        body: _isLoading
            ? const V2LoadingIndicator(message: 'جاري التحميل...')
            : Stack(
                children: [
                  Column(
                    children: [
                      // Form with TabBar and Content
                      Expanded(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              // Error Banner (inside form, before tabs) - with max height
                              if (state.errorMessage != null)
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 80.h),
                                  child: SingleChildScrollView(
                                    child: V2ErrorBanner(
                                      message: state.errorMessage!,
                                      onDismiss: () => notifier.clearError(),
                                    ),
                                  ),
                                ),

                              // 🆕 Tab Bar with Progress Indicator (wrapped in ListenableBuilder)
                              ListenableBuilder(
                                listenable: _tabController,
                                builder: (context, child) {
                                  return RepaintBoundary(
                                    child: TabNavigationBar(
                                      controller: _tabController,
                                      currentIndex: _tabController.index,
                                      totalTabs: 6,
                                    ),
                                  );
                                },
                              ),

                              // 🆕 Tab Content (wrapped in ListenableBuilder for ChangeNotifier)
                              Expanded(
                                child: ListenableBuilder(
                                  listenable: _controllers,
                                  builder: (context, child) {
                                    return RepaintBoundary(
                                      child: BeneficiaryFormTabs(
                                        controller: _tabController,
                                        formControllers: _controllers,
                                        onBirthDateTap: () =>
                                            _selectDate(context),
                                        firstFieldFocusNode:
                                            _firstFieldFocusNode,
                                        beneficiaryId: widget.beneficiaryId,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // 🆕 Previous/Next Navigation (wrapped in AnimatedBuilder)
                              AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, child) {
                                  return RepaintBoundary(
                                    child: TabNavigationButtons(
                                      controller: _tabController,
                                      currentIndex: _tabController.index,
                                      totalTabs: 6,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 🆕 Loading overlay (extracted widget)
                  LoadingOverlay(
                    isVisible: _isSaving || _isDeleting,
                    message: _isSaving ? 'جاري الحفظ...' : 'جاري الحذف...',
                  ),
                ],
              ),
        bottomNavigationBar: V2FormActions(
          canSave: !_isSaving && !_isDeleting,
          isSaving: _isSaving,
          onSave: _handleSave,
          onCancel: _handleCancel,
          onDelete: widget.beneficiaryId != null ? _handleDelete : null,
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
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _controllers.birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
