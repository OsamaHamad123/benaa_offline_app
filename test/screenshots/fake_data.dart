// Clearly fictional sample data for the screenshot harness.
//
// Rules: invented names built from common first names + generic family names,
// obviously fake phone numbers (0599 000 0xx), no identity numbers shown
// anywhere. `idNumber` is a required unique column, so it gets a small
// sequential placeholder (1, 2, 3 ...) that none of the captured screens show.
import 'package:benaa_offline_app/data/db/drift_database.dart';
import 'package:drift/drift.dart';

class _Person {
  final String first, father, grandfather, family;
  final int gender; // 1 = male, 2 = female
  final int section; // 1 orphan, 2 widow, 3 poor, 4 disability
  final int province;
  final int ageYears;
  final int individuals;
  final String sync;
  final String address;
  const _Person(this.first, this.father, this.grandfather, this.family,
      this.gender, this.section, this.province, this.ageYears,
      this.individuals, this.sync, this.address);
}

const _people = <_Person>[
  _Person('سارة', 'أحمد', 'محمود', 'السالم', 2, 2, 1, 38, 6, 'synced', 'حي الزهور - شارع المدارس'),
  _Person('يوسف', 'خالد', 'عمر', 'النجار', 1, 1, 9, 11, 5, 'pending', 'حي السلام - قرب السوق'),
  _Person('مريم', 'علي', 'حسن', 'الحداد', 2, 3, 7, 45, 7, 'synced', 'حي النور'),
  _Person('عمر', 'محمد', 'صالح', 'الخطيب', 1, 4, 1, 29, 4, 'synced', 'حي الربيع'),
  _Person('فاطمة', 'حسين', 'جاسم', 'العلي', 2, 2, 8, 41, 5, 'pending', 'حي الأمل'),
  _Person('آدم', 'سامي', 'ناصر', 'الكريم', 1, 1, 2, 9, 6, 'synced', 'حي الورود'),
  _Person('زينب', 'كريم', 'عادل', 'الصالح', 2, 3, 10, 52, 8, 'synced', 'حي الجامعة'),
  _Person('ليلى', 'فؤاد', 'رشيد', 'العمر', 2, 1, 1, 13, 4, 'synced', 'حي البساتين'),
  _Person('حسن', 'إبراهيم', 'يوسف', 'الأحمد', 1, 3, 5, 47, 9, 'pending', 'حي الفرات'),
  _Person('نور', 'مصطفى', 'جمال', 'الحسن', 2, 2, 9, 35, 3, 'synced', 'حي الياسمين'),
  _Person('علي', 'حيدر', 'كاظم', 'السعدي', 1, 1, 7, 8, 5, 'synced', 'حي الشهداء'),
  _Person('هدى', 'نبيل', 'منير', 'الشامي', 2, 4, 1, 26, 4, 'synced', 'حي الرياض'),
  _Person('خالد', 'وليد', 'فاضل', 'الرفاعي', 1, 3, 11, 50, 7, 'synced', 'حي المعلمين'),
  _Person('رقية', 'باسم', 'طارق', 'الموسوي', 2, 1, 8, 12, 6, 'pending', 'حي الحسين'),
  _Person('محمد', 'رائد', 'سعيد', 'البكري', 1, 1, 9, 10, 5, 'synced', 'حي القادسية'),
  _Person('أمل', 'ماجد', 'هاشم', 'الجبوري', 2, 2, 5, 44, 6, 'synced', 'حي التحرير'),
  _Person('سلمان', 'قاسم', 'عبدالله', 'الزيدي', 1, 3, 14, 58, 8, 'synced', 'حي الصناعة'),
  _Person('دعاء', 'ياسر', 'مهدي', 'العبيدي', 2, 1, 1, 7, 4, 'synced', 'حي الكرامة'),
];

/// Stable reference date so the counts don't depend on the clock too much;
/// relative offsets keep "today"/"this week" widgets populated.
Future<void> seedFakeData(AppDatabase db, {DateTime? now}) async {
  final today = now ?? DateTime.now();

  await db.batch((b) {
    for (var i = 0; i < _people.length; i++) {
      final p = _people[i];
      final created = today.subtract(Duration(days: i * 9 + (i.isEven ? 0 : 2), hours: i));
      final males = (p.individuals / 2).ceil();
      b.insert(
        db.beneficiaries,
        BeneficiariesCompanion.insert(
          idNumber: i + 1,
          firstName: Value(p.first),
          fatherName: Value(p.father),
          grandFatherName: Value(p.grandfather),
          familyName: Value(p.family),
          gender: Value(p.gender),
          sectionId: Value(p.section),
          province: Value(p.province),
          city: const Value(1),
          birthDate: Value(DateTime(today.year - p.ageYears, (i % 12) + 1, (i % 27) + 1)),
          phoneNumber: 599000001 + i,
          altPhoneNumber: 599000101 + i,
          numberOfIndividuals: Value(p.individuals),
          numberOfMales: Value(males),
          numberOfFemales: Value(p.individuals - males),
          maritalStatus: Value(p.section == 2 ? 4 : (p.ageYears < 18 ? 1 : 2)),
          healthStatus: Value(p.section == 4 ? 4 : (i % 5 == 0 ? 3 : 1)),
          numberOfIndividualsWithChronicDiseases: Value(i % 3),
          numberOfPeopleWithSpecialNeeds: Value(p.section == 4 ? 1 : 0),
          housingStatus: Value((i % 3) + 1),
          currentHousingType: Value((i % 2) + 1),
          displacementStatus: Value(i % 4 == 0 ? 2 : 1),
          currentAddress: Value(p.address),
          descriptionNeeds: Value(i.isEven
              ? 'سلة غذائية شهرية ومستلزمات مدرسية للأطفال'
              : 'مساعدة في إيجار السكن وأدوية مزمنة'),
          userInsertData: const Value('الباحثة سلمى'),
          syncState: Value(p.sync),
          createdAt: Value(created),
          updatedAt: Value(created),
        ),
      );
    }

    // Home visits: several today, the rest spread over the last weeks.
    const staff = ['الباحثة سلمى', 'الباحث مازن', 'الباحثة رنا'];
    const notes = [
      'زيارة منزلية دورية، الأسرة بحاجة إلى سلة غذائية.',
      'تم التحقق من حالة السكن، يوجد تسرب مياه في السقف.',
      'متابعة الحالة الصحية للأم وتوفير الأدوية الشهرية.',
      'تسجيل الأطفال في المدرسة وتوزيع القرطاسية.',
      'تحديث بيانات الأسرة بعد ولادة طفل جديد.',
    ];
    for (var v = 0; v < 26; v++) {
      final benId = (v % _people.length) + 1;
      final date = v < 4
          ? today.subtract(Duration(hours: v * 2 + 1))
          : today.subtract(Duration(days: v * 2, hours: v));
      b.insert(
        db.visits,
        VisitsCompanion.insert(
          id: 'visit-$v',
          beneficiaryId: '$benId',
          visitDate: date,
          staffName: staff[v % staff.length],
          notes: Value(notes[v % notes.length]),
          isSubmitted: Value(v > 5),
          createdAt: date,
          updatedAt: date,
          syncState: Value(v > 5 ? 'synced' : 'pending'),
        ),
      );
    }

    // Two document attachments (PDF, no image preview needed) for family 2.
    const docs = [
      ('medical_report', 'تقرير طبي.pdf', 184320),
      ('birth_certificate', 'شهادة ميلاد.pdf', 96256),
    ];
    for (var d = 0; d < docs.length; d++) {
      final (docType, fileName, size) = docs[d];
      final date = today.subtract(Duration(days: 3 + d * 5));
      b.insert(
        db.attachments,
        AttachmentsCompanion.insert(
          id: 'att-$d',
          beneficiaryId: '2',
          fileName: fileName,
          filePath: '/demo/$fileName',
          type: 'pdf',
          fileSize: size,
          documentType: Value(docType),
          personType: const Value('file_owner'),
          createdAt: date,
          updatedAt: date,
          syncState: const Value('synced'),
        ),
      );
    }

    // Activity log for the dashboard feed.
    const acts = [
      ('create', 'تم تسجيل أسرة جديدة'),
      ('visit', 'تم تسجيل زيارة منزلية'),
      ('update', 'تم تحديث بيانات المستفيد'),
      ('visit', 'تم تسجيل زيارة منزلية'),
      ('attachment', 'تمت إضافة مرفق'),
      ('create', 'تم تسجيل أسرة جديدة'),
      ('update', 'تم تحديث بيانات المستفيد'),
    ];
    for (var a = 0; a < acts.length; a++) {
      final (type, desc) = acts[a];
      final p = _people[a];
      b.insert(
        db.activities,
        ActivitiesCompanion.insert(
          id: 'act-$a',
          beneficiaryId: '${a + 1}',
          userId: 'demo',
          activityType: type,
          description: '$desc: ${p.first} ${p.family}',
          createdAt: today.subtract(Duration(minutes: 25 + a * 95)),
          syncState: Value(a < 2 ? 'pending' : 'synced'),
        ),
      );
    }

    // Sponsoring associations (fictional) and their kafalat.
    const assocs = [
      ('assoc-1', 'جمعية الرعاية النموذجية'),
      ('assoc-2', 'مؤسسة العطاء التجريبية'),
    ];
    for (final (id, name) in assocs) {
      b.insert(
        db.associations,
        AssociationsCompanion.insert(
          id: id,
          name: name,
          phone: '0599000900',
          bankName: 'بنك تجريبي',
          accountNumber: '000000',
          accountCurrency: const Value('USD'),
          createdAt: today.subtract(const Duration(days: 200)),
          updatedAt: today.subtract(const Duration(days: 200)),
          syncState: const Value('synced'),
        ),
      );
    }
    const sponsors = ['كافل من الخارج', 'متبرع كريم', 'فاعل خير', 'كفالة جماعية'];
    for (var s = 0; s < 11; s++) {
      final benIndex = s < 6 ? [1, 5, 7, 10, 13, 14][s] : s; // orphans first
      final p = _people[benIndex];
      final start = today.subtract(Duration(days: 30 * (s + 1)));
      b.insert(
        db.sponsorships,
        SponsorshipsCompanion.insert(
          beneficiaryId: benIndex + 1,
          associationId: assocs[s % 2].$1,
          sponsorName: Value(sponsors[s % sponsors.length]),
          guardianName: Value('${p.father} ${p.grandfather} ${p.family}'),
          guardianPhone: Value('0599000${(201 + s).toString().padLeft(3, '0')}'),
          durationMonths: const Value(12),
          startDate: Value(start),
          endDate: Value(start.add(const Duration(days: 365))),
          amount: Value(s.isEven ? 50 : 75),
          currency: const Value('USD'),
          status: Value(s == 9 ? 'paused' : (s == 10 ? 'ended' : 'active')),
          sponsorshipType: const Value('monthly'),
          governorate: const Value('بغداد'),
          city: const Value('المركز'),
          createdAt: Value(start),
          syncState: const Value('synced'),
        ),
      );
    }
  });
}
