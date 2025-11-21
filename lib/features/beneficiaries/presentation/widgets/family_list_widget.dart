import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';
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
    setState(() {});
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
    final database = ref.read(databaseProvider);
    final dao = database.familyMembersDao;

    return FutureBuilder<List<FamilyMember>>(
      future: dao.getMembersByBeneficiary(widget.beneficiaryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('لا يوجد أفراد عائلة'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة فرد'),
                ),
              ],
            ),
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
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.gender == 'male' ? Colors.blue : Colors.pink,
          child: Icon(
            member.gender == 'male' ? Icons.man : Icons.woman,
            color: Colors.white,
          ),
        ),
        title: Text(member.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member.relationship} • ${member.age ?? '؟'} سنة'),
            if (member.hasDisability || member.hasChronicDisease)
              Row(
                children: [
                  if (member.hasDisability)
                    const Chip(
                      label: Text('إعاقة', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.zero,
                    ),
                  if (member.hasChronicDisease)
                    const Chip(
                      label: Text('مرض مزمن', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                    ),
                ],
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
    final database = ref.read(databaseProvider);
    final dao = database.familyDeceasedDao;

    return FutureBuilder<List<FamilyDeceased>>(
      future: dao.getDeceasedByBeneficiary(widget.beneficiaryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final deceased = snapshot.data ?? [];

        if (deceased.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('لا يوجد أموات مسجلين'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddDeceasedForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
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
    );
  }

  Widget _buildDeceasedCard(FamilyDeceased deceased) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person_off, color: Colors.white),
        ),
        title: Text(deceased.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deceased.relationship} • ${deceased.ageAtDeath ?? '؟'} سنة',
            ),
            if (deceased.deathDate != null)
              Text(
                'تاريخ الوفاة: ${deceased.deathDate!.year}-${deceased.deathDate!.month}-${deceased.deathDate!.day}',
                style: const TextStyle(fontSize: 12),
              ),
            if (deceased.deathCause != null && deceased.deathCause!.isNotEmpty)
              Text(
                'السبب: ${deceased.deathCause}',
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف ${member.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final database = ref.read(databaseProvider);
      await database.familyMembersDao.deleteMember(member.id);
      _refreshLists();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم الحذف')));
      }
    }
  }

  Future<void> _confirmDeleteDeceased(FamilyDeceased deceased) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف ${deceased.fullName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final database = ref.read(databaseProvider);
      await database.familyDeceasedDao.deleteDeceased(deceased.id);
      _refreshLists();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم الحذف')));
      }
    }
  }
}
