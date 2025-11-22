import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Haptic Feedback
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/utils/ux_helpers.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import '../../family_deceased_form.dart';
import '../../family_members_form.dart';

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

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // 🪦 قسم الوالدين المتوفيين
        _DeceasedParentsSection(
          key: const ValueKey('deceased_section'),
          formControllers: widget.formControllers,
        ),
        SizedBox(height: 16.h),

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
class _DeceasedParentsSection extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;

  const _DeceasedParentsSection({super.key, required this.formControllers});

  @override
  Widget build(BuildContext context) {
    final father = formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 1)
        .firstOrNull;
    final mother = formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 2)
        .firstOrNull;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: father != null || mother != null,
        leading: Icon(Icons.local_hospital, color: Colors.red.shade700),
        title: Text(
          'الوالدين المتوفيين',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _getSubtitle(father, mother),
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // كارت الأب
                _ParentCard(
                  type: 'أب',
                  icon: Icons.man,
                  color: Colors.blue,
                  data: father,
                  formControllers: formControllers,
                ),
                SizedBox(height: 12.h),

                // كارت الأم
                _ParentCard(
                  type: 'أم',
                  icon: Icons.woman,
                  color: Colors.pink,
                  data: mother,
                  formControllers: formControllers,
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

  const _ParentCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.data,
    required this.formControllers,
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 24.r,
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data!['firstName'] ?? ''} ${data!['familyName'] ?? ''}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'هوية: ${data!['nationalId'] ?? 'غير محدد'}',
                  style: TextStyle(
                    fontSize: 13.sp,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // العنوان
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إضافة $type المتوفى',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // النموذج
              Expanded(
                child: FamilyDeceasedForm(
                  beneficiaryId: 0,
                  presetDeceasedType: deceasedType,
                  onSaved: () {
                    Navigator.pop(context);
                    ToastHelper.showSuccess('تم الحفظ بنجاح');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // العنوان
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تعديل بيانات $type',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // النموذج (مع بيانات موجودة)
              Expanded(
                child: FamilyDeceasedForm(
                  beneficiaryId: 0,
                  // existingDeceased: data, // TODO: تحويل Map إلى FamilyDeceased
                  onSaved: () {
                    Navigator.pop(context);
                    ToastHelper.showSuccess('تم التحديث بنجاح');
                  },
                ),
              ),
            ],
          ),
        ),
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
class _OrphansSection extends StatelessWidget {
  final BeneficiaryFormControllers formControllers;

  const _OrphansSection({super.key, required this.formControllers});

  @override
  Widget build(BuildContext context) {
    final orphansCount = formControllers.livingMembers.length;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: orphansCount > 0,
        leading: Icon(Icons.people, color: Colors.green.shade700),
        title: Text(
          'الأيتام',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          orphansCount == 0 ? 'لا يوجد أيتام' : '$orphansCount يتيم/أيتام',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // زر إضافة يتيم
                OutlinedButton.icon(
                  onPressed: () => _showAddOrphanDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة يتيم جديد'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                  ),
                ),

                if (orphansCount > 0) ...[
                  SizedBox(height: 16.h),

                  // قائمة الأيتام
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orphansCount,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final orphan = formControllers.livingMembers[index];
                      return _OrphanCard(
                        key: ValueKey('orphan_$index'),
                        data: orphan,
                        index: index,
                        formControllers: formControllers,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrphanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // العنوان
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إضافة يتيم جديد',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // النموذج
              Expanded(
                child: FamilyMembersForm(
                  beneficiaryId: 0,
                  onSaved: () {
                    Navigator.pop(context);
                    ToastHelper.showSuccess('تم الحفظ بنجاح');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// كارت اليتيم
class _OrphanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final BeneficiaryFormControllers formControllers;

  const _OrphanCard({
    super.key,
    required this.data,
    required this.index,
    required this.formControllers,
  });

  @override
  Widget build(BuildContext context) {
    final gender = data['gender'] as int?;
    final isMale = gender == 1;
    final color = isMale ? Colors.blue : Colors.pink;
    final icon = isMale ? Icons.boy : Icons.girl;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 24.r,
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['firstName'] ?? ''} ${data['familyName'] ?? ''}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.cake, size: 14.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Text(
                      '${data['age'] ?? '؟'} سنة',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.badge, size: 14.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${data['orphanNationalId'] ?? 'غير محدد'}',
                        style: TextStyle(
                          fontSize: 13.sp,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // مقبض السحب
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // العنوان
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تعديل بيانات اليتيم',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // النموذج (مع بيانات موجودة)
              Expanded(
                child: FamilyMembersForm(
                  beneficiaryId: 0,
                  // existingMember: data, // TODO: تحويل Map إلى FamilyMember
                  onSaved: () {
                    Navigator.pop(context);
                    ToastHelper.showSuccess('تم التحديث بنجاح');
                  },
                ),
              ),
            ],
          ),
        ),
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
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
