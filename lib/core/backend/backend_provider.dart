import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend_config.dart';
import 'firebase/firebase_backend.dart';
import 'remote_backend.dart';

final backendConfigProvider = Provider<BackendConfig>((ref) {
  return BackendConfig.current;
});

final remoteBackendProvider = Provider<RemoteBackend>((ref) {
  final config = ref.watch(backendConfigProvider);

  switch (config.flavor) {
    case BackendFlavor.firebase:
      return FirebaseBackend();
    case BackendFlavor.supabase:
      // TODO(supabase): Return Supabase-backed implementation of RemoteBackend.
      return _UnimplementedRemoteBackend(flavor: config.flavor);
  }
});

final remoteBackendInitializationProvider = FutureProvider<void>((ref) async {
  final backend = ref.watch(remoteBackendProvider);
  await backend.initialize();
});

class _UnimplementedRemoteBackend implements RemoteBackend {
  _UnimplementedRemoteBackend({required this.flavor});

  final BackendFlavor flavor;

  @override
  Future<void> initialize() async {
    // TODO(firebase): Wire SDK initialization for selected backend flavor.
  }

  @override
  Future<JsonMap?> signIn(String email, String password) {
    throw UnimplementedError(
      'Remote backend signIn is not implemented for $flavor yet.',
    );
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError(
      'Remote backend signOut is not implemented for $flavor yet.',
    );
  }

  @override
  Future<void> upsertBeneficiary(JsonMap data) {
    throw UnimplementedError(
      'Remote backend upsertBeneficiary is not implemented for $flavor yet.',
    );
  }

  @override
  Future<void> upsertVisit(String beneficiaryId, JsonMap data) {
    throw UnimplementedError(
      'Remote backend upsertVisit is not implemented for $flavor yet.',
    );
  }

  @override
  Future<void> upsertAttachmentMetadata(String beneficiaryId, JsonMap data) {
    throw UnimplementedError(
      'Remote backend upsertAttachmentMetadata is not implemented for $flavor yet.',
    );
  }

  @override
  Future<String?> uploadAttachment(
    String beneficiaryId,
    String localPath,
    String fileName,
    String contentType,
  ) {
    throw UnimplementedError(
      'Remote backend uploadAttachment is not implemented for $flavor yet.',
    );
  }

  @override
  Future<List<JsonMap>> pullUpdatedBeneficiaries({DateTime? since}) {
    throw UnimplementedError(
      'Remote backend pullUpdatedBeneficiaries is not implemented for $flavor yet.',
    );
  }
}
