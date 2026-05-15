// ============================================================================
// Firestore Collection Paths — PLACEHOLDER
// ============================================================================
// TODO: Define the Firestore collection structure for the new Firebase backend.
//
// Replace the path strings below with your actual Firestore collection names
// after setting up the Firebase project.
// ============================================================================

class FirestorePaths {
  // Root collections
  static const String beneficiaries = 'beneficiaries';
  static const String visits = 'visits';
  static const String associations = 'associations';
  static const String taxonomies = 'taxonomies';
  static const String sponsorships = 'sponsorships';
  static const String users = 'users';
  static const String devices = 'devices';
  static const String syncLogs = 'sync_logs';

  // Sub-collection paths
  static String userDevices(String userId) => 'users/$userId/devices';
  static String beneficiaryAttachments(String beneficiaryId) => 'beneficiaries/$beneficiaryId/attachments';
  static String beneficiaryVisits(String beneficiaryId) => 'beneficiaries/$beneficiaryId/visits';
}
