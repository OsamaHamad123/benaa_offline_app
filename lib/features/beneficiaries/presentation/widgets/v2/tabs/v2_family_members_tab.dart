import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';
import 'family_member_bottom_sheet.dart';
import 'enhanced_family_member_card.dart';

/// 👥 تبويب أفراد العائلة - تصميم محسّن UX
///
/// التصميم الجديد:
/// 1. قسم "الوالدين المتوفيين" - أزرار منفصلة للأب والأم
/// 2. قسم "الأيتام" - قائمة مع معلومات تفصيلية
class V2FamilyMembersTab extends ConsumerStatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const V2FamilyMembersTab({super.key, required this.formControllers});

  @override
  ConsumerState<V2FamilyMembersTab> createState() => _V2FamilyMembersTabState();
}

class _V2FamilyMembersTabState extends ConsumerState<V2FamilyMembersTab> {
  void _showAddMemberSheet({
    bool isDeceased = false,
    int? deceasedType,
    Map<String, dynamic>? existingMember,
    int? memberIndex,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false, // Better performance
      enableDrag: true, // Smooth dragging
      useSafeArea: true, // Proper safe area handling
      isDismissible: true,
      elevation: 0, // Reduce shadows for better performance
      builder: (context) => FamilyMemberBottomSheet(
        existingMember: existingMember,
        isDeceased: isDeceased,
        presetDeceasedType: deceasedType,
        onSave: (memberData) {
          // Close immediately without waiting for setState
          Navigator.pop(context);

          // Update state after closing
          if (isDeceased) {
            if (existingMember != null && memberIndex != null) {
              widget.formControllers.deceasedMembers[memberIndex] = memberData;
            } else {
              widget.formControllers.addDeceasedMember(memberData);
            }
          } else {
            if (existingMember != null && memberIndex != null) {
              widget.formControllers.livingMembers[memberIndex] = memberData;
            } else {
              widget.formControllers.addLivingMember(memberData);
            }
          }

          // Force rebuild
          if (mounted) {
            setState(() {});

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existingMember != null
                      ? 'تم التحديث بنجاح'
                      : 'تم الإضافة بنجاح',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RepaintBoundary(child: _buildDeceasedParentsSection()),
          SizedBox(height: 24.h),
          RepaintBoundary(child: _buildOrphansSection()),
        ],
      ),
    );
  }

  /// 🪦 قسم الوالدين المتوفيين
  Widget _buildDeceasedParentsSection() {
    // ابحث عن الأب والأم
    final father = widget.formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 1)
        .firstOrNull;
    final mother = widget.formControllers.deceasedMembers
        .where((d) => d['deceasedType'] == 2)
        .firstOrNull;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, size: 24.sp, color: Colors.red),
                SizedBox(width: 8.w),
                Text(
                  'الوالدين المتوفيين',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // كارت الأب
            _buildParentCard(
              title: 'الأب',
              icon: Icons.man,
              color: Colors.blue,
              data: father,
              onAdd: () =>
                  _showAddMemberSheet(isDeceased: true, deceasedType: 1),
              onEdit: () {
                final memberIndex = widget.formControllers.deceasedMembers
                    .indexOf(father!);
                _showAddMemberSheet(
                  isDeceased: true,
                  deceasedType: 1,
                  existingMember: father,
                  memberIndex: memberIndex,
                );
              },
              onDelete: () => _deleteDeceased(
                widget.formControllers.deceasedMembers.indexOf(father!),
              ),
            ),

            SizedBox(height: 12.h),

            // كارت الأم
            _buildParentCard(
              title: 'الأم',
              icon: Icons.woman,
              color: Colors.pink,
              data: mother,
              onAdd: () =>
                  _showAddMemberSheet(isDeceased: true, deceasedType: 2),
              onEdit: () {
                final memberIndex = widget.formControllers.deceasedMembers
                    .indexOf(mother!);
                _showAddMemberSheet(
                  isDeceased: true,
                  deceasedType: 2,
                  existingMember: mother,
                  memberIndex: memberIndex,
                );
              },
              onDelete: () => _deleteDeceased(
                widget.formControllers.deceasedMembers.indexOf(mother!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كارت الوالد/الوالدة
  Widget _buildParentCard({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, dynamic>? data,
    required VoidCallback onAdd,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    if (data == null) {
      // لم يتم الإضافة بعد
      return AddFamilyMemberCard(
        title: 'إضافة $title المتوفى',
        icon: icon,
        color: color,
        onTap: onAdd,
      );
    }

    // تم الإضافة - عرض البيانات باستخدام الكارت المحسّن
    final memberIndex = widget.formControllers.deceasedMembers.indexOf(data);
    return RepaintBoundary(
      key: ValueKey('deceased_${data['deceasedType']}'),
      child: EnhancedFamilyMemberCard(
        member: data,
        isDeceased: true,
        onEdit: onEdit,
        onDelete: onDelete,
        index: memberIndex,
      ),
    );
  }

  /// 👶 قسم الأيتام
  Widget _buildOrphansSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 24.sp, color: Colors.green),
                    SizedBox(width: 8.w),
                    Text(
                      'الأيتام (${widget.formControllers.livingMembers.length})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberSheet(isDeceased: false),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // قائمة الأيتام
            if (widget.formControllers.livingMembers.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'لا يوجد أيتام مسجلين',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.formControllers.livingMembers.length,
                itemBuilder: (context, index) {
                  final member = widget.formControllers.livingMembers[index];
                  return RepaintBoundary(
                    key: ValueKey('orphan_$index'),
                    child: EnhancedFamilyMemberCard(
                      member: member,
                      isDeceased: false,
                      onEdit: () => _showAddMemberSheet(
                        isDeceased: false,
                        existingMember: member,
                        memberIndex: index,
                      ),
                      onDelete: () => _deleteMember(index),
                      index: index,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// حذف يتيم
  void _deleteMember(int index) {
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
          TextButton(
            onPressed: () {
              widget.formControllers.livingMembers.removeAt(index);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح')));
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteDeceased(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المتوفى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              widget.formControllers.deceasedMembers.removeAt(index);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح')));
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
