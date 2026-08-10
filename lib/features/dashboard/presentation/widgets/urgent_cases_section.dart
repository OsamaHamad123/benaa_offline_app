import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/responsive_bottom_sheet.dart';
import '../../../../data/db/drift_database.dart';

/// Urgent Cases Section - عرض الحالات التي تحتاج متابعة عاجلة
class UrgentCasesSection extends ConsumerWidget {
  const UrgentCasesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUrgentCasesData(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSkeletonLoader();
        }

        final data = snapshot.data!;
        final noVisitsCount = data['noVisitsCount'] as int;
        final poorHealthCount = data['poorHealthCount'] as int;
        final disabilitiesCount = data['disabilitiesCount'] as int;
        final totalUrgent = noVisitsCount + poorHealthCount + disabilitiesCount;

        if (totalUrgent == 0) {
          return _buildEmptyState();
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.05),
                  Colors.orange.withOpacity(0.05),
                ],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حالات تحتاج متابعة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            '$totalUrgent حالة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showUrgentCasesDialog(
                        context,
                        database,
                        noVisitsCount,
                        poorHealthCount,
                        disabilitiesCount,
                      ),
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Urgent Cases List
                if (noVisitsCount > 0)
                  _UrgentCaseItem(
                    icon: Icons.event_busy,
                    title: 'بدون زيارات منذ 30+ يوم',
                    count: noVisitsCount,
                    color: Colors.orange,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'بدون زيارات منذ 30+ يوم',
                      database.beneficiariesDao
                          .getBeneficiariesWithNoRecentVisits(30),
                    ),
                  ),

                if (poorHealthCount > 0) ...[
                  SizedBox(height: 8.h),
                  _UrgentCaseItem(
                    icon: Icons.health_and_safety,
                    title: 'حالة صحية سيئة',
                    count: poorHealthCount,
                    color: Colors.red,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'حالة صحية سيئة',
                      database.beneficiariesDao
                          .getBeneficiariesWithPoorHealth(),
                    ),
                  ),
                ],

                if (disabilitiesCount > 0) ...[
                  SizedBox(height: 8.h),
                  _UrgentCaseItem(
                    icon: Icons.accessible,
                    title: 'ذوو إعاقة',
                    count: disabilitiesCount,
                    color: Colors.purple,
                    onTap: () => _showCasesList(
                      context,
                      database,
                      'ذوو إعاقة',
                      database.beneficiariesDao
                          .getBeneficiariesWithDisabilities(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadUrgentCasesData(
    AppDatabase database,
  ) async {
    final results = await Future.wait([
      database.beneficiariesDao.countBeneficiariesWithNoRecentVisits(30),
      database.beneficiariesDao.countBeneficiariesWithPoorHealth(),
      database.beneficiariesDao.countBeneficiariesWithDisabilities(),
    ]);

    return {
      'noVisitsCount': results[0],
      'poorHealthCount': results[1],
      'disabilitiesCount': results[2],
    };
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48.sp, color: Colors.green),
            SizedBox(height: 12.h),
            Text(
              'لا توجد حالات طارئة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'جميع المستفيدين يتلقون المتابعة المطلوبة',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUrgentCasesDialog(
    BuildContext context,
    AppDatabase database,
    int noVisitsCount,
    int poorHealthCount,
    int disabilitiesCount,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الحالات التي تحتاج متابعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (noVisitsCount > 0)
              ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.orange),
                title: const Text('بدون زيارات منذ 30+ يوم'),
                trailing: Text(
                  '$noVisitsCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'بدون زيارات منذ 30+ يوم',
                    database.beneficiariesDao
                        .getBeneficiariesWithNoRecentVisits(30),
                  );
                },
              ),
            if (poorHealthCount > 0)
              ListTile(
                leading: const Icon(Icons.health_and_safety, color: Colors.red),
                title: const Text('حالة صحية سيئة'),
                trailing: Text(
                  '$poorHealthCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'حالة صحية سيئة',
                    database.beneficiariesDao.getBeneficiariesWithPoorHealth(),
                  );
                },
              ),
            if (disabilitiesCount > 0)
              ListTile(
                leading: const Icon(Icons.accessible, color: Colors.purple),
                title: const Text('ذوو إعاقة'),
                trailing: Text(
                  '$disabilitiesCount',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCasesList(
                    context,
                    database,
                    'ذوو إعاقة',
                    database.beneficiariesDao
                        .getBeneficiariesWithDisabilities(),
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showCasesList(
    BuildContext context,
    AppDatabase database,
    String title,
    Future<List<Beneficiary>> future,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResponsiveBottomSheet(
        title: title,
        icon: Icons.priority_high,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (scrollController) => FutureBuilder<List<Beneficiary>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final beneficiaries = snapshot.data!;
            if (beneficiaries.isEmpty) {
              return const Center(child: Text('لا توجد حالات'));
            }

            return ListView.separated(
              controller: scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: beneficiaries.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final beneficiary = beneficiaries[index];
                return _BeneficiaryCard(
                  beneficiary: beneficiary,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/beneficiaries/${beneficiary.id}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SkeletonCard(height: 200.h, padding: EdgeInsets.all(16.w));
  }
}

/// Urgent Case Item Widget
class _UrgentCaseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _UrgentCaseItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: color),
          ],
        ),
      ),
    );
  }
}

/// Beneficiary Card Widget for List
class _BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;

  const _BeneficiaryCard({required this.beneficiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: _getCategoryColor(
                  beneficiary.sectionId,
                ).withOpacity(0.2),
                child: Text(
                  beneficiary.fullName.substring(0, 1),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(beneficiary.sectionId),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiary.fullName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 12.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          beneficiary.fileIdNumber ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            beneficiary.province?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int? sectionId) {
    switch (sectionId) {
      case 1: // orphan
        return Colors.blue;
      case 3: // widow
        return Colors.purple;
      case 2: // poor
        return Colors.orange;
      case 4: // disabled
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
