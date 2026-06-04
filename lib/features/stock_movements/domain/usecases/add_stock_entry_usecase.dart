import 'package:stock_flutter/features/products/domain/entities/product.dart';
import 'package:stock_flutter/features/products/domain/repositories/product_repository.dart';
import 'package:stock_flutter/features/stock_movements/domain/entities/stock_movement.dart';
import 'package:stock_flutter/features/stock_movements/domain/repositories/stock_movement_repository.dart';

/// Use Case : Effectuer une entrée en stock
/// Équivalent à domain/usecase/ du professeur
class AddStockEntryUseCase {
  final StockMovementRepository _movementRepository;
  final ProductRepository _productRepository;

  const AddStockEntryUseCase(this._movementRepository, this._productRepository);

  Future<StockMovement> execute({
    required Product product,
    required int quantity,
    required String ownerId,
    String? note,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('La quantité doit être positive');
    }

    // Créer le mouvement d'entrée
    final movement = StockMovement(
      id: '', // généré par Firestore
      product: product,
      type: MovementType.entry,
      quantity: quantity,
      note: note,
      ownerId: ownerId,
      date: DateTime.now(),
    );

    // Sauvegarder le mouvement
    final savedMovement = await _movementRepository.addMovement(movement);

    // Mettre à jour la quantité du produit
    final newQuantity = product.quantity + quantity;
    await _productRepository.updateProductQuantity(product.id, ownerId, newQuantity);

    return savedMovement;
  }
}
