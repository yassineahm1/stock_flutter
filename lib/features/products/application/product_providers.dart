import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/features/auth/application/auth_providers.dart';
import 'package:stock_flutter/features/products/data/services/product_repository_impl.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/products/domain/repositories/product_repository.dart';

/// Provider de l'implémentation du ProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(firestoreProvider));
});

/// Accès à l'impl concrète (pour usage interne data layer)
final productRepositoryImplProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(ref.watch(firestoreProvider));
});

/// Stream de tous les produits (temps réel)
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(productRepositoryProvider).watchProducts(user.uid);
});

/// Produits en dessous du seuil d'approvisionnement
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.read(productRepositoryProvider).getLowStockProducts(user.uid);
});

/// Notifier CRUD des produits
class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(productRepositoryProvider).getAllProducts(user.uid);
  }

  Future<void> addProduct(Product product) async {
    await ref.read(productRepositoryProvider).addProduct(product);
    ref.invalidateSelf();
  }

  Future<void> updateProduct(Product product) async {
    await ref.read(productRepositoryProvider).updateProduct(product);
    ref.invalidateSelf();
  }

  Future<void> deleteProduct(String productId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(productRepositoryProvider).deleteProduct(productId, user.uid);
    ref.invalidateSelf();
  }
}

final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, List<Product>>(ProductNotifier.new);
