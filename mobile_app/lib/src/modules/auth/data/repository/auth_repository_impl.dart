import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/data/remote/services/auth_service.dart';
import '../../domain/repository/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName}) {
    return _authService.signUpWithEmail(email, password, displayName: displayName);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordReset(email);
  }

  @override
  Future<void> deleteAccount() {
    return _authService.deleteAccount();
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }
}
