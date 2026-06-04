import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_flutter/features/auth/domain/entities/app_user.dart';
import 'package:stock_flutter/features/auth/domain/repositories/auth_repository.dart';

/// Implémentation du AuthRepository via Firebase Authentication
/// Équivalent exact à data/services/AuthRepoImpl.java du professeur
///
/// C'est ici que le code Firebase réel est écrit.
/// Le domaine ne voit jamais Firebase, seulement l'interface AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  const AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<AppUser> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapToAppUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<AppUser> register(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapToAppUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapToAppUser(user) : null;
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapToAppUser(user) : null;
    });
  }

  /// Convertit un User Firebase en AppUser (entité domaine)
  AppUser _mapToAppUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Traduit les exceptions Firebase en messages compréhensibles
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Aucun utilisateur trouvé avec cet email');
      case 'wrong-password':
        return Exception('Mot de passe incorrect');
      case 'email-already-in-use':
        return Exception('Cet email est déjà utilisé');
      case 'invalid-email':
        return Exception('Format email invalide');
      case 'weak-password':
        return Exception('Le mot de passe est trop faible');
      case 'user-disabled':
        return Exception('Ce compte a été désactivé');
      default:
        return Exception('Erreur d\'authentification: ${e.message}');
    }
  }
}
