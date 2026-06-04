import 'package:stock_flutter/features/auth/domain/entities/app_user.dart';

/// Interface du repository d'authentification - Domaine pur
/// Équivalent exact à domain/repositories/AuthRepositorie.java du professeur
///
/// Le domaine définit le CONTRAT, la couche data l'implémente.
abstract interface class AuthRepository {
  /// Connexion avec email et mot de passe
  Future<AppUser> login(String email, String password);

  /// Inscription d'un nouveau compte
  Future<AppUser> register(String email, String password);

  /// Déconnexion
  Future<void> logout();

  /// Utilisateur actuellement connecté (null si non connecté)
  Future<AppUser?> getCurrentUser();

  /// Stream de l'état d'authentification
  Stream<AppUser?> get authStateChanges;
}
