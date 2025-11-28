import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/haptic_patterns.dart';

/// ⚡ Autofill Button
///
/// Animated button to trigger autofill from civil registry data.
class AutofillButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final int filledFieldsCount;

  const AutofillButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.filledFieldsCount = 0,
  });

  @override
  State<AutofillButton> createState() => _AutofillButtonState();
}

class _AutofillButtonState extends State<AutofillButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Auto-animate on mount
    if (widget.isEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AutofillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isEnabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.filledFieldsCount > 0
          ? 'تعبئة ${widget.filledFieldsCount} حقل تلقائياً من السجل المدني'
          : 'تعبئة تلقائية من السجل المدني',
      hint: 'اضغط لملء البيانات تلقائياً',
      button: true,
      enabled: widget.isEnabled,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: ElevatedButton.icon(
                onPressed: widget.isEnabled
                    ? () {
                        HapticPatterns.selection();
                        widget.onPressed();
                      }
                    : null,
                icon: Icon(Icons.bolt_rounded, size: 20.sp),
                label: Text(
                  widget.filledFieldsCount > 0 ? 'تعبئة ${widget.filledFieldsCount} حقل تلقائياً' : 'تعبئة تلقائية',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
