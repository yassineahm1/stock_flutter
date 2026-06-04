import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_flutter/core/router/app_router.dart';
import 'package:stock_flutter/core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Point d'entrée de l'application Stock Flutter
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase avec le projet mybudget-2c631
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: StockFlutterApp(),
    ),
  );
}

/// Application racine
class StockFlutterApp extends ConsumerWidget {
  const StockFlutterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Stock Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
