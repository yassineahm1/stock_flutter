import 'package:stock_flutter/features/auth/domain/entities/app_user.dart';
import 'package:stock_flutter/features/auth/domain/repositories/auth_repository.dart';

/// Use Case : Connexion utilisateur
/// Équivalent exact à domain/usecase/Authentication.java du professeur
///
/// Contient la logique métier pure de l'authentification.
/// Orchestre l'appel au repository sans connaître l'implémentation.
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  /// Exécute la connexion avec validation des inputs
  Future<AppUser> execute(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email et mot de passe ne peuvent pas être vides');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      throw ArgumentError('Format email invalide');
    }
    if (password.length < 6) {
      throw ArgumentError('Le mot de passe doit contenir au moins 6 caractères');
    }
    return _authRepository.login(email.trim(), password);
  }
}
