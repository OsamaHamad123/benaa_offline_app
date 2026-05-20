import 'package:firebase_auth/firebase_auth.dart';

import '../remote_backend.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<JsonMap?> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;
    if (user == null) {
      return null;
    }

    return <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'isAnonymous': user.isAnonymous,
      'phoneNumber': user.phoneNumber,
      'photoURL': user.photoURL,
      'idToken': await user.getIdToken(),
    };
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
