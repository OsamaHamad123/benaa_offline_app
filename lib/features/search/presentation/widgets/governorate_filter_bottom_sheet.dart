import 'package:flutter/material.dart';

/// 🏛️ Governorate Filter Bottom Sheet
class GovernorateFilterBottomSheet extends StatefulWidget {
  final String? currentGovernorate;
  final List<String> availableGovernorates;
  final Function(String?) onApply;

  const GovernorateFilterBottomSheet({
    super.key,
    this.currentGovernorate,
    required this.availableGovernorates,
    required this.onApply,
  });

  @override
  State<GovernorateFilterBottomSheet> createState() =>
      _GovernorateFilterBottomSheetState();
}

class _GovernorateFilterBottomSheetState
    extends State<GovernorateFilterBottomSheet> {
  String? _selectedGovernorate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedGovernorate = widget.currentGovernorate;
  }

  List<String> get _filteredGovernorates {
    if (_searchQuery.isEmpty) {
      return widget.availableGovernorates;
    }
    return widget.availableGovernorates
        .where((gov) => gov.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city, color: Colors.blue.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اختر المحافظة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
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

          // Search Box
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن محافظة...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Governorates List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Clear Filter Option
                ListTile(
                  leading: Icon(
                    Icons.clear_all,
                    color: _selectedGovernorate == null
                        ? Colors.blue.shade700
                        : Colors.grey,
                  ),
                  title: Text(
                    'الكل (بدون فلتر)',
                    style: TextStyle(
                      fontWeight: _selectedGovernorate == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedGovernorate == null
                          ? Colors.blue.shade700
                          : Colors.black87,
                    ),
                  ),
                  trailing: _selectedGovernorate == null
                      ? Icon(Icons.check_circle, color: Colors.blue.shade700)
                      : null,
                  tileColor: _selectedGovernorate == null
                      ? Colors.blue.shade50
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedGovernorate = null;
                    });
                  },
                ),
                Divider(height: 1),
                // Governorate Options
                ..._filteredGovernorates.map((governorate) {
                  final isSelected = _selectedGovernorate == governorate;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isSelected ? Colors.blue.shade700 : Colors.grey,
                    ),
                    title: Text(
                      governorate,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue.shade700)
                        : null,
                    tileColor: isSelected ? Colors.blue.shade50 : null,
                    onTap: () {
                      setState(() {
                        _selectedGovernorate = governorate;
                      });
                    },
                  );
                }),
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
                      widget.onApply(_selectedGovernorate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue.shade700,
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
    );
  }
}
