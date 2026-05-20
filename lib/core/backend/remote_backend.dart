typedef JsonMap = Map<String, dynamic>;

/// Contract for any remote backend implementation (Firebase/Supabase/etc.).
///
/// Keep this interface SDK-agnostic so feature repositories remain decoupled
/// from any specific backend SDK.
abstract class RemoteBackend {
  Future<void> initialize();

  Future<JsonMap?> signIn(String email, String password);

  Future<void> signOut();

  Future<void> upsertBeneficiary(JsonMap data);

  Future<void> upsertVisit(String beneficiaryId, JsonMap data);

  Future<void> upsertAttachmentMetadata(String beneficiaryId, JsonMap data);

  Future<String?> uploadAttachment(
    String beneficiaryId,
    String localPath,
    String fileName,
    String contentType,
  );

  Future<List<JsonMap>> pullUpdatedBeneficiaries({DateTime? since});
}
