import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/features/auth/data/services/auth_repository_impl.dart';
import 'package:stock_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:stock_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:stock_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:stock_flutter/features/auth/domain/entities/app_user.dart';

/// Provider de l'implémentation du AuthRepository
/// Équivalent à l'injection de dépendances dans MainActivity du professeur
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider));
});

/// Provider du LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Provider du RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

/// Notifier de l'état d'authentification
class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loginUseCaseProvider).execute(email, password),
    );
  }

  Future<void> register(String email, String password, String confirmPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(registerUseCaseProvider).execute(email, password, confirmPassword),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(
  AuthNotifier.new,
);
