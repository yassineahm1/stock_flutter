import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_flutter/core/router/app_router.dart';
import 'package:stock_flutter/core/theme/app_theme.dart';
// import 'firebase_options.dart'; // Décommenter après flutterfire configure

/// Point d'entrée de l'application Stock Flutter
/// Équivalent à MainActivity.java du professeur (point de départ)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // TODO: Décommenter après avoir exécuté 'flutterfire configure'

  runApp(
    // ProviderScope = conteneur Riverpod (injection de dépendances)
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
