import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application title
  ///
  /// In ar, this message translates to:
  /// **'بناء - إدارة المستفيدين'**
  String get appTitle;

  /// Beneficiaries list page title
  ///
  /// In ar, this message translates to:
  /// **'قائمة المستفيدين'**
  String get beneficiariesList;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومة'**
  String get info;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوطني'**
  String get nationalId;

  /// Error message for required national ID
  ///
  /// In ar, this message translates to:
  /// **'🆔 الرقم الوطني مطلوب'**
  String get nationalIdRequired;

  /// Error message for invalid national ID
  ///
  /// In ar, this message translates to:
  /// **'🆔 الرقم الوطني يجب أن يكون {length} أرقام\n💡 مثال: 123456789'**
  String nationalIdInvalid(int length);

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'📱 رقم الهاتف مطلوب'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'📱 رقم غير صحيح - يجب أن يبدأ بـ 059 أو 056\n💡 مثال: 0595735352 أو +970595735352'**
  String get phoneInvalid;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'📧 البريد الإلكتروني مطلوب'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'📧 البريد الإلكتروني غير صحيح\n💡 مثال: example@email.com'**
  String get emailInvalid;

  /// No description provided for @birthDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get birthDate;

  /// No description provided for @birthDateRequired.
  ///
  /// In ar, this message translates to:
  /// **'📅 تاريخ الميلاد مطلوب'**
  String get birthDateRequired;

  /// No description provided for @birthDateInvalid.
  ///
  /// In ar, this message translates to:
  /// **'📅 تاريخ الميلاد غير صحيح\n💡 تحقق من صيغة التاريخ'**
  String get birthDateInvalid;

  /// No description provided for @birthDateFuture.
  ///
  /// In ar, this message translates to:
  /// **'📅 تاريخ الميلاد لا يمكن أن يكون في المستقبل\n💡 تحقق من التاريخ المدخل'**
  String get birthDateFuture;

  /// No description provided for @birthDateTooOld.
  ///
  /// In ar, this message translates to:
  /// **'📅 تاريخ الميلاد غير منطقي\n💡 العمر يجب أن يكون أقل من 120 سنة'**
  String get birthDateTooOld;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// Error message for required name field
  ///
  /// In ar, this message translates to:
  /// **'👤 {fieldName} مطلوب'**
  String nameRequired(String fieldName);

  /// No description provided for @nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'👤 {fieldName} يجب أن يكون حرفين على الأقل\n💡 الطول الحالي: {length}'**
  String nameTooShort(String fieldName, int length);

  /// No description provided for @nameTooLong.
  ///
  /// In ar, this message translates to:
  /// **'👤 {fieldName} طويل جداً\n💡 الحد الأقصى: 50 حرف (الطول الحالي: {length})'**
  String nameTooLong(String fieldName, int length);

  /// No description provided for @nameInvalidChars.
  ///
  /// In ar, this message translates to:
  /// **'👤 {fieldName} يحتوي على رموز غير مسموحة\n💡 استخدم أحرف عربية أو إنجليزية فقط'**
  String nameInvalidChars(String fieldName);

  /// No description provided for @nameArabicOnly.
  ///
  /// In ar, this message translates to:
  /// **'👤 الرجاء استخدام الأحرف العربية فقط في {fieldName}\n💡 مثال: محمد أحمد'**
  String nameArabicOnly(String fieldName);

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'⚠️ {fieldName} مطلوب'**
  String fieldRequired(String fieldName);

  /// No description provided for @addBeneficiary.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستفيد'**
  String get addBeneficiary;

  /// No description provided for @editBeneficiary.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مستفيد'**
  String get editBeneficiary;

  /// No description provided for @deleteBeneficiary.
  ///
  /// In ar, this message translates to:
  /// **'حذف مستفيد'**
  String get deleteBeneficiary;

  /// No description provided for @beneficiaryDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المستفيد'**
  String get beneficiaryDetails;

  /// No description provided for @beneficiaryAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المستفيد بنجاح'**
  String get beneficiaryAdded;

  /// No description provided for @beneficiaryUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المستفيد بنجاح'**
  String get beneficiaryUpdated;

  /// No description provided for @beneficiaryDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستفيد بنجاح'**
  String get beneficiaryDeleted;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا العنصر؟'**
  String get confirmDeleteMessage;

  /// No description provided for @deleteWarning.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء لا يمكن التراجع عنه'**
  String get deleteWarning;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالشبكة'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get female;

  /// No description provided for @married.
  ///
  /// In ar, this message translates to:
  /// **'متزوج'**
  String get married;

  /// No description provided for @single.
  ///
  /// In ar, this message translates to:
  /// **'أعزب'**
  String get single;

  /// No description provided for @divorced.
  ///
  /// In ar, this message translates to:
  /// **'مطلق'**
  String get divorced;

  /// No description provided for @widowed.
  ///
  /// In ar, this message translates to:
  /// **'أرمل'**
  String get widowed;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @totalBeneficiaries.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستفيدين'**
  String get totalBeneficiaries;

  /// No description provided for @activeBeneficiaries.
  ///
  /// In ar, this message translates to:
  /// **'المستفيدين النشطين'**
  String get activeBeneficiaries;

  /// No description provided for @pendingBeneficiaries.
  ///
  /// In ar, this message translates to:
  /// **'المستفيدين قيد الانتظار'**
  String get pendingBeneficiaries;

  /// No description provided for @todayActivities.
  ///
  /// In ar, this message translates to:
  /// **'أنشطة اليوم'**
  String get todayActivities;

  /// No description provided for @sync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة'**
  String get sync;

  /// No description provided for @syncInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري المزامنة...'**
  String get syncInProgress;

  /// No description provided for @syncCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت المزامنة'**
  String get syncFailed;

  /// No description provided for @lastSyncAt.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة: {time}'**
  String lastSyncAt(String time);

  /// No description provided for @draft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draft;

  /// No description provided for @drafts.
  ///
  /// In ar, this message translates to:
  /// **'المسودات'**
  String get drafts;

  /// No description provided for @saveDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get saveDraft;

  /// No description provided for @loadDraft.
  ///
  /// In ar, this message translates to:
  /// **'تحميل مسودة'**
  String get loadDraft;

  /// No description provided for @deleteDraft.
  ///
  /// In ar, this message translates to:
  /// **'حذف المسودة'**
  String get deleteDraft;

  /// No description provided for @draftSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المسودة'**
  String get draftSaved;

  /// No description provided for @draftLoaded.
  ///
  /// In ar, this message translates to:
  /// **'تم تحميل المسودة'**
  String get draftLoaded;

  /// No description provided for @attachment.
  ///
  /// In ar, this message translates to:
  /// **'مرفق'**
  String get attachment;

  /// No description provided for @attachments.
  ///
  /// In ar, this message translates to:
  /// **'المرفقات'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get addAttachment;

  /// No description provided for @deleteAttachment.
  ///
  /// In ar, this message translates to:
  /// **'حذف المرفق'**
  String get deleteAttachment;

  /// No description provided for @viewAttachment.
  ///
  /// In ar, this message translates to:
  /// **'عرض المرفق'**
  String get viewAttachment;

  /// No description provided for @noAttachments.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرفقات'**
  String get noAttachments;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @file.
  ///
  /// In ar, this message translates to:
  /// **'ملف'**
  String get file;

  /// No description provided for @takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختر من المعرض'**
  String get chooseFromGallery;

  /// No description provided for @chooseFile.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملف'**
  String get chooseFile;

  /// No description provided for @governorate.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorate;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @age.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// No description provided for @maritalStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة الاجتماعية'**
  String get maritalStatus;

  /// No description provided for @familyMembers.
  ///
  /// In ar, this message translates to:
  /// **'أفراد الأسرة'**
  String get familyMembers;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notes;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @priority.
  ///
  /// In ar, this message translates to:
  /// **'الأولوية'**
  String get priority;

  /// No description provided for @exportToPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير إلى PDF'**
  String get exportToPdf;

  /// No description provided for @exportToExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير إلى Excel'**
  String get exportToExcel;

  /// No description provided for @exportCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم التصدير بنجاح'**
  String get exportCompleted;

  /// No description provided for @exportFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التصدير'**
  String get exportFailed;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر الفاتح'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر الداكن'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get systemTheme;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
