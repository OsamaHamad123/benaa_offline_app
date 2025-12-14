import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/utils/haptic_patterns.dart';
import '../../../domain/entities/civil_person.dart';

/// 🎯 Search Actions Helper
///
/// يحتوي على جميع الـ actions المتعلقة بنتائج البحث:
/// - Copy to clipboard
/// - Add as beneficiary
/// - Export results
/// - Share
class SearchActions {
  SearchActions._();

  /// Copy person data to clipboard
  static void copyToClipboard(BuildContext context, CivilPerson person) {
    HapticPatterns.selection();
    final text = '''
الاسم: ${person.fullName}
الرقم الوطني: ${person.nationalId}
الجنس: ${person.gender.arabicLabel}
تاريخ الميلاد: ${person.birthDate ?? 'غير متوفر'}
اسم الأم: ${person.motherName ?? 'غير متوفر'}
المحافظة: ${person.governorate ?? 'غير متوفر'}
القضاء: ${person.city ?? 'غير متوفر'}
    ''';

    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ البيانات'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  /// Navigate to add beneficiary with pre-filled data
  static void addAsBeneficiary(BuildContext context, CivilPerson person) {
    HapticPatterns.submit();

    context.push('/beneficiaries/add', extra: {
      'name': person.fullName,
      'nationalId': person.nationalId,
      'gender': person.gender.arabicLabel,
      'motherName': person.motherName,
      'birthDate': person.birthDate,
      'city': person.city,
      'governorate': person.governorate,
    });
  }

  /// Export results to share
  static void exportResults(
    BuildContext context,
    List<CivilPerson> results,
  ) {
    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد نتائج للتصدير'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticPatterns.selection();

    // Format results as CSV-like text
    final buffer = StringBuffer();
    buffer.writeln('الاسم,الرقم الوطني,الجنس,تاريخ الميلاد,المحافظة,القضاء');

    for (final person in results) {
      buffer.writeln(
        '${person.fullName},${person.nationalId},${person.gender.arabicLabel},'
        '${person.birthDate ?? ''},${person.governorate ?? ''},${person.city ?? ''}',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نسخ ${results.length} نتيجة'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'مشاركة',
            textColor: Colors.white,
            onPressed: () => _shareResults(context, buffer.toString(), results.length),
          ),
        ),
      );
    });
  }

  /// Share results via system share dialog
  static void _shareResults(BuildContext context, String csvData, int count) {
    HapticPatterns.selection();

    Share.share(
      csvData,
      subject: 'نتائج البحث في السجل المدني ($count نتيجة)',
    ).then((result) {
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت المشاركة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في المشاركة: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}
