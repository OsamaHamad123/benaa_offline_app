import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/responsive_utils_v2.dart';

/// 🎓 Form Field Helper
///
/// Shows help text and examples for form fields
class FormFieldHelper extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? examples;
  final List<String>? tips;
  final IconData icon;
  final Color? color;

  const FormFieldHelper({
    required this.title, required this.description, super.key,
    this.examples,
    this.tips,
    this.icon = Icons.help_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helperColor = color ?? theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.smallSpace),
      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
      decoration: BoxDecoration(
        color: helperColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: helperColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: helperColor, size: 20),
              SizedBox(width: ResponsiveUtils.smallSpace),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: helperColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.smallSpace),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),

          // Examples
          if (examples != null && examples!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.smallSpace),
            Text(
              'أمثلة:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            SizedBox(height: ResponsiveUtils.xSmallSpace),
            ...examples!.map(
              (example) => Padding(
                padding: EdgeInsets.only(right: 12.w, bottom: 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.withOpacity(0.6),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        example,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Tips
          if (tips != null && tips!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.smallSpace),
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.smallSpace),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Colors.amber[700],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'نصائح:',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ...tips!.map(
                    (tip) => Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        '• $tip',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 📋 Quick Help Overlay
///
/// Floating help button with overlay
class QuickHelpOverlay extends StatefulWidget {
  final List<HelpItem> helpItems;
  final String title;

  const QuickHelpOverlay({
    required this.helpItems, super.key,
    this.title = 'المساعدة',
  });

  @override
  State<QuickHelpOverlay> createState() => _QuickHelpOverlayState();
}

class _QuickHelpOverlayState extends State<QuickHelpOverlay> {
  bool _isExpanded = false;

  void _toggleHelp() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Overlay
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleHelp,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

        // Help panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: _isExpanded ? 0 : -300.w,
          top: 0,
          bottom: 0,
          width: 300.w,
          child: Material(
            elevation: 8,
            child: Container(
              color: theme.colorScheme.surface,
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          SizedBox(width: ResponsiveUtils.smallSpace),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleHelp,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
                        itemCount: widget.helpItems.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: ResponsiveUtils.mediumSpace),
                        itemBuilder: (context, index) {
                          final item = widget.helpItems[index];
                          return _HelpItemWidget(item: item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating button
        Positioned(
          right: ResponsiveUtils.mediumSpace,
          bottom: ResponsiveUtils.mediumSpace,
          child: FloatingActionButton(
            onPressed: _toggleHelp,
            child: Icon(_isExpanded ? Icons.close : Icons.help_outline),
          ),
        ),
      ],
    );
  }
}

class _HelpItemWidget extends StatelessWidget {
  final HelpItem item;

  const _HelpItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(item.icon, size: 18, color: theme.colorScheme.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          item.description,
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class HelpItem {
  final String title;
  final String description;
  final IconData icon;

  const HelpItem({
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
  });
}

/// 🎯 Interactive Tour Guide
///
/// Step-by-step tour for new users
class TourGuide extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const TourGuide({
    required this.steps, required this.onComplete, super.key,
    this.onSkip,
  });

  @override
  State<TourGuide> createState() => _TourGuideState();
}

class _TourGuideState extends State<TourGuide> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skip() {
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = widget.steps[_currentStep];

    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          // Highlight area (simplified - would need positioning logic)
          Center(
            child: Container(
              margin: EdgeInsets.all(ResponsiveUtils.largeSpace),
              padding: EdgeInsets.all(ResponsiveUtils.largeSpace),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.mediumSpace),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.icon,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.mediumSpace),

                  // Title
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveUtils.smallSpace),

                  // Description
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveUtils.largeSpace),

                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.steps.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentStep
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.largeSpace),

                  // Buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            child: const Text('السابق'),
                          ),
                        ),
                      if (_currentStep > 0)
                        SizedBox(width: ResponsiveUtils.smallSpace),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _nextStep,
                          child: Text(
                            _currentStep == widget.steps.length - 1
                                ? 'إنهاء'
                                : 'التالي',
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (widget.onSkip != null) ...[
                    SizedBox(height: ResponsiveUtils.smallSpace),
                    TextButton(
                      onPressed: _skip,
                      child: const Text('تخطي الجولة'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData icon;

  const TourStep({
    required this.title,
    required this.description,
    this.icon = Icons.info_outline,
  });
}
