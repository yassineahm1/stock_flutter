import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_flutter/features/categories/data/remote/category_model.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';
import 'package:stock_flutter/features/products/data/remote/product_model.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/products/domain/repositories/product_repository.dart';

/// Implémentation du ProductRepository via Firestore
/// Équivalent à data/services/ du professeur
class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  const ProductRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) {
    return _firestore.collection(ProductModel.collectionPath(ownerId));
  }

  /// Charge la catégorie associée à un produit
  Future<Category> _loadCategory(String ownerId, String categoryId) async {
    final doc = await _firestore
        .collection(CategoryModel.collectionPath(ownerId))
        .doc(categoryId)
        .get();
    return CategoryModel.fromFirestore(doc);
  }

  @override
  Future<List<Product>> getAllProducts(String ownerId) async {
    final snapshot = await _collection(ownerId).orderBy('name').get();
    final products = <Product>[];
    for (final doc in snapshot.docs) {
      final categoryId = doc.data()['categoryId'] as String;
      final category = await _loadCategory(ownerId, categoryId);
      products.add(ProductModel.fromFirestore(doc, category));
    }
    return products;
  }

  @override
  Stream<List<Product>> watchProducts(String ownerId) {
    return _collection(ownerId).orderBy('name').snapshots().asyncMap(
      (snapshot) async {
        final products = <Product>[];
        for (final doc in snapshot.docs) {
          final categoryId = doc.data()['categoryId'] as String;
          final category = await _loadCategory(ownerId, categoryId);
          products.add(ProductModel.fromFirestore(doc, category));
        }
        return products;
      },
    );
  }

  @override
  Future<List<Product>> getLowStockProducts(String ownerId) async {
    final allProducts = await getAllProducts(ownerId);
    return allProducts.where((p) => p.isLowStock).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String ownerId, String categoryId) async {
    final snapshot = await _collection(ownerId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    final products = <Product>[];
    for (final doc in snapshot.docs) {
      final category = await _loadCategory(ownerId, categoryId);
      products.add(ProductModel.fromFirestore(doc, category));
    }
    return products;
  }

  @override
  Future<Product> addProduct(Product product) async {
    final model = ProductModel(
      id: '',
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      lowStockThreshold: product.lowStockThreshold,
      category: product.category,
      ownerId: product.ownerId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
    final docRef = await _collection(product.ownerId).add(model.toFirestore());
    return product.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      lowStockThreshold: product.lowStockThreshold,
      category: product.category,
      ownerId: product.ownerId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
    await _collection(product.ownerId).doc(product.id).update(model.toFirestore());
  }

  @override
  Future<void> updateProductQuantity(String productId, String ownerId, int newQuantity) async {
    await _collection(ownerId).doc(productId).update({
      'quantity': newQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteProduct(String productId, String ownerId) async {
    await _collection(ownerId).doc(productId).delete();
  }
}
