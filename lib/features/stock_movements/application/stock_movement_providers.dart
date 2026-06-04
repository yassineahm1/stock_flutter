import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_flutter/core/providers/firebase_providers.dart';
import 'package:stock_flutter/features/auth/application/auth_providers.dart';
import 'package:stock_flutter/features/products/application/product_providers.dart';
import 'package:stock_flutter/features/stock_movements/data/services/stock_movement_repository_impl.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/features/stock_movements/domain/repositories/stock_movement_repository.dart';
import 'package:stock_flutter/features/stock_movements/domain/usecases/add_stock_entry_usecase.dart';
import 'package:stock_flutter/features/stock_movements/domain/usecases/make_sale_usecase.dart';
import 'package:stock_flutter/features/products/domain/entities/product.dart';

/// Provider de l'implémentation du StockMovementRepository
final stockMovementRepositoryProvider = Provider<StockMovementRepository>((ref) {
  return StockMovementRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(productRepositoryImplProvider),
  );
});

/// Use cases
final addStockEntryUseCaseProvider = Provider<AddStockEntryUseCase>((ref) {
  return AddStockEntryUseCase(
    ref.watch(stockMovementRepositoryProvider),
    ref.watch(productRepositoryProvider),
  );
});

final makeSaleUseCaseProvider = Provider<MakeSaleUseCase>((ref) {
  return MakeSaleUseCase(
    ref.watch(stockMovementRepositoryProvider),
    ref.watch(productRepositoryProvider),
  );
});

/// Stream de tous les mouvements (temps réel)
final movementsStreamProvider = StreamProvider<List<StockMovement>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(stockMovementRepositoryProvider).watchMovements(user.uid);
});

/// Notifier pour les opérations sur les mouvements
class StockMovementNotifier extends AsyncNotifier<List<StockMovement>> {
  @override
  Future<List<StockMovement>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(stockMovementRepositoryProvider).getAllMovements(user.uid);
  }

  Future<void> addEntry(Product product, int quantity, {String? note}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(addStockEntryUseCaseProvider).execute(
        product: product,
        quantity: quantity,
        ownerId: user.uid,
        note: note,
      );
      return ref.read(stockMovementRepositoryProvider).getAllMovements(user.uid);
    });
  }

  Future<void> makeSale(Product product, int quantity, {double? salePrice, String? note}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(makeSaleUseCaseProvider).execute(
        product: product,
        quantity: quantity,
        ownerId: user.uid,
        salePrice: salePrice,
        note: note,
      );
      return ref.read(stockMovementRepositoryProvider).getAllMovements(user.uid);
    });
  }
}

final stockMovementNotifierProvider =
    AsyncNotifierProvider<StockMovementNotifier, List<StockMovement>>(
  StockMovementNotifier.new,
);
