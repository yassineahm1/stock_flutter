import 'package:stock_flutter/features/categories/domain/entities/category.dart';

/// Interface du repository des catégories - Domaine pur
/// Équivalent à domain/repositories/ImageRepository.java du professeur
abstract interface class CategoryRepository {
  /// Récupère toutes les catégories du client connecté
  Future<List<Category>> getAllCategories(String ownerId);

  /// Stream temps réel des catégories (Firestore)
  Stream<List<Category>> watchCategories(String ownerId);

  /// Ajoute une nouvelle catégorie
  Future<Category> addCategory(Category category);

  /// Met à jour une catégorie existante
  Future<void> updateCategory(Category category);

  /// Supprime une catégorie
  Future<void> deleteCategory(String categoryId, String ownerId);
}
