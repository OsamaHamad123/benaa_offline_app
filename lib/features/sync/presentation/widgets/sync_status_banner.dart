import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'sync_ui_tokens.dart';

class SyncStatusBanner extends StatelessWidget {
  final String message;
  final SyncTone tone;
  final IconData icon;

  const SyncStatusBanner({
    required this.message,
    required this.tone,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fg = SyncUiTokens.toneForeground(context, tone);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: SyncUiTokens.toneContainer(context, tone),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: fg),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
