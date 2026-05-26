import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName});
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<void> deleteAccount();
  Future<UserCredential> signInWithGoogle();
}
