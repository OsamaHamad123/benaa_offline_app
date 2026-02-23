import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../providers/associations_provider.dart';
import '../widgets/form_section_header.dart';
import '../widgets/modern_form_field.dart';
import '../widgets/modern_dropdown.dart';
import '../widgets/modern_switch.dart';
import '../widgets/responsive_form_row.dart';
import '../widgets/representative_dropdown_v2.dart';

/// 🏢 نموذج الجمعية - Modern & Organized
class AssociationFormBottomSheetModern extends ConsumerStatefulWidget {
  final Association? association;

  const AssociationFormBottomSheetModern({super.key, this.association});

  @override
  ConsumerState<AssociationFormBottomSheetModern> createState() => _AssociationFormBottomSheetModernState();
}

class _AssociationFormBottomSheetModernState extends ConsumerState<AssociationFormBottomSheetModern> {
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

  // ValueNotifiers
  late final ValueNotifier<String?> _selectedRepresentativeNotifier;
  late final ValueNotifier<String> _selectedCurrencyNotifier;
  late final ValueNotifier<bool> _isActiveNotifier;
  late final ValueNotifier<bool> _isLoadingNotifier;

  // FocusNodes
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

  /// عرض ورقة إضافة مندوب جديد
  Future<String?> _showAddRepresentativeSheet(
    BuildContext context,
    List representatives,
  ) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          return AddRepresentativeBottomSheet(
            onAdded: (rep) {
              // تحديث قائمة المندوبين
              ref.read(associationsProvider.notifier).loadRepresentatives();
            },
          );
        },
      ),
    );

    return result?.id;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBottomSheet(
      title: isEditing ? 'تعديل الجمعية' : 'إضافة جمعية جديدة',
      icon: Icons.business,
      useDraggableScrollableSheet: false,
      builder: (scrollController) {
        return Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
            physics: const BouncingScrollPhysics(),
            children: [
              // ✨ قسم المعلومات الأساسية
              _buildBasicInfoSection(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // 🏦 قسم المعلومات البنكية
              _buildBankInfoSection(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // 💰 العملة
              _buildCurrencySection(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // 👤 المندوب
              _buildRepresentativeSection(),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // ✅ الحالة النشطة
              _buildActiveStatusSection(),

              SizedBox(height: ResponsiveUtils.xLargeSpace),

              // 💾 زر الحفظ
              _buildSubmitButton(),

              SizedBox(height: ResponsiveUtils.mediumSpace),
            ],
          ),
        );
      },
    );
  }

  /// ✨ قسم المعلومات الأساسية
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionHeader(
          title: 'المعلومات الأساسية',
          subtitle: 'بيانات الجمعية الرئيسية',
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
        SizedBox(height: ResponsiveUtils.mediumSpace),
        ResponsiveFormRow(
          children: [
            // اسم الجمعية
            ModernFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              labelText: 'اسم الجمعية',
              hintText: 'أدخل اسم الجمعية',
              icon: Icons.business,
              required: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _shortNameFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم الجمعية';
                }
                return null;
              },
            ),
            // الاسم المختصر
            ModernFormField(
              controller: _shortNameController,
              focusNode: _shortNameFocus,
              labelText: 'الاسم المختصر',
              hintText: 'اختياري',
              icon: Icons.short_text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _phoneFocus.requestFocus(),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.mediumSpace),
        ResponsiveFormRow(
          children: [
            // رقم الهاتف
            ModernFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              labelText: 'رقم الهاتف',
              hintText: '07xxxxxxxxx',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              required: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _emailFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
            ),
            // البريد الإلكتروني
            ModernFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              labelText: 'البريد الإلكتروني',
              hintText: 'example@email.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _bankNameFocus.requestFocus(),
            ),
          ],
        ),
      ],
    );
  }

  /// 🏦 قسم المعلومات البنكية
  Widget _buildBankInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionHeader(
          title: 'المعلومات البنكية',
          subtitle: 'تفاصيل الحساب البنكي',
          icon: Icons.account_balance,
          color: Colors.teal,
        ),
        SizedBox(height: ResponsiveUtils.mediumSpace),
        ResponsiveFormRow(
          children: [
            // اسم البنك
            ModernFormField(
              controller: _bankNameController,
              focusNode: _bankNameFocus,
              labelText: 'اسم البنك',
              hintText: 'أدخل اسم البنك',
              icon: Icons.account_balance,
              required: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _accountNumberFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم البنك';
                }
                return null;
              },
            ),
            // رقم الحساب
            ModernFormField(
              controller: _accountNumberController,
              focusNode: _accountNumberFocus,
              labelText: 'رقم الحساب',
              hintText: 'أدخل رقم الحساب',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              required: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _swiftCodeFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الحساب';
                }
                return null;
              },
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.mediumSpace),
        ResponsiveFormRow(
          children: [
            // Swift Code
            ModernFormField(
              controller: _swiftCodeController,
              focusNode: _swiftCodeFocus,
              labelText: 'رمز SWIFT',
              hintText: 'اختياري',
              icon: Icons.tag,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: () => _bankPhoneFocus.requestFocus(),
            ),
            // رقم هاتف البنك
            ModernFormField(
              controller: _bankPhoneController,
              focusNode: _bankPhoneFocus,
              labelText: 'رقم هاتف البنك',
              hintText: 'اختياري',
              icon: Icons.phone_in_talk,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ],
    );
  }

  /// 💰 قسم العملة
  Widget _buildCurrencySection() {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedCurrencyNotifier,
      builder: (context, value, _) {
        return ModernDropdown<String>(
          labelText: 'العملة',
          hintText: 'اختر العملة',
          icon: Icons.monetization_on,
          required: true,
          value: value,
          items: const [
            DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
            DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
            DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
          ],
          onChanged: (newValue) {
            if (newValue != null) {
              _selectedCurrencyNotifier.value = newValue;
            }
          },
          validator: (value) {
            if (value == null) return 'الرجاء اختيار العملة';
            return null;
          },
        );
      },
    );
  }

  /// 👤 قسم المندوب
  Widget _buildRepresentativeSection() {
    final representatives = ref.watch(associationsProvider).representatives;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionHeader(
          title: 'المندوب',
          subtitle: 'اختر المندوب المسؤول',
          icon: Icons.person,
          color: Colors.deepPurple,
        ),
        SizedBox(height: ResponsiveUtils.mediumSpace),
        ValueListenableBuilder<String?>(
          valueListenable: _selectedRepresentativeNotifier,
          builder: (context, value, _) {
            return RepresentativeDropdownV2(
              selectedId: value,
              representatives: representatives,
              onChanged: (newValue) {
                _selectedRepresentativeNotifier.value = newValue;
              },
              onAddNew: () async {
                // عرض ورقة إضافة مندوب جديد
                final newRepId = await _showAddRepresentativeSheet(
                  context,
                  representatives,
                );
                if (newRepId != null) {
                  _selectedRepresentativeNotifier.value = newRepId;
                }
              },
            );
          },
        ),
      ],
    );
  }

  /// ✅ قسم الحالة النشطة
  Widget _buildActiveStatusSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isActiveNotifier,
      builder: (context, value, _) {
        return ModernSwitch(
          title: 'الحالة النشطة',
          subtitle: value ? 'الجمعية نشطة حالياً' : 'الجمعية معطلة',
          icon: value ? Icons.toggle_on : Icons.toggle_off_outlined,
          iconColor: value ? Colors.green : Colors.orange,
          value: value,
          onChanged: (newValue) {
            _isActiveNotifier.value = newValue;
            HapticFeedback.selectionClick();
          },
        );
      },
    );
  }

  /// 💾 زر الحفظ
  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, _) {
        return ElevatedButton.icon(
          onPressed: isLoading ? null : _submit,
          icon: isLoading
              ? SizedBox(
                  width: ResponsiveUtils.getIconSize(context) * 0.8,
                  height: ResponsiveUtils.getIconSize(context) * 0.8,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isEditing ? Icons.save : Icons.add_business,
                  size: ResponsiveUtils.getIconSize(context),
                ),
          label: Text(
            isEditing ? 'حفظ التعديلات' : 'إضافة الجمعية',
            style: TextStyle(
              fontSize: ResponsiveUtils.mediumFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.mediumSpace,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
          ),
        );
      },
    );
  }

  /// 💾 حفظ البيانات
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
        await _updateAssociation();
      } else {
        await _createAssociation();
      }
    } finally {
      if (mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  /// تحديث جمعية
  Future<void> _updateAssociation() async {
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

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, true);
      _showSuccessSnackbar('تم تحديث الجمعية بنجاح');
    } else {
      HapticFeedback.heavyImpact();
      _showErrorSnackbar('فشل في تحديث الجمعية');
    }
  }

  /// إضافة جمعية جديدة
  Future<void> _createAssociation() async {
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

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, true);
      _showSuccessSnackbar('تم إضافة الجمعية بنجاح');
    } else {
      HapticFeedback.heavyImpact();
      _showErrorSnackbar('فشل في إضافة الجمعية');
    }
  }

  /// رسالة نجاح
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: ResponsiveUtils.getIconSize(context)),
            SizedBox(width: ResponsiveUtils.smallSpace),
            Expanded(child: Text(message, textAlign: TextAlign.right)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius)),
        margin: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      ),
    );
  }

  /// رسالة خطأ
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: ResponsiveUtils.getIconSize(context)),
            SizedBox(width: ResponsiveUtils.smallSpace),
            Expanded(child: Text(message, textAlign: TextAlign.right)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius)),
        margin: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      ),
    );
  }
}
