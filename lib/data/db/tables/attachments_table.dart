import 'package:drift/drift.dart';

/// Attachments table - المرفقات
/// يدعم أنواع متعددة من الوثائق لكل مستفيد
@DataClassName('Attachment')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  TextColumn get visitId => text().nullable()();

  // معلومات الملف الأساسية
  TextColumn get fileName => text()(); // اسم الملف
  TextColumn get filePath => text()(); // المسار الكامل
  TextColumn get type => text()(); // 'image', 'pdf', 'other'
  IntColumn get fileSize => integer()(); // حجم الملف بالبايت
  TextColumn get thumbnailPath => text().nullable()(); // مسار الصورة المصغرة

  // نوع الوثيقة (Document Type)
  // الوثائق المرفقة: صورة هوية، تقرير طبي، شهادة الميلاد، آخر شهادة،
  // صورة شخصية، صورة طولية، حضر إرث، حجة أعالة يتيم، شهادة الميلاد،
  // آخر شهادة حصل عليها، test، صور شخصية، أوراق ثبوتية أخرى،
  // Test، وكالة في شؤون الولاية، حجة ترمل، حجة والدة، صورة طولية،
  // صورة حساب المحفظة
  TextColumn get documentType => text().nullable()();
  // القيم الممكنة: 'id_card', 'medical_report', 'birth_certificate',
  // 'last_certificate', 'personal_photo', 'full_photo', 'inheritance_deed',
  // 'orphan_care_deed', 'test_document', 'other_documents', 'agency_deed',
  // 'widowhood_deed', 'parenthood_deed', 'wallet_account_photo'

  // الشخص المرتبط بالمرفق (Person Related)
  // اختر الشخص: صاحب الملف، أفراد الأسرة، الأفراد المتوفيين، الأب المتوفي، الأم المتوفية
  TextColumn get personType => text().nullable()();
  // القيم: 'file_owner', 'family_member', 'deceased_member', 'deceased_father', 'deceased_mother'

  TextColumn get personId => text().nullable()(); // ID للشخص (إذا كان فرد من العائلة)

  // ملاحظات على المرفق
  TextColumn get notes => text().nullable()();

  // System fields
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get serverUrl => text().nullable()(); // URL على السيرفر بعد الرفع
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
