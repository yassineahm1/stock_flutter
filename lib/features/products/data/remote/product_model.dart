import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/core/utils/constants.dart';
import 'package:stock_flutter/features/categories/data/remote/category_model.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';

/// Modèle de données Firestore pour Product
/// Équivalent à data/remote/ du professeur (source distante = Firestore)
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.quantity,
    required super.lowStockThreshold,
    required super.category,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convertit depuis un document Firestore
  /// Note : category est passée en paramètre (déjà chargée)
  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Category category,
  ) {
    final data = doc.data()!;
    return ProductModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
      lowStockThreshold: (data['lowStockThreshold'] as int?) ??
          AppConstants.defaultLowStockThreshold,
      category: category,
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertit vers un Map Firestore (stocke seulement l'ID de la catégorie)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'categoryId': category.id,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Retourne le chemin Firestore (multi-tenant SaaS)
  static String collectionPath(String ownerId) =>
      '${AppConstants.usersCollection}/$ownerId/${AppConstants.productsCollection}';
}
