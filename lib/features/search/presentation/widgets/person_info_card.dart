import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/responsive_utils_v2.dart';
import '../../../../core/utils/haptic_patterns.dart';
import 'package:benaa_offline_app/core/extensions/context_extensions.dart';
import '../../domain/entities/civil_person.dart';
import 'gender_badge.dart';
import 'location_chip.dart';
import 'person_detail_row.dart';

/// Enhanced Person Info Card - بطاقة معلومات الشخص المحسّنة
///
/// Features:
/// - عرض كل البيانات المتاحة
/// - تصميم عصري مع gradients
/// - Responsive design
/// - Performance optimized
/// - 🎯 Search highlighting support
class PersonInfoCard extends StatelessWidget {
  final CivilPerson person;
  final VoidCallback onCopy;
  final VoidCallback onAddAsBeneficiary;
  final bool expanded;
  final String? searchQuery; // 🎯 NEW: للتظليل

  // ⚡ Cache common colors to avoid withOpacity() calls
  static final _shadowColor = Colors.blue.withOpacity(0.2);
  static final _borderColor = Colors.blue.withOpacity(0.1);
  static final _bgColor = Colors.blue.withOpacity(0.05);
  static final _dividerColor = Colors.blue.withOpacity(0.2);

  const PersonInfoCard({
    super.key,
    required this.person,
    required this.onCopy,
    required this.onAddAsBeneficiary,
    this.expanded = false,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    // ⚡ Get ResponsiveValues once - avoid recalculating on every build
    final rv = ResponsiveUtils.getValues(context);

    return Semantics(
      label: 'بطاقة معلومات ${person.fullName}, الرقم الوطني ${person.nationalId}',
      hint: 'اضغط لإضافة كمستفيد',
      button: true,
      child: Card(
        elevation: 2,
        shadowColor: _shadowColor,
        margin: EdgeInsets.only(bottom: rv.spacing),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _borderColor, width: 1.5),
        ),
        child: InkWell(
          onTap: () {
            HapticPatterns.selection(); // ⚡ خفيف
            onAddAsBeneficiary();
          },
          borderRadius: BorderRadius.circular(16),
          // ⚡ تحسين الأداء - تقليل rebuild area
          excludeFromSemantics: false,
          child: Padding(
            padding: rv.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ⚡ تحسين
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildPersonDetails(context),
                if (expanded) ...[
                  const SizedBox(height: 16),
                  _buildAdditionalInfo(context),
                ],
                const SizedBox(height: 16),
                _buildActions(context, rv),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header with name and badges
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚡ Simple Text - no highlighting for better performance
              Text(
                person.fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GenderBadge(gender: person.gender, compact: true),
                  if (person.city != null || person.governorate != null)
                    LocationChip(
                      city: person.city,
                      governorate: person.governorate,
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.blue, size: 32),
        ),
      ],
    );
  }

  /// Divider - simple and fast
  Widget _buildDivider() {
    return Divider(height: 1.5, thickness: 1.5, color: _dividerColor);
  }

  /// Person details section
  Widget _buildPersonDetails(BuildContext context) {
    return Column(
      children: [
        _buildNationalIdRow(context),
        const SizedBox(height: 12),
        _buildNameBreakdown(),
      ],
    );
  }

  /// National ID row with copy button
  Widget _buildNationalIdRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.badge, color: Colors.indigo, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرقم الوطني',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  person.nationalId,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'نسخ الرقم الوطني ${person.nationalId}',
            button: true,
            child: IconButton(
              onPressed: () => _copyNationalId(context),
              icon: const Icon(Icons.copy, size: 18),
              color: Colors.blue,
              tooltip: 'نسخ الرقم',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Name breakdown
  Widget _buildNameBreakdown() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallDetail(
                Icons.person_outline,
                'الاسم الأول',
                person.firstName,
                Colors.blue,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildSmallDetail(
                Icons.family_restroom,
                'اسم العائلة',
                person.familyName,
                Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSmallDetail(
                Icons.account_circle,
                'اسم الأب',
                person.fatherName,
                Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildSmallDetail(
                Icons.supervisor_account,
                'اسم الجد',
                person.grandFatherName,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Small detail widget
  Widget _buildSmallDetail(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    // ⚡ Cache color operations
    final bgColor = color.withOpacity(0.05);
    final borderColor = color.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Additional info (mother name, birth date)
  Widget _buildAdditionalInfo(BuildContext context) {
    final hasMotherName = person.motherName != null && person.motherName!.isNotEmpty;
    final hasBirthDate = person.birthDate != null && person.birthDate!.isNotEmpty;

    if (!hasMotherName && !hasBirthDate) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات إضافية',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12),
        if (hasMotherName)
          PersonDetailRow(
            icon: Icons.woman,
            label: 'اسم الأم',
            value: person.motherName!,
            iconColor: Colors.pink,
          ),
        if (hasMotherName && hasBirthDate) SizedBox(height: 8),
        if (hasBirthDate)
          PersonDetailRow(
            icon: Icons.cake,
            label: 'تاريخ الميلاد',
            value: person.birthDate!,
            iconColor: Colors.amber,
          ),
      ],
    );
  }

  /// Action buttons
  Widget _buildActions(BuildContext context, ResponsiveValues rv) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticPatterns.selection();
              _copyToClipboard(context);
            },
            icon: Icon(Icons.copy, size: 18),
            label: Text('نسخ', style: TextStyle(fontSize: rv.fontSize)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticPatterns.submit(); // ✨ تأثير اهتزازي عند الضغط
              onAddAsBeneficiary();
            },
            icon: Icon(Icons.person_add_rounded, size: 18),
            label: Text(
              'إضافة كمستفيد',
              style: TextStyle(
                fontSize: rv.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.blue.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Copy national ID only
  void _copyNationalId(BuildContext context) {
    HapticPatterns.selection();
    Clipboard.setData(ClipboardData(text: person.nationalId));
    context.showSuccess('تم نسخ الرقم الوطني ✓');
  }

  /// Copy to clipboard
  void _copyToClipboard(BuildContext context) {
    final text = '''
الاسم الكامل: ${person.fullName}
الرقم الوطني: ${person.nationalId}
الجنس: ${person.gender.arabicLabel}
${person.motherName != null ? 'اسم الأم: ${person.motherName}\n' : ''}${person.birthDate != null ? 'تاريخ الميلاد: ${person.birthDate}\n' : ''}${person.city != null ? 'المدينة: ${person.city}\n' : ''}${person.governorate != null ? 'المحافظة: ${person.governorate}\n' : ''}''';

    Clipboard.setData(ClipboardData(text: text));
    context.showSuccess('تم النسخ إلى الحافظة ✓');
  }
}
