class FirestoreCollectionPaths {
  const FirestoreCollectionPaths._();

  static String userDoc(String uid) => 'users/$uid';

  static String beneficiaryDoc(String beneficiaryId) => 'beneficiaries/$beneficiaryId';

  static String visitDoc(String beneficiaryId, String visitId) => 'beneficiaries/$beneficiaryId/visits/$visitId';

  static String attachmentDoc(String beneficiaryId, String attachmentId) =>
      'beneficiaries/$beneficiaryId/attachments/$attachmentId';

  static String familyMemberDoc(String beneficiaryId, String memberId) =>
      'beneficiaries/$beneficiaryId/family_members/$memberId';

  static String familyDeceasedDoc(String beneficiaryId, String deceasedId) =>
      'beneficiaries/$beneficiaryId/family_deceased/$deceasedId';

  static String sponsorshipDoc(String sponsorshipId) => 'sponsorships/$sponsorshipId';

  static String associationDoc(String associationId) => 'associations/$associationId';

  static String representativeDoc(String associationId, String representativeId) =>
      'associations/$associationId/representatives/$representativeId';

  static String taxonomyItemDoc(String group, String itemId) => 'taxonomies/$group/items/$itemId';

  static String activityDoc(String activityId) => 'activities/$activityId';

  static String dataRequestDoc(String requestId) => 'data_requests/$requestId';
}
