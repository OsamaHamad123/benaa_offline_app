import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Haptic Feedback
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/utils/ux_helpers.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart'; // 📐 Responsive sizing
import '../../../pages/v2_form_helpers/form_controllers.dart';
import 'zero_lag_family_dialog.dart'; // ⚡ Optimized version
import '../../../pages/v2_form_helpers/widgets/empty_state_widget.dart'
    as BeneficiaryEmpty; // ✅ Avoid conflict with Reports widget

Future<void> _showAdaptiveFamilyDialog(
  BuildContext context, {
  required void Function(Map<String, dynamic>) onSave,
  Map<String, dynamic>? existingMember,
  bool isDeceased = false,
  int? presetDeceasedType,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ZeroLagFamilyDialog(
      onSave: onSave,
      existingMember: existingMember,
      isDeceased: isDeceased,
      presetDeceasedType: presetDeceasedType,
      fullScreen: isMobile,
    ),
  );
}

/// 👥 تبويب أفراد العائلة - تصميم محسّن بدون AppBar
///
/// التصميم الجديد:
/// ✅ كروت قابلة للتوسيع (ExpansionTile)
/// ✅ إضافة أب وأم معاً
/// ✅ إضافة أيتام متعددين
/// ✅ بدون AppBar داخلي
/// ✅ أداء عالي (const + keys + AutomaticKeepAlive)
class V2FamilyMembersTabRedesigned extends ConsumerStatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const V2FamilyMembersTabRedesigned({
    required this.formControllers,
    super.key,
  });

  @override
  ConsumerState<V2FamilyMembersTabRedesigned> createState() => _V2FamilyMembersTabRedesignedState();
}

class _V2FamilyMembersTabRedesignedState extends ConsumerState<V2FamilyMembersTabRedesigned>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // ضروري لـ AutomaticKeepAliveClientMixin

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 🪦 قسم الوالدين المتوفيين
          _DeceasedParentsSection(
            key: const ValueKey('deceased_section'),
            formControllers: widget.formControllers,
          ),
          SizedBox(height: ResponsiveUtils.mediumSpace),

          // 👶 قسم الأيتام
          _OrphansSection(
            key: const ValueKey('orphans_section'),
            formControllers: widget.formControllers,
          ),
        ],
      ),
    );
  }
}

/// 🪦 قسم الوالدين المتوفيين
class _DeceasedParentsSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const _DeceasedParentsSection({required this.formControllers, super.key});

  @override
  State<_DeceasedParentsSection> createState() => _DeceasedParentsSectionState();
}

class _DeceasedParentsSectionState extends State<_DeceasedParentsSection> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.formControllers.deceasedMembersNotifier,
      builder: (context, deceasedMembers, _) {
        final father = deceasedMembers
            .where((d) => _parseDeceasedType(d['deceasedType'] ?? d['deceased_type'] ?? d['type']) == 1)
            .firstOrNull;
        final mother = deceasedMembers
            .where((d) => _parseDeceasedType(d['deceasedType'] ?? d['deceased_type'] ?? d['type']) == 2)
            .firstOrNull;

        return Card(
          elevation: 2,
          child: ExpansionTile(
            initiallyExpanded: father != null || mother != null,
            leading: Icon(Icons.local_hospital, color: Colors.red.shade700),
            title: Text(
              'الوالدين المتوفيين',
              style: TextStyle(
                fontSize: ResponsiveUtils.mediumFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              _getSubtitle(father, mother),
              style: TextStyle(
                fontSize: ResponsiveUtils.smallFont,
                color: Colors.grey.shade600,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
                child: Column(
                  children: [
                    // كارت الأب
                    _ParentCard(
                      type: 'أب',
                      icon: Icons.man,
                      color: Colors.blue,
                      data: father,
                      formControllers: widget.formControllers,
                    ),
                    SizedBox(height: ResponsiveUtils.smallSpace),

                    // كارت الأم
                    _ParentCard(
                      type: 'أم',
                      icon: Icons.woman,
                      color: Colors.pink,
                      data: mother,
                      formControllers: widget.formControllers,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSubtitle(
    Map<String, dynamic>? father,
    Map<String, dynamic>? mother,
  ) {
    if (father != null && mother != null) return 'الأب والأم متوفيان';
    if (father != null) return 'الأب متوفى';
    if (mother != null) return 'الأم متوفية';
    return 'لم يتم التسجيل';
  }

  int? _parseDeceasedType(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return null;
    if (raw == '1' || raw == 'father' || raw == 'أب') return 1;
    if (raw == '2' || raw == 'mother' || raw == 'أم') return 2;
    return int.tryParse(raw);
  }
}

/// كارت الوالد/الوالدة
class _ParentCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? data;
  final BeneficiaryFormControllers formControllers;
  // onUpdate removed: use formControllers notifiers instead

  const _ParentCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.data,
    required this.formControllers,
    // no onUpdate
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      // زر الإضافة
      return OutlinedButton.icon(
        key: ValueKey('add_${type}_deceased_button'),
        onPressed: () => _showAddDialog(context),
        icon: Icon(icon, color: color),
        label: Text('إضافة $type المتوفى'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 48.h),
          side: BorderSide(color: color, width: 1.5),
        ),
      );
    }

    // عرض البيانات
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20.r,
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: ResponsiveUtils.smallSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(data!),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.bodyFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.xSmallSpace),
                Text(
                  'هوية: ${_displayNationalId(data!)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.smallFont,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () => _showEditDialog(context),
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final deceasedType = type == 'أب' ? 1 : 2;

    _showAdaptiveFamilyDialog(
      context,
      isDeceased: true,
      presetDeceasedType: deceasedType,
      onSave: (memberData) {
        formControllers.addDeceasedMember(memberData);
        ToastHelper.showSuccess('تم الحفظ بنجاح');
        // parent sections listen to controller notifiers and will rebuild
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final deceasedType = type == 'أب' ? 1 : 2;
    final existingData = formControllers.deceasedMembers
        .where((d) => _parseDeceasedType(d['deceasedType'] ?? d['deceased_type'] ?? d['type']) == deceasedType)
        .firstOrNull;

    _showAdaptiveFamilyDialog(
      context,
      isDeceased: true,
      presetDeceasedType: deceasedType,
      existingMember: existingData,
      onSave: (memberData) {
        final index = formControllers.deceasedMembers.indexWhere(
          (d) => _parseDeceasedType(d['deceasedType'] ?? d['deceased_type'] ?? d['type']) == deceasedType,
        );
        if (index != -1) {
          formControllers.updateDeceasedMember(index, memberData);
        }
        ToastHelper.showSuccess('تم التحديث بنجاح');
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف بيانات $type؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact(); // ✅ Haptic feedback
              final index = formControllers.deceasedMembers.indexOf(data!);
              formControllers.removeDeceasedMember(index);
              Navigator.pop(context);
              ToastHelper.showSuccess('تم الحذف بنجاح');
              // parent listens to notifier
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  int? _parseDeceasedType(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return null;
    if (raw == '1' || raw == 'father' || raw == 'أب') return 1;
    if (raw == '2' || raw == 'mother' || raw == 'أم') return 2;
    return int.tryParse(raw);
  }

  String _displayName(Map<String, dynamic> data) {
    final first = _firstNonEmpty(data, const ['firstName', 'first_name', 'name']) ?? '';
    final family = _firstNonEmpty(data, const ['familyName', 'family_name', 'lastName', 'last_name']) ?? '';
    final fullName = '$first $family'.trim();
    return fullName.isEmpty ? 'غير محدد' : fullName;
  }

  String _displayNationalId(Map<String, dynamic> data) {
    final id = _firstNonEmpty(data, const ['nationalId', 'national_id', 'id_number']);
    if (id == null || id.isEmpty || id == '0') {
      return 'غير محدد';
    }
    return id;
  }

  String? _firstNonEmpty(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}

/// 👶 قسم الأيتام
class _OrphansSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const _OrphansSection({required this.formControllers, super.key});

  @override
  State<_OrphansSection> createState() => _OrphansSectionState();
}

class _OrphansSectionState extends State<_OrphansSection> {
  Future<void> _showCopyFromLastOptions(BuildContext context) async {
    if (widget.formControllers.livingMembers.isEmpty) {
      _showAddOrphanDialog(context);
      return;
    }

    final copyMode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('نسخ من آخر يتيم'),
        content: const Text('اختر نوع النسخ:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'familyOnly'),
            child: const Text('نسخ اسم العائلة فقط'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'full'),
            child: const Text('نسخ كامل البيانات'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );

    if (!mounted || copyMode == null) return;
    _showAddOrphanDialog(context, copyMode: copyMode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.formControllers.livingMembersNotifier,
      builder: (context, livingMembers, _) {
        final orphansCount = livingMembers.length;

        return Card(
          elevation: 2,
          child: ExpansionTile(
            initiallyExpanded: orphansCount > 0,
            leading: Icon(Icons.people, color: Colors.green.shade700),
            title: Text(
              'الأيتام',
              style: TextStyle(
                fontSize: ResponsiveUtils.mediumFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              orphansCount == 0 ? 'لا يوجد أيتام' : '$orphansCount يتيم/أيتام',
              style: TextStyle(
                fontSize: ResponsiveUtils.smallFont,
                color: Colors.grey.shade600,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
                child: orphansCount == 0
                    ? BeneficiaryEmpty.EmptyStateWidget.noFamilyMembers(
                        compact: true,
                        onAdd: () => _showAddOrphanDialog(context),
                      )
                    : Column(
                        children: [
                          // زر إضافة يتيم
                          OutlinedButton.icon(
                            key: const ValueKey('add_orphan_button'),
                            onPressed: () => _showAddOrphanDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة يتيم جديد'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 48.h),
                              side: BorderSide(
                                color: Colors.green.shade700,
                                width: 1.5,
                              ),
                            ),
                          ),

                          SizedBox(height: ResponsiveUtils.smallSpace),

                          OutlinedButton.icon(
                            onPressed: () => _showCopyFromLastOptions(context),
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('نسخ من آخر يتيم'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 44.h),
                            ),
                          ),

                          SizedBox(height: ResponsiveUtils.mediumSpace),

                          // 🔥 قائمة الأيتام - Virtualized list
                          SizedBox(
                            // Constrain height so the internal ListView can layout correctly
                            // We allow up to 6 items in a visible area before scrolling is required
                            height: (orphansCount.clamp(0, 6) * 80).toDouble(),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: orphansCount,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ResponsiveUtils.smallSpace,
                                  ),
                                  child: _OrphanCard(
                                    key: ValueKey('orphan_$index'),
                                    data: livingMembers[index],
                                    index: index,
                                    formControllers: widget.formControllers,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOrphanDialog(BuildContext context, {String copyMode = 'none'}) {
    Map<String, dynamic>? template;
    if (copyMode != 'none' && widget.formControllers.livingMembers.isNotEmpty) {
      final last = widget.formControllers.livingMembers.last;
      if (copyMode == 'familyOnly') {
        template = <String, dynamic>{
          'familyName': last['familyName'] ?? '',
        };
      } else {
        template = <String, dynamic>{
          ...last,
          'orphanNationalId': null,
        };
      }
    }

    _showAdaptiveFamilyDialog(
      context,
      existingMember: template,
      onSave: (memberData) {
        widget.formControllers.addLivingMember(memberData);
        ToastHelper.showSuccess('تمت الإضافة بنجاح');
      },
    );
  }
}

/// كارت اليتيم
class _OrphanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final BeneficiaryFormControllers formControllers;
  // Notifier-based: onUpdate removed

  const _OrphanCard({
    required this.data,
    required this.index,
    required this.formControllers,
    super.key,
    // no onUpdate
  });

  @override
  Widget build(BuildContext context) {
    final gender = data['gender'] as int?;
    final isMale = gender == 1;
    final color = isMale ? Colors.blue : Colors.pink;
    final icon = isMale ? Icons.boy : Icons.girl;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(ResponsiveUtils.mediumRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20.r,
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: ResponsiveUtils.smallSpace),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['firstName'] ?? ''} ${data['familyName'] ?? ''}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.bodyFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.cake, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 2.w),
                    Text(
                      '${data['age'] ?? '؟'} سنة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.badge, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 2.w),
                    Flexible(
                      child: Text(
                        '${data['orphanNationalId'] ?? 'غير محدد'}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () => _showEditDialog(context),
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    _showAdaptiveFamilyDialog(
      context,
      existingMember: data,
      onSave: (memberData) {
        formControllers.updateLivingMember(index, memberData);
        ToastHelper.showSuccess('تم التحديث بنجاح');
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا اليتيم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              formControllers.removeLivingMember(index);
              Navigator.pop(context);
              ToastHelper.showSuccess('تم الحذف بنجاح');
              // parent listens to notifier
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
