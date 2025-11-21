import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../pages/v2_form_helpers/form_controllers.dart';

/// 👥 تبويب أفراد العائلة التفصيلي
///
/// يسمح بإضافة/تعديل/حذف:
/// - أفراد العائلة الأحياء
/// - الأموات في العائلة
class V2FamilyMembersTab extends StatefulWidget {
  final BeneficiaryFormControllers formControllers;

  const V2FamilyMembersTab({super.key, required this.formControllers});

  @override
  State<V2FamilyMembersTab> createState() => _V2FamilyMembersTabState();
}

class _V2FamilyMembersTabState extends State<V2FamilyMembersTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // التبويبات الفرعية
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: TabBar(
            controller: _subTabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'الأحياء'),
              Tab(icon: Icon(Icons.local_hospital), text: 'الأموات'),
            ],
          ),
        ),

        // المحتوى - يتحدث تلقائياً عند تغيير formControllers
        Expanded(
          child: ListenableBuilder(
            listenable: widget.formControllers,
            builder: (context, _) {
              return TabBarView(
                controller: _subTabController,
                children: [
                  _buildLivingMembersView(),
                  _buildDeceasedMembersView(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 👥 أفراد العائلة الأحياء
  // ============================================================================

  Widget _buildLivingMembersView() {
    return Column(
      children: [
        // زر الإضافة
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton.icon(
            onPressed: _showAddLivingMemberDialog,
            icon: const Icon(Icons.add),
            label: const Text('إضافة فرد من العائلة'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ),

        // القائمة
        if (widget.formControllers.livingMembers.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'لا يوجد أفراد عائلة',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط الزر أعلاه لإضافة فرد',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: widget.formControllers.livingMembers.length,
              itemBuilder: (context, index) {
                final member = widget.formControllers.livingMembers[index];
                return _buildLivingMemberCard(member, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLivingMemberCard(Map<String, dynamic> member, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member['gender'] == 'male'
              ? Colors.blue
              : Colors.pink,
          child: Icon(
            member['gender'] == 'male' ? Icons.man : Icons.woman,
            color: Colors.white,
          ),
        ),
        title: Text(member['fullName'] ?? ''),
        subtitle: Text(
          '${member['relationship'] ?? ''} • ${member['age'] ?? '؟'} سنة',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditLivingMemberDialog(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteLivingMember(index),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 💀 الأموات في العائلة
  // ============================================================================

  Widget _buildDeceasedMembersView() {
    return Column(
      children: [
        // زر الإضافة
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton.icon(
            onPressed: _showAddDeceasedDialog,
            icon: const Icon(Icons.add),
            label: const Text('إضافة متوفى'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ),

        // القائمة
        if (widget.formControllers.deceasedMembers.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا يوجد أموات مسجلين',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اضغط الزر أعلاه لإضافة متوفى',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: widget.formControllers.deceasedMembers.length,
              itemBuilder: (context, index) {
                final deceased = widget.formControllers.deceasedMembers[index];
                return _buildDeceasedCard(deceased, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDeceasedCard(Map<String, dynamic> deceased, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person_off, color: Colors.white),
        ),
        title: Text(deceased['fullName'] ?? ''),
        subtitle: Text(
          '${deceased['relationship'] ?? ''} • ${deceased['ageAtDeath'] ?? '؟'} سنة',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDeceasedDialog(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteDeceased(index),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 🔨 Dialogs - أفراد العائلة الأحياء
  // ============================================================================

  void _showAddLivingMemberDialog() {
    _showLivingMemberDialog();
  }

  void _showEditLivingMemberDialog(int index) {
    _showLivingMemberDialog(
      initialData: widget.formControllers.livingMembers[index],
      index: index,
    );
  }

  void _showLivingMemberDialog({
    Map<String, dynamic>? initialData,
    int? index,
  }) {
    final nameController = TextEditingController(
      text: initialData?['fullName'],
    );
    final nationalIdController = TextEditingController(
      text: initialData?['nationalId'],
    );
    final phoneController = TextEditingController(text: initialData?['phone']);
    final ageController = TextEditingController(
      text: initialData?['age']?.toString(),
    );

    String? selectedRelationship = initialData?['relationship'];
    String? selectedGender = initialData?['gender'];
    bool hasDisability = initialData?['hasDisability'] ?? false;
    bool hasChronicDisease = initialData?['hasChronicDisease'] ?? false;
    bool livesWithBeneficiary = initialData?['livesWithBeneficiary'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'إضافة فرد من العائلة' : 'تعديل بيانات'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: 'صلة القرابة *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['ابن', 'ابنة', 'زوج', 'زوجة', 'أب', 'أم', 'أخ', 'أخت']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedRelationship = v),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'الجنس',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('ذكر')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('أنثى'),
                          ),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => selectedGender = v),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          labelText: 'العمر',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'الرقم الوطني',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12.h),
                SwitchListTile(
                  title: const Text('يعيش مع المستفيد'),
                  value: livesWithBeneficiary,
                  onChanged: (v) =>
                      setDialogState(() => livesWithBeneficiary = v),
                ),
                SwitchListTile(
                  title: const Text('لديه إعاقة'),
                  value: hasDisability,
                  onChanged: (v) => setDialogState(() => hasDisability = v),
                ),
                SwitchListTile(
                  title: const Text('لديه مرض مزمن'),
                  value: hasChronicDisease,
                  onChanged: (v) => setDialogState(() => hasChronicDisease = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    selectedRelationship == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء ملء الحقول المطلوبة')),
                  );
                  return;
                }

                final memberData = {
                  'fullName': nameController.text,
                  'relationship': selectedRelationship,
                  'gender': selectedGender ?? 'male',
                  'age': int.tryParse(ageController.text),
                  'nationalId': nationalIdController.text,
                  'phone': phoneController.text,
                  'livesWithBeneficiary': livesWithBeneficiary,
                  'hasDisability': hasDisability,
                  'hasChronicDisease': hasChronicDisease,
                };

                setState(() {
                  if (index == null) {
                    widget.formControllers.addLivingMember(memberData);
                  } else {
                    final updatedList = List<Map<String, dynamic>>.from(
                      widget.formControllers.livingMembers,
                    );
                    updatedList[index] = memberData;
                    widget.formControllers.updateLivingMembers(updatedList);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLivingMember(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف ${widget.formControllers.livingMembers[index]['fullName']}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              widget.formControllers.removeLivingMember(index);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🔨 Dialogs - الأموات
  // ============================================================================

  void _showAddDeceasedDialog() {
    _showDeceasedDialog();
  }

  void _showEditDeceasedDialog(int index) {
    _showDeceasedDialog(
      initialData: widget.formControllers.deceasedMembers[index],
      index: index,
    );
  }

  void _showDeceasedDialog({Map<String, dynamic>? initialData, int? index}) {
    final nameController = TextEditingController(
      text: initialData?['fullName'],
    );
    final causeController = TextEditingController(
      text: initialData?['deathCause'],
    );
    final ageController = TextEditingController(
      text: initialData?['ageAtDeath']?.toString(),
    );
    final notesController = TextEditingController(text: initialData?['notes']);

    String? selectedRelationship = initialData?['relationship'];
    String? selectedGender = initialData?['gender'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'إضافة متوفى' : 'تعديل بيانات متوفى'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: 'صلة القرابة *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['أب', 'أم', 'ابن', 'ابنة', 'أخ', 'أخت', 'زوج', 'زوجة']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedRelationship = v),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'الجنس',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('ذكر')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('أنثى'),
                          ),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => selectedGender = v),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          labelText: 'العمر عند الوفاة',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: causeController,
                  decoration: const InputDecoration(
                    labelText: 'سبب الوفاة',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    selectedRelationship == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء ملء الحقول المطلوبة')),
                  );
                  return;
                }

                final deceasedData = {
                  'fullName': nameController.text,
                  'relationship': selectedRelationship,
                  'gender': selectedGender ?? 'male',
                  'ageAtDeath': int.tryParse(ageController.text),
                  'deathCause': causeController.text,
                  'notes': notesController.text,
                };

                setState(() {
                  if (index == null) {
                    widget.formControllers.addDeceasedMember(deceasedData);
                  } else {
                    final updatedList = List<Map<String, dynamic>>.from(
                      widget.formControllers.deceasedMembers,
                    );
                    updatedList[index] = deceasedData;
                    widget.formControllers.updateDeceasedMembers(updatedList);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDeceased(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف ${widget.formControllers.deceasedMembers[index]['fullName']}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              widget.formControllers.removeDeceasedMember(index);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
