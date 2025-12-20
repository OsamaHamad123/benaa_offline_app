import 'package:flutter/material.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/utils/haptic_patterns.dart';

/// 👥 Gender Filter Bottom Sheet
class GenderFilterBottomSheet extends StatefulWidget {
  final String? currentGender; // 'ذكر' or 'أنثى'
  final Function(String?) onApply;

  const GenderFilterBottomSheet({
    super.key,
    this.currentGender,
    required this.onApply,
  });

  @override
  State<GenderFilterBottomSheet> createState() =>
      _GenderFilterBottomSheetState();
}

class _GenderFilterBottomSheetState extends State<GenderFilterBottomSheet> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.currentGender;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            FadeSlideTransition(
              duration: AppDurations.fast,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_alt, color: Colors.purple.shade700),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'اختر الجنس',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),

            // Gender Options
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Clear Filter Option
                  _buildGenderOption(
                    icon: Icons.clear_all,
                    label: 'الكل (ذكور وإناث)',
                    value: null,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  // Male Option
                  _buildGenderOption(
                    icon: Icons.male,
                    label: 'ذكور فقط',
                    value: 'ذكر',
                    color: Colors.blue,
                  ),
                  SizedBox(height: 12),
                  // Female Option
                  _buildGenderOption(
                    icon: Icons.female,
                    label: 'إناث فقط',
                    value: 'أنثى',
                    color: Colors.pink,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text('إلغاء', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticPatterns.success();
                        widget.onApply(_selectedGender);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.purple.shade700,
                      ),
                      child: Text(
                        'تطبيق',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required String? value,
    required MaterialColor color,
  }) {
    final isSelected = _selectedGender == value;

    return InkWell(
      onTap: () {
        HapticPatterns.selection();
        setState(() {
          _selectedGender = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.shade100 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color.shade700 : color.shade400,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color.shade900 : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color.shade700, size: 28),
          ],
        ),
      ),
    );
  }
}
