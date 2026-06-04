import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/core/utils/constants.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';

/// Modèle de données Firestore pour Category
/// Équivalent à data/remote/ du professeur (source distante = Firestore)
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    required super.ownerId,
    required super.createdAt,
  });

  /// Convertit depuis un document Firestore
  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convertit vers un Map Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Retourne le chemin Firestore (multi-tenant SaaS)
  static String collectionPath(String ownerId) =>
      '${AppConstants.usersCollection}/$ownerId/${AppConstants.categoriesCollection}';
}
