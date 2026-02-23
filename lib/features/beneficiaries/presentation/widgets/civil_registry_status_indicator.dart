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
    required this.state,
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == CivilRegistryStatus.initial) {
      return const SizedBox.shrink();
    }

    final message = _getMessage();

    return Semantics(
      liveRegion: true,
      label: message,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _getTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (state.status == CivilRegistryStatus.error && onRetry != null)
              IconButton(
                onPressed: onRetry,
                tooltip: 'إعادة المحاولة',
                icon: Icon(Icons.refresh, size: 20.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case CivilRegistryStatus.loading:
        return SizedBox(
          width: 16.w,
          height: 16.h,
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
        );
      case CivilRegistryStatus.success:
        return Icon(Icons.check_circle, color: colorScheme.primary, size: 20.sp);
      case CivilRegistryStatus.notFound:
        return Icon(Icons.warning_rounded, color: colorScheme.secondary, size: 20.sp);
      case CivilRegistryStatus.error:
        return Icon(Icons.error_rounded, color: colorScheme.error, size: 20.sp);
      case CivilRegistryStatus.initial:
        return const SizedBox.shrink();
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case CivilRegistryStatus.loading:
        return colorScheme.primaryContainer;
      case CivilRegistryStatus.success:
        return colorScheme.primaryContainer;
      case CivilRegistryStatus.notFound:
        return colorScheme.secondaryContainer;
      case CivilRegistryStatus.error:
        return colorScheme.errorContainer;
      case CivilRegistryStatus.initial:
        return Colors.transparent;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case CivilRegistryStatus.loading:
        return colorScheme.primary.withOpacity(0.35);
      case CivilRegistryStatus.success:
        return colorScheme.primary.withOpacity(0.35);
      case CivilRegistryStatus.notFound:
        return colorScheme.secondary.withOpacity(0.35);
      case CivilRegistryStatus.error:
        return colorScheme.error.withOpacity(0.35);
      case CivilRegistryStatus.initial:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case CivilRegistryStatus.loading:
        return colorScheme.onPrimaryContainer;
      case CivilRegistryStatus.success:
        return colorScheme.onPrimaryContainer;
      case CivilRegistryStatus.notFound:
        return colorScheme.onSecondaryContainer;
      case CivilRegistryStatus.error:
        return colorScheme.onErrorContainer;
      case CivilRegistryStatus.initial:
        return colorScheme.onSurface;
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
