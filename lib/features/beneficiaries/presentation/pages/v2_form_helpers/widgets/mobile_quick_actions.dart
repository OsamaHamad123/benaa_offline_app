import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📱 Mobile Quick Actions - Floating Action Button Menu
///
/// Features:
/// ✅ FAB with expandable menu
/// ✅ Copy data from another beneficiary
/// ✅ Clear all fields
/// ✅ Paste from clipboard
/// ✅ Quick fill demo data (for testing)
/// ✅ Material 3 design with animations
class MobileQuickActions extends StatefulWidget {
  final VoidCallback? onCopyFromBeneficiary;
  final VoidCallback? onClearAllFields;
  final VoidCallback? onPasteData;
  final VoidCallback? onFillDemoData;
  final bool enabled;

  const MobileQuickActions({
    super.key,
    this.onCopyFromBeneficiary,
    this.onClearAllFields,
    this.onPasteData,
    this.onFillDemoData,
    this.enabled = true,
  });

  @override
  State<MobileQuickActions> createState() => _MobileQuickActionsState();
}

class _MobileQuickActionsState extends State<MobileQuickActions>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 turn)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleAction(VoidCallback? action, String actionName) {
    if (!widget.enabled) return;

    HapticFeedback.mediumImpact();
    _toggleMenu(); // Close menu

    if (action != null) {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        // Overlay to close menu when tapping outside
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // Action buttons (appear above FAB)
        if (_isExpanded) ...[
          _buildActionButton(
            icon: Icons.content_copy,
            label: 'نسخ من مستفيد',
            color: Colors.blue,
            onTap: () => _handleAction(
              widget.onCopyFromBeneficiary,
              'copy_from_beneficiary',
            ),
            index: 3,
          ),
          _buildActionButton(
            icon: Icons.clear_all,
            label: 'مسح الحقول',
            color: Colors.orange,
            onTap: () => _handleAction(widget.onClearAllFields, 'clear_fields'),
            index: 2,
          ),
          _buildActionButton(
            icon: Icons.paste,
            label: 'لصق البيانات',
            color: Colors.purple,
            onTap: () => _handleAction(widget.onPasteData, 'paste_data'),
            index: 1,
          ),
          if (widget.onFillDemoData != null)
            _buildActionButton(
              icon: Icons.science,
              label: 'بيانات تجريبية',
              color: Colors.teal,
              onTap: () => _handleAction(widget.onFillDemoData, 'demo_data'),
              index: 0,
            ),
        ],

        // Main FAB
        Positioned(
          bottom: 16.h,
          left: 16.w,
          child: FloatingActionButton(
            onPressed: widget.enabled ? _toggleMenu : null,
            backgroundColor: widget.enabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                _isExpanded ? Icons.close : Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    // Calculate position based on index (each button 70.h apart)
    final bottomOffset = 16.h + 60.h + ((index + 1) * 70.h);

    return Positioned(
      bottom: bottomOffset,
      left: 16.w,
      child: ScaleTransition(
        scale: _expandAnimation,
        child: FadeTransition(
          opacity: _expandAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label chip
              Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Action button
              FloatingActionButton.small(
                onPressed: onTap,
                backgroundColor: color,
                heroTag: 'action_$index',
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🗑️ Clear All Fields Dialog
class ClearFieldsDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearFieldsDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange,
        size: 48.sp,
      ),
      title: const Text('تأكيد مسح الحقول'),
      content: const Text(
        'هل أنت متأكد من مسح جميع الحقول؟\n'
        'لن تتمكن من التراجع عن هذا الإجراء.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('مسح الكل'),
        ),
      ],
    );
  }
}

/// 📋 Copy From Beneficiary Dialog
class CopyFromBeneficiaryDialog extends StatefulWidget {
  final List<BeneficiaryPreview> beneficiaries;
  final Function(String beneficiaryId) onSelect;

  const CopyFromBeneficiaryDialog({
    super.key,
    required this.beneficiaries,
    required this.onSelect,
  });

  @override
  State<CopyFromBeneficiaryDialog> createState() =>
      _CopyFromBeneficiaryDialogState();
}

class _CopyFromBeneficiaryDialogState extends State<CopyFromBeneficiaryDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<BeneficiaryPreview> get _filteredBeneficiaries {
    if (_searchQuery.isEmpty) return widget.beneficiaries;

    final query = _searchQuery.toLowerCase();
    return widget.beneficiaries.where((b) {
      return b.name.toLowerCase().contains(query) ||
          b.nationalId.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 600.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.content_copy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                const Expanded(
                  child: Text(
                    'نسخ من مستفيد',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو الرقم الوطني...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            SizedBox(height: 16.h),

            // Beneficiaries list
            Expanded(
              child: _filteredBeneficiaries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _searchQuery.isEmpty
                                ? 'لا يوجد مستفيدون'
                                : 'لم يتم العثور على نتائج',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredBeneficiaries.length,
                      itemBuilder: (context, index) {
                        final beneficiary = _filteredBeneficiaries[index];
                        return _BeneficiaryTile(
                          beneficiary: beneficiary,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelect(beneficiary.id);
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
}

class _BeneficiaryTile extends StatelessWidget {
  final BeneficiaryPreview beneficiary;
  final VoidCallback onTap;

  const _BeneficiaryTile({required this.beneficiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            beneficiary.name[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          beneficiary.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم الوطني: ${beneficiary.nationalId}'),
            if (beneficiary.phoneNumber != null)
              Text('الهاتف: ${beneficiary.phoneNumber}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// 📊 Beneficiary Preview Model
class BeneficiaryPreview {
  final String id;
  final String name;
  final String nationalId;
  final String? phoneNumber;

  const BeneficiaryPreview({
    required this.id,
    required this.name,
    required this.nationalId,
    this.phoneNumber,
  });
}

/// 📋 Swipeable Field Card
///
/// Allows swipe actions on individual fields:
/// - Swipe right: Clear field
/// - Swipe left: Copy field value
class SwipeableFieldCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClear;
  final VoidCallback? onCopy;
  final bool enableSwipe;

  const SwipeableFieldCard({
    super.key,
    required this.child,
    this.onClear,
    this.onCopy,
    this.enableSwipe = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableSwipe) return child;

    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onClear != null) {
          // Swipe right - Clear
          HapticFeedback.mediumImpact();
          onClear!();
        } else if (direction == DismissDirection.endToStart && onCopy != null) {
          // Swipe left - Copy
          HapticFeedback.lightImpact();
          onCopy!();
        }
        return false; // Don't actually dismiss
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.clear, color: Colors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            const Text(
              'مسح',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'نسخ',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.content_copy, color: Colors.blue, size: 24.sp),
          ],
        ),
      ),
      child: child,
    );
  }
}
