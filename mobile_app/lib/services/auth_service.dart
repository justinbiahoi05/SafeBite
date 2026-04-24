import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email/password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with email/password
  Future<UserCredential> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name if provided
    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}