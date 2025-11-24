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
    super.key,
    required this.formControllers,
  });

  @override
  ConsumerState<V2FamilyMembersTabRedesigned> createState() =>
      _V2FamilyMembersTabRedesignedState();
}

class _V2FamilyMembersTabRedesignedState
    extends ConsumerState<V2FamilyMembersTabRedesigned>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // ضروري لـ AutomaticKeepAliveClientMixin

    return Column(
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
    );
  }
}

/// 🪦 قسم الوالدين المتوفيين
class _DeceasedParentsSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const _DeceasedParentsSection({super.key, required this.formControllers});

  @override
  State<_DeceasedParentsSection> createState() =>
      _DeceasedParentsSectionState();
}

class _DeceasedParentsSectionState extends State<_DeceasedParentsSection> {
  @override
  Widget build(BuildContext context) {
    final father = widget.formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 1)
        .firstOrNull;
    final mother = widget.formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 2)
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
                  onUpdate: () => setState(() {}), // تحديث الواجهة
                ),
                SizedBox(height: ResponsiveUtils.smallSpace),

                // كارت الأم
                _ParentCard(
                  type: 'أم',
                  icon: Icons.woman,
                  color: Colors.pink,
                  data: mother,
                  formControllers: widget.formControllers,
                  onUpdate: () => setState(() {}), // تحديث الواجهة
                ),
              ],
            ),
          ),
        ],
      ),
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
}

/// كارت الوالد/الوالدة
class _ParentCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? data;
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onUpdate; // callback لتحديث الواجهة

  const _ParentCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.data,
    required this.formControllers,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      // زر الإضافة
      return OutlinedButton.icon(
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
                  '${data!['firstName'] ?? ''} ${data!['familyName'] ?? ''}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.bodyFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.xSmallSpace),
                Text(
                  'هوية: ${data!['nationalId'] ?? 'غير محدد'}',
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

    showDialog(
      context: context,
      builder: (context) => ZeroLagFamilyDialog(
        isDeceased: true,
        presetDeceasedType: deceasedType,
        onSave: (memberData) {
          formControllers.addDeceasedMember(memberData);
          ToastHelper.showSuccess('تم الحفظ بنجاح');
          onUpdate(); // تحديث الواجهة
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final deceasedType = type == 'أب' ? 1 : 2;
    final existingData = formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == deceasedType)
        .firstOrNull;

    showDialog(
      context: context,
      builder: (context) => ZeroLagFamilyDialog(
        isDeceased: true,
        presetDeceasedType: deceasedType,
        existingMember: existingData,
        onSave: (memberData) {
          final index = formControllers.deceasedMembers.indexWhere(
            (d) => d['deceasedType'] == deceasedType,
          );
          if (index != -1) {
            formControllers.deceasedMembers[index] = memberData;
          }
          ToastHelper.showSuccess('تم التحديث بنجاح');
          onUpdate(); // تحديث الواجهة
        },
      ),
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
              formControllers.deceasedMembers.removeAt(index);
              Navigator.pop(context);
              ToastHelper.showSuccess('تم الحذف بنجاح');
              onUpdate(); // تحديث الواجهة
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// 👶 قسم الأيتام
class _OrphansSection extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const _OrphansSection({super.key, required this.formControllers});

  @override
  State<_OrphansSection> createState() => _OrphansSectionState();
}

class _OrphansSectionState extends State<_OrphansSection> {
  @override
  Widget build(BuildContext context) {
    final orphansCount = widget.formControllers.livingMembers.length;

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
                    onAdd: () => _showAddOrphanDialog(context),
                  )
                : Column(
                    children: [
                      // زر إضافة يتيم
                      OutlinedButton.icon(
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

                      SizedBox(height: ResponsiveUtils.mediumSpace),

                      // 🔥 قائمة الأيتام - Column بدل ListView لتقليل lag
                      ...List.generate(
                        orphansCount,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveUtils.smallSpace,
                          ),
                          child: _OrphanCard(
                            key: ValueKey('orphan_$index'),
                            data: widget.formControllers.livingMembers[index],
                            index: index,
                            formControllers: widget.formControllers,
                            onUpdate: () => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddOrphanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ZeroLagFamilyDialog(
        isDeceased: false,
        onSave: (memberData) {
          widget.formControllers.addLivingMember(memberData);
          ToastHelper.showSuccess('تمت الإضافة بنجاح');
          setState(() {}); // تحديث الواجهة
        },
      ),
    );
  }
}

/// كارت اليتيم
class _OrphanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final BeneficiaryFormControllers formControllers;
  final VoidCallback onUpdate;

  const _OrphanCard({
    super.key,
    required this.data,
    required this.index,
    required this.formControllers,
    required this.onUpdate,
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
    showDialog(
      context: context,
      builder: (context) => ZeroLagFamilyDialog(
        isDeceased: false,
        existingMember: data,
        onSave: (memberData) {
          formControllers.livingMembers[index] = memberData;
          ToastHelper.showSuccess('تم التحديث بنجاح');
          onUpdate(); // تحديث الواجهة
        },
      ),
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
              formControllers.livingMembers.removeAt(index);
              Navigator.pop(context);
              ToastHelper.showSuccess('تم الحذف بنجاح');
              onUpdate(); // تحديث الواجهة
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
