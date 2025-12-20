import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔌 External Integration Service
/// خدمة التكامل مع الأنظمة الخارجية

class ExternalIntegrationService {
  final String baseUrl;
  final String? apiKey;
  final Map<String, String>? defaultHeaders;

  ExternalIntegrationService({
    required this.baseUrl,
    this.apiKey,
    this.defaultHeaders,
  });

  /// --- WhatsApp Integration ---

  /// إرسال رسالة WhatsApp
  Future<WhatsAppResult> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // TODO: Integrate with WhatsApp Business API or Twilio
      // This is a placeholder implementation

      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/send'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return WhatsAppResult(
          success: true,
          messageId: jsonDecode(response.body)['message_id'],
        );
      } else {
        return WhatsAppResult(
          success: false,
          error: 'فشل الإرسال: ${response.statusCode}',
        );
      }
    } catch (e) {
      return WhatsAppResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// إرسال تذكير بالزيارة عبر WhatsApp
  Future<WhatsAppResult> sendVisitReminder({
    required String phoneNumber,
    required String beneficiaryName,
    required DateTime visitDate,
  }) async {
    final message = '''
السلام عليكم $beneficiaryName،

نذكركم بموعد الزيارة المجدول في:
📅 ${visitDate.toString().substring(0, 10)}
🕐 ${visitDate.toString().substring(11, 16)}

نسعد بلقائكم.
منظومة بناء
    ''';

    return await sendWhatsAppMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  /// --- Payment Gateway Integration ---

  /// إنشاء عملية دفع
  Future<PaymentResult> createPayment({
    required double amount,
    required String currency,
    required String description,
    required String customerName,
    required String? customerEmail,
    required String? customerPhone,
  }) async {
    try {
      // TODO: Integrate with payment gateway (Stripe, PayPal, local gateways)
      // This is a placeholder implementation

      final response = await http.post(
        Uri.parse('$baseUrl/payments/create'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'description': description,
          'customer': {
            'name': customerName,
            'email': customerEmail,
            'phone': customerPhone,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResult(
          success: true,
          paymentId: data['payment_id'],
          paymentUrl: data['payment_url'],
        );
      } else {
        return PaymentResult(
          success: false,
          error: 'فشل إنشاء عملية الدفع: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// التحقق من حالة الدفع
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentStatus(
          paymentId: paymentId,
          status: data['status'],
          amount: data['amount']?.toDouble(),
          paidAt: data['paid_at'] != null
              ? DateTime.parse(data['paid_at'])
              : null,
        );
      } else {
        return PaymentStatus(
          paymentId: paymentId,
          status: 'unknown',
        );
      }
    } catch (e) {
      return PaymentStatus(
        paymentId: paymentId,
        status: 'error',
      );
    }
  }

  /// --- REST API Integration ---

  /// جلب البيانات من API خارجي
  Future<ApiResponse<T>> fetchData<T>({
    required String endpoint,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (fromJson != null) {
          return ApiResponse<T>(
            success: true,
            data: fromJson(data),
          );
        } else {
          return ApiResponse<T>(
            success: true,
            rawData: data,
          );
        }
      } else {
        return ApiResponse<T>(
          success: false,
          error: 'خطأ في جلب البيانات: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// إرسال البيانات إلى API خارجي
  Future<ApiResponse<T>> postData<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (fromJson != null) {
          return ApiResponse<T>(
            success: true,
            data: fromJson(responseData),
          );
        } else {
          return ApiResponse<T>(
            success: true,
            rawData: responseData,
          );
        }
      } else {
        return ApiResponse<T>(
          success: false,
          error: 'خطأ في إرسال البيانات: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// --- Email Integration ---

  /// إرسال بريد إلكتروني
  Future<EmailResult> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<String>? attachments,
  }) async {
    try {
      // TODO: Integrate with email service (SendGrid, AWS SES, etc.)
      // This is a placeholder implementation

      final response = await http.post(
        Uri.parse('$baseUrl/email/send'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          ...?defaultHeaders,
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'body': body,
          'attachments': attachments,
        }),
      );

      if (response.statusCode == 200) {
        return EmailResult(
          success: true,
          messageId: jsonDecode(response.body)['message_id'],
        );
      } else {
        return EmailResult(
          success: false,
          error: 'فشل إرسال البريد: ${response.statusCode}',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// نتيجة WhatsApp
class WhatsAppResult {
  final bool success;
  final String? messageId;
  final String? error;

  WhatsAppResult({
    required this.success,
    this.messageId,
    this.error,
  });
}

/// نتيجة الدفع
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? paymentUrl;
  final String? error;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.paymentUrl,
    this.error,
  });
}

/// حالة الدفع
class PaymentStatus {
  final String paymentId;
  final String status; // pending, completed, failed, cancelled
  final double? amount;
  final DateTime? paidAt;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    this.amount,
    this.paidAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
}

/// نتيجة API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final dynamic rawData;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.rawData,
    this.error,
  });
}

/// نتيجة البريد الإلكتروني
class EmailResult {
  final bool success;
  final String? messageId;
  final String? error;

  EmailResult({
    required this.success,
    this.messageId,
    this.error,
  });
}
