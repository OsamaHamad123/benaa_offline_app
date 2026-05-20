import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

import '../remote_backend.dart';
import 'firebase_auth_service.dart';
import 'firebase_firestore_service.dart';
import 'firebase_storage_service.dart';

class FirebaseBackend implements RemoteBackend {
  FirebaseBackend({
    FirebaseAuthService? authService,
    FirebaseFirestoreService? firestoreService,
    FirebaseStorageService? storageService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirebaseFirestoreService(),
        _storageService = storageService ?? FirebaseStorageService();

  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;
  final FirebaseStorageService _storageService;

  bool _initialized = false;

  static Future<void> initializeFirebaseAtStartup() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await FirebaseFirestoreService().configureOfflinePersistence();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await _firestoreService.configureOfflinePersistence();
    _initialized = true;
  }

  @override
  Future<JsonMap?> signIn(String email, String password) async {
    await initialize();
    return _authService.signIn(email, password);
  }

  @override
  Future<void> signOut() async {
    await initialize();
    await _authService.signOut();
  }

  @override
  Future<void> upsertBeneficiary(JsonMap data) async {
    await initialize();
    await _firestoreService.upsertBeneficiary(data);
  }

  @override
  Future<void> upsertVisit(String beneficiaryId, JsonMap data) async {
    await initialize();
    await _firestoreService.upsertVisit(beneficiaryId, data);
  }

  @override
  Future<void> upsertAttachmentMetadata(String beneficiaryId, JsonMap data) async {
    await initialize();
    await _firestoreService.upsertAttachmentMetadata(beneficiaryId, data);
  }

  @override
  Future<String?> uploadAttachment(
    String beneficiaryId,
    String localPath,
    String fileName,
    String contentType,
  ) async {
    await initialize();
    return _storageService.uploadAttachment(
      beneficiaryId,
      localPath,
      fileName,
      contentType,
    );
  }

  @override
  Future<List<JsonMap>> pullUpdatedBeneficiaries({DateTime? since}) async {
    await initialize();
    return _firestoreService.pullUpdatedBeneficiaries(since: since);
  }
}
