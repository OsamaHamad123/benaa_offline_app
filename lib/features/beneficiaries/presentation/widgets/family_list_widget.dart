import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../../../core/widgets/custom_empty_state.dart';
import '../../../../core/utils/family_enums.dart';
import '../../../../core/enums/sponsorship_enums.dart';
import '../../../../data/db/drift_database.dart';
import '../providers/beneficiary_dependencies.dart';
import '../providers/family_providers.dart';
import 'family_deceased_form.dart';
import 'family_members_form.dart';

/// قائمة عرض أفراد العائلة (الأحياء والأموات)
class FamilyListWidget extends ConsumerStatefulWidget {
  final int beneficiaryId;

  const FamilyListWidget({required this.beneficiaryId, super.key});

  @override
  ConsumerState<FamilyListWidget> createState() => _FamilyListWidgetState();
}

class _FamilyListWidgetState extends ConsumerState<FamilyListWidget> with SingleTickerProviderStateMixin {
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
    final colorScheme = Theme.of(context).colorScheme;
    final livingCount = ref.watch(
      familyMembersProvider(widget.beneficiaryId).select(
        (state) => state.maybeWhen(data: (items) => items.length, orElse: () => 0),
      ),
    );
    final deceasedCount = ref.watch(
      familyDeceasedProvider(widget.beneficiaryId).select(
        (state) => state.maybeWhen(data: (items) => items.length, orElse: () => 0),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: colorScheme.onPrimaryContainer,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, size: 18),
                      const SizedBox(width: 6),
                      Text('الأحياء ($livingCount)'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_hospital, size: 18),
                      const SizedBox(width: 6),
                      Text('المتوفون ($deceasedCount)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 460,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
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
          onRetry: () => ref.invalidate(familyMembersProvider(widget.beneficiaryId)),
        ),
      ),
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    final colorScheme = Theme.of(context).colorScheme;
    final genderColor = member.gender == 1 ? colorScheme.primary : colorScheme.secondary;
    final now = DateTime.now();
    final age = member.age ?? (now.difference(member.birthDate).inDays ~/ 365);
    final sponsorshipStatus = SponsorshipStatus.fromId(member.sponsorshipStatus);
    final sponsorshipType = SponsorshipType.fromId(member.sponsorshipType);
    final attachmentsCount = _attachmentsCount(member.attachments);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: genderColor,
                  child: Icon(
                    member.gender == 1 ? Icons.man : Icons.woman,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fullName(
                      member.firstName,
                      member.secondName,
                      member.thirdName,
                      member.familyName,
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  onPressed: () => _showEditMemberForm(context, member),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () => _confirmDeleteMember(member),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label: 'الهوية ${member.orphanNationalId}',
                ),
                _buildInfoChip(
                  icon: Icons.cake_outlined,
                  label: 'العمر $age',
                ),
                _buildInfoChip(
                  icon: member.gender == 1 ? Icons.man : Icons.woman,
                  label: Gender.toArabic(member.gender),
                ),
                _buildInfoChip(
                  icon: Icons.health_and_safety_outlined,
                  label: HealthStatus.toArabic(member.healthStatus),
                ),
                _buildInfoChip(
                  icon: Icons.attach_file,
                  label: 'المرفقات $attachmentsCount',
                ),
                if (sponsorshipStatus != null)
                  _buildInfoChip(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'حالة الكفالة ${sponsorshipStatus.arabicName}',
                  ),
                if (sponsorshipType != null)
                  _buildInfoChip(
                    icon: Icons.handshake_outlined,
                    label: 'نوع الكفالة ${sponsorshipType.arabicName}',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMetaLine('تاريخ الميلاد', _formatDate(member.birthDate)),
            if (member.sponsorName != null && member.sponsorName!.trim().isNotEmpty)
              _buildMetaLine('اسم الكفيل', member.sponsorName!.trim()),
            if (member.sponsorshipStartDate != null)
              _buildMetaLine('بداية الكفالة', _formatDate(member.sponsorshipStartDate!)),
            if (member.notes != null && member.notes!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'ملاحظات: ${member.notes!.trim()}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeceasedList() {
    final colorScheme = Theme.of(context).colorScheme;
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
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
          onRetry: () => ref.invalidate(familyDeceasedProvider(widget.beneficiaryId)),
        ),
      ),
    );
  }

  Widget _buildDeceasedCard(FamilyDeceased deceased) {
    final colorScheme = Theme.of(context).colorScheme;
    final deceasedTypeLabel = DeceasedType.toArabic(deceased.deceasedType);
    final deceasedTypeIcon = deceased.deceasedType == DeceasedType.father ? Icons.man : Icons.woman;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    deceasedTypeIcon,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _fullName(
                      deceased.firstName,
                      deceased.secondName,
                      deceased.thirdName,
                      deceased.familyName,
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  onPressed: () => _showEditDeceasedForm(context, deceased),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () => _confirmDeleteDeceased(deceased),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.family_restroom,
                  label: deceasedTypeLabel,
                ),
                _buildInfoChip(
                  icon: Icons.badge_outlined,
                  label: 'الهوية ${deceased.nationalId}',
                ),
                _buildInfoChip(
                  icon: Icons.calendar_month_outlined,
                  label: _formatDate(deceased.deathDate),
                ),
                _buildInfoChip(
                  icon: Icons.coronavirus_outlined,
                  label: DeathCause.toArabic(deceased.deathCause),
                ),
                if (deceased.documentType != null)
                  _buildInfoChip(
                    icon: Icons.description_outlined,
                    label: DocumentType.toArabic(deceased.documentType!),
                  ),
                if (deceased.documentPath != null && deceased.documentPath!.trim().isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.attach_file,
                    label: 'وثيقة مرفقة',
                  ),
              ],
            ),
            if (deceased.notes != null && deceased.notes!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'ملاحظات: ${deceased.notes!.trim()}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
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

  String _fullName(
    String firstName,
    String? secondName,
    String? thirdName,
    String familyName,
  ) {
    final parts = [firstName, secondName, thirdName, familyName]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return parts.join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _attachmentsCount(String? attachments) {
    final raw = attachments?.trim();
    if (raw == null || raw.isEmpty) {
      return 0;
    }

    return raw.split(',').map((entry) => entry.trim()).where((entry) => entry.isNotEmpty).length;
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaLine(String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        '$title: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
