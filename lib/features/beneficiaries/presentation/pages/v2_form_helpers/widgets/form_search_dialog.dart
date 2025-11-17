import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🔍 Smart Search in Form (Ctrl+F)
class FormSearchDialog extends StatefulWidget {
  final Map<String, String> searchableFields;
  final Function(String fieldKey) onFieldSelected;

  const FormSearchDialog({
    super.key,
    required this.searchableFields,
    required this.onFieldSelected,
  });

  @override
  State<FormSearchDialog> createState() => _FormSearchDialogState();
}

class _FormSearchDialogState extends State<FormSearchDialog> {
  final _searchController = TextEditingController();
  List<MapEntry<String, String>> _filteredFields = [];

  @override
  void initState() {
    super.initState();
    _filteredFields = widget.searchableFields.entries.toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFields = widget.searchableFields.entries.toList();
      } else {
        _filteredFields = widget.searchableFields.entries
            .where(
              (entry) =>
                  entry.value.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500.h, maxWidth: 400.w),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  'البحث في النموذج',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Search Field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث عن حقل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: _onSearchChanged,
            ),

            SizedBox(height: 16.h),

            // Results
            Expanded(
              child: _filteredFields.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredFields.length,
                      itemBuilder: (context, index) {
                        final entry = _filteredFields[index];
                        return ListTile(
                          leading: Icon(
                            Icons.text_fields_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            entry.value,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onFieldSelected(entry.key);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
