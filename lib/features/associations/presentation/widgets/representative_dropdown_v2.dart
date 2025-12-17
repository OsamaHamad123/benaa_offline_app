import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../providers/associations_provider.dart';

/// 🧑‍💼 Representative Dropdown V2
///
/// ✅ استخدام ResponsiveBottomSheet لإضافة مندوب
/// ✅ ResponsiveUtils
/// ✅ Theme موحد
/// ✅ ValueNotifier بدلاً من setState (تحسين performance)
class RepresentativeDropdownV2 extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const RepresentativeDropdownV2({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final representatives = ref.watch(associationsProvider).representatives;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown
        DropdownButtonFormField<String?>(
          value: selectedId,
          decoration: InputDecoration(
            labelText: 'المندوب *',
            prefixIcon: Icon(Icons.person, size: 20.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.mediumSpace,
              vertical: 12.h,
            ),
          ),
          items: representatives
              .map((rep) => DropdownMenuItem(
                    value: rep.id,
                    child: Text(rep.name, textAlign: TextAlign.right),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'الرجاء اختيار المندوب';
            }
            return null;
          },
        ),

        SizedBox(height: ResponsiveUtils.smallSpace),

        // زر إضافة مندوب جديد
        TextButton.icon(
          onPressed: () => _showAddRepresentativeSheet(context, ref),
          icon: Icon(Icons.add, size: 18.r, color: colorScheme.primary),
          label: Text(
            'إضافة مندوب جديد',
            style: TextStyle(
              fontSize: ResponsiveUtils.smallFont,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddRepresentativeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddRepresentativeBottomSheet(
        onAdded: (rep) {
          onChanged(rep.id);
        },
      ),
    );
  }
}

/// ورقة إضافة مندوب جديد - محسّنة بـ ValueNotifier
class _AddRepresentativeBottomSheet extends ConsumerWidget {
  final Function(dynamic) onAdded;

  const _AddRepresentativeBottomSheet({required this.onAdded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoadingNotifier = ValueNotifier<bool>(false);
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      isLoadingNotifier.value = true;

      try {
        final rep = await ref.read(associationsProvider.notifier).createRepresentative(nameController.text.trim());

        if (context.mounted) {
          if (rep != null) {
            Navigator.pop(context);
            onAdded(rep);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إضافة المندوب بنجاح')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('فشل إضافة المندوب')),
            );
          }
        }
      } finally {
        isLoadingNotifier.value = false;
      }
    }

    return ResponsiveBottomSheet(
      title: 'إضافة مندوب جديد',
      child: Form(
        key: formKey,
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + ResponsiveUtils.mediumSpace,
            left: ResponsiveUtils.mediumSpace,
            right: ResponsiveUtils.mediumSpace,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اسم المندوب
              TextFormField(
                controller: nameController,
                textAlign: TextAlign.right,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'اسم المندوب *',
                  prefixIcon: Icon(Icons.person, size: 20.r),
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
                    return 'الرجاء إدخال اسم المندوب';
                  }
                  return null;
                },
              ),

              SizedBox(height: ResponsiveUtils.largeSpace),

              // زر الحفظ
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submit,
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
                            'إضافة',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.mediumFont,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
