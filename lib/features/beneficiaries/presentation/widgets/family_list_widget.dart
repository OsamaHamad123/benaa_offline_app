import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../../../../core/utils/family_enums.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';
import '../providers/family_providers.dart';
import 'family_deceased_form.dart';
import 'family_members_form.dart';

/// قائمة عرض أفراد العائلة (الأحياء والأموات)
class FamilyListWidget extends ConsumerStatefulWidget {
  final int beneficiaryId;

  const FamilyListWidget({super.key, required this.beneficiaryId});

  @override
  ConsumerState<FamilyListWidget> createState() => _FamilyListWidgetState();
}

class _FamilyListWidgetState extends ConsumerState<FamilyListWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshLists() {
    // ⚡ استخدام invalidate بدلاً من setState لتحديث البيانات
    ref.invalidate(familyMembersProvider(widget.beneficiaryId));
    ref.invalidate(familyDeceasedProvider(widget.beneficiaryId));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'أفراد العائلة'),
              Tab(icon: Icon(Icons.local_hospital), text: 'الأموات'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [_buildLivingMembersList(), _buildDeceasedList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivingMembersList() {
    final membersAsync = ref.watch(familyMembersProvider(widget.beneficiaryId));

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return CustomEmptyState(
            icon: Icons.people_outline,
            title: 'لا يوجد أفراد عائلة',
            message: 'ابدأ بإضافة أول فرد من العائلة',
            onAction: () => _showAddMemberForm(context),
            actionLabel: 'إضافة فرد',
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'العدد الإجمالي: ${members.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _buildMemberCard(member);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: ErrorState(
          errorMessage: 'خطأ في تحميل أفراد العائلة: $error',
          onRetry: () =>
              ref.invalidate(familyMembersProvider(widget.beneficiaryId)),
        ),
      ),
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              member.gender == 1 ? Colors.blue : Colors.pink, // 1=male
          child: Icon(
            member.gender == 1 ? Icons.man : Icons.woman, // 1=male
            color: Colors.white,
          ),
        ),
        title: Text('${member.firstName} ${member.familyName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member.age ?? '؟'} سنة • هوية: ${member.orphanNationalId}'),
            if (member.healthStatus != 1) // 1=healthy
              Chip(
                label: Text(
                  HealthStatus.toArabic(member.healthStatus),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: member.healthStatus == 4 // 4=disabled
                    ? Colors.orange
                    : member.healthStatus == 3 // 3=chronic
                        ? Colors.red
                        : Colors.yellow.shade700,
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditMemberForm(context, member),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteMember(member),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeceasedList() {
    final deceasedAsync = ref.watch(
      familyDeceasedProvider(widget.beneficiaryId),
    );

    return deceasedAsync.when(
      data: (deceased) {
        if (deceased.isEmpty) {
          return CustomEmptyState(
            icon: Icons.local_hospital_outlined,
            title: 'لا يوجد أموات مسجلين',
            message: 'سجل بيانات الأموات من العائلة',
            onAction: () => _showAddDeceasedForm(context),
            actionLabel: 'إضافة متوفى',
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'العدد الإجمالي: ${deceased.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDeceasedForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: deceased.length,
                itemBuilder: (context, index) {
                  final person = deceased[index];
                  return _buildDeceasedCard(person);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: ErrorState(
          errorMessage: 'خطأ في تحميل بيانات المتوفين: $error',
          onRetry: () =>
              ref.invalidate(familyDeceasedProvider(widget.beneficiaryId)),
        ),
      ),
    );
  }

  Widget _buildDeceasedCard(FamilyDeceased deceased) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(
            deceased.deceasedType == 'father' ? Icons.man : Icons.woman,
            color: Colors.white,
          ),
        ),
        title: Text('${deceased.firstName} ${deceased.familyName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deceased.deceasedType == 'father' ? 'أب' : 'أم'} • هوية: ${deceased.nationalId}',
            ),
            Text(
              'تاريخ الوفاة: ${deceased.deathDate.year}-${deceased.deathDate.month}-${deceased.deathDate.day}',
              style: const TextStyle(fontSize: 12),
            ),
            if (deceased.deathCause != 8) // 8=unknown
              Text(
                'السبب: ${DeathCause.toArabic(deceased.deathCause)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDeceasedForm(context, deceased),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteDeceased(deceased),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyMembersForm(
          beneficiaryId: widget.beneficiaryId,
          onSaved: _refreshLists,
        ),
      ),
    );
  }

  void _showEditMemberForm(BuildContext context, FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyMembersForm(
          beneficiaryId: widget.beneficiaryId,
          existingMember: member,
          onSaved: _refreshLists,
        ),
      ),
    );
  }

  void _showAddDeceasedForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyDeceasedForm(
          beneficiaryId: widget.beneficiaryId,
          onSaved: _refreshLists,
        ),
      ),
    );
  }

  void _showEditDeceasedForm(BuildContext context, FamilyDeceased deceased) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyDeceasedForm(
          beneficiaryId: widget.beneficiaryId,
          existingDeceased: deceased,
          onSaved: _refreshLists,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMember(FamilyMember member) async {
    final confirm = await CommonDialogs.showConfirmation(
      context,
      title: 'تأكيد الحذف',
      message: 'هل تريد حذف ${member.firstName} ${member.familyName}؟',
      confirmText: 'حذف',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      final database = ref.read(databaseProvider);
      await database.familyMembersDao.deleteMember(member.id);
      _refreshLists();
      if (mounted) {
        CommonDialogs.showSuccess(context, message: 'تم الحذف');
      }
    }
  }

  Future<void> _confirmDeleteDeceased(FamilyDeceased deceased) async {
    final confirm = await CommonDialogs.showConfirmation(
      context,
      title: 'تأكيد الحذف',
      message: 'هل تريد حذف ${deceased.firstName} ${deceased.familyName}؟',
      confirmText: 'حذف',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      final database = ref.read(databaseProvider);
      await database.familyDeceasedDao.deleteDeceased(deceased.id);
      _refreshLists();
      if (mounted) {
        CommonDialogs.showSuccess(context, message: 'تم الحذف');
      }
    }
  }
}
