import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_dimensions.dart';
import '../../../../../../core/theme/app_breakpoints.dart';
import '../../../providers/beneficiary_dependencies.dart';
import 'family_dialog_widgets.dart';

/// 🚀 Optimized Family Member Dialog - Zero Lag Performance
///
/// ⚡ Performance Improvements:
/// - ValueNotifier instead of setState (prevents full rebuild)
/// - const constructors everywhere
/// - Minimal widget rebuilds
/// - PageStorage for scroll position
class OptimizedFamilyMemberDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingMember;
  final bool isDeceased;
  final int? presetDeceasedType;
  final Function(Map<String, dynamic>) onSave;

  const OptimizedFamilyMemberDialog({
    super.key,
    this.existingMember,
    this.isDeceased = false,
    this.presetDeceasedType,
    required this.onSave,
  });

  @override
  ConsumerState<OptimizedFamilyMemberDialog> createState() =>
      _OptimizedFamilyMemberDialogState();
}

class _OptimizedFamilyMemberDialogState
    extends ConsumerState<OptimizedFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _thirdNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _notesController;

  // ⚡ ValueNotifiers instead of setState - prevents full widget rebuild
  late final ValueNotifier<int> _selectedGenderNotifier;
  late final ValueNotifier<DateTime?> _selectedDateNotifier;
  late final ValueNotifier<int?> _healthStatusNotifier;
  late final ValueNotifier<int?> _deathCauseNotifier;
  late final ValueNotifier<int?> _documentTypeNotifier;
  late final ValueNotifier<bool> _isFetchingNotifier;
  late final ValueNotifier<String?> _civilRegistryStatusNotifier;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  void _initializeNotifiers() {
    final m = widget.existingMember;

    _selectedGenderNotifier = ValueNotifier<int>(m?['gender'] ?? 1);
    _selectedDateNotifier = ValueNotifier<DateTime?>(
      m?['birthDate'] as DateTime? ?? m?['deathDate'] as DateTime?,
    );
    _healthStatusNotifier = ValueNotifier<int?>(m?['healthStatus']);
    _deathCauseNotifier = ValueNotifier<int?>(m?['deathCause']);
    _documentTypeNotifier = ValueNotifier<int?>(m?['documentType']);
    _isFetchingNotifier = ValueNotifier<bool>(false);
    _civilRegistryStatusNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _familyNameController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();

    _selectedGenderNotifier.dispose();
    _selectedDateNotifier.dispose();
    _healthStatusNotifier.dispose();
    _deathCauseNotifier.dispose();
    _documentTypeNotifier.dispose();
    _isFetchingNotifier.dispose();
    _civilRegistryStatusNotifier.dispose();

    super.dispose();
  }

  /// 🔍 Fetch from Civil Registry
  Future<void> _fetchFromCivilRegistry(String nationalId) async {
    if (nationalId.length != 9) {
      _civilRegistryStatusNotifier.value = 'الرقم الوطني يجب أن يكون 9 أرقام';
      return;
    }

    _isFetchingNotifier.value = true;
    _civilRegistryStatusNotifier.value = 'جاري البحث في السجل المدني...';

    try {
      await ref
          .read(civilRegistryProvider.notifier)
          .fetchByNationalId(nationalId);

      final civilRegistryState = ref.read(civilRegistryProvider);

      if (civilRegistryState.isSuccess && civilRegistryState.person != null) {
        final person = civilRegistryState.person!;

        _firstNameController.text = person.firstName;
        _secondNameController.text = person.fatherName;
        _thirdNameController.text = person.grandfatherName ?? '';
        _familyNameController.text = person.lastName;
        _selectedGenderNotifier.value = person.gender == 'ذكر' ? 1 : 2;

        if (!widget.isDeceased && person.birthDate != null) {
          _selectedDateNotifier.value = person.birthDate;
        }

        _isFetchingNotifier.value = false;
        _civilRegistryStatusNotifier.value =
            '✅ تم العثور على البيانات وملؤها تلقائياً';

        HapticFeedback.lightImpact();
      } else {
        _isFetchingNotifier.value = false;
        _civilRegistryStatusNotifier.value =
            '❌ لم يتم العثور على بيانات في السجل المدني';
      }
    } catch (e) {
      _isFetchingNotifier.value = false;
      _civilRegistryStatusNotifier.value = '❌ خطأ في البحث: ${e.toString()}';
    }
  }

  void _handleNationalIdChanged(String value) {
    if (value.length == 9 && _isFetchingNotifier.value == false) {
      _fetchFromCivilRegistry(value);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إكمال الحقول المطلوبة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final memberData = _buildMemberData();
    widget.onSave(memberData);
    Navigator.pop(context);
  }

  Map<String, dynamic> _buildMemberData() {
    final memberData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'secondName': _secondNameController.text.trim(),
      'thirdName': _thirdNameController.text.trim(),
      'familyName': _familyNameController.text.trim(),
      'gender': _selectedGenderNotifier.value,
      'notes': _notesController.text.trim(),
    };

    if (widget.isDeceased) {
      memberData.addAll({
        'deceasedType': widget.presetDeceasedType,
        'nationalId': int.tryParse(_nationalIdController.text.trim()),
        'deathDate': _selectedDateNotifier.value ?? DateTime.now(),
        'deathCause': _deathCauseNotifier.value ?? 8,
        'documentType': _documentTypeNotifier.value,
      });
    } else {
      memberData.addAll({
        'orphanNationalId': int.tryParse(_nationalIdController.text.trim()),
        'birthDate': _selectedDateNotifier.value ?? DateTime.now(),
        'age': _selectedDateNotifier.value != null
            ? DateTime.now().difference(_selectedDateNotifier.value!).inDays ~/
                  365
            : 0,
        'healthStatus': _healthStatusNotifier.value ?? 5,
      });
    }

    return memberData;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.dialogMaxWidth(context),
          maxHeight:
              MediaQuery.of(context).size.height *
              AppDimensions.dialogMaxHeightPercent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - const, never rebuilds
            FamilyDialogHeader(
              title: _getDialogTitle(),
              icon: widget.isDeceased ? Icons.person_off : Icons.child_care,
              onClose: () => Navigator.pop(context),
            ),

            // Form Content - Optimized with ValueNotifiers
            Expanded(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: ListView(
                  key: const PageStorageKey('optimized_family_dialog'),
                  padding: AppDimensions.paddingLG,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 1500, // Larger cache
                  children: [
                    // Name Fields - Static, no rebuilds
                    const _SectionLabel('الاسم الكامل'),
                    NameFieldsSection(
                      key: const ValueKey('name_fields'),
                      firstNameController: _firstNameController,
                      secondNameController: _secondNameController,
                      thirdNameController: _thirdNameController,
                      familyNameController: _familyNameController,
                    ),
                    SizedBox(height: AppDimensions.md),

                    // National ID - Isolated with ValueListenableBuilder
                    const _SectionLabel('الرقم الوطني'),
                    ValueListenableBuilder2<bool, String?>(
                      first: _isFetchingNotifier,
                      second: _civilRegistryStatusNotifier,
                      builder: (context, isFetching, status, child) {
                        return NationalIdWithCivilRegistry(
                          nationalIdController: _nationalIdController,
                          isFetching: isFetching,
                          statusMessage: status,
                          onFetch: () => _fetchFromCivilRegistry(
                            _nationalIdController.text,
                          ),
                          onChanged: _handleNationalIdChanged,
                        );
                      },
                    ),
                    SizedBox(height: AppDimensions.md),

                    // Gender - Only this widget rebuilds
                    ValueListenableBuilder<int>(
                      valueListenable: _selectedGenderNotifier,
                      builder: (context, selectedGender, child) {
                        return GenderSelector(
                          selectedGender: selectedGender,
                          onChanged: (gender) {
                            _selectedGenderNotifier.value = gender;
                          },
                        );
                      },
                    ),
                    SizedBox(height: AppDimensions.md),

                    // Date Picker - Only this widget rebuilds
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: _selectedDateNotifier,
                      builder: (context, selectedDate, child) {
                        return DatePickerField(
                          selectedDate: selectedDate,
                          onDateSelected: (date) {
                            _selectedDateNotifier.value = date;
                          },
                          label: widget.isDeceased
                              ? 'تاريخ الوفاة'
                              : 'تاريخ الميلاد',
                          iconColor: widget.isDeceased
                              ? Colors.red
                              : Colors.green,
                        );
                      },
                    ),
                    SizedBox(height: AppDimensions.md),

                    // Specific Fields - Each isolated
                    if (widget.isDeceased) ...[
                      ValueListenableBuilder<int?>(
                        valueListenable: _deathCauseNotifier,
                        builder: (context, deathCause, child) {
                          return DeathCauseSelector(
                            selectedCause: deathCause,
                            onCauseSelected: (cause) {
                              _deathCauseNotifier.value = cause;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      ValueListenableBuilder<int?>(
                        valueListenable: _documentTypeNotifier,
                        builder: (context, documentType, child) {
                          return DocumentTypeSelector(
                            selectedType: documentType,
                            onTypeSelected: (type) {
                              _documentTypeNotifier.value = type;
                            },
                          );
                        },
                      ),
                    ] else ...[
                      ValueListenableBuilder<int?>(
                        valueListenable: _healthStatusNotifier,
                        builder: (context, healthStatus, child) {
                          return HealthStatusSelector(
                            selectedStatus: healthStatus,
                            onStatusSelected: (status) {
                              _healthStatusNotifier.value = status;
                            },
                          );
                        },
                      ),
                    ],

                    SizedBox(height: AppDimensions.md),

                    // Notes - Static
                    const _SectionLabel('ملاحظات'),
                    NotesField(
                      key: const ValueKey('notes'),
                      controller: _notesController,
                    ),
                  ],
                ),
              ),
            ),

            // Footer - const, never rebuilds
            FamilyDialogFooter(
              onCancel: () => Navigator.pop(context),
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  String _getDialogTitle() {
    if (widget.isDeceased) {
      return widget.presetDeceasedType == 1 ? 'أب متوفى' : 'أم متوفاة';
    }
    return 'يتيم';
  }
}

/// Simple section label
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// ⚡ Custom ValueListenableBuilder for 2 values
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}
