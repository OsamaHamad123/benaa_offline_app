import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 💡 Smart Field Hints System
///
/// Contextual hints that appear when focusing on fields
///
/// Features:
/// - Animated tooltips
/// - Image support
/// - Examples
/// - Format validation hints
/// - Auto-hide on correct input
///
/// Usage:
/// ```dart
/// SmartHintField(
///   hint: SmartHint.nationalId(),
///   child: TextFormField(...),
/// )
/// ```

/// Smart hint configuration
class SmartHint {
  final String title;
  final String description;
  final String? example;
  final String? imageAsset;
  final IconData icon;
  final Color color;
  final List<String>? bulletPoints;
  final Widget? customWidget;

  const SmartHint({
    required this.title,
    required this.description,
    this.example,
    this.imageAsset,
    this.icon = Icons.info_outline,
    this.color = Colors.blue,
    this.bulletPoints,
    this.customWidget,
  });

  // Pre-configured hints

  /// National ID hint
  static SmartHint nationalId() {
    return SmartHint(
      title: 'الرقم الوطني',
      description: 'رقم البطاقة الوطنية الموحدة',
      example: '123456789012345678 (18 رقم)',
      icon: Icons.badge,
      color: Colors.indigo,
      bulletPoints: [
        '✅ يجب أن يتكون من 18 رقماً بالضبط',
        '✅ لا يحتوي على أحرف أو رموز',
        '✅ مكتوب في أعلى البطاقة الوطنية',
        '💡 يبدأ برقم المحافظة',
      ],
    );
  }

  /// Phone number hint
  static SmartHint phoneNumber() {
    return SmartHint(
      title: 'رقم الهاتف',
      description: 'رقم الهاتف المحمول العراقي',
      example: '07701234567',
      icon: Icons.phone,
      color: Colors.green,
      bulletPoints: [
        '✅ يبدأ بـ 07 (07XX)',
        '✅ يتكون من 11 رقماً',
        '✅ بدون مسافات أو فواصل',
        '📱 مثال: 07701234567',
      ],
    );
  }

  /// Email hint
  static SmartHint email() {
    return SmartHint(
      title: 'البريد الإلكتروني',
      description: 'عنوان البريد الإلكتروني',
      example: 'example@email.com',
      icon: Icons.email,
      color: Colors.orange,
      bulletPoints: [
        '✅ يحتوي على @ واحدة فقط',
        '✅ يحتوي على نطاق (مثل .com)',
        '✅ لا يحتوي على مسافات',
        '📧 مثال: ahmad@gmail.com',
      ],
    );
  }

  /// Date of birth hint
  static SmartHint dateOfBirth() {
    return SmartHint(
      title: 'تاريخ الميلاد',
      description: 'تاريخ الميلاد كما في البطاقة الوطنية',
      example: '1990-05-15',
      icon: Icons.calendar_today,
      color: Colors.purple,
      bulletPoints: [
        '✅ بالصيغة: YYYY-MM-DD',
        '✅ يجب أن يكون في الماضي',
        '✅ يجب أن يكون عمر منطقي (1-120 سنة)',
        '📅 مثال: 1990-05-15',
      ],
    );
  }

  /// Address hint
  static SmartHint address() {
    return SmartHint(
      title: 'العنوان',
      description: 'العنوان الكامل للسكن',
      icon: Icons.home,
      color: Colors.brown,
      bulletPoints: [
        '🏠 المحافظة',
        '🏘️ القضاء/المدينة',
        '🏡 الحي/المنطقة',
        '🚪 رقم الدار (إن وجد)',
      ],
    );
  }

  /// Occupation hint
  static SmartHint occupation() {
    return SmartHint(
      title: 'المهنة',
      description: 'المهنة أو العمل الحالي',
      icon: Icons.work,
      color: Colors.teal,
      bulletPoints: [
        '💼 موظف حكومي',
        '🏢 موظف قطاع خاص',
        '🔧 عمل حر',
        '🏠 ربة منزل',
        '🎓 طالب',
        '💤 عاطل عن العمل',
      ],
    );
  }

  /// Income hint
  static SmartHint income() {
    return SmartHint(
      title: 'الدخل الشهري',
      description: 'الدخل الشهري بالدينار العراقي',
      example: '500,000 IQD',
      icon: Icons.attach_money,
      color: Colors.amber,
      bulletPoints: [
        '💰 بالدينار العراقي (IQD)',
        '✅ أرقام فقط (بدون فواصل)',
        '✅ لا يمكن أن يكون سالباً',
        '💡 مثال: 500000',
      ],
    );
  }

  /// Family members hint
  static SmartHint familyMembers() {
    return SmartHint(
      title: 'عدد أفراد العائلة',
      description: 'عدد الأشخاص الذين تعيلهم',
      icon: Icons.people,
      color: Colors.pink,
      bulletPoints: [
        '👨‍👩‍👧‍👦 الزوج/الزوجة',
        '👶 الأطفال',
        '👴 الوالدين',
        '👥 المعالين الآخرين',
      ],
    );
  }

  /// UNHCR number hint
  static SmartHint unhcrNumber() {
    return SmartHint(
      title: 'رقم المفوضية',
      description: 'رقم المفوضية السامية للأمم المتحدة لشؤون اللاجئين',
      example: '123-XX-C-12345',
      icon: Icons.verified_user,
      color: Colors.blue,
      bulletPoints: [
        '✅ يتكون من أرقام وأحرف',
        '✅ يحتوي على شرطات (-)',
        '📝 مثال: 123-XX-C-12345',
        '⚠️ تأكد من الكتابة بدقة',
      ],
    );
  }

  /// Ration card hint
  static SmartHint rationCard() {
    return SmartHint(
      title: 'رقم البطاقة التموينية',
      description: 'رقم البطاقة التموينية العراقية',
      example: '1234567890',
      icon: Icons.credit_card,
      color: Colors.deepOrange,
      bulletPoints: [
        '✅ يتكون من 10 أرقام',
        '✅ لا يحتوي على أحرف',
        '📇 مكتوب على البطاقة التموينية',
        '💡 مثال: 1234567890',
      ],
    );
  }
}

/// Smart hint field wrapper
class SmartHintField extends StatefulWidget {
  final SmartHint hint;
  final Widget child;
  final bool showOnFocus;
  final Duration animationDuration;
  final Alignment tooltipAlignment;

  const SmartHintField({
    super.key,
    required this.hint,
    required this.child,
    this.showOnFocus = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.tooltipAlignment = Alignment.bottomLeft,
  });

  @override
  State<SmartHintField> createState() => _SmartHintFieldState();
}

class _SmartHintFieldState extends State<SmartHintField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.showOnFocus) {
      _focusNode.addListener(_handleFocusChange);
    } else {
      _show();
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _show();
    } else {
      _hide();
    }
  }

  void _show() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      _controller.forward();
    }
  }

  void _hide() {
    if (_isVisible) {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _isVisible = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original field with focus node
        Focus(focusNode: _focusNode, child: widget.child),

        // Animated hint tooltip
        if (_isVisible)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                child: _buildHintCard(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.hint.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.hint.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.hint.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(widget.hint.icon, color: widget.hint.color, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.hint.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.hint.color,
                  ),
                ),
              ),
              // Close button
              GestureDetector(
                onTap: _hide,
                child: Icon(
                  Icons.close,
                  size: 18.sp,
                  color: widget.hint.color.withOpacity(0.6),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Description
          Text(
            widget.hint.description,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),

          // Example
          if (widget.hint.example != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16.sp,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.hint.example!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'monospace',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bullet points
          if (widget.hint.bulletPoints != null && widget.hint.bulletPoints!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...widget.hint.bulletPoints!.map(
              (point) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: widget.hint.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Custom widget
          if (widget.hint.customWidget != null) ...[
            SizedBox(height: 12.h),
            widget.hint.customWidget!,
          ],

          // Image
          if (widget.hint.imageAsset != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                widget.hint.imageAsset!,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 600, // ✅ Image Optimization: تصغير في الذاكرة
                cacheHeight: 360,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120.h,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 32.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact hint badge (alternative to full card)
class HintBadge extends StatelessWidget {
  final SmartHint hint;
  final VoidCallback? onTap;

  const HintBadge({super.key, required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFullHint(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: hint.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: hint.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hint.icon, size: 14.sp, color: hint.color),
            SizedBox(width: 6.w),
            Text(
              hint.title,
              style: TextStyle(
                fontSize: 12.sp,
                color: hint.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.help_outline,
              size: 14.sp,
              color: hint.color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(hint.icon, color: hint.color, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        hint.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: hint.color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  hint.description,
                  style: TextStyle(fontSize: 14.sp, height: 1.5),
                ),

                // Example
                if (hint.example != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      hint.example!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],

                // Bullet points
                if (hint.bulletPoints != null) ...[
                  SizedBox(height: 16.h),
                  ...hint.bulletPoints!.map(
                    (point) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        '• $point',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
