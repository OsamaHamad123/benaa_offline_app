import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'sync_ui_tokens.dart';

class SyncSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final SyncTone tone;
  final Widget child;

  const SyncSectionCard({
    required this.title,
    required this.icon,
    required this.tone,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fg = SyncUiTokens.toneForeground(context, tone);

    return Card(
      color: SyncUiTokens.toneContainer(context, tone),
      child: Padding(
        padding: EdgeInsets.all(SyncUiTokens.contentPadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: fg, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            child,
          ],
        ),
      ),
    );
  }
}
