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
/// 🚀 NO REF.WATCH - يستقبل representatives كـ parameter (performance optimization)
class RepresentativeDropdownV2 extends StatefulWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final List<dynamic> representatives;
  final VoidCallback onAddNew;

  const RepresentativeDropdownV2({
    required this.selectedId,
    required this.onChanged,
    required this.representatives,
    required this.onAddNew,
    super.key,
  });

  @override
  State<RepresentativeDropdownV2> createState() => _RepresentativeDropdownV2State();
}

class _RepresentativeDropdownV2State extends State<RepresentativeDropdownV2> {
  late List<DropdownMenuItem<String?>> _items;

  String? _normalizeId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  void initState() {
    super.initState();
    _rebuildItems();
  }

  @override
  void didUpdateWidget(covariant RepresentativeDropdownV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recompute only when the list reference changes (provider updates),
    // not on every rebuild caused by keyboard/viewInsets changes.
    if (!identical(oldWidget.representatives, widget.representatives)) {
      _rebuildItems();
    }
  }

  void _rebuildItems() {
    final seenIds = <String>{};
    _items = widget.representatives
        .where((rep) {
          final id = _normalizeId(rep.id);
          if (id == null) return false;
          if (seenIds.contains(id)) return false;
          seenIds.add(id);
          return true;
        })
        .map(
          (rep) => DropdownMenuItem<String?>(
            value: _normalizeId(rep.id),
            child: Text(rep.name, textAlign: TextAlign.right),
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedId = _normalizeId(widget.selectedId);
    final hasSelectedInItems = selectedId != null && _items.any((item) => item.value == selectedId);
    final safeSelectedId = hasSelectedInItems ? selectedId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown
        DropdownButtonFormField<String?>(
          initialValue: safeSelectedId,
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
          items: _items,
          onTap: () {
            // 🚀 Unfocus لتحسين الأداء عند فتح dropdown
            FocusScope.of(context).unfocus();
          },
          onChanged: (value) => widget.onChanged(_normalizeId(value)),
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
          onPressed: widget.onAddNew,
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
}

/// ورقة إضافة مندوب جديد - FIXED PERFORMANCE
/// 🚀 المشكلة: ConsumerWidget يعيد البناء باستمرار من Provider
/// ✅ الحل: StatefulWidget مع Controllers ثابتة
class AddRepresentativeBottomSheet extends StatefulWidget {
  final Function(dynamic) onAdded;

  const AddRepresentativeBottomSheet({required this.onAdded, super.key});

  @override
  State<AddRepresentativeBottomSheet> createState() => _AddRepresentativeBottomSheetState();
}

class _AddRepresentativeBottomSheetState extends State<AddRepresentativeBottomSheet> {
  // Controllers - يُنشأ مرة واحدة فقط في initState
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
      final rep = await ref.read(associationsProvider.notifier).createRepresentative(_nameController.text.trim());

      if (!mounted) return;

      if (rep != null) {
        Navigator.pop(context, rep);
        widget.onAdded(rep);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المندوب بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إضافة المندوب')),
        );
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
              // اسم المندوب
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                autofocus: true,
                textInputAction: TextInputAction.done,
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

              // زر الحفظ - Consumer فقط للـ submit
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
                              borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
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
