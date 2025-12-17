import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../providers/associations_provider.dart';
import '../widgets/representative_dropdown_v2.dart';

/// 🏢 Association Form Bottom Sheet - OPTIMIZED
///
/// ✅ ResponsiveBottomSheet
/// ✅ استخدام ResponsiveUtils
/// ✅ Theme موحد
/// ✅ ValueNotifier بدل setState
/// 🚀 PERFORMANCE OPTIMIZATIONS:
///    - Separated widgets to minimize rebuilds
///    - Const constructors where possible
///    - Cached InputDecoration
///    - FocusNode management
///    - textInputAction for better UX
class AssociationFormBottomSheet extends ConsumerStatefulWidget {
  final Association? association;

  const AssociationFormBottomSheet({super.key, this.association});

  @override
  ConsumerState<AssociationFormBottomSheet> createState() => _AssociationFormBottomSheetState();
}

class _AssociationFormBottomSheetState extends ConsumerState<AssociationFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _swiftCodeController;
  late final TextEditingController _bankPhoneController;

  // ValueNotifiers for reactive state
  late final ValueNotifier<String?> _selectedRepresentativeNotifier;
  late final ValueNotifier<String> _selectedCurrencyNotifier;
  late final ValueNotifier<bool> _isActiveNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;

  // FocusNodes for better UX
  late final FocusNode _nameFocus;
  late final FocusNode _shortNameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _bankNameFocus;
  late final FocusNode _accountNumberFocus;
  late final FocusNode _swiftCodeFocus;
  late final FocusNode _bankPhoneFocus;

  bool get isEditing => widget.association != null;

  @override
  void initState() {
    super.initState();
    final assoc = widget.association;

    // Initialize controllers
    _nameController = TextEditingController(text: assoc?.name);
    _shortNameController = TextEditingController(text: assoc?.shortName);
    _phoneController = TextEditingController(text: assoc?.phone);
    _emailController = TextEditingController(text: assoc?.email);
    _bankNameController = TextEditingController(text: assoc?.bankName);
    _accountNumberController = TextEditingController(text: assoc?.accountNumber);
    _swiftCodeController = TextEditingController(text: assoc?.swiftCode);
    _bankPhoneController = TextEditingController(text: assoc?.bankPhone);

    // Initialize ValueNotifiers
    _selectedRepresentativeNotifier = ValueNotifier(assoc?.representativeId);
    _selectedCurrencyNotifier = ValueNotifier(assoc?.accountCurrency ?? 'IQD');
    _isActiveNotifier = ValueNotifier(assoc?.isActive ?? true);
    _isLoadingNotifier = ValueNotifier(false);

    // Initialize FocusNodes
    _nameFocus = FocusNode();
    _shortNameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _emailFocus = FocusNode();
    _bankNameFocus = FocusNode();
    _accountNumberFocus = FocusNode();
    _swiftCodeFocus = FocusNode();
    _bankPhoneFocus = FocusNode();

    // Load representatives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(associationsProvider.notifier).loadRepresentatives();
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _shortNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    _bankPhoneController.dispose();

    // Dispose ValueNotifiers
    _selectedRepresentativeNotifier.dispose();
    _selectedCurrencyNotifier.dispose();
    _isActiveNotifier.dispose();
    _isLoadingNotifier.dispose();

    // Dispose FocusNodes
    _nameFocus.dispose();
    _shortNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _bankNameFocus.dispose();
    _accountNumberFocus.dispose();
    _swiftCodeFocus.dispose();
    _bankPhoneFocus.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRepresentativeNotifier.value == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المندوب')),
      );
      return;
    }

    _isLoadingNotifier.value = true;

    try {
      if (isEditing) {
        final updated = widget.association!.copyWith(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty ? _swiftCodeController.text.trim() : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty ? _bankPhoneController.text.trim() : null,
          accountCurrency: _selectedCurrencyNotifier.value,
          representativeId: _selectedRepresentativeNotifier.value!,
          isActive: _isActiveNotifier.value,
        );

        final success = await ref.read(associationsProvider.notifier).updateAssociation(updated);

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الجمعية بنجاح')),
          );
        }
      } else {
        final params = AssociationParams(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty ? _swiftCodeController.text.trim() : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty ? _bankPhoneController.text.trim() : null,
          accountCurrency: _selectedCurrencyNotifier.value,
          representativeId: _selectedRepresentativeNotifier.value!,
          isActive: _isActiveNotifier.value,
        );

        final success = await ref.read(associationsProvider.notifier).createAssociation(params);

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة الجمعية بنجاح')),
          );
        }
      }
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBottomSheet(
      title: isEditing ? 'تعديل الجمعية' : 'إضافة جمعية جديدة',
      child: Form(
        key: _formKey,
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + ResponsiveUtils.mediumSpace,
            left: ResponsiveUtils.mediumSpace,
            right: ResponsiveUtils.mediumSpace,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Information Section
                _BasicInfoSection(
                  nameController: _nameController,
                  shortNameController: _shortNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  nameFocus: _nameFocus,
                  shortNameFocus: _shortNameFocus,
                  phoneFocus: _phoneFocus,
                  emailFocus: _emailFocus,
                  bankNameFocus: _bankNameFocus,
                ),

                SizedBox(height: ResponsiveUtils.largeSpace),

                // Bank Information Section
                _BankInfoSection(
                  bankNameController: _bankNameController,
                  accountNumberController: _accountNumberController,
                  swiftCodeController: _swiftCodeController,
                  bankPhoneController: _bankPhoneController,
                  bankNameFocus: _bankNameFocus,
                  accountNumberFocus: _accountNumberFocus,
                  swiftCodeFocus: _swiftCodeFocus,
                  bankPhoneFocus: _bankPhoneFocus,
                ),

                SizedBox(height: ResponsiveUtils.mediumSpace),

                // Currency Dropdown
                _CurrencyDropdown(currencyNotifier: _selectedCurrencyNotifier),

                SizedBox(height: ResponsiveUtils.largeSpace),

                // Representative Dropdown
                _RepresentativeSection(representativeNotifier: _selectedRepresentativeNotifier),

                SizedBox(height: ResponsiveUtils.mediumSpace),

                // Active Status Switch
                _ActiveStatusSwitch(isActiveNotifier: _isActiveNotifier),

                SizedBox(height: ResponsiveUtils.largeSpace),

                // Submit Button
                _SubmitButton(
                  isLoadingNotifier: _isLoadingNotifier,
                  isEditing: isEditing,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== OPTIMIZED SECTIONS ====================

/// Basic Information Section - Separated widget to minimize rebuilds
class _BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController shortNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final FocusNode nameFocus;
  final FocusNode shortNameFocus;
  final FocusNode phoneFocus;
  final FocusNode emailFocus;
  final FocusNode bankNameFocus;

  const _BasicInfoSection({
    required this.nameController,
    required this.shortNameController,
    required this.phoneController,
    required this.emailController,
    required this.nameFocus,
    required this.shortNameFocus,
    required this.phoneFocus,
    required this.emailFocus,
    required this.bankNameFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name Field
        TextFormField(
          controller: nameController,
          focusNode: nameFocus,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => shortNameFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'اسم الجمعية *',
            prefixIcon: Icon(Icons.business, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال اسم الجمعية';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Short Name Field
        TextFormField(
          controller: shortNameController,
          focusNode: shortNameFocus,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => phoneFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'الاسم المختصر',
            prefixIcon: Icon(Icons.short_text, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Phone Field
        TextFormField(
          controller: phoneController,
          focusNode: phoneFocus,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => emailFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'رقم الهاتف *',
            prefixIcon: Icon(Icons.phone, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال رقم الهاتف';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Email Field
        TextFormField(
          controller: emailController,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => bankNameFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            prefixIcon: Icon(Icons.email, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bank Information Section - Separated widget
class _BankInfoSection extends StatelessWidget {
  final TextEditingController bankNameController;
  final TextEditingController accountNumberController;
  final TextEditingController swiftCodeController;
  final TextEditingController bankPhoneController;
  final FocusNode bankNameFocus;
  final FocusNode accountNumberFocus;
  final FocusNode swiftCodeFocus;
  final FocusNode bankPhoneFocus;

  const _BankInfoSection({
    required this.bankNameController,
    required this.accountNumberController,
    required this.swiftCodeController,
    required this.bankPhoneController,
    required this.bankNameFocus,
    required this.accountNumberFocus,
    required this.swiftCodeFocus,
    required this.bankPhoneFocus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Text(
          'المعلومات البنكية',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: ResponsiveUtils.mediumFont,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Bank Name
        TextFormField(
          controller: bankNameController,
          focusNode: bankNameFocus,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => accountNumberFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'اسم البنك *',
            prefixIcon: Icon(Icons.account_balance, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال اسم البنك';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Account Number
        TextFormField(
          controller: accountNumberController,
          focusNode: accountNumberFocus,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => swiftCodeFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'رقم الحساب *',
            prefixIcon: Icon(Icons.credit_card, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال رقم الحساب';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // SWIFT Code
        TextFormField(
          controller: swiftCodeController,
          focusNode: swiftCodeFocus,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => bankPhoneFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'SWIFT Code',
            prefixIcon: Icon(Icons.code, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        // Bank Phone
        TextFormField(
          controller: bankPhoneController,
          focusNode: bankPhoneFocus,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'هاتف البنك',
            prefixIcon: Icon(Icons.phone_in_talk, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

/// Currency Dropdown - Separated widget with ValueListenableBuilder
class _CurrencyDropdown extends StatelessWidget {
  final ValueNotifier<String> currencyNotifier;

  const _CurrencyDropdown({required this.currencyNotifier});

  static const List<DropdownMenuItem<String>> _currencyItems = [
    DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
    DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
    DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currencyNotifier,
      builder: (context, selectedCurrency, _) {
        return DropdownButtonFormField<String>(
          value: selectedCurrency,
          decoration: InputDecoration(
            labelText: 'عملة الحساب *',
            prefixIcon: Icon(Icons.attach_money, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          items: _currencyItems,
          onChanged: (value) {
            if (value != null) {
              currencyNotifier.value = value;
            }
          },
        );
      },
    );
  }
}

/// Representative Section - Separated widget with ValueListenableBuilder
class _RepresentativeSection extends StatelessWidget {
  final ValueNotifier<String?> representativeNotifier;

  const _RepresentativeSection({required this.representativeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: representativeNotifier,
      builder: (context, selectedId, _) {
        return RepresentativeDropdownV2(
          selectedId: selectedId,
          onChanged: (value) => representativeNotifier.value = value,
        );
      },
    );
  }
}

/// Active Status Switch - Separated widget with ValueListenableBuilder
class _ActiveStatusSwitch extends StatelessWidget {
  final ValueNotifier<bool> isActiveNotifier;

  const _ActiveStatusSwitch({required this.isActiveNotifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isActiveNotifier,
      builder: (context, isActive, _) {
        return SwitchListTile(
          value: isActive,
          onChanged: (value) => isActiveNotifier.value = value,
          title: const Text('الجمعية نشطة', textAlign: TextAlign.right),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary.withOpacity(0.5);
            }
            return null;
          }),
        );
      },
    );
  }
}

/// Submit Button - Separated widget with ValueListenableBuilder
class _SubmitButton extends StatelessWidget {
  final ValueNotifier<bool> isLoadingNotifier;
  final bool isEditing;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoadingNotifier,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing ? 'تحديث' : 'إضافة',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.mediumFont,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
