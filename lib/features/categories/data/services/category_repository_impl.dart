import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/features/categories/data/remote/category_model.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';
import 'package:stock_flutter/features/categories/domain/repositories/category_repository.dart';

/// Implémentation du CategoryRepository via Firestore
/// Équivalent à data/services/ du professeur
class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  const CategoryRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) {
    return _firestore.collection(CategoryModel.collectionPath(ownerId));
  }

  @override
  Future<List<Category>> getAllCategories(String ownerId) async {
    final snapshot = await _collection(ownerId).orderBy('name').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<Category>> watchCategories(String ownerId) {
    return _collection(ownerId).orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Category> addCategory(Category category) async {
    final model = CategoryModel(
      id: '',
      name: category.name,
      description: category.description,
      ownerId: category.ownerId,
      createdAt: category.createdAt,
    );
    final docRef = await _collection(category.ownerId).add(model.toFirestore());
    return category.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      ownerId: category.ownerId,
      createdAt: category.createdAt,
    );
    await _collection(category.ownerId).doc(category.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteCategory(String categoryId, String ownerId) async {
    await _collection(ownerId).doc(categoryId).delete();
  }
}
