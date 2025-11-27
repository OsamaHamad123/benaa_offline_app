import 'package:flutter/material.dart';

/// 🎯 Age Filter Bottom Sheet
/// Allows filtering search results by age range
class AgeFilterBottomSheet extends StatefulWidget {
  final int? initialMinAge;
  final int? initialMaxAge;
  final Function(int? minAge, int? maxAge) onApply;

  const AgeFilterBottomSheet({
    super.key,
    this.initialMinAge,
    this.initialMaxAge,
    required this.onApply,
  });

  @override
  State<AgeFilterBottomSheet> createState() => _AgeFilterBottomSheetState();
}

class _AgeFilterBottomSheetState extends State<AgeFilterBottomSheet> {
  late RangeValues _ageRange;
  bool _isEnabled = false;

  static const double _minAge = 0;
  static const double _maxAge = 100;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialMinAge != null || widget.initialMaxAge != null;
    _ageRange = RangeValues(
      widget.initialMinAge?.toDouble() ?? _minAge,
      widget.initialMaxAge?.toDouble() ?? _maxAge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue.shade700),
              SizedBox(width: 12),
              Text(
                'فلتر العمر',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              // Enable/Disable switch
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                },
              ),
            ],
          ),
          SizedBox(height: 24),

          // Age range display
          if (_isEnabled) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'من ${_ageRange.start.round()} سنة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.arrow_back, color: Colors.blue.shade700),
                  SizedBox(width: 16),
                  Text(
                    'إلى ${_ageRange.end.round()} سنة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Range Slider
            RangeSlider(
              values: _ageRange,
              min: _minAge,
              max: _maxAge,
              divisions: 100,
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
              activeColor: Colors.blue.shade700,
              inactiveColor: Colors.blue.shade100,
              onChanged: (values) {
                setState(() => _ageRange = values);
              },
            ),

            // Quick age preset chips
            SizedBox(height: 16),
            Text(
              'اختيارات سريعة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('أطفال (0-12)', 0, 12),
                _buildPresetChip('مراهقين (13-18)', 13, 18),
                _buildPresetChip('شباب (19-35)', 19, 35),
                _buildPresetChip('كبار (50+)', 50, 100),
              ],
            ),
          ],

          SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('إلغاء'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isEnabled) {
                      widget.onApply(
                        _ageRange.start.round(),
                        _ageRange.end.round(),
                      );
                    } else {
                      widget.onApply(null, null);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'تطبيق الفلتر',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, int min, int max) {
    final isSelected = _isEnabled && _ageRange.start.round() == min && _ageRange.end.round() == max;

    return InkWell(
      onTap: () {
        setState(() {
          _isEnabled = true;
          _ageRange = RangeValues(min.toDouble(), max.toDouble());
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
