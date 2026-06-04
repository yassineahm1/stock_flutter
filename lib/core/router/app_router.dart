import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:stock_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:stock_flutter/features/categories/presentation/pages/category_list_page.dart';
import 'package:stock_flutter/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:stock_flutter/features/products/presentation/pages/product_list_page.dart';
import 'package:stock_flutter/features/stock_movements/presentation/pages/stock_movement_page.dart';

/// Routes nommées de l'application
/// Équivalent à la navigation entre Activities du professeur (Intents)
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String stockMovements = '/stock-movements';
}

/// Configuration GoRouter
/// Gère la redirection automatique selon l'état d'authentification
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Non connecté → rediriger vers login
      if (!isAuthenticated && !isOnAuthPage) {
        return AppRoutes.login;
      }
      // Connecté et sur la page login → rediriger vers dashboard
      if (isAuthenticated && isOnAuthPage) {
        return AppRoutes.dashboard;
      }
      return null; // Pas de redirection
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => const ProductListPage(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const CategoryListPage(),
      ),
      GoRoute(
        path: AppRoutes.stockMovements,
        name: 'stock-movements',
        builder: (context, state) => const StockMovementPage(),
      ),
    ],
  );
});
