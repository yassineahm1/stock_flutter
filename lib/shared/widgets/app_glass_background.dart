import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stock_flutter/core/theme/app_theme.dart';

/// Un arrière-plan premium de type Glassmorphism avec des orbes de lumière floutés.
/// Ajoute un effet néon/SaaS moderne et créatif aux pages.
class AppGlassBackground extends StatelessWidget {
  final Widget child;

  const AppGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Fond sombre uniforme
        Container(
          color: AppTheme.backgroundColor,
        ),
        // Orbe violet en haut à droite
        Positioned(
          top: -size.height * 0.15,
          right: -size.width * 0.25,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        // Orbe cyan en bas à gauche
        Positioned(
          bottom: -size.height * 0.2,
          left: -size.width * 0.25,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor.withValues(alpha: 0.13),
            ),
          ),
        ),
        // Couche de flou (Glassmorphic Backdrop Filter)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Le contenu de la page
        child,
      ],
    );
  }
}
