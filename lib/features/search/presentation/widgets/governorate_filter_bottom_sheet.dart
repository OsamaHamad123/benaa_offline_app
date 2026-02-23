import 'package:flutter/material.dart';
import '../../../../core/design_system/app_animations.dart';
import '../../../../core/utils/haptic_patterns.dart';

/// 🏛️ Governorate Filter Bottom Sheet
class GovernorateFilterBottomSheet extends StatefulWidget {
  final String? currentGovernorate;
  final List<String> availableGovernorates;
  final Function(String?) onApply;

  const GovernorateFilterBottomSheet({
    required this.availableGovernorates, required this.onApply, super.key,
    this.currentGovernorate,
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
    return ScaleTransitionWidget(
      duration: AppDurations.fast,
      child: Container(
        decoration: const BoxDecoration(
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
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
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن محافظة...',
                  prefixIcon: const Icon(Icons.search),
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
                      HapticPatterns.selection();
                      setState(() {
                        _selectedGovernorate = null;
                      });
                    },
                  ),
                  const Divider(height: 1),
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
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Colors.blue.shade700)
                          : null,
                      tileColor: isSelected ? Colors.blue.shade50 : null,
                      onTap: () {
                        HapticPatterns.selection();
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
              padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticPatterns.success();
                        widget.onApply(_selectedGovernorate);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue.shade700,
                      ),
                      child: const Text(
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
}
