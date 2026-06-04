/// Constants globales de l'application
/// Équivalent à core/utils/Constants.java du professeur
class AppConstants {
  AppConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String movementsCollection = 'movements';

  // Seuil d'approvisionnement par défaut
  static const int defaultLowStockThreshold = 5;

  // Types de mouvements
  static const String movementTypeEntry = 'entry';   // Entrée en stock
  static const String movementTypeSale = 'sale';     // Vente (sortie)
}
