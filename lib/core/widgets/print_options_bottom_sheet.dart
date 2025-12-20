import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../printing/printing_service.dart';

/// 🖨️ Print Options Bottom Sheet
/// نافذة خيارات الطباعة

class PrintOptionsBottomSheet extends StatelessWidget {
  final String beneficiaryId;
  final String fullName;
  final String nationalId;
  final String? phoneNumber;
  final String? address;
  final String? dateOfBirth;
  final String? gender;
  final Uint8List? photoBytes;
  final Map<String, dynamic>? beneficiaryData;
  final List<Map<String, dynamic>>? visits;
  final List<Map<String, dynamic>>? sponsorships;

  const PrintOptionsBottomSheet({
    super.key,
    required this.beneficiaryId,
    required this.fullName,
    required this.nationalId,
    this.phoneNumber,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.photoBytes,
    this.beneficiaryData,
    this.visits,
    this.sponsorships,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.print,
                size: 28.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'خيارات الطباعة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Beneficiary Card Option
          _buildOptionCard(
            context: context,
            icon: Icons.badge,
            title: 'طباعة بطاقة المستفيد',
            subtitle: 'بطاقة تعريفية مع رمز QR',
            onTap: () async {
              Navigator.pop(context);
              await _printCard(context);
            },
            onPreview: () async {
              Navigator.pop(context);
              await _previewCard(context);
            },
          ),

          SizedBox(height: 12.h),

          // Full Report Option (if data available)
          if (beneficiaryData != null)
            _buildOptionCard(
              context: context,
              icon: Icons.description,
              title: 'طباعة تقرير كامل',
              subtitle: 'تقرير شامل مع الزيارات والكفالات',
              onTap: () async {
                Navigator.pop(context);
                await _printReport(context);
              },
              onPreview: () async {
                Navigator.pop(context);
                await _previewReport(context);
              },
            ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onPreview,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28.sp,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
          textDirection: TextDirection.rtl,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview button
            IconButton(
              icon: const Icon(Icons.visibility),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: onPreview,
              tooltip: 'معاينة',
            ),
            // Print button
            IconButton(
              icon: const Icon(Icons.print),
              color: Theme.of(context).colorScheme.primary,
              onPressed: onTap,
              tooltip: 'طباعة',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printCard(BuildContext context) async {
    try {
      await PrintingService.printBeneficiaryCard(
        beneficiaryId: beneficiaryId,
        fullName: fullName,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
        photoBytes: photoBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _previewCard(BuildContext context) async {
    try {
      await PrintingService.previewBeneficiaryCard(
        beneficiaryId: beneficiaryId,
        fullName: fullName,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
        photoBytes: photoBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاينة: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _printReport(BuildContext context) async {
    if (beneficiaryData == null) return;

    try {
      await PrintingService.printBeneficiaryReport(
        beneficiaryId: beneficiaryId,
        fullName: fullName,
        beneficiaryData: beneficiaryData!,
        visits: visits ?? [],
        sponsorships: sponsorships ?? [],
        photoBytes: photoBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _previewReport(BuildContext context) async {
    if (beneficiaryData == null) return;

    try {
      await PrintingService.previewBeneficiaryReport(
        beneficiaryId: beneficiaryId,
        fullName: fullName,
        beneficiaryData: beneficiaryData!,
        visits: visits ?? [],
        sponsorships: sponsorships ?? [],
        photoBytes: photoBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاينة: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// عرض نافذة خيارات الطباعة
  static Future<void> show(
    BuildContext context, {
    required String beneficiaryId,
    required String fullName,
    required String nationalId,
    String? phoneNumber,
    String? address,
    String? dateOfBirth,
    String? gender,
    Uint8List? photoBytes,
    Map<String, dynamic>? beneficiaryData,
    List<Map<String, dynamic>>? visits,
    List<Map<String, dynamic>>? sponsorships,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrintOptionsBottomSheet(
        beneficiaryId: beneficiaryId,
        fullName: fullName,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
        photoBytes: photoBytes,
        beneficiaryData: beneficiaryData,
        visits: visits,
        sponsorships: sponsorships,
      ),
    );
  }
}
