import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/civil_registry_provider.dart';

/// 🔔 Civil Registry Status Indicator
///
/// Shows loading/success/error states for civil registry lookup.
class CivilRegistryStatusIndicator extends StatelessWidget {
  final CivilRegistryState state;
  final VoidCallback? onRetry;

  const CivilRegistryStatusIndicator({
    super.key,
    required this.state,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == CivilRegistryStatus.initial) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _getMessage(),
              style: TextStyle(
                fontSize: 13.sp,
                color: _getTextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state.status == CivilRegistryStatus.error && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 20.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (state.status) {
      case CivilRegistryStatus.loading:
        return SizedBox(
          width: 16.w,
          height: 16.h,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case CivilRegistryStatus.success:
        return Icon(Icons.check_circle, color: Colors.green, size: 20.sp);
      case CivilRegistryStatus.notFound:
        return Icon(Icons.warning_rounded, color: Colors.orange, size: 20.sp);
      case CivilRegistryStatus.error:
        return Icon(Icons.error_rounded, color: Colors.red, size: 20.sp);
      case CivilRegistryStatus.initial:
        return const SizedBox.shrink();
    }
  }

  Color _getBackgroundColor() {
    switch (state.status) {
      case CivilRegistryStatus.loading:
        return Colors.blue.shade50;
      case CivilRegistryStatus.success:
        return Colors.green.shade50;
      case CivilRegistryStatus.notFound:
        return Colors.orange.shade50;
      case CivilRegistryStatus.error:
        return Colors.red.shade50;
      case CivilRegistryStatus.initial:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    switch (state.status) {
      case CivilRegistryStatus.loading:
        return Colors.blue.shade200;
      case CivilRegistryStatus.success:
        return Colors.green.shade200;
      case CivilRegistryStatus.notFound:
        return Colors.orange.shade200;
      case CivilRegistryStatus.error:
        return Colors.red.shade200;
      case CivilRegistryStatus.initial:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (state.status) {
      case CivilRegistryStatus.loading:
        return Colors.blue.shade900;
      case CivilRegistryStatus.success:
        return Colors.green.shade900;
      case CivilRegistryStatus.notFound:
        return Colors.orange.shade900;
      case CivilRegistryStatus.error:
        return Colors.red.shade900;
      case CivilRegistryStatus.initial:
        return Colors.black;
    }
  }

  String _getMessage() {
    switch (state.status) {
      case CivilRegistryStatus.loading:
        return 'جاري البحث في السجل المدني...';
      case CivilRegistryStatus.success:
        return 'تم العثور على البيانات في السجل المدني';
      case CivilRegistryStatus.notFound:
        return state.errorMessage ?? 'لم يتم العثور على هذا الرقم في السجل';
      case CivilRegistryStatus.error:
        return state.errorMessage ?? 'حدث خطأ في البحث';
      case CivilRegistryStatus.initial:
        return '';
    }
  }
}
