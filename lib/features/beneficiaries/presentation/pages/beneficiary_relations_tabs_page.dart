import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/offline/firestore_local_cache_store.dart';
import '../../../../core/providers/providers.dart';
import '../../../../data/db/daos/sponsorships_dao.dart';
import '../../../../data/db/drift_database.dart';
import '../../../../core/utils/beneficiary_identity_resolver.dart';
import '../../../attachments/presentation/providers/attachments_provider.dart';
import '../../../kafalat/presentation/widgets/sponsorship_form_sheet.dart';
import '../../../visits/presentation/pages/record_visit_page_enhanced.dart';

class BeneficiaryRelationsTabsPage extends ConsumerStatefulWidget {
  const BeneficiaryRelationsTabsPage({
    required this.beneficiaryId,
    super.key,
  });

  final String beneficiaryId;

  @override
  ConsumerState<BeneficiaryRelationsTabsPage> createState() => _BeneficiaryRelationsTabsPageState();
}

class _BeneficiaryRelationsTabsPageState extends ConsumerState<BeneficiaryRelationsTabsPage> {
  Future<void> _openAddSponsorship(_BeneficiaryContext ctx) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final viewInsets = MediaQuery.of(sheetContext).viewInsets;
        final screenHeight = MediaQuery.of(sheetContext).size.height;
        final maxHeight = screenHeight * 0.92;
        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(sheetContext).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            size: 20,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة كفالة',
                            style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Theme.of(sheetContext).colorScheme.outlineVariant),
                    Expanded(
                      child: SponsorshipFormSheet(beneficiaryId: ctx.localId),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (result == true) {
      ref.invalidate(_beneficiarySponsorshipsProvider(ctx.localId));
    }
  }

  Future<void> _openAddVisit(_BeneficiaryContext ctx) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordVisitPageEnhanced(beneficiary: ctx.beneficiary),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      ref.invalidate(_beneficiaryVisitsProvider(ctx));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctxAsync = ref.watch(_beneficiaryContextProvider(widget.beneficiaryId));

    return ctxAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المستفيد')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المستفيد')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('تعذر تحميل بيانات المستفيد: $error'),
          ),
        ),
      ),
      data: (ctx) => DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctx.beneficiary.fullName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'الكفالات والزيارات',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorWeight: 3,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
              tabs: const [
                Tab(text: 'نظرة عامة', icon: Icon(Icons.info_outline, size: 18)),
                Tab(text: 'الكفالات', icon: Icon(Icons.handshake_outlined, size: 18)),
                Tab(text: 'الزيارات', icon: Icon(Icons.event_outlined, size: 18)),
                Tab(text: 'المتابعات', icon: Icon(Icons.timeline_outlined, size: 18)),
                Tab(text: 'المستندات', icon: Icon(Icons.attach_file_outlined, size: 18)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _OverviewTab(ctx: ctx),
              _SponsorshipsTab(
                beneficiary: ctx,
                onAddSponsorship: () => _openAddSponsorship(ctx),
              ),
              _VisitsTab(
                beneficiary: ctx,
                onAddVisit: () => _openAddVisit(ctx),
              ),
              _FollowupsTab(beneficiary: ctx),
              _DocumentsTab(beneficiary: ctx),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.ctx});

  final _BeneficiaryContext ctx;

  @override
  Widget build(BuildContext context) {
    final b = ctx.beneficiary;
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _kv(context, 'رقم الملف', b.fileIdNumber ?? 'غير متوفر'),
                if (b.idNumber != 0) _kv(context, 'الرقم الوطني', b.idNumber.toString()),
                if (b.phoneNumber != 0) _kv(context, 'الهاتف', b.phoneNumber.toString()),
                if (b.sectionId != null && b.sectionId != 0) _kv(context, 'التصنيف', b.sectionId.toString()),
                _kv(context, 'المحافظة', b.province?.toString() ?? 'غير محدد'),
                _kv(context, 'المدينة', b.city?.toString() ?? 'غير محدد'),
                _kv(context, 'العنوان', b.currentAddress ?? 'غير متوفر'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorshipsTab extends ConsumerWidget {
  const _SponsorshipsTab({
    required this.beneficiary,
    required this.onAddSponsorship,
  });

  final _BeneficiaryContext beneficiary;
  final VoidCallback onAddSponsorship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponsorshipsAsync = ref.watch(_beneficiarySponsorshipsProvider(beneficiary.localId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'الكفالات',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: onAddSponsorship,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة كفالة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: sponsorshipsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: 'تعذر تحميل الكفالات: $e'),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyState(
                  icon: Icons.handshake_outlined,
                  message: 'لا توجد كفالات لهذا المستفيد',
                  action: OutlinedButton.icon(
                    onPressed: onAddSponsorship,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة كفالة'),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final row = items[index];
                  final s = row.sponsorship;
                  final colorScheme = Theme.of(context).colorScheme;
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.handshake_outlined, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  row.associationName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _StatusChip(s.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _kvRow('النوع', s.sponsorshipType),
                          _kvRow('القيمة', '${s.amount?.toStringAsFixed(2) ?? '-'} ${s.currency ?? ''}'),
                          _kvRow('المدة', '${s.durationMonths?.toString() ?? '-'} شهر'),
                          _kvRow('البداية', _fmtDate(s.startDate)),
                          _kvRow('النهاية', _fmtDate(s.endDate)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VisitsTab extends ConsumerWidget {
  const _VisitsTab({
    required this.beneficiary,
    required this.onAddVisit,
  });

  final _BeneficiaryContext beneficiary;
  final VoidCallback onAddVisit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(_beneficiaryVisitsProvider(beneficiary));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'الزيارات',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: onAddVisit,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة زيارة'),
              ),
            ],
          ),
        ),
        Expanded(
          child: visitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: 'تعذر تحميل الزيارات: $e'),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyState(
                  icon: Icons.event_busy_outlined,
                  message: 'لا توجد زيارات مسجلة',
                  action: OutlinedButton.icon(
                    onPressed: onAddVisit,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة زيارة'),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final v = items[index];
                  final colorScheme = Theme.of(context).colorScheme;
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_outlined, size: 16, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'زيارة: ${_fmtDate(v.scheduledAt)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _StatusChip(v.status),
                            ],
                          ),
                          if (v.visitedByName != null && v.visitedByName!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            _kvRow('نفذها', v.visitedByName!),
                          ],
                          if (v.completedAt != null) _kvRow('اكتملت', _fmtDate(v.completedAt)),
                          if (v.nextVisitAt != null) _kvRow('الزيارة القادمة', _fmtDate(v.nextVisitAt)),
                          if (v.summary != null && v.summary!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              v.summary!,
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FollowupsTab extends ConsumerWidget {
  const _FollowupsTab({required this.beneficiary});

  final _BeneficiaryContext beneficiary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followupsAsync = ref.watch(_beneficiaryFollowupsProvider(beneficiary));

    return followupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: 'تعذر تحميل المتابعات: $e'),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.timeline_outlined,
            message: 'لا توجد متابعات لهذا المستفيد',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final f = items[index];
            final colorScheme = Theme.of(context).colorScheme;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timeline_outlined, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            f.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(f.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _kvRow('النوع', f.type),
                    _kvRow('الاستحقاق', _fmtDate(f.dueDate)),
                    if (f.description != null && f.description!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          f.description!,
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab({required this.beneficiary});

  final _BeneficiaryContext beneficiary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsState = ref.watch(attachmentsProvider(beneficiary.localId.toString()));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(Icons.attach_file_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'المستندات (${attachmentsState.attachments.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/attachments/${beneficiary.localId}'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('فتح المرفقات'),
              ),
            ],
          ),
        ),
        Expanded(
          child: attachmentsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : attachmentsState.attachments.isEmpty
                  ? const _EmptyState(
                      icon: Icons.folder_open_outlined,
                      message: 'لا توجد مستندات مرفقة',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: attachmentsState.attachments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final a = attachmentsState.attachments[index];
                        return ListTile(
                          leading: Icon(Icons.insert_drive_file_outlined, color: colorScheme.primary),
                          title: Text(a.fileName, overflow: TextOverflow.ellipsis),
                          subtitle: Text(a.fileSizeReadable),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

/// Reusable empty-state widget for tabs
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable error-state widget for tabs
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small status chip
class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = status == 'active' || status == 'completed';
    final bgColor = isActive ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHighest;
    final fgColor = isActive ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;
    final label = _localizeStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fgColor),
      ),
    );
  }

  String _localizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'scheduled':
        return 'مجدول';
      case 'paused':
        return 'موقوف';
      case 'ended':
        return 'منتهٍ';
      case 'open':
        return 'مفتوح';
      case 'closed':
        return 'مغلق';
      default:
        return status;
    }
  }
}

/// Key-value row helper
Widget _kvRow(String key, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            key,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

final _beneficiaryContextProvider =
    FutureProvider.autoDispose.family<_BeneficiaryContext, String>((ref, beneficiaryId) async {
  final db = ref.watch(databaseProvider);
  final localId = await BeneficiaryIdentityResolver.resolveLocalBeneficiaryId(
    database: db,
    beneficiaryId: beneficiaryId,
  );

  if (localId == null) {
    throw StateError('تعذر تحديد المستفيد من المعرف الحالي');
  }

  final beneficiary = await db.beneficiariesDao.getBeneficiaryById(localId);
  if (beneficiary == null) {
    throw StateError('المستفيد غير موجود محلياً');
  }

  return _BeneficiaryContext(
    beneficiary: beneficiary,
    localId: localId,
    remoteId: beneficiary.serverId?.toString(),
    fileNumber: beneficiary.fileIdNumber,
  );
});

final _beneficiarySponsorshipsProvider =
    StreamProvider.autoDispose.family<List<SponsorshipWithAssociation>, int>((ref, localId) {
  final db = ref.watch(databaseProvider);
  return db.sponsorshipsDao.watchSponsorshipsForBeneficiary(localId);
});

final _beneficiaryVisitsProvider =
    FutureProvider.autoDispose.family<List<_LinkedVisitItem>, _BeneficiaryContext>((ref, ctx) async {
  final db = ref.watch(databaseProvider);
  final store = FirestoreLocalCacheStore(db);

  final items = <_LinkedVisitItem>[];
  final ids = ctx.candidates;

  final localVisits = await db.visitsDao.getBeneficiaryVisits(ctx.localId.toString());
  for (final v in localVisits) {
    items.add(
      _LinkedVisitItem(
        id: v.id,
        visitType: 'legacy_visit',
        status: v.isSubmitted ? 'completed' : 'scheduled',
        scheduledAt: v.visitDate,
        completedAt: v.isSubmitted ? v.updatedAt : null,
        summary: v.notes,
        nextVisitAt: null,
        visitedByName: v.staffName,
      ),
    );
  }

  final cacheRows = await store.getAll('beneficiary_visits');
  for (final row in cacheRows) {
    final payload = row.payload;
    final pBeneficiaryId = _stringVal(payload['beneficiaryId']);
    final pBeneficiaryLocalId = _stringVal(payload['beneficiaryLocalId']);
    final pBeneficiaryRemoteId = _stringVal(payload['beneficiaryRemoteId']);
    final pFile = _stringVal(payload['beneficiaryFileNumber']);

    final matches = ids.contains(pBeneficiaryId) ||
        ids.contains(pBeneficiaryLocalId) ||
        ids.contains(pBeneficiaryRemoteId) ||
        (pFile != null && ids.contains(pFile));

    if (!matches) continue;

    items.add(
      _LinkedVisitItem(
        id: _stringVal(payload['id']) ?? row.localId,
        visitType: _stringVal(payload['visitType']) ?? 'other',
        status: _stringVal(payload['status']) ?? 'scheduled',
        scheduledAt: _dateVal(payload['scheduledAt']),
        completedAt: _dateVal(payload['completedAt']),
        summary: _stringVal(payload['summary']),
        nextVisitAt: _dateVal(payload['nextVisitAt']),
        visitedByName: _stringVal(payload['visitedByName']),
      ),
    );
  }

  final uniqueById = <String, _LinkedVisitItem>{};
  for (final item in items) {
    uniqueById[item.id] = item;
  }

  final merged = uniqueById.values.toList()
    ..sort((a, b) => (b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0)));

  return merged;
});

final _beneficiaryFollowupsProvider =
    FutureProvider.autoDispose.family<List<_LinkedFollowupItem>, _BeneficiaryContext>((ref, ctx) async {
  final db = ref.watch(databaseProvider);
  final store = FirestoreLocalCacheStore(db);
  final rows = await store.getAll('beneficiary_followups');

  final list = <_LinkedFollowupItem>[];
  final ids = ctx.candidates;

  for (final row in rows) {
    final payload = row.payload;
    final pBeneficiaryId = _stringVal(payload['beneficiaryId']);
    final pBeneficiaryLocalId = _stringVal(payload['beneficiaryLocalId']);
    final pBeneficiaryRemoteId = _stringVal(payload['beneficiaryRemoteId']);
    final pFile = _stringVal(payload['beneficiaryFileNumber']);

    final matches = ids.contains(pBeneficiaryId) ||
        ids.contains(pBeneficiaryLocalId) ||
        ids.contains(pBeneficiaryRemoteId) ||
        (pFile != null && ids.contains(pFile));

    if (!matches) continue;

    list.add(
      _LinkedFollowupItem(
        id: _stringVal(payload['id']) ?? row.localId,
        type: _stringVal(payload['type']) ?? 'other',
        status: _stringVal(payload['status']) ?? 'open',
        title: _stringVal(payload['title']) ?? 'متابعة',
        description: _stringVal(payload['description']),
        dueDate: _dateVal(payload['dueDate']),
      ),
    );
  }

  list.sort((a, b) => (b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0))
      .compareTo(a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0)));

  return list;
});

class _BeneficiaryContext {
  const _BeneficiaryContext({
    required this.beneficiary,
    required this.localId,
    required this.remoteId,
    required this.fileNumber,
  });

  final Beneficiary beneficiary;
  final int localId;
  final String? remoteId;
  final String? fileNumber;

  Set<String> get candidates => <String>{
        localId.toString(),
        if (remoteId != null && remoteId!.trim().isNotEmpty) remoteId!.trim(),
        if (fileNumber != null && fileNumber!.trim().isNotEmpty) fileNumber!.trim(),
      };

  @override
  bool operator ==(Object other) {
    return other is _BeneficiaryContext &&
        other.localId == localId &&
        other.remoteId == remoteId &&
        other.fileNumber == fileNumber;
  }

  @override
  int get hashCode => Object.hash(localId, remoteId, fileNumber);
}

class _LinkedVisitItem {
  const _LinkedVisitItem({
    required this.id,
    required this.visitType,
    required this.status,
    required this.scheduledAt,
    required this.completedAt,
    required this.summary,
    required this.nextVisitAt,
    required this.visitedByName,
  });

  final String id;
  final String visitType;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String? summary;
  final DateTime? nextVisitAt;
  final String? visitedByName;
}

class _LinkedFollowupItem {
  const _LinkedFollowupItem({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.dueDate,
  });

  final String id;
  final String type;
  final String status;
  final String title;
  final String? description;
  final DateTime? dueDate;
}

String? _stringVal(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

DateTime? _dateVal(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  final asString = _stringVal(value);
  if (asString == null) return null;
  final decoded = jsonDecode(jsonEncode(value));
  if (decoded is String) {
    return DateTime.tryParse(decoded);
  }
  return DateTime.tryParse(asString);
}

String _fmtDate(DateTime? value) {
  if (value == null) return '---';
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
