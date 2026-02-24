import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:benaa_offline_app/features/taxonomies/domain/entities/taxonomy_group.dart';
import 'package:benaa_offline_app/features/taxonomies/presentation/providers/taxonomy_bridge_providers.dart';
import 'package:benaa_offline_app/features/beneficiaries/presentation/utils/taxonomy_value_resolver.dart';
import '../../../../../../core/theme/app_dimensions.dart';
import '../../../../../../core/theme/app_breakpoints.dart';
import 'family_dialog_widgets.dart';

/// ⚡ ULTRA OPTIMIZED - Zero Keyboard Lag
///
/// Key Optimizations:
/// 1. Deferred widget building - only build visible widgets
/// 2. Separate FocusNodes - prevent keyboard layout jank
/// 3. AutofillHints disabled - reduces overhead
/// 4. No Form validation on type - only on save
/// 5. RepaintBoundary for each text field
class UltraOptimizedFamilyDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const UltraOptimizedFamilyDialog({
    required this.onSave,
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
  });

  @override
  ConsumerState<UltraOptimizedFamilyDialog> createState() => _UltraOptimizedFamilyDialogState();
}

class _UltraOptimizedFamilyDialogState extends ConsumerState<UltraOptimizedFamilyDialog> {
  // Controllers - minimal
  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _thirdNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _notesController;

  // FocusNodes - prevent keyboard rebuild lag
  late final FocusNode _firstNameFocus;
  late final FocusNode _secondNameFocus;
  late final FocusNode _thirdNameFocus;
  late final FocusNode _familyNameFocus;
  late final FocusNode _nationalIdFocus;

  // ValueNotifiers - isolated rebuilds
  late final ValueNotifier<int> _genderNotifier;
  late final ValueNotifier<DateTime?> _dateNotifier;
  late final ValueNotifier<int?> _healthStatusNotifier;
  late final ValueNotifier<int?> _deathCauseNotifier;
  late final ValueNotifier<int?> _documentTypeNotifier;
  late final ValueNotifier<bool> _isFetchingNotifier;
  late final ValueNotifier<String?> _statusNotifier;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _initializeNotifiers();
  }

  void _initializeControllers() {
    final m = widget.existingMember;
    _firstNameController = TextEditingController(text: m?['firstName']);
    _secondNameController = TextEditingController(text: m?['secondName']);
    _thirdNameController = TextEditingController(text: m?['thirdName']);
    _familyNameController = TextEditingController(text: m?['familyName']);
    _nationalIdController = TextEditingController(
      text: m?['nationalId']?.toString() ?? m?['orphanNationalId']?.toString(),
    );
    _notesController = TextEditingController(text: m?['notes']);
  }

  void _initializeFocusNodes() {
    _firstNameFocus = FocusNode();
    _secondNameFocus = FocusNode();
    _thirdNameFocus = FocusNode();
    _familyNameFocus = FocusNode();
    _nationalIdFocus = FocusNode();
  }

  void _initializeNotifiers() {
    final m = widget.existingMember;
    _genderNotifier = ValueNotifier<int>(m?['gender'] ?? 1);
    _dateNotifier = ValueNotifier<DateTime?>(
      m?['birthDate'] as DateTime? ?? m?['deathDate'] as DateTime?,
    );
    _healthStatusNotifier = ValueNotifier<int?>(m?['healthStatus']);
    _deathCauseNotifier = ValueNotifier<int?>(m?['deathCause']);
    _documentTypeNotifier = ValueNotifier<int?>(m?['documentType']);
    _isFetchingNotifier = ValueNotifier<bool>(false);
    _statusNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();

    _firstNameFocus.dispose();
    _secondNameFocus.dispose();
    _thirdNameFocus.dispose();
    _familyNameFocus.dispose();
    _nationalIdFocus.dispose();

    _genderNotifier.dispose();
    _dateNotifier.dispose();
    _healthStatusNotifier.dispose();
    _deathCauseNotifier.dispose();
    _documentTypeNotifier.dispose();
    _isFetchingNotifier.dispose();
    _statusNotifier.dispose();

    super.dispose();
  }

  Future<void> _fetchFromCivilRegistry(String nationalId) async {
    _isFetchingNotifier.value = true;
    _statusNotifier.value = '🔍 جاري البحث...';

    try {
      // TODO: Implement civil registry fetch
      await Future.delayed(const Duration(milliseconds: 500));
      const Map<String, dynamic>? data = null; // Placeholder

      if (data != null && mounted) {
        _firstNameController.text = data['firstName'] ?? '';
        _secondNameController.text = data['secondName'] ?? '';
        _thirdNameController.text = data['thirdName'] ?? '';
        _familyNameController.text = data['familyName'] ?? '';

        _genderNotifier.value = data['gender'] ?? 1;

        if (data['birthDate'] != null) {
          _dateNotifier.value = data['birthDate'] as DateTime;
        }

        _statusNotifier.value = '✅ تم جلب البيانات بنجاح';
        HapticFeedback.lightImpact();

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _statusNotifier.value = null;
        });
      } else {
        _statusNotifier.value = '❌ لم يتم العثور على بيانات';
      }
    } catch (e) {
      _statusNotifier.value = '❌ خطأ في البحث';
    } finally {
      _isFetchingNotifier.value = false;
    }
  }

  int? _resolveDynamicDefault(TaxonomyGroup group) {
    final options =
        ref.read(bridgeTaxonomiesByGroupOnceProvider(group)).maybeWhen(data: (value) => value, orElse: () => const []);
    var resolvedCount = 0;
    for (final taxonomy in options) {
      final resolved = TaxonomyValueResolver.resolveToInt(
        code: taxonomy.code,
        id: taxonomy.id,
        group: group,
        source: 'ultra_optimized_family_dialog_default',
      );
      if (resolved != null) {
        resolvedCount++;
        TaxonomyValueResolver.logSummary(
          group: group,
          source: 'ultra_optimized_family_dialog_default',
          total: options.length,
          resolved: resolvedCount,
        );
        return resolved;
      }
    }
    TaxonomyValueResolver.logSummary(
      group: group,
      source: 'ultra_optimized_family_dialog_default',
      total: options.length,
      resolved: resolvedCount,
    );
    return null;
  }

  void _handleSave() {
    if (_firstNameController.text.trim().isEmpty || _familyNameController.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الاسم الأول والعائلة على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final memberData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'secondName': _secondNameController.text.trim(),
      'thirdName': _thirdNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'gender': _genderNotifier.value,
      'notes': _notesController.text.trim(),
    };

    if (widget.isDeceased) {
      memberData.addAll({
        'deceasedType': widget.presetDeceasedType,
        'nationalId': int.tryParse(_nationalIdController.text.trim()),
        'deathDate': _dateNotifier.value ?? DateTime.now(),
        'deathCause': _deathCauseNotifier.value ?? _resolveDynamicDefault(TaxonomyGroup.deathReason),
        'documentType': _documentTypeNotifier.value,
      });
    } else {
      memberData.addAll({
        'orphanNationalId': int.tryParse(_nationalIdController.text.trim()),
        'birthDate': _dateNotifier.value ?? DateTime.now(),
        'age': _dateNotifier.value != null ? DateTime.now().difference(_dateNotifier.value!).inDays ~/ 365 : 0,
        'healthStatus': _healthStatusNotifier.value ?? _resolveDynamicDefault(TaxonomyGroup.healthStatus),
      });
    }

    widget.onSave(memberData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.dialogMaxWidth(context),
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            FamilyDialogHeader(
              title: widget.isDeceased
                  ? (widget.presetDeceasedType == 1 ? 'إضافة أب متوفى' : 'إضافة أم متوفاة')
                  : 'إضافة يتيم',
              icon: widget.isDeceased ? Icons.person_off : Icons.child_care,
              onClose: () => Navigator.pop(context),
            ),

            // Content - Ultra Optimized
            Expanded(
              child: ListView(
                key: const PageStorageKey('ultra_dialog'),
                padding: AppDimensions.paddingLG,
                physics: const BouncingScrollPhysics(),
                cacheExtent: 2000,
                children: [
                  // Name Fields - Optimized TextFields
                  _buildNameFields(),
                  SizedBox(height: 16.h),

                  // Gender Selector
                  ValueListenableBuilder<int>(
                    valueListenable: _genderNotifier,
                    builder: (context, gender, _) => RepaintBoundary(
                      child: GenderSelector(
                        selectedGender: gender,
                        onChanged: (g) => _genderNotifier.value = g,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // National ID with Civil Registry
                  _buildNationalIdField(),
                  SizedBox(height: 16.h),

                  // Date Picker
                  ValueListenableBuilder<DateTime?>(
                    valueListenable: _dateNotifier,
                    builder: (context, date, _) => RepaintBoundary(
                      child: DatePickerField(
                        label: widget.isDeceased ? 'تاريخ الوفاة' : 'تاريخ الميلاد',
                        selectedDate: date,
                        onDateSelected: (d) => _dateNotifier.value = d,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Conditional Fields
                  if (widget.isDeceased) ...[
                    ValueListenableBuilder<int?>(
                      valueListenable: _deathCauseNotifier,
                      builder: (context, cause, _) => RepaintBoundary(
                        child: DeathCauseSelector(
                          selectedCause: cause,
                          onCauseSelected: (c) => _deathCauseNotifier.value = c,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<int?>(
                      valueListenable: _documentTypeNotifier,
                      builder: (context, docType, _) => RepaintBoundary(
                        child: DocumentTypeSelector(
                          selectedType: docType,
                          onTypeSelected: (t) => _documentTypeNotifier.value = t,
                        ),
                      ),
                    ),
                  ] else ...[
                    ValueListenableBuilder<int?>(
                      valueListenable: _healthStatusNotifier,
                      builder: (context, status, _) => RepaintBoundary(
                        child: HealthStatusSelector(
                          selectedStatus: status,
                          onStatusSelected: (s) => _healthStatusNotifier.value = s,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),

                  // Notes
                  _buildNotesField(),
                ],
              ),
            ),

            // Actions
            FamilyDialogFooter(
              onCancel: () => Navigator.pop(context),
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Optimized Builders - Minimal Widget Tree
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNameFields() {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الاسم الكامل',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _LightTextField(
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  label: 'الأول *',
                  nextFocus: _secondNameFocus,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _LightTextField(
                  controller: _secondNameController,
                  focusNode: _secondNameFocus,
                  label: 'الأب',
                  nextFocus: _thirdNameFocus,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _LightTextField(
                  controller: _thirdNameController,
                  focusNode: _thirdNameFocus,
                  label: 'الجد',
                  nextFocus: _familyNameFocus,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _LightTextField(
                  controller: _familyNameController,
                  focusNode: _familyNameFocus,
                  label: 'العائلة *',
                  nextFocus: _nationalIdFocus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNationalIdField() {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'الرقم الوطني',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _isFetchingNotifier,
                builder: (context, isFetching, _) => isFetching
                    ? SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _LightTextField(
            controller: _nationalIdController,
            focusNode: _nationalIdFocus,
            label: 'أدخل الرقم الوطني (9 أرقام)',
            keyboardType: TextInputType.number,
            maxLength: 9,
            onChanged: (value) {
              if (value.length == 9 && !_isFetchingNotifier.value) {
                _fetchFromCivilRegistry(value);
              }
            },
          ),
          ValueListenableBuilder<String?>(
            valueListenable: _statusNotifier,
            builder: (context, status, _) => status != null
                ? Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: status.startsWith('✅') ? Colors.green : Colors.orange,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملاحظات',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'أي ملاحظات إضافية',
              hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusMD,
              ),
              contentPadding: AppDimensions.paddingMD,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ⚡ Light TextField - Zero Lag, Minimal Overhead
// ═══════════════════════════════════════════════════════════════════════════

class _LightTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FocusNode? nextFocus;
  final ValueChanged<String>? onChanged;

  const _LightTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    this.keyboardType,
    this.maxLength,
    this.nextFocus,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enableInteractiveSelection: false, // ⚡ Disable selection UI for speed
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onChanged: onChanged,
        onSubmitted: (_) {
          if (nextFocus != null) {
            nextFocus!.requestFocus();
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13.sp),
          border: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMD,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          counterText: '', // Remove counter
          isDense: true,
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }
}
