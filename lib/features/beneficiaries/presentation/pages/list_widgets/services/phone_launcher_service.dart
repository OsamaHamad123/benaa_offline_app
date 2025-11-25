import 'package:url_launcher/url_launcher.dart';

/// 📞 خدمة إطلاق الروابط الخارجية
class PhoneLauncherService {
  PhoneLauncherService._(); // Private constructor (Utility class)

  /// إجراء مكالمة هاتفية
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      // تنظيف الرقم
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse('tel:$cleanPhone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// فتح محادثة واتساب
  /// يدعم أرقام قطاع غزة مع مفاتيح +972 و +970
  static Future<bool> openWhatsApp(String phoneNumber) async {
    try {
      // تنظيف الرقم
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // معالجة أرقام قطاع غزة/فلسطين
      if (cleanPhone.startsWith('059') || cleanPhone.startsWith('056')) {
        // استخدام +970 كمفتاح افتراضي لأرقام تبدأ ب 0
        cleanPhone = '970${cleanPhone.substring(1)}';
      } else if (cleanPhone.startsWith('+972')) {
        // إزالة + للاستخدام مع WhatsApp
        cleanPhone = cleanPhone.substring(1);
      } else if (cleanPhone.startsWith('+970')) {
        cleanPhone = cleanPhone.substring(1);
      } else if (cleanPhone.startsWith('00972')) {
        cleanPhone = '972${cleanPhone.substring(5)}';
      } else if (cleanPhone.startsWith('00970')) {
        cleanPhone = '970${cleanPhone.substring(5)}';
      } else if (cleanPhone.startsWith('+')) {
        cleanPhone = cleanPhone.substring(1);
      }

      final uri = Uri.parse('https://wa.me/$cleanPhone');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// فتح موقع GPS على الخرائط
  static Future<bool> openLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      // استخدام Google Maps
      final uri = Uri.parse(
        'https://maps.google.com/?q=$latitude,$longitude${label != null ? '($label)' : ''}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// فتح تطبيق الخرائط الافتراضي للملاحة
  static Future<bool> openNavigation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // محاولة فتح Google Maps للملاحة
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// إرسال SMS
  static Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse(
        'sms:$cleanPhone${message != null ? '?body=${Uri.encodeComponent(message)}' : ''}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// فتح البريد الإلكتروني
  static Future<bool> sendEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
