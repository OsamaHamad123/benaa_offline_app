import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../providers/associations_provider.dart';
import '../widgets/representative_dropdown_v2.dart';

/// 🏢 Association Form Bottom Sheet
///
/// ✅ ResponsiveBottomSheet
/// ✅ استخدام ResponsiveUtils
/// ✅ Theme موحد
class AssociationFormBottomSheet extends ConsumerStatefulWidget {
  final Association? association;

  const AssociationFormBottomSheet({super.key, this.association});

  @override
  ConsumerState<AssociationFormBottomSheet> createState() => _AssociationFormBottomSheetState();
}

class _AssociationFormBottomSheetState extends ConsumerState<AssociationFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _swiftCodeController;
  late final TextEditingController _bankPhoneController;

  String? _selectedRepresentativeId;
  String _selectedCurrency = 'IQD';
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.association != null;

  @override
  void initState() {
    super.initState();
    final assoc = widget.association;

    _nameController = TextEditingController(text: assoc?.name);
    _shortNameController = TextEditingController(text: assoc?.shortName);
    _phoneController = TextEditingController(text: assoc?.phone);
    _emailController = TextEditingController(text: assoc?.email);
    _bankNameController = TextEditingController(text: assoc?.bankName);
    _accountNumberController = TextEditingController(text: assoc?.accountNumber);
    _swiftCodeController = TextEditingController(text: assoc?.swiftCode);
    _bankPhoneController = TextEditingController(text: assoc?.bankPhone);

    if (assoc != null) {
      _selectedRepresentativeId = assoc.representativeId;
      _selectedCurrency = assoc.accountCurrency ?? 'IQD';
      _isActive = assoc.isActive;
    }

    // تحميل المندوبين
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(associationsProvider.notifier).loadRepresentatives();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    _bankPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRepresentativeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المندوب')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        // تحديث
        final updated = widget.association!.copyWith(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty ? _swiftCodeController.text.trim() : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty ? _bankPhoneController.text.trim() : null,
          accountCurrency: _selectedCurrency,
          representativeId: _selectedRepresentativeId!,
          isActive: _isActive,
        );

        final success = await ref.read(associationsProvider.notifier).updateAssociation(updated);

        if (success && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الجمعية بنجاح')),
          );
        }
      } else {
        // إضافة جديدة
        final params = AssociationParams(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : null,
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          swiftCode: _swiftCodeController.text.trim().isNotEmpty ? _swiftCodeController.text.trim() : null,
          bankPhone: _bankPhoneController.text.trim().isNotEmpty ? _bankPhoneController.text.trim() : null,
          accountCurrency: _selectedCurrency,
          representativeId: _selectedRepresentativeId!,
          isActive: _isActive,
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              children: [
                // الاسم
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
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

                // الاسم المختصر
                TextFormField(
                  controller: _shortNameController,
                  textAlign: TextAlign.right,
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

                // الهاتف
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
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

                // البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
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

                SizedBox(height: ResponsiveUtils.largeSpace),

                // عنوان قسم البنك
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المعلومات البنكية',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.mediumFont,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveUtils.mediumSpace),

                // اسم البنك
                TextFormField(
                  controller: _bankNameController,
                  textAlign: TextAlign.right,
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

                // رقم الحساب
                TextFormField(
                  controller: _accountNumberController,
                  textAlign: TextAlign.right,
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
                  controller: _swiftCodeController,
                  textAlign: TextAlign.right,
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

                // هاتف البنك
                TextFormField(
                  controller: _bankPhoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
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

                SizedBox(height: ResponsiveUtils.mediumSpace),

                // العملة
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
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
                  items: const [
                    DropdownMenuItem(value: 'IQD', child: Text('دينار عراقي (IQD)')),
                    DropdownMenuItem(value: 'USD', child: Text('دولار أمريكي (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('يورو (EUR)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCurrency = value);
                    }
                  },
                ),

                SizedBox(height: ResponsiveUtils.largeSpace),

                // المندوب
                RepresentativeDropdownV2(
                  selectedId: _selectedRepresentativeId,
                  onChanged: (value) => setState(() => _selectedRepresentativeId = value),
                ),

                SizedBox(height: ResponsiveUtils.mediumSpace),

                // حالة الجمعية
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('الجمعية نشطة', textAlign: TextAlign.right),
                  activeColor: colorScheme.primary,
                ),

                SizedBox(height: ResponsiveUtils.largeSpace),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
                      ),
                    ),
                    child: _isLoading
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
