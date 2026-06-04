import 'package:stock_flutter/features/auth/domain/entities/app_user.dart';
import 'package:stock_flutter/features/auth/domain/repositories/auth_repository.dart';

/// Use Case : Inscription d'un nouvel utilisateur
/// Équivalent à domain/usecase/ du professeur
class RegisterUseCase {
  final AuthRepository _authRepository;

  const RegisterUseCase(this._authRepository);

  Future<AppUser> execute(String email, String password, String confirmPassword) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email et mot de passe ne peuvent pas être vides');
    }
    if (password != confirmPassword) {
      throw ArgumentError('Les mots de passe ne correspondent pas');
    }
    if (password.length < 6) {
      throw ArgumentError('Le mot de passe doit contenir au moins 6 caractères');
    }
    return _authRepository.register(email.trim(), password);
  }
}
