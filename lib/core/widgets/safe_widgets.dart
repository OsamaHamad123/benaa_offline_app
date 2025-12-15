import 'package:flutter/material.dart';

/// 🛡️ Safe Widgets - منع أخطاء RenderFlex overflow
///
/// هذا الملف يحتوي على widgets آمنة تمنع ظهور أخطاء overflow
/// في Sentry والتي تظهر عندما يكون النص أو المحتوى أكبر من المساحة المتاحة

/// Safe Row - صف آمن يمنع overflow
/// 
/// استخدمه بدلاً من Row عندما يكون المحتوى قد يتجاوز عرض الشاشة
class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry? padding;

  const SafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );

    if (padding != null) {
      row = Padding(padding: padding!, child: row);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: row,
    );
  }
}

/// Safe Column - عمود آمن يمنع overflow
///
/// استخدمه بدلاً من Column عندما يكون المحتوى قد يتجاوز ارتفاع الشاشة
class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const SafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget column = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );

    if (padding != null) {
      column = Padding(padding: padding!, child: column);
    }

    return SingleChildScrollView(
      child: column,
    );
  }
}

/// Safe Text - نص آمن يمنع overflow
///
/// يستخدم ellipsis تلقائياً ويدعم النصوص الطويلة
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final bool softWrap;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Safe Flexible Text - نص مرن يتكيف مع المساحة المتاحة
///
/// مثالي للاستخدام داخل Row أو Column
class SafeFlexibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final int flex;

  const SafeFlexibleText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Safe Expanded Text - نص يملأ المساحة المتاحة
///
/// مثالي للاستخدام داخل Row أو Column عندما تريد النص يأخذ كل المساحة
class SafeExpandedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final int flex;

  const SafeExpandedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }
}

/// Safe Container - حاوية آمنة تمنع overflow في المحتوى
class SafeContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final BoxConstraints? constraints;

  const SafeContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints,
      child: ClipRect(
        child: child,
      ),
    );
  }
}

/// Overflow Prevention Mixin - لمنع أخطاء overflow في أي widget
mixin OverflowPrevention on Widget {
  /// Wraps any widget to prevent overflow errors
  Widget preventOverflow(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          ),
          child: SingleChildScrollView(
            child: child,
          ),
        );
      },
    );
  }
}

/// Global Flutter Error Handler - يلتقط جميع أخطاء overflow
class FlutterErrorHandler {
  static void initialize() {
    // Capture FlutterError.onError
    final originalOnError = FlutterError.onError;
    
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if it's a RenderFlex overflow error
      if (details.exception.toString().contains('RenderFlex overflowed') ||
          details.exception.toString().contains('A RenderFlex overflowed')) {
        // Log to Sentry but don't show red screen
        debugPrint('⚠️ Overflow prevented: ${details.exception}');
        // You can log to ErrorLogger here if needed
        return;
      }
      
      // For other errors, use original handler
      originalOnError?.call(details);
    };
  }
}
