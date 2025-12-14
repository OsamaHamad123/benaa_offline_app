// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بناء - إدارة المستفيدين';

  @override
  String get beneficiariesList => 'قائمة المستفيدين';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسناً';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومة';

  @override
  String get nationalId => 'الرقم الوطني';

  @override
  String get nationalIdRequired => '🆔 الرقم الوطني مطلوب';

  @override
  String nationalIdInvalid(int length) {
    return '🆔 الرقم الوطني يجب أن يكون $length أرقام\n💡 مثال: 123456789';
  }

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneRequired => '📱 رقم الهاتف مطلوب';

  @override
  String get phoneInvalid =>
      '📱 رقم غير صحيح - يجب أن يبدأ بـ 059 أو 056\n💡 مثال: 0595735352 أو +970595735352';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailRequired => '📧 البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid =>
      '📧 البريد الإلكتروني غير صحيح\n💡 مثال: example@email.com';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get birthDateRequired => '📅 تاريخ الميلاد مطلوب';

  @override
  String get birthDateInvalid =>
      '📅 تاريخ الميلاد غير صحيح\n💡 تحقق من صيغة التاريخ';

  @override
  String get birthDateFuture =>
      '📅 تاريخ الميلاد لا يمكن أن يكون في المستقبل\n💡 تحقق من التاريخ المدخل';

  @override
  String get birthDateTooOld =>
      '📅 تاريخ الميلاد غير منطقي\n💡 العمر يجب أن يكون أقل من 120 سنة';

  @override
  String get name => 'الاسم';

  @override
  String nameRequired(String fieldName) {
    return '👤 $fieldName مطلوب';
  }

  @override
  String nameTooShort(String fieldName, int length) {
    return '👤 $fieldName يجب أن يكون حرفين على الأقل\n💡 الطول الحالي: $length';
  }

  @override
  String nameTooLong(String fieldName, int length) {
    return '👤 $fieldName طويل جداً\n💡 الحد الأقصى: 50 حرف (الطول الحالي: $length)';
  }

  @override
  String nameInvalidChars(String fieldName) {
    return '👤 $fieldName يحتوي على رموز غير مسموحة\n💡 استخدم أحرف عربية أو إنجليزية فقط';
  }

  @override
  String nameArabicOnly(String fieldName) {
    return '👤 الرجاء استخدام الأحرف العربية فقط في $fieldName\n💡 مثال: محمد أحمد';
  }

  @override
  String fieldRequired(String fieldName) {
    return '⚠️ $fieldName مطلوب';
  }

  @override
  String get addBeneficiary => 'إضافة مستفيد';

  @override
  String get editBeneficiary => 'تعديل مستفيد';

  @override
  String get deleteBeneficiary => 'حذف مستفيد';

  @override
  String get beneficiaryDetails => 'تفاصيل المستفيد';

  @override
  String get beneficiaryAdded => 'تم إضافة المستفيد بنجاح';

  @override
  String get beneficiaryUpdated => 'تم تحديث المستفيد بنجاح';

  @override
  String get beneficiaryDeleted => 'تم حذف المستفيد بنجاح';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteMessage => 'هل أنت متأكد من حذف هذا العنصر؟';

  @override
  String get deleteWarning => 'هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get networkError => 'خطأ في الاتصال بالشبكة';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get unknownError => 'حدث خطأ غير متوقع';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get married => 'متزوج';

  @override
  String get single => 'أعزب';

  @override
  String get divorced => 'مطلق';

  @override
  String get widowed => 'أرمل';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get totalBeneficiaries => 'إجمالي المستفيدين';

  @override
  String get activeBeneficiaries => 'المستفيدين النشطين';

  @override
  String get pendingBeneficiaries => 'المستفيدين قيد الانتظار';

  @override
  String get todayActivities => 'أنشطة اليوم';

  @override
  String get sync => 'مزامنة';

  @override
  String get syncInProgress => 'جاري المزامنة...';

  @override
  String get syncCompleted => 'تمت المزامنة بنجاح';

  @override
  String get syncFailed => 'فشلت المزامنة';

  @override
  String lastSyncAt(String time) {
    return 'آخر مزامنة: $time';
  }

  @override
  String get draft => 'مسودة';

  @override
  String get drafts => 'المسودات';

  @override
  String get saveDraft => 'حفظ كمسودة';

  @override
  String get loadDraft => 'تحميل مسودة';

  @override
  String get deleteDraft => 'حذف المسودة';

  @override
  String get draftSaved => 'تم حفظ المسودة';

  @override
  String get draftLoaded => 'تم تحميل المسودة';

  @override
  String get attachment => 'مرفق';

  @override
  String get attachments => 'المرفقات';

  @override
  String get addAttachment => 'إضافة مرفق';

  @override
  String get deleteAttachment => 'حذف المرفق';

  @override
  String get viewAttachment => 'عرض المرفق';

  @override
  String get noAttachments => 'لا توجد مرفقات';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get file => 'ملف';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get chooseFile => 'اختر ملف';

  @override
  String get governorate => 'المحافظة';

  @override
  String get city => 'المدينة';

  @override
  String get address => 'العنوان';

  @override
  String get age => 'العمر';

  @override
  String get gender => 'الجنس';

  @override
  String get maritalStatus => 'الحالة الاجتماعية';

  @override
  String get familyMembers => 'أفراد الأسرة';

  @override
  String get notes => 'ملاحظات';

  @override
  String get description => 'الوصف';

  @override
  String get status => 'الحالة';

  @override
  String get priority => 'الأولوية';

  @override
  String get exportToPdf => 'تصدير إلى PDF';

  @override
  String get exportToExcel => 'تصدير إلى Excel';

  @override
  String get exportCompleted => 'تم التصدير بنجاح';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get lightTheme => 'المظهر الفاتح';

  @override
  String get darkTheme => 'المظهر الداكن';

  @override
  String get systemTheme => 'حسب النظام';
}
