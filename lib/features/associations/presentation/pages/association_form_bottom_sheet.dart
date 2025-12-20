import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✨ Haptic Feedback
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
  ConsumerState<AssociationFormBottomSheet> createState() =>
      _AssociationFormBottomSheetState();
}

class _AssociationFormBottomSheetState
    extends ConsumerState<AssociationFormBottomSheet> {
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
    _accountNumberController =
        TextEditingController(text: assoc?.accountNumber);
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
          shortName: _shortNameController.text.trim().isNotEmpty
              ? _shortNameController.text.trim()
              : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty
              ? _swiftCodeController.text.trim()
              : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty
              ? _bankPhoneController.text.trim()
              : null,
          accountCurrency: _selectedCurrencyNotifier.value,
          representativeId: _selectedRepresentativeNotifier.value!,
          isActive: _isActiveNotifier.value,
        );

        final success = await ref
            .read(associationsProvider.notifier)
            .updateAssociation(updated);

        if (success && mounted) {
          HapticFeedback.mediumImpact(); // ✨ اهتزاز نجاح
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 24.r),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text('✅ تم تحديث الجمعية بنجاح',
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.r),
            ),
          );
        } else if (!success && mounted) {
          HapticFeedback.heavyImpact(); // ❌ اهتزاز خطأ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 24.r),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text('❌ فشل في تحديث الجمعية',
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.r),
            ),
          );
        }
      } else {
        final params = AssociationParams(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim().isNotEmpty
              ? _shortNameController.text.trim()
              : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty
              ? _swiftCodeController.text.trim()
              : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty
              ? _bankPhoneController.text.trim()
              : null,
          accountCurrency: _selectedCurrencyNotifier.value,
          representativeId: _selectedRepresentativeNotifier.value!,
          isActive: _isActiveNotifier.value,
        );

        final success = await ref
            .read(associationsProvider.notifier)
            .createAssociation(params);

        if (success && mounted) {
          HapticFeedback.mediumImpact(); // ✨ اهتزاز نجاح
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 24.r),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text('✅ تم إضافة الجمعية بنجاح',
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.r),
            ),
          );
        } else if (!success && mounted) {
          HapticFeedback.heavyImpact(); // ❌ اهتزاز خطأ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 24.r),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: Text('❌ فشل في إضافة الجمعية',
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.r),
            ),
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
      icon: Icons.business, // ✨ أيقونة مميزة
      useDraggableScrollableSheet: false,
      builder: (scrollController) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: ResponsiveUtils.mediumSpace,
              right: ResponsiveUtils.mediumSpace,
              top: ResponsiveUtils.smallSpace,
              bottom: ResponsiveUtils.mediumSpace,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 920 : double.infinity,
                    ),
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
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

                        const Divider(height: 1),

                        SizedBox(height: ResponsiveUtils.mediumSpace),

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
                        _CurrencyDropdown(
                            currencyNotifier: _selectedCurrencyNotifier),

                        SizedBox(height: ResponsiveUtils.largeSpace),

                        // Representative Dropdown
                        _RepresentativeSection(
                          representativeNotifier:
                              _selectedRepresentativeNotifier,
                        ),

                        SizedBox(height: ResponsiveUtils.mediumSpace),

                        // Active Status Switch
                        _ActiveStatusSwitch(
                            isActiveNotifier: _isActiveNotifier),

                        SizedBox(height: ResponsiveUtils.largeSpace),

                        // Actions (Save / Cancel)
                        _SubmitButton(
                          isLoadingNotifier: _isLoadingNotifier,
                          isEditing: isEditing,
                          onPressed: _submit,
                        ),

                        SizedBox(height: ResponsiveUtils.mediumSpace),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    Widget wrapGrid(List<Widget> fields) {
      if (!isWide) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              fields[i],
              if (i != fields.length - 1)
                SizedBox(height: ResponsiveUtils.mediumSpace),
            ],
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 12.w;
          final colWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: 12.h,
            children: [
              for (final f in fields)
                SizedBox(
                  width: colWidth,
                  child: f,
                ),
            ],
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.info_outline,
                  size: 20.r, color: colorScheme.primary),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المعلومات الأساسية',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'بيانات الجمعية الرئيسية',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        wrapGrid([
          // Name Field
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: nameController,
            builder: (context, value, _) {
              return TextFormField(
                controller: nameController,
                focusNode: nameFocus,
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => shortNameFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: 'اسم الجمعية *',
                  hintText: 'أدخل اسم الجمعية',
                  prefixIcon: Icon(Icons.business, size: 20.r),
                  suffixIcon: value.text.trim().isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 20.r),
                          onPressed: () {
                            nameController.clear();
                            nameFocus.requestFocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ResponsiveUtils.mediumRadius),
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
              );
            },
          ),

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
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: 12.h,
              ),
            ),
          ),

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
              hintText: '07xxxxxxxxx',
              prefixIcon: Icon(Icons.phone, size: 20.r),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
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
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: 12.h,
              ),
            ),
          ),
        ]),
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
    final isWide =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    Widget wrapGrid(List<Widget> fields) {
      if (!isWide) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              fields[i],
              if (i != fields.length - 1)
                SizedBox(height: ResponsiveUtils.mediumSpace),
            ],
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 12.w;
          final colWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: 12.h,
            children: [
              for (final f in fields)
                SizedBox(
                  width: colWidth,
                  child: f,
                ),
            ],
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ✨ Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.account_balance,
                  size: 20.r, color: colorScheme.primary),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المعلومات البنكية',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'تفاصيل الحساب البنكي',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.mediumSpace),

        wrapGrid([
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
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
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
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
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

          // SWIFT Code
          TextFormField(
            controller: swiftCodeController,
            focusNode: swiftCodeFocus,
            textAlign: TextAlign.right,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Swift Code',
              prefixIcon: Icon(Icons.code, size: 20.r),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: 12.h,
              ),
            ),
          ),

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
                borderRadius:
                    BorderRadius.circular(ResponsiveUtils.mediumRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.mediumSpace,
                vertical: 12.h,
              ),
            ),
          ),
        ]),
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

/// Representative Section - Consumer wrapper to access ref
class _RepresentativeSection extends StatelessWidget {
  final ValueNotifier<String?> representativeNotifier;

  const _RepresentativeSection({required this.representativeNotifier});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final representatives = ref.read(associationsProvider).representatives;

        return ValueListenableBuilder<String?>(
          valueListenable: representativeNotifier,
          builder: (context, selectedId, __) {
            return RepresentativeDropdownV2(
              selectedId: selectedId,
              onChanged: (value) => representativeNotifier.value = value,
              representatives: representatives,
              onAddNew: () =>
                  _showAddRepSheet(context, ref, representativeNotifier),
            );
          },
        );
      },
    );
  }

  void _showAddRepSheet(
      BuildContext context, WidgetRef ref, ValueNotifier<String?> notifier) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) =>
          _AddRepBottomSheet(representativeNotifier: notifier),
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
              return colorScheme.primary.withAlpha(128);
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            final cancel = OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveUtils.mediumRadius),
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: ResponsiveUtils.mediumFont),
              ),
            );

            final save = FilledButton(
              onPressed: isLoading
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      onPressed();
                    },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ResponsiveUtils.mediumRadius),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.mediumFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );

            if (isNarrow) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity, child: save),
                  SizedBox(height: 12.h),
                  SizedBox(width: double.infinity, child: cancel),
                ],
              );
            }

            return Center(
              child: Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(width: 180.w, child: cancel),
                  SizedBox(width: 180.w, child: save),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Bottom Sheet لإضافة مندوب جديد
class _AddRepBottomSheet extends StatefulWidget {
  final ValueNotifier<String?> representativeNotifier;

  const _AddRepBottomSheet({required this.representativeNotifier});

  @override
  State<_AddRepBottomSheet> createState() => _AddRepBottomSheetState();
}

class _AddRepBottomSheetState extends State<_AddRepBottomSheet> {
  late final TextEditingController _nameController;
  late final GlobalKey<FormState> _formKey;
  late final ValueNotifier<bool> _isLoadingNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _isLoadingNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    _isLoadingNotifier.value = true;

    try {
      final rep = await ref
          .read(associationsProvider.notifier)
          .createRepresentative(_nameController.text.trim());

      if (!mounted) return;

      if (rep != null) {
        widget.representativeNotifier.value = rep.id;
        await ref.read(associationsProvider.notifier).loadRepresentatives();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إضافة المندوب بنجاح')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBottomSheet(
      title: 'إضافة مندوب جديد',
      icon: Icons.person_add, // ✨ أيقونة
      child: Form(
        key: _formKey,
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: ResponsiveUtils.mediumSpace,
            left: ResponsiveUtils.mediumSpace,
            right: ResponsiveUtils.mediumSpace,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'اسم المندوب *',
                  prefixIcon: Icon(Icons.person, size: 20.r),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ResponsiveUtils.mediumRadius),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.mediumSpace,
                    vertical: 12.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم المندوب';
                  }
                  return null;
                },
              ),
              SizedBox(height: ResponsiveUtils.largeSpace),
              Consumer(
                builder: (context, ref, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _isLoadingNotifier,
                    builder: (context, isLoading, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : () => _submit(ref),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.mediumRadius),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  'إضافة',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.mediumFont,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
