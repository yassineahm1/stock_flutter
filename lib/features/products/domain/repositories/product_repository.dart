import 'package:stock_flutter/features/products/domain/entities/product.dart';

/// Interface du repository des produits - Domaine pur
abstract interface class ProductRepository {
  /// Récupère tous les produits du client connecté
  Future<List<Product>> getAllProducts(String ownerId);

  /// Stream temps réel des produits (Firestore)
  Stream<List<Product>> watchProducts(String ownerId);

  /// Récupère les produits en dessous du seuil d'approvisionnement
  Future<List<Product>> getLowStockProducts(String ownerId);

  /// Récupère les produits d'une catégorie
  Future<List<Product>> getProductsByCategory(String ownerId, String categoryId);

  /// Ajoute un nouveau produit
  Future<Product> addProduct(Product product);

  /// Met à jour un produit existant
  Future<void> updateProduct(Product product);

  /// Met à jour uniquement la quantité (après un mouvement de stock)
  Future<void> updateProductQuantity(String productId, String ownerId, int newQuantity);

  /// Supprime un produit
  Future<void> deleteProduct(String productId, String ownerId);
}
