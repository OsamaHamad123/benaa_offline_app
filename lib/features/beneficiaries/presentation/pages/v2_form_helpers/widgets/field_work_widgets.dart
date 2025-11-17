import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📍 GPS & Location Widgets for Field Work
///
/// Essential for field data collection

class LocationCaptureButton extends StatelessWidget {
  final VoidCallback? onCapture;
  final bool isLoading;
  final String? currentLocation;

  const LocationCaptureButton({
    super.key,
    this.onCapture,
    this.isLoading = false,
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'الموقع الجغرافي',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (currentLocation != null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      currentLocation!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onCapture,
              icon: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location_rounded, size: 20.sp),
              label: Text(
                isLoading ? 'جاري تحديد الموقع...' : 'تحديد الموقع الحالي',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🗺️ Map Preview Widget
class LocationMapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final VoidCallback? onOpenFullMap;

  const LocationMapPreview({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.onOpenFullMap,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRectangle(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Placeholder for map
            Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      size: 48.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'خريطة الموقع',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (address != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        address!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Open full map button
            if (onOpenFullMap != null)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  elevation: 2,
                  child: InkWell(
                    onTap: onOpenFullMap,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(Icons.open_in_full_rounded, size: 20.sp),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ClipRRectangle extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const ClipRRectangle({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}

/// 🎯 GPS Accuracy Indicator
class GPSAccuracyIndicator extends StatelessWidget {
  final double? accuracy; // in meters
  final bool isActive;

  const GPSAccuracyIndicator({super.key, this.accuracy, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    if (!isActive || accuracy == null) {
      return const SizedBox.shrink();
    }

    final isGood = accuracy! < 10;
    final isFair = accuracy! < 30;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color:
            (isGood
                    ? Colors.green
                    : isFair
                    ? Colors.orange
                    : Colors.red)
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gps_fixed_rounded,
            size: 16.sp,
            color: isGood
                ? Colors.green
                : isFair
                ? Colors.orange
                : Colors.red,
          ),
          SizedBox(width: 6.w),
          Text(
            'دقة: ${accuracy!.toStringAsFixed(1)}م',
            style: TextStyle(
              fontSize: 12.sp,
              color: isGood
                  ? Colors.green
                  : isFair
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
