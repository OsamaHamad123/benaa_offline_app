import 'package:cloud_firestore/cloud_firestore.dart';

class CedarSampleDataSeed {
  CedarSampleDataSeed({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seed() async {
    final now = FieldValue.serverTimestamp();

    final assoc1 = 'cedar_assoc_1';
    final assoc2 = 'cedar_assoc_2';
    await _firestore.collection('associations').doc(assoc1).set({
      'id': assoc1,
      'nameAr': 'جمعية Cedar التعليمية',
      'nameEn': 'Cedar Education Association',
      'type': 'educational',
      'registrationNumber': 'CEDAR-ASSOC-001',
      'isActive': true,
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('associations').doc(assoc2).set({
      'id': assoc2,
      'nameAr': 'جمعية Cedar الطبية',
      'nameEn': 'Cedar Medical Association',
      'type': 'medical',
      'registrationNumber': 'CEDAR-ASSOC-002',
      'isActive': true,
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('association_contacts').doc('cedar_contact_1').set({
      'id': 'cedar_contact_1',
      'associationId': assoc1,
      'name': 'أحمد خالد',
      'role': 'manager',
      'phone': '0599000001',
      'isPrimary': true,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('association_contacts').doc('cedar_contact_2').set({
      'id': 'cedar_contact_2',
      'associationId': assoc2,
      'name': 'سارة محمد',
      'role': 'coordinator',
      'phone': '0599000002',
      'isPrimary': true,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    const fileId = 'cedar_sponsorship_file_1';
    await _firestore.collection('sponsorship_files').doc(fileId).set({
      'id': fileId,
      'associationId': assoc1,
      'title': 'Cedar Sample Data - File 1',
      'sourceType': 'manual',
      'status': 'reviewed',
      'totalRows': 3,
      'matchedBeneficiaries': 1,
      'createdBeneficiaries': 1,
      'unmatchedRows': 1,
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('sponsorship_candidates').doc('cedar_candidate_1').set({
      'id': 'cedar_candidate_1',
      'sponsorshipFileId': fileId,
      'associationId': assoc1,
      'rawName': 'محمد محمود علي',
      'nationalId': '900100200',
      'phone': '0598000001',
      'city': 'غزة',
      'matchStatus': 'matched_existing',
      'matchedBeneficiaryId': 'existing_beneficiary_if_any',
      'sponsorshipType': 'monthly',
      'requestedAmount': 300,
      'currency': 'ILS',
      'priority': 'medium',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('sponsorship_candidates').doc('cedar_candidate_2').set({
      'id': 'cedar_candidate_2',
      'sponsorshipFileId': fileId,
      'associationId': assoc1,
      'rawName': 'ليان يوسف أحمد',
      'nationalId': '900100201',
      'phone': '0598000002',
      'city': 'دير البلح',
      'matchStatus': 'created_new_beneficiary',
      'createdBeneficiaryId': 'new_beneficiary_placeholder',
      'sponsorshipType': 'monthly',
      'requestedAmount': 350,
      'currency': 'ILS',
      'priority': 'high',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('sponsorship_candidates').doc('cedar_candidate_3').set({
      'id': 'cedar_candidate_3',
      'sponsorshipFileId': fileId,
      'associationId': assoc1,
      'rawName': 'نورا عادل حمد',
      'phone': '0598000003',
      'city': 'خان يونس',
      'matchStatus': 'needs_review',
      'sponsorshipType': 'emergency',
      'requestedAmount': 500,
      'currency': 'ILS',
      'priority': 'urgent',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('sponsorships').doc('cedar_sponsorship_1').set({
      'id': 'cedar_sponsorship_1',
      'beneficiaryId': 'existing_beneficiary_if_any',
      'beneficiaryFileNumber': 'GZ-2026-000001',
      'associationId': assoc1,
      'sponsorshipFileId': fileId,
      'candidateId': 'cedar_candidate_1',
      'type': 'family_sponsorship',
      'status': 'active',
      'amount': 300,
      'currency': 'ILS',
      'frequency': 'monthly',
      'startDate': DateTime.now().toIso8601String(),
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('beneficiary_visits').doc('cedar_visit_1').set({
      'id': 'cedar_visit_1',
      'beneficiaryId': 'existing_beneficiary_if_any',
      'beneficiaryFileNumber': 'GZ-2026-000001',
      'sponsorshipId': 'cedar_sponsorship_1',
      'associationId': assoc1,
      'visitType': 'follow_up',
      'status': 'scheduled',
      'scheduledAt': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'visitedBy': 'seed',
      'visitedByName': 'Cedar Seeder',
      'summary': 'زيارة مجدولة من بيانات Cedar Sample Data',
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await _firestore.collection('beneficiary_followups').doc('cedar_followup_1').set({
      'id': 'cedar_followup_1',
      'beneficiaryId': 'existing_beneficiary_if_any',
      'relatedVisitId': 'cedar_visit_1',
      'relatedSponsorshipId': 'cedar_sponsorship_1',
      'type': 'call',
      'status': 'open',
      'title': 'متابعة اتصال بعد الزيارة',
      'description': 'Cedar Sample Data follow-up',
      'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'createdBy': 'seed',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}
