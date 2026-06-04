import 'package:stock_flutter/features/categories/domain/entities/category.dart';

/// Entité Product - Domaine pur
/// Équivalent à domain/entities/ du professeur
class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int quantity;         // quantité actuelle en stock
  final int lowStockThreshold; // seuil d'approvisionnement
  final Category category;
  final String ownerId;       // uid du client (multi-tenant SaaS)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.quantity,
    required this.lowStockThreshold,
    required this.category,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vérifie si le produit est en dessous du seuil d'approvisionnement
  bool get isLowStock => quantity <= lowStockThreshold;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    int? lowStockThreshold,
    Category? category,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, quantity: $quantity)';
}
