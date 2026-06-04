import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/features/categories/data/services/category_repository_impl.dart';
import 'package:stock_flutter/features/categories/domain/entities/category.dart';
import 'package:stock_flutter/features/categories/domain/repositories/category_repository.dart';
import 'package:stock_flutter/features/auth/application/auth_providers.dart';

/// Provider de l'implémentation du CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(firestoreProvider));
});

/// Stream de toutes les catégories (temps réel)
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(categoryRepositoryProvider).watchCategories(user.uid);
});

/// Notifier pour les opérations CRUD sur les catégories
class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(categoryRepositoryProvider).getAllCategories(user.uid);
  }

  Future<void> addCategory(String name, {String? description}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final category = Category(
      id: '',
      name: name,
      description: description,
      ownerId: user.uid,
      createdAt: DateTime.now(),
    );
    await ref.read(categoryRepositoryProvider).addCategory(category);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(categoryRepositoryProvider).deleteCategory(categoryId, user.uid);
    ref.invalidateSelf();
  }
}

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);
