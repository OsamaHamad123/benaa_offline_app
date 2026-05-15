// ============================================================================
// Firebase Auth Service — PLACEHOLDER
// ============================================================================
// TODO: Implement Firebase Authentication to replace the old company server login.
//
// Steps to implement:
//   1. Add firebase_auth: ^X.X.X to pubspec.yaml
//   2. Run: flutter pub get
//   3. Follow Firebase setup guide: https://firebase.google.com/docs/flutter/setup
//   4. Replace the demo local login in login_page.dart with Firebase sign-in.
//
// DEMO LOGIN MODE:
//   Server authentication is currently disabled.
//   The app accepts any non-empty username + password for local demo login.
// ============================================================================

class FirebaseAuthService {
  /// Sign in with email and password via Firebase Auth.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // TODO: Implement Firebase Auth sign-in.
    // Example:
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    throw UnimplementedError('FirebaseAuthService.signInWithEmailAndPassword is not yet implemented.');
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    // TODO: Implement Firebase Auth sign-out.
    // Example:
    //   await FirebaseAuth.instance.signOut();
    throw UnimplementedError('FirebaseAuthService.signOut is not yet implemented.');
  }

  /// Get the currently signed-in user UID.
  String? getCurrentUserId() {
    // TODO: Return FirebaseAuth.instance.currentUser?.uid;
    return null;
  }

  /// Check if a user is currently signed in.
  bool isSignedIn() {
    // TODO: return FirebaseAuth.instance.currentUser != null;
    return false;
  }
}
